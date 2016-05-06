From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] i40evf: Drop packet split receive routine
Date: Fri,  6 May 2016 00:03:42 -0700
Message-ID: <1462518228-30527-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40897 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757874AbcEFHGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 03:06:30 -0400
In-Reply-To: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As part of preparation for the rx-refactor, remove the
packet split receive routine and ancillary code.

Some of the split related context set up code stays in
i40e_virtchnl_pf.c in case an older VF driver tries to load
and still wants to use packet split.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 21 +---------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  7 ------
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  2 --
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 14 -----------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 28 +---------------------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  4 ----
 7 files changed, 3 insertions(+), 75 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 6b9db79..36aa33a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -590,7 +590,7 @@ static int i40e_config_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_id,
 		}
 		rx_ctx.hbuff = info->hdr_size >> I40E_RXQ_CTX_HBUFF_SHIFT;
 
-		/* set splitalways mode 10b */
+		/* set split mode 10b */
 		rx_ctx.dtype = I40E_RX_DTYPE_HEADER_SPLIT;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index a37a3f3..61d4a7a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -504,22 +504,6 @@ void i40evf_clean_rx_ring(struct i40e_ring *rx_ring)
 	if (!rx_ring->rx_bi)
 		return;
 
-	if (ring_is_ps_enabled(rx_ring)) {
-		int bufsz = ALIGN(rx_ring->rx_hdr_len, 256) * rx_ring->count;
-
-		rx_bi = &rx_ring->rx_bi[0];
-		if (rx_bi->hdr_buf) {
-			dma_free_coherent(dev,
-					  bufsz,
-					  rx_bi->hdr_buf,
-					  rx_bi->dma);
-			for (i = 0; i < rx_ring->count; i++) {
-				rx_bi = &rx_ring->rx_bi[i];
-				rx_bi->dma = 0;
-				rx_bi->hdr_buf = NULL;
-			}
-		}
-	}
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		rx_bi = &rx_ring->rx_bi[i];
@@ -1435,10 +1419,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	i40e_for_each_ring(ring, q_vector->rx) {
 		int cleaned;
 
-		if (ring_is_ps_enabled(ring))
-			cleaned = i40e_clean_rx_irq_ps(ring, budget_per_ring);
-		else
-			cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
+		cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
 
 		work_done += cleaned;
 		/* if we clean as many as budgeted, we must not be done */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 3b3f976..f24a97e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -244,16 +244,9 @@ struct i40e_rx_queue_stats {
 enum i40e_ring_state_t {
 	__I40E_TX_FDIR_INIT_DONE,
 	__I40E_TX_XPS_INIT_DONE,
-	__I40E_RX_PS_ENABLED,
 	__I40E_RX_16BYTE_DESC_ENABLED,
 };
 
-#define ring_is_ps_enabled(ring) \
-	test_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
-#define set_ring_ps_enabled(ring) \
-	set_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
-#define clear_ring_ps_enabled(ring) \
-	clear_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
 #define ring_is_16byte_desc_enabled(ring) \
 	test_bit(__I40E_RX_16BYTE_DESC_ENABLED, &(ring)->state)
 #define set_ring_16byte_desc_enabled(ring) \
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 25afabf..83ccc58 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -209,8 +209,6 @@ struct i40evf_adapter {
 	u32 flags;
 #define I40EVF_FLAG_RX_CSUM_ENABLED              BIT(0)
 #define I40EVF_FLAG_RX_1BUF_CAPABLE              BIT(1)
-#define I40EVF_FLAG_RX_PS_CAPABLE                BIT(2)
-#define I40EVF_FLAG_RX_PS_ENABLED                BIT(3)
 #define I40EVF_FLAG_IMIR_ENABLED                 BIT(5)
 #define I40EVF_FLAG_MQ_CAPABLE                   BIT(6)
 #define I40EVF_FLAG_NEED_LINK_UPDATE             BIT(7)
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 5a48ee0..e972ebc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -527,12 +527,8 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
  **/
 static u32 i40evf_get_priv_flags(struct net_device *dev)
 {
-	struct i40evf_adapter *adapter = netdev_priv(dev);
 	u32 ret_flags = 0;
 
-	ret_flags |= adapter->flags & I40EVF_FLAG_RX_PS_ENABLED ?
-		I40EVF_PRIV_FLAGS_PS : 0;
-
 	return ret_flags;
 }
 
@@ -546,16 +542,6 @@ static int i40evf_set_priv_flags(struct net_device *dev, u32 flags)
 	struct i40evf_adapter *adapter = netdev_priv(dev);
 	bool reset_required = false;
 
-	if ((flags & I40EVF_PRIV_FLAGS_PS) &&
-	    !(adapter->flags & I40EVF_FLAG_RX_PS_ENABLED)) {
-		adapter->flags |= I40EVF_FLAG_RX_PS_ENABLED;
-		reset_required = true;
-	} else if (!(flags & I40EVF_PRIV_FLAGS_PS) &&
-		   (adapter->flags & I40EVF_FLAG_RX_PS_ENABLED)) {
-		adapter->flags &= ~I40EVF_FLAG_RX_PS_ENABLED;
-		reset_required = true;
-	}
-
 	/* if needed, issue reset to cause things to take effect */
 	if (reset_required)
 		i40evf_schedule_reset(adapter);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 9f0bd7a..52408bc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -641,28 +641,11 @@ static void i40evf_configure_tx(struct i40evf_adapter *adapter)
 static void i40evf_configure_rx(struct i40evf_adapter *adapter)
 {
 	struct i40e_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
-	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i;
-	int rx_buf_len;
-
-
-	/* Set the RX buffer length according to the mode */
-	if (adapter->flags & I40EVF_FLAG_RX_PS_ENABLED ||
-	    netdev->mtu <= ETH_DATA_LEN)
-		rx_buf_len = I40EVF_RXBUFFER_2048;
-	else
-		rx_buf_len = ALIGN(max_frame, 1024);
 
 	for (i = 0; i < adapter->num_active_queues; i++) {
 		adapter->rx_rings[i].tail = hw->hw_addr + I40E_QRX_TAIL1(i);
-		adapter->rx_rings[i].rx_buf_len = rx_buf_len;
-		if (adapter->flags & I40EVF_FLAG_RX_PS_ENABLED) {
-			set_ring_ps_enabled(&adapter->rx_rings[i]);
-			adapter->rx_rings[i].rx_hdr_len = I40E_RX_HDR_SIZE;
-		} else {
-			clear_ring_ps_enabled(&adapter->rx_rings[i]);
-		}
+		adapter->rx_rings[i].rx_buf_len = I40EVF_RXBUFFER_2048;
 	}
 }
 
@@ -1007,12 +990,7 @@ static void i40evf_configure(struct i40evf_adapter *adapter)
 	for (i = 0; i < adapter->num_active_queues; i++) {
 		struct i40e_ring *ring = &adapter->rx_rings[i];
 
-	if (adapter->flags & I40EVF_FLAG_RX_PS_ENABLED) {
-		i40evf_alloc_rx_headers(ring);
-		i40evf_alloc_rx_buffers_ps(ring, ring->count);
-	} else {
 		i40evf_alloc_rx_buffers_1buf(ring, ring->count);
-	}
 		ring->next_to_use = ring->count - 1;
 		writel(ring->next_to_use, ring->tail);
 	}
@@ -2424,10 +2402,6 @@ static void i40evf_init_task(struct work_struct *work)
 
 	adapter->flags |= I40EVF_FLAG_RX_CSUM_ENABLED;
 	adapter->flags |= I40EVF_FLAG_RX_1BUF_CAPABLE;
-	adapter->flags |= I40EVF_FLAG_RX_PS_CAPABLE;
-
-	/* Default to single buffer rx, can be changed through ethtool. */
-	adapter->flags &= ~I40EVF_FLAG_RX_PS_ENABLED;
 
 	netdev->netdev_ops = &i40evf_netdev_ops;
 	i40evf_set_ethtool_ops(netdev);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index ba7fbc0..c5d33a2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -270,10 +270,6 @@ void i40evf_configure_queues(struct i40evf_adapter *adapter)
 		vqpi->rxq.max_pkt_size = adapter->netdev->mtu
 					+ ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN;
 		vqpi->rxq.databuffer_size = adapter->rx_rings[i].rx_buf_len;
-		if (adapter->flags & I40EVF_FLAG_RX_PS_ENABLED) {
-			vqpi->rxq.splithdr_enabled = true;
-			vqpi->rxq.hdr_size = I40E_RX_HDR_SIZE;
-		}
 		vqpi++;
 	}
 
-- 
2.5.5
