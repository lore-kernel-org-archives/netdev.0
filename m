From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 2/2] xen-netfront: call netif_carrier_off() only once when disconnecting
Date: Wed, 2 Jul 2014 16:09:15 +0100
Message-ID: <1404313755-27349-3-git-send-email-david.vrabel@citrix.com>
References: <1404313755-27349-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15604 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754048AbaGBPJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 11:09:25 -0400
In-Reply-To: <1404313755-27349-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In xennet_disconnect_backend(), netif_carrier_off() was called once
per queue when it needs to only be called once.

The queue locking around the netif_carrier_off() call looked very
odd. I think they were supposed to synchronize any NAPI instances with
the expectation that no further NAPI instances would be scheduled
because of the carrier being off (see the check in
xennet_rx_interrupt()).  But I can't easily tell if this works
correctly.

Instead, add a napi_synchronize() call after disabling the interrupts.
This is obviously correct as with no Rx interrupts, no further NAPI
instances will be scheduled.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6a37d62..055222b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1439,16 +1439,11 @@ static void xennet_disconnect_backend(struct netfront_info *info)
 	unsigned int i = 0;
 	unsigned int num_queues = info->netdev->real_num_tx_queues;
 
+	netif_carrier_off(info->netdev);
+
 	for (i = 0; i < num_queues; ++i) {
 		struct netfront_queue *queue = &info->queues[i];
 
-		/* Stop old i/f to prevent errors whilst we rebuild the state. */
-		spin_lock_bh(&queue->rx_lock);
-		spin_lock_irq(&queue->tx_lock);
-		netif_carrier_off(queue->info->netdev);
-		spin_unlock_irq(&queue->tx_lock);
-		spin_unlock_bh(&queue->rx_lock);
-
 		if (queue->tx_irq && (queue->tx_irq == queue->rx_irq))
 			unbind_from_irqhandler(queue->tx_irq, queue);
 		if (queue->tx_irq && (queue->tx_irq != queue->rx_irq)) {
@@ -1458,6 +1453,8 @@ static void xennet_disconnect_backend(struct netfront_info *info)
 		queue->tx_evtchn = queue->rx_evtchn = 0;
 		queue->tx_irq = queue->rx_irq = 0;
 
+		napi_synchronize(&queue->napi);
+
 		/* End access and free the pages */
 		xennet_end_access(queue->tx_ring_ref, queue->tx.sring);
 		xennet_end_access(queue->rx_ring_ref, queue->rx.sring);
-- 
1.7.10.4
