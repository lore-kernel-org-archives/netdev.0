From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's ndisc_recv_ns
 (v3).
Date: Mon, 24 Mar 2008 11:24:05 +0300
Message-ID: <47E76525.9010807@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52040 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755096AbYCXIYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 04:24:16 -0400
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


Changes from v2:
As David noticed, Exported the __pneigh_lookup() to ipv6 module. 
The checkpatch generates a warning on it, since the EXPORT_SYMBOL 
does not follow the symbol itself, but in this file all the 
exports come at the end, so I decided no to break this harmony.

Changes from v1:
Fixed comments from YOSHIFUJI - indentation of prototype in header
and the pndisc_check_router() name - and a compilation fix, pointed
by Daniel - the is_routed was (falsely) considered as uninitialized
by gcc.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index ebbfb50..64a5f01 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -218,6 +218,10 @@ extern unsigned long		neigh_rand_reach_time(unsigned long base);
 extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 					       struct sk_buff *skb);
 extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev, int creat);
+extern struct pneigh_entry	*__pneigh_lookup(struct neigh_table *tbl,
+						 struct net *net,
+						 const void *key,
+						 struct net_device *dev);
 extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev);
 
 extern void neigh_app_ns(struct neighbour *n);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d9a02b2..19b8e00 100644
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
@@ -2803,6 +2825,7 @@ EXPORT_SYMBOL(neigh_table_init_no_netlink);
 EXPORT_SYMBOL(neigh_update);
 EXPORT_SYMBOL(pneigh_enqueue);
 EXPORT_SYMBOL(pneigh_lookup);
+EXPORT_SYMBOL_GPL(__pneigh_lookup);
 
 #ifdef CONFIG_ARPD
 EXPORT_SYMBOL(neigh_app_ns);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 51557c2..452a2ac 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -676,6 +676,20 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	}
 }
 
+static struct pneigh_entry *pndisc_check_router(struct net_device *dev,
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
@@ -692,7 +706,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	struct pneigh_entry *pneigh = NULL;
 	int dad = ipv6_addr_any(saddr);
 	int inc;
-	int is_router;
+	int is_router = 0;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
 		ND_PRINTK2(KERN_WARNING
@@ -790,8 +804,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
 		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
-		     (pneigh = pneigh_lookup(&nd_tbl, &init_net,
-					     &msg->target, dev, 0)) != NULL)) {
+		     (pneigh = pndisc_check_router(dev, &msg->target,
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
