From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 2/2] cxgb4: replace ntoh{s,l} and hton{s,l} calls with the generic byteorder
Date: Tue, 19 May 2015 18:20:44 +0530
Message-ID: <1432039844-23326-3-git-send-email-hariprasad@chelsio.com>
References: <1432039844-23326-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6557 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754281AbbESHib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 03:38:31 -0400
In-Reply-To: <1432039844-23326-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace ntoh{s,l} and hton{s,l} calls with the generic byteorder in
cxgb4/t4_hw.c file

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 399 ++++++++++++++++-------------
 1 file changed, 217 insertions(+), 182 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 3bde71b..cd23db5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -214,8 +214,8 @@ static void fw_asrt(struct adapter *adap, u32 mbox_addr)
 	get_mbox_rpl(adap, (__be64 *)&asrt, sizeof(asrt) / 8, mbox_addr);
 	dev_alert(adap->pdev_dev,
 		  "FW assertion at %.16s:%u, val0 %#x, val1 %#x\n",
-		  asrt.u.assert.filename_0_7, ntohl(asrt.u.assert.line),
-		  ntohl(asrt.u.assert.x), ntohl(asrt.u.assert.y));
+		  asrt.u.assert.filename_0_7, be32_to_cpu(asrt.u.assert.line),
+		  be32_to_cpu(asrt.u.assert.x), be32_to_cpu(asrt.u.assert.y));
 }
 
 static void dump_mbox(struct adapter *adap, int mbox, u32 data_reg)
@@ -1508,7 +1508,7 @@ int t4_read_flash(struct adapter *adapter, unsigned int addr,
 		if (ret)
 			return ret;
 		if (byte_oriented)
-			*data = (__force __u32) (htonl(*data));
+			*data = (__force __u32)(cpu_to_be32(*data));
 	}
 	return 0;
 }
@@ -1869,7 +1869,7 @@ int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
 			"FW image size not multiple of 512 bytes\n");
 		return -EINVAL;
 	}
-	if (ntohs(hdr->len512) * 512 != size) {
+	if ((unsigned int)be16_to_cpu(hdr->len512) * 512 != size) {
 		dev_err(adap->pdev_dev,
 			"FW image size differs from size in FW header\n");
 		return -EINVAL;
@@ -1883,7 +1883,7 @@ int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
 		return -EINVAL;
 
 	for (csum = 0, i = 0; i < size / sizeof(csum); i++)
-		csum += ntohl(p[i]);
+		csum += be32_to_cpu(p[i]);
 
 	if (csum != 0xffffffff) {
 		dev_err(adap->pdev_dev,
@@ -1902,7 +1902,7 @@ int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
 	 * first page with a bad version.
 	 */
 	memcpy(first_page, fw_data, SF_PAGE_SIZE);
-	((struct fw_hdr *)first_page)->fw_ver = htonl(0xffffffff);
+	((struct fw_hdr *)first_page)->fw_ver = cpu_to_be32(0xffffffff);
 	ret = t4_write_flash(adap, fw_img_start, SF_PAGE_SIZE, first_page);
 	if (ret)
 		goto out;
@@ -1997,19 +1997,22 @@ int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
 		fc |= FW_PORT_CAP_FC_TX;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) | FW_CMD_REQUEST_F |
-			       FW_CMD_EXEC_F | FW_PORT_CMD_PORTID_V(port));
-	c.action_to_len16 = htonl(FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_L1_CFG) |
-				  FW_LEN16(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
+				     FW_CMD_REQUEST_F | FW_CMD_EXEC_F |
+				     FW_PORT_CMD_PORTID_V(port));
+	c.action_to_len16 =
+		cpu_to_be32(FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_L1_CFG) |
+			    FW_LEN16(c));
 
 	if (!(lc->supported & FW_PORT_CAP_ANEG)) {
-		c.u.l1cfg.rcap = htonl((lc->supported & ADVERT_MASK) | fc);
+		c.u.l1cfg.rcap = cpu_to_be32((lc->supported & ADVERT_MASK) |
+					     fc);
 		lc->fc = lc->requested_fc & (PAUSE_RX | PAUSE_TX);
 	} else if (lc->autoneg == AUTONEG_DISABLE) {
-		c.u.l1cfg.rcap = htonl(lc->requested_speed | fc | mdi);
+		c.u.l1cfg.rcap = cpu_to_be32(lc->requested_speed | fc | mdi);
 		lc->fc = lc->requested_fc & (PAUSE_RX | PAUSE_TX);
 	} else
-		c.u.l1cfg.rcap = htonl(lc->advertising | fc | mdi);
+		c.u.l1cfg.rcap = cpu_to_be32(lc->advertising | fc | mdi);
 
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
@@ -2027,11 +2030,13 @@ int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port)
 	struct fw_port_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) | FW_CMD_REQUEST_F |
