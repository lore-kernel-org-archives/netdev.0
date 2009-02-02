From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] udp : increments sk_drops in __udp_queue_rcv_skb()
Date: Mon, 02 Feb 2009 16:32:51 +0100
Message-ID: <49871223.2000701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33528 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbZBBPdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 10:33:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

While investigating with Kenny Chang multicast drops problems, I found sk_drops
field was not anymore updated in current kernels for UDP IPV4 sockets.

Thank you

[PATCH] udp: increments sk_drops in __udp_queue_rcv_skb()

Commit 93821778def10ec1e69aa3ac10adee975dad4ff3
(udp: Fix rcv socket locking) accidentally removed sk_drops increments for
UDP IPV4 sockets.

This field can be used to detect incorrect sizing of socket receive buffers.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b7faffe..997c418 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1015,9 +1015,11 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	if ((rc = sock_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
-		if (rc == -ENOMEM)
+		if (rc == -ENOMEM) {
 			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
 					 is_udplite);
+			atomic_inc(&sk->sk_drops);
+		}
 		goto drop;
 	}
 
