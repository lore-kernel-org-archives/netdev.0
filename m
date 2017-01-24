From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net 3/3] alx: work around hardware bug in interrupt fallback path
Date: Tue, 24 Jan 2017 14:34:24 +0100
Message-ID: <903f6b4893eded589c75413e106127f9e04ba937.1485263833.git.tobias.regnery@gmail.com>
References: <cover.1485263833.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35562 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdAXNe5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 08:34:57 -0500
Received: by mail-lf0-f68.google.com with SMTP id v186so17384344lfa.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 05:34:56 -0800 (PST)
In-Reply-To: <cover.1485263833.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1485263833.git.tobias.regnery@gmail.com>
References: <cover.1485263833.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If requesting msi-x interrupts fails in alx_request_irq we fall back to
a single tx queue and msi or legacy interrupts.

Currently the adapter stops working in this case and we get tx watchdog
timeouts. For reasons unknown the adapter gets confused when we load the
dma adresses to the chip in alx_init_ring_ptrs twice: the first time with
multiple queues and the second time in the fallback case with a single
queue.

To fix this move the the call to alx_reinit_rings (which calls
alx_init_ring_ptrs) after alx_request_irq. At this time it is clear how
much tx queues we have and which dma addresses we use.

Fixes: d768319cd427 ("alx: enable multiple tx queues")
Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 75cbd46e429d..7dcc907a449d 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -685,8 +685,6 @@ static int alx_alloc_rings(struct alx_priv *alx)
 		return -ENOMEM;
 	}
 
-	alx_reinit_rings(alx);
-
 	return 0;
 }
 
@@ -1242,6 +1240,12 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 	if (err)
 		goto out_free_rings;
 
+	/* must be called after alx_request_irq because the chip stops working
+	 * if we copy the dma addresses in alx_init_ring_ptrs twice when
+	 * requesting msi-x interrupts failed
+	 */
+	alx_reinit_rings(alx);
+
 	netif_set_real_num_tx_queues(alx->dev, alx->num_txq);
 	netif_set_real_num_rx_queues(alx->dev, alx->num_rxq);
 
-- 
2.9.3