-			       FW_CMD_EXEC_F | FW_PORT_CMD_PORTID_V(port));
-	c.action_to_len16 = htonl(FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_L1_CFG) |
-				  FW_LEN16(c));
-	c.u.l1cfg.rcap = htonl(FW_PORT_CAP_ANEG);
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
+				     FW_CMD_REQUEST_F | FW_CMD_EXEC_F |
+				     FW_PORT_CMD_PORTID_V(port));
+	c.action_to_len16 =
+		cpu_to_be32(FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_L1_CFG) |
+			    FW_LEN16(c));
+	c.u.l1cfg.rcap = cpu_to_be32(FW_PORT_CAP_ANEG);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -2835,18 +2840,18 @@ int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
 	struct fw_rss_ind_tbl_cmd cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = htonl(FW_CMD_OP_V(FW_RSS_IND_TBL_CMD) |
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_RSS_IND_TBL_CMD) |
 			       FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
 			       FW_RSS_IND_TBL_CMD_VIID_V(viid));
-	cmd.retval_len16 = htonl(FW_LEN16(cmd));
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 
 	/* each fw_rss_ind_tbl_cmd takes up to 32 entries */
 	while (n > 0) {
 		int nq = min(n, 32);
 		__be32 *qp = &cmd.iq0_to_iq2;
 
-		cmd.niqid = htons(nq);
-		cmd.startidx = htons(start);
+		cmd.niqid = cpu_to_be16(nq);
+		cmd.startidx = cpu_to_be16(start);
 
 		start += nq;
 		n -= nq;
@@ -2864,7 +2869,7 @@ int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
 			if (++rsp >= rsp_end)
 				rsp = rspq;
 
-			*qp++ = htonl(v);
+			*qp++ = cpu_to_be32(v);
 			nq -= 3;
 		}
 
@@ -2890,15 +2895,16 @@ int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
 	struct fw_rss_glb_config_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_write = htonl(FW_CMD_OP_V(FW_RSS_GLB_CONFIG_CMD) |
-			      FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
-	c.retval_len16 = htonl(FW_LEN16(c));
+	c.op_to_write = cpu_to_be32(FW_CMD_OP_V(FW_RSS_GLB_CONFIG_CMD) |
+				    FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
+	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
 	if (mode == FW_RSS_GLB_CONFIG_CMD_MODE_MANUAL) {
-		c.u.manual.mode_pkd = htonl(FW_RSS_GLB_CONFIG_CMD_MODE_V(mode));
+		c.u.manual.mode_pkd =
+			cpu_to_be32(FW_RSS_GLB_CONFIG_CMD_MODE_V(mode));
 	} else if (mode == FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL) {
 		c.u.basicvirtual.mode_pkd =
-			htonl(FW_RSS_GLB_CONFIG_CMD_MODE_V(mode));
-		c.u.basicvirtual.synmapen_to_hashtoeplitz = htonl(flags);
+			cpu_to_be32(FW_RSS_GLB_CONFIG_CMD_MODE_V(mode));
+		c.u.basicvirtual.synmapen_to_hashtoeplitz = cpu_to_be32(flags);
 	} else
 		return -EINVAL;
 	return t4_wr_mbox(adapter, mbox, &c, sizeof(c), NULL);
@@ -3559,33 +3565,38 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 void t4_mk_filtdelwr(unsigned int ftid, struct fw_filter_wr *wr, int qid)
 {
 	memset(wr, 0, sizeof(*wr));
-	wr->op_pkd = htonl(FW_WR_OP_V(FW_FILTER_WR));
-	wr->len16_pkd = htonl(FW_WR_LEN16_V(sizeof(*wr) / 16));
-	wr->tid_to_iq = htonl(FW_FILTER_WR_TID_V(ftid) |
-			FW_FILTER_WR_NOREPLY_V(qid < 0));
-	wr->del_filter_to_l2tix = htonl(FW_FILTER_WR_DEL_FILTER_F);
+	wr->op_pkd = cpu_to_be32(FW_WR_OP_V(FW_FILTER_WR));
+	wr->len16_pkd = cpu_to_be32(FW_WR_LEN16_V(sizeof(*wr) / 16));
+	wr->tid_to_iq = cpu_to_be32(FW_FILTER_WR_TID_V(ftid) |
+				    FW_FILTER_WR_NOREPLY_V(qid < 0));
+	wr->del_filter_to_l2tix = cpu_to_be32(FW_FILTER_WR_DEL_FILTER_F);
 	if (qid >= 0)
-		wr->rx_chan_rx_rpl_iq = htons(FW_FILTER_WR_RX_RPL_IQ_V(qid));
+		wr->rx_chan_rx_rpl_iq =
+			cpu_to_be16(FW_FILTER_WR_RX_RPL_IQ_V(qid));
 }
 
 #define INIT_CMD(var, cmd, rd_wr) do { \
-	(var).op_to_write = htonl(FW_CMD_OP_V(FW_##cmd##_CMD) | \
-				  FW_CMD_REQUEST_F | FW_CMD_##rd_wr##_F); \
-	(var).retval_len16 = htonl(FW_LEN16(var)); \
+	(var).op_to_write = cpu_to_be32(FW_CMD_OP_V(FW_##cmd##_CMD) | \
+					FW_CMD_REQUEST_F | \
+					FW_CMD_##rd_wr##_F); \
+	(var).retval_len16 = cpu_to_be32(FW_LEN16(var)); \
 } while (0)
 
 int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
 			  u32 addr, u32 val)
 {
+	u32 ldst_addrspace;
 	struct fw_ldst_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_WRITE_F |
-			    FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_FIRMWARE));
-	c.cycles_to_len16 = htonl(FW_LEN16(c));
-	c.u.addrval.addr = htonl(addr);
-	c.u.addrval.val = htonl(val);
+	ldst_addrspace = FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_FIRMWARE);
+	c.op_to_addrspace = cpu_to_be32(FW_CMD_OP_V(FW_LDST_CMD) |
+					FW_CMD_REQUEST_F |
+					FW_CMD_WRITE_F |
+					ldst_addrspace);
+	c.cycles_to_len16 = cpu_to_be32(FW_LEN16(c));
+	c.u.addrval.addr = cpu_to_be32(addr);
+	c.u.addrval.val = cpu_to_be32(val);
 
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
@@ -3605,19 +3616,22 @@ int t4_mdio_rd(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 	       unsigned int mmd, unsigned int reg, u16 *valp)
 {
 	int ret;
+	u32 ldst_addrspace;
 	struct fw_ldst_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
-		FW_CMD_READ_F | FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_MDIO));
-	c.cycles_to_len16 = htonl(FW_LEN16(c));
-	c.u.mdio.paddr_mmd = htons(FW_LDST_CMD_PADDR_V(phy_addr) |
-				   FW_LDST_CMD_MMD_V(mmd));
-	c.u.mdio.raddr = htons(reg);
+	ldst_addrspace = FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_MDIO);
+	c.op_to_addrspace = cpu_to_be32(FW_CMD_OP_V(FW_LDST_CMD) |
+					FW_CMD_REQUEST_F | FW_CMD_READ_F |
+					ldst_addrspace);
+	c.cycles_to_len16 = cpu_to_be32(FW_LEN16(c));
+	c.u.mdio.paddr_mmd = cpu_to_be16(FW_LDST_CMD_PADDR_V(phy_addr) |
+					 FW_LDST_CMD_MMD_V(mmd));
+	c.u.mdio.raddr = cpu_to_be16(reg);
 
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 	if (ret == 0)
-		*valp = ntohs(c.u.mdio.rval);
+		*valp = be16_to_cpu(c.u.mdio.rval);
 	return ret;
 }
 
