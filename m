From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH v2 net-next] cxgb4: Support compressed error vector for T6
Date: Wed,  4 Jan 2017 19:04:20 +0530
Message-ID: <1483536860-2672-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Arjun V <arjun@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>,
        Hariprasad Shenai <hariprasad@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:60758 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030695AbdADNfB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 08:35:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun V <arjun@chelsio.com>

t6fw-1.15.15.0 enabled compressed error vector in cpl_rx_pkt for T6.
Updating driver to take care of these changes.

Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
Signed-off-by: Arjun V <arjun@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
v2: Fixed kbuild errors
---

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h   |  5 +++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c     | 16 ++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c   |  7 +++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h  | 15 +++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |  4 ++++
 5 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 0bce1bf..9a49c42 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -263,6 +263,11 @@ struct tp_params {
 	u32 vlan_pri_map;               /* cached TP_VLAN_PRI_MAP */
 	u32 ingress_config;             /* cached TP_INGRESS_CONFIG */
 
+	/* cached TP_OUT_CONFIG compressed error vector
+	 * and passing outer header info for encapsulated packets.
+	 */
+	int rx_pkt_encap;
+
 	/* TP_VLAN_PRI_MAP Compressed Filter Tuple field offsets.  This is a
 	 * subset of the set of fields which may be present in the Compressed
 	 * Filter Tuple portion of filters and TCP TCB connections.  The
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 9f60647..0fe04b4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2038,13 +2038,20 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	struct sge *s = &q->adap->sge;
 	int cpl_trace_pkt = is_t4(q->adap->params.chip) ?
 			    CPL_TRACE_PKT : CPL_TRACE_PKT_T5;
+	u16 err_vec;
 	struct port_info *pi;
 
 	if (unlikely(*(u8 *)rsp == cpl_trace_pkt))
 		return handle_trace_pkt(q->adap, si);
 
 	pkt = (const struct cpl_rx_pkt *)rsp;
-	csum_ok = pkt->csum_calc && !pkt->err_vec &&
+	/* Compressed error vector is enabled for T6 only */
+	if (q->adap->params.tp.rx_pkt_encap)
+		err_vec = T6_COMPR_RXERR_VEC_G(be16_to_cpu(pkt->err_vec));
+	else
+		err_vec = be16_to_cpu(pkt->err_vec);
+
+	csum_ok = pkt->csum_calc && !err_vec &&
 		  (q->netdev->features & NETIF_F_RXCSUM);
 	if ((pkt->l2info & htonl(RXF_TCP_F)) &&
 	    !(cxgb_poll_busy_polling(q)) &&
@@ -2092,7 +2099,12 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 		if (!(pkt->l2info & cpu_to_be32(CPL_RX_PKT_FLAGS))) {
 			if ((pkt->l2info & cpu_to_be32(RXF_FCOE_F)) &&
 			    (pi->fcoe.flags & CXGB_FCOE_ENABLED)) {
-				if (!(pkt->err_vec & cpu_to_be16(RXERR_CSUM_F)))
+				if (q->adap->params.tp.rx_pkt_encap)
+					csum_ok = err_vec &
+						  T6_COMPR_RXERR_SUM_F;
+				else
+					csum_ok = err_vec & RXERR_CSUM_F;
+				if (!csum_ok)
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
 			}
 		}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 20dec85..b5b32ec 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7686,6 +7686,13 @@ int t4_init_tp_params(struct adapter *adap)
 				 &adap->params.tp.ingress_config, 1,
 				 TP_INGRESS_CONFIG_A);
 	}
+	/* For T6, cache the adapter's compressed error vector
+	 * and passing outer header info for encapsulated packets.
+	 */
+	if (CHELSIO_CHIP_VERSION(adap->params.chip) > CHELSIO_T5) {
+		v = t4_read_reg(adap, TP_OUT_CONFIG_A);
+		adap->params.tp.rx_pkt_encap = (v & CRXPKTENC_F) ? 1 : 0;
+	}
 
 	/* Now that we have TP_VLAN_PRI_MAP cached, we can calculate the field
 	 * shift positions of several elements of the Compressed Filter Tuple
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index fba3b2a..5ce88c9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -1162,6 +1162,21 @@ struct cpl_rx_pkt {
 #define RXERR_CSUM_V(x) ((x) << RXERR_CSUM_S)
 #define RXERR_CSUM_F    RXERR_CSUM_V(1U)
 
+#define T6_COMPR_RXERR_LEN_S    1
+#define T6_COMPR_RXERR_LEN_V(x) ((x) << T6_COMPR_RXERR_LEN_S)
+#define T6_COMPR_RXERR_LEN_F    T6_COMPR_RXERR_LEN_V(1U)
+
+#define T6_COMPR_RXERR_VEC_S    0
+#define T6_COMPR_RXERR_VEC_M    0x3F
+#define T6_COMPR_RXERR_VEC_V(x) ((x) << T6_COMPR_RXERR_LEN_S)
+#define T6_COMPR_RXERR_VEC_G(x) \
+		(((x) >> T6_COMPR_RXERR_VEC_S) & T6_COMPR_RXERR_VEC_M)
+
+/* Logical OR of RX_ERROR_CSUM, RX_ERROR_CSIP */
+#define T6_COMPR_RXERR_SUM_S    4
+#define T6_COMPR_RXERR_SUM_V(x) ((x) << T6_COMPR_RXERR_SUM_S)
+#define T6_COMPR_RXERR_SUM_F    T6_COMPR_RXERR_SUM_V(1U)
+
 struct cpl_trace_pkt {
 	u8 opcode;
 	u8 intf;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 9fea255..e685163 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1276,6 +1276,10 @@
 #define DBGLARPTR_M    0x7fU
 #define DBGLARPTR_V(x) ((x) << DBGLARPTR_S)
 
+#define CRXPKTENC_S    3
+#define CRXPKTENC_V(x) ((x) << CRXPKTENC_S)
+#define CRXPKTENC_F    CRXPKTENC_V(1U)
+
 #define TP_DBG_LA_DATAL_A	0x7ed8
 #define TP_DBG_LA_CONFIG_A	0x7ed4
 #define TP_OUT_CONFIG_A		0x7d04
-- 
2.3.5
