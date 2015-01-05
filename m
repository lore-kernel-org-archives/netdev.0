From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 4/5] cxgb4/csiostor: Cleanup TP, MPS and TCAM related register defines
Date: Mon,  5 Jan 2015 16:30:46 +0530
Message-ID: <1420455647-23094-5-git-send-email-hariprasad@chelsio.com>
References: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, praveenm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420455647-23094-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch cleanups all TP, MPS and TCAM related macros/register defines
that are defined in t4_regs.h and the affected files

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   70 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  154 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  607 ++++++++++++++---------
 drivers/scsi/csiostor/csio_hw.c                 |  113 +++--
 drivers/scsi/csiostor/csio_wr.c                 |    4 +-
 5 files changed, 536 insertions(+), 412 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 16c633f..53ad8d3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -359,8 +359,8 @@ MODULE_PARM_DESC(select_queue,
  */
 enum {
 	TP_VLAN_PRI_MAP_DEFAULT = HW_TPL_FR_MT_PR_IV_P_FC,
-	TP_VLAN_PRI_MAP_FIRST = FCOE_SHIFT,
-	TP_VLAN_PRI_MAP_LAST = FRAGMENTATION_SHIFT,
+	TP_VLAN_PRI_MAP_FIRST = FCOE_S,
+	TP_VLAN_PRI_MAP_LAST = FRAGMENTATION_S,
 };
 
 static unsigned int tp_vlan_pri_map = TP_VLAN_PRI_MAP_DEFAULT;
@@ -1177,10 +1177,10 @@ freeout:	t4_free_sge_resources(adap);
 	}
 
 	t4_write_reg(adap, is_t4(adap->params.chip) ?
-				MPS_TRC_RSS_CONTROL :
-				MPS_T5_TRC_RSS_CONTROL,
-		     RSSCONTROL(netdev2pinfo(adap->port[0])->tx_chan) |
-		     QUEUENUMBER(s->ethrxq[0].rspq.abs_id));
+				MPS_TRC_RSS_CONTROL_A :
+				MPS_T5_TRC_RSS_CONTROL_A,
+		     RSSCONTROL_V(netdev2pinfo(adap->port[0])->tx_chan) |
+		     QUEUENUMBER_V(s->ethrxq[0].rspq.abs_id));
 	return 0;
 }
 
@@ -4094,7 +4094,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.nports = adap->params.nports;
 	lli.wr_cred = adap->params.ofldq_wr_cred;
 	lli.adapter_type = adap->params.chip;
-	lli.iscsi_iolen = MAXRXDATA_GET(t4_read_reg(adap, TP_PARA_REG2));
+	lli.iscsi_iolen = MAXRXDATA_G(t4_read_reg(adap, TP_PARA_REG2_A));
 	lli.cclk_ps = 1000000000 / adap->params.vpd.cclk;
 	lli.udb_density = 1 << adap->params.sge.eq_qpp;
 	lli.ucq_density = 1 << adap->params.sge.iq_qpp;
@@ -4949,11 +4949,11 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	t4_sge_init(adap);
 
 	/* tweak some settings */
-	t4_write_reg(adap, TP_SHIFT_CNT, 0x64f8849);
+	t4_write_reg(adap, TP_SHIFT_CNT_A, 0x64f8849);
 	t4_write_reg(adap, ULP_RX_TDDP_PSZ, HPZ0(PAGE_SHIFT - 12));
-	t4_write_reg(adap, TP_PIO_ADDR, TP_INGRESS_CONFIG);
-	v = t4_read_reg(adap, TP_PIO_DATA);
-	t4_write_reg(adap, TP_PIO_DATA, v & ~CSUM_HAS_PSEUDO_HDR);
+	t4_write_reg(adap, TP_PIO_ADDR_A, TP_INGRESS_CONFIG_A);
+	v = t4_read_reg(adap, TP_PIO_DATA_A);
+	t4_write_reg(adap, TP_PIO_DATA_A, v & ~CSUM_HAS_PSEUDO_HDR_F);
 
 	/* first 4 Tx modulation queues point to consecutive Tx channels */
 	adap->params.tp.tx_modq_map = 0xE4;
@@ -4962,11 +4962,11 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 
 	/* associate each Tx modulation queue with consecutive Tx channels */
 	v = 0x84218421;
-	t4_write_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
 			  &v, 1, A_TP_TX_SCHED_HDR);
-	t4_write_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
 			  &v, 1, A_TP_TX_SCHED_FIFO);
-	t4_write_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
 			  &v, 1, A_TP_TX_SCHED_PCMD);
 
 #define T4_TX_MODQ_10G_WEIGHT_DEFAULT 16 /* in KB units */
@@ -5034,8 +5034,8 @@ static int adap_init0_tweaks(struct adapter *adapter)
 	 * Don't include the "IP Pseudo Header" in CPL_RX_PKT checksums: Linux
 	 * adds the pseudo header itself.
 	 */
-	t4_tp_wr_bits_indirect(adapter, TP_INGRESS_CONFIG,
-			       CSUM_HAS_PSEUDO_HDR, 0);
+	t4_tp_wr_bits_indirect(adapter, TP_INGRESS_CONFIG_A,
+			       CSUM_HAS_PSEUDO_HDR_F, 0);
 
 	return 0;
 }
@@ -5401,34 +5401,34 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 			case 0:
 				/* compressed filter field not enabled */
 				break;
-			case FCOE_MASK:
+			case FCOE_F:
 				bits +=  1;
 				break;
-			case PORT_MASK:
+			case PORT_F:
 				bits +=  3;
 				break;
-			case VNIC_ID_MASK:
+			case VNIC_F:
 				bits += 17;
 				break;
-			case VLAN_MASK:
+			case VLAN_F:
 				bits += 17;
 				break;
-			case TOS_MASK:
+			case TOS_F:
 				bits +=  8;
 				break;
-			case PROTOCOL_MASK:
+			case PROTOCOL_F:
 				bits +=  8;
 				break;
-			case ETHERTYPE_MASK:
+			case ETHERTYPE_F:
 				bits += 16;
 				break;
-			case MACMATCH_MASK:
+			case MACMATCH_F:
 				bits +=  9;
 				break;
-			case MPSHITTYPE_MASK:
+			case MPSHITTYPE_F:
 				bits +=  3;
 				break;
-			case FRAGMENTATION_MASK:
+			case FRAGMENTATION_F:
 				bits +=  1;
 				break;
 			}
@@ -5442,8 +5442,8 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 		}
 	}
 	v = tp_vlan_pri_map;
-	t4_write_indirect(adapter, TP_PIO_ADDR, TP_PIO_DATA,
-			  &v, 1, TP_VLAN_PRI_MAP);
+	t4_write_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+			  &v, 1, TP_VLAN_PRI_MAP_A);
 
 	/*
 	 * We need Five Tuple Lookup mode to be set in TP_GLOBAL_CONFIG order
@@ -5456,17 +5456,17 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 	 * performance impact).
 	 */
 	if (tp_vlan_pri_map)
-		t4_set_reg_field(adapter, TP_GLOBAL_CONFIG,
-				 FIVETUPLELOOKUP_MASK,
-				 FIVETUPLELOOKUP_MASK);
+		t4_set_reg_field(adapter, TP_GLOBAL_CONFIG_A,
+				 FIVETUPLELOOKUP_V(FIVETUPLELOOKUP_M),
+				 FIVETUPLELOOKUP_V(FIVETUPLELOOKUP_M));
 
 	/*
 	 * Tweak some settings.
 	 */
