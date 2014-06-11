From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e/i40evf: set headwb Tx context flags and use them
Date: Wed, 11 Jun 2014 09:33:12 -0700
Message-ID: <1402504404-8954-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ashish Shah <ashish.n.shah@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55591 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932468AbaFKQd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:29 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashish Shah <ashish.n.shah@intel.com>

Set appropriate fields in Tx queue configuration virtchnl message
to pf to enable headwb and setup headwb addr.
Then use that info from the VF to set headwb and headwb_addr instead of
always enabling them.

Change-ID: I7d393d1b2b07f0f3355b3a4f7c2d3c6ee3b0d622
Signed-off-by: Ashish Shah <ashish.n.shah@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c  | 5 ++---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 3 +++
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 385a46f..d9d0456 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -248,9 +248,8 @@ static int i40e_config_vsi_tx_queue(struct i40e_vf *vf, u16 vsi_idx,
 	tx_ctx.qlen = info->ring_len;
 	tx_ctx.rdylist = le16_to_cpu(pf->vsi[vsi_idx]->info.qs_handle[0]);
 	tx_ctx.rdylist_act = 0;
-	tx_ctx.head_wb_ena = 1;
-	tx_ctx.head_wb_addr = info->dma_ring_addr +
-			      (info->ring_len * sizeof(struct i40e_tx_desc));
+	tx_ctx.head_wb_ena = info->headwb_enabled;
+	tx_ctx.head_wb_addr = info->dma_headwb_addr;
 
 	/* clear the context in the HMC */
 	ret = i40e_clear_lan_tx_queue_context(hw, pf_queue_id);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index cd414da..6d76f29 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -233,6 +233,9 @@ void i40evf_configure_queues(struct i40evf_adapter *adapter)
 		vqpi->txq.queue_id = i;
 		vqpi->txq.ring_len = adapter->tx_rings[i]->count;
 		vqpi->txq.dma_ring_addr = adapter->tx_rings[i]->dma;
+		vqpi->txq.headwb_enabled = 1;
+		vqpi->txq.dma_headwb_addr = vqpi->txq.dma_ring_addr +
+		    (vqpi->txq.ring_len * sizeof(struct i40e_tx_desc));
 
 		vqpi->rxq.vsi_id = vqci->vsi_id;
 		vqpi->rxq.queue_id = i;
-- 
1.9.3