@@ -3635,16 +3649,19 @@ int t4_mdio_rd(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 int t4_mdio_wr(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 	       unsigned int mmd, unsigned int reg, u16 val)
 {
+	u32 ldst_addrspace;
 	struct fw_ldst_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
-		FW_CMD_WRITE_F | FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_MDIO));
-	c.cycles_to_len16 = htonl(FW_LEN16(c));
-	c.u.mdio.paddr_mmd = htons(FW_LDST_CMD_PADDR_V(phy_addr) |
-				   FW_LDST_CMD_MMD_V(mmd));
-	c.u.mdio.raddr = htons(reg);
-	c.u.mdio.rval = htons(val);
+	ldst_addrspace = FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_MDIO);
+	c.op_to_addrspace = cpu_to_be32(FW_CMD_OP_V(FW_LDST_CMD) |
+					FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+					ldst_addrspace);
+	c.cycles_to_len16 = cpu_to_be32(FW_LEN16(c));
+	c.u.mdio.paddr_mmd = cpu_to_be16(FW_LDST_CMD_PADDR_V(phy_addr) |
+					 FW_LDST_CMD_MMD_V(mmd));
+	c.u.mdio.raddr = cpu_to_be16(reg);
+	c.u.mdio.rval = cpu_to_be16(val);
 
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
@@ -3778,11 +3795,11 @@ int t4_fw_hello(struct adapter *adap, unsigned int mbox, unsigned int evt_mbox,
 retry:
 	memset(&c, 0, sizeof(c));
 	INIT_CMD(c, HELLO, WRITE);
-	c.err_to_clearinit = htonl(
+	c.err_to_clearinit = cpu_to_be32(
 		FW_HELLO_CMD_MASTERDIS_V(master == MASTER_CANT) |
 		FW_HELLO_CMD_MASTERFORCE_V(master == MASTER_MUST) |
-		FW_HELLO_CMD_MBMASTER_V(master == MASTER_MUST ? mbox :
-				      FW_HELLO_CMD_MBMASTER_M) |
+		FW_HELLO_CMD_MBMASTER_V(master == MASTER_MUST ?
+					mbox : FW_HELLO_CMD_MBMASTER_M) |
 		FW_HELLO_CMD_MBASYNCNOT_V(evt_mbox) |
 		FW_HELLO_CMD_STAGE_V(fw_hello_cmd_stage_os) |
 		FW_HELLO_CMD_CLEARINIT_F);
@@ -3803,7 +3820,7 @@ retry:
 		return ret;
 	}
 
-	v = ntohl(c.err_to_clearinit);
+	v = be32_to_cpu(c.err_to_clearinit);
 	master_mbox = FW_HELLO_CMD_MBMASTER_G(v);
 	if (state) {
 		if (v & FW_HELLO_CMD_ERR_F)
@@ -3932,7 +3949,7 @@ int t4_fw_reset(struct adapter *adap, unsigned int mbox, int reset)
 
 	memset(&c, 0, sizeof(c));
 	INIT_CMD(c, RESET, WRITE);
-	c.val = htonl(reset);
+	c.val = cpu_to_be32(reset);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -3965,8 +3982,8 @@ static int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force)
 
 		memset(&c, 0, sizeof(c));
 		INIT_CMD(c, RESET, WRITE);
-		c.val = htonl(PIORST_F | PIORSTMODE_F);
-		c.halt_pkd = htonl(FW_RESET_CMD_HALT_F);
+		c.val = cpu_to_be32(PIORST_F | PIORSTMODE_F);
+		c.halt_pkd = cpu_to_be32(FW_RESET_CMD_HALT_F);
 		ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 	}
 
