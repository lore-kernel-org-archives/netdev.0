From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: arp: code cleanup
Date: Thu,  2 Sep 2010 07:51:50 +0800
Message-ID: <1283385110-2953-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:62976 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714Ab0IAXwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 19:52:08 -0400
Received: by pxi10 with SMTP id 10so3045074pxi.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 16:52:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean the code up according to Documentation/CodingStyle.

Don't initialize the variable dont_send in arp_process().

Remove the temporary varialbe flags in arp_state_to_flags().

Replace printk(KERN_DEBUG...) with pr_debug(...).

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 1 file changed, 212 insertions(+), 228 deletions(-)
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 96c1955..cbb0e7c 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1,4 +1,5 @@
-/* linux/net/ipv4/arp.c
+/*
+ * linux/net/ipv4/arp.c
  *
  * Copyright (C) 1994 by Florian  La Roche
  *
@@ -55,7 +56,7 @@
  *		Stuart Cheshire	:	Metricom and grat arp fixes
  *					*** FOR 2.1 clean this up ***
  *		Lawrence V. Stefani: (08/12/96) Added FDDI support.
- *		Alan Cox 	:	Took the AP1000 nasty FDDI hack and
+ *		Alan Cox	:	Took the AP1000 nasty FDDI hack and
  *					folded into the mainstream FDDI code.
  *					Ack spit, Linus how did you allow that
  *					one in...
@@ -120,7 +121,7 @@ EXPORT_SYMBOL(clip_tbl_hook);
 #endif
 
 #include <asm/system.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #include <linux/netfilter_arp.h>
 
@@ -173,32 +174,32 @@ const struct neigh_ops arp_broken_ops = {
 EXPORT_SYMBOL(arp_broken_ops);
 
 struct neigh_table arp_tbl = {
-	.family =	AF_INET,
-	.entry_size =	sizeof(struct neighbour) + 4,
-	.key_len =	4,
-	.hash =		arp_hash,
-	.constructor =	arp_constructor,
-	.proxy_redo =	parp_redo,
-	.id =		"arp_cache",
-	.parms = {
-		.tbl =			&arp_tbl,
-		.base_reachable_time =	30 * HZ,
-		.retrans_time =	1 * HZ,
-		.gc_staletime =	60 * HZ,
-		.reachable_time =		30 * HZ,
-		.delay_probe_time =	5 * HZ,
-		.queue_len =		3,
-		.ucast_probes =	3,
-		.mcast_probes =	3,
-		.anycast_delay =	1 * HZ,
-		.proxy_delay =		(8 * HZ) / 10,
-		.proxy_qlen =		64,
-		.locktime =		1 * HZ,
+	.family		= AF_INET,
+	.entry_size	= sizeof(struct neighbour) + 4,
+	.key_len	= 4,
+	.hash		= arp_hash,
+	.constructor	= arp_constructor,
+	.proxy_redo	= parp_redo,
+	.id		= "arp_cache",
+	.parms		= {
+		.tbl			= &arp_tbl,
+		.base_reachable_time	= 30 * HZ,
+		.retrans_time		= 1 * HZ,
+		.gc_staletime		= 60 * HZ,
+		.reachable_time		= 30 * HZ,
+		.delay_probe_time	= 5 * HZ,
+		.queue_len		= 3,
+		.ucast_probes		= 3,
+		.mcast_probes		= 3,
+		.anycast_delay		= 1 * HZ,
+		.proxy_delay		= (8 * HZ) / 10,
+		.proxy_qlen		= 64,
+		.locktime		= 1 * HZ,
 	},
-	.gc_interval =	30 * HZ,
-	.gc_thresh1 =	128,
-	.gc_thresh2 =	512,
-	.gc_thresh3 =	1024,
+	.gc_interval	= 30 * HZ,
+	.gc_thresh1	= 128,
+	.gc_thresh2	= 512,
+	.gc_thresh3	= 1024,
 };
 EXPORT_SYMBOL(arp_tbl);
 
@@ -233,7 +234,7 @@ static u32 arp_hash(const void *pkey, const struct net_device *dev)
 
 static int arp_constructor(struct neighbour *neigh)
 {
-	__be32 addr = *(__be32*)neigh->primary_key;
+	__be32 addr = *(__be32 *)neigh->primary_key;
 	struct net_device *dev = neigh->dev;
 	struct in_device *in_dev;
 	struct neigh_parms *parms;
@@ -258,31 +259,31 @@ static int arp_constructor(struct neighbour *neigh)
 		neigh->output = neigh->ops->queue_xmit;
 	} else {
 		/* Good devices (checked by reading texts, but only Ethernet is
-		   tested)
-
-		   ARPHRD_ETHER: (ethernet, apfddi)
-		   ARPHRD_FDDI: (fddi)
-		   ARPHRD_IEEE802: (tr)
-		   ARPHRD_METRICOM: (strip)
-		   ARPHRD_ARCNET:
-		   etc. etc. etc.
-
-		   ARPHRD_IPDDP will also work, if author repairs it.
-		   I did not it, because this driver does not work even
-		   in old paradigm.
+		 * tested)
+		 *
+		 * ARPHRD_ETHER: (ethernet, apfddi)
+		 * ARPHRD_FDDI: (fddi)
+		 * ARPHRD_IEEE802: (tr)
+		 * ARPHRD_METRICOM: (strip)
+		 * ARPHRD_ARCNET:
+		 * etc. etc. etc.
+		 *
+		 * ARPHRD_IPDDP will also work, if author repairs it.
+		 * I did not it, because this driver does not work even
+		 * in old paradigm.
 		 */
 
 #if 1
 		/* So... these "amateur" devices are hopeless.
-		   The only thing, that I can say now:
-		   It is very sad that we need to keep ugly obsolete
-		   code to make them happy.
-
-		   They should be moved to more reasonable state, now
-		   they use rebuild_header INSTEAD OF hard_start_xmit!!!
-		   Besides that, they are sort of out of date
-		   (a lot of redundant clones/copies, useless in 2.1),
-		   I wonder why people believe that they work.
+		 * The only thing, that I can say now:
+		 * It is very sad that we need to keep ugly obsolete
+		 * code to make them happy.
+		 *
+		 * They should be moved to more reasonable state, now
+		 * they use rebuild_header INSTEAD OF hard_start_xmit!!!
+		 * Besides that, they are sort of out of date
+		 * (a lot of redundant clones/copies, useless in 2.1),
+		 * I wonder why people believe that they work.
 		 */
 		switch (dev->type) {
 		default:
@@ -296,16 +297,19 @@ static int arp_constructor(struct neighbour *neigh)
 			neigh->ops = &arp_broken_ops;
 			neigh->output = neigh->ops->output;
 			return 0;
+#else
+			break;
 #endif
-		;}
+		}
 #endif
 		if (neigh->type == RTN_MULTICAST) {
 			neigh->nud_state = NUD_NOARP;
 			arp_mc_map(addr, neigh->ha, dev, 1);
-		} else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
+		} else if (dev->flags & (IFF_NOARP | IFF_LOOPBACK)) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
-		} else if (neigh->type == RTN_BROADCAST || dev->flags&IFF_POINTOPOINT) {
+		} else if (neigh->type == RTN_BROADCAST ||
+			   dev->flags & IFF_POINTOPOINT) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
 		}
