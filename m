From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] fm10k: don't clear the RXQCTL register when enabling or disabling queues
Date: Mon, 29 Aug 2016 02:13:45 -0700
Message-ID: <1472462026-42133-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56356 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932429AbcH2JNw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:52 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Ensure that other bits in the RXQCTL register do not get cleared. This
ensures that bits related to queue ownership are maintained.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index d7f1eca..b1a2f84 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -734,15 +734,15 @@ static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
 	u64 rdba = ring->dma;
 	struct fm10k_hw *hw = &interface->hw;
 	u32 size = ring->count * sizeof(union fm10k_rx_desc);
-	u32 rxqctl = FM10K_RXQCTL_ENABLE | FM10K_RXQCTL_PF;
-	u32 rxdctl = FM10K_RXDCTL_WRITE_BACK_MIN_DELAY;
+	u32 rxqctl, rxdctl = FM10K_RXDCTL_WRITE_BACK_MIN_DELAY;
 	u32 srrctl = FM10K_SRRCTL_BUFFER_CHAINING_EN;
 	u32 rxint = FM10K_INT_MAP_DISABLE;
 	u8 rx_pause = interface->rx_pause;
 	u8 reg_idx = ring->reg_idx;
 
 	/* disable queue to avoid issues while updating state */
-	fm10k_write_reg(hw, FM10K_RXQCTL(reg_idx), 0);
+	rxqctl = fm10k_read_reg(hw, FM10K_RXQCTL(reg_idx));
+	rxqctl &= ~FM10K_RXQCTL_ENABLE;
 	fm10k_write_flush(hw);
 
 	/* possible poll here to verify ring resources have been cleaned */
@@ -797,6 +797,8 @@ static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
 	fm10k_write_reg(hw, FM10K_RXINT(reg_idx), rxint);
 
 	/* enable queue */
+	rxqctl = fm10k_read_reg(hw, FM10K_RXQCTL(reg_idx));
+	rxqctl |= FM10K_RXQCTL_ENABLE;
 	fm10k_write_reg(hw, FM10K_RXQCTL(reg_idx), rxqctl);
 
 	/* place buffers on ring for receive data */
-- 
2.7.4
