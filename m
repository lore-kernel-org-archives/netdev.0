From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/5] RDMA/cxgb4/csiostor: Cleansup FW related macros/register defines for PF/VF and LDST
Date: Fri, 21 Nov 2014 12:52:02 +0530
Message-ID: <1416554525-11844-3-git-send-email-hariprasad@chelsio.com>
References: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, hch@infradead.org,
	swise@opengridcomputing.com, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, praveen@chelsio.com,
	varun@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33690
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752436AbaKUHRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 02:17:23 -0500
In-Reply-To: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleanups PF/VF and LDST related macros/register defines that are
defined in t4fw_api.h and the affected files.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                   |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   61 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   78 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  270 +++++++++++++-------
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   10 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   72 +++---
 drivers/scsi/csiostor/csio_hw.c                    |   20 +-
 drivers/scsi/csiostor/csio_mb.c                    |   30 +-
 drivers/scsi/csiostor/csio_mb.h                    |   12 +-
 9 files changed, 327 insertions(+), 228 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 0ad8e2a..4b8c611 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -478,7 +478,7 @@ static void send_flowc(struct c4iw_ep *ep, struct sk_buff *skb)
 					  16)) | FW_WR_FLOWID_V(ep->hwtid));
 
 	flowc->mnemval[0].mnemonic = FW_FLOWC_MNEM_PFNVFN;
-	flowc->mnemval[0].val = cpu_to_be32(FW_PFVF_CMD_PFN
+	flowc->mnemval[0].val = cpu_to_be32(FW_PFVF_CMD_PFN_V
 					    (ep->com.dev->rdev.lldi.pf));
 	flowc->mnemval[1].mnemonic = FW_FLOWC_MNEM_CH;
 	flowc->mnemval[1].val = cpu_to_be32(ep->tx_chan);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6b6d7e1..4caec41 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -141,7 +141,7 @@ static unsigned int pfvfres_pmask(struct adapter *adapter,
 	 * Give PF's access to all of the ports.
 	 */
 	if (vf == 0)
-		return FW_PFVF_CMD_PMASK_MASK;
+		return FW_PFVF_CMD_PMASK_M;
 
 	/*
 	 * For VFs, we'll assign them access to the ports based purely on the
@@ -512,9 +512,10 @@ static void dcb_tx_queue_prio_enable(struct net_device *dev, int enable)
 		u32 name, value;
 		int err;
 
-		name = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DMAQ) |
-			FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DMAQ_EQ_DCBPRIO_ETH) |
-			FW_PARAMS_PARAM_YZ(txq->q.cntxt_id));
+		name = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
+			FW_PARAMS_PARAM_X_V(
+				FW_PARAMS_PARAM_DMAQ_EQ_DCBPRIO_ETH) |
+			FW_PARAMS_PARAM_YZ_V(txq->q.cntxt_id));
 		value = enable ? i : 0xffffffff;
 
 		/* Since we can be called while atomic (from "interrupt
@@ -2717,9 +2718,10 @@ static int set_rspq_intr_params(struct sge_rspq *q,
 		new_idx = closest_thres(&adap->sge, cnt);
 		if (q->desc && q->pktcnt_idx != new_idx) {
 			/* the queue has already been created, update it */
-			v = FW_PARAMS_MNEM(FW_PARAMS_MNEM_DMAQ) |
-			    FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DMAQ_IQ_INTCNTTHRESH) |
-			    FW_PARAMS_PARAM_YZ(q->cntxt_id);
+			v = FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
+			    FW_PARAMS_PARAM_X_V(
+					FW_PARAMS_PARAM_DMAQ_IQ_INTCNTTHRESH) |
+			    FW_PARAMS_PARAM_YZ_V(q->cntxt_id);
 			err = t4_set_params(adap, adap->fn, adap->fn, 0, 1, &v,
 					    &new_idx);
 			if (err)
@@ -4870,11 +4872,11 @@ static u32 t4_read_pcie_cfg4(struct adapter *adap, int reg)
 		htonl(FW_CMD_OP_V(FW_LDST_CMD) |
 		      FW_CMD_REQUEST_F |
 		      FW_CMD_READ_F |
-		      FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_FUNC_PCIE));
+		      FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_FUNC_PCIE));
 	ldst_cmd.cycles_to_len16 = htonl(FW_LEN16(ldst_cmd));
-	ldst_cmd.u.pcie.select_naccess = FW_LDST_CMD_NACCESS(1);
+	ldst_cmd.u.pcie.select_naccess = FW_LDST_CMD_NACCESS_V(1);
 	ldst_cmd.u.pcie.ctrl_to_fn =
-		(FW_LDST_CMD_LC | FW_LDST_CMD_FN(adap->fn));
+		(FW_LDST_CMD_LC_F | FW_LDST_CMD_FN_V(adap->fn));
 	ldst_cmd.u.pcie.r = reg;
 	ret = t4_wr_mbox(adap, adap->mbox, &ldst_cmd, sizeof(ldst_cmd),
 			 &ldst_cmd);
@@ -5148,8 +5150,8 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 		if (cf->size >= FLASH_CFG_MAX_SIZE)
 			ret = -ENOMEM;
 		else {
-			params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
-			     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_CF));
+			params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+			     FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_CF));
 			ret = t4_query_params(adapter, adapter->mbox,
 					      adapter->fn, 0, 1, params, val);
 			if (ret == 0) {
@@ -5167,8 +5169,8 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 				size_t size = cf->size & ~0x3;
 				__be32 *data = (__be32 *)cf->data;
 
-				mtype = FW_PARAMS_PARAM_Y_GET(val[0]);
-				maddr = FW_PARAMS_PARAM_Z_GET(val[0]) << 16;
+				mtype = FW_PARAMS_PARAM_Y_G(val[0]);
+				maddr = FW_PARAMS_PARAM_Z_G(val[0]) << 16;
 
 				spin_lock(&adapter->win0_lock);
 				ret = t4_memory_rw(adapter, 0, mtype, maddr,
@@ -5209,9 +5211,9 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 		      FW_CMD_REQUEST_F |
 		      FW_CMD_READ_F);
 	caps_cmd.cfvalid_to_len16 =
-		htonl(FW_CAPS_CONFIG_CMD_CFVALID |
-		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF(mtype) |
-		      FW_CAPS_CONFIG_CMD_MEMADDR64K_CF(maddr >> 16) |
+		htonl(FW_CAPS_CONFIG_CMD_CFVALID_F |
+		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF_V(mtype) |
+		      FW_CAPS_CONFIG_CMD_MEMADDR64K_CF_V(maddr >> 16) |
 		      FW_LEN16(caps_cmd));
 	ret = t4_wr_mbox(adapter, adapter->mbox, &caps_cmd, sizeof(caps_cmd),
 			 &caps_cmd);
@@ -5377,7 +5379,7 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 			  PFRES_NEQ, PFRES_NETHCTRL,
 			  PFRES_NIQFLINT, PFRES_NIQ,
 			  PFRES_TC, PFRES_NVI,
-			  FW_PFVF_CMD_CMASK_MASK,
+			  FW_PFVF_CMD_CMASK_M,
 			  pfvfres_pmask(adapter, adapter->fn, 0),
 			  PFRES_NEXACTF,
 			  PFRES_R_CAPS, PFRES_WX_CAPS);
@@ -5422,7 +5424,7 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 						  VFRES_NEQ, VFRES_NETHCTRL,
 						  VFRES_NIQFLINT, VFRES_NIQ,
 						  VFRES_TC, VFRES_NVI,
-						  FW_PFVF_CMD_CMASK_MASK,
+						  FW_PFVF_CMD_CMASK_M,
 						  pfvfres_pmask(
 						  adapter, pf, vf),
 						  VFRES_NEXACTF,
@@ -5686,8 +5688,8 @@ static int adap_init0(struct adapter *adap)
 	 * and portvec ...
 	 */
 	v =
-	    FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
-	    FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_PORTVEC);
+	    FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+	    FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_PORTVEC);
 	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 1, &v, &port_vec);
 	if (ret < 0)
 		goto bye;