@@ -334,7 +338,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	__be32 saddr = 0;
 	u8  *dst_ha = NULL;
 	struct net_device *dev = neigh->dev;
-	__be32 target = *(__be32*)neigh->primary_key;
+	__be32 target = *(__be32 *)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 	struct in_device *in_dev;
 
@@ -346,11 +350,12 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	}
 	switch (IN_DEV_ARP_ANNOUNCE(in_dev)) {
 	default:
-	case 0:		/* By default announce any local IP */
-		if (skb && inet_addr_type(dev_net(dev), ip_hdr(skb)->saddr) == RTN_LOCAL)
+	case 0: /* By default announce any local IP */
+		if (skb && inet_addr_type(dev_net(dev),
+					  ip_hdr(skb)->saddr) == RTN_LOCAL)
 			saddr = ip_hdr(skb)->saddr;
 		break;
-	case 1:		/* Restrict announcements of saddr in same subnet */
+	case 1: /* Restrict announcements of saddr in same subnet */
 		if (!skb)
 			break;
 		saddr = ip_hdr(skb)->saddr;
@@ -361,7 +366,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		}
 		saddr = 0;
 		break;
-	case 2:		/* Avoid secondary IPs, get a primary/preferred one */
+	case 2: /* Avoid secondary IPs, get a primary/preferred one */
 		break;
 	}
 	rcu_read_unlock();
