From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 06/12] net/core: Add rtnetlink support to vif parameters
Date: Wed,  1 Aug 2012 20:09:29 +0300
Message-ID: <1343840975-3252-7-git-send-email-ogerlitz@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:33737 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753502Ab2HARJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 13:09:59 -0400
In-Reply-To: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

Add IFLA_VIF_INFO which allows user space to configure mac/vlan for a VIF

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/if_link.h |   16 ++++++++++++++++
 net/core/rtnetlink.c    |   42 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 57 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index ac173bd..2a401f3 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -142,6 +142,7 @@ enum {
 #define IFLA_PROMISCUITY IFLA_PROMISCUITY
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
+	IFLA_VIFINFO_LIST,/* config virtual interface, gives it mac/vlan */
 	__IFLA_MAX
 };
 
@@ -398,4 +399,19 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* support vif configuration. */
+enum {
+	IFLA_VIF_INFO_UNSPEC,
+	IFLA_VIF_INFO,
+	__IFLA_VIF_INFO_MAX,
+};
+
+#define IFLA_VIF_INFO_MAX (__IFLA_VIF_INFO_MAX - 1)
+
+struct ifla_vif_param {
+	__u32 vif;
+	__u8  mac[32]; /* MAX_ADDR_LEN */
+	__u16 vlan;
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 334b930..751e55d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -780,7 +780,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
-	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
+	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+	       + nla_total_size(sizeof(struct ifla_vif_param)); /* IFLA_VIF_INFO */
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -1114,6 +1115,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
 	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
+	[IFLA_VIFINFO_LIST]     = {. type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1137,6 +1139,11 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_spoofchk) },
 };
 
+static const struct nla_policy ifla_vifinfo_policy[IFLA_VIF_INFO_MAX+1] = {
+	[IFLA_VIF_INFO]		= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vif_param)},
+};
+
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_VF]		= { .type = NLA_U32 },
 	[IFLA_PORT_PROFILE]	= { .type = NLA_STRING,
@@ -1258,6 +1265,22 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 	return err;
 }
 
+static int do_setvifinfo(struct net_device *dev, struct ifla_vif_param *ivp)
+{
+	int  err = -EINVAL;
+	struct net_device *vif_dev = __dev_get_by_index(dev_net(dev),
+							    ivp->vif);
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (ops->ndo_set_vif_param)
+		err = ops->ndo_set_vif_param(dev,
+					     vif_dev,
+					     ivp->vlan,
+					     ivp->mac);
+
+	return err;
+}
+
 static int do_set_master(struct net_device *dev, int ifindex)
 {
 	struct net_device *master_dev;
@@ -1449,8 +1472,25 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			modified = 1;
 		}
 	}
+
 	err = 0;
+	if (tb[IFLA_VIFINFO_LIST]) {
+		struct nlattr *vif_param_info[IFLA_VIF_INFO_MAX + 1];
+		struct ifla_vif_param ivp;
+		err = nla_parse_nested(vif_param_info, IFLA_VIF_INFO_MAX,
+				       tb[IFLA_VIFINFO_LIST], ifla_vifinfo_policy);
+		if (err < 0)
+			return err;
+		if (vif_param_info[IFLA_VIF_INFO]) {
+			nla_memcpy(&ivp, vif_param_info[IFLA_VIF_INFO], sizeof(ivp));
+			err = do_setvifinfo(dev, &ivp);
+			if (err < 0)
+				goto errout;
+			modified = 1;
+		}
+	}
 
+	err = 0;
 	if (tb[IFLA_VF_PORTS]) {
 		struct nlattr *port[IFLA_PORT_MAX+1];
 		struct nlattr *attr;
-- 
1.7.1
