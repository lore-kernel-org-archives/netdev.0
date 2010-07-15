From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: fix problem in reading sock TX queue
Date: Wed, 14 Jul 2010 20:48:08 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1007142025430.22782@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:57792 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758196Ab0GODsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 23:48:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix problem in reading the tx_queue recorded in a socket.  In
dev_pick_tx, the TX queue is read by doing a check with
sk_tx_queue_recorded on the socket, followed by a sk_tx_queue_get.
The problem is that there is not mutual exclusion across these
calls in the socket so it it is possible that the queue in the
sock can be invalidated after sk_tx_queue_recorded is called so
that sk_tx_queue get returns -1, which sets 65535 in queue_index
and thus dev_pick_tx returns 65536 which is a bogus queue and
can cause crash in dev_queue_xmit.

We fix this by only calling sk_tx_queue_get which does the proper
checks.  The interface is that sk_tx_queue_get returns the TX queue
if the sock argument is non-NULL and TX queue is recorded, else it
returns -1.  sk_tx_queue_recorded is no longer used so it can be
completely removed.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/net/sock.h b/include/net/sock.h
index 3100e71..a441c9c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1226,12 +1226,7 @@ static inline void sk_tx_queue_clear(struct sock *sk)
 
 static inline int sk_tx_queue_get(const struct sock *sk)
 {
-	return sk->sk_tx_queue_mapping;
-}
-
-static inline bool sk_tx_queue_recorded(const struct sock *sk)
-{
-	return (sk && sk->sk_tx_queue_mapping >= 0);
+	return sk ? sk->sk_tx_queue_mapping : -1;
 }
 
 static inline void sk_set_socket(struct sock *sk, struct socket *sock)
diff --git a/net/core/dev.c b/net/core/dev.c
index e2b9fa2..f071252 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2053,12 +2053,11 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
-	u16 queue_index;
+	int queue_index;
 	struct sock *sk = skb->sk;
 
-	if (sk_tx_queue_recorded(sk)) {
-		queue_index = sk_tx_queue_get(sk);
-	} else {
+	queue_index = sk_tx_queue_get(sk);
+	if (queue_index < 0) {
 		const struct net_device_ops *ops = dev->netdev_ops;
 
 		if (ops->ndo_select_queue) {
