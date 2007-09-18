From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Tue, 18 Sep 2007 20:08:30 +0800
Message-ID: <E1IXbsU-0002Pl-00@gondolin.me.apana.org.au>
References: <20070918120438.GA9121@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1034 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755731AbXIRMIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 08:08:36 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IXbsV-0002Xl-Lc
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 22:08:31 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IXbsU-0002Pl-00
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 20:08:30 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP] L2TP: Fix skb handling in pppol2tp_xmit

This patch makes pppol2tp_xmit call skb_cow_head so that we don't modify
cloned skb data.  It also gets rid of skb2 we only need to preserve the
original skb for congestion notification, which is only applicable for
ppp_async and ppp_sync.

The other semantic change made here is the removal of socket accounting
for data tranmitted out of pppol2tp_xmit.  The original code leaked any
existing socket skb accounting.  We could fix this by dropping the
original skb owner.  However, this is undesirable as the packet has not
physically left the host yet.

In fact, all other tunnels in the kernel do not account skb's passing
through to their own socket.  In partciular, ESP over UDP does not do
so and it is the closest tunnel type to PPPoL2TP.  So this patch simply
removes the socket accounting in pppol2tp_xmit.  The accounting still
applies to control packets of course.

I've also added a reminder that the outgoing checksum here doesn't work.
I suppose existing deployments don't actually enable checksums.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/pppol2tp.c |   60 +++++++++++++++++--------------------------------
 1 files changed, 21 insertions(+), 39 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 440e190..e259f45 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -962,7 +962,6 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	int data_len = skb->len;
 	struct inet_sock *inet;
 	__wsum csum = 0;
-	struct sk_buff *skb2 = NULL;
 	struct udphdr *uh;
 	unsigned int len;
 
@@ -993,41 +992,30 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	 */
 	headroom = NET_SKB_PAD + sizeof(struct iphdr) +
 		sizeof(struct udphdr) + hdr_len + sizeof(ppph);
-	if (skb_headroom(skb) < headroom) {
-		skb2 = skb_realloc_headroom(skb, headroom);
-		if (skb2 == NULL)
-			goto abort;
-	} else
-		skb2 = skb;
-
-	/* Check that the socket has room */
-	if (atomic_read(&sk_tun->sk_wmem_alloc) < sk_tun->sk_sndbuf)
-		skb_set_owner_w(skb2, sk_tun);
-	else
-		goto discard;
+	if (skb_cow_head(skb, headroom))
+		goto abort;
 
 	/* Setup PPP header */
-	skb_push(skb2, sizeof(ppph));
-	skb2->data[0] = ppph[0];
-	skb2->data[1] = ppph[1];
+	__skb_push(skb, sizeof(ppph));
+	skb->data[0] = ppph[0];
+	skb->data[1] = ppph[1];
 
 	/* Setup L2TP header */
-	skb_push(skb2, hdr_len);
-	pppol2tp_build_l2tp_header(session, skb2->data);
+	pppol2tp_build_l2tp_header(session, __skb_push(skb, hdr_len));
 
 	/* Setup UDP header */
 	inet = inet_sk(sk_tun);
-	skb_push(skb2, sizeof(struct udphdr));
-	skb_reset_transport_header(skb2);
-	uh = (struct udphdr *) skb2->data;
+	__skb_push(skb, sizeof(*uh));
+	skb_reset_transport_header(skb);
+	uh = udp_hdr(skb);
 	uh->source = inet->sport;
 	uh->dest = inet->dport;
 	uh->len = htons(sizeof(struct udphdr) + hdr_len + sizeof(ppph) + data_len);
 	uh->check = 0;
 
-	/* Calculate UDP checksum if configured to do so */
+	/* *BROKEN* Calculate UDP checksum if configured to do so */
 	if (sk_tun->sk_no_check != UDP_CSUM_NOXMIT)
-		csum = udp_csum_outgoing(sk_tun, skb2);
+		csum = udp_csum_outgoing(sk_tun, skb);
 
 	/* Debug */
 	if (session->send_seq)
@@ -1040,7 +1028,7 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 
 	if (session->debug & PPPOL2TP_MSG_DATA) {
 		int i;
-		unsigned char *datap = skb2->data;
+		unsigned char *datap = skb->data;
 
 		printk(KERN_DEBUG "%s: xmit:", session->name);
 		for (i = 0; i < data_len; i++) {
@@ -1053,18 +1041,18 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 		printk("\n");
 	}
 
-	memset(&(IPCB(skb2)->opt), 0, sizeof(IPCB(skb2)->opt));
-	IPCB(skb2)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
-			       IPSKB_REROUTED);
-	nf_reset(skb2);
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
+			      IPSKB_REROUTED);
+	nf_reset(skb);
 
 	/* Get routing info from the tunnel socket */
-	dst_release(skb2->dst);
-	skb2->dst = sk_dst_get(sk_tun);
+	dst_release(skb->dst);
+	skb->dst = sk_dst_get(sk_tun);
 
 	/* Queue the packet to IP for output */
-	len = skb2->len;
-	rc = ip_queue_xmit(skb2, 1);
+	len = skb->len;
+	rc = ip_queue_xmit(skb, 1);
 
 	/* Update stats */
 	if (rc >= 0) {
@@ -1078,16 +1066,10 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	}
 
 	/* Free the original skb */
+abort:
 	kfree_skb(skb);
 
 	return 1;
-
-discard:
-	/* Free the new skb. Caller will free original skb. */
-	if (skb2 != skb)
-		kfree_skb(skb2);
-abort:
-	return 0;
 }
 
 /*****************************************************************************
