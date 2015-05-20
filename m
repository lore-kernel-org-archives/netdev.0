From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Optimize and cleanup setup memory window code
Date: Wed, 20 May 2015 17:53:45 +0530
Message-ID: <1432124626-22948-2-git-send-email-hariprasad@chelsio.com>
References: <1432124626-22948-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21110 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751004AbbETHKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 03:10:53 -0400
In-Reply-To: <1432124626-22948-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  4 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 79 +-------------------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 96 +++++++++++++++++++++++++
 3 files changed, 102 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 7988f5e..6e884d1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1157,6 +1157,10 @@ int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
 		  struct link_config *lc);
 int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port);
 
+u32 t4_read_pcie_cfg4(struct adapter *adap, int reg);
+u32 t4_get_util_window(struct adapter *adap);
+void t4_setup_memwin(struct adapter *adap, u32 memwin_base, u32 window);
+
 #define T4_MEMORY_WRITE	0
 #define T4_MEMORY_READ	1
 int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr, u32 len,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5aecf69..5b8f80fb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3057,86 +3057,11 @@ void t4_fatal_err(struct adapter *adap)
 	dev_alert(adap->pdev_dev, "encountered fatal error, adapter stopped\n");
 }
 
-/* Return the specified PCI-E Configuration Space register from our Physical
- * Function.  We try first via a Firmware LDST Command since we prefer to let
- * the firmware own all of these registers, but if that fails we go for it
- * directly ourselves.
- */
-static u32 t4_read_pcie_cfg4(struct adapter *adap, int reg)
-{
-	struct fw_ldst_cmd ldst_cmd;
-	u32 val;
-	int ret;
-
-	/* Construct and send the Firmware LDST Command to retrieve the
-	 * specified PCI-E Configuration Space register.
-	 */
-	memset(&ldst_cmd, 0, sizeof(ldst_cmd));
-	ldst_cmd.op_to_addrspace =
-		htonl(FW_CMD_OP_V(FW_LDST_CMD) |
-		      FW_CMD_REQUEST_F |
-		      FW_CMD_READ_F |
-		      FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_FUNC_PCIE));
-	ldst_cmd.cycles_to_len16 = htonl(FW_LEN16(ldst_cmd));
-	ldst_cmd.u.pcie.select_naccess = FW_LDST_CMD_NACCESS_V(1);
-	ldst_cmd.u.pcie.ctrl_to_fn =
-		(FW_LDST_CMD_LC_F | FW_LDST_CMD_FN_V(adap->fn));
-	ldst_cmd.u.pcie.r = reg;
-	ret = t4_wr_mbox(adap, adap->mbox, &ldst_cmd, sizeof(ldst_cmd),
-			 &ldst_cmd);
-
-	/* If the LDST Command suucceeded, exctract the returned register
-	 * value.  Otherwise read it directly ourself.
-	 */
-	if (ret == 0)
-		val = ntohl(ldst_cmd.u.pcie.data[0]);
-	else
-		t4_hw_pci_read_cfg4(adap, reg, &val);
-
-	return val;
-}
-
 static void setup_memwin(struct adapter *adap)
 {
-	u32 mem_win0_base, mem_win1_base, mem_win2_base, mem_win2_aperture;
+	u32 nic_win_base = t4_get_util_window(adap);
 
-	if (is_t4(adap->params.chip)) {
-		u32 bar0;
-
-		/* Truncation intentional: we only read the bottom 32-bits of
-		 * the 64-bit BAR0/BAR1 ...  We use the hardware backdoor
-		 * mechanism to read BAR0 instead of using
-		 * pci_resource_start() because we could be operating from
-		 * within a Virtual Machine which is trapping our accesses to
-		 * our Configuration Space and we need to set up the PCI-E
-		 * Memory Window decoders with the actual addresses which will
-		 * be coming across the PCI-E link.
-		 */
-		bar0 = t4_read_pcie_cfg4(adap, PCI_BASE_ADDRESS_0);
-		bar0 &= PCI_BASE_ADDRESS_MEM_MASK;
-		adap->t4_bar0 = bar0;
-
-		mem_win0_base = bar0 + MEMWIN0_BASE;
-		mem_win1_base = bar0 + MEMWIN1_BASE;
-		mem_win2_base = bar0 + MEMWIN2_BASE;
-		mem_win2_aperture = MEMWIN2_APERTURE;
-	} else {
-		/* For T5, only relative offset inside the PCIe BAR is passed */
-		mem_win0_base = MEMWIN0_BASE;
-		mem_win1_base = MEMWIN1_BASE;
-		mem_win2_base = MEMWIN2_BASE_T5;
-		mem_win2_aperture = MEMWIN2_APERTURE_T5;
-	}
-	t4_write_reg(adap, PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN_A, 0),
-		     mem_win0_base | BIR_V(0) |
-		     WINDOW_V(ilog2(MEMWIN0_APERTURE) - 10));
-	t4_write_reg(adap, PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN_A, 1),
-		     mem_win1_base | BIR_V(0) |
-		     WINDOW_V(ilog2(MEMWIN1_APERTURE) - 10));
-	t4_write_reg(adap, PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN_A, 2),
-		     mem_win2_base | BIR_V(0) |
-		     WINDOW_V(ilog2(mem_win2_aperture) - 10));
-	t4_read_reg(adap, PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN_A, 2));
+	t4_setup_memwin(adap, nic_win_base, MEMWIN_NIC);
 }
 
 static void setup_memwin_rdma(struct adapter *adap)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index cd23db5..c8e265c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -515,6 +515,102 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 	return 0;
 }
 
