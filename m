From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 17/20] igb: make tx ring map and free
	functionality non-static
Date: Tue, 27 Oct 2009 18:54:43 -0700
Message-ID: <20091028015442.12470.96576.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:42861
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757160AbZJ1B60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:58:26 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes a minor change to the xmit_frame_ring_adv funcition in that
it moves 2 checks from it into the xmit_frame_adv since the checks were not
ring specific.  In addition it exports the xmit_frame_ring_adv and the
unmap_and_free_tx_resource calls so that they can be used by other code such
as the ethtool loopback testing calls.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    3 +++
 drivers/net/igb/igb_main.c |   35 ++++++++++++++++-------------------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 8b189a0..6c35c90 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -349,6 +349,9 @@ extern void igb_configure_tx_ring(struct igb_adapter *, struct igb_ring *);
 extern void igb_configure_rx_ring(struct igb_adapter *, struct igb_ring *);
 extern void igb_setup_tctl(struct igb_adapter *);
 extern void igb_setup_rctl(struct igb_adapter *);
+extern netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *, struct igb_ring *);
+extern void igb_unmap_and_free_tx_resource(struct igb_ring *,
+					   struct igb_buffer *);
 extern void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
 extern void igb_update_stats(struct igb_adapter *);
 extern void igb_set_ethtool_ops(struct net_device *);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 576a4fa..c9fda11 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -99,10 +99,7 @@ static void igb_set_rx_mode(struct net_device *);
 static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
 static void igb_watchdog_task(struct work_struct *);
-static netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *,
-					   struct igb_ring *);
-static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb,
-				      struct net_device *);
+static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *);
 static struct net_device_stats *igb_get_stats(struct net_device *);
 static int igb_change_mtu(struct net_device *, int);
 static int igb_set_mac(struct net_device *, void *);
@@ -2521,8 +2518,8 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 		igb_free_tx_resources(&adapter->tx_ring[i]);
 }
 
-static void igb_unmap_and_free_tx_resource(struct igb_ring *tx_ring,
-					   struct igb_buffer *buffer_info)
+void igb_unmap_and_free_tx_resource(struct igb_ring *tx_ring,
+				    struct igb_buffer *buffer_info)
 {
 	buffer_info->dma = 0;
 	if (buffer_info->skb) {
@@ -3585,8 +3582,8 @@ static int igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
 	return __igb_maybe_stop_tx(tx_ring, size);
 }
 
-static netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
-					   struct igb_ring *tx_ring)
+netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
+				    struct igb_ring *tx_ring)
 {
 	struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
 	unsigned int first;
@@ -3596,16 +3593,6 @@ static netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	int tso = 0;
 	union skb_shared_tx *shtx;
 
-	if (test_bit(__IGB_DOWN, &adapter->state)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
-	if (skb->len <= 0) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	/* need: 1 descriptor per page,
 	 *       + 2 desc gap to keep tail from touching head,
 	 *       + 1 desc for skb->data,
@@ -3680,8 +3667,18 @@ static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct igb_ring *tx_ring;
-
 	int r_idx = 0;
+
+	if (test_bit(__IGB_DOWN, &adapter->state)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (skb->len <= 0) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
 	r_idx = skb->queue_mapping & (IGB_ABS_MAX_TX_QUEUES - 1);
 	tx_ring = adapter->multi_tx_table[r_idx];
 

