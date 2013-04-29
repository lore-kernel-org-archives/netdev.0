From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net 2/3] cxgb4: Support CPL_SGE_EGR_UPDATEs encapsulated in a CPL_FW4_MSG
Date: Mon, 29 Apr 2013 19:34:40 +0530
Message-ID: <1367244281-23043-3-git-send-email-vipul@chelsio.com>
References: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, leedom@chelsio.com,
	swise@opengridcomputing.com, Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16564 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757698Ab3D2OLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 10:11:02 -0400
In-Reply-To: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer firmware can post CPL_SGE_EGR_UPDATE message encapsulated in a
CPL_FW4_MSG as follows

flit0 rss_header (if DropRSS == 0 in IQ context)
flit1 CPL_FW4_MSG cpl
flit2 rss_header w/opcode CPL_SGE_EGR_UPDATE
flit3 CPL_SGE_EGR_UPDATE cpl

So FW4_MSG CPLs with a newly created type of FW_TYPE_RSSCPL have the
CPL_SGE_EGR_UPDATE CPL message in flit 2 of the FW4_MSG. Firmware can still
post regular CPL_SGE_EGR_UPDATE messages, so the drivers need to handle
both.

This patch also writes a new parameter to firmware requesting encapsulated
EGR_UPDATE. This allows firmware with this support to not break older drivers.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 31 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     | 10 +++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   | 38 +++++++++++++++++++++++--
 3 files changed, 76 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 656f934..c59ec3d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -645,6 +645,21 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 	u8 opcode = ((const struct rss_header *)rsp)->opcode;
 
 	rsp++;                                          /* skip RSS header */
+
+	/* FW can send EGR_UPDATEs encapsulated in a CPL_FW4_MSG.
+	 */
+	if (unlikely(opcode == CPL_FW4_MSG &&
+	   ((const struct cpl_fw4_msg *)rsp)->type == FW_TYPE_RSSCPL)) {
+		rsp++;
+		opcode = ((const struct rss_header *)rsp)->opcode;
+		rsp++;
+		if (opcode != CPL_SGE_EGR_UPDATE) {
+			dev_err(q->adap->pdev_dev, "unexpected FW4/CPL %#x on FW event queue\n"
+				, opcode);
+			goto out;
+		}
+	}
+
 	if (likely(opcode == CPL_SGE_EGR_UPDATE)) {
 		const struct cpl_sge_egr_update *p = (void *)rsp;
 		unsigned int qid = EGR_QID(ntohl(p->opcode_qid));
@@ -679,6 +694,7 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 	} else
 		dev_err(q->adap->pdev_dev,
 			"unexpected CPL %#x on FW event queue\n", opcode);
+out:
 	return 0;
 }
 