-	t4_write_reg(adapter, TP_SHIFT_CNT, SYNSHIFTMAX(6) |
-		     RXTSHIFTMAXR1(4) | RXTSHIFTMAXR2(15) |
-		     PERSHIFTBACKOFFMAX(8) | PERSHIFTMAX(8) |
-		     KEEPALIVEMAXR1(4) | KEEPALIVEMAXR2(9));
+	t4_write_reg(adapter, TP_SHIFT_CNT_A, SYNSHIFTMAX_V(6) |
+		     RXTSHIFTMAXR1_V(4) | RXTSHIFTMAXR2_V(15) |
+		     PERSHIFTBACKOFFMAX_V(8) | PERSHIFTMAX_V(8) |
+		     KEEPALIVEMAXR1_V(4) | KEEPALIVEMAXR2_V(9));
 
 	/*
 	 * Get basic stuff going by issuing the Firmware Initialize command.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c9777e0..cf0bf79 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1486,11 +1486,11 @@ static void tp_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info tp_intr_info[] = {
 		{ 0x3fffffff, "TP parity error", -1, 1 },
-		{ FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1 },
+		{ FLMTXFLSTEMPTY_F, "TP out of Tx pages", -1, 1 },
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adapter, TP_INT_CAUSE, tp_intr_info))
+	if (t4_handle_intr_status(adapter, TP_INT_CAUSE_A, tp_intr_info))
 		t4_fatal_err(adapter);
 }
 
@@ -1629,19 +1629,19 @@ static void ulprx_intr_handler(struct adapter *adapter)
 static void ulptx_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info ulptx_intr_info[] = {
-		{ PBL_BOUND_ERR_CH3, "ULPTX channel 3 PBL out of bounds", -1,
+		{ PBL_BOUND_ERR_CH3_F, "ULPTX channel 3 PBL out of bounds", -1,
 		  0 },
-		{ PBL_BOUND_ERR_CH2, "ULPTX channel 2 PBL out of bounds", -1,
+		{ PBL_BOUND_ERR_CH2_F, "ULPTX channel 2 PBL out of bounds", -1,
 		  0 },
-		{ PBL_BOUND_ERR_CH1, "ULPTX channel 1 PBL out of bounds", -1,
+		{ PBL_BOUND_ERR_CH1_F, "ULPTX channel 1 PBL out of bounds", -1,
 		  0 },
-		{ PBL_BOUND_ERR_CH0, "ULPTX channel 0 PBL out of bounds", -1,
+		{ PBL_BOUND_ERR_CH0_F, "ULPTX channel 0 PBL out of bounds", -1,
 		  0 },
 		{ 0xfffffff, "ULPTX parity error", -1, 1 },
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adapter, ULP_TX_INT_CAUSE, ulptx_intr_info))
+	if (t4_handle_intr_status(adapter, ULP_TX_INT_CAUSE_A, ulptx_intr_info))
 		t4_fatal_err(adapter);
 }
 
@@ -1651,19 +1651,20 @@ static void ulptx_intr_handler(struct adapter *adapter)
 static void pmtx_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info pmtx_intr_info[] = {
-		{ PCMD_LEN_OVFL0, "PMTX channel 0 pcmd too large", -1, 1 },
-		{ PCMD_LEN_OVFL1, "PMTX channel 1 pcmd too large", -1, 1 },
-		{ PCMD_LEN_OVFL2, "PMTX channel 2 pcmd too large", -1, 1 },
-		{ ZERO_C_CMD_ERROR, "PMTX 0-length pcmd", -1, 1 },
-		{ PMTX_FRAMING_ERROR, "PMTX framing error", -1, 1 },
-		{ OESPI_PAR_ERROR, "PMTX oespi parity error", -1, 1 },
-		{ DB_OPTIONS_PAR_ERROR, "PMTX db_options parity error", -1, 1 },
-		{ ICSPI_PAR_ERROR, "PMTX icspi parity error", -1, 1 },
-		{ C_PCMD_PAR_ERROR, "PMTX c_pcmd parity error", -1, 1},
+		{ PCMD_LEN_OVFL0_F, "PMTX channel 0 pcmd too large", -1, 1 },
+		{ PCMD_LEN_OVFL1_F, "PMTX channel 1 pcmd too large", -1, 1 },
+		{ PCMD_LEN_OVFL2_F, "PMTX channel 2 pcmd too large", -1, 1 },
+		{ ZERO_C_CMD_ERROR_F, "PMTX 0-length pcmd", -1, 1 },
+		{ PMTX_FRAMING_ERROR_F, "PMTX framing error", -1, 1 },
+		{ OESPI_PAR_ERROR_F, "PMTX oespi parity error", -1, 1 },
+		{ DB_OPTIONS_PAR_ERROR_F, "PMTX db_options parity error",
+		  -1, 1 },
+		{ ICSPI_PAR_ERROR_F, "PMTX icspi parity error", -1, 1 },
+		{ PMTX_C_PCMD_PAR_ERROR_F, "PMTX c_pcmd parity error", -1, 1},
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adapter, PM_TX_INT_CAUSE, pmtx_intr_info))
+	if (t4_handle_intr_status(adapter, PM_TX_INT_CAUSE_A, pmtx_intr_info))
 		t4_fatal_err(adapter);
 }
 
@@ -1673,16 +1674,17 @@ static void pmtx_intr_handler(struct adapter *adapter)
 static void pmrx_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info pmrx_intr_info[] = {
-		{ ZERO_E_CMD_ERROR, "PMRX 0-length pcmd", -1, 1 },
-		{ PMRX_FRAMING_ERROR, "PMRX framing error", -1, 1 },
-		{ OCSPI_PAR_ERROR, "PMRX ocspi parity error", -1, 1 },
-		{ DB_OPTIONS_PAR_ERROR, "PMRX db_options parity error", -1, 1 },
-		{ IESPI_PAR_ERROR, "PMRX iespi parity error", -1, 1 },
-		{ E_PCMD_PAR_ERROR, "PMRX e_pcmd parity error", -1, 1},
+		{ ZERO_E_CMD_ERROR_F, "PMRX 0-length pcmd", -1, 1 },
+		{ PMRX_FRAMING_ERROR_F, "PMRX framing error", -1, 1 },
+		{ OCSPI_PAR_ERROR_F, "PMRX ocspi parity error", -1, 1 },
+		{ DB_OPTIONS_PAR_ERROR_F, "PMRX db_options parity error",
+		  -1, 1 },
+		{ IESPI_PAR_ERROR_F, "PMRX iespi parity error", -1, 1 },
+		{ PMRX_E_PCMD_PAR_ERROR_F, "PMRX e_pcmd parity error", -1, 1},
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adapter, PM_RX_INT_CAUSE, pmrx_intr_info))
+	if (t4_handle_intr_status(adapter, PM_RX_INT_CAUSE_A, pmrx_intr_info))
 		t4_fatal_err(adapter);
 }
 
@@ -1733,19 +1735,22 @@ static void mps_intr_handler(struct adapter *adapter)
 		{ 0 }
 	};
 	static const struct intr_info mps_tx_intr_info[] = {
-		{ TPFIFO, "MPS Tx TP FIFO parity error", -1, 1 },
-		{ NCSIFIFO, "MPS Tx NC-SI FIFO parity error", -1, 1 },
-		{ TXDATAFIFO, "MPS Tx data FIFO parity error", -1, 1 },
-		{ TXDESCFIFO, "MPS Tx desc FIFO parity error", -1, 1 },
-		{ BUBBLE, "MPS Tx underflow", -1, 1 },
-		{ SECNTERR, "MPS Tx SOP/EOP error", -1, 1 },
-		{ FRMERR, "MPS Tx framing error", -1, 1 },
+		{ TPFIFO_V(TPFIFO_M), "MPS Tx TP FIFO parity error", -1, 1 },
+		{ NCSIFIFO_F, "MPS Tx NC-SI FIFO parity error", -1, 1 },
+		{ TXDATAFIFO_V(TXDATAFIFO_M), "MPS Tx data FIFO parity error",
+		  -1, 1 },
+		{ TXDESCFIFO_V(TXDESCFIFO_M), "MPS Tx desc FIFO parity error",
+		  -1, 1 },
+		{ BUBBLE_F, "MPS Tx underflow", -1, 1 },
+		{ SECNTERR_F, "MPS Tx SOP/EOP error", -1, 1 },
+		{ FRMERR_F, "MPS Tx framing error", -1, 1 },
 		{ 0 }
 	};
 	static const struct intr_info mps_trc_intr_info[] = {
-		{ FILTMEM, "MPS TRC filter parity error", -1, 1 },
-		{ PKTFIFO, "MPS TRC packet FIFO parity error", -1, 1 },
-		{ MISCPERR, "MPS TRC misc parity error", -1, 1 },
+		{ FILTMEM_V(FILTMEM_M), "MPS TRC filter parity error", -1, 1 },
+		{ PKTFIFO_V(PKTFIFO_M), "MPS TRC packet FIFO parity error",
+		  -1, 1 },
+		{ MISCPERR_F, "MPS TRC misc parity error", -1, 1 },
 		{ 0 }
 	};
 	static const struct intr_info mps_stat_sram_intr_info[] = {
@@ -1761,32 +1766,31 @@ static void mps_intr_handler(struct adapter *adapter)
 		{ 0 }
 	};
 	static const struct intr_info mps_cls_intr_info[] = {
-		{ MATCHSRAM, "MPS match SRAM parity error", -1, 1 },
-		{ MATCHTCAM, "MPS match TCAM parity error", -1, 1 },
-		{ HASHSRAM, "MPS hash SRAM parity error", -1, 1 },
+		{ MATCHSRAM_F, "MPS match SRAM parity error", -1, 1 },
+		{ MATCHTCAM_F, "MPS match TCAM parity error", -1, 1 },
+		{ HASHSRAM_F, "MPS hash SRAM parity error", -1, 1 },
 		{ 0 }
 	};
 
 	int fat;
 
-	fat = t4_handle_intr_status(adapter, MPS_RX_PERR_INT_CAUSE,
+	fat = t4_handle_intr_status(adapter, MPS_RX_PERR_INT_CAUSE_A,
 				    mps_rx_intr_info) +
-	      t4_handle_intr_status(adapter, MPS_TX_INT_CAUSE,
+	      t4_handle_intr_status(adapter, MPS_TX_INT_CAUSE_A,
 				    mps_tx_intr_info) +
-	      t4_handle_intr_status(adapter, MPS_TRC_INT_CAUSE,
+	      t4_handle_intr_status(adapter, MPS_TRC_INT_CAUSE_A,
 				    mps_trc_intr_info) +
-	      t4_handle_intr_status(adapter, MPS_STAT_PERR_INT_CAUSE_SRAM,
+	      t4_handle_intr_status(adapter, MPS_STAT_PERR_INT_CAUSE_SRAM_A,
 				    mps_stat_sram_intr_info) +
-	      t4_handle_intr_status(adapter, MPS_STAT_PERR_INT_CAUSE_TX_FIFO,
+	      t4_handle_intr_status(adapter, MPS_STAT_PERR_INT_CAUSE_TX_FIFO_A,
 				    mps_stat_tx_intr_info) +
-	      t4_handle_intr_status(adapter, MPS_STAT_PERR_INT_CAUSE_RX_FIFO,
+	      t4_handle_intr_status(adapter, MPS_STAT_PERR_INT_CAUSE_RX_FIFO_A,
 				    mps_stat_rx_intr_info) +
-	      t4_handle_intr_status(adapter, MPS_CLS_INT_CAUSE,
+	      t4_handle_intr_status(adapter, MPS_CLS_INT_CAUSE_A,
 				    mps_cls_intr_info);
 
-	t4_write_reg(adapter, MPS_INT_CAUSE, CLSINT | TRCINT |
-		     RXINT | TXINT | STATINT);
-	t4_read_reg(adapter, MPS_INT_CAUSE);                    /* flush */
+	t4_write_reg(adapter, MPS_INT_CAUSE_A, 0);
+	t4_read_reg(adapter, MPS_INT_CAUSE_A);                    /* flush */
 	if (fat)
 		t4_fatal_err(adapter);
 }