@@ -369,16 +374,20 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	if (!saddr)
 		saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
 
-	if ((probes -= neigh->parms->ucast_probes) < 0) {
+	probes -= neigh->parms->ucast_probes;
+	if (probes < 0) {
 		if (!(neigh->nud_state&NUD_VALID))
-			printk(KERN_DEBUG "trying to ucast probe in NUD_INVALID\n");
+			pr_debug("trying to ucast probe in NUD_INVALID\n");
 		dst_ha = neigh->ha;
 		read_lock_bh(&neigh->lock);
-	} else if ((probes -= neigh->parms->app_probes) < 0) {
+	} else {
+		probes -= neigh->parms->app_probes;
+		if (probes < 0) {
 #ifdef CONFIG_ARPD
-		neigh_app_ns(neigh);
+			neigh_app_ns(neigh);
 #endif
-		return;
+			return;
+		}
 	}
 
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
@@ -443,19 +452,20 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 /* OBSOLETE FUNCTIONS */
 
 /*
- *	Find an arp mapping in the cache. If not found, post a request.
+ * Find an arp mapping in the cache. If not found, post a request.
  *
- *	It is very UGLY routine: it DOES NOT use skb->dst->neighbour,
- *	even if it exists. It is supposed that skb->dev was mangled
- *	by a virtual device (eql, shaper). Nobody but broken devices
- *	is allowed to use this function, it is scheduled to be removed. --ANK
+ * It is very UGLY routine: it DOES NOT use skb->dst->neighbour,
+ * even if it exists. It is supposed that skb->dev was mangled
+ * by a virtual device (eql, shaper). Nobody but broken devices
+ * is allowed to use this function, it is scheduled to be removed. --ANK
  */
 
-static int arp_set_predefined(int addr_hint, unsigned char * haddr, __be32 paddr, struct net_device * dev)
+static int arp_set_predefined(int addr_hint, unsigned char *haddr,
+			      __be32 paddr, struct net_device *dev)
 {
 	switch (addr_hint) {
 	case RTN_LOCAL:
-		printk(KERN_DEBUG "ARP: arp called for own IP address\n");
+		pr_debug("ARP: arp called for own IP address\n");
 		memcpy(haddr, dev->dev_addr, dev->addr_len);
 		return 1;
 	case RTN_MULTICAST:
@@ -476,14 +486,15 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 	struct neighbour *n;
 
 	if (!skb_dst(skb)) {
-		printk(KERN_DEBUG "arp_find is called with dst==NULL\n");
+		pr_debug("arp_find is called with dst==NULL\n");
 		kfree_skb(skb);
 		return 1;
 	}
 
 	paddr = skb_rtable(skb)->rt_gateway;
 
-	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr, paddr, dev))
+	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr,
+			       paddr, dev))
 		return 0;
 
 	n = __neigh_lookup(&arp_tbl, &paddr, dev, 1);
@@ -515,13 +526,14 @@ int arp_bind_neighbour(struct dst_entry *dst)
 		return -EINVAL;
 	if (n == NULL) {
 		__be32 nexthop = ((struct rtable *)dst)->rt_gateway;
-		if (dev->flags&(IFF_LOOPBACK|IFF_POINTOPOINT))
+		if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
 			nexthop = 0;
 		n = __neigh_lookup_errno(
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-		    dev->type == ARPHRD_ATM ? clip_tbl_hook :
+					 dev->type == ARPHRD_ATM ?
+					 clip_tbl_hook :
 #endif
-		    &arp_tbl, &nexthop, dev);
+					 &arp_tbl, &nexthop, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
 		dst->neighbour = n;
@@ -529,9 +541,7 @@ int arp_bind_neighbour(struct dst_entry *dst)
 	return 0;
 }
 