@@ -5723,8 +5725,9 @@ static int adap_init0(struct adapter *adap)
 			 * Find out whether we're dealing with a version of
 			 * the firmware which has configuration file support.
 			 */
-			params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
-				     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_CF));
+			params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+				     FW_PARAMS_PARAM_X_V(
+					     FW_PARAMS_PARAM_DEV_CF));
 			ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 1,
 					      params, val);
 
@@ -5784,14 +5787,14 @@ static int adap_init0(struct adapter *adap)
 	 * Grab some of our basic fundamental operating parameters.
 	 */
 #define FW_PARAM_DEV(param) \
-	(FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) | \
-	FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_##param))
+	(FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) | \
+	FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_##param))
 
 #define FW_PARAM_PFVF(param) \
-	FW_PARAMS_MNEM(FW_PARAMS_MNEM_PFVF) | \
-	FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_PFVF_##param)|  \
-	FW_PARAMS_PARAM_Y(0) | \
-	FW_PARAMS_PARAM_Z(0)
+	FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_PFVF) | \
+	FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_PFVF_##param)|  \
+	FW_PARAMS_PARAM_Y_V(0) | \
+	FW_PARAMS_PARAM_Z_V(0)
 
 	params[0] = FW_PARAM_PFVF(EQ_START);
 	params[1] = FW_PARAM_PFVF(L2T_START);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 0c78be3..9f1b304 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -711,8 +711,8 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	 * Ask firmware for the Core Clock since it knows how to translate the
 	 * Reference Clock ('V2') VPD field into a Core Clock value ...
 	 */
-	cclk_param = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
-		      FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_CCLK));
+	cclk_param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		      FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_CCLK));
 	ret = t4_query_params(adapter, adapter->mbox, 0, 0,
 			      1, &cclk_param, &cclk_val);
 
@@ -2577,7 +2577,7 @@ int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
 	memset(&c, 0, sizeof(c));
 	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F |
-			    FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_FIRMWARE));
+			    FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_FIRMWARE));
 	c.cycles_to_len16 = htonl(FW_LEN16(c));
 	c.u.addrval.addr = htonl(addr);
 	c.u.addrval.val = htonl(val);
@@ -2604,10 +2604,10 @@ int t4_mdio_rd(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
-		FW_CMD_READ_F | FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_MDIO));
+		FW_CMD_READ_F | FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_MDIO));
 	c.cycles_to_len16 = htonl(FW_LEN16(c));
-	c.u.mdio.paddr_mmd = htons(FW_LDST_CMD_PADDR(phy_addr) |
-				   FW_LDST_CMD_MMD(mmd));
+	c.u.mdio.paddr_mmd = htons(FW_LDST_CMD_PADDR_V(phy_addr) |
+				   FW_LDST_CMD_MMD_V(mmd));
 	c.u.mdio.raddr = htons(reg);
 
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
@@ -2634,10 +2634,10 @@ int t4_mdio_wr(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_addrspace = htonl(FW_CMD_OP_V(FW_LDST_CMD) | FW_CMD_REQUEST_F |
-		FW_CMD_WRITE_F | FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_MDIO));
+		FW_CMD_WRITE_F | FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_MDIO));
 	c.cycles_to_len16 = htonl(FW_LEN16(c));
-	c.u.mdio.paddr_mmd = htons(FW_LDST_CMD_PADDR(phy_addr) |
-				   FW_LDST_CMD_MMD(mmd));
+	c.u.mdio.paddr_mmd = htons(FW_LDST_CMD_PADDR_V(phy_addr) |
+				   FW_LDST_CMD_MMD_V(mmd));
 	c.u.mdio.raddr = htons(reg);
 	c.u.mdio.rval = htons(val);
 
@@ -2774,13 +2774,13 @@ retry:
 	memset(&c, 0, sizeof(c));
 	INIT_CMD(c, HELLO, WRITE);
 	c.err_to_clearinit = htonl(
-		FW_HELLO_CMD_MASTERDIS(master == MASTER_CANT) |
-		FW_HELLO_CMD_MASTERFORCE(master == MASTER_MUST) |
-		FW_HELLO_CMD_MBMASTER(master == MASTER_MUST ? mbox :
-				      FW_HELLO_CMD_MBMASTER_MASK) |
-		FW_HELLO_CMD_MBASYNCNOT(evt_mbox) |
-		FW_HELLO_CMD_STAGE(fw_hello_cmd_stage_os) |
-		FW_HELLO_CMD_CLEARINIT);
+		FW_HELLO_CMD_MASTERDIS_V(master == MASTER_CANT) |
+		FW_HELLO_CMD_MASTERFORCE_V(master == MASTER_MUST) |
+		FW_HELLO_CMD_MBMASTER_V(master == MASTER_MUST ? mbox :
+				      FW_HELLO_CMD_MBMASTER_M) |
+		FW_HELLO_CMD_MBASYNCNOT_V(evt_mbox) |
+		FW_HELLO_CMD_STAGE_V(fw_hello_cmd_stage_os) |
+		FW_HELLO_CMD_CLEARINIT_F);
 
 	/*
 	 * Issue the HELLO command to the firmware.  If it's not successful
@@ -2799,11 +2799,11 @@ retry:
 	}
 
 	v = ntohl(c.err_to_clearinit);
-	master_mbox = FW_HELLO_CMD_MBMASTER_GET(v);
+	master_mbox = FW_HELLO_CMD_MBMASTER_G(v);
 	if (state) {
-		if (v & FW_HELLO_CMD_ERR)
+		if (v & FW_HELLO_CMD_ERR_F)
 			*state = DEV_STATE_ERR;
-		else if (v & FW_HELLO_CMD_INIT)
+		else if (v & FW_HELLO_CMD_INIT_F)
 			*state = DEV_STATE_INIT;
 		else
 			*state = DEV_STATE_UNINIT;
@@ -2820,7 +2820,7 @@ retry:
 	 * this case, the Master PF returned by the firmware will be
 	 * FW_PCIE_FW_MASTER_MASK so the test below will work ...
 	 */
