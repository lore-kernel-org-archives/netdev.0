From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/3] e1000: Use kcalloc()
Date: Tue, 06 Mar 2007 08:58:04 -0800
Message-ID: <20070306165804.27452.62594.stgit@localhost.localdomain>
References: <20070306165802.27452.22955.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7329 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965961AbXCFQ63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 11:58:29 -0500
In-Reply-To: <20070306165802.27452.22955.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yan Burman <burman.yan@gmail.com>

Replace kmalloc+memsetout the driver. Slightly modified by Auke Kok.

Signed-off-by: Yan Burman <burman.yan@gmail.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   26 ++++++++++++--------------
 drivers/net/e1000/e1000_main.c    |   29 ++++++++++++-----------------
 2 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index a094288..2881da1 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -654,14 +654,11 @@ e1000_set_ringparam(struct net_device *netdev,
 	e1000_mac_type mac_type = adapter->hw.mac_type;
 	struct e1000_tx_ring *txdr, *tx_old;
 	struct e1000_rx_ring *rxdr, *rx_old;
-	int i, err, tx_ring_size, rx_ring_size;
+	int i, err;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
-	tx_ring_size = sizeof(struct e1000_tx_ring) * adapter->num_tx_queues;
-	rx_ring_size = sizeof(struct e1000_rx_ring) * adapter->num_rx_queues;
-
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
 		msleep(1);
 
@@ -672,11 +669,11 @@ e1000_set_ringparam(struct net_device *netdev,
 	rx_old = adapter->rx_ring;
 
 	err = -ENOMEM;
-	txdr = kzalloc(tx_ring_size, GFP_KERNEL);
+	txdr = kcalloc(adapter->num_tx_queues, sizeof(struct e1000_tx_ring), GFP_KERNEL);
 	if (!txdr)
 		goto err_alloc_tx;
 
-	rxdr = kzalloc(rx_ring_size, GFP_KERNEL);
+	rxdr = kcalloc(adapter->num_rx_queues, sizeof(struct e1000_rx_ring), GFP_KERNEL);
 	if (!rxdr)
 		goto err_alloc_rx;
 
@@ -1053,23 +1050,24 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	struct e1000_rx_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
 	uint32_t rctl;
-	int size, i, ret_val;
+	int i, ret_val;
 
 	/* Setup Tx descriptor ring and Tx buffers */
 
 	if (!txdr->count)
 		txdr->count = E1000_DEFAULT_TXD;
 
-	size = txdr->count * sizeof(struct e1000_buffer);
-	if (!(txdr->buffer_info = kmalloc(size, GFP_KERNEL))) {
+	if (!(txdr->buffer_info = kcalloc(txdr->count,
+	                                  sizeof(struct e1000_buffer),
+		                          GFP_KERNEL))) {
 		ret_val = 1;
 		goto err_nomem;
 	}
-	memset(txdr->buffer_info, 0, size);
 
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	E1000_ROUNDUP(txdr->size, 4096);
-	if (!(txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma))) {
+	if (!(txdr->desc = pci_alloc_consistent(pdev, txdr->size,
+	                                        &txdr->dma))) {
 		ret_val = 2;
 		goto err_nomem;
 	}
@@ -1116,12 +1114,12 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	if (!rxdr->count)
 		rxdr->count = E1000_DEFAULT_RXD;
 
-	size = rxdr->count * sizeof(struct e1000_buffer);
-	if (!(rxdr->buffer_info = kmalloc(size, GFP_KERNEL))) {
+	if (!(rxdr->buffer_info = kcalloc(rxdr->count,
+	                                  sizeof(struct e1000_buffer),
+	                                  GFP_KERNEL))) {
 		ret_val = 4;
 		goto err_nomem;
 	}
-	memset(rxdr->buffer_info, 0, size);
 
 	rxdr->size = rxdr->count * sizeof(struct e1000_rx_desc);
 	if (!(rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma))) {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7bbefca..530d5d7 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1354,31 +1354,27 @@ e1000_sw_init(struct e1000_adapter *adapter)
 static int __devinit
 e1000_alloc_queues(struct e1000_adapter *adapter)
 {
-	int size;
-
-	size = sizeof(struct e1000_tx_ring) * adapter->num_tx_queues;
-	adapter->tx_ring = kmalloc(size, GFP_KERNEL);
+	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
+	                           sizeof(struct e1000_tx_ring), GFP_KERNEL);
 	if (!adapter->tx_ring)
 		return -ENOMEM;
-	memset(adapter->tx_ring, 0, size);
 
-	size = sizeof(struct e1000_rx_ring) * adapter->num_rx_queues;
-	adapter->rx_ring = kmalloc(size, GFP_KERNEL);
+	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
+	                           sizeof(struct e1000_rx_ring), GFP_KERNEL);
 	if (!adapter->rx_ring) {
 		kfree(adapter->tx_ring);
 		return -ENOMEM;
 	}
-	memset(adapter->rx_ring, 0, size);
 
 #ifdef CONFIG_E1000_NAPI
-	size = sizeof(struct net_device) * adapter->num_rx_queues;
-	adapter->polling_netdev = kmalloc(size, GFP_KERNEL);
+	adapter->polling_netdev = kcalloc(adapter->num_rx_queues,
+	                                  sizeof(struct net_device),
+	                                  GFP_KERNEL);
 	if (!adapter->polling_netdev) {
 		kfree(adapter->tx_ring);
 		kfree(adapter->rx_ring);
 		return -ENOMEM;
 	}
-	memset(adapter->polling_netdev, 0, size);
 #endif
 
 	return E1000_SUCCESS;
@@ -1774,18 +1770,18 @@ e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	}
 	memset(rxdr->buffer_info, 0, size);
 
-	size = sizeof(struct e1000_ps_page) * rxdr->count;
-	rxdr->ps_page = kmalloc(size, GFP_KERNEL);
+	rxdr->ps_page = kcalloc(rxdr->count, sizeof(struct e1000_ps_page),
+	                        GFP_KERNEL);
 	if (!rxdr->ps_page) {
 		vfree(rxdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->ps_page, 0, size);
 
-	size = sizeof(struct e1000_ps_page_dma) * rxdr->count;
-	rxdr->ps_page_dma = kmalloc(size, GFP_KERNEL);
+	rxdr->ps_page_dma = kcalloc(rxdr->count,
+	                            sizeof(struct e1000_ps_page_dma),
+	                            GFP_KERNEL);
 	if (!rxdr->ps_page_dma) {
 		vfree(rxdr->buffer_info);
 		kfree(rxdr->ps_page);
@@ -1793,7 +1789,6 @@ e1000_setup_rx_resources(struct e1000_adapter *adapter,
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->ps_page_dma, 0, size);
 
 	if (adapter->hw.mac_type <= e1000_82547_rev_2)
 		desc_len = sizeof(struct e1000_rx_desc);
