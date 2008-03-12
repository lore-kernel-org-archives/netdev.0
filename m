From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's ndisc_recv_ns
 - V2
Date: Wed, 12 Mar 2008 10:41:01 +0100
Message-ID: <47D7A52D.2090007@fr.ibm.com>
References: <47CFD2ED.3060207@openvz.org> <47D68817.9030709@openvz.org> <20080311.175212.74407707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010408010005030609050403"
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:31032 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbYCLJmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 05:42:44 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2C9ggqx212240
	for <netdev@vger.kernel.org>; Wed, 12 Mar 2008 09:42:42 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2C9gddx1749184
	for <netdev@vger.kernel.org>; Wed, 12 Mar 2008 10:42:41 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2C9gdHc002193
	for <netdev@vger.kernel.org>; Wed, 12 Mar 2008 10:42:39 +0100
In-Reply-To: <20080311.175212.74407707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010408010005030609050403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Tue, 11 Mar 2008 16:24:39 +0300
> 
>> You picked up the patch with /proc/net symlink, but skipped this
>> one, while it was sent earlier. Is it _that_ bad :) ?
> 
> I am travelling and giving presentations in Japan, and
> this patch is in my backlog to look at :-)

The patch does not apply anymore due to the ndisc modification to be per 
namespace. I modified it to take the namespace into account and 
initialized the is_router variable to avoid a compilation warning.

--------------010408010005030609050403
Content-Type: text/x-patch;
 name="ndisc_recv_ns-pneigh-race.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ndisc_recv_ns-pneigh-race.patch"

Subject: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's ndisc_recv_ns - V2
From: Pavel Emelyanov <xemul@openvz.org>

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
counting for 2.6.26  :)  ?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

---
 include/net/neighbour.h |    2 ++
 net/core/neighbour.c    |   22 ++++++++++++++++++++++
 net/ipv6/ndisc.c        |   23 +++++++++++++++++++----
 3 files changed, 43 insertions(+), 4 deletions(-)

Index: net-2.6.26/include/net/neighbour.h
===================================================================
--- net-2.6.26.orig/include/net/neighbour.h
+++ net-2.6.26/include/net/neighbour.h
@@ -218,6 +218,8 @@ extern unsigned long		neigh_rand_reach_t
 extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 					       struct sk_buff *skb);
 extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev, int creat);
+extern struct pneigh_entry	*__pneigh_lookup(struct neigh_table *tbl,
+		struct net *net, const void *key, struct net_device *dev);
 extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev);
 
 extern void neigh_app_ns(struct neighbour *n);
Index: net-2.6.26/net/core/neighbour.c
===================================================================
--- net-2.6.26.orig/net/core/neighbour.c
+++ net-2.6.26/net/core/neighbour.c
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
Index: net-2.6.26/net/ipv6/ndisc.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ndisc.c
+++ net-2.6.26/net/ipv6/ndisc.c
@@ -659,6 +659,21 @@ static void ndisc_solicit(struct neighbo
 	}
 }
 
+static struct pneigh_entry *neigh_check_router(struct net_device *dev,
+					       struct in6_addr *addr,
+					       int *is_router)
+{
+	struct pneigh_entry *n;
+
+	read_lock_bh(&nd_tbl.lock);
+	n = __pneigh_lookup(&nd_tbl, dev->nd_net, addr, dev);
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
@@ -675,7 +690,7 @@ static void ndisc_recv_ns(struct sk_buff
 	struct pneigh_entry *pneigh = NULL;
 	int dad = ipv6_addr_any(saddr);
 	int inc;
-	int is_router;
+	int is_router = 0;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
 		ND_PRINTK2(KERN_WARNING
@@ -774,8 +789,8 @@ static void ndisc_recv_ns(struct sk_buff
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
 		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
-		     (pneigh = pneigh_lookup(&nd_tbl, dev->nd_net,
-					     &msg->target, dev, 0)) != NULL)) {
+		     (pneigh =  neigh_check_router(dev, &msg->target,
+						   &is_router)) != NULL)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
 			    inc != 0 &&
@@ -796,7 +811,7 @@ static void ndisc_recv_ns(struct sk_buff
 			goto out;
 	}
 
-	is_router = !!(pneigh ? pneigh->flags & NTF_ROUTER : idev->cnf.forwarding);
+	is_router = !!(pneigh ? is_router : idev->cnf.forwarding);
 
 	if (dad) {
 		struct in6_addr maddr;

--------------010408010005030609050403--
