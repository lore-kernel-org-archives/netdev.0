From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH v3 net] tcp: Fix integer-overflow in TCP vegas
Date: Tue, 29 Jul 2014 13:40:57 +0200
Message-ID: <1406634057-1289-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Doug Leith <doug.leith@nuim.ie>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:43547 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409AbaG2LlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 07:41:24 -0400
Received: by mail-we0-f178.google.com with SMTP id w61so8650650wes.23
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 04:41:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vegas we do a multiplication of the cwnd and the rtt. This
may overflow and thus their result is stored in a u64. However, we first
need to cast the cwnd so that actually 64-bit arithmetic is done.

Then, we need to do do_div to allow this to be used on 32-bit arches.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Laight <David.Laight@ACULAB.COM>
Cc: Doug Leith <doug.leith@nuim.ie>
Fixes: 8d3a564da34e (tcp: tcp_vegas cong avoid fix)
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---

Notes:
    v3: Go back to v1, using a simple type-cast and adding the do_div, as suggested
        by Stephen and Eric.
    
    v2: David Laight noted that a do_div is necessary to allow this on 32-bit machines.
        David Miller then added that a do_div should be avoided. So, v2 handles overflows
        now correctly.
    
        Additionally, the target_cwnd could actually be computed a bit later in the code
        (inside the "if", where it is used). But that's probably rather net-next material.

 net/ipv4/tcp_vegas.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 9a5e05f27f4f..b40ad897f945 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -218,7 +218,8 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 			 * This is:
 			 *     (actual rate in segments) * baseRTT
 			 */
-			target_cwnd = tp->snd_cwnd * vegas->baseRTT / rtt;
+			target_cwnd = (u64)tp->snd_cwnd * vegas->baseRTT;
+			do_div(target_cwnd, rtt);
 
 			/* Calculate the difference between the window we had,
 			 * and the window we would like to have. This quantity
-- 
1.9.3