@@ -4105,7 +4122,7 @@ int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 	 * the newly loaded firmware will handle this right by checking
 	 * its header flags to see if it advertises the capability.
 	 */
-	reset = ((ntohl(fw_hdr->flags) & FW_HDR_FLAGS_RESET_HALT) == 0);
+	reset = ((be32_to_cpu(fw_hdr->flags) & FW_HDR_FLAGS_RESET_HALT) == 0);
 	return t4_fw_restart(adap, mbox, reset);
 }
 
@@ -4260,17 +4277,19 @@ int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		return -EINVAL;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PARAMS_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_READ_F | FW_PARAMS_CMD_PFN_V(pf) |
-			    FW_PARAMS_CMD_VFN_V(vf));
-	c.retval_len16 = htonl(FW_LEN16(c));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
+				  FW_CMD_REQUEST_F | FW_CMD_READ_F |
+				  FW_PARAMS_CMD_PFN_V(pf) |
+				  FW_PARAMS_CMD_VFN_V(vf));
+	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
+
 	for (i = 0; i < nparams; i++, p += 2)
-		*p = htonl(*params++);
+		*p = cpu_to_be32(*params++);
 
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 	if (ret == 0)
 		for (i = 0, p = &c.param[0].val; i < nparams; i++, p += 2)
-			*val++ = ntohl(*p);
+			*val++ = be32_to_cpu(*p);
 	return ret;
 }
 
@@ -4338,13 +4357,14 @@ int t4_set_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		return -EINVAL;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PARAMS_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_WRITE_F | FW_PARAMS_CMD_PFN_V(pf) |
-			    FW_PARAMS_CMD_VFN_V(vf));
-	c.retval_len16 = htonl(FW_LEN16(c));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
+				  FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+				  FW_PARAMS_CMD_PFN_V(pf) |
+				  FW_PARAMS_CMD_VFN_V(vf));
+	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
 	while (nparams--) {
-		*p++ = htonl(*params++);
-		*p++ = htonl(*val++);
+		*p++ = cpu_to_be32(*params++);
+		*p++ = cpu_to_be32(*val++);
 	}
 
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
@@ -4380,20 +4400,21 @@ int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_pfvf_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PFVF_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_WRITE_F | FW_PFVF_CMD_PFN_V(pf) |
-			    FW_PFVF_CMD_VFN_V(vf));
-	c.retval_len16 = htonl(FW_LEN16(c));
-	c.niqflint_niq = htonl(FW_PFVF_CMD_NIQFLINT_V(rxqi) |
-			       FW_PFVF_CMD_NIQ_V(rxq));
-	c.type_to_neq = htonl(FW_PFVF_CMD_CMASK_V(cmask) |
-			       FW_PFVF_CMD_PMASK_V(pmask) |
-			       FW_PFVF_CMD_NEQ_V(txq));
-	c.tc_to_nexactf = htonl(FW_PFVF_CMD_TC_V(tc) | FW_PFVF_CMD_NVI_V(vi) |
-				FW_PFVF_CMD_NEXACTF_V(nexact));
-	c.r_caps_to_nethctrl = htonl(FW_PFVF_CMD_R_CAPS_V(rcaps) |
-				     FW_PFVF_CMD_WX_CAPS_V(wxcaps) |
-				     FW_PFVF_CMD_NETHCTRL_V(txq_eth_ctrl));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PFVF_CMD) | FW_CMD_REQUEST_F |
+				  FW_CMD_WRITE_F | FW_PFVF_CMD_PFN_V(pf) |
+				  FW_PFVF_CMD_VFN_V(vf));
+	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
+	c.niqflint_niq = cpu_to_be32(FW_PFVF_CMD_NIQFLINT_V(rxqi) |
+				     FW_PFVF_CMD_NIQ_V(rxq));
+	c.type_to_neq = cpu_to_be32(FW_PFVF_CMD_CMASK_V(cmask) |
+				    FW_PFVF_CMD_PMASK_V(pmask) |
+				    FW_PFVF_CMD_NEQ_V(txq));
+	c.tc_to_nexactf = cpu_to_be32(FW_PFVF_CMD_TC_V(tc) |
+				      FW_PFVF_CMD_NVI_V(vi) |
+				      FW_PFVF_CMD_NEXACTF_V(nexact));
+	c.r_caps_to_nethctrl = cpu_to_be32(FW_PFVF_CMD_R_CAPS_V(rcaps) |
+					FW_PFVF_CMD_WX_CAPS_V(wxcaps) |
+					FW_PFVF_CMD_NETHCTRL_V(txq_eth_ctrl));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -4422,10 +4443,10 @@ int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 	struct fw_vi_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_VI_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_VI_CMD_PFN_V(pf) | FW_VI_CMD_VFN_V(vf));
-	c.alloc_to_len16 = htonl(FW_VI_CMD_ALLOC_F | FW_LEN16(c));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_VI_CMD) | FW_CMD_REQUEST_F |
+				  FW_CMD_WRITE_F | FW_CMD_EXEC_F |
+				  FW_VI_CMD_PFN_V(pf) | FW_VI_CMD_VFN_V(vf));
+	c.alloc_to_len16 = cpu_to_be32(FW_VI_CMD_ALLOC_F | FW_LEN16(c));
 	c.portid_pkd = FW_VI_CMD_PORTID_V(port);
 	c.nmac = nmac - 1;
 
