From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Thu, 21 Feb 2008 19:51:52 +0100
Message-ID: <47BDC848.50607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000801010702030709080103"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:34872 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167AbYBUSv4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 13:51:56 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2e24.orange.fr (SMTP Server) with ESMTP id DA6D2700009A
	for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 19:51:54 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000801010702030709080103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

This is an RFC, based on net-2.6 for convenience only.

Thank you

[RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()

Loopback transmit function loopback_xmit() actually calls netif_rx() to 
queue
a skb to the softnet queue, and arms a softirq so that this skb can be 
handled later.

This has a cost on SMP, because we need to hold a reference on the 
device, and free this
reference when softirq dequeues packet.

Following patch directly calls netif_receive_skb() and avoids lot of 
atomic operations.
(atomic_inc(&dev->refcnt), set_and_set_bit(NAPI_STATE_SCHED, &n->state), ...
  atomic_dec(&dev->refcnt)...), cache line ping-pongs on device refcnt, 
but also softirq overhead.

This gives a nice boost on tbench for example (5 % on my machine)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------000801010702030709080103
Content-Type: text/plain;
 name="loopback_xmit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="loopback_xmit.patch"

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index f2a6e71..9bed7ed 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -158,7 +158,7 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 	lb_stats->bytes += skb->len;
 	lb_stats->packets++;
 
-	netif_rx(skb);
+	netif_receive_skb(skb);
 
 	return 0;
 }

--------------000801010702030709080103--


