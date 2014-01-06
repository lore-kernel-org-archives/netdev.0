From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Record dma buffer info for dummy packets
Date: Mon,  6 Jan 2014 04:30:22 -0800
Message-ID: <1389011436-18424-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44283 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbaAFMaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:39 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Save information that we can use while cleaning the tx ring. Also record
the time_stamp since we will need it to check tx hangs.

Change-Id: Ia3f1c17f6fec9bcb7fef2542d77eac7f6c4f115c
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 2584d6b..fac4fb3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -77,7 +77,6 @@ int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 	/* grab the next descriptor */
 	i = tx_ring->next_to_use;
 	fdir_desc = I40E_TX_FDIRDESC(tx_ring, i);
-	tx_buf = &tx_ring->tx_bi[i];
 
 	tx_ring->next_to_use = (i + 1 < tx_ring->count) ? i + 1 : 0;
 
@@ -129,15 +128,23 @@ int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 	/* Now program a dummy descriptor */
 	i = tx_ring->next_to_use;
 	tx_desc = I40E_TX_DESC(tx_ring, i);
+	tx_buf = &tx_ring->tx_bi[i];
 
 	tx_ring->next_to_use = (i + 1 < tx_ring->count) ? i + 1 : 0;
 
+	/* record length, and DMA address */
+	dma_unmap_len_set(tx_buf, len, I40E_FDIR_MAX_RAW_PACKET_LOOKUP);
+	dma_unmap_addr_set(tx_buf, dma, dma);
+
 	tx_desc->buffer_addr = cpu_to_le64(dma);
 	td_cmd = I40E_TXD_CMD | I40E_TX_DESC_CMD_DUMMY;
 
 	tx_desc->cmd_type_offset_bsz =
 		build_ctob(td_cmd, 0, I40E_FDIR_MAX_RAW_PACKET_LOOKUP, 0);
 
+	/* set the timestamp */
+	tx_buf->time_stamp = jiffies;
+
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
-- 
1.8.3.1