@@ -2187,23 +2191,23 @@ int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
 void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 			 struct tp_tcp_stats *v6)
 {
-	u32 val[TP_MIB_TCP_RXT_SEG_LO - TP_MIB_TCP_OUT_RST + 1];
+	u32 val[TP_MIB_TCP_RXT_SEG_LO_A - TP_MIB_TCP_OUT_RST_A + 1];
 
-#define STAT_IDX(x) ((TP_MIB_TCP_##x) - TP_MIB_TCP_OUT_RST)
+#define STAT_IDX(x) ((TP_MIB_TCP_##x##_A) - TP_MIB_TCP_OUT_RST_A)
 #define STAT(x)     val[STAT_IDX(x)]
 #define STAT64(x)   (((u64)STAT(x##_HI) << 32) | STAT(x##_LO))
 
 	if (v4) {
-		t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, val,
-				 ARRAY_SIZE(val), TP_MIB_TCP_OUT_RST);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, val,
+				 ARRAY_SIZE(val), TP_MIB_TCP_OUT_RST_A);
 		v4->tcpOutRsts = STAT(OUT_RST);
 		v4->tcpInSegs  = STAT64(IN_SEG);
 		v4->tcpOutSegs = STAT64(OUT_SEG);
 		v4->tcpRetransSegs = STAT64(RXT_SEG);
 	}
 	if (v6) {
-		t4_read_indirect(adap, TP_MIB_INDEX, TP_MIB_DATA, val,
-				 ARRAY_SIZE(val), TP_MIB_TCP_V6OUT_RST);
+		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, val,
+				 ARRAY_SIZE(val), TP_MIB_TCP_V6OUT_RST_A);
 		v6->tcpOutRsts = STAT(OUT_RST);
 		v6->tcpInSegs  = STAT64(IN_SEG);
 		v6->tcpOutSegs = STAT64(OUT_SEG);
@@ -2228,12 +2232,12 @@ void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log)
 	int i;
 
 	for (i = 0; i < NMTUS; ++i) {
-		t4_write_reg(adap, TP_MTU_TABLE,
-			     MTUINDEX(0xff) | MTUVALUE(i));
-		v = t4_read_reg(adap, TP_MTU_TABLE);
-		mtus[i] = MTUVALUE_GET(v);
+		t4_write_reg(adap, TP_MTU_TABLE_A,
+			     MTUINDEX_V(0xff) | MTUVALUE_V(i));
+		v = t4_read_reg(adap, TP_MTU_TABLE_A);
+		mtus[i] = MTUVALUE_G(v);
 		if (mtu_log)
-			mtu_log[i] = MTUWIDTH_GET(v);
+			mtu_log[i] = MTUWIDTH_G(v);
 	}
 }
 
@@ -2249,9 +2253,9 @@ void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log)
 void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
 			    unsigned int mask, unsigned int val)
 {
-	t4_write_reg(adap, TP_PIO_ADDR, addr);
-	val |= t4_read_reg(adap, TP_PIO_DATA) & ~mask;
-	t4_write_reg(adap, TP_PIO_DATA, val);
+	t4_write_reg(adap, TP_PIO_ADDR_A, addr);
+	val |= t4_read_reg(adap, TP_PIO_DATA_A) & ~mask;
+	t4_write_reg(adap, TP_PIO_DATA_A, val);
 }
 
 /**
@@ -2330,8 +2334,8 @@ void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
 
 		if (!(mtu & ((1 << log2) >> 2)))     /* round */
 			log2--;
-		t4_write_reg(adap, TP_MTU_TABLE, MTUINDEX(i) |
-			     MTUWIDTH(log2) | MTUVALUE(mtu));
+		t4_write_reg(adap, TP_MTU_TABLE_A, MTUINDEX_V(i) |
+			     MTUWIDTH_V(log2) | MTUVALUE_V(mtu));
 
 		for (w = 0; w < NCCTRL_WIN; ++w) {
 			unsigned int inc;
@@ -2339,7 +2343,7 @@ void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
 			inc = max(((mtu - 40) * alpha[w]) / avg_pkts[w],
 				  CC_MIN_INCR);
 
-			t4_write_reg(adap, TP_CCTRL_TABLE, (i << 21) |
+			t4_write_reg(adap, TP_CCTRL_TABLE_A, (i << 21) |
 				     (w << 16) | (beta[w] << 13) | inc);
 		}
 	}