@@ -4447,8 +4468,8 @@ int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 		}
 	}
 	if (rss_size)
-		*rss_size = FW_VI_CMD_RSSSIZE_G(ntohs(c.rsssize_pkd));
-	return FW_VI_CMD_VIID_G(ntohs(c.type_viid));
+		*rss_size = FW_VI_CMD_RSSSIZE_G(be16_to_cpu(c.rsssize_pkd));
+	return FW_VI_CMD_VIID_G(be16_to_cpu(c.type_viid));
 }
 
 /**
@@ -4484,14 +4505,16 @@ int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
 		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_M;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_RXMODE_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_WRITE_F | FW_VI_RXMODE_CMD_VIID_V(viid));
-	c.retval_len16 = htonl(FW_LEN16(c));
-	c.mtu_to_vlanexen = htonl(FW_VI_RXMODE_CMD_MTU_V(mtu) |
-				  FW_VI_RXMODE_CMD_PROMISCEN_V(promisc) |
-				  FW_VI_RXMODE_CMD_ALLMULTIEN_V(all_multi) |
-				  FW_VI_RXMODE_CMD_BROADCASTEN_V(bcast) |
-				  FW_VI_RXMODE_CMD_VLANEXEN_V(vlanex));
+	c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_RXMODE_CMD) |
+				   FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+				   FW_VI_RXMODE_CMD_VIID_V(viid));
+	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
+	c.mtu_to_vlanexen =
+		cpu_to_be32(FW_VI_RXMODE_CMD_MTU_V(mtu) |
+			    FW_VI_RXMODE_CMD_PROMISCEN_V(promisc) |
+			    FW_VI_RXMODE_CMD_ALLMULTIEN_V(all_multi) |
+			    FW_VI_RXMODE_CMD_BROADCASTEN_V(bcast) |
+			    FW_VI_RXMODE_CMD_VLANEXEN_V(vlanex));
 	return t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), NULL, sleep_ok);
 }
 
@@ -4532,15 +4555,17 @@ int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 		return -EINVAL;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_WRITE_F | (free ? FW_CMD_EXEC_F : 0) |
-			     FW_VI_MAC_CMD_VIID_V(viid));
-	c.freemacs_to_len16 = htonl(FW_VI_MAC_CMD_FREEMACS_V(free) |
-				    FW_CMD_LEN16_V((naddr + 2) / 2));
+	c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+				   FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+				   (free ? FW_CMD_EXEC_F : 0) |
+				   FW_VI_MAC_CMD_VIID_V(viid));
+	c.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_FREEMACS_V(free) |
+					  FW_CMD_LEN16_V((naddr + 2) / 2));
 
 	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
-		p->valid_to_idx = htons(FW_VI_MAC_CMD_VALID_F |
-				      FW_VI_MAC_CMD_IDX_V(FW_VI_MAC_ADD_MAC));
+		p->valid_to_idx =
+			cpu_to_be16(FW_VI_MAC_CMD_VALID_F |
+				    FW_VI_MAC_CMD_IDX_V(FW_VI_MAC_ADD_MAC));
 		memcpy(p->macaddr, addr[i], sizeof(p->macaddr));
 	}
 
@@ -4549,7 +4574,7 @@ int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 		return ret;
 
 	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
-		u16 index = FW_VI_MAC_CMD_IDX_G(ntohs(p->valid_to_idx));
+		u16 index = FW_VI_MAC_CMD_IDX_G(be16_to_cpu(p->valid_to_idx));
 
 		if (idx)
 			idx[i] = index >= max_naddr ? 0xffff : index;
@@ -4595,17 +4620,18 @@ int t4_change_mac(struct adapter *adap, unsigned int mbox, unsigned int viid,
 	mode = add_smt ? FW_VI_MAC_SMT_AND_MPSTCAM : FW_VI_MAC_MPS_TCAM_ENTRY;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_WRITE_F | FW_VI_MAC_CMD_VIID_V(viid));
-	c.freemacs_to_len16 = htonl(FW_CMD_LEN16_V(1));
-	p->valid_to_idx = htons(FW_VI_MAC_CMD_VALID_F |
-				FW_VI_MAC_CMD_SMAC_RESULT_V(mode) |
-				FW_VI_MAC_CMD_IDX_V(idx));
+	c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+				   FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+				   FW_VI_MAC_CMD_VIID_V(viid));
+	c.freemacs_to_len16 = cpu_to_be32(FW_CMD_LEN16_V(1));
+	p->valid_to_idx = cpu_to_be16(FW_VI_MAC_CMD_VALID_F |
+				      FW_VI_MAC_CMD_SMAC_RESULT_V(mode) |
+				      FW_VI_MAC_CMD_IDX_V(idx));
 	memcpy(p->macaddr, addr, sizeof(p->macaddr));
 
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 	if (ret == 0) {
-		ret = FW_VI_MAC_CMD_IDX_G(ntohs(p->valid_to_idx));
+		ret = FW_VI_MAC_CMD_IDX_G(be16_to_cpu(p->valid_to_idx));
 		if (ret >= max_mac_addr)
 			ret = -ENOMEM;
 	}
@@ -4629,11 +4655,12 @@ int t4_set_addr_hash(struct adapter *adap, unsigned int mbox, unsigned int viid,
 	struct fw_vi_mac_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_WRITE_F | FW_VI_ENABLE_CMD_VIID_V(viid));
-	c.freemacs_to_len16 = htonl(FW_VI_MAC_CMD_HASHVECEN_F |
-				    FW_VI_MAC_CMD_HASHUNIEN_V(ucast) |
-				    FW_CMD_LEN16_V(1));
+	c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+				   FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+				   FW_VI_ENABLE_CMD_VIID_V(viid));
+	c.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_HASHVECEN_F |
+					  FW_VI_MAC_CMD_HASHUNIEN_V(ucast) |
+					  FW_CMD_LEN16_V(1));
 	c.u.hash.hashvec = cpu_to_be64(vec);
 	return t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), NULL, sleep_ok);
 }
@@ -4656,12 +4683,13 @@ int t4_enable_vi_params(struct adapter *adap, unsigned int mbox,
 	struct fw_vi_enable_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_EXEC_F | FW_VI_ENABLE_CMD_VIID_V(viid));
-
-	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_IEN_V(rx_en) |
-			       FW_VI_ENABLE_CMD_EEN_V(tx_en) | FW_LEN16(c) |
-			       FW_VI_ENABLE_CMD_DCB_INFO_V(dcb_en));
+	c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_ENABLE_CMD) |
+				   FW_CMD_REQUEST_F | FW_CMD_EXEC_F |
+				   FW_VI_ENABLE_CMD_VIID_V(viid));
+	c.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_IEN_V(rx_en) |
+				     FW_VI_ENABLE_CMD_EEN_V(tx_en) |
+				     FW_VI_ENABLE_CMD_DCB_INFO_V(dcb_en) |
+				     FW_LEN16(c));
 	return t4_wr_mbox_ns(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -4696,10 +4724,11 @@ int t4_identify_port(struct adapter *adap, unsigned int mbox, unsigned int viid,
 	struct fw_vi_enable_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_EXEC_F | FW_VI_ENABLE_CMD_VIID_V(viid));
-	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_LED_F | FW_LEN16(c));
-	c.blinkdur = htons(nblinks);
+	c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_ENABLE_CMD) |
+				   FW_CMD_REQUEST_F | FW_CMD_EXEC_F |
+				   FW_VI_ENABLE_CMD_VIID_V(viid));
+	c.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_LED_F | FW_LEN16(c));
+	c.blinkdur = cpu_to_be16(nblinks);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -4723,14 +4752,14 @@ int t4_iq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_iq_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_EXEC_F | FW_IQ_CMD_PFN_V(pf) |
-			    FW_IQ_CMD_VFN_V(vf));
-	c.alloc_to_len16 = htonl(FW_IQ_CMD_FREE_F | FW_LEN16(c));
-	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE_V(iqtype));
-	c.iqid = htons(iqid);
-	c.fl0id = htons(fl0id);
-	c.fl1id = htons(fl1id);
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_IQ_CMD) | FW_CMD_REQUEST_F |
+				  FW_CMD_EXEC_F | FW_IQ_CMD_PFN_V(pf) |
+				  FW_IQ_CMD_VFN_V(vf));
+	c.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_FREE_F | FW_LEN16(c));
+	c.type_to_iqandstindex = cpu_to_be32(FW_IQ_CMD_TYPE_V(iqtype));
+	c.iqid = cpu_to_be16(iqid);
+	c.fl0id = cpu_to_be16(fl0id);
+	c.fl1id = cpu_to_be16(fl1id);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -4750,11 +4779,12 @@ int t4_eth_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_eq_eth_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_ETH_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_EXEC_F | FW_EQ_ETH_CMD_PFN_V(pf) |
-			    FW_EQ_ETH_CMD_VFN_V(vf));
-	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_FREE_F | FW_LEN16(c));
-	c.eqid_pkd = htonl(FW_EQ_ETH_CMD_EQID_V(eqid));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_EQ_ETH_CMD) |
+				  FW_CMD_REQUEST_F | FW_CMD_EXEC_F |
+				  FW_EQ_ETH_CMD_PFN_V(pf) |
+				  FW_EQ_ETH_CMD_VFN_V(vf));
+	c.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_FREE_F | FW_LEN16(c));
+	c.eqid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_EQID_V(eqid));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -4774,11 +4804,12 @@ int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_eq_ctrl_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_EXEC_F | FW_EQ_CTRL_CMD_PFN_V(pf) |
-			    FW_EQ_CTRL_CMD_VFN_V(vf));
-	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_FREE_F | FW_LEN16(c));
-	c.cmpliqid_eqid = htonl(FW_EQ_CTRL_CMD_EQID_V(eqid));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_EQ_CTRL_CMD) |
+				  FW_CMD_REQUEST_F | FW_CMD_EXEC_F |
+				  FW_EQ_CTRL_CMD_PFN_V(pf) |
+				  FW_EQ_CTRL_CMD_VFN_V(vf));
+	c.alloc_to_len16 = cpu_to_be32(FW_EQ_CTRL_CMD_FREE_F | FW_LEN16(c));
+	c.cmpliqid_eqid = cpu_to_be32(FW_EQ_CTRL_CMD_EQID_V(eqid));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -4798,11 +4829,12 @@ int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	struct fw_eq_ofld_cmd c;
 
 	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_EXEC_F | FW_EQ_OFLD_CMD_PFN_V(pf) |
-			    FW_EQ_OFLD_CMD_VFN_V(vf));
-	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_FREE_F | FW_LEN16(c));
-	c.eqid_pkd = htonl(FW_EQ_OFLD_CMD_EQID_V(eqid));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_EQ_OFLD_CMD) |
+				  FW_CMD_REQUEST_F | FW_CMD_EXEC_F |
+				  FW_EQ_OFLD_CMD_PFN_V(pf) |
+				  FW_EQ_OFLD_CMD_VFN_V(vf));
+	c.alloc_to_len16 = cpu_to_be32(FW_EQ_OFLD_CMD_FREE_F | FW_LEN16(c));
+	c.eqid_pkd = cpu_to_be32(FW_EQ_OFLD_CMD_EQID_V(eqid));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -4820,11 +4852,11 @@ int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl)
 	if (opcode == FW_PORT_CMD) {    /* link/module state change message */
 		int speed = 0, fc = 0;
 		const struct fw_port_cmd *p = (void *)rpl;
