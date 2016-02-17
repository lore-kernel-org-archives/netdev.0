From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: fix bug in dma sync
Date: Wed, 17 Feb 2016 09:51:34 -0800
Message-ID: <1455731506-62165-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4789 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161601AbcBQRvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:50 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Driver was using an offset based off a DMA handle while mapping and
unmapping using sync_single_range_for[cpu|device], where it should
be using DMA handle (returned from alloc_coherent) and the offset of the
memory to be sync'd.

Change-ID: I208256565b1595ff0e9171ab852de06b997917c6
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reviewed-by: Nelson, Shannon <shannon.nelson@intel.com>
Reviewed-by: Williams, Mitch A <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 8 ++++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 6234136..f2e6afc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1226,8 +1226,8 @@ void i40e_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
 		}
 
 		dma_sync_single_range_for_device(rx_ring->dev,
-						 bi->dma,
-						 0,
+						 rx_ring->rx_bi[0].dma,
+						 i * rx_ring->rx_hdr_len,
 						 rx_ring->rx_hdr_len,
 						 DMA_FROM_DEVICE);
 		/* Refresh the desc even if buffer_addrs didn't change
@@ -1542,8 +1542,8 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 			skb_record_rx_queue(skb, rx_ring->queue_index);
 			/* we are reusing so sync this buffer for CPU use */
 			dma_sync_single_range_for_cpu(rx_ring->dev,
-						      rx_bi->dma,
-						      0,
+						      rx_ring->rx_bi[0].dma,
+						      i * rx_ring->rx_hdr_len,
 						      rx_ring->rx_hdr_len,
 						      DMA_FROM_DEVICE);
 		}
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 3e69235..69fb85f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -700,8 +700,8 @@ void i40evf_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
 		}
 
 		dma_sync_single_range_for_device(rx_ring->dev,
-						 bi->dma,
-						 0,
+						 rx_ring->rx_bi[0].dma,
+						 i * rx_ring->rx_hdr_len,
 						 rx_ring->rx_hdr_len,
 						 DMA_FROM_DEVICE);
 		/* Refresh the desc even if buffer_addrs didn't change
@@ -1007,8 +1007,8 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 			skb_record_rx_queue(skb, rx_ring->queue_index);
 			/* we are reusing so sync this buffer for CPU use */
 			dma_sync_single_range_for_cpu(rx_ring->dev,
-						      rx_bi->dma,
-						      0,
+						      rx_ring->rx_bi[0].dma,
+						      i * rx_ring->rx_hdr_len,
 						      rx_ring->rx_hdr_len,
 						      DMA_FROM_DEVICE);
 		}
-- 
2.5.0
