From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 4/4] [bonding 2.4] Support old commands over new bonding ioctl
Date: Thu, 8 Jan 2004 18:25:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081825.54932.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Support old commands (enslave, release, change-active) over the new
bonding ioctl (SIOCBONDDEVICE).


diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Jan  8 18:03:27 2004
+++ b/drivers/net/bonding/bond_main.c	Thu Jan  8 18:03:29 2004
@@ -1955,6 +1955,86 @@ static int bond_ethtool_ioctl(struct net
 	}
 }
 
+static int bond_ioctl_slave_dev(struct bonding *bond, int cmd, void *addr)
+{
+	struct bond_ioctl_cmd bond_cmd;
+	struct net_device *slave_dev;
+	int prev_abi_ver = app_abi_ver;
+	int prev_orig_abi_ver = orig_app_abi_ver;
+	int res = 0;
+
+	if (copy_from_user(&bond_cmd, addr, sizeof(bond_cmd))) {
+		return -EFAULT;
+	}
+
+	bond_cmd.ifname[IFNAMSIZ - 1] = 0;
+
+	slave_dev = dev_get_by_name(bond_cmd.ifname);
+	if (!slave_dev) {
+		return -ENODEV;
+	}
+
+	/* This is for backward compatibility only.
+	 * Unconditionaly set both global abi_ver vars so we can block
+	 * old ioctls in bond_do_ioctl().
+	 */
+	orig_app_abi_ver = bond_cmd.abi_ver;
+	app_abi_ver = bond_cmd.abi_ver;
+
+	switch (cmd) {
+	case BOND_CMD_ENSLAVE:
+		res = bond_enslave(bond->dev, slave_dev, bond_cmd.abi_ver);
+		break;
+
+	case BOND_CMD_RELEASE:
+		res = bond_release(bond->dev, slave_dev);
+		break;
+
+	case BOND_CMD_CHANGE_ACTIVE:
+		res = bond_ioctl_change_active(bond->dev, slave_dev);
+		break;
+
+	default:
+		res = -EOPNOTSUPP;
+		break;
+	}
+
+	dev_put(slave_dev);
+
+	if (res < 0) {
+		/* The ioctl failed, so there's no point in changing the
+		 * orig_app_abi_ver. We'll restore it's value just in case
+		 * we've changed it earlier in this function.
+		 */
+		app_abi_ver = prev_abi_ver;
+		orig_app_abi_ver = prev_orig_abi_ver;
+	}
+
+	return res;
+}
+
+static int bond_ioctl_device(struct bonding *bond, void *addr)
+{
+	u32 cmd;
+
+	if (get_user(cmd, (u32 *) addr)) {
+		return -EFAULT;
+	}
+
+	switch (cmd) {
+	case BOND_CMD_ENSLAVE:
+	case BOND_CMD_RELEASE:
+	case BOND_CMD_CHANGE_ACTIVE:
+		/* these ioctl cmds receive a slave name as an arg */
+		return bond_ioctl_slave_dev(bond, cmd, addr);
+
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
 static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 {
 	struct bonding *bond = bond_dev->priv;
@@ -3214,6 +3294,7 @@ static struct net_device_stats *bond_get
 
 static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd)
 {
+	struct bonding *bond = bond_dev->priv;
 	struct net_device *slave_dev = NULL;
 	struct ifbond *u_binfo = NULL, k_binfo;
 	struct ifslave *u_sinfo = NULL, k_sinfo;
@@ -3224,6 +3305,10 @@ static int bond_do_ioctl(struct net_devi
 	dprintk("bond_ioctl: master=%s, cmd=%d\n",
 		bond_dev->name, cmd);
 
+	if (!capable(CAP_NET_ADMIN)) {
+		return -EPERM;
+	}
+
 	switch (cmd) {
 	case SIOCETHTOOL:
 		return bond_ethtool_ioctl(bond_dev, ifr);
@@ -3245,7 +3330,6 @@ static int bond_do_ioctl(struct net_devi
 		}
 
 		if (mii->reg_num == 1) {
-			struct bonding *bond = bond_dev->priv;
 			mii->val_out = 0;
 			read_lock_bh(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
@@ -3289,13 +3373,19 @@ static int bond_do_ioctl(struct net_devi
 		}
 
 		return res;
+	case SIOCBONDDEVICE:
+		return bond_ioctl_device(bond, ifr->ifr_data);
+
 	default:
 		/* Go on */
 		break;
 	}
 
-	if (!capable(CAP_NET_ADMIN)) {
-		return -EPERM;
+	if (orig_app_abi_ver > 2) {
+		/* Refuse to support old ioctls if the app has already
+		 * declared it is new enough for SIOCBONDDEVICE commands.
+		 */
+		return -EOPNOTSUPP;
 	}
 
 	if (orig_app_abi_ver == -1) {
diff -Nuarp a/include/linux/if_bonding.h b/include/linux/if_bonding.h
--- a/include/linux/if_bonding.h	Thu Jan  8 18:03:27 2004
+++ b/include/linux/if_bonding.h	Thu Jan  8 18:03:29 2004
@@ -112,6 +112,9 @@ struct ad_info {
 #define BOND_CMD_DRV_INFO	0x00000001
 #define BOND_CMD_ADD_BOND	0x00000002
 #define BOND_CMD_DEL_BOND	0x00000003
+#define BOND_CMD_ENSLAVE	0x00000004
+#define BOND_CMD_RELEASE	0x00000005
+#define BOND_CMD_CHANGE_ACTIVE	0x00000006
 
 /**
  * bond_ioctl_drv_info
@@ -127,6 +130,19 @@ struct bond_ioctl_drv_info {
 	char reserved[32];
 };
 
+/**
+ * bond_ioctl_cmd
+ *
+ * %BOND_CMD_ENSLAVE, %BOND_CMD_RELEASE and %BOND_CMD_CHANGE_ACTIVE pass the
+ * name of the slave to work on in @ifname.
+ */
+struct bond_ioctl_cmd {
+	__u32 cmd;
+	__u32 abi_ver;
+	__u32 num_prms;
+	char ifname[IFNAMSIZ];
+};
+
 #endif /* _LINUX_IF_BONDING_H */
 
 /*