-	if ((v & (FW_HELLO_CMD_ERR|FW_HELLO_CMD_INIT)) == 0 &&
+	if ((v & (FW_HELLO_CMD_ERR_F|FW_HELLO_CMD_INIT_F)) == 0 &&
 	    master_mbox != mbox) {
 		int waiting = FW_CMD_HELLO_TIMEOUT;
 
@@ -2961,7 +2961,7 @@ static int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force)
 		memset(&c, 0, sizeof(c));
 		INIT_CMD(c, RESET, WRITE);
 		c.val = htonl(PIORST | PIORSTMODE);
-		c.halt_pkd = htonl(FW_RESET_CMD_HALT(1U));
+		c.halt_pkd = htonl(FW_RESET_CMD_HALT_F);
 		ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 	}
 
@@ -3252,8 +3252,8 @@ int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PARAMS_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_READ_F | FW_PARAMS_CMD_PFN(pf) |
-			    FW_PARAMS_CMD_VFN(vf));
+			    FW_CMD_READ_F | FW_PARAMS_CMD_PFN_V(pf) |
+			    FW_PARAMS_CMD_VFN_V(vf));
 	c.retval_len16 = htonl(FW_LEN16(c));
 	for (i = 0; i < nparams; i++, p += 2)
 		*p = htonl(*params++);
@@ -3293,8 +3293,8 @@ int t4_set_params_nosleep(struct adapter *adap, unsigned int mbox,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
 				FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
-				FW_PARAMS_CMD_PFN(pf) |
-				FW_PARAMS_CMD_VFN(vf));
+				FW_PARAMS_CMD_PFN_V(pf) |
+				FW_PARAMS_CMD_VFN_V(vf));
 	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
 
 	while (nparams--) {
@@ -3330,8 +3330,8 @@ int t4_set_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PARAMS_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_WRITE_F | FW_PARAMS_CMD_PFN(pf) |
-			    FW_PARAMS_CMD_VFN(vf));
+			    FW_CMD_WRITE_F | FW_PARAMS_CMD_PFN_V(pf) |
+			    FW_PARAMS_CMD_VFN_V(vf));
 	c.retval_len16 = htonl(FW_LEN16(c));
 	while (nparams--) {
 		*p++ = htonl(*params++);
@@ -3372,19 +3372,19 @@ int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, unsigned int pf,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_PFVF_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_WRITE_F | FW_PFVF_CMD_PFN(pf) |
-			    FW_PFVF_CMD_VFN(vf));
+			    FW_CMD_WRITE_F | FW_PFVF_CMD_PFN_V(pf) |
+			    FW_PFVF_CMD_VFN_V(vf));
 	c.retval_len16 = htonl(FW_LEN16(c));
