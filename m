From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/18] fm10k: Only trigger data path reset if fabric is up
Date: Tue, 15 Sep 2015 17:36:42 -0700
Message-ID: <1442363803-47237-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58335 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644AbbIPAgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:51 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@redhat.com>

This change makes it so that we only trigger the data path reset if the
fabric is ready to handle traffic.  The general idea is to avoid
triggering the reset unless the switch API is ready for us.  Otherwise
we can just postpone the reset until we receive a switch ready
notification.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 241b969..d806d87 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -59,6 +59,11 @@ static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
 	if (reg & (FM10K_DMA_CTRL_TX_ACTIVE | FM10K_DMA_CTRL_RX_ACTIVE))
 		return FM10K_ERR_DMA_PENDING;
 
+	/* verify the switch is ready for reset */
+	reg = fm10k_read_reg(hw, FM10K_DMA_CTRL2);
+	if (!(reg & FM10K_DMA_CTRL2_SWITCH_READY))
+		goto out;
+
 	/* Inititate data path reset */
 	reg |= FM10K_DMA_CTRL_DATAPATH_RESET;
 	fm10k_write_reg(hw, FM10K_DMA_CTRL, reg);
@@ -72,6 +77,7 @@ static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
 	if (!(reg & FM10K_IP_NOTINRESET))
 		err = FM10K_ERR_RESET_FAILED;
 
+out:
 	return err;
 }
 
-- 
2.4.3
