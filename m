From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] rtnl: make ifla_policy static
Date: Tue, 18 Feb 2014 20:53:18 +0100
Message-ID: <1392753198-9437-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kaber@trash.net, xiyou.wangcong@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:65448 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaBRTxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 14:53:22 -0500
Received: by mail-ea0-f173.google.com with SMTP id d10so8155526eaj.4
        for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 11:53:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only place this is used outside rtnetlink.c is veth. So provide
wrapper function for this usage.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/veth.c      |   8 ++--
 include/net/rtnetlink.h |   2 +-
 net/core/rtnetlink.c    | 107 +++++++++++++++++++++++++-----------------------
 3 files changed, 61 insertions(+), 56 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 91c33c1..34b5263 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -14,6 +14,7 @@
 #include <linux/etherdevice.h>
 #include <linux/u64_stats_sync.h>
 
+#include <net/rtnetlink.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
 #include <linux/veth.h>
@@ -323,10 +324,9 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 		nla_peer = data[VETH_INFO_PEER];
 		ifmp = nla_data(nla_peer);
-		err = nla_parse(peer_tb, IFLA_MAX,
-				nla_data(nla_peer) + sizeof(struct ifinfomsg),
-				nla_len(nla_peer) - sizeof(struct ifinfomsg),
-				ifla_policy);
+		err = rtnl_nla_parse_ifla(peer_tb,
+					  nla_data(nla_peer) + sizeof(struct ifinfomsg),
+					  nla_len(nla_peer) - sizeof(struct ifinfomsg));
 		if (err < 0)
 			return err;
 
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 661e45d..72240e5 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -140,7 +140,7 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 				    struct nlattr *tb[]);
 int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm);
 
-extern const struct nla_policy ifla_policy[IFLA_MAX+1];
+int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len);
 
 #define MODULE_ALIAS_RTNL_LINK(kind) MODULE_ALIAS("rtnl-link-" kind)
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 048dc8d..7b2ad56 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1121,56 +1121,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
-{
-	struct net *net = sock_net(skb->sk);
-	int h, s_h;
-	int idx = 0, s_idx;
-	struct net_device *dev;
-	struct hlist_head *head;
-	struct nlattr *tb[IFLA_MAX+1];
-	u32 ext_filter_mask = 0;
-
-	s_h = cb->args[0];
-	s_idx = cb->args[1];
-
-	rcu_read_lock();
-	cb->seq = net->dev_base_seq;
-
-	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
-			ifla_policy) >= 0) {
-
-		if (tb[IFLA_EXT_MASK])
-			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
-	}
-
-	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
-		idx = 0;
-		head = &net->dev_index_head[h];
-		hlist_for_each_entry_rcu(dev, head, index_hlist) {
-			if (idx < s_idx)
-				goto cont;
-			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
-					     NETLINK_CB(cb->skb).portid,
-					     cb->nlh->nlmsg_seq, 0,
-					     NLM_F_MULTI,
-					     ext_filter_mask) <= 0)
-				goto out;
-
-			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
-cont:
-			idx++;
-		}
-	}
-out:
-	rcu_read_unlock();
-	cb->args[1] = idx;
-	cb->args[0] = h;
-
-	return skb->len;
-}
-
-const struct nla_policy ifla_policy[IFLA_MAX+1] = {
+static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_IFNAME]		= { .type = NLA_STRING, .len = IFNAMSIZ-1 },
 	[IFLA_ADDRESS]		= { .type = NLA_BINARY, .len = MAX_ADDR_LEN },
 	[IFLA_BROADCAST]	= { .type = NLA_BINARY, .len = MAX_ADDR_LEN },
@@ -1197,7 +1148,6 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
 };
-EXPORT_SYMBOL(ifla_policy);
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 	[IFLA_INFO_KIND]	= { .type = NLA_STRING },
@@ -1235,6 +1185,61 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
 };
 
+static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	int h, s_h;
+	int idx = 0, s_idx;
+	struct net_device *dev;
+	struct hlist_head *head;
+	struct nlattr *tb[IFLA_MAX+1];
+	u32 ext_filter_mask = 0;
+
+	s_h = cb->args[0];
+	s_idx = cb->args[1];
+
+	rcu_read_lock();
+	cb->seq = net->dev_base_seq;
+
+	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
+			ifla_policy) >= 0) {
+
+		if (tb[IFLA_EXT_MASK])
+			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+	}
+
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry_rcu(dev, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
+					     NETLINK_CB(cb->skb).portid,
+					     cb->nlh->nlmsg_seq, 0,
+					     NLM_F_MULTI,
+					     ext_filter_mask) <= 0)
+				goto out;
+
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
+cont:
+			idx++;
+		}
+	}
+out:
+	rcu_read_unlock();
+	cb->args[1] = idx;
+	cb->args[0] = h;
+
+	return skb->len;
+}
+
+int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len)
+{
+	return nla_parse(tb, IFLA_MAX, head, len, ifla_policy);
+}
+EXPORT_SYMBOL(rtnl_nla_parse_ifla);
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
-- 
1.8.5.3
