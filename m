From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCH net-next-2.6] Re: TCP/IP stack interpretation of acceptable
	packet
Date: Thu, 19 Mar 2009 00:44:53 +0000
Message-ID: <1237423493.32009.31.camel@Maple>
References: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
To: Oliver Zheng <mailinglists+netdev@oliverzheng.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:25371 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992AbZCSAo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 20:44:58 -0400
Received: by qw-out-2122.google.com with SMTP id 8so285630qwh.37
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 17:44:56 -0700 (PDT)
In-Reply-To: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-02-24 at 14:59 -0800, Oliver Zheng wrote:
> When a packet is received with the correct
> sequence number but incorrect acknowledgement number (in my tests, it
> was higher than the correct acknowledgement number), the stack accepts
> the packet as a valid packet and passes the data up to the application

TCP's fast path currently accepts segments who ack data that was never
sent.  The slow path and processing for states other than ESTABLISHED
discard such segments.

RFC793 says (Section 3.9) that not only should such segments be
discarded, but that an ACK should be sent to the peer.  I can't see what
that accomplishes, and it seems to badly interact with fast
retransmit--under some conditions with crafted packets you can get the
two stacks ACKing each other forever.  So I left that out of this patch:


[PATCH net-next-2.6] tcp: Discard segments that ack data not yet sent

Discard incoming packets whose ack field iincludes data not yet sent.
This is consistent with RFC 793 Section 3.9.

Change tcp_ack() to distinguish between too-small and too-large ack
field values.  Keep segments with too-large ack fields out of the fast
path, and change slow path to discard them.

Reported-by:  Oliver Zheng <mailinglists+netdev@oliverzheng.com>
Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 net/ipv4/tcp_input.c |   31 +++++++++++++++++++------------
 1 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fae78e3..01544cd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3587,16 +3587,19 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	u32 prior_fackets;
 	int prior_packets;
 	int frto_cwnd = 0;
-
-	/* If the ack is newer than sent or older than previous acks
+
+	/* If the ack is older than previous acks
 	 * then we can probably ignore it.
 	 */
-	if (after(ack, tp->snd_nxt))
-		goto uninteresting_ack;
-
 	if (before(ack, prior_snd_una))
 		goto old_ack;
 
+	/* If the ack includes data we haven't sent yet, discard
+	 * this segment (RFC793 Section 3.9).
+	 */
+	if (after(ack, tp->snd_nxt))
+		goto invalid_ack;
+
 	if (after(ack, prior_snd_una))
 		flag |= FLAG_SND_UNA_ADVANCED;
 
@@ -3686,6 +3689,10 @@ no_queue:
 		tcp_ack_probe(sk);
 	return 1;
 
+invalid_ack:
+	SOCK_DEBUG(sk, "Ack %u after %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
+	return -1;
+
 old_ack:
 	if (TCP_SKB_CB(skb)->sacked) {
 		tcp_sacktag_write_queue(sk, skb, prior_snd_una);
@@ -3693,9 +3700,8 @@ old_ack:
 			tcp_try_keep_open(sk);
 	}
 
-uninteresting_ack:
-	SOCK_DEBUG(sk, "Ack %u out of %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
-	return 0;
+	SOCK_DEBUG(sk, "Ack %u before %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
+	return 0;
 }
 
 /* Look for tcp options. Normally only called on SYN and SYNACK packets.
@@ -5158,7 +5164,8 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	 */
 
 	if ((tcp_flag_word(th) & TCP_HP_BITS) == tp->pred_flags &&
-	    TCP_SKB_CB(skb)->seq == tp->rcv_nxt) {
+	    TCP_SKB_CB(skb)->seq == tp->rcv_nxt &&
+	    !after(TCP_SKB_CB(skb)->ack_seq, tp->snd_nxt)) {
 		int tcp_header_len = tp->tcp_header_len;
 
 		/* Timestamp header prediction: tcp_header_len
@@ -5311,8 +5318,8 @@ slow_path:
 		return -res;
 
 step5:
-	if (th->ack)
-		tcp_ack(sk, skb, FLAG_SLOWPATH);
+	if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
+		goto discard;
 
 	tcp_rcv_rtt_measure_ts(sk, skb);
 
@@ -5649,7 +5656,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 	/* step 5: check the ACK field */
 	if (th->ack) {
-		int acceptable = tcp_ack(sk, skb, FLAG_SLOWPATH);
+		int acceptable = tcp_ack(sk, skb, FLAG_SLOWPATH) > 0;
 
 		switch (sk->sk_state) {
 		case TCP_SYN_RECV:
-- 
1.5.4.3




