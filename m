From: igorm@etf.rs
Subject: [PATCH net-next] forcedeath: Fix bql support for forcedeath
Date: Fri,  2 Dec 2011 10:48:20 +0100
Message-ID: <1322819300-14330-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:49064 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312Ab1LBJsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 04:48:33 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Moved netdev_completed_queue() out of while loop in function nv_tx_done_optimized().
Because this function was in while loop,
BUG_ON(count > dql->num_queued - dql->num_completed)
was hit in dql_completed().

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 5245dac..4c4e7f4 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2561,13 +2561,14 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 				nv_tx_flip_ownership(dev);
 		}
 
-		netdev_completed_queue(np->dev, tx_work, bytes_cleaned);
-
 		if (unlikely(np->get_tx.ex++ == np->last_tx.ex))
 			np->get_tx.ex = np->first_tx.ex;
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
+
+	netdev_completed_queue(np->dev, tx_work, bytes_cleaned);
+
 	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx))) {
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
-- 
1.7.5.4
