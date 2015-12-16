From: Luuk Paulussen <luuk.paulussen@alliedtelesis.co.nz>
Subject: [PATCH] Octeon: Fix logic for waking octoen ethernet tx queue.
Date: Thu, 17 Dec 2015 09:59:32 +1300
Message-ID: <1450299572-11012-1-git-send-email-luuk.paulussen@alliedtelesis.co.nz>
Cc: support@caviumnetworks.com,
	Luuk Paulussen <luuk.paulussen@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:59429 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934216AbbLPU7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 15:59:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethernet driver tx queue is stopped when the queue length exceeds
what is allowed.  It should only be started again when the queue length
is back within bounds.

The logic here was just reenabling the queue when any buffers had been
freed.  the queue was stopped whenever the length exceeded 1000
(MAX_OUT_QUEUE_DEPTH), but then was essentially immediately started again.
On a congested link, the queue length would just keep increasing up to around
8000 (for average size packets), at which point the hardware would start
refusing the packets and they would begin to be dropped.
This prevented the qdisc layer from effectively managing and prioritising
packets, as essentially all packets were being allowed into the driver queue
and then were being dropped by the hardware.

This change only restarts the queue if the length is less than 1000
(MAX_OUT_QUEUE_DEPTH).

Reviewed-by: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>
Reviewed-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
Reviewed-by: Richard Laing <richard.laing@alliedtelesis.co.nz>
---
 drivers/staging/octeon/ethernet-tx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index c053c4a..31292fe 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -126,7 +126,7 @@ static void cvm_oct_free_tx_skbs(struct net_device *dev)
 		}
 		total_remaining += skb_queue_len(&priv->tx_free_list[qos]);
 	}
-	if (total_freed >= 0 && netif_queue_stopped(dev))
+	if (total_remaining < MAX_OUT_QUEUE_DEPTH && netif_queue_stopped(dev))
 		netif_wake_queue(dev);
 	if (total_remaining)
 		cvm_oct_kick_tx_poll_watchdog();
-- 
2.6.4
