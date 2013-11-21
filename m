From: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Subject: [PATCH 4/4] bonding: L2DA query IOCTL
Date: Thu, 21 Nov 2013 16:55:38 +0200
Message-ID: <1385045738-29726-5-git-send-email-Anton.Nayshtut@wilocity.com>
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

L2DA query IOCTL introduction. The SIOCBONDL2DAQUERY is used to get L2DA related
information: default slave and map entries.

Signed-off-by: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Signed-off-by: Erez Kirshenbaum <Erez.Kirshenbaum@wilocity.com>
Signed-off-by: Boris Lapshin <Boris.Lapshin@wilocity.com>
---
 drivers/net/bonding/bond_main.c | 69 +++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_bonding.h | 15 +++++++++
 include/uapi/linux/sockios.h    |  3 +-
 net/core/dev_ioctl.c            |  2 ++
 net/socket.c                    |  2 ++
 5 files changed, 90 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ddaee7b..ecfe349 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1935,6 +1935,59 @@ out:
 	return res;
 }
 
+struct bond_ioctl_l2da_query_clb_ctx {
+	int res;
+	__s32 i;
+	struct l2da_query *l2da_query;
+};
+
+static int bond_ioctl_l2da_query_clb(const unsigned char *da,
+				     struct slave *slave, void *_ctx)
+{
+	struct bond_ioctl_l2da_query_clb_ctx *ctx = _ctx;
+	if (ctx->i == ctx->l2da_query->entry_id) {
+		strcpy(ctx->l2da_query->slave_name, slave->dev->name);
+		memcpy(ctx->l2da_query->da, da, ETH_ALEN);
+		ctx->res = 0;
+		return 1;
+	}
+	++ctx->i;
+	return 0;
+}
+
+static int bond_ioctl_l2da_query(struct net_device *bond_dev,
+				 struct l2da_query *l2da_query)
+{
+	int res = -EINVAL;
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct bond_ioctl_l2da_query_clb_ctx ctx;
+
+	read_lock(&bond->lock);
+
+	if (!bond_is_l2da(bond))
+		goto out;
+
+	switch (l2da_query->query) {
+	case BOND_L2DA_QUERY_DEFAULT:
+		res = bond_l2da_get_default_slave_name(bond,
+					l2da_query->slave_name,
+					sizeof(l2da_query->slave_name));
+		break;
+	case BOND_L2DA_QUERY_MAP:
+		ctx.res        = res;
+		ctx.i          = 0;
+		ctx.l2da_query = l2da_query;
+		bond_l2da_call_foreach(bond, bond_ioctl_l2da_query_clb, &ctx);
+		res = ctx.res;
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
@@ -3239,6 +3292,8 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	struct ifbond __user *u_binfo = NULL;
 	struct ifslave k_sinfo;
 	struct ifslave __user *u_sinfo = NULL;
+	struct l2da_query k_l2da_query;
+	struct l2da_query __user *u_l2da_query = NULL;
 	struct mii_ioctl_data *mii = NULL;
 	struct net *net;
 	int res = 0;
@@ -3301,6 +3356,20 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 			return -EFAULT;
 
 		return res;
+	case SIOCBONDL2DAQUERY:
+		u_l2da_query = (struct l2da_query __user *)ifr->ifr_data;
+
+		if (copy_from_user(&k_l2da_query, u_l2da_query,
+				   sizeof(k_l2da_query)))
+			return -EFAULT;
+
+		res = bond_ioctl_l2da_query(bond_dev, &k_l2da_query);
+		if (res == 0 &&
+		    copy_to_user(u_l2da_query, &k_l2da_query,
+				 sizeof(k_l2da_query)))
+			return -EFAULT;
+
+		return res;
 	default:
 		/* Go on */
 		break;
diff --git a/include/uapi/linux/if_bonding.h b/include/uapi/linux/if_bonding.h
index a4d3baf..fdfe491 100644
--- a/include/uapi/linux/if_bonding.h
+++ b/include/uapi/linux/if_bonding.h
@@ -100,6 +100,10 @@
 #define BOND_L2DA_CMD_MAP_ADD        1 /* add DA:iface mapping */
 #define BOND_L2DA_CMD_MAP_DEL        2 /* add DA mapping */
 
+/* l2da queries */
+#define BOND_L2DA_QUERY_DEFAULT      0 /* get default slave */
+#define BOND_L2DA_QUERY_MAP          1 /* get map entry */
+
 typedef struct ifbond {
 	__s32 bond_mode;
 	__s32 num_slaves;
@@ -133,6 +137,17 @@ struct l2da_cmd {
 				    * */
 };
 
+struct l2da_query {
+	__u16 query; /* one of the BOND_L2DA_QUERY_... queries */
+	__s32 entry_id;  /* Used as IN parameter in:
+			  *   BOND_L2DA_QUERY_MAP */
+	__u8 da[ETH_ALEN]; /* Used as OUT parameter in:
+			    *   BOND_L2DA_QUERY_MAP */
+	char slave_name[IFNAMSIZ]; /* Used as OUT parameter in:
+				    *   BOND_L2DA_QUERY_DEFAULT
+				    *   BOND_L2DA_QUERY_MAP */
+};
+
 #endif /* _LINUX_IF_BONDING_H */
 
 /*
diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
index 2af055d..86b1d0a 100644
--- a/include/uapi/linux/sockios.h
+++ b/include/uapi/linux/sockios.h
@@ -118,7 +118,8 @@
 #define SIOCBONDINFOQUERY      0x8994	/* rtn info about bond state    */
 #define SIOCBONDCHANGEACTIVE   0x8995   /* update to a new active slave */
 #define SIOCBONDL2DACMD        0x8996   /* l2da related command */
-			
+#define SIOCBONDL2DAQUERY      0x8997   /* l2da related query */
+
 /* bridge calls */
 #define SIOCBRADDBR     0x89a0		/* create new bridge device     */
 #define SIOCBRDELBR     0x89a1		/* remove bridge device         */
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 3a4716a..f189744 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -322,6 +322,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		    cmd == SIOCBONDINFOQUERY ||
 		    cmd == SIOCBONDCHANGEACTIVE ||
 		    cmd == SIOCBONDL2DACMD ||
+		    cmd == SIOCBONDL2DAQUERY ||
 		    cmd == SIOCGMIIPHY ||
 		    cmd == SIOCGMIIREG ||
 		    cmd == SIOCSMIIREG ||
@@ -528,6 +529,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		/* fall through */
 	case SIOCBONDSLAVEINFOQUERY:
 	case SIOCBONDINFOQUERY:
+	case SIOCBONDL2DAQUERY:
 		dev_load(net, ifr.ifr_name);
 		rtnl_lock();
 		ret = dev_ifsioc(net, &ifr, cmd);
diff --git a/net/socket.c b/net/socket.c
index 2ed653b..e4524f5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2988,6 +2988,7 @@ static int bond_ioctl(struct net *net, unsigned int cmd,
 		return err;
 	case SIOCBONDSLAVEINFOQUERY:
 	case SIOCBONDINFOQUERY:
+	case SIOCBONDL2DAQUERY:
 		uifr = compat_alloc_user_space(sizeof(*uifr));
 		if (copy_in_user(&uifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
 			return -EFAULT;
@@ -3264,6 +3265,7 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCBONDINFOQUERY:
 	case SIOCBONDCHANGEACTIVE:
 	case SIOCBONDL2DACMD:
+	case SIOCBONDL2DAQUERY:
 		return bond_ioctl(net, cmd, argp);
 	case SIOCADDRT:
 	case SIOCDELRT:
-- 
1.8.3.1
