From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net] tcp: Fix integer-overflows in TCP veno
Date: Tue, 22 Jul 2014 23:33:58 +0200
Message-ID: <1406064838-21782-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35045 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932226AbaGVVe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 17:34:26 -0400
Received: by mail-wg0-f42.google.com with SMTP id l18so250298wgh.25
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 14:34:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In veno we do a multiplication of the cwnd and the rtt. This
may overflow and thus their result is stored in a u64. However, we first
need to cast the cwnd so that actually 64-bit arithmetic is done.

A first attempt at fixing 76f1017757aa0 ([TCP]: TCP Veno congestion
control) was made by 159131149c2 (tcp: Overflow bug in Vegas), but it
failed to add the required cast in tcp_veno_cong_avoid().

Fixes: 76f1017757aa0 ([TCP]: TCP Veno congestion control)
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_veno.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 27b9825753d1..8276977d2c85 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -144,7 +144,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 
 		rtt = veno->minrtt;
 
-		target_cwnd = (tp->snd_cwnd * veno->basertt);
+		target_cwnd = (u64)tp->snd_cwnd * veno->basertt;
 		target_cwnd <<= V_PARAM_SHIFT;
 		do_div(target_cwnd, rtt);
 
-- 
1.9.3
