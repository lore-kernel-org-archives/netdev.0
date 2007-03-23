From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH]: SAD sometimes has double SAs.
Date: Fri, 23 Mar 2007 16:58:20 -0600
Message-ID: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
Cc: davem@davemloft.net, eparis@redhat.com,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@trustedcs.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:55468 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992618AbXCWXOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 19:14:46 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2NNEjjT000688
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 19:14:45 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2NNEicw314202
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 19:14:44 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2NNEhVQ018242
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 19:14:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Last Friday I proposed creating larval SAs to act as
placeholders to prevent a second acquire resulting in 
double SAs being created. 
I tried this and so far I have not seen any double SAs
being created. I also plan to run some stress tests over 
the weekend.

Please let me know what improvements I can make to this patch or
if there is a better way to do this.

> A while back I reported that I sometimes saw double and triple 
> SAs being created. The patch to check for protocol when deleting
> larval SA removed one obstacle in that I no longer see triple SAs. 
> Now, once in a while double SAs. I think I have figured out the
> second obstacle.
> 
> The initiator installs his SAs into the kernel before the responder.
> As soon as they are installed, the blocked packet (which started
> the ACQUIRE) is sent. By this time the responder has installed his
> inbound SA(s) and so the newly arrived ipsec packet can be processed.
> In the case of tcp connections and a ping, a response may be 
> warranted, and thus an outgoing packet results. 
> 
> >From what I can tell of the log file below, sometimes, this
> might happen before the responder has completed installing 
> the outbound SAs. In the log file, the outbound AH has been added, 
> but not the outbound ESP, which is the one the outgoing packet 
> looks for first. Thus resulting in a second acquire. 
> 
> I think this becomes more problematic when using both AH AND ESP, 
> rather than just using ESP with authentication. With the latter, 
> only one SA needed thus reducing the latency in installing the 
> SAs before incoming packet arrives.     
> 
> So far, the only solution I can think of besides mandating all 
> userspace key daemons do SA maintenance is to perhaps add larval 
> SAs for both directions when adding the SPI. Currently, responder 
> does GETSPI for one way and initiator for opposite. When GETSPI is
> called, larval SA is created containing the SPI, but it is only 
> for one direction. Perhaps we can add a larval SA (no SPI) for 
> opposite direction to act as a placeholder indicating ACQUIRE 
> occurring, since SAs are created for both directions during an ACQUIRE.
> The initiator may have larval SA from GETSPI and larval SA from the
> ACQUIRE depending that GETSPI is in opposite direction of ACQUIRE.
> Calling __find_acq_core() should ensure we don't create duplicate 
> larval SAs. Also, should IKE negotiations return error, larval SAs
> should expire. They also should be removed when we do the
> xfrm_state_add() and xfrm_state_update() to add the new SAs.
>  

Joy


This patch is against linux-2.6.21-rc4-git5

Signed-off-by: Joy Latten<latten@austin.ibm.com>


diff -urpN linux-2.6.20.orig/net/xfrm/xfrm_state.c linux-2.6.20/net/xfrm/xfrm_state.c
--- linux-2.6.20.orig/net/xfrm/xfrm_state.c	2007-03-20 22:39:15.000000000 -0500
+++ linux-2.6.20/net/xfrm/xfrm_state.c	2007-03-23 16:38:37.000000000 -0500
@@ -692,12 +692,15 @@ void xfrm_state_insert(struct xfrm_state
 }
 EXPORT_SYMBOL(xfrm_state_insert);
 
+static struct xfrm_state *create_larval_sa(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr);
+
 /* xfrm_state_lock is held */
 static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
 {
 	unsigned int h = xfrm_dst_hash(daddr, saddr, reqid, family);
 	struct hlist_node *entry;
-	struct xfrm_state *x;
+	struct xfrm_state *x, *x1;
+	int track_opposite = 0;
 
 	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
 		if (x->props.reqid  != reqid ||
@@ -710,11 +713,20 @@ static struct xfrm_state *__find_acq_cor
 
 		switch (family) {
 		case AF_INET:
+			if (x->id.daddr.a4 == saddr->a4 &&
+			    x->props.saddr.a4 == daddr->a4)
+				track_opposite = 1;
 			if (x->id.daddr.a4    != daddr->a4 ||
 			    x->props.saddr.a4 != saddr->a4)
 				continue;
 			break;
 		case AF_INET6:
+			if (ipv6_addr_equal((struct in6_addr *)x->id.daddr.a6,
+					     (struct in6_addr *)saddr) ||
+			    ipv6_addr_equal((struct in6_addr *)
+					     x->props.saddr.a6,
+					     (struct in6_addr *)daddr))
+					track_opposite = 1;
 			if (!ipv6_addr_equal((struct in6_addr *)x->id.daddr.a6,
 					     (struct in6_addr *)daddr) ||
 			    !ipv6_addr_equal((struct in6_addr *)
@@ -731,6 +743,27 @@ static struct xfrm_state *__find_acq_cor
 	if (!create)
 		return NULL;
 
+	x = create_larval_sa(family, mode, reqid, proto, daddr, saddr);
+	
+	/* create a larval SA for opposite direction to act as a 
+	   placeholder duing the ACQUIRE. This prevents any additional
+	   packets from creating additional ACQUIRES for same traffic
+	   stream.
+ 	*/
+	
+	if (!track_opposite) 
+		x1 = create_larval_sa(family, mode, reqid, proto, saddr, daddr);
+	
+	wake_up(&km_waitq);
+	return x;
+}
+
+/* xfrm_state_lock is held */
+static struct xfrm_state *create_larval_sa(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr)
+{
+	struct xfrm_state *x;
+	unsigned int h = xfrm_dst_hash(daddr, saddr, reqid, family);
+	
 	x = xfrm_state_alloc();
 	if (likely(x)) {
 		switch (family) {
@@ -769,15 +802,14 @@ static struct xfrm_state *__find_acq_cor
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
-		wake_up(&km_waitq);
 
 		xfrm_state_num++;
 
 		xfrm_hash_grow_check(x->bydst.next != NULL);
-	}
 
-	return x;
-}
+	};
+		return x;
+};
 
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
