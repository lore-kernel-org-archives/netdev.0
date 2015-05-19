From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 1/2] cxgb4: Remove dead function t4_read_edc and t4_read_mc
Date: Tue, 19 May 2015 18:20:43 +0530
Message-ID: <1432039844-23326-2-git-send-email-hariprasad@chelsio.com>
References: <1432039844-23326-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11696 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754268AbbESHi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 03:38:26 -0400
In-Reply-To: <1432039844-23326-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |   4 --
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 110 -----------------------------
 2 files changed, 114 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 932ab3b..7988f5e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1220,10 +1220,6 @@ void t4_read_rss_vf_config(struct adapter *adapter, unsigned int index,
 u32 t4_read_rss_pf_map(struct adapter *adapter);
 u32 t4_read_rss_pf_mask(struct adapter *adapter);
 
-int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
-	       u64 *parity);
-int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
-		u64 *parity);
 unsigned int t4_get_mps_bg_map(struct adapter *adapter, int idx);
 void t4_pmtx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[]);
 void t4_pmrx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[]);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c626252..3bde71b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -333,116 +333,6 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 }
 
 /**
- *	t4_mc_read - read from MC through backdoor accesses
- *	@adap: the adapter
- *	@addr: address of first byte requested
- *	@idx: which MC to access
- *	@data: 64 bytes of data containing the requested address
- *	@ecc: where to store the corresponding 64-bit ECC word
- *
- *	Read 64 bytes of data from MC starting at a 64-byte-aligned address
- *	that covers the requested address @addr.  If @parity is not %NULL it
- *	is assigned the 64-bit ECC word for the read data.
- */
-int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
-{
-	int i;
-	u32 mc_bist_cmd, mc_bist_cmd_addr, mc_bist_cmd_len;
-	u32 mc_bist_status_rdata, mc_bist_data_pattern;
-
-	if (is_t4(adap->params.chip)) {
-		mc_bist_cmd = MC_BIST_CMD_A;
-		mc_bist_cmd_addr = MC_BIST_CMD_ADDR_A;
-		mc_bist_cmd_len = MC_BIST_CMD_LEN_A;
-		mc_bist_status_rdata = MC_BIST_STATUS_RDATA_A;
-		mc_bist_data_pattern = MC_BIST_DATA_PATTERN_A;
-	} else {
-		mc_bist_cmd = MC_REG(MC_P_BIST_CMD_A, idx);
-		mc_bist_cmd_addr = MC_REG(MC_P_BIST_CMD_ADDR_A, idx);
-		mc_bist_cmd_len = MC_REG(MC_P_BIST_CMD_LEN_A, idx);
-		mc_bist_status_rdata = MC_REG(MC_P_BIST_STATUS_RDATA_A, idx);
-		mc_bist_data_pattern = MC_REG(MC_P_BIST_DATA_PATTERN_A, idx);
-	}
-
-	if (t4_read_reg(adap, mc_bist_cmd) & START_BIST_F)
-		return -EBUSY;
-	t4_write_reg(adap, mc_bist_cmd_addr, addr & ~0x3fU);
-	t4_write_reg(adap, mc_bist_cmd_len, 64);
-	t4_write_reg(adap, mc_bist_data_pattern, 0xc);
-	t4_write_reg(adap, mc_bist_cmd, BIST_OPCODE_V(1) | START_BIST_F |
-		     BIST_CMD_GAP_V(1));
-	i = t4_wait_op_done(adap, mc_bist_cmd, START_BIST_F, 0, 10, 1);
-	if (i)
-		return i;
-
-#define MC_DATA(i) MC_BIST_STATUS_REG(mc_bist_status_rdata, i)
-
-	for (i = 15; i >= 0; i--)
-		*data++ = htonl(t4_read_reg(adap, MC_DATA(i)));
-	if (ecc)
-		*ecc = t4_read_reg64(adap, MC_DATA(16));
-#undef MC_DATA
-	return 0;
-}
-
-/**
- *	t4_edc_read - read from EDC through backdoor accesses
- *	@adap: the adapter
- *	@idx: which EDC to access
- *	@addr: address of first byte requested
- *	@data: 64 bytes of data containing the requested address
- *	@ecc: where to store the corresponding 64-bit ECC word
- *
- *	Read 64 bytes of data from EDC starting at a 64-byte-aligned address
- *	that covers the requested address @addr.  If @parity is not %NULL it
- *	is assigned the 64-bit ECC word for the read data.
- */
-int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
-{
-	int i;
-	u32 edc_bist_cmd, edc_bist_cmd_addr, edc_bist_cmd_len;
-	u32 edc_bist_cmd_data_pattern, edc_bist_status_rdata;
-
-	if (is_t4(adap->params.chip)) {
-		edc_bist_cmd = EDC_REG(EDC_BIST_CMD_A, idx);
-		edc_bist_cmd_addr = EDC_REG(EDC_BIST_CMD_ADDR_A, idx);
-		edc_bist_cmd_len = EDC_REG(EDC_BIST_CMD_LEN_A, idx);
-		edc_bist_cmd_data_pattern = EDC_REG(EDC_BIST_DATA_PATTERN_A,
-						    idx);
-		edc_bist_status_rdata = EDC_REG(EDC_BIST_STATUS_RDATA_A,
-						idx);
-	} else {
-		edc_bist_cmd = EDC_REG_T5(EDC_H_BIST_CMD_A, idx);
-		edc_bist_cmd_addr = EDC_REG_T5(EDC_H_BIST_CMD_ADDR_A, idx);
-		edc_bist_cmd_len = EDC_REG_T5(EDC_H_BIST_CMD_LEN_A, idx);
-		edc_bist_cmd_data_pattern =
-			EDC_REG_T5(EDC_H_BIST_DATA_PATTERN_A, idx);
-		edc_bist_status_rdata =
-			 EDC_REG_T5(EDC_H_BIST_STATUS_RDATA_A, idx);
-	}
-
-	if (t4_read_reg(adap, edc_bist_cmd) & START_BIST_F)
-		return -EBUSY;
-	t4_write_reg(adap, edc_bist_cmd_addr, addr & ~0x3fU);
-	t4_write_reg(adap, edc_bist_cmd_len, 64);
-	t4_write_reg(adap, edc_bist_cmd_data_pattern, 0xc);
-	t4_write_reg(adap, edc_bist_cmd,
-		     BIST_OPCODE_V(1) | BIST_CMD_GAP_V(1) | START_BIST_F);
-	i = t4_wait_op_done(adap, edc_bist_cmd, START_BIST_F, 0, 10, 1);
-	if (i)
-		return i;
-
-#define EDC_DATA(i) (EDC_BIST_STATUS_REG(edc_bist_status_rdata, i))
-
-	for (i = 15; i >= 0; i--)
-		*data++ = htonl(t4_read_reg(adap, EDC_DATA(i)));
-	if (ecc)
-		*ecc = t4_read_reg64(adap, EDC_DATA(16));
-#undef EDC_DATA
-	return 0;
-}
-
-/**
  *	t4_memory_rw - read/write EDC 0, EDC 1 or MC via PCIE memory window
  *	@adap: the adapter
  *	@win: PCI-E Memory Window to use
-- 
2.3.4