-		int chan = FW_PORT_CMD_PORTID_G(ntohl(p->op_to_portid));
+		int chan = FW_PORT_CMD_PORTID_G(be32_to_cpu(p->op_to_portid));
 		int port = adap->chan_map[chan];
 		struct port_info *pi = adap2pinfo(adap, port);
 		struct link_config *lc = &pi->link_cfg;
-		u32 stat = ntohl(p->u.info.lstatus_to_modtype);
+		u32 stat = be32_to_cpu(p->u.info.lstatus_to_modtype);
 		int link_ok = (stat & FW_PORT_CMD_LSTATUS_F) != 0;
 		u32 mod = FW_PORT_CMD_MODTYPE_G(stat);
 
@@ -5138,18 +5170,19 @@ int t4_init_devlog_params(struct adapter *adap)
 	/* Otherwise, ask the firmware for it's Device Log Parameters.
 	 */
 	memset(&devlog_cmd, 0, sizeof(devlog_cmd));
-	devlog_cmd.op_to_write = htonl(FW_CMD_OP_V(FW_DEVLOG_CMD) |
-				       FW_CMD_REQUEST_F | FW_CMD_READ_F);
-	devlog_cmd.retval_len16 = htonl(FW_LEN16(devlog_cmd));
+	devlog_cmd.op_to_write = cpu_to_be32(FW_CMD_OP_V(FW_DEVLOG_CMD) |
+					     FW_CMD_REQUEST_F | FW_CMD_READ_F);
+	devlog_cmd.retval_len16 = cpu_to_be32(FW_LEN16(devlog_cmd));
 	ret = t4_wr_mbox(adap, adap->mbox, &devlog_cmd, sizeof(devlog_cmd),
 			 &devlog_cmd);
 	if (ret)
 		return ret;
 