-	c.niqflint_niq = htonl(FW_PFVF_CMD_NIQFLINT(rxqi) |
-			       FW_PFVF_CMD_NIQ(rxq));
-	c.type_to_neq = htonl(FW_PFVF_CMD_CMASK(cmask) |
-			       FW_PFVF_CMD_PMASK(pmask) |
-			       FW_PFVF_CMD_NEQ(txq));
-	c.tc_to_nexactf = htonl(FW_PFVF_CMD_TC(tc) | FW_PFVF_CMD_NVI(vi) |
-				FW_PFVF_CMD_NEXACTF(nexact));
-	c.r_caps_to_nethctrl = htonl(FW_PFVF_CMD_R_CAPS(rcaps) |
-				     FW_PFVF_CMD_WX_CAPS(wxcaps) |
-				     FW_PFVF_CMD_NETHCTRL(txq_eth_ctrl));
+	c.niqflint_niq = htonl(FW_PFVF_CMD_NIQFLINT_V(rxqi) |
+			       FW_PFVF_CMD_NIQ_V(rxq));
+	c.type_to_neq = htonl(FW_PFVF_CMD_CMASK_V(cmask) |
+			       FW_PFVF_CMD_PMASK_V(pmask) |
+			       FW_PFVF_CMD_NEQ_V(txq));
+	c.tc_to_nexactf = htonl(FW_PFVF_CMD_TC_V(tc) | FW_PFVF_CMD_NVI_V(vi) |
+				FW_PFVF_CMD_NEXACTF_V(nexact));
+	c.r_caps_to_nethctrl = htonl(FW_PFVF_CMD_R_CAPS_V(rcaps) |
+				     FW_PFVF_CMD_WX_CAPS_V(wxcaps) |
+				     FW_PFVF_CMD_NETHCTRL_V(txq_eth_ctrl));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 3bc5bdb..5839b80 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -761,7 +761,8 @@ enum fw_ldst_func_mod_index {
 
 struct fw_ldst_cmd {
 	__be32 op_to_addrspace;
-#define FW_LDST_CMD_ADDRSPACE(x) ((x) << 0)
+#define FW_LDST_CMD_ADDRSPACE_S		0
+#define FW_LDST_CMD_ADDRSPACE_V(x)	((x) << FW_LDST_CMD_ADDRSPACE_S)
 	__be32 cycles_to_len16;
 	union fw_ldst {
 		struct fw_ldst_addrval {
@@ -817,15 +818,33 @@ struct fw_ldst_cmd {
 	} u;
 };
 
-#define FW_LDST_CMD_MSG(x)	((x) << 31)
-#define FW_LDST_CMD_PADDR(x)	((x) << 8)
-#define FW_LDST_CMD_MMD(x)	((x) << 0)
-#define FW_LDST_CMD_FID(x)	((x) << 15)
-#define FW_LDST_CMD_CTL(x)	((x) << 0)
-#define FW_LDST_CMD_RPLCPF(x)	((x) << 0)
-#define FW_LDST_CMD_LC		(1U << 4)
-#define FW_LDST_CMD_NACCESS(x)	((x) << 0)
-#define FW_LDST_CMD_FN(x)	((x) << 0)
+#define FW_LDST_CMD_MSG_S       31
+#define FW_LDST_CMD_MSG_V(x)	((x) << FW_LDST_CMD_MSG_S)
+
+#define FW_LDST_CMD_PADDR_S     8
+#define FW_LDST_CMD_PADDR_V(x)	((x) << FW_LDST_CMD_PADDR_S)
+
+#define FW_LDST_CMD_MMD_S       0
+#define FW_LDST_CMD_MMD_V(x)	((x) << FW_LDST_CMD_MMD_S)
+
+#define FW_LDST_CMD_FID_S       15
+#define FW_LDST_CMD_FID_V(x)	((x) << FW_LDST_CMD_FID_S)
+
+#define FW_LDST_CMD_CTL_S       0
+#define FW_LDST_CMD_CTL_V(x)	((x) << FW_LDST_CMD_CTL_S)
+
+#define FW_LDST_CMD_RPLCPF_S    0
+#define FW_LDST_CMD_RPLCPF_V(x)	((x) << FW_LDST_CMD_RPLCPF_S)
+
+#define FW_LDST_CMD_LC_S        4
+#define FW_LDST_CMD_LC_V(x)     ((x) << FW_LDST_CMD_LC_S)
+#define FW_LDST_CMD_LC_F	FW_LDST_CMD_LC_V(1U)
+
+#define FW_LDST_CMD_FN_S        0
+#define FW_LDST_CMD_FN_V(x)	((x) << FW_LDST_CMD_FN_S)
+
+#define FW_LDST_CMD_NACCESS_S           0
+#define FW_LDST_CMD_NACCESS_V(x)	((x) << FW_LDST_CMD_NACCESS_S)
 
 struct fw_reset_cmd {
 	__be32 op_to_write;
@@ -834,11 +853,12 @@ struct fw_reset_cmd {
 	__be32 halt_pkd;
 };
 
-#define FW_RESET_CMD_HALT_SHIFT    31
-#define FW_RESET_CMD_HALT_MASK     0x1
-#define FW_RESET_CMD_HALT(x)       ((x) << FW_RESET_CMD_HALT_SHIFT)
-#define FW_RESET_CMD_HALT_GET(x)  \
-	(((x) >> FW_RESET_CMD_HALT_SHIFT) & FW_RESET_CMD_HALT_MASK)
+#define FW_RESET_CMD_HALT_S	31
+#define FW_RESET_CMD_HALT_M     0x1
+#define FW_RESET_CMD_HALT_V(x)	((x) << FW_RESET_CMD_HALT_S)
+#define FW_RESET_CMD_HALT_G(x)  \
+	(((x) >> FW_RESET_CMD_HALT_S) & FW_RESET_CMD_HALT_M)
+#define FW_RESET_CMD_HALT_F	FW_RESET_CMD_HALT_V(1U)
 
 enum fw_hellow_cmd {
 	fw_hello_cmd_stage_os		= 0x0
@@ -848,22 +868,42 @@ struct fw_hello_cmd {
 	__be32 op_to_write;
 	__be32 retval_len16;
 	__be32 err_to_clearinit;
-#define FW_HELLO_CMD_ERR	    (1U << 31)
-#define FW_HELLO_CMD_INIT	    (1U << 30)
-#define FW_HELLO_CMD_MASTERDIS(x)   ((x) << 29)
-#define FW_HELLO_CMD_MASTERFORCE(x) ((x) << 28)
-#define FW_HELLO_CMD_MBMASTER_MASK   0xfU
-#define FW_HELLO_CMD_MBMASTER_SHIFT  24
-#define FW_HELLO_CMD_MBMASTER(x)     ((x) << FW_HELLO_CMD_MBMASTER_SHIFT)
-#define FW_HELLO_CMD_MBMASTER_GET(x) \
-	(((x) >> FW_HELLO_CMD_MBMASTER_SHIFT) & FW_HELLO_CMD_MBMASTER_MASK)
-#define FW_HELLO_CMD_MBASYNCNOTINT(x)	((x) << 23)
-#define FW_HELLO_CMD_MBASYNCNOT(x)  ((x) << 20)
-#define FW_HELLO_CMD_STAGE(x)       ((x) << 17)
-#define FW_HELLO_CMD_CLEARINIT      (1U << 16)
 	__be32 fwrev;
 };
 
+#define FW_HELLO_CMD_ERR_S      31
+#define FW_HELLO_CMD_ERR_V(x)   ((x) << FW_HELLO_CMD_ERR_S)
+#define FW_HELLO_CMD_ERR_F	FW_HELLO_CMD_ERR_V(1U)
+
+#define FW_HELLO_CMD_INIT_S     30
+#define FW_HELLO_CMD_INIT_V(x)  ((x) << FW_HELLO_CMD_INIT_S)
+#define FW_HELLO_CMD_INIT_F	FW_HELLO_CMD_INIT_V(1U)
+
+#define FW_HELLO_CMD_MASTERDIS_S	29
+#define FW_HELLO_CMD_MASTERDIS_V(x)	((x) << FW_HELLO_CMD_MASTERDIS_S)
+
+#define FW_HELLO_CMD_MASTERFORCE_S      28
+#define FW_HELLO_CMD_MASTERFORCE_V(x)	((x) << FW_HELLO_CMD_MASTERFORCE_S)
+
+#define FW_HELLO_CMD_MBMASTER_S		24
+#define FW_HELLO_CMD_MBMASTER_M		0xfU
+#define FW_HELLO_CMD_MBMASTER_V(x)	((x) << FW_HELLO_CMD_MBMASTER_S)
+#define FW_HELLO_CMD_MBMASTER_G(x)	\
+	(((x) >> FW_HELLO_CMD_MBMASTER_S) & FW_HELLO_CMD_MBMASTER_M)
+
+#define FW_HELLO_CMD_MBASYNCNOTINT_S    23
+#define FW_HELLO_CMD_MBASYNCNOTINT_V(x)	((x) << FW_HELLO_CMD_MBASYNCNOTINT_S)
+
+#define FW_HELLO_CMD_MBASYNCNOT_S       20
+#define FW_HELLO_CMD_MBASYNCNOT_V(x)	((x) << FW_HELLO_CMD_MBASYNCNOT_S)
+
+#define FW_HELLO_CMD_STAGE_S		17
+#define FW_HELLO_CMD_STAGE_V(x)		((x) << FW_HELLO_CMD_STAGE_S)
+
+#define FW_HELLO_CMD_CLEARINIT_S        16
+#define FW_HELLO_CMD_CLEARINIT_V(x)     ((x) << FW_HELLO_CMD_CLEARINIT_S)
+#define FW_HELLO_CMD_CLEARINIT_F	FW_HELLO_CMD_CLEARINIT_V(1U)
+
 struct fw_bye_cmd {
 	__be32 op_to_write;
 	__be32 retval_len16;
@@ -974,9 +1014,17 @@ struct fw_caps_config_cmd {
 	__be32 finicsum;
 };
 
-#define FW_CAPS_CONFIG_CMD_CFVALID          (1U << 27)
-#define FW_CAPS_CONFIG_CMD_MEMTYPE_CF(x)    ((x) << 24)
-#define FW_CAPS_CONFIG_CMD_MEMADDR64K_CF(x) ((x) << 16)
+#define FW_CAPS_CONFIG_CMD_CFVALID_S    27
+#define FW_CAPS_CONFIG_CMD_CFVALID_V(x) ((x) << FW_CAPS_CONFIG_CMD_CFVALID_S)
+#define FW_CAPS_CONFIG_CMD_CFVALID_F    FW_CAPS_CONFIG_CMD_CFVALID_V(1U)
+
+#define FW_CAPS_CONFIG_CMD_MEMTYPE_CF_S		24
+#define FW_CAPS_CONFIG_CMD_MEMTYPE_CF_V(x)	\
+	((x) << FW_CAPS_CONFIG_CMD_MEMTYPE_CF_S)
+
+#define FW_CAPS_CONFIG_CMD_MEMADDR64K_CF_S      16
+#define FW_CAPS_CONFIG_CMD_MEMADDR64K_CF_V(x)	\
+	((x) << FW_CAPS_CONFIG_CMD_MEMADDR64K_CF_S)
 
 /*
  * params command mnemonics
@@ -1072,20 +1120,29 @@ enum fw_params_param_dmaq {
 	FW_PARAMS_PARAM_DMAQ_EQ_DCBPRIO_ETH = 0x13,
 };
 
-#define FW_PARAMS_MNEM(x)      ((x) << 24)
-#define FW_PARAMS_PARAM_X(x)   ((x) << 16)
-#define FW_PARAMS_PARAM_Y_SHIFT  8
-#define FW_PARAMS_PARAM_Y_MASK   0xffU
-#define FW_PARAMS_PARAM_Y(x)     ((x) << FW_PARAMS_PARAM_Y_SHIFT)
-#define FW_PARAMS_PARAM_Y_GET(x) (((x) >> FW_PARAMS_PARAM_Y_SHIFT) &\
-		FW_PARAMS_PARAM_Y_MASK)
-#define FW_PARAMS_PARAM_Z_SHIFT  0
-#define FW_PARAMS_PARAM_Z_MASK   0xffu
-#define FW_PARAMS_PARAM_Z(x)     ((x) << FW_PARAMS_PARAM_Z_SHIFT)
-#define FW_PARAMS_PARAM_Z_GET(x) (((x) >> FW_PARAMS_PARAM_Z_SHIFT) &\
-		FW_PARAMS_PARAM_Z_MASK)
-#define FW_PARAMS_PARAM_XYZ(x) ((x) << 0)
-#define FW_PARAMS_PARAM_YZ(x)  ((x) << 0)
+#define FW_PARAMS_MNEM_S	24
+#define FW_PARAMS_MNEM_V(x)	((x) << FW_PARAMS_MNEM_S)
+
+#define FW_PARAMS_PARAM_X_S     16
+#define FW_PARAMS_PARAM_X_V(x)	((x) << FW_PARAMS_PARAM_X_S)
+
+#define FW_PARAMS_PARAM_Y_S	8
+#define FW_PARAMS_PARAM_Y_M	0xffU
+#define FW_PARAMS_PARAM_Y_V(x)	((x) << FW_PARAMS_PARAM_Y_S)
+#define FW_PARAMS_PARAM_Y_G(x)	(((x) >> FW_PARAMS_PARAM_Y_S) &\
+		FW_PARAMS_PARAM_Y_M)
+
+#define FW_PARAMS_PARAM_Z_S	0
+#define FW_PARAMS_PARAM_Z_M	0xffu
+#define FW_PARAMS_PARAM_Z_V(x)	((x) << FW_PARAMS_PARAM_Z_S)
+#define FW_PARAMS_PARAM_Z_G(x)	(((x) >> FW_PARAMS_PARAM_Z_S) &\
+		FW_PARAMS_PARAM_Z_M)
+
+#define FW_PARAMS_PARAM_XYZ_S		0
+#define FW_PARAMS_PARAM_XYZ_V(x)	((x) << FW_PARAMS_PARAM_XYZ_S)
+
+#define FW_PARAMS_PARAM_YZ_S		0
+#define FW_PARAMS_PARAM_YZ_V(x)		((x) << FW_PARAMS_PARAM_YZ_S)
 
 struct fw_params_cmd {
 	__be32 op_to_vfn;
@@ -1096,8 +1153,11 @@ struct fw_params_cmd {
 	} param[7];
 };
 
-#define FW_PARAMS_CMD_PFN(x) ((x) << 8)
-#define FW_PARAMS_CMD_VFN(x) ((x) << 0)
+#define FW_PARAMS_CMD_PFN_S     8
+#define FW_PARAMS_CMD_PFN_V(x)	((x) << FW_PARAMS_CMD_PFN_S)
+
+#define FW_PARAMS_CMD_VFN_S     0
+#define FW_PARAMS_CMD_VFN_V(x)	((x) << FW_PARAMS_CMD_VFN_S)
 
 struct fw_pfvf_cmd {
 	__be32 op_to_vfn;
@@ -1111,46 +1171,82 @@ struct fw_pfvf_cmd {
 	__be32 r4;
 };
 
-#define FW_PFVF_CMD_PFN(x) ((x) << 8)
-#define FW_PFVF_CMD_VFN(x) ((x) << 0)
-
-#define FW_PFVF_CMD_NIQFLINT(x) ((x) << 20)
-#define FW_PFVF_CMD_NIQFLINT_GET(x) (((x) >> 20) & 0xfff)
-
-#define FW_PFVF_CMD_NIQ(x) ((x) << 0)
-#define FW_PFVF_CMD_NIQ_GET(x) (((x) >> 0) & 0xfffff)
-
-#define FW_PFVF_CMD_TYPE (1 << 31)
-#define FW_PFVF_CMD_TYPE_GET(x) (((x) >> 31) & 0x1)
-
-#define FW_PFVF_CMD_CMASK(x) ((x) << 24)
-#define FW_PFVF_CMD_CMASK_MASK 0xf
-#define FW_PFVF_CMD_CMASK_GET(x) (((x) >> 24) & FW_PFVF_CMD_CMASK_MASK)
-
-#define FW_PFVF_CMD_PMASK(x) ((x) << 20)
-#define FW_PFVF_CMD_PMASK_MASK 0xf
-#define FW_PFVF_CMD_PMASK_GET(x) (((x) >> 20) & FW_PFVF_CMD_PMASK_MASK)
-
-#define FW_PFVF_CMD_NEQ(x) ((x) << 0)
-#define FW_PFVF_CMD_NEQ_GET(x) (((x) >> 0) & 0xfffff)
-
-#define FW_PFVF_CMD_TC(x) ((x) << 24)
-#define FW_PFVF_CMD_TC_GET(x) (((x) >> 24) & 0xff)
-
-#define FW_PFVF_CMD_NVI(x) ((x) << 16)
-#define FW_PFVF_CMD_NVI_GET(x) (((x) >> 16) & 0xff)
-
-#define FW_PFVF_CMD_NEXACTF(x) ((x) << 0)
-#define FW_PFVF_CMD_NEXACTF_GET(x) (((x) >> 0) & 0xffff)
-
-#define FW_PFVF_CMD_R_CAPS(x) ((x) << 24)
-#define FW_PFVF_CMD_R_CAPS_GET(x) (((x) >> 24) & 0xff)
-
-#define FW_PFVF_CMD_WX_CAPS(x) ((x) << 16)
-#define FW_PFVF_CMD_WX_CAPS_GET(x) (((x) >> 16) & 0xff)
-
-#define FW_PFVF_CMD_NETHCTRL(x) ((x) << 0)
-#define FW_PFVF_CMD_NETHCTRL_GET(x) (((x) >> 0) & 0xffff)
+#define FW_PFVF_CMD_PFN_S	8
+#define FW_PFVF_CMD_PFN_V(x)	((x) << FW_PFVF_CMD_PFN_S)
+
+#define FW_PFVF_CMD_VFN_S       0
+#define FW_PFVF_CMD_VFN_V(x)	((x) << FW_PFVF_CMD_VFN_S)
+
+#define FW_PFVF_CMD_NIQFLINT_S          20
+#define FW_PFVF_CMD_NIQFLINT_M          0xfff
+#define FW_PFVF_CMD_NIQFLINT_V(x)	((x) << FW_PFVF_CMD_NIQFLINT_S)
+#define FW_PFVF_CMD_NIQFLINT_G(x)	\
+	(((x) >> FW_PFVF_CMD_NIQFLINT_S) & FW_PFVF_CMD_NIQFLINT_M)
+
+#define FW_PFVF_CMD_NIQ_S       0
+#define FW_PFVF_CMD_NIQ_M       0xfffff
+#define FW_PFVF_CMD_NIQ_V(x)	((x) << FW_PFVF_CMD_NIQ_S)
+#define FW_PFVF_CMD_NIQ_G(x)	\
+	(((x) >> FW_PFVF_CMD_NIQ_S) & FW_PFVF_CMD_NIQ_M)
+
+#define FW_PFVF_CMD_TYPE_S      31
+#define FW_PFVF_CMD_TYPE_M      0x1
+#define FW_PFVF_CMD_TYPE_V(x)   ((x) << FW_PFVF_CMD_TYPE_S)
+#define FW_PFVF_CMD_TYPE_G(x)	\
+	(((x) >> FW_PFVF_CMD_TYPE_S) & FW_PFVF_CMD_TYPE_M)
+#define FW_PFVF_CMD_TYPE_F      FW_PFVF_CMD_TYPE_V(1U)
+
+#define FW_PFVF_CMD_CMASK_S     24
+#define FW_PFVF_CMD_CMASK_M	0xf
+#define FW_PFVF_CMD_CMASK_V(x)	((x) << FW_PFVF_CMD_CMASK_S)
+#define FW_PFVF_CMD_CMASK_G(x)	\
+	(((x) >> FW_PFVF_CMD_CMASK_S) & FW_PFVF_CMD_CMASK_M)
+
+#define FW_PFVF_CMD_PMASK_S     20
+#define FW_PFVF_CMD_PMASK_M	0xf
+#define FW_PFVF_CMD_PMASK_V(x)	((x) << FW_PFVF_CMD_PMASK_S)
+#define FW_PFVF_CMD_PMASK_G(x) \
+	(((x) >> FW_PFVF_CMD_PMASK_S) & FW_PFVF_CMD_PMASK_M)
+
+#define FW_PFVF_CMD_NEQ_S       0
+#define FW_PFVF_CMD_NEQ_M       0xfffff
+#define FW_PFVF_CMD_NEQ_V(x)	((x) << FW_PFVF_CMD_NEQ_S)
+#define FW_PFVF_CMD_NEQ_G(x)	\
+	(((x) >> FW_PFVF_CMD_NEQ_S) & FW_PFVF_CMD_NEQ_M)
+
+#define FW_PFVF_CMD_TC_S        24
+#define FW_PFVF_CMD_TC_M        0xff
+#define FW_PFVF_CMD_TC_V(x)	((x) << FW_PFVF_CMD_TC_S)
+#define FW_PFVF_CMD_TC_G(x)	(((x) >> FW_PFVF_CMD_TC_S) & FW_PFVF_CMD_TC_M)
+
+#define FW_PFVF_CMD_NVI_S       16
+#define FW_PFVF_CMD_NVI_M       0xff
+#define FW_PFVF_CMD_NVI_V(x)	((x) << FW_PFVF_CMD_NVI_S)
+#define FW_PFVF_CMD_NVI_G(x)	(((x) >> FW_PFVF_CMD_NVI_S) & FW_PFVF_CMD_NVI_M)
+
+#define FW_PFVF_CMD_NEXACTF_S           0
+#define FW_PFVF_CMD_NEXACTF_M           0xffff
+#define FW_PFVF_CMD_NEXACTF_V(x)	((x) << FW_PFVF_CMD_NEXACTF_S)
+#define FW_PFVF_CMD_NEXACTF_G(x)	\
+	(((x) >> FW_PFVF_CMD_NEXACTF_S) & FW_PFVF_CMD_NEXACTF_M)
+
+#define FW_PFVF_CMD_R_CAPS_S    24
+#define FW_PFVF_CMD_R_CAPS_M    0xff
+#define FW_PFVF_CMD_R_CAPS_V(x) ((x) << FW_PFVF_CMD_R_CAPS_S)
+#define FW_PFVF_CMD_R_CAPS_G(x) \
+	(((x) >> FW_PFVF_CMD_R_CAPS_S) & FW_PFVF_CMD_R_CAPS_M)
+
+#define FW_PFVF_CMD_WX_CAPS_S           16
+#define FW_PFVF_CMD_WX_CAPS_M           0xff
+#define FW_PFVF_CMD_WX_CAPS_V(x)	((x) << FW_PFVF_CMD_WX_CAPS_S)
+#define FW_PFVF_CMD_WX_CAPS_G(x)	\
+	(((x) >> FW_PFVF_CMD_WX_CAPS_S) & FW_PFVF_CMD_WX_CAPS_M)
+
+#define FW_PFVF_CMD_NETHCTRL_S          0
+#define FW_PFVF_CMD_NETHCTRL_M          0xffff
+#define FW_PFVF_CMD_NETHCTRL_V(x)	((x) << FW_PFVF_CMD_NETHCTRL_S)
+#define FW_PFVF_CMD_NETHCTRL_G(x)	\
+	(((x) >> FW_PFVF_CMD_NETHCTRL_S) & FW_PFVF_CMD_NETHCTRL_M)
 
 enum fw_iq_type {
 	FW_IQ_TYPE_FL_INT_CAP,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 0b42bdd..7c24b50 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1030,10 +1030,10 @@ static int set_rxq_intr_params(struct adapter *adapter, struct sge_rspq *rspq,
 
 		pktcnt_idx = closest_thres(&adapter->sge, cnt);
 		if (rspq->desc && rspq->pktcnt_idx != pktcnt_idx) {
-			v = FW_PARAMS_MNEM(FW_PARAMS_MNEM_DMAQ) |
-			    FW_PARAMS_PARAM_X(
+			v = FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
+			    FW_PARAMS_PARAM_X_V(
 					FW_PARAMS_PARAM_DMAQ_IQ_INTCNTTHRESH) |
-			    FW_PARAMS_PARAM_YZ(rspq->cntxt_id);
+			    FW_PARAMS_PARAM_YZ_V(rspq->cntxt_id);
 			err = t4vf_set_params(adapter, 1, &v, &pktcnt_idx);
 			if (err)
 				return err;
@@ -2184,8 +2184,8 @@ static int adap_init0(struct adapter *adapter)
 	 * firmware won't understand this and we'll just get
 	 * unencapsulated messages ...
 	 */
-	param = FW_PARAMS_MNEM(FW_PARAMS_MNEM_PFVF) |
-		FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_PFVF_CPLFW4MSG_ENCAP);
+	param = FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_PFVF) |
+		FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_PFVF_CPLFW4MSG_ENCAP);
 	val = 1;
 	(void) t4vf_set_params(adapter, 1, &param, &val);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index fae0c95..f2087eb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -443,20 +443,20 @@ int t4vf_get_sge_params(struct adapter *adapter)
 	u32 params[7], vals[7];
 	int v;
 
-	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_CONTROL));
-	params[1] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_HOST_PAGE_SIZE));
-	params[2] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_FL_BUFFER_SIZE0));
-	params[3] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_FL_BUFFER_SIZE1));
-	params[4] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_TIMER_VALUE_0_AND_1));
-	params[5] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_TIMER_VALUE_2_AND_3));
-	params[6] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_TIMER_VALUE_4_AND_5));
+	params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_CONTROL));
+	params[1] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_HOST_PAGE_SIZE));
+	params[2] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_FL_BUFFER_SIZE0));
+	params[3] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_FL_BUFFER_SIZE1));
+	params[4] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_TIMER_VALUE_0_AND_1));
+	params[5] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_TIMER_VALUE_2_AND_3));
+	params[6] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_TIMER_VALUE_4_AND_5));
 	v = t4vf_query_params(adapter, 7, params, vals);
 	if (v)
 		return v;
