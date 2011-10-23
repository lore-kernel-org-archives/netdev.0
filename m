From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH V3 02/10] cxgb4: Common platform specific changes for DB Drop Recovery
Date: Sun, 23 Oct 2011 12:09:46 +0530
Message-ID: <1319351986-2823-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

    - Add platform-specific callback functions for interrupts.  This is
    needed to do a single read-clear of the CAUSE register and then call
    out to platform specific functions for DB threshold interrupts and DB
    drop interrupts.

    - Add t4_mem_win_read_len() - mem-window reads for arbitrary lengths.
    This is used to read the CIDX/PIDX values from EC contexts during DB
    drop recovery.

    - Add t4_fwaddrspace_write() - sends addrspace write cmds to the fw.
    Needed to flush the sge eq context cache.

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
V2: Corrected the subject for patch.
V3: Moved function declarations from t4fw_api.h to cxgb4.h

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |    3 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |   69 +++++++++++++++++++++++----
 2 files changed, 61 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index e18b5ad..d5f9bd7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -723,4 +723,7 @@ int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl);
 void t4_db_full(struct adapter *adapter);
 void t4_db_dropped(struct adapter *adapter);
+int t4_mem_win_read_len(struct adapter *adap, u32 addr, __be32 *data, int len);
+int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
+			 u32 addr, u32 val);
 #endif /* __CXGB4_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 13609bf..32e1dd5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -868,11 +868,14 @@ int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port)
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
+typedef void (*int_handler_t)(struct adapter *adap);
+
 struct intr_info {
 	unsigned int mask;       /* bits to check in interrupt status */
 	const char *msg;         /* message to print or NULL */
 	short stat_idx;          /* stat counter to increment or -1 */
 	unsigned short fatal;    /* whether the condition reported is fatal */
+	int_handler_t int_handler; /* platform-specific int handler */
 };
 
 /**
@@ -905,6 +908,8 @@ static int t4_handle_intr_status(struct adapter *adapter, unsigned int reg,
 		} else if (acts->msg && printk_ratelimit())
 			dev_warn(adapter->pdev_dev, "%s (0x%x)\n", acts->msg,
 				 status & acts->mask);
+		if (acts->int_handler)
+			acts->int_handler(adapter);
 		mask |= acts->mask;
 	}
 	status &= mask;
@@ -1013,9 +1018,9 @@ static void sge_intr_handler(struct adapter *adapter)
 		{ ERR_INVALID_CIDX_INC,
 		  "SGE GTS CIDX increment too large", -1, 0 },
 		{ ERR_CPL_OPCODE_0, "SGE received 0-length CPL", -1, 0 },
-		{ F_DBFIFO_LP_INT, NULL, -1, 0 },
-		{ F_DBFIFO_HP_INT, NULL, -1, 0 },
-		{ ERR_DROPPED_DB, "SGE doorbell dropped", -1, 0 },
+		{ F_DBFIFO_LP_INT, NULL, -1, 0, t4_db_full },
+		{ F_DBFIFO_HP_INT, NULL, -1, 0, t4_db_full },
+		{ F_ERR_DROPPED_DB, NULL, -1, 0, t4_db_dropped },
 		{ ERR_DATA_CPL_ON_HIGH_QID1 | ERR_DATA_CPL_ON_HIGH_QID0,
 		  "SGE IQID > 1023 received CPL for FL", -1, 0 },
 		{ ERR_BAD_DB_PIDX3, "SGE DBP 3 pidx increment too large", -1,
@@ -1036,20 +1041,14 @@ static void sge_intr_handler(struct adapter *adapter)
 	};
 
 	v = (u64)t4_read_reg(adapter, SGE_INT_CAUSE1) |
-	    ((u64)t4_read_reg(adapter, SGE_INT_CAUSE2) << 32);
+		((u64)t4_read_reg(adapter, SGE_INT_CAUSE2) << 32);
 	if (v) {
 		dev_alert(adapter->pdev_dev, "SGE parity error (%#llx)\n",
-			 (unsigned long long)v);
+				(unsigned long long)v);
 		t4_write_reg(adapter, SGE_INT_CAUSE1, v);
 		t4_write_reg(adapter, SGE_INT_CAUSE2, v >> 32);
 	}
 
-	err = t4_read_reg(adapter, A_SGE_INT_CAUSE3);
-	if (err & (F_DBFIFO_HP_INT|F_DBFIFO_LP_INT))
-		t4_db_full(adapter);
-	if (err & F_ERR_DROPPED_DB)
-		t4_db_dropped(adapter);
-
 	if (t4_handle_intr_status(adapter, SGE_INT_CAUSE3, sge_intr_info) ||
 	    v != 0)
 		t4_fatal_err(adapter);
@@ -1995,6 +1994,54 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 	(var).retval_len16 = htonl(FW_LEN16(var)); \
 } while (0)
 
+int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
+			  u32 addr, u32 val)
+{
+	struct fw_ldst_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_addrspace = htonl(V_FW_CMD_OP(FW_LDST_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_WRITE |
+			    V_FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_FIRMWARE));
+	c.cycles_to_len16 = htonl(FW_LEN16(c));
+	c.u.addrval.addr = htonl(addr);
+	c.u.addrval.val = htonl(val);
+
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/*
+ *     t4_mem_win_read_len - read memory through PCIE memory window
+ *     @adap: the adapter
+ *     @addr: address of first byte requested aligned on 32b.
+ *     @data: len bytes to hold the data read
+ *     @len: amount of data to read from window.  Must be <=
+ *            MEMWIN0_APERATURE after adjusting for 16B alignment
+ *            requirements of the the memory window.
+ *
+ *     Read len bytes of data from MC starting at @addr.
+ */
+int t4_mem_win_read_len(struct adapter *adap, u32 addr, __be32 *data, int len)
+{
+	int i;
+	int off;
+
+	/*
+	 * Align on a 16B boundary.
+	 */
+	off = addr & 15;
+	if ((addr & 3) || (len + off) > MEMWIN0_APERTURE)
+		return -EINVAL;
+
+	t4_write_reg(adap, A_PCIE_MEM_ACCESS_OFFSET, addr & ~15);
+	t4_read_reg(adap, A_PCIE_MEM_ACCESS_OFFSET);
+
+	for (i = 0; i < len; i += 4)
+		*data++ = t4_read_reg(adap, (MEMWIN0_BASE + off + i));
+
+	return 0;
+}
+
 /**
  *	t4_mdio_rd - read a PHY register through MDIO
  *	@adap: the adapter
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
