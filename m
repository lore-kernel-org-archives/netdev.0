From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Add support for filtering neigh dump by master device
Date: Thu, 24 Sep 2015 16:04:53 -0600
Message-ID: <1443132293-67841-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34578 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397AbbIXWE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 18:04:57 -0400
Received: by iofb144 with SMTP id b144so92687086iof.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 15:04:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for filtering neighbor dumps by master device by adding
the NDA_MASTER attribute to the dump request.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
This method works for other filters as well and other dump commands
as well. Works fine for all combinations of new and old kernel and ip:
1. new ip command on old kernel, NDA_MASTER attribute is ignored
2. old ip command on new kernel, NDA_MASTER attribute is not present
3. new ip on new kernel ... goodness ensues by limiting data to
   only what user wants

 net/core/neighbour.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2b515ba7e94f..f686c524ce7e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2235,14 +2235,36 @@ static void neigh_update_notify(struct neighbour *neigh)
 	__neigh_notify(neigh, RTM_NEWNEIGH, 0);
 }
 
+static bool neigh_master_filtered(struct net_device *dev, int master_idx)
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
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
+	const struct nlmsghdr *nlh = cb->nlh;
+	struct nlattr *tb[NDA_MAX + 1];
 	struct neighbour *n;
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
 	struct neigh_hash_table *nht;
+	int filter_master_idx = 0;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(struct ndmsg), tb, NDA_MAX, NULL);
+	if (!err && tb[NDA_MASTER])
+		filter_master_idx = nla_get_u32(tb[NDA_MASTER]);
 
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
@@ -2255,6 +2277,8 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		     n = rcu_dereference_bh(n->next)) {
 			if (!net_eq(dev_net(n->dev), net))
 				continue;
+			if (neigh_master_filtered(n->dev, filter_master_idx))
+				continue;
 			if (idx < s_idx)
 				goto next;
 			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
-- 
2.3.8 (Apple Git-58)