@@ -479,8 +479,8 @@ int t4vf_get_sge_params(struct adapter *adapter)
 	 * right value.
 	 */
 	if (!is_t4(adapter->params.chip)) {
-		params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-			     FW_PARAMS_PARAM_XYZ(SGE_CONTROL2_A));
+		params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+			     FW_PARAMS_PARAM_XYZ_V(SGE_CONTROL2_A));
 		v = t4vf_query_params(adapter, 1, params, vals);
 		if (v != FW_SUCCESS) {
 			dev_err(adapter->pdev_dev,
@@ -491,10 +491,10 @@ int t4vf_get_sge_params(struct adapter *adapter)
 		sge_params->sge_control2 = vals[0];
 	}
 
-	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_INGRESS_RX_THRESHOLD));
-	params[1] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
-		     FW_PARAMS_PARAM_XYZ(SGE_CONM_CTRL));
+	params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_INGRESS_RX_THRESHOLD));
+	params[1] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ_V(SGE_CONM_CTRL));
 	v = t4vf_query_params(adapter, 2, params, vals);
 	if (v)
 		return v;
@@ -517,8 +517,8 @@ int t4vf_get_vpd_params(struct adapter *adapter)
 	u32 params[7], vals[7];
 	int v;
 
-	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
-		     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_CCLK));
+	params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		     FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_CCLK));
 	v = t4vf_query_params(adapter, 1, params, vals);
 	if (v)
 		return v;