@@ -2356,7 +2360,7 @@ void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
  */
 static unsigned int get_mps_bg_map(struct adapter *adap, int idx)
 {
-	u32 n = NUMPORTS_GET(t4_read_reg(adap, MPS_CMN_CTL));
+	u32 n = NUMPORTS_G(t4_read_reg(adap, MPS_CMN_CTL_A));
 
 	if (n == 0)
 		return idx == 0 ? 0xf : 0;
@@ -2498,7 +2502,7 @@ void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
 	} else {
 		mag_id_reg_l = T5_PORT_REG(port, MAC_PORT_MAGIC_MACID_LO);
 		mag_id_reg_h = T5_PORT_REG(port, MAC_PORT_MAGIC_MACID_HI);
-		port_cfg_reg = T5_PORT_REG(port, MAC_PORT_CFG2);
+		port_cfg_reg = T5_PORT_REG(port, MAC_PORT_CFG2_A);
 	}
 
 	if (addr) {
@@ -2536,7 +2540,7 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 	if (is_t4(adap->params.chip))
 		port_cfg_reg = PORT_REG(port, XGMAC_PORT_CFG2);
 	else
-		port_cfg_reg = T5_PORT_REG(port, MAC_PORT_CFG2);
+		port_cfg_reg = T5_PORT_REG(port, MAC_PORT_CFG2_A);
 
 	if (!enable) {
 		t4_set_reg_field(adap, port_cfg_reg, PATEN, 0);
@@ -2547,7 +2551,7 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 
 #define EPIO_REG(name) \
 	(is_t4(adap->params.chip) ? PORT_REG(port, XGMAC_PORT_EPIO_##name) : \
-	T5_PORT_REG(port, MAC_PORT_EPIO_##name))
+	T5_PORT_REG(port, MAC_PORT_EPIO_##name##_A))
 
 	t4_write_reg(adap, EPIO_REG(DATA1), mask0 >> 32);
 	t4_write_reg(adap, EPIO_REG(DATA2), mask1);
@@ -4171,9 +4175,9 @@ int t4_init_tp_params(struct adapter *adap)
 	int chan;
 	u32 v;
 
-	v = t4_read_reg(adap, TP_TIMER_RESOLUTION);
-	adap->params.tp.tre = TIMERRESOLUTION_GET(v);
-	adap->params.tp.dack_re = DELAYEDACKRESOLUTION_GET(v);
+	v = t4_read_reg(adap, TP_TIMER_RESOLUTION_A);
+	adap->params.tp.tre = TIMERRESOLUTION_G(v);
+	adap->params.tp.dack_re = DELAYEDACKRESOLUTION_G(v);
 
 	/* MODQ_REQ_MAP defaults to setting queues 0-3 to chan 0-3 */
 	for (chan = 0; chan < NCHAN; chan++)
@@ -4182,12 +4186,12 @@ int t4_init_tp_params(struct adapter *adap)
 	/* Cache the adapter's Compressed Filter Mode and global Incress
 	 * Configuration.
 	 */
-	t4_read_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+	t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
 			 &adap->params.tp.vlan_pri_map, 1,
-			 TP_VLAN_PRI_MAP);
-	t4_read_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+			 TP_VLAN_PRI_MAP_A);
+	t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
 			 &adap->params.tp.ingress_config, 1,
-			 TP_INGRESS_CONFIG);
+			 TP_INGRESS_CONFIG_A);
 
 	/* Now that we have TP_VLAN_PRI_MAP cached, we can calculate the field
 	 * shift positions of several elements of the Compressed Filter Tuple
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 4b66818..ec0addc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1182,158 +1182,258 @@
 #define RSVDSPACEINT_V(x) ((x) << RSVDSPACEINT_S)
 #define RSVDSPACEINT_F    RSVDSPACEINT_V(1U)
 
-#define TP_OUT_CONFIG 0x7d04
-#define  VLANEXTENABLE_MASK  0x0000f000U
-#define  VLANEXTENABLE_SHIFT 12
-
-#define TP_GLOBAL_CONFIG 0x7d08
-#define  FIVETUPLELOOKUP_SHIFT  17
-#define  FIVETUPLELOOKUP_MASK   0x00060000U
-#define  FIVETUPLELOOKUP(x)     ((x) << FIVETUPLELOOKUP_SHIFT)
-#define  FIVETUPLELOOKUP_GET(x) (((x) & FIVETUPLELOOKUP_MASK) >> \
-				FIVETUPLELOOKUP_SHIFT)
-
-#define TP_PARA_REG2 0x7d68
-#define  MAXRXDATA_MASK    0xffff0000U
-#define  MAXRXDATA_SHIFT   16
-#define  MAXRXDATA_GET(x) (((x) & MAXRXDATA_MASK) >> MAXRXDATA_SHIFT)
-
-#define TP_TIMER_RESOLUTION 0x7d90
-#define  TIMERRESOLUTION_MASK   0x00ff0000U
-#define  TIMERRESOLUTION_SHIFT  16
-#define  TIMERRESOLUTION_GET(x) (((x) & TIMERRESOLUTION_MASK) >> TIMERRESOLUTION_SHIFT)
-#define  DELAYEDACKRESOLUTION_MASK 0x000000ffU
-#define  DELAYEDACKRESOLUTION_SHIFT     0
-#define  DELAYEDACKRESOLUTION_GET(x) \
-	(((x) & DELAYEDACKRESOLUTION_MASK) >> DELAYEDACKRESOLUTION_SHIFT)
-
-#define TP_SHIFT_CNT 0x7dc0
-#define  SYNSHIFTMAX_SHIFT         24
-#define  SYNSHIFTMAX_MASK          0xff000000U
-#define  SYNSHIFTMAX(x)            ((x) << SYNSHIFTMAX_SHIFT)
-#define  SYNSHIFTMAX_GET(x)        (((x) & SYNSHIFTMAX_MASK) >> \
-				   SYNSHIFTMAX_SHIFT)
-#define  RXTSHIFTMAXR1_SHIFT       20
-#define  RXTSHIFTMAXR1_MASK        0x00f00000U
-#define  RXTSHIFTMAXR1(x)          ((x) << RXTSHIFTMAXR1_SHIFT)
-#define  RXTSHIFTMAXR1_GET(x)      (((x) & RXTSHIFTMAXR1_MASK) >> \
-				   RXTSHIFTMAXR1_SHIFT)
-#define  RXTSHIFTMAXR2_SHIFT       16
-#define  RXTSHIFTMAXR2_MASK        0x000f0000U
-#define  RXTSHIFTMAXR2(x)          ((x) << RXTSHIFTMAXR2_SHIFT)
-#define  RXTSHIFTMAXR2_GET(x)      (((x) & RXTSHIFTMAXR2_MASK) >> \
-				   RXTSHIFTMAXR2_SHIFT)
-#define  PERSHIFTBACKOFFMAX_SHIFT  12
-#define  PERSHIFTBACKOFFMAX_MASK   0x0000f000U
-#define  PERSHIFTBACKOFFMAX(x)     ((x) << PERSHIFTBACKOFFMAX_SHIFT)
-#define  PERSHIFTBACKOFFMAX_GET(x) (((x) & PERSHIFTBACKOFFMAX_MASK) >> \
-				   PERSHIFTBACKOFFMAX_SHIFT)
-#define  PERSHIFTMAX_SHIFT         8
-#define  PERSHIFTMAX_MASK          0x00000f00U
-#define  PERSHIFTMAX(x)            ((x) << PERSHIFTMAX_SHIFT)
-#define  PERSHIFTMAX_GET(x)        (((x) & PERSHIFTMAX_MASK) >> \
-				   PERSHIFTMAX_SHIFT)
-#define  KEEPALIVEMAXR1_SHIFT      4
-#define  KEEPALIVEMAXR1_MASK       0x000000f0U
-#define  KEEPALIVEMAXR1(x)         ((x) << KEEPALIVEMAXR1_SHIFT)
-#define  KEEPALIVEMAXR1_GET(x)     (((x) & KEEPALIVEMAXR1_MASK) >> \
-				   KEEPALIVEMAXR1_SHIFT)
-#define KEEPALIVEMAXR2_SHIFT       0
-#define KEEPALIVEMAXR2_MASK        0x0000000fU
-#define KEEPALIVEMAXR2(x)          ((x) << KEEPALIVEMAXR2_SHIFT)
-#define KEEPALIVEMAXR2_GET(x)      (((x) & KEEPALIVEMAXR2_MASK) >> \
-				   KEEPALIVEMAXR2_SHIFT)
-
-#define TP_CCTRL_TABLE 0x7ddc
-#define TP_MTU_TABLE 0x7de4
-#define  MTUINDEX_MASK   0xff000000U
-#define  MTUINDEX_SHIFT  24
-#define  MTUINDEX(x)     ((x) << MTUINDEX_SHIFT)
-#define  MTUWIDTH_MASK   0x000f0000U
-#define  MTUWIDTH_SHIFT  16
-#define  MTUWIDTH(x)     ((x) << MTUWIDTH_SHIFT)
-#define  MTUWIDTH_GET(x) (((x) & MTUWIDTH_MASK) >> MTUWIDTH_SHIFT)
-#define  MTUVALUE_MASK   0x00003fffU
-#define  MTUVALUE_SHIFT  0
-#define  MTUVALUE(x)     ((x) << MTUVALUE_SHIFT)
-#define  MTUVALUE_GET(x) (((x) & MTUVALUE_MASK) >> MTUVALUE_SHIFT)
-
-#define TP_RSS_LKP_TABLE 0x7dec
-#define  LKPTBLROWVLD        0x80000000U
-#define  LKPTBLQUEUE1_MASK   0x000ffc00U
-#define  LKPTBLQUEUE1_SHIFT  10
-#define  LKPTBLQUEUE1(x)     ((x) << LKPTBLQUEUE1_SHIFT)
-#define  LKPTBLQUEUE1_GET(x) (((x) & LKPTBLQUEUE1_MASK) >> LKPTBLQUEUE1_SHIFT)
-#define  LKPTBLQUEUE0_MASK   0x000003ffU
-#define  LKPTBLQUEUE0_SHIFT  0
-#define  LKPTBLQUEUE0(x)     ((x) << LKPTBLQUEUE0_SHIFT)
-#define  LKPTBLQUEUE0_GET(x) (((x) & LKPTBLQUEUE0_MASK) >> LKPTBLQUEUE0_SHIFT)
-
-#define TP_PIO_ADDR 0x7e40
-#define TP_PIO_DATA 0x7e44
-#define TP_MIB_INDEX 0x7e50
-#define TP_MIB_DATA 0x7e54
-#define TP_INT_CAUSE 0x7e74
-#define  FLMTXFLSTEMPTY 0x40000000U
-
-#define TP_VLAN_PRI_MAP 0x140
-#define  FRAGMENTATION_SHIFT 9
-#define  FRAGMENTATION_MASK  0x00000200U
-#define  MPSHITTYPE_MASK     0x00000100U
-#define  MACMATCH_MASK       0x00000080U
-#define  ETHERTYPE_MASK      0x00000040U
-#define  PROTOCOL_MASK       0x00000020U
-#define  TOS_MASK            0x00000010U
-#define  VLAN_MASK           0x00000008U
-#define  VNIC_ID_MASK        0x00000004U
-#define  PORT_MASK           0x00000002U
-#define  FCOE_SHIFT          0
-#define  FCOE_MASK           0x00000001U
-
-#define TP_INGRESS_CONFIG 0x141
-#define  VNIC                0x00000800U
-#define  CSUM_HAS_PSEUDO_HDR 0x00000400U
-#define  RM_OVLAN            0x00000200U
-#define  LOOKUPEVERYPKT      0x00000100U
-
-#define TP_MIB_MAC_IN_ERR_0 0x0
-#define TP_MIB_TCP_OUT_RST 0xc
-#define TP_MIB_TCP_IN_SEG_HI 0x10
-#define TP_MIB_TCP_IN_SEG_LO 0x11
-#define TP_MIB_TCP_OUT_SEG_HI 0x12
-#define TP_MIB_TCP_OUT_SEG_LO 0x13
-#define TP_MIB_TCP_RXT_SEG_HI 0x14
-#define TP_MIB_TCP_RXT_SEG_LO 0x15
-#define TP_MIB_TNL_CNG_DROP_0 0x18
-#define TP_MIB_TCP_V6IN_ERR_0 0x28
-#define TP_MIB_TCP_V6OUT_RST 0x2c
-#define TP_MIB_OFD_ARP_DROP 0x36
-#define TP_MIB_TNL_DROP_0 0x44
-#define TP_MIB_OFD_VLN_DROP_0 0x58
-
-#define ULP_TX_INT_CAUSE 0x8dcc
-#define  PBL_BOUND_ERR_CH3 0x80000000U
-#define  PBL_BOUND_ERR_CH2 0x40000000U
-#define  PBL_BOUND_ERR_CH1 0x20000000U
-#define  PBL_BOUND_ERR_CH0 0x10000000U
-
-#define PM_RX_INT_CAUSE 0x8fdc
-#define  ZERO_E_CMD_ERROR     0x00400000U
-#define  PMRX_FRAMING_ERROR   0x003ffff0U
-#define  OCSPI_PAR_ERROR      0x00000008U
-#define  DB_OPTIONS_PAR_ERROR 0x00000004U
-#define  IESPI_PAR_ERROR      0x00000002U
-#define  E_PCMD_PAR_ERROR     0x00000001U
-
-#define PM_TX_INT_CAUSE 0x8ffc
-#define  PCMD_LEN_OVFL0     0x80000000U
-#define  PCMD_LEN_OVFL1     0x40000000U
-#define  PCMD_LEN_OVFL2     0x20000000U
-#define  ZERO_C_CMD_ERROR   0x10000000U
-#define  PMTX_FRAMING_ERROR 0x0ffffff0U
-#define  OESPI_PAR_ERROR    0x00000008U
-#define  ICSPI_PAR_ERROR    0x00000002U
-#define  C_PCMD_PAR_ERROR   0x00000001U
+/* registers for module TP */
+#define TP_OUT_CONFIG_A		0x7d04
+#define TP_GLOBAL_CONFIG_A	0x7d08
+
+#define FIVETUPLELOOKUP_S    17
+#define FIVETUPLELOOKUP_M    0x3U
+#define FIVETUPLELOOKUP_V(x) ((x) << FIVETUPLELOOKUP_S)
+#define FIVETUPLELOOKUP_G(x) (((x) >> FIVETUPLELOOKUP_S) & FIVETUPLELOOKUP_M)
+
+#define TP_PARA_REG2_A 0x7d68
+
+#define MAXRXDATA_S    16
+#define MAXRXDATA_M    0xffffU
+#define MAXRXDATA_G(x) (((x) >> MAXRXDATA_S) & MAXRXDATA_M)
+
+#define TP_TIMER_RESOLUTION_A 0x7d90
+
+#define TIMERRESOLUTION_S    16
+#define TIMERRESOLUTION_M    0xffU
+#define TIMERRESOLUTION_G(x) (((x) >> TIMERRESOLUTION_S) & TIMERRESOLUTION_M)
+
+#define DELAYEDACKRESOLUTION_S    0
+#define DELAYEDACKRESOLUTION_M    0xffU
+#define DELAYEDACKRESOLUTION_G(x) \
+	(((x) >> DELAYEDACKRESOLUTION_S) & DELAYEDACKRESOLUTION_M)
+
+#define TP_SHIFT_CNT_A 0x7dc0
+
+#define SYNSHIFTMAX_S    24
+#define SYNSHIFTMAX_M    0xffU
+#define SYNSHIFTMAX_V(x) ((x) << SYNSHIFTMAX_S)
+#define SYNSHIFTMAX_G(x) (((x) >> SYNSHIFTMAX_S) & SYNSHIFTMAX_M)
+
+#define RXTSHIFTMAXR1_S    20
+#define RXTSHIFTMAXR1_M    0xfU
+#define RXTSHIFTMAXR1_V(x) ((x) << RXTSHIFTMAXR1_S)
+#define RXTSHIFTMAXR1_G(x) (((x) >> RXTSHIFTMAXR1_S) & RXTSHIFTMAXR1_M)
+
+#define RXTSHIFTMAXR2_S    16
+#define RXTSHIFTMAXR2_M    0xfU
+#define RXTSHIFTMAXR2_V(x) ((x) << RXTSHIFTMAXR2_S)
+#define RXTSHIFTMAXR2_G(x) (((x) >> RXTSHIFTMAXR2_S) & RXTSHIFTMAXR2_M)
+
+#define PERSHIFTBACKOFFMAX_S    12
+#define PERSHIFTBACKOFFMAX_M    0xfU
+#define PERSHIFTBACKOFFMAX_V(x) ((x) << PERSHIFTBACKOFFMAX_S)
+#define PERSHIFTBACKOFFMAX_G(x) \
+	(((x) >> PERSHIFTBACKOFFMAX_S) & PERSHIFTBACKOFFMAX_M)
+
+#define PERSHIFTMAX_S    8
+#define PERSHIFTMAX_M    0xfU
+#define PERSHIFTMAX_V(x) ((x) << PERSHIFTMAX_S)
+#define PERSHIFTMAX_G(x) (((x) >> PERSHIFTMAX_S) & PERSHIFTMAX_M)
+
+#define KEEPALIVEMAXR1_S    4
+#define KEEPALIVEMAXR1_M    0xfU
+#define KEEPALIVEMAXR1_V(x) ((x) << KEEPALIVEMAXR1_S)
+#define KEEPALIVEMAXR1_G(x) (((x) >> KEEPALIVEMAXR1_S) & KEEPALIVEMAXR1_M)
+
+#define KEEPALIVEMAXR2_S    0
+#define KEEPALIVEMAXR2_M    0xfU
+#define KEEPALIVEMAXR2_V(x) ((x) << KEEPALIVEMAXR2_S)
+#define KEEPALIVEMAXR2_G(x) (((x) >> KEEPALIVEMAXR2_S) & KEEPALIVEMAXR2_M)
+
+#define TP_CCTRL_TABLE_A	0x7ddc
+#define TP_MTU_TABLE_A		0x7de4
+
+#define MTUINDEX_S    24
+#define MTUINDEX_V(x) ((x) << MTUINDEX_S)
+
+#define MTUWIDTH_S    16
+#define MTUWIDTH_M    0xfU
+#define MTUWIDTH_V(x) ((x) << MTUWIDTH_S)
+#define MTUWIDTH_G(x) (((x) >> MTUWIDTH_S) & MTUWIDTH_M)
+
+#define MTUVALUE_S    0
+#define MTUVALUE_M    0x3fffU
+#define MTUVALUE_V(x) ((x) << MTUVALUE_S)
+#define MTUVALUE_G(x) (((x) >> MTUVALUE_S) & MTUVALUE_M)
+
+#define TP_RSS_LKP_TABLE_A	0x7dec
+
+#define LKPTBLROWVLD_S    31
+#define LKPTBLROWVLD_V(x) ((x) << LKPTBLROWVLD_S)
+#define LKPTBLROWVLD_F    LKPTBLROWVLD_V(1U)
+
+#define LKPTBLQUEUE1_S    10
+#define LKPTBLQUEUE1_M    0x3ffU
+#define LKPTBLQUEUE1_G(x) (((x) >> LKPTBLQUEUE1_S) & LKPTBLQUEUE1_M)
+
+#define LKPTBLQUEUE0_S    0
+#define LKPTBLQUEUE0_M    0x3ffU
+#define LKPTBLQUEUE0_G(x) (((x) >> LKPTBLQUEUE0_S) & LKPTBLQUEUE0_M)
+
+#define TP_PIO_ADDR_A	0x7e40
+#define TP_PIO_DATA_A	0x7e44
+#define TP_MIB_INDEX_A	0x7e50
+#define TP_MIB_DATA_A	0x7e54
+#define TP_INT_CAUSE_A	0x7e74
+
+#define FLMTXFLSTEMPTY_S    30
+#define FLMTXFLSTEMPTY_V(x) ((x) << FLMTXFLSTEMPTY_S)
+#define FLMTXFLSTEMPTY_F    FLMTXFLSTEMPTY_V(1U)
+
+#define TP_VLAN_PRI_MAP_A 0x140
+
+#define FRAGMENTATION_S    9
+#define FRAGMENTATION_V(x) ((x) << FRAGMENTATION_S)
+#define FRAGMENTATION_F    FRAGMENTATION_V(1U)
+
+#define MPSHITTYPE_S    8
+#define MPSHITTYPE_V(x) ((x) << MPSHITTYPE_S)
+#define MPSHITTYPE_F    MPSHITTYPE_V(1U)
+
+#define MACMATCH_S    7
+#define MACMATCH_V(x) ((x) << MACMATCH_S)
+#define MACMATCH_F    MACMATCH_V(1U)
+
+#define ETHERTYPE_S    6
+#define ETHERTYPE_V(x) ((x) << ETHERTYPE_S)
+#define ETHERTYPE_F    ETHERTYPE_V(1U)
+
+#define PROTOCOL_S    5
+#define PROTOCOL_V(x) ((x) << PROTOCOL_S)
+#define PROTOCOL_F    PROTOCOL_V(1U)
+
+#define TOS_S    4
+#define TOS_V(x) ((x) << TOS_S)
+#define TOS_F    TOS_V(1U)
+
+#define VLAN_S    3
+#define VLAN_V(x) ((x) << VLAN_S)
+#define VLAN_F    VLAN_V(1U)
+
+#define VNIC_ID_S    2
+#define VNIC_ID_V(x) ((x) << VNIC_ID_S)
+#define VNIC_ID_F    VNIC_ID_V(1U)
+
+#define PORT_S    1
+#define PORT_V(x) ((x) << PORT_S)
+#define PORT_F    PORT_V(1U)
+
+#define FCOE_S    0
+#define FCOE_V(x) ((x) << FCOE_S)
+#define FCOE_F    FCOE_V(1U)
+
+#define FILTERMODE_S    15
+#define FILTERMODE_V(x) ((x) << FILTERMODE_S)
+#define FILTERMODE_F    FILTERMODE_V(1U)
+
+#define FCOEMASK_S    14
+#define FCOEMASK_V(x) ((x) << FCOEMASK_S)
+#define FCOEMASK_F    FCOEMASK_V(1U)
+
+#define TP_INGRESS_CONFIG_A	0x141
+
+#define VNIC_S    11
+#define VNIC_V(x) ((x) << VNIC_S)
+#define VNIC_F    VNIC_V(1U)
+
+#define CSUM_HAS_PSEUDO_HDR_S    10
+#define CSUM_HAS_PSEUDO_HDR_V(x) ((x) << CSUM_HAS_PSEUDO_HDR_S)
+#define CSUM_HAS_PSEUDO_HDR_F    CSUM_HAS_PSEUDO_HDR_V(1U)
+
+#define TP_MIB_MAC_IN_ERR_0_A	0x0
+#define TP_MIB_TCP_OUT_RST_A	0xc
+#define TP_MIB_TCP_IN_SEG_HI_A	0x10
+#define TP_MIB_TCP_IN_SEG_LO_A	0x11
+#define TP_MIB_TCP_OUT_SEG_HI_A	0x12
+#define TP_MIB_TCP_OUT_SEG_LO_A 0x13
+#define TP_MIB_TCP_RXT_SEG_HI_A	0x14
+#define TP_MIB_TCP_RXT_SEG_LO_A	0x15
+#define TP_MIB_TNL_CNG_DROP_0_A 0x18
+#define TP_MIB_TCP_V6IN_ERR_0_A 0x28
+#define TP_MIB_TCP_V6OUT_RST_A	0x2c
+#define TP_MIB_OFD_ARP_DROP_A	0x36
+#define TP_MIB_TNL_DROP_0_A	0x44
+#define TP_MIB_OFD_VLN_DROP_0_A	0x58
+
+#define ULP_TX_INT_CAUSE_A	0x8dcc
+
+#define PBL_BOUND_ERR_CH3_S    31
+#define PBL_BOUND_ERR_CH3_V(x) ((x) << PBL_BOUND_ERR_CH3_S)
+#define PBL_BOUND_ERR_CH3_F    PBL_BOUND_ERR_CH3_V(1U)
+
+#define PBL_BOUND_ERR_CH2_S    30
+#define PBL_BOUND_ERR_CH2_V(x) ((x) << PBL_BOUND_ERR_CH2_S)
+#define PBL_BOUND_ERR_CH2_F    PBL_BOUND_ERR_CH2_V(1U)
+
+#define PBL_BOUND_ERR_CH1_S    29
+#define PBL_BOUND_ERR_CH1_V(x) ((x) << PBL_BOUND_ERR_CH1_S)
+#define PBL_BOUND_ERR_CH1_F    PBL_BOUND_ERR_CH1_V(1U)
+
+#define PBL_BOUND_ERR_CH0_S    28
+#define PBL_BOUND_ERR_CH0_V(x) ((x) << PBL_BOUND_ERR_CH0_S)
+#define PBL_BOUND_ERR_CH0_F    PBL_BOUND_ERR_CH0_V(1U)
+
+#define PM_RX_INT_CAUSE_A	0x8fdc
+
+#define PMRX_FRAMING_ERROR_F	0x003ffff0U
+
+#define ZERO_E_CMD_ERROR_S    22
+#define ZERO_E_CMD_ERROR_V(x) ((x) << ZERO_E_CMD_ERROR_S)
+#define ZERO_E_CMD_ERROR_F    ZERO_E_CMD_ERROR_V(1U)
+
+#define OCSPI_PAR_ERROR_S    3
+#define OCSPI_PAR_ERROR_V(x) ((x) << OCSPI_PAR_ERROR_S)
+#define OCSPI_PAR_ERROR_F    OCSPI_PAR_ERROR_V(1U)
+
+#define DB_OPTIONS_PAR_ERROR_S    2
+#define DB_OPTIONS_PAR_ERROR_V(x) ((x) << DB_OPTIONS_PAR_ERROR_S)
+#define DB_OPTIONS_PAR_ERROR_F    DB_OPTIONS_PAR_ERROR_V(1U)
+
+#define IESPI_PAR_ERROR_S    1
+#define IESPI_PAR_ERROR_V(x) ((x) << IESPI_PAR_ERROR_S)
+#define IESPI_PAR_ERROR_F    IESPI_PAR_ERROR_V(1U)
+
+#define PMRX_E_PCMD_PAR_ERROR_S    0
+#define PMRX_E_PCMD_PAR_ERROR_V(x) ((x) << PMRX_E_PCMD_PAR_ERROR_S)
+#define PMRX_E_PCMD_PAR_ERROR_F    PMRX_E_PCMD_PAR_ERROR_V(1U)
+
+#define PM_TX_INT_CAUSE_A	0x8ffc
+
+#define PCMD_LEN_OVFL0_S    31
+#define PCMD_LEN_OVFL0_V(x) ((x) << PCMD_LEN_OVFL0_S)
+#define PCMD_LEN_OVFL0_F    PCMD_LEN_OVFL0_V(1U)
+
+#define PCMD_LEN_OVFL1_S    30
+#define PCMD_LEN_OVFL1_V(x) ((x) << PCMD_LEN_OVFL1_S)
+#define PCMD_LEN_OVFL1_F    PCMD_LEN_OVFL1_V(1U)
+
+#define PCMD_LEN_OVFL2_S    29
+#define PCMD_LEN_OVFL2_V(x) ((x) << PCMD_LEN_OVFL2_S)
+#define PCMD_LEN_OVFL2_F    PCMD_LEN_OVFL2_V(1U)
+
+#define ZERO_C_CMD_ERROR_S    28
+#define ZERO_C_CMD_ERROR_V(x) ((x) << ZERO_C_CMD_ERROR_S)
+#define ZERO_C_CMD_ERROR_F    ZERO_C_CMD_ERROR_V(1U)
+
+#define  PMTX_FRAMING_ERROR_F 0x0ffffff0U
+
+#define OESPI_PAR_ERROR_S    3
+#define OESPI_PAR_ERROR_V(x) ((x) << OESPI_PAR_ERROR_S)
+#define OESPI_PAR_ERROR_F    OESPI_PAR_ERROR_V(1U)
+
+#define ICSPI_PAR_ERROR_S    1
+#define ICSPI_PAR_ERROR_V(x) ((x) << ICSPI_PAR_ERROR_S)
+#define ICSPI_PAR_ERROR_F    ICSPI_PAR_ERROR_V(1U)
+
+#define PMTX_C_PCMD_PAR_ERROR_S    0
+#define PMTX_C_PCMD_PAR_ERROR_V(x) ((x) << PMTX_C_PCMD_PAR_ERROR_S)
+#define PMTX_C_PCMD_PAR_ERROR_F    PMTX_C_PCMD_PAR_ERROR_V(1U)
 
 #define MPS_PORT_STAT_TX_PORT_BYTES_L 0x400
 #define MPS_PORT_STAT_TX_PORT_BYTES_H 0x404
@@ -1462,41 +1562,57 @@
 #define MPS_PORT_STAT_RX_PORT_PPP7_H 0x60c
 #define MPS_PORT_STAT_RX_PORT_LESS_64B_L 0x610
 #define MPS_PORT_STAT_RX_PORT_LESS_64B_H 0x614
-#define MAC_PORT_CFG2 0x818
 #define MAC_PORT_MAGIC_MACID_LO 0x824
 #define MAC_PORT_MAGIC_MACID_HI 0x828
-#define MAC_PORT_EPIO_DATA0 0x8c0
-#define MAC_PORT_EPIO_DATA1 0x8c4
-#define MAC_PORT_EPIO_DATA2 0x8c8
-#define MAC_PORT_EPIO_DATA3 0x8cc
-#define MAC_PORT_EPIO_OP 0x8d0
-
-#define MPS_CMN_CTL 0x9000
-#define  NUMPORTS_MASK   0x00000003U
-#define  NUMPORTS_SHIFT  0
-#define  NUMPORTS_GET(x) (((x) & NUMPORTS_MASK) >> NUMPORTS_SHIFT)
-
-#define MPS_INT_CAUSE 0x9008
-#define  STATINT 0x00000020U
-#define  TXINT   0x00000010U
-#define  RXINT   0x00000008U
-#define  TRCINT  0x00000004U
-#define  CLSINT  0x00000002U
-#define  PLINT   0x00000001U
-
-#define MPS_TX_INT_CAUSE 0x9408
-#define  PORTERR    0x00010000U
-#define  FRMERR     0x00008000U
-#define  SECNTERR   0x00004000U
-#define  BUBBLE     0x00002000U
-#define  TXDESCFIFO 0x00001e00U
-#define  TXDATAFIFO 0x000001e0U
-#define  NCSIFIFO   0x00000010U
-#define  TPFIFO     0x0000000fU
-
-#define MPS_STAT_PERR_INT_CAUSE_SRAM 0x9614
-#define MPS_STAT_PERR_INT_CAUSE_TX_FIFO 0x9620
-#define MPS_STAT_PERR_INT_CAUSE_RX_FIFO 0x962c
+
+#define MAC_PORT_EPIO_DATA0_A 0x8c0
+#define MAC_PORT_EPIO_DATA1_A 0x8c4
+#define MAC_PORT_EPIO_DATA2_A 0x8c8
+#define MAC_PORT_EPIO_DATA3_A 0x8cc
+#define MAC_PORT_EPIO_OP_A 0x8d0
+
+#define MAC_PORT_CFG2_A 0x818
+
+#define MPS_CMN_CTL_A	0x9000
+
+#define NUMPORTS_S    0
+#define NUMPORTS_M    0x3U
+#define NUMPORTS_G(x) (((x) >> NUMPORTS_S) & NUMPORTS_M)
+
+#define MPS_INT_CAUSE_A 0x9008
+#define MPS_TX_INT_CAUSE_A 0x9408
+
+#define FRMERR_S    15
+#define FRMERR_V(x) ((x) << FRMERR_S)
+#define FRMERR_F    FRMERR_V(1U)
+
+#define SECNTERR_S    14
+#define SECNTERR_V(x) ((x) << SECNTERR_S)
+#define SECNTERR_F    SECNTERR_V(1U)
+
+#define BUBBLE_S    13
+#define BUBBLE_V(x) ((x) << BUBBLE_S)
+#define BUBBLE_F    BUBBLE_V(1U)
+
+#define TXDESCFIFO_S    9
+#define TXDESCFIFO_M    0xfU
+#define TXDESCFIFO_V(x) ((x) << TXDESCFIFO_S)
+
+#define TXDATAFIFO_S    5
+#define TXDATAFIFO_M    0xfU
+#define TXDATAFIFO_V(x) ((x) << TXDATAFIFO_S)
+
+#define NCSIFIFO_S    4
+#define NCSIFIFO_V(x) ((x) << NCSIFIFO_S)
+#define NCSIFIFO_F    NCSIFIFO_V(1U)
+
+#define TPFIFO_S    0
+#define TPFIFO_M    0xfU
+#define TPFIFO_V(x) ((x) << TPFIFO_S)
+
+#define MPS_STAT_PERR_INT_CAUSE_SRAM_A		0x9614
+#define MPS_STAT_PERR_INT_CAUSE_TX_FIFO_A	0x9620
+#define MPS_STAT_PERR_INT_CAUSE_RX_FIFO_A	0x962c
 
 #define MPS_STAT_RX_BG_0_MAC_DROP_FRAME_L 0x9640
 #define MPS_STAT_RX_BG_0_MAC_DROP_FRAME_H 0x9644
@@ -1530,66 +1646,67 @@
 #define MPS_STAT_RX_BG_2_LB_TRUNC_FRAME_H 0x96b4
 #define MPS_STAT_RX_BG_3_LB_TRUNC_FRAME_L 0x96b8
 #define MPS_STAT_RX_BG_3_LB_TRUNC_FRAME_H 0x96bc
-#define MPS_TRC_CFG 0x9800
-#define  TRCFIFOEMPTY       0x00000010U
-#define  TRCIGNOREDROPINPUT 0x00000008U
-#define  TRCKEEPDUPLICATES  0x00000004U
-#define  TRCEN              0x00000002U
-#define  TRCMULTIFILTER     0x00000001U
-
-#define MPS_TRC_RSS_CONTROL 0x9808
-#define MPS_T5_TRC_RSS_CONTROL 0xa00c
-#define  RSSCONTROL_MASK    0x00ff0000U
-#define  RSSCONTROL_SHIFT   16
-#define  RSSCONTROL(x)      ((x) << RSSCONTROL_SHIFT)
-#define  QUEUENUMBER_MASK   0x0000ffffU
-#define  QUEUENUMBER_SHIFT  0
-#define  QUEUENUMBER(x)     ((x) << QUEUENUMBER_SHIFT)
-
-#define MPS_TRC_FILTER_MATCH_CTL_A 0x9810
-#define  TFINVERTMATCH   0x01000000U
-#define  TFPKTTOOLARGE   0x00800000U
-#define  TFEN            0x00400000U
-#define  TFPORT_MASK     0x003c0000U
-#define  TFPORT_SHIFT    18
-#define  TFPORT(x)       ((x) << TFPORT_SHIFT)
-#define  TFPORT_GET(x)   (((x) & TFPORT_MASK) >> TFPORT_SHIFT)
-#define  TFDROP          0x00020000U
-#define  TFSOPEOPERR     0x00010000U
-#define  TFLENGTH_MASK   0x00001f00U
-#define  TFLENGTH_SHIFT  8
-#define  TFLENGTH(x)     ((x) << TFLENGTH_SHIFT)
-#define  TFLENGTH_GET(x) (((x) & TFLENGTH_MASK) >> TFLENGTH_SHIFT)
-#define  TFOFFSET_MASK   0x0000001fU
-#define  TFOFFSET_SHIFT  0
-#define  TFOFFSET(x)     ((x) << TFOFFSET_SHIFT)
-#define  TFOFFSET_GET(x) (((x) & TFOFFSET_MASK) >> TFOFFSET_SHIFT)
-
-#define MPS_TRC_FILTER_MATCH_CTL_B 0x9820
-#define  TFMINPKTSIZE_MASK   0x01ff0000U
-#define  TFMINPKTSIZE_SHIFT  16
-#define  TFMINPKTSIZE(x)     ((x) << TFMINPKTSIZE_SHIFT)
-#define  TFMINPKTSIZE_GET(x) (((x) & TFMINPKTSIZE_MASK) >> TFMINPKTSIZE_SHIFT)
-#define  TFCAPTUREMAX_MASK   0x00003fffU
-#define  TFCAPTUREMAX_SHIFT  0
-#define  TFCAPTUREMAX(x)     ((x) << TFCAPTUREMAX_SHIFT)
-#define  TFCAPTUREMAX_GET(x) (((x) & TFCAPTUREMAX_MASK) >> TFCAPTUREMAX_SHIFT)
-
-#define MPS_TRC_INT_CAUSE 0x985c
-#define  MISCPERR 0x00000100U
-#define  PKTFIFO  0x000000f0U
-#define  FILTMEM  0x0000000fU
-
-#define MPS_TRC_FILTER0_MATCH 0x9c00
-#define MPS_TRC_FILTER0_DONT_CARE 0x9c80
-#define MPS_TRC_FILTER1_MATCH 0x9d00
-#define MPS_CLS_INT_CAUSE 0xd028
-#define  PLERRENB  0x00000008U
-#define  HASHSRAM  0x00000004U
-#define  MATCHTCAM 0x00000002U
-#define  MATCHSRAM 0x00000001U
-
-#define MPS_RX_PERR_INT_CAUSE 0x11074
+
+#define MPS_TRC_CFG_A 0x9800
+
+#define TRCFIFOEMPTY_S    4
+#define TRCFIFOEMPTY_V(x) ((x) << TRCFIFOEMPTY_S)
+#define TRCFIFOEMPTY_F    TRCFIFOEMPTY_V(1U)
+
+#define TRCIGNOREDROPINPUT_S    3
+#define TRCIGNOREDROPINPUT_V(x) ((x) << TRCIGNOREDROPINPUT_S)
+#define TRCIGNOREDROPINPUT_F    TRCIGNOREDROPINPUT_V(1U)
+
+#define TRCKEEPDUPLICATES_S    2
+#define TRCKEEPDUPLICATES_V(x) ((x) << TRCKEEPDUPLICATES_S)
+#define TRCKEEPDUPLICATES_F    TRCKEEPDUPLICATES_V(1U)
+
+#define TRCEN_S    1
+#define TRCEN_V(x) ((x) << TRCEN_S)
+#define TRCEN_F    TRCEN_V(1U)
+
+#define TRCMULTIFILTER_S    0
+#define TRCMULTIFILTER_V(x) ((x) << TRCMULTIFILTER_S)
+#define TRCMULTIFILTER_F    TRCMULTIFILTER_V(1U)
+
+#define MPS_TRC_RSS_CONTROL_A		0x9808
+#define MPS_T5_TRC_RSS_CONTROL_A	0xa00c
+
+#define RSSCONTROL_S    16
+#define RSSCONTROL_V(x) ((x) << RSSCONTROL_S)
+
+#define QUEUENUMBER_S    0
+#define QUEUENUMBER_V(x) ((x) << QUEUENUMBER_S)
+
+#define MPS_TRC_INT_CAUSE_A	0x985c
+
+#define MISCPERR_S    8
+#define MISCPERR_V(x) ((x) << MISCPERR_S)
+#define MISCPERR_F    MISCPERR_V(1U)
+
+#define PKTFIFO_S    4
+#define PKTFIFO_M    0xfU
+#define PKTFIFO_V(x) ((x) << PKTFIFO_S)
+
+#define FILTMEM_S    0
+#define FILTMEM_M    0xfU
+#define FILTMEM_V(x) ((x) << FILTMEM_S)
+
+#define MPS_CLS_INT_CAUSE_A 0xd028
+
+#define HASHSRAM_S    2
+#define HASHSRAM_V(x) ((x) << HASHSRAM_S)
+#define HASHSRAM_F    HASHSRAM_V(1U)
+
+#define MATCHTCAM_S    1
+#define MATCHTCAM_V(x) ((x) << MATCHTCAM_S)
+#define MATCHTCAM_F    MATCHTCAM_V(1U)
+
+#define MATCHSRAM_S    0
+#define MATCHSRAM_V(x) ((x) << MATCHSRAM_S)
+#define MATCHSRAM_F    MATCHSRAM_V(1U)
+
+#define MPS_RX_PERR_INT_CAUSE_A 0x11074
 
 #define CPL_INTR_CAUSE 0x19054
 #define  CIM_OP_MAP_PERR   0x00000020U
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 257dc8d..c641931 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -188,9 +188,9 @@ void
 csio_hw_tp_wr_bits_indirect(struct csio_hw *hw, unsigned int addr,
 			unsigned int mask, unsigned int val)
 {
-	csio_wr_reg32(hw, addr, TP_PIO_ADDR);
-	val |= csio_rd_reg32(hw, TP_PIO_DATA) & ~mask;
-	csio_wr_reg32(hw, val, TP_PIO_DATA);
+	csio_wr_reg32(hw, addr, TP_PIO_ADDR_A);
+	val |= csio_rd_reg32(hw, TP_PIO_DATA_A) & ~mask;
+	csio_wr_reg32(hw, val, TP_PIO_DATA_A);
 }
 
 void
@@ -2683,11 +2683,11 @@ static void csio_tp_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info tp_intr_info[] = {
 		{ 0x3fffffff, "TP parity error", -1, 1 },
-		{ FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1 },
+		{ FLMTXFLSTEMPTY_F, "TP out of Tx pages", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, TP_INT_CAUSE, tp_intr_info))
+	if (csio_handle_intr_status(hw, TP_INT_CAUSE_A, tp_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -2824,19 +2824,19 @@ static void csio_ulprx_intr_handler(struct csio_hw *hw)
 static void csio_ulptx_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info ulptx_intr_info[] = {
-		{ PBL_BOUND_ERR_CH3, "ULPTX channel 3 PBL out of bounds", -1,
+		{ PBL_BOUND_ERR_CH3_F, "ULPTX channel 3 PBL out of bounds", -1,
 		  0 },
-		{ PBL_BOUND_ERR_CH2, "ULPTX channel 2 PBL out of bounds", -1,
+		{ PBL_BOUND_ERR_CH2_F, "ULPTX channel 2 PBL out of bounds", -1,
 		  0 },
-		{ PBL_BOUND_ERR_CH1, "ULPTX channel 1 PBL out of bounds", -1,
+		{ PBL_BOUND_ERR_CH1_F, "ULPTX channel 1 PBL out of bounds", -1,
 		  0 },
-		{ PBL_BOUND_ERR_CH0, "ULPTX channel 0 PBL out of bounds", -1,
+		{ PBL_BOUND_ERR_CH0_F, "ULPTX channel 0 PBL out of bounds", -1,
 		  0 },
 		{ 0xfffffff, "ULPTX parity error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, ULP_TX_INT_CAUSE, ulptx_intr_info))
+	if (csio_handle_intr_status(hw, ULP_TX_INT_CAUSE_A, ulptx_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -2846,20 +2846,20 @@ static void csio_ulptx_intr_handler(struct csio_hw *hw)
 static void csio_pmtx_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info pmtx_intr_info[] = {
-		{ PCMD_LEN_OVFL0, "PMTX channel 0 pcmd too large", -1, 1 },
-		{ PCMD_LEN_OVFL1, "PMTX channel 1 pcmd too large", -1, 1 },
-		{ PCMD_LEN_OVFL2, "PMTX channel 2 pcmd too large", -1, 1 },
-		{ ZERO_C_CMD_ERROR, "PMTX 0-length pcmd", -1, 1 },
+		{ PCMD_LEN_OVFL0_F, "PMTX channel 0 pcmd too large", -1, 1 },
+		{ PCMD_LEN_OVFL1_F, "PMTX channel 1 pcmd too large", -1, 1 },
+		{ PCMD_LEN_OVFL2_F, "PMTX channel 2 pcmd too large", -1, 1 },
+		{ ZERO_C_CMD_ERROR_F, "PMTX 0-length pcmd", -1, 1 },
 		{ 0xffffff0, "PMTX framing error", -1, 1 },
-		{ OESPI_PAR_ERROR, "PMTX oespi parity error", -1, 1 },
-		{ DB_OPTIONS_PAR_ERROR, "PMTX db_options parity error", -1,
+		{ OESPI_PAR_ERROR_F, "PMTX oespi parity error", -1, 1 },
+		{ DB_OPTIONS_PAR_ERROR_F, "PMTX db_options parity error", -1,
 		  1 },
-		{ ICSPI_PAR_ERROR, "PMTX icspi parity error", -1, 1 },
-		{ C_PCMD_PAR_ERROR, "PMTX c_pcmd parity error", -1, 1},
+		{ ICSPI_PAR_ERROR_F, "PMTX icspi parity error", -1, 1 },
+		{ PMTX_C_PCMD_PAR_ERROR_F, "PMTX c_pcmd parity error", -1, 1},
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, PM_TX_INT_CAUSE, pmtx_intr_info))
+	if (csio_handle_intr_status(hw, PM_TX_INT_CAUSE_A, pmtx_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -2869,17 +2869,17 @@ static void csio_pmtx_intr_handler(struct csio_hw *hw)
 static void csio_pmrx_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info pmrx_intr_info[] = {
-		{ ZERO_E_CMD_ERROR, "PMRX 0-length pcmd", -1, 1 },
+		{ ZERO_E_CMD_ERROR_F, "PMRX 0-length pcmd", -1, 1 },
 		{ 0x3ffff0, "PMRX framing error", -1, 1 },
-		{ OCSPI_PAR_ERROR, "PMRX ocspi parity error", -1, 1 },
-		{ DB_OPTIONS_PAR_ERROR, "PMRX db_options parity error", -1,
+		{ OCSPI_PAR_ERROR_F, "PMRX ocspi parity error", -1, 1 },
+		{ DB_OPTIONS_PAR_ERROR_F, "PMRX db_options parity error", -1,
 		  1 },
-		{ IESPI_PAR_ERROR, "PMRX iespi parity error", -1, 1 },
-		{ E_PCMD_PAR_ERROR, "PMRX e_pcmd parity error", -1, 1},
+		{ IESPI_PAR_ERROR_F, "PMRX iespi parity error", -1, 1 },
+		{ PMRX_E_PCMD_PAR_ERROR_F, "PMRX e_pcmd parity error", -1, 1},
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, PM_RX_INT_CAUSE, pmrx_intr_info))
+	if (csio_handle_intr_status(hw, PM_RX_INT_CAUSE_A, pmrx_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -2930,19 +2930,22 @@ static void csio_mps_intr_handler(struct csio_hw *hw)
 		{ 0, NULL, 0, 0 }
 	};
 	static struct intr_info mps_tx_intr_info[] = {
-		{ TPFIFO, "MPS Tx TP FIFO parity error", -1, 1 },
-		{ NCSIFIFO, "MPS Tx NC-SI FIFO parity error", -1, 1 },
-		{ TXDATAFIFO, "MPS Tx data FIFO parity error", -1, 1 },
-		{ TXDESCFIFO, "MPS Tx desc FIFO parity error", -1, 1 },
-		{ BUBBLE, "MPS Tx underflow", -1, 1 },
-		{ SECNTERR, "MPS Tx SOP/EOP error", -1, 1 },
-		{ FRMERR, "MPS Tx framing error", -1, 1 },
+		{ TPFIFO_V(TPFIFO_M), "MPS Tx TP FIFO parity error", -1, 1 },
+		{ NCSIFIFO_F, "MPS Tx NC-SI FIFO parity error", -1, 1 },
+		{ TXDATAFIFO_V(TXDATAFIFO_M), "MPS Tx data FIFO parity error",
+		  -1, 1 },
+		{ TXDESCFIFO_V(TXDESCFIFO_M), "MPS Tx desc FIFO parity error",
+		  -1, 1 },
+		{ BUBBLE_F, "MPS Tx underflow", -1, 1 },
+		{ SECNTERR_F, "MPS Tx SOP/EOP error", -1, 1 },
+		{ FRMERR_F, "MPS Tx framing error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 	static struct intr_info mps_trc_intr_info[] = {
-		{ FILTMEM, "MPS TRC filter parity error", -1, 1 },
-		{ PKTFIFO, "MPS TRC packet FIFO parity error", -1, 1 },
-		{ MISCPERR, "MPS TRC misc parity error", -1, 1 },
+		{ FILTMEM_V(FILTMEM_M), "MPS TRC filter parity error", -1, 1 },
+		{ PKTFIFO_V(PKTFIFO_M), "MPS TRC packet FIFO parity error",
+		  -1, 1 },
+		{ MISCPERR_F, "MPS TRC misc parity error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 	static struct intr_info mps_stat_sram_intr_info[] = {
@@ -2958,31 +2961,31 @@ static void csio_mps_intr_handler(struct csio_hw *hw)
 		{ 0, NULL, 0, 0 }
 	};
 	static struct intr_info mps_cls_intr_info[] = {
-		{ MATCHSRAM, "MPS match SRAM parity error", -1, 1 },
-		{ MATCHTCAM, "MPS match TCAM parity error", -1, 1 },
-		{ HASHSRAM, "MPS hash SRAM parity error", -1, 1 },
+		{ MATCHSRAM_F, "MPS match SRAM parity error", -1, 1 },
+		{ MATCHTCAM_F, "MPS match TCAM parity error", -1, 1 },
+		{ HASHSRAM_F, "MPS hash SRAM parity error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
 	int fat;
 
-	fat = csio_handle_intr_status(hw, MPS_RX_PERR_INT_CAUSE,
-				    mps_rx_intr_info) +
-	      csio_handle_intr_status(hw, MPS_TX_INT_CAUSE,
-				    mps_tx_intr_info) +
-	      csio_handle_intr_status(hw, MPS_TRC_INT_CAUSE,
-				    mps_trc_intr_info) +
-	      csio_handle_intr_status(hw, MPS_STAT_PERR_INT_CAUSE_SRAM,
-				    mps_stat_sram_intr_info) +
-	      csio_handle_intr_status(hw, MPS_STAT_PERR_INT_CAUSE_TX_FIFO,
-				    mps_stat_tx_intr_info) +
-	      csio_handle_intr_status(hw, MPS_STAT_PERR_INT_CAUSE_RX_FIFO,
-				    mps_stat_rx_intr_info) +
-	      csio_handle_intr_status(hw, MPS_CLS_INT_CAUSE,
-				    mps_cls_intr_info);
-
-	csio_wr_reg32(hw, 0, MPS_INT_CAUSE);
-	csio_rd_reg32(hw, MPS_INT_CAUSE);                    /* flush */
+	fat = csio_handle_intr_status(hw, MPS_RX_PERR_INT_CAUSE_A,
+				      mps_rx_intr_info) +
+	      csio_handle_intr_status(hw, MPS_TX_INT_CAUSE_A,
+				      mps_tx_intr_info) +
+	      csio_handle_intr_status(hw, MPS_TRC_INT_CAUSE_A,
+				      mps_trc_intr_info) +
+	      csio_handle_intr_status(hw, MPS_STAT_PERR_INT_CAUSE_SRAM_A,
+				      mps_stat_sram_intr_info) +
+	      csio_handle_intr_status(hw, MPS_STAT_PERR_INT_CAUSE_TX_FIFO_A,
+				      mps_stat_tx_intr_info) +
+	      csio_handle_intr_status(hw, MPS_STAT_PERR_INT_CAUSE_RX_FIFO_A,
+				      mps_stat_rx_intr_info) +
+	      csio_handle_intr_status(hw, MPS_CLS_INT_CAUSE_A,
+				      mps_cls_intr_info);
+
+	csio_wr_reg32(hw, 0, MPS_INT_CAUSE_A);
+	csio_rd_reg32(hw, MPS_INT_CAUSE_A);                    /* flush */
 	if (fat)
 		csio_hw_fatal_err(hw);
 }
diff --git a/drivers/scsi/csiostor/csio_wr.c b/drivers/scsi/csiostor/csio_wr.c
index 12697c6..e22503b 100644
--- a/drivers/scsi/csiostor/csio_wr.c
+++ b/drivers/scsi/csiostor/csio_wr.c
@@ -1350,8 +1350,8 @@ csio_wr_fixup_host_params(struct csio_hw *hw)
 			   PKTSHIFT_V(PKTSHIFT_M),
 			   PKTSHIFT_V(CSIO_SGE_RX_DMA_OFFSET));
 
-	csio_hw_tp_wr_bits_indirect(hw, TP_INGRESS_CONFIG,
-				    CSUM_HAS_PSEUDO_HDR, 0);
+	csio_hw_tp_wr_bits_indirect(hw, TP_INGRESS_CONFIG_A,
+				    CSUM_HAS_PSEUDO_HDR_F, 0);
 }
 
 static void
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
