From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [BUG PATCH NET-NEXT-2.6] kernel panic in dev_hard_start_xmit:
	remove faulty software TX time stamping
Date: Sat, 21 Feb 2009 10:28:08 +0100
Message-ID: <1235208488.22598.40.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49697 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547AbZBUJ2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2009 04:28:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation of the TX software time stamping fallback is
faulty because it accesses the skb after ndo_start_xmit() returns
successfully. This patch removes the fallback, which fixes kernel panics
seen during stress tests. Hardware time stamping is not affected by this
removal.

Signed-Off: Patrick Ohly <patrick.ohly@intel.com>
Signed-Off: Emil Tantilov <emil.s.tantilov@intel.com>

diff --git a/net/core/dev.c b/net/core/dev.c
index d393fc9..1dcace3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1672,16 +1672,6 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
 }
 
-static void tstamp_tx(struct sk_buff *skb)
-{
-	union skb_shared_tx *shtx =
-		skb_tx(skb);
-	if (unlikely(shtx->software &&
-			!shtx->in_progress)) {
-		skb_tstamp_tx(skb, NULL);
-	}
-}
-
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1715,8 +1705,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		 * the skb destructor before the call and restoring it
 		 * afterwards, then doing the skb_orphan() ourselves?
 		 */
-		if (likely(!rc))
-			tstamp_tx(skb);
 		return rc;
 	}
 
@@ -1732,7 +1720,6 @@ gso:
 			skb->next = nskb;
 			return rc;
 		}
-		tstamp_tx(skb);
 		if (unlikely(netif_tx_queue_stopped(txq) && skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);