@@ -540,10 +540,10 @@ int t4vf_get_dev_params(struct adapter *adapter)
 	u32 params[7], vals[7];
 	int v;
 
-	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
-		     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_FWREV));
-	params[1] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
-		     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_TPREV));
+	params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		     FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_FWREV));
+	params[1] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		     FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_TPREV));
 	v = t4vf_query_params(adapter, 2, params, vals);
 	if (v)
 		return v;
@@ -659,22 +659,22 @@ int t4vf_get_vfres(struct adapter *adapter)
 	 * Extract VF resource limits and return success.
 	 */
 	word = be32_to_cpu(rpl.niqflint_niq);
-	vfres->niqflint = FW_PFVF_CMD_NIQFLINT_GET(word);
-	vfres->niq = FW_PFVF_CMD_NIQ_GET(word);
+	vfres->niqflint = FW_PFVF_CMD_NIQFLINT_G(word);
+	vfres->niq = FW_PFVF_CMD_NIQ_G(word);
 
 	word = be32_to_cpu(rpl.type_to_neq);
-	vfres->neq = FW_PFVF_CMD_NEQ_GET(word);
-	vfres->pmask = FW_PFVF_CMD_PMASK_GET(word);
+	vfres->neq = FW_PFVF_CMD_NEQ_G(word);
+	vfres->pmask = FW_PFVF_CMD_PMASK_G(word);
 
 	word = be32_to_cpu(rpl.tc_to_nexactf);
