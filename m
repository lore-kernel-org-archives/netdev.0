From: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Subject: [PATCH 3/4] bonding: L2DA command IOCTL
Date: Thu, 21 Nov 2013 16:55:37 +0200
Message-ID: <1385045738-29726-4-git-send-email-Anton.Nayshtut@wilocity.com>
References: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Anton Nayshtut <Anton.Nayshtut@wilocity.com>,
	Erez Kirshenbaum <Erez.Kirshenbaum@wilocity.com>,
	Boris Lapshin <Boris.Lapshin@wilocity.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L2DA command IOCTL introduction. The SIOCBONDL2DACMD is used to control L2DA
bonding logic: change default slave, add and delete map entries.

Signed-off-by: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Signed-off-by: Erez Kirshenbaum <Erez.Kirshenbaum@wilocity.com>
Signed-off-by: Boris Lapshin <Boris.Lapshin@wilocity.com>
---
 drivers/net/bonding/bond_main.c | 52 +++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_bonding.h | 16 +++++++++++++
 include/uapi/linux/sockios.h    |  1 +
 net/core/dev_ioctl.c            |  2 ++
 net/socket.c                    |  2 ++
 5 files changed, 73 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 33733be..ddaee7b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1886,6 +1886,55 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 	return ret;
 }
 
+static int bond_ioctl_l2da_cmd(struct net_device *bond_dev,
+			       void __user *usr_data)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct l2da_cmd *u_l2dacmd = (struct l2da_cmd __user *)usr_data;
+	struct l2da_cmd  k_l2dacmd;
+	struct net_device *slave_dev;
+	struct slave *slave;
+	int res = -EFAULT;
+
+	if (copy_from_user(&k_l2dacmd, u_l2dacmd, sizeof(struct l2da_cmd)))
+		return res;
+
+	read_lock(&bond->lock);
+
+	if (!bond_is_l2da(bond))
+		goto out;
+
+	switch (k_l2dacmd.cmd) {
+	case BOND_L2DA_CMD_SET_DEFAULT:
+		slave_dev = dev_get_by_name(dev_net(bond_dev),
+					    k_l2dacmd.slave_name);
+		if (slave_dev) {
+			slave = bond_get_slave_by_dev(bond, slave_dev);
+			bond_l2da_set_default_slave(bond, slave);
+			dev_put(slave_dev);
+			res = 0;
+		}
+		break;
+	case BOND_L2DA_CMD_MAP_ADD:
+		slave_dev = dev_get_by_name(dev_net(bond_dev),
+					    k_l2dacmd.slave_name);
+		if (slave_dev) {
+			slave = bond_get_slave_by_dev(bond, slave_dev);
+			res = bond_l2da_set_da_slave(bond, k_l2dacmd.da, slave);
+			dev_put(slave_dev);
+		}
+		break;
+	case BOND_L2DA_CMD_MAP_DEL:
+		res = bond_l2da_del_da(bond, k_l2dacmd.da);
+		break;
+	default:
+		break;
+	}
+out:
+	read_unlock(&bond->lock);
+	return res;
+}
+
 static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -3262,6 +3311,9 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (cmd == SIOCBONDL2DACMD)
+		return bond_ioctl_l2da_cmd(bond_dev, ifr->ifr_data);
+
 	slave_dev = dev_get_by_name(net, ifr->ifr_slave);
 
 	pr_debug("slave_dev=%p:\n", slave_dev);
diff --git a/include/uapi/linux/if_bonding.h b/include/uapi/linux/if_bonding.h
index b70ff3e..a4d3baf 100644
--- a/include/uapi/linux/if_bonding.h
+++ b/include/uapi/linux/if_bonding.h
@@ -95,6 +95,11 @@
 #define BOND_XMIT_POLICY_ENCAP23	3 /* encapsulated layer 2+3 */
 #define BOND_XMIT_POLICY_ENCAP34	4 /* encapsulated layer 3+4 */
 
+/* l2da commands */
+#define BOND_L2DA_CMD_SET_DEFAULT    0 /* set default slave */
+#define BOND_L2DA_CMD_MAP_ADD        1 /* add DA:iface mapping */
+#define BOND_L2DA_CMD_MAP_DEL        2 /* add DA mapping */
+
 typedef struct ifbond {
 	__s32 bond_mode;
 	__s32 num_slaves;
@@ -117,6 +122,17 @@ struct ad_info {
 	__u8 partner_system[ETH_ALEN];
 };
 
+struct l2da_cmd {
+	__u16 cmd; /* one of the BOND_L2DA_CMD_... commands */
+	__u8 da[ETH_ALEN]; /* Used as IN parameter in:
+			    *   BOND_L2DA_CMD_MAP_ADD
+			    *   BOND_L2DA_CMD_MAP_DEL*/
+	char slave_name[IFNAMSIZ]; /* Used as IN parameter in:
+				    *   BOND_L2DA_CMD_SET_DEFAULT
+				    *   BOND_L2DA_CMD_MAP_ADD
+				    * */
+};
+
 #endif /* _LINUX_IF_BONDING_H */
 
 /*
diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
index 7997a50..2af055d 100644
--- a/include/uapi/linux/sockios.h
+++ b/include/uapi/linux/sockios.h
@@ -117,6 +117,7 @@
 #define SIOCBONDSLAVEINFOQUERY 0x8993   /* rtn info about slave state   */
 #define SIOCBONDINFOQUERY      0x8994	/* rtn info about bond state    */
 #define SIOCBONDCHANGEACTIVE   0x8995   /* update to a new active slave */
+#define SIOCBONDL2DACMD        0x8996   /* l2da related command */
 			
 /* bridge calls */
 #define SIOCBRADDBR     0x89a0		/* create new bridge device     */
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 5b7d0e1..3a4716a 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -321,6 +321,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		    cmd == SIOCBONDSLAVEINFOQUERY ||
 		    cmd == SIOCBONDINFOQUERY ||
 		    cmd == SIOCBONDCHANGEACTIVE ||
+		    cmd == SIOCBONDL2DACMD ||
 		    cmd == SIOCGMIIPHY ||
 		    cmd == SIOCGMIIREG ||
 		    cmd == SIOCSMIIREG ||
@@ -518,6 +519,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCBONDRELEASE:
 	case SIOCBONDSETHWADDR:
 	case SIOCBONDCHANGEACTIVE:
+	case SIOCBONDL2DACMD:
 	case SIOCBRADDIF:
 	case SIOCBRDELIF:
 	case SIOCSHWTSTAMP:
diff --git a/net/socket.c b/net/socket.c
index c226ace..2ed653b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2975,6 +2975,7 @@ static int bond_ioctl(struct net *net, unsigned int cmd,
 	case SIOCBONDRELEASE:
 	case SIOCBONDSETHWADDR:
 	case SIOCBONDCHANGEACTIVE:
+	case SIOCBONDL2DACMD:
 		if (copy_from_user(&kifr, ifr32, sizeof(struct compat_ifreq)))
 			return -EFAULT;
 
@@ -3262,6 +3263,7 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCBONDSLAVEINFOQUERY:
 	case SIOCBONDINFOQUERY:
 	case SIOCBONDCHANGEACTIVE:
+	case SIOCBONDL2DACMD:
 		return bond_ioctl(net, cmd, argp);
 	case SIOCADDRT:
 	case SIOCDELRT:
-- 
1.8.3.1