+/* Return the specified PCI-E Configuration Space register from our Physical
+ * Function.  We try first via a Firmware LDST Command since we prefer to let
+ * the firmware own all of these registers, but if that fails we go for it
+ * directly ourselves.
+ */
+u32 t4_read_pcie_cfg4(struct adapter *adap, int reg)
+{
+	u32 val, ldst_addrspace;
+
+	/* If fw_attach != 0, construct and send the Firmware LDST Command to
+	 * retrieve the specified PCI-E Configuration Space register.
+	 */
+	struct fw_ldst_cmd ldst_cmd;
+	int ret;
+
+	memset(&ldst_cmd, 0, sizeof(ldst_cmd));
+	ldst_addrspace = FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_FUNC_PCIE);
+	ldst_cmd.op_to_addrspace = cpu_to_be32(FW_CMD_OP_V(FW_LDST_CMD) |
+					       FW_CMD_REQUEST_F |
+					       FW_CMD_READ_F |
+					       ldst_addrspace);
+	ldst_cmd.cycles_to_len16 = cpu_to_be32(FW_LEN16(ldst_cmd));
+	ldst_cmd.u.pcie.select_naccess = FW_LDST_CMD_NACCESS_V(1);
+	ldst_cmd.u.pcie.ctrl_to_fn =
+		(FW_LDST_CMD_LC_F | FW_LDST_CMD_FN_V(adap->fn));
+	ldst_cmd.u.pcie.r = reg;
+
+	/* If the LDST Command succeeds, return the result, otherwise
+	 * fall through to reading it directly ourselves ...
+	 */
+	ret = t4_wr_mbox(adap, adap->mbox, &ldst_cmd, sizeof(ldst_cmd),
+			 &ldst_cmd);
+	if (ret == 0)
+		val = be32_to_cpu(ldst_cmd.u.pcie.data[0]);
+	else
+		/* Read the desired Configuration Space register via the PCI-E
+		 * Backdoor mechanism.
+		 */
+		t4_hw_pci_read_cfg4(adap, reg, &val);
+	return val;
+}
+
+/* Get the window based on base passed to it.
+ * Window aperture is currently unhandled, but there is no use case for it
+ * right now
+ */
+static u32 t4_get_window(struct adapter *adap, u32 pci_base, u64 pci_mask,
+			 u32 memwin_base)
+{
+	u32 ret;
+
+	if (is_t4(adap->params.chip)) {
+		u32 bar0;
+
+		/* Truncation intentional: we only read the bottom 32-bits of
+		 * the 64-bit BAR0/BAR1 ...  We use the hardware backdoor
+		 * mechanism to read BAR0 instead of using
+		 * pci_resource_start() because we could be operating from
+		 * within a Virtual Machine which is trapping our accesses to
+		 * our Configuration Space and we need to set up the PCI-E
+		 * Memory Window decoders with the actual addresses which will
+		 * be coming across the PCI-E link.
+		 */
+		bar0 = t4_read_pcie_cfg4(adap, pci_base);
+		bar0 &= pci_mask;
+		adap->t4_bar0 = bar0;
+
+		ret = bar0 + memwin_base;
+	} else {
+		/* For T5, only relative offset inside the PCIe BAR is passed */
+		ret = memwin_base;
+	}
+	return ret;
+}
+
+/* Get the default utility window (win0) used by everyone */
+u32 t4_get_util_window(struct adapter *adap)
+{
+	return t4_get_window(adap, PCI_BASE_ADDRESS_0,
+			     PCI_BASE_ADDRESS_MEM_MASK, MEMWIN0_BASE);
+}
+
+/* Set up memory window for accessing adapter memory ranges.  (Read
+ * back MA register to ensure that changes propagate before we attempt
+ * to use the new values.)
+ */
+void t4_setup_memwin(struct adapter *adap, u32 memwin_base, u32 window)
+{
+	t4_write_reg(adap,
+		     PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN_A, window),
+		     memwin_base | BIR_V(0) |
+		     WINDOW_V(ilog2(MEMWIN0_APERTURE) - WINDOW_SHIFT_X));
+	t4_read_reg(adap,
+		    PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN_A, window));
+}
+
 /**
  *	t4_get_regs_len - return the size of the chips register set
  *	@adapter: the adapter
-- 
2.3.4
