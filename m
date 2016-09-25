From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Split Flow Director descriptor config into separate function
Date: Sat, 24 Sep 2016 23:42:46 -0700
Message-ID: <1474785769-54665-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:18328 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965704AbcIYGmz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:55 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In an effort to improve code readability I am splitting the Flow Director
filter configuration out into a separate function like we have done for the
standard xmit path.  The general idea is to provide a single block of code
that translates the flow specification into a proper Flow Director
descriptor.

Change-ID: Id355ad8030c4e6c72c57504fa09de60c976a8ffe
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 115 ++++++++++++++++------------
 1 file changed, 64 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 6e0a7ac..ef9b8d7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -40,6 +40,69 @@ static inline __le64 build_ctob(u32 td_cmd, u32 td_offset, unsigned int size,
 }
 
 #define I40E_TXD_CMD (I40E_TX_DESC_CMD_EOP | I40E_TX_DESC_CMD_RS)
+/**
+ * i40e_fdir - Generate a Flow Director descriptor based on fdata
+ * @tx_ring: Tx ring to send buffer on
+ * @fdata: Flow director filter data
+ * @add: Indicate if we are adding a rule or deleting one
+ *
+ **/
+static void i40e_fdir(struct i40e_ring *tx_ring,
+		      struct i40e_fdir_filter *fdata, bool add)
+{
+	struct i40e_filter_program_desc *fdir_desc;
+	struct i40e_pf *pf = tx_ring->vsi->back;
+	u32 flex_ptype, dtype_cmd;
+	u16 i;
+
+	/* grab the next descriptor */
+	i = tx_ring->next_to_use;
+	fdir_desc = I40E_TX_FDIRDESC(tx_ring, i);
+
+	i++;
+	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;
+
+	flex_ptype = I40E_TXD_FLTR_QW0_QINDEX_MASK &
+		     (fdata->q_index << I40E_TXD_FLTR_QW0_QINDEX_SHIFT);
+
+	flex_ptype |= I40E_TXD_FLTR_QW0_FLEXOFF_MASK &
+		      (fdata->flex_off << I40E_TXD_FLTR_QW0_FLEXOFF_SHIFT);
+
+	flex_ptype |= I40E_TXD_FLTR_QW0_PCTYPE_MASK &
+		      (fdata->pctype << I40E_TXD_FLTR_QW0_PCTYPE_SHIFT);
+
+	/* Use LAN VSI Id if not programmed by user */
+	flex_ptype |= I40E_TXD_FLTR_QW0_DEST_VSI_MASK &
+		      ((u32)(fdata->dest_vsi ? : pf->vsi[pf->lan_vsi]->id) <<
+		       I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT);
+
+	dtype_cmd = I40E_TX_DESC_DTYPE_FILTER_PROG;
+
+	dtype_cmd |= add ?
+		     I40E_FILTER_PROGRAM_DESC_PCMD_ADD_UPDATE <<
+		     I40E_TXD_FLTR_QW1_PCMD_SHIFT :
+		     I40E_FILTER_PROGRAM_DESC_PCMD_REMOVE <<
+		     I40E_TXD_FLTR_QW1_PCMD_SHIFT;
+
+	dtype_cmd |= I40E_TXD_FLTR_QW1_DEST_MASK &
+		     (fdata->dest_ctl << I40E_TXD_FLTR_QW1_DEST_SHIFT);
+
+	dtype_cmd |= I40E_TXD_FLTR_QW1_FD_STATUS_MASK &
+		     (fdata->fd_status << I40E_TXD_FLTR_QW1_FD_STATUS_SHIFT);
+
+	if (fdata->cnt_index) {
+		dtype_cmd |= I40E_TXD_FLTR_QW1_CNT_ENA_MASK;
+		dtype_cmd |= I40E_TXD_FLTR_QW1_CNTINDEX_MASK &
+			     ((u32)fdata->cnt_index <<
+			      I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT);
+	}
+
+	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(flex_ptype);
+	fdir_desc->rsvd = cpu_to_le32(0);
+	fdir_desc->dtype_cmd_cntindex = cpu_to_le32(dtype_cmd);
+	fdir_desc->fd_id = cpu_to_le32(fdata->fd_id);
+}
+
 #define I40E_FD_CLEAN_DELAY 10
 /**
  * i40e_program_fdir_filter - Program a Flow Director filter
@@ -51,11 +114,9 @@ static inline __le64 build_ctob(u32 td_cmd, u32 td_offset, unsigned int size,
 int i40e_program_fdir_filter(struct i40e_fdir_filter *fdir_data, u8 *raw_packet,
 			     struct i40e_pf *pf, bool add)
 {
-	struct i40e_filter_program_desc *fdir_desc;
 	struct i40e_tx_buffer *tx_buf, *first;
 	struct i40e_tx_desc *tx_desc;
 	struct i40e_ring *tx_ring;
-	unsigned int fpt, dcc;
 	struct i40e_vsi *vsi;
 	struct device *dev;
 	dma_addr_t dma;
@@ -92,56 +153,8 @@ int i40e_program_fdir_filter(struct i40e_fdir_filter *fdir_data, u8 *raw_packet,
 
 	/* grab the next descriptor */
 	i = tx_ring->next_to_use;