-	vfres->tc = FW_PFVF_CMD_TC_GET(word);
-	vfres->nvi = FW_PFVF_CMD_NVI_GET(word);
-	vfres->nexactf = FW_PFVF_CMD_NEXACTF_GET(word);
+	vfres->tc = FW_PFVF_CMD_TC_G(word);
+	vfres->nvi = FW_PFVF_CMD_NVI_G(word);
+	vfres->nexactf = FW_PFVF_CMD_NEXACTF_G(word);
 
 	word = be32_to_cpu(rpl.r_caps_to_nethctrl);
-	vfres->r_caps = FW_PFVF_CMD_R_CAPS_GET(word);
-	vfres->wx_caps = FW_PFVF_CMD_WX_CAPS_GET(word);
-	vfres->nethctrl = FW_PFVF_CMD_NETHCTRL_GET(word);
+	vfres->r_caps = FW_PFVF_CMD_R_CAPS_G(word);
+	vfres->wx_caps = FW_PFVF_CMD_WX_CAPS_G(word);
+	vfres->nethctrl = FW_PFVF_CMD_NETHCTRL_G(word);
 
 	return 0;
 }
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 5f06877..80ad9c5 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -1170,7 +1170,7 @@ csio_hw_fw_halt(struct csio_hw *hw, uint32_t mbox, int32_t force)
 		}
 
 		csio_mb_reset(hw, mbp, CSIO_MB_DEFAULT_TMO,
-			      PIORSTMODE | PIORST, FW_RESET_CMD_HALT(1),
+			      PIORSTMODE | PIORST, FW_RESET_CMD_HALT_F,
 			      NULL);
 
 		if (csio_mb_issue(hw, mbp)) {
@@ -1374,9 +1374,9 @@ csio_hw_fw_config_file(struct csio_hw *hw,
 		      FW_CMD_REQUEST_F |
 		      FW_CMD_READ_F);
 	caps_cmd->cfvalid_to_len16 =
-		htonl(FW_CAPS_CONFIG_CMD_CFVALID |
-		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF(mtype) |
-		      FW_CAPS_CONFIG_CMD_MEMADDR64K_CF(maddr >> 16) |
+		htonl(FW_CAPS_CONFIG_CMD_CFVALID_F |
+		      FW_CAPS_CONFIG_CMD_MEMTYPE_CF_V(mtype) |
+		      FW_CAPS_CONFIG_CMD_MEMADDR64K_CF_V(maddr >> 16) |
 		      FW_LEN16(*caps_cmd));
 
 	if (csio_mb_issue(hw, mbp)) {
@@ -1723,8 +1723,8 @@ csio_hw_check_fwconfig(struct csio_hw *hw, u32 *param)
 	 * Find out whether we're dealing with a version of
 	 * the firmware which has configuration file support.
 	 */
-	_param[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
-		     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_CF));
+	_param[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		     FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_CF));
 
 	csio_mb_params(hw, mbp, CSIO_MB_DEFAULT_TMO, hw->pfn, 0,
 		       ARRAY_SIZE(_param), _param, NULL, false, NULL);
@@ -1781,8 +1781,8 @@ csio_hw_flash_config(struct csio_hw *hw, u32 *fw_cfg_param, char *path)
 		goto leave;
 	}
 
