From: Christian Benvenuti <benve@cisco.com>
Subject: [RFC][net-next-2.6 PATCH 1/2] Add new protocol nested
	IFLA_PORT_PROTO_* attr
Date: Tue, 07 Dec 2010 20:31:01 -0800
Message-ID: <20101208042953.16856.38217.stgit@savbu-pc100.cisco.com>
References: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:4955 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab0LHEbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 23:31:03 -0500
In-Reply-To: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Benvenuti <benve@cisco.com>



Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 include/linux/if_link.h |   31 +++++++++++++++++++++++++++++--
 include/net/rtnetlink.h |    3 +++
 net/core/rtnetlink.c    |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 76 insertions(+), 3 deletions(-)


diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 6485d2a..6f331aa 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -332,12 +332,14 @@ enum {
 enum {
 	IFLA_PORT_UNSPEC,
 	IFLA_PORT_VF,			/* __u32 */
-	IFLA_PORT_PROFILE,		/* string */
-	IFLA_PORT_VSI_TYPE,		/* 802.1Qbg (pre-)standard VDP */
+	IFLA_PORT_PROFILE,		/* (deprecated) */
+	IFLA_PORT_VSI_TYPE,		/* (deprecated) */
 	IFLA_PORT_INSTANCE_UUID,	/* binary UUID */
 	IFLA_PORT_HOST_UUID,		/* binary UUID */
 	IFLA_PORT_REQUEST,		/* __u8 */
 	IFLA_PORT_RESPONSE,		/* __u16, output only */
+	IFLA_PORT_PROTO_8021QBH,
+	IFLA_PORT_PROTO_8021QBG,
 	__IFLA_PORT_MAX,
 };
 
@@ -378,4 +380,29 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+enum port_proto {
+	PORT_PROTO_UNSPEC,
+	PORT_PROTO_8021QBH,
+	PORT_PROTO_8021QBG,
+	__PORT_PROTO_MAX,
+};
+
+#define PORT_PROTO_MAX (__PORT_PROTO_MAX - 1)
+
+enum {
+	IFLA_PORT_8021QBG_UNSPEC,
+	IFLA_PORT_8021QBG_VSI_TYPE,	/* (pre-)standard VDP */
+	__IFLA_PORT_8021QBG_MAX,
+};
+
+#define IFLA_PORT_8021QBG_MAX (__IFLA_PORT_8021QBG_MAX - 1)
+
+enum {
+	IFLA_PORT_8021QBH_UNSPEC,
+	IFLA_PORT_8021QBH_PROFILE,
+	__IFLA_PORT_8021QBH_MAX,
+};
+
+#define IFLA_PORT_8021QBH_MAX (__IFLA_PORT_8021QBH_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 4093ca7..bea154c 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -118,6 +118,9 @@ extern int	rtnl_af_register(struct rtnl_af_ops *ops);
 extern void	rtnl_af_unregister(struct rtnl_af_ops *ops);
 
 
+extern int	rtnl_link_parse_port_proto(enum port_proto proto,
+					   struct nlattr *proto_attr,
+					   struct nlattr *tb[]);
 extern struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
 extern struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 	char *ifname, const struct rtnl_link_ops *ops, struct nlattr *tb[]);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 750db57..7390b60 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -723,7 +723,15 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		+ nla_total_size(PORT_UUID_MAX)		/* PORT_INSTANCE_UUID */
 		+ nla_total_size(PORT_UUID_MAX)		/* PORT_HOST_UUID */
 		+ nla_total_size(1)			/* PROT_VDP_REQUEST */
-		+ nla_total_size(2);			/* PORT_VDP_RESPONSE */
+		+ nla_total_size(2)			/* PORT_VDP_RESPONSE */
+
+		+ nla_total_size(0)			/* PROTO_8021QBH */
+		+ nla_total_size(PORT_PROFILE_MAX)	/* 8021QBH_PROFILE */
+
+		+ nla_total_size(0)			/* PROTO_8021QBG */
+		+ nla_total_size(sizeof(struct ifla_port_vsi));
+							/* 8021QBG_VSI */
+
 	size_t vf_ports_size = nla_total_size(sizeof(struct nlattr));
 	size_t vf_port_size = nla_total_size(sizeof(struct nlattr))
 		+ port_size;
@@ -1067,6 +1075,18 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_tx_rate) },
 };
 
+static
+const struct nla_policy ifla_port_8021qbh_policy[IFLA_PORT_8021QBH_MAX+1] = {
+	[IFLA_PORT_8021QBH_PROFILE] = { .type = NLA_STRING,
+					.len = PORT_PROFILE_MAX },
+};
+
+static
+const struct nla_policy ifla_port_8021qbg_policy[IFLA_PORT_8021QBG_MAX+1] = {
+	[IFLA_PORT_8021QBG_VSI_TYPE] = { .type = NLA_BINARY,
+					 .len = sizeof(struct ifla_port_vsi)},
+};
+
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_VF]		= { .type = NLA_U32 },
 	[IFLA_PORT_PROFILE]	= { .type = NLA_STRING,
@@ -1079,8 +1099,31 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 				    .len = PORT_UUID_MAX },
 	[IFLA_PORT_REQUEST]	= { .type = NLA_U8, },
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
+	[IFLA_PORT_PROTO_8021QBH]	= { .type = NLA_NESTED },
+	[IFLA_PORT_PROTO_8021QBG]	= { .type = NLA_NESTED },
 };
 
+int rtnl_link_parse_port_proto(enum port_proto proto, struct nlattr *proto_attr,
+			       struct nlattr *tb[])
+{
+	if ((proto > PORT_PROTO_MAX) || (proto_attr == NULL) || (tb == NULL))
+		return -EINVAL;
+
+	switch (proto) {
+	case PORT_PROTO_UNSPEC:
+		return -EINVAL;
+	case PORT_PROTO_8021QBH:
+		return nla_parse_nested(tb, IFLA_PORT_8021QBH_MAX,
+					proto_attr, ifla_port_8021qbh_policy);
+	case PORT_PROTO_8021QBG:
+		return nla_parse_nested(tb, IFLA_PORT_8021QBG_MAX,
+					proto_attr, ifla_port_8021qbg_policy);
+	default:
+		return -ENOTSUPP;
+	}
+}
+EXPORT_SYMBOL(rtnl_link_parse_port_proto);
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;

