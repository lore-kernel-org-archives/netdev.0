From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/6] cxgb4: Fix T5 adapter accessing T4 adapter registers
Date: Tue, 12 Aug 2014 11:09:10 +0530
Message-ID: <1407821953-8711-4-git-send-email-hariprasad@chelsio.com>
References: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43197
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751978AbaHLFdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 01:33:38 -0400
In-Reply-To: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    4 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   29 +++++++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    2 +
 3 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 1a162d2..f1ff11b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1253,7 +1253,9 @@ freeout:	t4_free_sge_resources(adap);
 			goto freeout;
 	}
 
-	t4_write_reg(adap, MPS_TRC_RSS_CONTROL,
+	t4_write_reg(adap, is_t4(adap->params.chip) ?
+				MPS_TRC_RSS_CONTROL :
+				MPS_T5_TRC_RSS_CONTROL,
 		     RSSCONTROL(netdev2pinfo(adap->port[0])->tx_chan) |
 		     QUEUENUMBER(s->ethrxq[0].rspq.abs_id));
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index adf16a5..0250a9d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1403,15 +1403,18 @@ static void pcie_intr_handler(struct adapter *adapter)
 
 	int fat;
 
-	fat = t4_handle_intr_status(adapter,
-				    PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS,
-				    sysbus_intr_info) +
-	      t4_handle_intr_status(adapter,
-				    PCIE_CORE_UTL_PCI_EXPRESS_PORT_STATUS,
-				    pcie_port_intr_info) +
-	      t4_handle_intr_status(adapter, PCIE_INT_CAUSE,
-				    is_t4(adapter->params.chip) ?
-				    pcie_intr_info : t5_pcie_intr_info);
+	if (is_t4(adapter->params.chip))
+		fat = t4_handle_intr_status(adapter,
+					    PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS,
+					    sysbus_intr_info) +
+			t4_handle_intr_status(adapter,
+					      PCIE_CORE_UTL_PCI_EXPRESS_PORT_STATUS,
+					      pcie_port_intr_info) +
+			t4_handle_intr_status(adapter, PCIE_INT_CAUSE,
+					      pcie_intr_info);
+	else
+		fat = t4_handle_intr_status(adapter, PCIE_INT_CAUSE,
+					    t5_pcie_intr_info);
 
 	if (fat)
 		t4_fatal_err(adapter);
@@ -1777,10 +1780,16 @@ static void ma_intr_handler(struct adapter *adap)
 {
 	u32 v, status = t4_read_reg(adap, MA_INT_CAUSE);
 
-	if (status & MEM_PERR_INT_CAUSE)
+	if (status & MEM_PERR_INT_CAUSE) {
 		dev_alert(adap->pdev_dev,
 			  "MA parity error, parity status %#x\n",
 			  t4_read_reg(adap, MA_PARITY_ERROR_STATUS));
+		if (is_t5(adap->params.chip))
+			dev_alert(adap->pdev_dev,
+				  "MA parity error, parity status %#x\n",
+				  t4_read_reg(adap,
+					      MA_PARITY_ERROR_STATUS2));
+	}
 	if (status & MEM_WRAP_INT_CAUSE) {
 		v = t4_read_reg(adap, MA_INT_WRAP_STATUS);
 		dev_alert(adap->pdev_dev, "MA address wrap-around error by "
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index e3146e8..39fb325 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -511,6 +511,7 @@
 #define  MEM_WRAP_CLIENT_NUM_GET(x) (((x) & MEM_WRAP_CLIENT_NUM_MASK) >> MEM_WRAP_CLIENT_NUM_SHIFT)
 #define MA_PCIE_FW 0x30b8
 #define MA_PARITY_ERROR_STATUS 0x77f4
+#define MA_PARITY_ERROR_STATUS2 0x7804
 
 #define MA_EXT_MEMORY1_BAR 0x7808
 #define EDC_0_BASE_ADDR 0x7900
@@ -959,6 +960,7 @@
 #define  TRCMULTIFILTER     0x00000001U
 
 #define MPS_TRC_RSS_CONTROL 0x9808
+#define MPS_T5_TRC_RSS_CONTROL 0xa00c
 #define  RSSCONTROL_MASK    0x00ff0000U
 #define  RSSCONTROL_SHIFT   16
 #define  RSSCONTROL(x)      ((x) << RSSCONTROL_SHIFT)
-- 
1.7.1