-/*
- * Check if we can use proxy ARP for this path
- */
+/* Check if we can use proxy ARP for this path */
 static inline int arp_fwd_proxy(struct in_device *in_dev,
 				struct net_device *dev,	struct rtable *rt)
 {
@@ -543,8 +553,8 @@ static inline int arp_fwd_proxy(struct in_device *in_dev,
 
 	if (!IN_DEV_PROXY_ARP(in_dev))
 		return 0;
-
-	if ((imi = IN_DEV_MEDIUM_ID(in_dev)) == 0)
+	imi = IN_DEV_MEDIUM_ID(in_dev);
+	if (imi == 0)
 		return 1;
 	if (imi == -1)
 		return 0;
@@ -595,14 +605,9 @@ static inline int arp_fwd_pvlan(struct in_device *in_dev,
 		return 0;
 }
 
-/*
- *	Interface to link layer: send routine and receive handler.
- */
+/* Interface to link layer: send routine and receive handler.  */
 
-/*
- *	Create an arp packet. If (dest_hw == NULL), we create a broadcast
- *	message.
- */
+/* Create an arp packet. If (dest_hw == NULL), we create a broadcast message. */
 struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 			   struct net_device *dev, __be32 src_ip,
 			   const unsigned char *dest_hw,
@@ -613,9 +618,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	struct arphdr *arp;
 	unsigned char *arp_ptr;
 
-	/*
-	 *	Allocate a buffer
-	 */
+	/* Allocate a buffer */
 
 	skb = alloc_skb(arp_hdr_len(dev) + LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
@@ -631,9 +634,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	if (dest_hw == NULL)
 		dest_hw = dev->broadcast;
 
-	/*
-	 *	Fill the device header for the ARP frame
-	 */
+	/* Fill the device header for the ARP frame */
 	if (dev_hard_header(skb, dev, ptype, dest_hw, src_hw, skb->len) < 0)
 		goto out;
 
@@ -642,10 +643,9 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	 *
 	 * The arp hardware type should match the device type, except for FDDI,
 	 * which (according to RFC 1390) should always equal 1 (Ethernet).
-	 */
-	/*
-	 *	Exceptions everywhere. AX.25 uses the AX.25 PID value not the
-	 *	DIX code for the protocol. Make these device structure fields.
+	 *
+	 * Exceptions everywhere. AX.25 uses the AX.25 PID value not the
+	 * DIX code for the protocol. Make these device structure fields.
 	 */
 	switch (dev->type) {
 	default:
@@ -685,7 +685,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	arp->ar_pln = 4;
 	arp->ar_op = htons(type);
 
-	arp_ptr=(unsigned char *)(arp+1);
+	arp_ptr = (unsigned char *)(arp+1);
 
 	memcpy(arp_ptr, src_hw, dev->addr_len);
 	arp_ptr += dev->addr_len;
@@ -706,9 +706,7 @@ out:
 }
 EXPORT_SYMBOL(arp_create);
 
-/*
- *	Send an arp packet.
- */
+/* Send an arp packet. */
 void arp_xmit(struct sk_buff *skb)
 {
 	/* Send it off, maybe filter it using firewalling first.  */
@@ -716,9 +714,7 @@ void arp_xmit(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(arp_xmit);
 
-/*
- *	Create and send an arp packet.
- */
+/* Create and send an arp packet. */
 void arp_send(int type, int ptype, __be32 dest_ip,
 	      struct net_device *dev, __be32 src_ip,
 	      const unsigned char *dest_hw, const unsigned char *src_hw,
@@ -726,26 +722,20 @@ void arp_send(int type, int ptype, __be32 dest_ip,
 {
 	struct sk_buff *skb;
 
-	/*
-	 *	No arp on this interface.
-	 */
-
-	if (dev->flags&IFF_NOARP)
+	/* No arp on this interface. */
+	if (dev->flags & IFF_NOARP)
 		return;
 
 	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
 			 dest_hw, src_hw, target_hw);
-	if (skb == NULL) {
+	if (skb == NULL)
 		return;
-	}
 
 	arp_xmit(skb);
 }
 EXPORT_SYMBOL(arp_send);
 
-/*
- *	Process an arp request.
- */
+/* Process an arp request. */
 
 static int arp_process(struct sk_buff *skb)
 {
@@ -761,7 +751,8 @@ static int arp_process(struct sk_buff *skb)
 	struct neighbour *n;
 	struct net *net = dev_net(dev);
 
-	/* arp_rcv below verifies the ARP header and verifies the device
+	/*
+	 * arp_rcv below verifies the ARP header and verifies the device
 	 * is ARP'able.
 	 */
 
@@ -807,50 +798,45 @@ static int arp_process(struct sk_buff *skb)
 	}
 
 	/* Understand only these message types */
-
 	if (arp->ar_op != htons(ARPOP_REPLY) &&
 	    arp->ar_op != htons(ARPOP_REQUEST))
 		goto out;
 
-/*
- *	Extract fields
- */
-	arp_ptr= (unsigned char *)(arp+1);
-	sha	= arp_ptr;
+	/* Extract fields */
+	arp_ptr = (unsigned char *)(arp + 1);
+	sha = arp_ptr;
 	arp_ptr += dev->addr_len;
 	memcpy(&sip, arp_ptr, 4);
 	arp_ptr += 4;
 	arp_ptr += dev->addr_len;
 	memcpy(&tip, arp_ptr, 4);
-/*
- *	Check for bad requests for 127.x.x.x and requests for multicast
- *	addresses.  If this is one such, delete it.
- */
+	/*
+	 * Check for bad requests for 127.x.x.x and requests for multicast
+	 * addresses.  If this is one such, delete it.
+	 */
 	if (ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
 		goto out;
 
-/*
- *     Special case: We must set Frame Relay source Q.922 address
- */
+	/* Special case: We must set Frame Relay source Q.922 address */
 	if (dev_type == ARPHRD_DLCI)
 		sha = dev->broadcast;
 
-/*
- *  Process entry.  The idea here is we want to send a reply if it is a
- *  request for us or if it is a request for someone else that we hold
- *  a proxy for.  We want to add an entry to our cache if it is a reply
- *  to us or if it is a request for our address.
- *  (The assumption for this last is that if someone is requesting our
- *  address, they are probably intending to talk to us, so it saves time
- *  if we cache their address.  Their address is also probably not in
- *  our cache, since ours is not in their cache.)
- *
- *  Putting this another way, we only care about replies if they are to
- *  us, in which case we add them to the cache.  For requests, we care
- *  about those for us and those for our proxies.  We reply to both,
- *  and in the case of requests for us we add the requester to the arp
- *  cache.
- */
+	/*
+	 *  Process entry.  The idea here is we want to send a reply if it is a
+	 *  request for us or if it is a request for someone else that we hold
+	 *  a proxy for.  We want to add an entry to our cache if it is a reply
+	 *  to us or if it is a request for our address.
+	 *  (The assumption for this last is that if someone is requesting our
+	 *  address, they are probably intending to talk to us, so it saves time
+	 *  if we cache their address.  Their address is also probably not in
+	 *  our cache, since ours is not in their cache.)
+	 *
+	 *  Putting this another way, we only care about replies if they are to
+	 *  us, in which case we add them to the cache.  For requests, we care
+	 *  about those for us and those for our proxies.  We reply to both,
+	 *  and in the case of requests for us we add the requester to the arp
+	 *  cache.
+	 */
 
 	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
 	if (sip == 0) {
@@ -869,16 +855,17 @@ static int arp_process(struct sk_buff *skb)
 		addr_type = rt->rt_type;
 
 		if (addr_type == RTN_LOCAL) {
-			int dont_send = 0;
+			int dont_send;
 
-			if (!dont_send)
-				dont_send |= arp_ignore(in_dev,sip,tip);
+			dont_send = arp_ignore(in_dev, sip, tip);
 			if (!dont_send && IN_DEV_ARPFILTER(in_dev))
-				dont_send |= arp_filter(sip,tip,dev);
+				dont_send |= arp_filter(sip, tip, dev);
 			if (!dont_send) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n) {
-					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+					arp_send(ARPOP_REPLY, ETH_P_ARP, sip,
+						 dev, tip, sha, dev->dev_addr,
+						 sha);
 					neigh_release(n);
 				}
 			}
@@ -887,8 +874,7 @@ static int arp_process(struct sk_buff *skb)
 			if (addr_type == RTN_UNICAST  &&
 			    (arp_fwd_proxy(in_dev, dev, rt) ||
 			     arp_fwd_pvlan(in_dev, dev, rt, sip, tip) ||
-			     pneigh_lookup(&arp_tbl, net, &tip, dev, 0)))
-			{
+			     pneigh_lookup(&arp_tbl, net, &tip, dev, 0))) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n)
 					neigh_release(n);
@@ -896,9 +882,12 @@ static int arp_process(struct sk_buff *skb)
 				if (NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED ||
 				    skb->pkt_type == PACKET_HOST ||
 				    in_dev->arp_parms->proxy_delay == 0) {
-					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+					arp_send(ARPOP_REPLY, ETH_P_ARP, sip,
+						 dev, tip, sha, dev->dev_addr,
+						 sha);
 				} else {
-					pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
+					pneigh_enqueue(&arp_tbl,
+						       in_dev->arp_parms, skb);
 					return 0;
 				}
 				goto out;
@@ -911,9 +900,10 @@ static int arp_process(struct sk_buff *skb)
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
 	if (IPV4_DEVCONF_ALL(dev_net(dev), ARP_ACCEPT)) {
-		/* Unsolicited ARP is not accepted by default.
-		   It is possible, that this option should be enabled for some
-		   devices (strip is candidate)
+		/*
+		 * Unsolicited ARP is not accepted by default.
+		 * It is possible, that this option should be enabled for some
+		 * devices (strip is candidate)
 		 */
 		if (n == NULL &&
 		    (arp->ar_op == htons(ARPOP_REPLY) ||
@@ -926,20 +916,23 @@ static int arp_process(struct sk_buff *skb)
 		int state = NUD_REACHABLE;
 		int override;
 
-		/* If several different ARP replies follows back-to-back,
-		   use the FIRST one. It is possible, if several proxy
-		   agents are active. Taking the first reply prevents
-		   arp trashing and chooses the fastest router.
+		/*
+		 * If several different ARP replies follows back-to-back,
+		 * use the FIRST one. It is possible, if several proxy
+		 * agents are active. Taking the first reply prevents
+		 * arp trashing and chooses the fastest router.
 		 */
 		override = time_after(jiffies, n->updated + n->parms->locktime);
 
-		/* Broadcast replies and request packets
-		   do not assert neighbour reachability.
+		/*
+		 * Broadcast replies and request packets
+		 * do not assert neighbour reachability.
 		 */
 		if (arp->ar_op != htons(ARPOP_REPLY) ||
 		    skb->pkt_type != PACKET_HOST)
 			state = NUD_STALE;
-		neigh_update(n, sha, state, override ? NEIGH_UPDATE_F_OVERRIDE : 0);
+		neigh_update(n, sha, state,
+			     override ? NEIGH_UPDATE_F_OVERRIDE : 0);
 		neigh_release(n);
 	}
 
@@ -954,9 +947,7 @@ static void parp_redo(struct sk_buff *skb)
 }
 
 
-/*
- *	Receive an arp request from the device layer.
- */
+/* Receive an arp request from the device layer. */
 
 static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev)
@@ -975,7 +966,8 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 	    arp->ar_pln != 4)
 		goto freeskb;
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (skb == NULL)
 		goto out_of_mem;
 
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
@@ -988,13 +980,9 @@ out_of_mem:
 	return 0;
 }
 
-/*
- *	User level interface (ioctl)
- */
+/* User level interface (ioctl) */
 
-/*
- *	Set (create) an ARP cache entry.
- */
+/* Set (create) an ARP cache entry. */
 
 static int arp_req_set_proxy(struct net *net, struct net_device *dev, int on)
 {
@@ -1019,7 +1007,7 @@ static int arp_req_set_public(struct net *net, struct arpreq *r,
 		return -EINVAL;
 	if (!dev && (r->arp_flags & ATF_COM)) {
 		dev = dev_getbyhwaddr(net, r->arp_ha.sa_family,
-				r->arp_ha.sa_data);
+				      r->arp_ha.sa_data);
 		if (!dev)
 			return -ENODEV;
 	}
@@ -1033,7 +1021,7 @@ static int arp_req_set_public(struct net *net, struct arpreq *r,
 }
 
 static int arp_req_set(struct net *net, struct arpreq *r,
-		struct net_device * dev)
+		       struct net_device *dev)
 {
 	__be32 ip;
 	struct neighbour *neigh;
@@ -1048,8 +1036,9 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	if (dev == NULL) {
 		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip,
 							 .tos = RTO_ONLINK } } };
-		struct rtable * rt;
-		if ((err = ip_route_output_key(net, &rt, &fl)) != 0)
+		struct rtable *rt;
+		err = ip_route_output_key(net, &rt, &fl);
+		if (err != 0)
 			return err;
 		dev = rt->dst.dev;
 		ip_rt_put(rt);
@@ -1083,9 +1072,9 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 		unsigned state = NUD_STALE;
 		if (r->arp_flags & ATF_PERM)
 			state = NUD_PERMANENT;
-		err = neigh_update(neigh, (r->arp_flags&ATF_COM) ?
+		err = neigh_update(neigh, (r->arp_flags & ATF_COM) ?
 				   r->arp_ha.sa_data : NULL, state,
-				   NEIGH_UPDATE_F_OVERRIDE|
+				   NEIGH_UPDATE_F_OVERRIDE |
 				   NEIGH_UPDATE_F_ADMIN);
 		neigh_release(neigh);
 	}
@@ -1094,17 +1083,15 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 
 static unsigned arp_state_to_flags(struct neighbour *neigh)
 {
-	unsigned flags = 0;
-	if (neigh->nud_state&NUD_PERMANENT)
-		flags = ATF_PERM|ATF_COM;
-	else if (neigh->nud_state&NUD_VALID)
-		flags = ATF_COM;
-	return flags;
+	if (neigh->nud_state & NUD_PERMANENT)
+		return ATF_PERM | ATF_COM;
+	else if (neigh->nud_state & NUD_VALID)
+		return ATF_COM;
+	else
+		return 0;
 }
 
-/*
- *	Get an ARP cache entry.
- */
+/* Get an ARP cache entry. */
 
 static int arp_req_get(struct arpreq *r, struct net_device *dev)
 {
@@ -1142,7 +1129,7 @@ static int arp_req_delete_public(struct net *net, struct arpreq *r,
 }
 
 static int arp_req_delete(struct net *net, struct arpreq *r,
-		struct net_device * dev)
+			  struct net_device *dev)
 {
 	int err;
 	__be32 ip;
@@ -1155,8 +1142,9 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 	if (dev == NULL) {
 		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip,
 							 .tos = RTO_ONLINK } } };
-		struct rtable * rt;
-		if ((err = ip_route_output_key(net, &rt, &fl)) != 0)
+		struct rtable *rt;
+		err = ip_route_output_key(net, &rt, &fl);
+		if (err != 0)
 			return err;
 		dev = rt->dst.dev;
 		ip_rt_put(rt);
@@ -1166,7 +1154,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 	err = -ENXIO;
 	neigh = neigh_lookup(&arp_tbl, &ip, dev);
 	if (neigh) {
-		if (neigh->nud_state&~NUD_NOARP)
+		if (neigh->nud_state & ~NUD_NOARP)
 			err = neigh_update(neigh, NULL, NUD_FAILED,
 					   NEIGH_UPDATE_F_OVERRIDE|
 					   NEIGH_UPDATE_F_ADMIN);
@@ -1175,9 +1163,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 	return err;
 }
 
-/*
- *	Handle an ARP layer I/O control request.
- */
+/* Handle an ARP layer I/O control request. */
 
 int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 {
@@ -1186,24 +1172,24 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	struct net_device *dev = NULL;
 
 	switch (cmd) {
-		case SIOCDARP:
-		case SIOCSARP:
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-		case SIOCGARP:
-			err = copy_from_user(&r, arg, sizeof(struct arpreq));
-			if (err)
-				return -EFAULT;
-			break;
-		default:
-			return -EINVAL;
+	case SIOCDARP:
+	case SIOCSARP:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+	case SIOCGARP:
+		err = copy_from_user(&r, arg, sizeof(struct arpreq));
+		if (err)
+			return -EFAULT;
+		break;
+	default:
+		return -EINVAL;
 	}
 
 	if (r.arp_pa.sa_family != AF_INET)
 		return -EPFNOSUPPORT;
 
 	if (!(r.arp_flags & ATF_PUBL) &&
-	    (r.arp_flags & (ATF_NETMASK|ATF_DONTPUB)))
+	    (r.arp_flags & (ATF_NETMASK | ATF_DONTPUB)))
 		return -EINVAL;
 	if (!(r.arp_flags & ATF_NETMASK))
 		((struct sockaddr_in *)&r.arp_netmask)->sin_addr.s_addr =
@@ -1211,7 +1197,8 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	rtnl_lock();
 	if (r.arp_dev[0]) {
 		err = -ENODEV;
-		if ((dev = __dev_get_by_name(net, r.arp_dev)) == NULL)
+		dev = __dev_get_by_name(net, r.arp_dev);
+		if (dev == NULL)
 			goto out;
 
 		/* Mmmm... It is wrong... ARPHRD_NETROM==0 */
@@ -1243,7 +1230,8 @@ out:
 	return err;
 }
 
-static int arp_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
+static int arp_netdev_event(struct notifier_block *this, unsigned long event,
+			    void *ptr)
 {
 	struct net_device *dev = ptr;
 
@@ -1263,9 +1251,10 @@ static struct notifier_block arp_netdev_notifier = {
 	.notifier_call = arp_netdev_event,
 };
 
-/* Note, that it is not on notifier chain.
-   It is necessary, that this routine was called after route cache will be
-   flushed.
+/*
+ * Note, that it is not on notifier chain.
+ * It is necessary, that this routine was called after route cache will be
+ * flushed.
  */
 void arp_ifdown(struct net_device *dev)
 {
@@ -1273,9 +1262,7 @@ void arp_ifdown(struct net_device *dev)
 }
 
 
-/*
- *	Called once on startup.
- */
+/* Called once on startup. */
 
 static struct packet_type arp_packet_type __read_mostly = {
 	.type =	cpu_to_be16(ETH_P_ARP),
@@ -1299,10 +1286,7 @@ void __init arp_init(void)
 #ifdef CONFIG_PROC_FS
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 
-/* ------------------------------------------------------------------------ */
-/*
- *	ax25 -> ASCII conversion
- */
+/* ax25 -> ASCII conversion */
 static char *ax2asc2(ax25_address *a, char *buf)
 {
 	char c, *s;
@@ -1311,12 +1295,13 @@ static char *ax2asc2(ax25_address *a, char *buf)
 	for (n = 0, s = buf; n < 6; n++) {
 		c = (a->ax25_call[n] >> 1) & 0x7F;
 
-		if (c != ' ') *s++ = c;
+		if (c != ' ')
+			*s++ = c;
 	}
 
 	*s++ = '-';
-
-	if ((n = ((a->ax25_call[6] >> 1) & 0x0F)) > 9) {
+	n = (a->ax25_call[6] >> 1) & 0x0F;
+	if (n > 9) {
 		*s++ = '1';
 		n -= 10;
 	}
@@ -1325,10 +1310,9 @@ static char *ax2asc2(ax25_address *a, char *buf)
 	*s++ = '\0';
 
 	if (*buf == '\0' || *buf == '-')
-	   return "*";
+		return "*";
 
 	return buf;
-
 }
 #endif /* CONFIG_AX25 */
 
@@ -1408,10 +1392,10 @@ static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
 /* ------------------------------------------------------------------------ */
 
 static const struct seq_operations arp_seq_ops = {
-	.start  = arp_seq_start,
-	.next   = neigh_seq_next,
-	.stop   = neigh_seq_stop,
-	.show   = arp_seq_show,
+	.start	= arp_seq_start,
+	.next	= neigh_seq_next,
+	.stop	= neigh_seq_stop,
+	.show	= arp_seq_show,
 };
 
 static int arp_seq_open(struct inode *inode, struct file *file)
