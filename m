From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 3/4] [bonding 2.6] Add support for the bond_hook in bonding
Date: Thu, 8 Jan 2004 18:29:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081829.54372.amir.noam@intel.com>
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

Add support for the bond_hook in bonding, and use it to export some
parameters to the calling app. These parameters will be needed later
by the application for dynamic configuration of bonding interfaces.


diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Jan  8 18:06:49 2004
+++ b/drivers/net/bonding/bond_main.c	Thu Jan  8 18:06:50 2004
@@ -599,6 +599,7 @@ static struct bond_parm_tbl bond_mode_tb
 
 /*-------------------------- Forward declarations ---------------------------*/
 
+extern void bond_ioctl_set(int (*hook)(unsigned long));
 static inline void bond_set_mode_ops(struct net_device *bond_dev, int mode);
 
 /*---------------------------- General routines -----------------------------*/
@@ -3898,6 +3899,57 @@ static void bond_free_all(void)
 #endif
 }
 
+static int bond_ioctl_deviceless(unsigned long arg)
+{
+	void *addr = (void *)arg;
+	u32 cmd;
+
+	if (!capable(CAP_NET_ADMIN)) {
+		return -EPERM;
+	}
+
+	if (get_user(cmd, (u32 *)addr)) {
+		return -EFAULT;
+	}
+
+	switch (cmd) {
+	case BOND_CMD_DRV_INFO: {
+		struct bond_ioctl_drv_info drvinfo;
+
+		if (copy_from_user(&drvinfo, addr, sizeof(drvinfo))) {
+			return -EFAULT;
+		}
+
+		/* This is for backward compatibility only.
+		 * Unconditionaly set both global abi_ver vars so we can block
+		 * old ioctls in bond_do_ioctl().
+		 */
+		orig_app_abi_ver = drvinfo.abi_ver;
+		app_abi_ver = drvinfo.abi_ver;
+
+		drvinfo.abi_ver = BOND_ABI_VERSION;
+		drvinfo.num_prms = 0;
+		drvinfo.num_arp_targets = BOND_MAX_ARP_TARGETS;
+
+		if (copy_to_user(addr, &drvinfo, sizeof(drvinfo))) {
+			return -EFAULT;
+		}
+
+		break;
+	}
+
+	/* TODO: implement dynamic add/del of bond interfaces
+	case BOND_CMD_ADD_BOND:
+	case BOND_CMD_DEL_BOND:
+	*/
+
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
 /*------------------------- Module initialization ---------------------------*/
 
 /*
@@ -4219,6 +4271,8 @@ static int __init bonding_init(void)
 	}
 
 	rtnl_unlock();
+
+	bond_ioctl_set(bond_ioctl_deviceless);
 	register_netdevice_notifier(&bond_netdev_notifier);
 
 	return 0;
@@ -4235,6 +4289,7 @@ out_err:
 static void __exit bonding_exit(void)
 {
 	unregister_netdevice_notifier(&bond_netdev_notifier);
+	bond_ioctl_set(NULL);
 
 	rtnl_lock();
 	bond_free_all();
diff -Nuarp a/include/linux/if_bonding.h b/include/linux/if_bonding.h
--- a/include/linux/if_bonding.h	Thu Jan  8 18:06:49 2004
+++ b/include/linux/if_bonding.h	Thu Jan  8 18:06:50 2004
@@ -103,6 +103,30 @@ struct ad_info {
 	__u8 partner_system[ETH_ALEN];
 };
 
+
+/*
+ * The following are the available command codes for the SIOCBONDING and
+ * SIOCBONDDEVICE ioctls. The command codes are the first u32 value of the
+ * passed struct. The second u32 value is the ABI version of the application.
+ */
+#define BOND_CMD_DRV_INFO	0x00000001
+#define BOND_CMD_ADD_BOND	0x00000002
+#define BOND_CMD_DEL_BOND	0x00000003
+
+/**
+ * bond_ioctl_drv_info
+ *
+ * Used by the %BOND_CMD_DRV_INFO command to retrieve some parameters of the
+ * bonding driver.
+ */
+struct bond_ioctl_drv_info {
+	__u32 cmd;
+	__u32 abi_ver;
+	__u32 num_prms;
+	__u32 num_arp_targets;
+	char reserved[32];
+};
+
 #endif /* _LINUX_IF_BONDING_H */
 
 /*