-	fdir_desc = I40E_TX_FDIRDESC(tx_ring, i);
 	first = &tx_ring->tx_bi[i];
-	memset(first, 0, sizeof(struct i40e_tx_buffer));
-
-	tx_ring->next_to_use = ((i + 1) < tx_ring->count) ? i + 1 : 0;
-
-	fpt = (fdir_data->q_index << I40E_TXD_FLTR_QW0_QINDEX_SHIFT) &
-	      I40E_TXD_FLTR_QW0_QINDEX_MASK;
-
-	fpt |= (fdir_data->flex_off << I40E_TXD_FLTR_QW0_FLEXOFF_SHIFT) &
-	       I40E_TXD_FLTR_QW0_FLEXOFF_MASK;
-
-	fpt |= (fdir_data->pctype << I40E_TXD_FLTR_QW0_PCTYPE_SHIFT) &
-	       I40E_TXD_FLTR_QW0_PCTYPE_MASK;
-
-	/* Use LAN VSI Id if not programmed by user */
-	if (fdir_data->dest_vsi == 0)
-		fpt |= (pf->vsi[pf->lan_vsi]->id) <<
-		       I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT;
-	else
-		fpt |= ((u32)fdir_data->dest_vsi <<
-			I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT) &
-		       I40E_TXD_FLTR_QW0_DEST_VSI_MASK;
-
-	dcc = I40E_TX_DESC_DTYPE_FILTER_PROG;
-
-	if (add)
-		dcc |= I40E_FILTER_PROGRAM_DESC_PCMD_ADD_UPDATE <<
-		       I40E_TXD_FLTR_QW1_PCMD_SHIFT;
-	else
-		dcc |= I40E_FILTER_PROGRAM_DESC_PCMD_REMOVE <<
-		       I40E_TXD_FLTR_QW1_PCMD_SHIFT;
-
-	dcc |= (fdir_data->dest_ctl << I40E_TXD_FLTR_QW1_DEST_SHIFT) &
-	       I40E_TXD_FLTR_QW1_DEST_MASK;
-
-	dcc |= (fdir_data->fd_status << I40E_TXD_FLTR_QW1_FD_STATUS_SHIFT) &
-	       I40E_TXD_FLTR_QW1_FD_STATUS_MASK;
-
-	if (fdir_data->cnt_index != 0) {
-		dcc |= I40E_TXD_FLTR_QW1_CNT_ENA_MASK;
-		dcc |= ((u32)fdir_data->cnt_index <<
-			I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
-			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
-	}
-
-	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(fpt);
-	fdir_desc->rsvd = cpu_to_le32(0);
-	fdir_desc->dtype_cmd_cntindex = cpu_to_le32(dcc);
-	fdir_desc->fd_id = cpu_to_le32(fdir_data->fd_id);
+	i40e_fdir(tx_ring, fdir_data, add);
 
 	/* Now program a dummy descriptor */
 	i = tx_ring->next_to_use;
-- 
2.7.4
