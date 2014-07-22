From: P.Fiterau-Brostean@science.ru.nl
Subject: RFC973 and RFC5961 invalid ack compliance
Date: Tue, 22 Jul 2014 22:36:35 +0200
Message-ID: <8c4462613e81134352365f810188fe1f.squirrel@squirrel.science.ru.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Frits Vaandrager" <F.Vaandrager@cs.ru.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tortel.science.ru.nl ([131.174.16.137]:49759 "EHLO
	tortel.science.ru.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbaGVUvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 16:51:39 -0400
Received: from smeltpunt.science.ru.nl (smeltpunt.science.ru.nl [131.174.16.143])
	by tortel.science.ru.nl (8.14.4/5.32) with ESMTP id s6MKpaeV022708
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 22:51:36 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The protocols have that for (1) SEG.ACK > SND.NXT (RFC973 p. 72) and (2)
SEG.ACK < SND.UNA - MAX_WIN_SIZE (RFC5691 p. 11) that the ack is
unacceptable and that tcp should send an ACK and drop the segment.
Corresponding standard excerpts are displayed at the end.

Currently, the behavior is inconsistent, as an ACK is sent only in case
(2) and not in case (1) (which is misinterpreted). I suggest a patch to
correct this, based on the one Neal Caldwell has given previously on this
same issue, and make things clearer below:

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b5c2375..55724a0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3371,24 +3371,26 @@ static int tcp_ack(struct sock *sk, const struct
sk_buff *skb, int flag)
 	int acked = 0; /* Number of packets newly acked */
 	long sack_rtt_us = -1L;

-	/* If the ack is older than previous acks
-	 * then we can probably ignore it.
-	 */
 	if (before(ack, prior_snd_una)) {
-		/* RFC 5961 5.2 [Blind Data Injection Attack].[Mitigation] */
-		if (before(ack, prior_snd_una - tp->max_window)) {
-			tcp_send_challenge_ack(sk);
-			return -1;
+		/* If the ack < SND.UNA - MAX.SND.WND, it is invalid.
+		 * (RFC5961 Section 5.2 [Blind Data Injection Attack].[Mitigation])
+		 */
+		if (before(ack, prior_snd_una - tp->max_window))
+			goto invalid_ack;
+		/* If the ack is older but within max_window of previous acks
+		 * then we can probably ignore it.
+		 */
+		else
+			goto old_ack;
+	} else {
+		/* If the ack includes data we haven't sent yet (SEG.ACK > SND.NXT), it
is invalid.
+		 * (RFC793 Section 3.9, p. 72)
+		 */
+		if (after(ack, tp->snd_nxt)) {
+			goto invalid_ack;
 		}
-		goto old_ack;
 	}

-	/* If the ack includes data we haven't sent yet, discard
-	 * this segment (RFC793 Section 3.9).
-	 */
-	if (after(ack, tp->snd_nxt))
-		goto invalid_ack;
-
 	if (icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
 	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)
 		tcp_rearm_rto(sk);
@@ -3489,7 +3491,15 @@ no_queue:
 	return 1;

 invalid_ack:
-	SOCK_DEBUG(sk, "Ack %u after %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
+        /* If the ack is unacceptable, send ACK,
+	 * drop the segment and return (RFC793 Section 3.4, p. 37).
+	 * Send ACK according to (RFC5961 Section 7 [ACK Throttling])
+         */
+	tcp_send_challenge_ack(sk);
+	if(after(ack, tp->snd_nxt))
+		SOCK_DEBUG(sk, "Ack %u after %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
+	if(before(ack, prior_snd_una - tp->max_window))
+		SOCK_DEBUG(sk, "Ack %u before %u:%u\n", ack, tp->snd_una, prior_snd_una
- tp->max_window);
 	return -1;

 old_ack:

I am interested to know if there are significant negative implications
that this tweak might have. The patch does not seem to affect any of the
working packetdrill tests on my machine. Bellow are packetdrills script to
test for ACK receipt in both (1) and (2) in sync states.

For ESTABLISHED and FIN_WAIT2:

// Checks ACK-ing of invalid ack segments in ESTABLISHED and FIN_WAIT_2
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0    setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0    bind(3, ..., ...) = 0
+0    listen(3, 1) = 0

// Establish connection 67291
0.000 < S 0:0(0) win 32792 <mss 1460,nop,nop,sackOK>
0.000 > S. 0:0(0) ack 1    <mss 1460,nop,nop,sackOK>
0.100 < . 1:1(0) ack 1 win 32792

0.100 accept(3, ..., ...) = 4

// Check ack-ing invalid ACK in ESTABLISHED
0.100 < . 1:1(0) ack 10 win 32792   // (RFC793 invalid ack)
0.100 > . 1:1(0) ack 1
0.100 < . 1:1(0) ack 4294934504 win 32792   // (RFC5961 invalid ack)
0.100 > . 1:1(0) ack 1

0.200 close(4) = 0
0.200 > F. 1:1(0) ack 1

// Check ack-ing invalid ACK in FIN-WAIT_2
0.200 < . 2:2(0) ack 10 win 32792   // (RFC793 invalid ack)
0.200 > . 2:2(0) ack 1
0.200 < . 2:2(0) ack 4294934504 win 32792   // (RFC5961 invalid ack)
0.200 > . 2:2(0) ack 1
0.300 < F. 1:1(0) ack 2 win 32792
0.300 > . 2:2(0) ack 2

For CLOSE_WAIT:
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0    setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0    bind(3, ..., ...) = 0
+0    listen(3, 1) = 0

// Go to CLOSE_WAIT fast
0.000 < S 0:0(0) win 32792 <mss 1460,nop,nop,sackOK>
0.000 > S. 0:0(0) ack 1    <mss 1460,nop,nop,sackOK>
0.000 < F. 1:1(0) ack 1 win 32792
0.000 > . 1:1(0) ack 2

// Check ack-ing invalid ACK in CLOSE_WAIT
0.100 < . 1:1(0) ack 10 win 32792   // (RFC793 invalid ack)
0.100 > . 1:1(0) ack 2
0.100 < . 1:1(0) ack 4294934504 win 32792   // (RFC5961 invalid ack)
0.100 > . 1:1(0) ack 2

0.200 close(3)
0.200 > F. 1:1(0) ack 2

I suspect the same behavior would be exhibited for FIN_WAIT_1 and
LAST_ACK, but this cannot be readily tested with packetdrill (as close
cannot be split in 2).

It would be useful if packetdrill could support
-> checking that no output was emitted as a response to a package
-> allowing negative relative numbers to be set (so it is not necessary to
resort to 4294934504)


RFC973:
   If the ACK acks
   something not yet sent (SEG.ACK > SND.NXT) then send an ACK,
   drop the segment, and return.

RFC5691:
   The ACK value is considered acceptable only if
   it is in the range of ((SND.UNA - MAX.SND.WND) <= SEG.ACK <=
   SND.NXT).  All incoming segments whose ACK value doesn't satisfy the
   above condition MUST be discarded and an ACK sent back.
