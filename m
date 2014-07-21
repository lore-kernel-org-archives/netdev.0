From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/5] cxgb4: Add the MC1 registers to read in the interrupt handler
Date: Mon, 21 Jul 2014 20:55:12 +0530
Message-ID: <1405956316-13591-2-git-send-email-hariprasad@chelsio.com>
References: <1405956316-13591-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405956316-13591-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c   |   16 +++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |    3 +++
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index eb5a278..e768852 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1719,16 +1719,24 @@ static void mps_intr_handler(struct adapter *adapter)
  */
 static void mem_intr_handler(struct adapter *adapter, int idx)
 {
-	static const char name[3][5] = { "EDC0", "EDC1", "MC" };
+	static const char name[4][7] = { "EDC0", "EDC1", "MC/MC0", "MC1" };
 
 	unsigned int addr, cnt_addr, v;
 
 	if (idx <= MEM_EDC1) {
 		addr = EDC_REG(EDC_INT_CAUSE, idx);
 		cnt_addr = EDC_REG(EDC_ECC_STATUS, idx);
+	} else if (idx == MEM_MC) {
+		if (is_t4(adapter->params.chip)) {
+			addr = MC_INT_CAUSE;
+			cnt_addr = MC_ECC_STATUS;
+		} else {
+			addr = MC_P_INT_CAUSE;
+			cnt_addr = MC_P_ECC_STATUS;
+		}
 	} else {
-		addr = MC_INT_CAUSE;
-		cnt_addr = MC_ECC_STATUS;
+		addr = MC_REG(MC_P_INT_CAUSE, 1);
+		cnt_addr = MC_REG(MC_P_ECC_STATUS, 1);
 	}
 
 	v = t4_read_reg(adapter, addr) & MEM_INT_MASK;
@@ -1892,6 +1900,8 @@ int t4_slow_intr_handler(struct adapter *adapter)
 		pcie_intr_handler(adapter);
 	if (cause & MC)
 		mem_intr_handler(adapter, MEM_MC);
+	if (!is_t4(adapter->params.chip) && (cause & MC1))
+		mem_intr_handler(adapter, MEM_MC1);
 	if (cause & EDC0)
 		mem_intr_handler(adapter, MEM_EDC0);
 	if (cause & EDC1)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 3b244ab..e3146e8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -448,11 +448,13 @@
 #define  TDUE 0x00010000U
 
 #define MC_INT_CAUSE 0x7518
+#define MC_P_INT_CAUSE 0x41318
 #define  ECC_UE_INT_CAUSE 0x00000004U
 #define  ECC_CE_INT_CAUSE 0x00000002U
 #define  PERR_INT_CAUSE   0x00000001U
 
 #define MC_ECC_STATUS 0x751c
+#define MC_P_ECC_STATUS 0x4131c
 #define  ECC_CECNT_MASK   0xffff0000U
 #define  ECC_CECNT_SHIFT  16
 #define  ECC_CECNT(x)     ((x) << ECC_CECNT_SHIFT)
@@ -1101,6 +1103,7 @@
 #define  I2CM       0x00000002U
 #define  CIM        0x00000001U
 
+#define MC1 0x31
 #define PL_INT_ENABLE 0x19410
 #define PL_INT_MAP0 0x19414
 #define PL_RST 0x19428
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
