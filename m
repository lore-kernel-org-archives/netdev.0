From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 00:05:47 -0700 (PDT)
Message-ID: <20080425.000547.152086801.davem@davemloft.net>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35845
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752012AbYDYHFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:05:48 -0400
In-Reply-To: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Wed, 23 Apr 2008 16:29:58 -0700

> I've been seeing the same problem here and am trying to fix it.
> My fix is to not count those pkts still in the host queue as "prior_in_flight"
> when feeding the latter to tcp_cong_avoid(). This should cause
> tcp_is_cwnd_limited() test to fail when the previous in_flight build-up
> is all due to the large host queue, and stop the cwnd to grow beyond
> what's really necessary.

Does something like the following suit your needs?

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 299ec4b..6cdf4be 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -140,6 +140,7 @@ struct skb_frag_struct {
  */
 struct skb_shared_info {
 	atomic_t	dataref;
+	atomic_t	*in_flight;
 	unsigned short	nr_frags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d96d9b1..62bb58d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -271,6 +271,8 @@ struct tcp_sock {
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
 	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
 
+	atomic_t host_inflight;	/* packets queued in transmit path	*/
+
 	/* Data for direct copy to user */
 	struct {
 		struct sk_buff_head	prequeue;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4fe605f..a6880c2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -212,6 +212,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
+	shinfo->in_flight = NULL;
 	shinfo->nr_frags  = 0;
 	shinfo->gso_size = 0;
 	shinfo->gso_segs = 0;
@@ -403,6 +404,8 @@ static void skb_release_all(struct sk_buff *skb)
 void __kfree_skb(struct sk_buff *skb)
 {
 	skb_release_all(skb);
+	if (skb_shinfo(skb)->in_flight)
+		atomic_dec(skb_shinfo(skb)->in_flight);
 	kfree_skbmem(skb);
 }
 
@@ -486,6 +489,8 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	atomic_set(&n->users, 1);
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));
+	if (skb_shinfo(skb)->in_flight)
+		atomic_inc(skb_shinfo(skb)->in_flight);
 	skb->cloned = 1;
 
 	return n;
@@ -743,6 +748,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
+	skb_shinfo(skb)->in_flight = NULL;
 	return 0;
 
 nodata:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f886531..28a71fd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -479,6 +479,7 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
+	skb_shinfo(skb)->in_flight = &tp->host_inflight;
 	skb->csum    = 0;
 	tcb->seq     = tcb->end_seq = tp->write_seq;
 	tcb->flags   = TCPCB_FLAG_ACK;

