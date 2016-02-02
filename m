From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Add support for filtering link dump by master device and kind
Date: Tue,  2 Feb 2016 08:17:07 -0800
Message-ID: <1454429827-16841-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nikolay@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34374 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbcBBQRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:17:15 -0500
Received: by mail-pa0-f51.google.com with SMTP id uo6so103164842pac.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:17:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for filtering link dumps by master device and kind, similar
to the filtering implemented for neighbor dumps.

Each net_device that exists adds between 1196 bytes (eth) and 1556 bytes
(bridge) to the link dump. As the number of interfaces increases so does
the amount of data pushed to user space for a link list. If the user
only wants to see a list of specific devices (e.g., interfaces enslaved
to a specific bridge or a list of VRFs) most of that data is thrown away.
Passing the filters to the kernel to have only relevant data returned
makes the dump more efficient.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 67 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d735e854f916..1cca63032949 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1412,6 +1412,58 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
 };
 
+static const struct rtnl_link_ops *linkinfo_to_kind_ops(const struct nlattr *nla)
+{
+	const struct rtnl_link_ops *ops = NULL;
+	struct nlattr *linfo[IFLA_INFO_MAX + 1];
+
+	if (nla_parse_nested(linfo, IFLA_INFO_MAX, nla, ifla_info_policy) < 0)
+		return NULL;
+
+	if (linfo[IFLA_INFO_KIND]) {
+		char kind[MODULE_NAME_LEN];
+
+		nla_strlcpy(kind, linfo[IFLA_INFO_KIND], sizeof(kind));
+		ops = rtnl_link_ops_get(kind);
+	}
+
+	return ops;
+}
+
+static bool link_master_filtered(struct net_device *dev, int master_idx)
+{
+	struct net_device *master;
+
+	if (!master_idx)
+		return false;
+
+	master = netdev_master_upper_dev_get(dev);
+	if (!master || master->ifindex != master_idx)
+		return true;
+
+	return false;
+}
+
+static bool link_kind_filtered(const struct net_device *dev,
+			       const struct rtnl_link_ops *kind_ops)
+{
+	if (kind_ops && dev->rtnl_link_ops != kind_ops)
+		return true;
+
+	return false;
+}
+
+static bool link_dump_filtered(struct net_device *dev,
+			       int master_idx,
+			       const struct rtnl_link_ops *kind_ops)
+{
+	if (link_master_filtered(dev, master_idx) ||
+	    link_kind_filtered(dev, kind_ops))
+		return true;
+
+	return false;
+}
+
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1421,6 +1473,9 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	struct hlist_head *head;
 	struct nlattr *tb[IFLA_MAX+1];
 	u32 ext_filter_mask = 0;
+	const struct rtnl_link_ops *kind_ops = NULL;
+	unsigned int flags = NLM_F_MULTI;
+	int master_idx = 0;
 	int err;
 	int hdrlen;
 
@@ -1443,18 +1498,29 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 
 		if (tb[IFLA_EXT_MASK])
 			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+
+		if (tb[IFLA_MASTER])
+			master_idx = nla_get_u32(tb[IFLA_MASTER]);
+
+		if (tb[IFLA_LINKINFO])
+			kind_ops = linkinfo_to_kind_ops(tb[IFLA_LINKINFO]);
+
+		if (master_idx || kind_ops)
+			flags |= NLM_F_DUMP_FILTERED;
 	}
 
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
 		hlist_for_each_entry(dev, head, index_hlist) {
+			if (link_dump_filtered(dev, master_idx, kind_ops))
+				continue;
 			if (idx < s_idx)
 				goto cont;
 			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, 0,
-					       NLM_F_MULTI,
+					       flags,
 					       ext_filter_mask);
 			/* If we ran out of room on the first message,
 			 * we're in trouble
-- 
2.1.4
