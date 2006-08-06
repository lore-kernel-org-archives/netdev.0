From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/7] [NEIGH]: Convert neighbour dumping to new netlink api
Date: Mon, 07 Aug 2006 00:00:03 +0200
Message-ID: <20060807171050.299057210@postel.suug.ch>
References: <20060807170944.259251279@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2510 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932066AbWHGRMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 13:12:20 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_neigh_dump
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/neighbour.c
===================================================================
--- net-2.6.19.git.orig/net/core/neighbour.c
+++ net-2.6.19.git/net/core/neighbour.c
@@ -1898,48 +1898,49 @@ out:
 	return skb->len;
 }
 
-static int neigh_fill_info(struct sk_buff *skb, struct neighbour *n,
-			   u32 pid, u32 seq, int event, unsigned int flags)
+static int neigh_fill_info(struct sk_buff *skb, struct neighbour *neigh,
+			   u32 pid, u32 seq, int type, unsigned int flags)
 {
 	unsigned long now = jiffies;
-	unsigned char *b = skb->tail;
 	struct nda_cacheinfo ci;
-	int locked = 0;
-	u32 probes;
-	struct nlmsghdr *nlh = NLMSG_NEW(skb, pid, seq, event,
-					 sizeof(struct ndmsg), flags);
-	struct ndmsg *ndm = NLMSG_DATA(nlh);
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
 
-	ndm->ndm_family	 = n->ops->family;
+	ndm = nlmsg_data(nlh);
+	ndm->ndm_family	 = neigh->ops->family;
 	ndm->ndm_pad1    = 0;
 	ndm->ndm_pad2    = 0;
-	ndm->ndm_flags	 = n->flags;
-	ndm->ndm_type	 = n->type;
-	ndm->ndm_ifindex = n->dev->ifindex;
-	RTA_PUT(skb, NDA_DST, n->tbl->key_len, n->primary_key);
-	read_lock_bh(&n->lock);
-	locked		 = 1;
-	ndm->ndm_state	 = n->nud_state;
-	if (n->nud_state & NUD_VALID)
-		RTA_PUT(skb, NDA_LLADDR, n->dev->addr_len, n->ha);
-	ci.ndm_used	 = now - n->used;
-	ci.ndm_confirmed = now - n->confirmed;
-	ci.ndm_updated	 = now - n->updated;
-	ci.ndm_refcnt	 = atomic_read(&n->refcnt) - 1;
-	probes = atomic_read(&n->probes);
-	read_unlock_bh(&n->lock);
-	locked		 = 0;
-	RTA_PUT(skb, NDA_CACHEINFO, sizeof(ci), &ci);
-	RTA_PUT(skb, NDA_PROBES, sizeof(probes), &probes);
-	nlh->nlmsg_len	 = skb->tail - b;
-	return skb->len;
+	ndm->ndm_flags	 = neigh->flags;
+	ndm->ndm_type	 = neigh->type;
+	ndm->ndm_ifindex = neigh->dev->ifindex;
+
+	NLA_PUT(skb, NDA_DST, neigh->tbl->key_len, neigh->primary_key);
+
+	read_lock_bh(&neigh->lock);
+	ndm->ndm_state	 = neigh->nud_state;
+	if ((neigh->nud_state & NUD_VALID) &&
+	    nla_put(skb, NDA_LLADDR, neigh->dev->addr_len, neigh->ha) < 0) {
+		read_unlock_bh(&neigh->lock);
+		goto nla_put_failure;
+	}
 
-nlmsg_failure:
-rtattr_failure:
-	if (locked)
-		read_unlock_bh(&n->lock);
-	skb_trim(skb, b - skb->data);
-	return -1;
+	ci.ndm_used	 = now - neigh->used;
+	ci.ndm_confirmed = now - neigh->confirmed;
+	ci.ndm_updated	 = now - neigh->updated;
+	ci.ndm_refcnt	 = atomic_read(&neigh->refcnt) - 1;
+	read_unlock_bh(&neigh->lock);
+
+	NLA_PUT_U32(skb, NDA_PROBES, atomic_read(&neigh->probes));
+	NLA_PUT(skb, NDA_CACHEINFO, sizeof(ci), &ci);
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 
@@ -1983,7 +1984,7 @@ int neigh_dump_info(struct sk_buff *skb,
 	int t, family, s_t;
 
 	read_lock(&neigh_tbl_lock);
-	family = ((struct rtgenmsg *)NLMSG_DATA(cb->nlh))->rtgen_family;
+	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 	s_t = cb->args[0];
 
 	for (tbl = neigh_tables, t = 0; tbl; tbl = tbl->next, t++) {
@@ -2364,39 +2365,34 @@ static struct file_operations neigh_stat
 #ifdef CONFIG_ARPD
 void neigh_app_ns(struct neighbour *n)
 {
-	struct nlmsghdr  *nlh;
-	int size = NLMSG_SPACE(sizeof(struct ndmsg) + 256);
-	struct sk_buff *skb = alloc_skb(size, GFP_ATOMIC);
+	struct sk_buff *skb;
 
-	if (!skb)
+	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (skb == NULL)
 		return;
 
-	if (neigh_fill_info(skb, n, 0, 0, RTM_GETNEIGH, 0) < 0) {
+	if (neigh_fill_info(skb, n, 0, 0, RTM_GETNEIGH, NLM_F_REQUEST) <= 0)
 		kfree_skb(skb);
-		return;
+	else {
+		NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
+		netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
 	}
-	nlh			   = (struct nlmsghdr *)skb->data;
-	nlh->nlmsg_flags	   = NLM_F_REQUEST;
-	NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
 }
 
 static void neigh_app_notify(struct neighbour *n)
 {
-	struct nlmsghdr *nlh;
-	int size = NLMSG_SPACE(sizeof(struct ndmsg) + 256);
-	struct sk_buff *skb = alloc_skb(size, GFP_ATOMIC);
+	struct sk_buff *skb;
 
-	if (!skb)
+	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (skb == NULL)
 		return;
 
-	if (neigh_fill_info(skb, n, 0, 0, RTM_NEWNEIGH, 0) < 0) {
+	if (neigh_fill_info(skb, n, 0, 0, RTM_NEWNEIGH, 0) <= 0)
 		kfree_skb(skb);
-		return;
+	else {
+		NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
+		netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
 	}
-	nlh			   = (struct nlmsghdr *)skb->data;
-	NETLINK_CB(skb).dst_group  = RTNLGRP_NEIGH;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_NEIGH, GFP_ATOMIC);
 }
 
 #endif /* CONFIG_ARPD */

