From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 1/3] igb, ixgbe(vf), i40e(vf),
 fm10k: Use dev_kfree_skb in Tx cleanup path
Date: Thu, 30 Apr 2015 13:58:18 -0700
Message-ID: <20150430205818.1512.11765.stgit@ahduyck-vm-fedora22>
References: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, Dept-HSGLinuxNICDev@qlogic.com,
	sony.chacko@qlogic.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbbD3U62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 16:58:28 -0400
In-Reply-To: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the use of either dev_kfree_skb_any or
dev_consume_skb_any in the Tx cleanup paths of these drivers with
dev_kfree_skb.  There isn't any need for the "_any" version of these
functions since the NAPI cleanup context is not a hard irq context.

This change allows us to drop one function call from the clean-up path
since dev_kfree_skb_any was just calling into dev_kfree_skb in these paths
anyway.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 4eafdad318b4..1e3fe455cdea 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1227,7 +1227,7 @@ static bool fm10k_clean_tx_irq(struct fm10k_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_consume_skb_any(tx_buffer->skb);
+		dev_kfree_skb(tx_buffer->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 4bd3a80aba82..52a6e2a609a7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -726,7 +726,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 		total_packets += tx_buf->gso_segs;
 
 		/* free the skb */
-		dev_consume_skb_any(tx_buf->skb);
+		dev_kfree_skb(tx_buf->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index b077e02a0cc7..976b93ca996a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -245,7 +245,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 		total_packets += tx_buf->gso_segs;
 
 		/* free the skb */
-		dev_kfree_skb_any(tx_buf->skb);
+		dev_kfree_skb(tx_buf->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index cab50593c315..699902618a6f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6425,7 +6425,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_consume_skb_any(tx_buffer->skb);
+		dev_kfree_skb(tx_buffer->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d3f4b0ceb3f7..e7586663a2cf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1114,7 +1114,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_consume_skb_any(tx_buffer->skb);
+		dev_kfree_skb(tx_buffer->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index cca8936f2fc3..0d5b94be1f0d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -326,7 +326,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_kfree_skb_any(tx_buffer->skb);
+		dev_kfree_skb(tx_buffer->skb);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
