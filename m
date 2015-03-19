From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH] fix tcp fin memory accounting
Date: Thu, 19 Mar 2015 19:19:30 -0400
Message-ID: <1426807170-19258-1-git-send-email-johunt@akamai.com>
Cc: edumazet@google.com, Josh Hunt <johunt@akamai.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:36514 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751318AbbCSXTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 19:19:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_send_fin() does not account for the memory it allocates properly, so
sk_forward_alloc can be negative in cases where we've sent a FIN:

ss example output (ss -amn | grep -B1 f4294):
tcp    FIN-WAIT-1 0      1            192.168.0.1:45520         192.0.2.1:8080
	skmem:(r0,rb87380,t0,tb87380,f4294966016,w1280,o0,bl0)
--
tcp    FIN-WAIT-1 0      1            192.168.0.1:8080          192.0.2.1:59710
	skmem:(r0,rb87380,t0,tb87380,f4294966016,w1280,o0,bl0)

This can be resolved by using sk_stream_alloc_skb() instead of calling alloc_skb_fclone()
directly. The same fix was made in tcp_connect() in commit 355a901e6cf1 (tcp: make connect() mem charging friendly).

With this fix applied I no longer see the negative sk_forward_alloc values (or
very large values repoted by ss) in my tests.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 net/ipv4/tcp_output.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5a73ad5..c2f0f60 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2820,15 +2820,11 @@ void tcp_send_fin(struct sock *sk)
 	} else {
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
-			skb = alloc_skb_fclone(MAX_TCP_HEADER,
-					       sk->sk_allocation);
+			skb = sk_stream_alloc_skb(sk, 0, sk->sk_allocation);
 			if (skb)
 				break;
 			yield();
 		}
-
-		/* Reserve space for headers and prepare control bits. */
-		skb_reserve(skb, MAX_TCP_HEADER);
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
 		tcp_init_nondata_skb(skb, tp->write_seq,
 				     TCPHDR_ACK | TCPHDR_FIN);
-- 
1.7.9.5
