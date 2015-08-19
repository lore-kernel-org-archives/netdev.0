From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: [PATCH net-next] net/xen-netfront: only clean up queues if present
Date: Wed, 19 Aug 2015 19:14:20 -0400
Message-ID: <1440026060.2546.9.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36508 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbbHSXOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 19:14:22 -0400
Received: by qkep139 with SMTP id p139so8410130qke.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 16:14:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chas Williams <3chas3@gmail.com>

If you simply load and unload the module without starting the interfaces,
the queues are never created and you get a bad pointer dereference.

Signed-off-by: Chas Williams <3chas3@gmail.com>
---
 drivers/net/xen-netfront.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f948c46..002062d 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1336,7 +1336,7 @@ static void xennet_disconnect_backend(struct netfront_info *info)
 
 	netif_carrier_off(info->netdev);
 
-	for (i = 0; i < num_queues; ++i) {
+	for (i = 0; i < num_queues && info->queues; ++i) {
 		struct netfront_queue *queue = &info->queues[i];
 
 		if (queue->tx_irq && (queue->tx_irq == queue->rx_irq))
@@ -2101,7 +2101,8 @@ static int xennet_remove(struct xenbus_device *dev)
 
 	unregister_netdev(info->netdev);
 
-	xennet_destroy_queues(info);
+	if (info->queues)
+		xennet_destroy_queues(info);
 	xennet_free_netdev(info->netdev);
 
 	return 0;
-- 
2.1.0
