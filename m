From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 14/26] igb: cleanup igb_netpoll to be more friendly
	with napi & GRO
Date: Sat, 07 Feb 2009 01:19:29 -0800
Message-ID: <20090207091929.15697.59702.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:39105
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752099AbZBGJTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:19:49 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch cleans up igb_netpoll so that it is more friendly with both the
current napi and newly introduced GRO features.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    5 ++---
 drivers/net/igb/igb_main.c |   37 +++++++++++++++++++++----------------
 2 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 88fdfe4..0519ae4 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -280,9 +280,8 @@ struct igb_adapter {
 #define IGB_FLAG_HAS_MSI           (1 << 0)
 #define IGB_FLAG_MSI_ENABLE        (1 << 1)
 #define IGB_FLAG_DCA_ENABLED       (1 << 2)
-#define IGB_FLAG_IN_NETPOLL        (1 << 3)
-#define IGB_FLAG_QUAD_PORT_A       (1 << 4)
-#define IGB_FLAG_NEED_CTX_IDX      (1 << 5)
+#define IGB_FLAG_QUAD_PORT_A       (1 << 3)
+#define IGB_FLAG_NEED_CTX_IDX      (1 << 4)
 
 enum e1000_state_t {
 	__IGB_TESTING,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c05ca34..3bf560f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -404,7 +404,7 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 		/* Turn on MSI-X capability first, or our settings
 		 * won't stick.  And it will take days to debug. */
 		wr32(E1000_GPIE, E1000_GPIE_MSIX_MODE |
-				   E1000_GPIE_PBA | E1000_GPIE_EIAME | 
+				   E1000_GPIE_PBA | E1000_GPIE_EIAME |
  				   E1000_GPIE_NSICR);
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
@@ -1629,7 +1629,7 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 	for (i = 0; i < IGB_MAX_TX_QUEUES; i++) {
 		r_idx = i % adapter->num_tx_queues;
 		adapter->multi_tx_table[i] = &adapter->tx_ring[r_idx];
-	}	
+	}
 	return err;
 }
 
@@ -3298,7 +3298,7 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 	/* guard against interrupt when we're going down */
 	if (!test_bit(__IGB_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer, jiffies + 1);
-	
+
 no_link_interrupt:
 	wr32(E1000_IMS, E1000_IMS_LSC | E1000_IMS_DOUTSYNC);
 	wr32(E1000_EIMS, adapter->eims_other);
@@ -3751,7 +3751,7 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 
 /**
  * igb_receive_skb - helper function to handle rx indications
- * @ring: pointer to receive ring receving this packet 
+ * @ring: pointer to receive ring receving this packet
  * @status: descriptor status field as written by hardware
  * @vlan: descriptor vlan field as written by hardware (no le/be conversion)
  * @skb: pointer to sk_buff to be indicated to stack
@@ -4378,22 +4378,27 @@ static void igb_shutdown(struct pci_dev *pdev)
 static void igb_netpoll(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	int i;
-	int work_done = 0;
 
-	igb_irq_disable(adapter);
-	adapter->flags |= IGB_FLAG_IN_NETPOLL;
-
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_clean_tx_irq(&adapter->tx_ring[i]);
+	if (!adapter->msix_entries) {
+		igb_irq_disable(adapter);
+		napi_schedule(&adapter->rx_ring[0].napi);
+		return;
+	}
 
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_irq_adv(&adapter->rx_ring[i],
-				     &work_done,
-				     adapter->rx_ring[i].napi.weight);
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct igb_ring *tx_ring = &adapter->tx_ring[i];
+		wr32(E1000_EIMC, tx_ring->eims_value);
+		igb_clean_tx_irq(tx_ring);
+		wr32(E1000_EIMS, tx_ring->eims_value);
+	}
 
-	adapter->flags &= ~IGB_FLAG_IN_NETPOLL;
-	igb_irq_enable(adapter);
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct igb_ring *rx_ring = &adapter->rx_ring[i];
+		wr32(E1000_EIMC, rx_ring->eims_value);
+		napi_schedule(&rx_ring->napi);
+	}
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 

