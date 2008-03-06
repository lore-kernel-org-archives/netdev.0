From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's ndisc_recv_ns.
Date: Thu, 06 Mar 2008 14:18:05 +0300
Message-ID: <47CFD2ED.3060207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41234 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754462AbYCFLS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 06:18:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Proxy neighbors do not have any reference counting, so any caller
of pneigh_lookup (unless it's a netlink triggered add/del routine)
should _not_ perform any actions on the found proxy entry. 

There's one exception from this rule - the ipv6's ndisc_recv_ns() 
uses found entry to check the flags for NTF_ROUTER.

This creates a race between the ndisc and pneigh_delete - after 
the pneigh is returned to the caller, the nd_tbl.lock is dropped 
and the deleting procedure may proceed.

One of the fixes would be to add a reference counting, but this
problem exists for ndisc only. Besides such a patch would be too 
big for -rc4.

So I propose to introduce a __pneigh_lookup() which is supposed
to be called with the lock held and use it in ndisc code to check
the flags on alive pneigh entry. 

If this is OK, is there a real need in proxy neighbors reference
counting for 2.6.26 :) ?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index ebbfb50..cca1904 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -218,6 +218,8 @@ extern unsigned long		neigh_rand_reach_time(unsigned long base);
 extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 					       struct sk_buff *skb);
 extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev, int creat);
+extern struct pneigh_entry	*__pneigh_lookup(struct neigh_table *tbl,
+		struct net *net, const void *key, struct net_device *dev);
 extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev);
 
 extern void neigh_app_ns(struct neighbour *n);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d9a02b2..c97bf5b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -466,6 +466,28 @@ out_neigh_release:
 	goto out;
 }
 
+struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl,
+		struct net *net, const void *pkey, struct net_device *dev)
+{
+	struct pneigh_entry *n;
+	int key_len = tbl->key_len;
+	u32 hash_val = *(u32 *)(pkey + key_len - 4);
+
+	hash_val ^= (hash_val >> 16);
+	hash_val ^= hash_val >> 8;
+	hash_val ^= hash_val >> 4;
+	hash_val &= PNEIGH_HASHMASK;
+
+	for (n = tbl->phash_buckets[hash_val]; n; n = n->next) {
+		if (!memcmp(n->key, pkey, key_len) &&
+		    (n->net == net) &&
+		    (n->dev == dev || !n->dev))
+			break;
+	}
+
+	return n;
+}
+
 struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 				    struct net *net, const void *pkey,
 				    struct net_device *dev, int creat)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0d33a7d..bb72ef4 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -676,6 +676,20 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	}
 }
 
+static struct pneigh_entry *neigh_check_router(struct net_device *dev,
+		struct in6_addr *addr, int *is_router)
+{
+	struct pneigh_entry *n;
+
+	read_lock_bh(&nd_tbl.lock);
+	n = __pneigh_lookup(&nd_tbl, &init_net, addr, dev);
+	if (n != NULL)
+		*is_router = (n->flags & NTF_ROUTER);
+	read_unlock_bh(&nd_tbl.lock);
+
+	return n;
+}
+
 static void ndisc_recv_ns(struct sk_buff *skb)
 {
 	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
@@ -790,8 +804,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
 		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
-		     (pneigh = pneigh_lookup(&nd_tbl, &init_net,
-					     &msg->target, dev, 0)) != NULL)) {
+		     (pneigh = neigh_check_router(dev, &msg->target,
+						  &is_router)) != NULL)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
 			    inc != 0 &&
@@ -812,7 +826,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 			goto out;
 	}
 
-	is_router = !!(pneigh ? pneigh->flags & NTF_ROUTER : idev->cnf.forwarding);
+	is_router = !!(pneigh ? is_router : idev->cnf.forwarding);
 
 	if (dad) {
 		struct in6_addr maddr;
