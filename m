From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v4 2/4] netlink: changes for setting and clearing protodown via netlink.
Date: Wed,  8 Jul 2015 14:04:23 -0700
Message-ID: <1436389465-3077-3-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33020 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758261AbbGHVEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:04:40 -0400
Received: by pdbqm3 with SMTP id qm3so8378987pdb.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:04:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

A nested attribute has been added allowing apps to update bits
(IF_PROTOF_DOWN) in the proto_flags field.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |   10 ++++++++
 net/core/rtnetlink.c         |   57 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 2c7e8e3..cadfc1a 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -148,6 +148,7 @@ enum {
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
 	IFLA_PHYS_PORT_NAME,
+	IFLA_PROTO_FLAGS_INFO,
 	__IFLA_MAX
 };
 
@@ -651,4 +652,13 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* proto_flags section */
+enum {
+	IFLA_PROTO_FLAGS_UNSPEC,
+	IFLA_PROTO_FLAGS_VAL,
+	IFLA_PROTO_FLAGS_CHANGE,
+	__IFLA_PROTO_FLAGS_MAX,
+};
+
+#define IFLA_PROTO_FLAGS_MAX (__IFLA_PROTO_FLAGS_MAX - 1)
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 01ced4a..3a49d45 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -864,6 +864,16 @@ static size_t rtnl_port_size(const struct net_device *dev,
 		return port_self_size;
 }
 
+static size_t rtnl_proto_flags_info_size(const struct net_device *dev)
+{
+	size_t proto_flags_size =
+		nla_total_size(sizeof(struct nlattr))
+		+ nla_total_size(4)	/* IFLA_PROTO_FLAGS_VAL */
+		+ nla_total_size(4);	/* IFLA_PROTO_FLAGS_CHANGE */
+
+	return proto_flags_size;
+}
+
 static noinline size_t if_nlmsg_size(const struct net_device *dev,
 				     u32 ext_filter_mask)
 {
@@ -896,7 +906,9 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
-	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_SWITCH_ID */
+	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
+	       + rtnl_proto_flags_info_size(dev); /* IFLA_PROTO_FLAGS_INFO */
+
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -1046,6 +1058,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
 	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
+	struct nlattr *proto_flags_info;
 
 	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -1282,6 +1295,14 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 
 	nla_nest_end(skb, af_spec);
 
+	proto_flags_info = nla_nest_start(skb, IFLA_PROTO_FLAGS_INFO);
+	if (!proto_flags_info)
+		goto nla_put_failure;
+	if (nla_put_u32(skb, IFLA_PROTO_FLAGS_VAL, dev->proto_flags) ||
+	    nla_put_u32(skb, IFLA_PROTO_FLAGS_CHANGE, ~0))
+		goto nla_put_failure;
+	nla_nest_end(skb, proto_flags_info);
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
@@ -1319,6 +1340,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
 	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
+	[IFLA_PROTO_FLAGS_INFO]	= {. type = NLA_NESTED },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1366,6 +1388,12 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
 };
 
+static const struct nla_policy
+	ifla_proto_flags_policy[IFLA_PROTO_FLAGS_MAX + 1] = {
+	[IFLA_PROTO_FLAGS_VAL]		= { .type = NLA_U32 },
+	[IFLA_PROTO_FLAGS_CHANGE]	= { .type = NLA_U32 },
+};
+
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1853,6 +1881,33 @@ static int do_setlink(const struct sk_buff *skb,
 	}
 	err = 0;
 
+	if (tb[IFLA_PROTO_FLAGS_INFO]) {
+		struct nlattr *proto_flags[IFLA_PROTO_FLAGS_MAX + 1];
+		int rem;
+		unsigned int pflags;
+		unsigned int pchange;
+
+		err = nla_parse_nested(proto_flags, IFLA_PROTO_FLAGS_MAX,
+				       tb[IFLA_PROTO_FLAGS_INFO],
+				       ifla_proto_flags_policy);
+		if (err < 0)
+			goto errout;
+
+		if (!proto_flags[IFLA_PROTO_FLAGS_VAL] ||
+		    !proto_flags[IFLA_PROTO_FLAGS_CHANGE]) {
+			err = -EOPNOTSUPP;
+			goto errout;
+		}
+		pflags = nla_get_u32(proto_flags[IFLA_PROTO_FLAGS_VAL]);
+		pchange = nla_get_u32(proto_flags[IFLA_PROTO_FLAGS_CHANGE]);
+		pflags = (pflags & pchange) | (dev->proto_flags & ~pchange);
+		err = dev_change_proto_flags(dev, pflags);
+		if (err < 0)
+			goto errout;
+
+		status |= DO_SETLINK_NOTIFY;
+	}
+	err = 0;
 errout:
 	if (status & DO_SETLINK_MODIFIED) {
 		if (status & DO_SETLINK_NOTIFY)
-- 
1.7.10.4
