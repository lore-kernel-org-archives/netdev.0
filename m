From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Add support for filtering neigh dump by device index
Date: Sat,  3 Oct 2015 11:25:54 -0700
Message-ID: <1443896754-20065-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35170 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbJCS0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 14:26:03 -0400
Received: by pacfv12 with SMTP id fv12so138600385pac.2
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2015 11:26:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for filtering neighbor dumps by device by adding the
NDA_IFINDEX attribute to the dump request. When set the kernel only
sends neighbor entries for the given device.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/neighbour.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8c57fdf4d68e..f7786eaef613 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2249,6 +2249,14 @@ static bool neigh_master_filtered(struct net_device *dev, int master_idx)
 	return false;
 }
 
+static bool neigh_ifindex_filtered(struct net_device *dev, int filter_idx)
+{
+	if (filter_idx && dev->ifindex != filter_idx)
+		return true;
+
+	return false;
+}
+
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
 {
@@ -2259,16 +2267,19 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
 	struct neigh_hash_table *nht;
-	int filter_master_idx = 0;
+	int filter_master_idx = 0, filter_idx = 0;
 	unsigned int flags = NLM_F_MULTI;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(struct ndmsg), tb, NDA_MAX, NULL);
 	if (!err) {
+		if (tb[NDA_IFINDEX])
+			filter_idx = nla_get_u32(tb[NDA_IFINDEX]);
+
 		if (tb[NDA_MASTER])
 			filter_master_idx = nla_get_u32(tb[NDA_MASTER]);
 
-		if (filter_master_idx)
+		if (filter_idx | filter_master_idx)
 			flags |= NLM_F_DUMP_FILTERED;
 	}
 
@@ -2283,6 +2294,8 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		     n = rcu_dereference_bh(n->next)) {
 			if (!net_eq(dev_net(n->dev), net))
 				continue;
+			if (neigh_ifindex_filtered(n->dev, filter_idx))
+				continue;
 			if (neigh_master_filtered(n->dev, filter_master_idx))
 				continue;
 			if (idx < s_idx)
-- 
1.9.1
