From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: Fix memory leaks, sideband filter programming
Date: Thu,  3 Dec 2015 05:25:50 -0800
Message-ID: <1449149160-105219-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kiran Patil <kiran.patil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:6976 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756687AbbLCN0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:04 -0500
In-Reply-To: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kiran Patil <kiran.patil@intel.com>

This patch fixes the memory leak which would be seen otherwise when user
programs flow-director filter using ethtool (sideband filter programming).

When ethtool is used to program flow directory filter, 'raw_buf' gets
allocated and it is supposed to be freed as part of queue cleanup. But
check of 'tx_buffer->skb' was preventing it from being freed.

Change-ID: Ief4f0a1a32a653180498bf6e987c1b4342ab8923
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 19 ++++++++++++++-----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 10 +++++-----
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1d7d01c..18a493e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -235,6 +235,9 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 				 "Filter deleted for PCTYPE %d loc = %d\n",
 				 fd_data->pctype, fd_data->fd_id);
 	}
+	if (err)
+		kfree(raw_packet);
+
 	return err ? -EOPNOTSUPP : 0;
 }
 
@@ -312,6 +315,9 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 				 fd_data->pctype, fd_data->fd_id);
 	}
 
+	if (err)
+		kfree(raw_packet);
+
 	return err ? -EOPNOTSUPP : 0;
 }
 
@@ -387,6 +393,9 @@ static int i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 		}
 	}
 
+	if (err)
+		kfree(raw_packet);
+
 	return err ? -EOPNOTSUPP : 0;
 }
 
@@ -526,11 +535,7 @@ static void i40e_unmap_and_free_tx_resource(struct i40e_ring *ring,
 					    struct i40e_tx_buffer *tx_buffer)
 {
 	if (tx_buffer->skb) {
-		if (tx_buffer->tx_flags & I40E_TX_FLAGS_FD_SB)
-			kfree(tx_buffer->raw_buf);
-		else
-			dev_kfree_skb_any(tx_buffer->skb);
-
+		dev_kfree_skb_any(tx_buffer->skb);
 		if (dma_unmap_len(tx_buffer, len))
 			dma_unmap_single(ring->dev,
 					 dma_unmap_addr(tx_buffer, dma),
@@ -542,6 +547,10 @@ static void i40e_unmap_and_free_tx_resource(struct i40e_ring *ring,
 			       dma_unmap_len(tx_buffer, len),
 			       DMA_TO_DEVICE);
 	}
+
+	if (tx_buffer->tx_flags & I40E_TX_FLAGS_FD_SB)
+		kfree(tx_buffer->raw_buf);
+
 	tx_buffer->next_to_watch = NULL;
 	tx_buffer->skb = NULL;
 	dma_unmap_len_set(tx_buffer, len, 0);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 06b6636..4f1ac86 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -51,11 +51,7 @@ static void i40e_unmap_and_free_tx_resource(struct i40e_ring *ring,
 					    struct i40e_tx_buffer *tx_buffer)
 {
 	if (tx_buffer->skb) {
-		if (tx_buffer->tx_flags & I40E_TX_FLAGS_FD_SB)
-			kfree(tx_buffer->raw_buf);
-		else
-			dev_kfree_skb_any(tx_buffer->skb);
-
+		dev_kfree_skb_any(tx_buffer->skb);
 		if (dma_unmap_len(tx_buffer, len))
 			dma_unmap_single(ring->dev,
 					 dma_unmap_addr(tx_buffer, dma),
@@ -67,6 +63,10 @@ static void i40e_unmap_and_free_tx_resource(struct i40e_ring *ring,
 			       dma_unmap_len(tx_buffer, len),
 			       DMA_TO_DEVICE);
 	}
+
+	if (tx_buffer->tx_flags & I40E_TX_FLAGS_FD_SB)
+		kfree(tx_buffer->raw_buf);
+
 	tx_buffer->next_to_watch = NULL;
 	tx_buffer->skb = NULL;
 	dma_unmap_len_set(tx_buffer, len, 0);
-- 
2.5.0
