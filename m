From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual device
Date: Wed, 17 Sep 2014 10:08:08 +0200
Message-ID: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34299 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbaIQIIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 04:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 412ca1550cbe ("macvlan: Move broadcasts into a work queue"), the
driver uses tx_queue_len of the master device as the limit of packets enqueuing.
Problem is that virtual drivers have this value set to 0, thus all broadcast
packets were rejected.
Because tx_queue_len was arbitrarily chosen, I replace it with a static limit
of 1000 (also arbitrarily chosen).

CC: Herbert Xu <herbert@gondor.apana.org.au>
Reported-by: Thibaut Collet <thibaut.collet@6wind.com>
Suggested-by: Thibaut Collet <thibaut.collet@6wind.com>
Tested-by: Thibaut Collet <thibaut.collet@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/macvlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index a96955597755..8e776935ca52 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -36,6 +36,7 @@
 #include <linux/netpoll.h>
 
 #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
+#define MACVLAN_BC_QUEUE_LEN	1000
 
 struct macvlan_port {
 	struct net_device	*dev;
@@ -248,7 +249,7 @@ static void macvlan_broadcast_enqueue(struct macvlan_port *port,
 		goto err;
 
 	spin_lock(&port->bc_queue.lock);
-	if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
+	if (skb_queue_len(&port->bc_queue) < MACVLAN_BC_QUEUE_LEN) {
 		__skb_queue_tail(&port->bc_queue, nskb);
 		err = 0;
 	}
-- 
2.1.0
