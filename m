From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/9] sky2: lock less transmit completion
Date: Fri, 14 Aug 2009 08:15:18 -0700
Message-ID: <20090814151608.441363342@vyatta.com>
References: <20090814151511.992669598@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44116 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932514AbZHNPTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 11:19:51 -0400
Content-Disposition: inline; filename=sky2-tx4b.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Transmit completion can safely run lockless against transmit start.
In the normal case, completion is done from NAPI and only looks
at elements that are at the tail of the ring.  When doing shutdown
or reset, the transmiter should be completely block by NAPI disable
and blocking of transmit queue. 

Based on earlier work by Mike McCormack.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |  120 +++++++++++++++++++++++++----------------------------
 1 file changed, 57 insertions(+), 63 deletions(-)

--- a/drivers/net/sky2.c	2009-08-14 07:58:48.448220547 -0700
+++ b/drivers/net/sky2.c	2009-08-14 07:58:49.410251274 -0700
@@ -1734,8 +1734,12 @@ mapping_error:
 /*
  * Free ring elements from starting at tx_cons until "done"
  *
- * NB: the hardware will tell us about partial completion of multi-part
+ * NB:
+ *  1. The hardware will tell us about partial completion of multi-part
  *     buffers so make sure not to free skb to early.
+ *  2. This may run in parallel start_xmit because the it only
+ *     looks at the tail of the queue of FIFO (tx_cons), not
+ *     the head (tx_prod)
  */
 static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 {
@@ -1793,16 +1797,6 @@ static void sky2_tx_complete(struct sky2
 		netif_wake_queue(dev);
 }
 
-/* Cleanup all untransmitted buffers, assume transmitter not running */
-static void sky2_tx_clean(struct net_device *dev)
-{
-	struct sky2_port *sky2 = netdev_priv(dev);
-
-	netif_tx_lock_bh(dev);
-	sky2_tx_complete(sky2, sky2->tx_prod);
-	netif_tx_unlock_bh(dev);
-}
-
 static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
 {
 	/* Disable Force Sync bit and Enable Alloc bit */
@@ -1890,7 +1884,9 @@ static int sky2_down(struct net_device *
 
 	sky2_tx_reset(hw, port);
 
-	sky2_tx_clean(dev);
+	/* Free any pending frames stuck in HW queue */
+	sky2_tx_complete(sky2, sky2->tx_prod);
+
 	sky2_rx_clean(sky2);
 
 	pci_free_consistent(hw->pdev, RX_LE_BYTES,
@@ -2367,11 +2363,8 @@ static inline void sky2_tx_done(struct n
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (netif_running(dev)) {
-		netif_tx_lock(dev);
+	if (netif_running(dev))
 		sky2_tx_complete(sky2, last);
-		netif_tx_unlock(dev);
-	}
 }
 
 static inline void sky2_skb_rx(const struct sky2_port *sky2,

-- 

