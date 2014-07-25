From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH v2 net] tcp: Fix integer-overflows in TCP vegas
Date: Fri, 25 Jul 2014 13:52:39 +0200
Message-ID: <1406289159-30498-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Neal Cardwell <ncardwell@google.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Doug Leith <doug.leith@nuim.ie>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:55630 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760052AbaGYLyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 07:54:00 -0400
Received: by mail-we0-f180.google.com with SMTP id w61so4177111wes.39
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 04:53:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vegas we do a multiplication of the cwnd and the rtt. This
may overflow and thus their result is stored in a u64. The current code
however does not cast the cwnd to a u64 and thus 32-bit arithmetic will
be done. This means, that in case of an integer overflow, the result is
completly wrong.

This patch fixes it, by splitting the calculation of target_cwnd in two:

1. The non-overflow case: We just do a regular division here.
2. The overflow-case: In this case we also want to avoid doing a costly do_div.
   So, we calculate the upper 32 bits (that are overflowing) and the
   error and add everything up. More details are in the comment in
   tcp_vegas.c

For the accuracy, I tested this with a python script that does the
same 32-bit arithmetic and compared the difference of this one with
the result of floating-point arithmetic with the following ranges in
a space-filling design across this 3-dimensional space:

snd_cwnd : [1, 2^31 / 1500] (that's the maximum congestion-window size,
                             assuming a send-buffer of 2^31 and a MSS of 1500)
rtt: [1, 2^28]
baseRTT: [1, rtt]

The error is never bigger than 10% in this simulation.

If I set the rtt bigger than 2^28 the error may grow up to 50%.

Cc: Neal Cardwell <ncardwell@google.com>
Cc: David Laight <David.Laight@ACULAB.COM>
Cc: Doug Leith <doug.leith@nuim.ie>
Fixes: 8d3a564da34e (tcp: tcp_vegas cong avoid fix)
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---

Notes:
    v2: David Laight noted that a do_div is necessary to allow this on 32-bit machines.
        David Miller then added that a do_div should be avoided. So, v2 handles overflows
        now correctly.
    
        Additionally, the target_cwnd could actually be computed a bit later in the code
        (inside the "if", where it is used). But that's probably rather net-next material.

 net/ipv4/tcp_vegas.c | 34 +++++++++++++++++++++++++++++++---
 1 file changed, 31 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 9a5e05f27f4f..ec714d91581e 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -196,8 +196,8 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 			 */
 			tcp_reno_cong_avoid(sk, ack, acked);
 		} else {
-			u32 rtt, diff;
-			u64 target_cwnd;
+			u32 rtt, diff, target_cwnd;
+			u64 cwnd_rtt;
 
 			/* We have enough RTT samples, so, using the Vegas
 			 * algorithm, we determine if we should increase or
@@ -218,7 +218,35 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 			 * This is:
 			 *     (actual rate in segments) * baseRTT
 			 */
-			target_cwnd = tp->snd_cwnd * vegas->baseRTT / rtt;
+			cwnd_rtt = (u64)tp->snd_cwnd * vegas->baseRTT;
+			if (cwnd_rtt > U32_MAX) {
+				/* We would overflow 32-bit integer arithmetic.
+				 *
+				 * So, we split the calculation by using:
+				 * cwnd * baseRTT = U32_MAX * x
+				 * and x = upper + err / U32_MAX
+				 *
+				 * Which brings us to:
+				 * target_cwnd = U32_MAX /rtt * upper + err / rtt
+				 *
+				 * This approach allows an error of less than
+				 * 10% of the target_cwnd compared to the
+				 * intended cwnd (calculated with floating-point
+				 * numbers) for the following ranges:
+				 * cwnd: 1 to 2^31/1500
+				 * rtt: 1 to 2^28
+				 *
+				 * In case the rtt becomes bigger, the error
+				 * increases to 50%.
+				 */
+
+				u32 upper = (u32)(cwnd_rtt >> 32);
+				u32 err = (u32)(cwnd_rtt & U32_MAX);
+
+				target_cwnd = U32_MAX / rtt * upper + err / rtt;
+			} else {
+				target_cwnd = (u32)cwnd_rtt / rtt;
+			}
 
 			/* Calculate the difference between the window we had,
 			 * and the window we would like to have. This quantity
-- 
1.9.3