@@ -696,6 +712,12 @@ static int uldrx_handler(struct sge_rspq *q, const __be64 *rsp,
 {
 	struct sge_ofld_rxq *rxq = container_of(q, struct sge_ofld_rxq, rspq);
 
+	/* FW can send CPLs encapsulated in a CPL_FW4_MSG.
+	 */
+	if (((const struct rss_header *)rsp)->opcode == CPL_FW4_MSG &&
+	    ((const struct cpl_fw4_msg *)(rsp + 1))->type == FW_TYPE_RSSCPL)
+		rsp += 2;
+
 	if (ulds[q->uld].rx_handler(q->adap->uld_handle[q->uld], rsp, gl)) {
 		rxq->stats.nomem++;
 		return -1;
@@ -4990,6 +5012,15 @@ static int adap_init0(struct adapter *adap)
 		adap->tids.aftid_end = val[1];
 	}
 
+	/* If we're running on newer firmware, let it know that we're
+	 * prepared to deal with encapsulated CPL messages.  Older
+	 * firmware won't understand this and we'll just get
+	 * unencapsulated messages ...
+	 */
+	params[0] = FW_PARAM_PFVF(CPLFW4MSG_ENCAP);
+	val[0] = 1;
+	(void) t4_set_params(adap, adap->mbox, adap->fn, 0, 1, params, val);
+
 	/*
 	 * Get device capabilities so we can determine what resources we need
 	 * to manage.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 47656ac..357e297 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -688,6 +688,15 @@ struct cpl_sge_egr_update {
 	__be16 pidx;
 };
 
+/* cpl_fw*.type values */
+enum {
+	FW_TYPE_CMD_RPL = 0,
+	FW_TYPE_WR_RPL = 1,
+	FW_TYPE_CQE = 2,
+	FW_TYPE_OFLD_CONNECTION_WR_RPL = 3,
+	FW_TYPE_RSSCPL = 4,
+};
+
 struct cpl_fw4_pld {
 	u8 opcode;
 	u8 rsvd0[3];
@@ -737,6 +746,7 @@ enum {
 	FW6_TYPE_WR_RPL = 1,
 	FW6_TYPE_CQE = 2,
 	FW6_TYPE_OFLD_CONNECTION_WR_RPL = 3,
+	FW6_TYPE_RSSCPL = FW_TYPE_RSSCPL,
 };
 
 struct cpl_fw6_msg_ofld_connection_wr_rpl {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 9344432..d1c755f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -973,7 +973,9 @@ enum fw_params_param_pfvf {
 	FW_PARAMS_PARAM_PFVF_EQ_START	= 0x2B,
 	FW_PARAMS_PARAM_PFVF_EQ_END	= 0x2C,
 	FW_PARAMS_PARAM_PFVF_ACTIVE_FILTER_START = 0x2D,
-	FW_PARAMS_PARAM_PFVF_ACTIVE_FILTER_END = 0x2E
+	FW_PARAMS_PARAM_PFVF_ACTIVE_FILTER_END = 0x2E,
+	FW_PARAMS_PARAM_PFVF_ETHOFLD_END = 0x30,
+	FW_PARAMS_PARAM_PFVF_CPLFW4MSG_ENCAP = 0x31
 };
 
 /*
@@ -1758,6 +1760,25 @@ enum fw_port_module_type {
 	FW_PORT_MOD_TYPE_NONE = FW_PORT_CMD_MODTYPE_MASK
 };
 
+enum fw_port_mod_sub_type {
+	FW_PORT_MOD_SUB_TYPE_NA,
+	FW_PORT_MOD_SUB_TYPE_MV88E114X = 0x1,
+	FW_PORT_MOD_SUB_TYPE_TN8022 = 0x2,
+	FW_PORT_MOD_SUB_TYPE_AQ1202 = 0x3,
+	FW_PORT_MOD_SUB_TYPE_88x3120 = 0x4,
+	FW_PORT_MOD_SUB_TYPE_BCM84834 = 0x5,
+	FW_PORT_MOD_SUB_TYPE_BT_VSC8634 = 0x8,
+
+	/* The following will never been in the VPD.  They are TWINAX cable
+	 * lengths decoded from SFP+ module i2c PROMs.  These should
+	 * almost certainly go somewhere else ...
+	 */
+	FW_PORT_MOD_SUB_TYPE_TWINAX_1 = 0x9,
+	FW_PORT_MOD_SUB_TYPE_TWINAX_3 = 0xA,
+	FW_PORT_MOD_SUB_TYPE_TWINAX_5 = 0xB,
+	FW_PORT_MOD_SUB_TYPE_TWINAX_7 = 0xC,
+};
+
 /* port stats */
 #define FW_NUM_PORT_STATS 50
 #define FW_NUM_PORT_TX_STATS 23
@@ -2123,11 +2144,11 @@ struct fw_hdr {
 	u8 intfver_ri;
 	u8 intfver_iscsipdu;
 	u8 intfver_iscsi;
+	u8 intfver_fcoepdu;
 	u8 intfver_fcoe;
-	u8 reserved2;
+	__u32   reserved2;
 	__u32   reserved3;
 	__u32   reserved4;
-	__u32   reserved5;
 	__be32  flags;
 	__be32  reserved6[23];
 };
@@ -2137,6 +2158,17 @@ struct fw_hdr {
 #define FW_HDR_FW_VER_MICRO_GET(x) (((x) >> 8) & 0xff)
 #define FW_HDR_FW_VER_BUILD_GET(x) (((x) >> 0) & 0xff)
 
+enum fw_hdr_intfver {
+	FW_HDR_INTFVER_NIC      = 0x00,
+	FW_HDR_INTFVER_VNIC     = 0x00,
+	FW_HDR_INTFVER_OFLD     = 0x00,
+	FW_HDR_INTFVER_RI       = 0x00,
+	FW_HDR_INTFVER_ISCSIPDU = 0x00,
+	FW_HDR_INTFVER_ISCSI    = 0x00,
+	FW_HDR_INTFVER_FCOEPDU  = 0x00,
+	FW_HDR_INTFVER_FCOE     = 0x00,
+};
+
 enum fw_hdr_flags {
 	FW_HDR_FLAGS_RESET_HALT = 0x00000001,
 };
-- 
1.8.0