-	mtype = FW_PARAMS_PARAM_Y_GET(*fw_cfg_param);
-	maddr = FW_PARAMS_PARAM_Z_GET(*fw_cfg_param) << 16;
+	mtype = FW_PARAMS_PARAM_Y_G(*fw_cfg_param);
+	maddr = FW_PARAMS_PARAM_Z_G(*fw_cfg_param) << 16;
 
 	ret = csio_memory_write(hw, mtype, maddr,
 				cf->size + value_to_add, cfg_data);
@@ -1871,8 +1871,8 @@ csio_hw_use_fwconfig(struct csio_hw *hw, int reset, u32 *fw_cfg_param)
 			goto bye;
 		}
 	} else {
-		mtype = FW_PARAMS_PARAM_Y_GET(*fw_cfg_param);
-		maddr = FW_PARAMS_PARAM_Z_GET(*fw_cfg_param) << 16;
+		mtype = FW_PARAMS_PARAM_Y_G(*fw_cfg_param);
+		maddr = FW_PARAMS_PARAM_Z_G(*fw_cfg_param) << 16;
 		using_flash = 0;
 	}
 
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index ffa8489..a1e0568 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -85,13 +85,13 @@ csio_mb_hello(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 				       FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
 	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->err_to_clearinit = htonl(
-		FW_HELLO_CMD_MASTERDIS(master == CSIO_MASTER_CANT)	|
-		FW_HELLO_CMD_MASTERFORCE(master == CSIO_MASTER_MUST)	|
-		FW_HELLO_CMD_MBMASTER(master == CSIO_MASTER_MUST ?
-				m_mbox : FW_HELLO_CMD_MBMASTER_MASK)	|
-		FW_HELLO_CMD_MBASYNCNOT(a_mbox) |
-		FW_HELLO_CMD_STAGE(fw_hello_cmd_stage_os) |
-		FW_HELLO_CMD_CLEARINIT);
+		FW_HELLO_CMD_MASTERDIS_V(master == CSIO_MASTER_CANT)	|
+		FW_HELLO_CMD_MASTERFORCE_V(master == CSIO_MASTER_MUST)	|
+		FW_HELLO_CMD_MBMASTER_V(master == CSIO_MASTER_MUST ?
+				m_mbox : FW_HELLO_CMD_MBMASTER_M)	|
+		FW_HELLO_CMD_MBASYNCNOT_V(a_mbox) |
+		FW_HELLO_CMD_STAGE_V(fw_hello_cmd_stage_os) |
+		FW_HELLO_CMD_CLEARINIT_F);
 
 }
 
@@ -118,11 +118,11 @@ csio_mb_process_hello_rsp(struct csio_hw *hw, struct csio_mb *mbp,
 		hw->fwrev = ntohl(rsp->fwrev);
 
 		value = ntohl(rsp->err_to_clearinit);
-		*mpfn = FW_HELLO_CMD_MBMASTER_GET(value);
+		*mpfn = FW_HELLO_CMD_MBMASTER_G(value);
 
-		if (value & FW_HELLO_CMD_INIT)
+		if (value & FW_HELLO_CMD_INIT_F)
 			*state = CSIO_DEV_STATE_INIT;
-		else if (value & FW_HELLO_CMD_ERR)
+		else if (value & FW_HELLO_CMD_ERR_F)
 			*state = CSIO_DEV_STATE_ERR;
 		else
 			*state = CSIO_DEV_STATE_UNINIT;
@@ -205,8 +205,8 @@ csio_mb_params(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_PARAMS_CMD)		|
 				FW_CMD_REQUEST_F			|
 				(wr ? FW_CMD_WRITE_F : FW_CMD_READ_F)	|
-				FW_PARAMS_CMD_PFN(pf)			|
-				FW_PARAMS_CMD_VFN(vf));
+				FW_PARAMS_CMD_PFN_V(pf)			|
+				FW_PARAMS_CMD_VFN_V(vf));
 	cmdp->retval_len16 = htonl(FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	/* Write Params */
@@ -274,11 +274,11 @@ csio_mb_ldst(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo, int reg)
 			htonl(FW_CMD_OP_V(FW_LDST_CMD)	|
 			FW_CMD_REQUEST_F			|
 			FW_CMD_READ_F			|
-			FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_FUNC_PCIE));
+			FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_FUNC_PCIE));
 	ldst_cmd->cycles_to_len16 = htonl(FW_LEN16(struct fw_ldst_cmd));
-	ldst_cmd->u.pcie.select_naccess = FW_LDST_CMD_NACCESS(1);
+	ldst_cmd->u.pcie.select_naccess = FW_LDST_CMD_NACCESS_V(1);
 	ldst_cmd->u.pcie.ctrl_to_fn =
-		(FW_LDST_CMD_LC | FW_LDST_CMD_FN(hw->pfn));
+		(FW_LDST_CMD_LC_F | FW_LDST_CMD_FN_V(hw->pfn));
 	ldst_cmd->u.pcie.r = (uint8_t)reg;
 }
 
diff --git a/drivers/scsi/csiostor/csio_mb.h b/drivers/scsi/csiostor/csio_mb.h
index a84179e..1bc82d0 100644
--- a/drivers/scsi/csiostor/csio_mb.h
+++ b/drivers/scsi/csiostor/csio_mb.h
@@ -79,14 +79,14 @@ enum csio_dev_state {
 };
 
 #define FW_PARAM_DEV(param) \
-	(FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) | \
-	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_##param))
+	(FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) | \
+	 FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_##param))
 
 #define FW_PARAM_PFVF(param) \
-	(FW_PARAMS_MNEM(FW_PARAMS_MNEM_PFVF) | \
-	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_PFVF_##param)|  \
-	 FW_PARAMS_PARAM_Y(0) | \
-	 FW_PARAMS_PARAM_Z(0))
+	(FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_PFVF) | \
+	 FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_PFVF_##param)|  \
+	 FW_PARAMS_PARAM_Y_V(0) | \
+	 FW_PARAMS_PARAM_Z_V(0))
 
 enum {
 	PAUSE_RX      = 1 << 0,
-- 
1.7.1
