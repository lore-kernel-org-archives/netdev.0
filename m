From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Advance fast path pointer for first block only
Date: Wed, 31 Jan 2007 12:48:30 -0800 (PST)
Message-ID: <20070131.124830.93210236.davem@davemloft.net>
References: <20070129071339.24050.21052.sendpatchset@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030569AbXAaUsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 15:48:31 -0500
In-Reply-To: <20070129071339.24050.21052.sendpatchset@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Mon, 29 Jan 2007 09:13:39 +0200

> Only advance the SACK fast-path pointer for the first block, the fast-path
> assumes that only the first block advances next time so we should not move the
> skb for the next sack blocks.
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>
> 
> ---
> 
> I'm not sure about the fack_count part, this patch changes the value that is
> maintained in this case.

I'm not sure about this patch :-)

The fastpath is being used for two things here, I believe.

First, it's being used to monitor the expanding of the initial
SACK block, as you note.  This is clear by the fact that we
only use the fastpath cache on future calls when this code path
triggers:

	if (flag)
		num_sacks = 1;

because otherwise we clear the fastpath cache to NULL.

But it's also being used in this loop you are editing to remember
where we stopped in the previous iteration of the loop.  With your
change it will always walk the whole retransmit queue from the end of
the first SACK block, whereas before it would iterate starting at the
last SKB visited at the end of the previous sack block processed by
the loop.

This sounds trivial, but on deep pipes it could bring back some of
the performance problems the hinting was meant to cure.

The fack_count issue should be OK, since we're using the value
properly calculated at the end of the first SACK block as we
iterate to find the SKBs within the SACK block.  Another way
of saying this is that if the algorithm is correct when the
fastpath cache is missed, it should be correct if we only cache
for the first SACK block.

I'll use this opportunity to say I'm rather unhappy with all of
these fastpath hinting schemes.  They chew up a ton of space in
the tcp_sock because we have several pointers for each of the
different queue states we can cache and those eat 8 bytes a
piece on 64-bit.

We can probably fix the bug and preserve the inter-iteration
end-SKB caching by having local variable SKB/fack_count caches
in this function, and only updating the tcp_sock cache values
for the first SACK block.

Maybe something like this?

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c26076f..b470a85 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -936,12 +936,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned char *ptr = ack_skb->h.raw + TCP_SKB_CB(ack_skb)->sacked;
 	struct tcp_sack_block_wire *sp = (struct tcp_sack_block_wire *)(ptr+2);
+	struct sk_buff *cached_skb;
 	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int reord = tp->packets_out;
 	int prior_fackets;
 	u32 lost_retrans = 0;
 	int flag = 0;
 	int dup_sack = 0;
+	int cached_fack_count;
 	int i;
 
 	if (!tp->sacked_out)
@@ -1025,20 +1027,22 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	/* clear flag as used for different purpose in following code */
 	flag = 0;
 
+	/* Use SACK fastpath hint if valid */
+	cached_skb = tp->fastpath_skb_hint;
+	cached_fack_count = tp->fastpath_cnt_hint;
+	if (!cached_skb) {
+		cached_skb = sk->sk_write_queue.next;
+		cached_fack_count = 0;
+	}
+
 	for (i=0; i<num_sacks; i++, sp++) {
 		struct sk_buff *skb;
 		__u32 start_seq = ntohl(sp->start_seq);
 		__u32 end_seq = ntohl(sp->end_seq);
 		int fack_count;
 
-		/* Use SACK fastpath hint if valid */
-		if (tp->fastpath_skb_hint) {
-			skb = tp->fastpath_skb_hint;
-			fack_count = tp->fastpath_cnt_hint;
-		} else {
-			skb = sk->sk_write_queue.next;
-			fack_count = 0;
-		}
+		skb = cached_skb;
+		fack_count = cached_fack_count;
 
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
@@ -1048,8 +1052,12 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			int in_sack, pcount;
 			u8 sacked;
 
-			tp->fastpath_skb_hint = skb;
-			tp->fastpath_cnt_hint = fack_count;
+			cached_skb = skb;
+			cached_fack_count = fack_count;
+			if (i == 0) {
+				tp->fastpath_skb_hint = skb;
+				tp->fastpath_cnt_hint = fack_count;
+			}
 
 			/* The retransmission queue is always in order, so
 			 * we can short-circuit the walk early.
