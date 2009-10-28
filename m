From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 12/23] igb: cleanup code related to ring resource
	allocation and free
Date: Wed, 28 Oct 2009 02:49:20 -0700
Message-ID: <20091028094919.13156.21655.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:40787
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751482AbZJ1JxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:53:06 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch cleans up some of the ring alloc and free code to better handle
exceptions such as attempting to free resources on an already freed ring.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f75f90f..e67ff0e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1952,7 +1952,8 @@ int igb_setup_tx_resources(struct igb_ring *tx_ring)
 	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
-	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
+	tx_ring->desc = pci_alloc_consistent(pdev,
+	                                     tx_ring->size,
 					     &tx_ring->dma);
 
 	if (!tx_ring->desc)
@@ -1978,13 +1979,13 @@ err:
  **/
 static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	int i, err = 0;
-	int r_idx;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		err = igb_setup_tx_resources(&adapter->tx_ring[i]);
 		if (err) {
-			dev_err(&adapter->pdev->dev,
+			dev_err(&pdev->dev,
 				"Allocation for Tx Queue %u failed\n", i);
 			for (i--; i >= 0; i--)
 				igb_free_tx_resources(&adapter->tx_ring[i]);
@@ -1993,7 +1994,7 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 	}
 
 	for (i = 0; i < IGB_MAX_TX_QUEUES; i++) {
-		r_idx = i % adapter->num_tx_queues;
+		int r_idx = i % adapter->num_tx_queues;
 		adapter->multi_tx_table[i] = &adapter->tx_ring[r_idx];
 	}
 	return err;
@@ -2116,6 +2117,7 @@ int igb_setup_rx_resources(struct igb_ring *rx_ring)
 
 err:
 	vfree(rx_ring->buffer_info);
+	rx_ring->buffer_info = NULL;
 	dev_err(&pdev->dev, "Unable to allocate memory for "
 		"the receive descriptor ring\n");
 	return -ENOMEM;
@@ -2130,12 +2132,13 @@ err:
  **/
 static int igb_setup_all_rx_resources(struct igb_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		err = igb_setup_rx_resources(&adapter->rx_ring[i]);
 		if (err) {
-			dev_err(&adapter->pdev->dev,
+			dev_err(&pdev->dev,
 				"Allocation for Rx Queue %u failed\n", i);
 			for (i--; i >= 0; i--)
 				igb_free_rx_resources(&adapter->rx_ring[i]);
@@ -2476,6 +2479,10 @@ void igb_free_tx_resources(struct igb_ring *tx_ring)
 	vfree(tx_ring->buffer_info);
 	tx_ring->buffer_info = NULL;
 
+	/* if not set, then don't free */
+	if (!tx_ring->desc)
+		return;
+
 	pci_free_consistent(tx_ring->pdev, tx_ring->size,
 	                    tx_ring->desc, tx_ring->dma);
 
@@ -2534,14 +2541,10 @@ static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 	memset(tx_ring->buffer_info, 0, size);
 
 	/* Zero out the descriptor ring */
-
 	memset(tx_ring->desc, 0, tx_ring->size);
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
-
-	writel(0, tx_ring->head);
-	writel(0, tx_ring->tail);
 }
 
 /**
@@ -2569,6 +2572,10 @@ void igb_free_rx_resources(struct igb_ring *rx_ring)
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
+	/* if not set, then don't free */
+	if (!rx_ring->desc)
+		return;
+
 	pci_free_consistent(rx_ring->pdev, rx_ring->size,
 	                    rx_ring->desc, rx_ring->dma);
 
@@ -2601,6 +2608,7 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 
 	if (!rx_ring->buffer_info)
 		return;
+
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
@@ -2638,9 +2646,6 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
-
-	writel(0, rx_ring->head);
-	writel(0, rx_ring->tail);
 }
 
 /**