-	devlog_meminfo = ntohl(devlog_cmd.memtype_devlog_memaddr16_devlog);
+	devlog_meminfo =
+		be32_to_cpu(devlog_cmd.memtype_devlog_memaddr16_devlog);
 	dparams->memtype = FW_DEVLOG_CMD_MEMTYPE_DEVLOG_G(devlog_meminfo);
 	dparams->start = FW_DEVLOG_CMD_MEMADDR16_DEVLOG_G(devlog_meminfo) << 4;
-	dparams->size = ntohl(devlog_cmd.memsize_devlog);
+	dparams->size = be32_to_cpu(devlog_cmd.memsize_devlog);
 
 	return 0;
 }
@@ -5298,14 +5331,15 @@ int t4_init_rss_mode(struct adapter *adap, int mbox)
 	for_each_port(adap, i) {
 		struct port_info *p = adap2pinfo(adap, i);
 
-		rvc.op_to_viid = htonl(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
-				       FW_CMD_REQUEST_F | FW_CMD_READ_F |
-				       FW_RSS_VI_CONFIG_CMD_VIID_V(p->viid));
-		rvc.retval_len16 = htonl(FW_LEN16(rvc));
+		rvc.op_to_viid =
+			cpu_to_be32(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
+				    FW_CMD_REQUEST_F | FW_CMD_READ_F |
+				    FW_RSS_VI_CONFIG_CMD_VIID_V(p->viid));
+		rvc.retval_len16 = cpu_to_be32(FW_LEN16(rvc));
 		ret = t4_wr_mbox(adap, mbox, &rvc, sizeof(rvc), &rvc);
 		if (ret)
 			return ret;
-		p->rss_mode = ntohl(rvc.u.basicvirtual.defaultq_to_udpen);
+		p->rss_mode = be32_to_cpu(rvc.u.basicvirtual.defaultq_to_udpen);
 	}
 	return 0;
 }
