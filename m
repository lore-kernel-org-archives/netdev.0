From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/3] i40e: check desc pointer before printing
Date: Wed, 15 Jan 2014 15:18:23 -0800
Message-ID: <1389827904-14713-3-git-send-email-aaron.f.brown@intel.com>
References: <1389827904-14713-1-git-send-email-aaron.f.brown@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49479 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751AbaAOXSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 18:18:32 -0500
In-Reply-To: <1389827904-14713-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Check that the descriptors were allocated before trying to dump
them to the logfile.  While we're there, de-trick-ify the code
so as to be easier to read and not abusing the types and unions.

Change-ID: I22898f4b22cecda3582d4d9e4018da9cd540f177
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 67 +++++++++++++++-----------
 1 file changed, 39 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 36a5cc8..913ba9e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -752,7 +752,8 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 			       struct i40e_pf *pf, bool is_rx_ring)
 {
-	union i40e_rx_desc *ds;
+	struct i40e_tx_desc *txd;
+	union i40e_rx_desc *rxd;
 	struct i40e_ring ring;
 	struct i40e_vsi *vsi;
 	int i;
@@ -766,7 +767,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 		dev_info(&pf->pdev->dev, "ring %d not found\n", ring_id);
 		return;
 	}
-	if (!vsi->tx_rings) {
+	if (!vsi->tx_rings || !vsi->tx_rings[0]->desc) {
 		dev_info(&pf->pdev->dev,
 			 "descriptor rings have not been allocated for vsi %d\n",
 			 vsi_seid);
@@ -780,22 +781,27 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 		dev_info(&pf->pdev->dev, "vsi = %02i %s ring = %02i\n",
 			 vsi_seid, is_rx_ring ? "rx" : "tx", ring_id);
 		for (i = 0; i < ring.count; i++) {
-			if (is_rx_ring)
-				ds = I40E_RX_DESC(&ring, i);
-			else
-				ds = (union i40e_rx_desc *)
-					I40E_TX_DESC(&ring, i);
-			if ((sizeof(union i40e_rx_desc) ==
-			    sizeof(union i40e_16byte_rx_desc)) || (!is_rx_ring))
+			if (!is_rx_ring) {
+				txd = I40E_TX_DESC(&ring, i);
 				dev_info(&pf->pdev->dev,
-					 "   d[%03i] = 0x%016llx 0x%016llx\n", i,
-					 ds->read.pkt_addr, ds->read.hdr_addr);
-			else
+					 "   d[%03i] = 0x%016llx 0x%016llx\n",
+					 i, txd->buffer_addr,
+					 txd->cmd_type_offset_bsz);
+			} else if (sizeof(union i40e_rx_desc) ==
+				   sizeof(union i40e_16byte_rx_desc)) {
+				rxd = I40E_RX_DESC(&ring, i);
+				dev_info(&pf->pdev->dev,
+					 "   d[%03i] = 0x%016llx 0x%016llx\n",
+					 i, rxd->read.pkt_addr,
+					 rxd->read.hdr_addr);
+			} else {
+				rxd = I40E_RX_DESC(&ring, i);
 				dev_info(&pf->pdev->dev,
 					 "   d[%03i] = 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
-					 i, ds->read.pkt_addr,
-					 ds->read.hdr_addr,
-					 ds->read.rsvd1, ds->read.rsvd2);
+					 i, rxd->read.pkt_addr,
+					 rxd->read.hdr_addr,
+					 rxd->read.rsvd1, rxd->read.rsvd2);
+			}
 		}
 	} else if (cnt == 3) {
 		if (desc_n >= ring.count || desc_n < 0) {
@@ -803,22 +809,27 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 				 "descriptor %d not found\n", desc_n);
 			return;
 		}
-		if (is_rx_ring)
-			ds = I40E_RX_DESC(&ring, desc_n);
-		else
-			ds = (union i40e_rx_desc *)I40E_TX_DESC(&ring, desc_n);
-		if ((sizeof(union i40e_rx_desc) ==
-		    sizeof(union i40e_16byte_rx_desc)) || (!is_rx_ring))
+		if (!is_rx_ring) {
+			txd = I40E_TX_DESC(&ring, desc_n);
 			dev_info(&pf->pdev->dev,
-				 "vsi = %02i %s ring = %02i d[%03i] = 0x%016llx 0x%016llx\n",
-				 vsi_seid, is_rx_ring ? "rx" : "tx", ring_id,
-				 desc_n, ds->read.pkt_addr, ds->read.hdr_addr);
-		else
+				 "vsi = %02i tx ring = %02i d[%03i] = 0x%016llx 0x%016llx\n",
+				 vsi_seid, ring_id, desc_n,
+				 txd->buffer_addr, txd->cmd_type_offset_bsz);
+		} else if (sizeof(union i40e_rx_desc) ==
+			   sizeof(union i40e_16byte_rx_desc)) {
+			rxd = I40E_RX_DESC(&ring, desc_n);
+			dev_info(&pf->pdev->dev,
+				 "vsi = %02i rx ring = %02i d[%03i] = 0x%016llx 0x%016llx\n",
+				 vsi_seid, ring_id, desc_n,
+				 rxd->read.pkt_addr, rxd->read.hdr_addr);
+		} else {
+			rxd = I40E_RX_DESC(&ring, desc_n);
 			dev_info(&pf->pdev->dev,
 				 "vsi = %02i rx ring = %02i d[%03i] = 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
-				 vsi_seid, ring_id,
-				 desc_n, ds->read.pkt_addr, ds->read.hdr_addr,
-				 ds->read.rsvd1, ds->read.rsvd2);
+				 vsi_seid, ring_id, desc_n,
+				 rxd->read.pkt_addr, rxd->read.hdr_addr,
+				 rxd->read.rsvd1, rxd->read.rsvd2);
+		}
 	} else {
 		dev_info(&pf->pdev->dev, "dump desc rx/tx <vsi_seid> <ring_id> [<desc_n>]\n");
 	}
-- 
1.8.5.GIT
