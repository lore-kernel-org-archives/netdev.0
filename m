From: Tom Herbert <therbert@google.com>
Subject: [PATCH] forcedeth: Account for consumed budget in napi poll
Date: Wed, 5 May 2010 21:15:21 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1005052111440.31888@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:14043 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776Ab0EFEP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 00:15:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Repeated calls to nv_rx_process in napi poll routine do not take
portion of budget that has been consumed in previous calls.  Fix by
subtracting the number of packets processed.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index f9e1dd4..e282d0a 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3564,14 +3564,15 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 			tx_work += nv_tx_done(dev, np->tx_ring_size);
 			spin_unlock_irqrestore(&np->lock, flags);
 
-			rx_count = nv_rx_process(dev, budget);
+			rx_count = nv_rx_process(dev, budget - rx_work);
 			retcode = nv_alloc_rx(dev);
 		} else {
 			spin_lock_irqsave(&np->lock, flags);
 			tx_work += nv_tx_done_optimized(dev, np->tx_ring_size);
 			spin_unlock_irqrestore(&np->lock, flags);
 
-			rx_count = nv_rx_process_optimized(dev, budget);
+			rx_count = nv_rx_process_optimized(dev,
+			    budget - rx_work);
 			retcode = nv_alloc_rx_optimized(dev);
 		}
 	} while (retcode == 0 &&