@@ -5327,10 +5361,10 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		while ((adap->params.portvec & (1 << j)) == 0)
 			j++;
 
-		c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) |
-				       FW_CMD_REQUEST_F | FW_CMD_READ_F |
-				       FW_PORT_CMD_PORTID_V(j));
-		c.action_to_len16 = htonl(
+		c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
+					     FW_CMD_REQUEST_F | FW_CMD_READ_F |
+					     FW_PORT_CMD_PORTID_V(j));
+		c.action_to_len16 = cpu_to_be32(
 			FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_GET_PORT_INFO) |
 			FW_LEN16(c));
 		ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
@@ -5348,22 +5382,23 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		memcpy(adap->port[i]->dev_addr, addr, ETH_ALEN);
 		adap->port[i]->dev_port = j;
 
-		ret = ntohl(c.u.info.lstatus_to_modtype);
+		ret = be32_to_cpu(c.u.info.lstatus_to_modtype);
 		p->mdio_addr = (ret & FW_PORT_CMD_MDIOCAP_F) ?
 			FW_PORT_CMD_MDIOADDR_G(ret) : -1;
 		p->port_type = FW_PORT_CMD_PTYPE_G(ret);
 		p->mod_type = FW_PORT_MOD_TYPE_NA;
 
-		rvc.op_to_viid = htonl(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
-				       FW_CMD_REQUEST_F | FW_CMD_READ_F |
-				       FW_RSS_VI_CONFIG_CMD_VIID(p->viid));
-		rvc.retval_len16 = htonl(FW_LEN16(rvc));
+		rvc.op_to_viid =
+			cpu_to_be32(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
+				    FW_CMD_REQUEST_F | FW_CMD_READ_F |
+				    FW_RSS_VI_CONFIG_CMD_VIID(p->viid));
+		rvc.retval_len16 = cpu_to_be32(FW_LEN16(rvc));
 		ret = t4_wr_mbox(adap, mbox, &rvc, sizeof(rvc), &rvc);
 		if (ret)
 			return ret;
-		p->rss_mode = ntohl(rvc.u.basicvirtual.defaultq_to_udpen);
+		p->rss_mode = be32_to_cpu(rvc.u.basicvirtual.defaultq_to_udpen);
 
-		init_link_config(&p->link_cfg, ntohs(c.u.info.pcap));
+		init_link_config(&p->link_cfg, be16_to_cpu(c.u.info.pcap));
 		j++;
 	}
 	return 0;
-- 
2.3.4
