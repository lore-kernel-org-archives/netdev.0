From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 2/6] cxgb4: Enable congestion notification from SGE for IQs and FLs.
Date: Tue,  5 May 2015 14:59:52 +0530
Message-ID: <1430818196-26508-3-git-send-email-hariprasad@chelsio.com>
References: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5432 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751438AbbEEER0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 00:17:26 -0400
In-Reply-To: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also changed the name of t4_hw.c:get_mps_bg_map() to t4_get_mps_bg_map()
and make it an exported routine with a definition in cxgb4.h.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  3 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 10 ++++++----
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 20 +++++++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  6 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  2 ++
 5 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 524d110..b6fa958 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1055,7 +1055,7 @@ int t4_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 int t4_ofld_send(struct adapter *adap, struct sk_buff *skb);
 int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		     struct net_device *dev, int intr_idx,
-		     struct sge_fl *fl, rspq_handler_t hnd);
+		     struct sge_fl *fl, rspq_handler_t hnd, int cong);
 int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 			 struct net_device *dev, struct netdev_queue *netdevq,
 			 unsigned int iqid);
@@ -1215,6 +1215,7 @@ int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 	       u64 *parity);
 int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 		u64 *parity);
+unsigned int t4_get_mps_bg_map(struct adapter *adapter, int idx);
 void t4_pmtx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[]);
 void t4_pmrx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[]);
 int t4_read_cim_ibq(struct adapter *adap, unsigned int qid, u32 *data,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 803d91b..12cd8e4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -977,7 +977,7 @@ static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
 		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
 				       adap->port[i / per_chan],
 				       msi_idx, q->fl.size ? &q->fl : NULL,
-				       uldrx_handler);
+				       uldrx_handler, 0);
 		if (err)
 			return err;
 		memset(&q->stats, 0, sizeof(q->stats));
@@ -1007,7 +1007,7 @@ static int setup_sge_queues(struct adapter *adap)
 		msi_idx = 1;         /* vector 0 is for non-queue interrupts */
 	else {
 		err = t4_sge_alloc_rxq(adap, &s->intrq, false, adap->port[0], 0,
-				       NULL, NULL);
+				       NULL, NULL, -1);
 		if (err)
 			return err;
 		msi_idx = -((int)s->intrq.abs_id + 1);
@@ -1027,7 +1027,7 @@ static int setup_sge_queues(struct adapter *adap)
 	 *    new/deleted queues.
 	 */
 	err = t4_sge_alloc_rxq(adap, &s->fw_evtq, true, adap->port[0],
-			       msi_idx, NULL, fwevtq_handler);
+			       msi_idx, NULL, fwevtq_handler, -1);
 	if (err) {
 freeout:	t4_free_sge_resources(adap);
 		return err;
@@ -1044,7 +1044,9 @@ freeout:	t4_free_sge_resources(adap);
 				msi_idx++;
 			err = t4_sge_alloc_rxq(adap, &q->rspq, false, dev,
 					       msi_idx, &q->fl,
-					       t4_ethrx_handler);
+					       t4_ethrx_handler,
+					       t4_get_mps_bg_map(adap,
+								 pi->tx_chan));
 			if (err)
 				goto freeout;
 			q->rspq.idx = j;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 517d5b4..6397d6c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2437,9 +2437,12 @@ static void __iomem *bar2_address(struct adapter *adapter,
 	return adapter->bar2 + bar2_qoffset;
 }
 
+/* @intr_idx: MSI/MSI-X vector if >=0, -(absolute qid + 1) if < 0
+ * @cong: < 0 -> no congestion feedback, >= 0 -> congestion channel map
+ */
 int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		     struct net_device *dev, int intr_idx,
-		     struct sge_fl *fl, rspq_handler_t hnd)
+		     struct sge_fl *fl, rspq_handler_t hnd, int cong)
 {
 	int ret, flsz = 0;
 	struct fw_iq_cmd c;
@@ -2471,6 +2474,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		FW_IQ_CMD_IQESIZE_V(ilog2(iq->iqe_len) - 4));
 	c.iqsize = htons(iq->size);
 	c.iqaddr = cpu_to_be64(iq->phys_addr);
+	if (cong >= 0)
+		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_IQFLINTCONGEN_F);
 
 	if (fl) {
 		/* Allocate the ring for the hardware free list (with space
@@ -2490,10 +2495,15 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 			goto fl_nomem;
 
 		flsz = fl->size / 8 + s->stat_len / sizeof(struct tx_desc);
-		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_FL0PACKEN_F |
-					    FW_IQ_CMD_FL0FETCHRO_F |
-					    FW_IQ_CMD_FL0DATARO_F |
-					    FW_IQ_CMD_FL0PADEN_F);
+		c.iqns_to_fl0congen |= htonl(FW_IQ_CMD_FL0PACKEN_F |
+					     FW_IQ_CMD_FL0FETCHRO_F |
+					     FW_IQ_CMD_FL0DATARO_F |
+					     FW_IQ_CMD_FL0PADEN_F);
+		if (cong >= 0)
+			c.iqns_to_fl0congen |=
+				htonl(FW_IQ_CMD_FL0CNGCHMAP_V(cong) |
+				      FW_IQ_CMD_FL0CONGCIF_F |
+				      FW_IQ_CMD_FL0CONGEN_F);
 		c.fl0dcaen_to_fl0cidxfthresh = htons(FW_IQ_CMD_FL0FBMIN_V(2) |
 				FW_IQ_CMD_FL0FBMAX_V(3));
 		c.fl0size = htons(flsz);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index e8578a7..8ba91c3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3401,7 +3401,7 @@ void t4_pmrx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[])
 }
 
 /**
- *	get_mps_bg_map - return the buffer groups associated with a port
+ *	t4_get_mps_bg_map - return the buffer groups associated with a port
  *	@adap: the adapter
  *	@idx: the port index
  *
@@ -3409,7 +3409,7 @@ void t4_pmrx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[])
  *	with the given port.  Bit i is set if buffer group i is used by the
  *	port.
  */
-static unsigned int get_mps_bg_map(struct adapter *adap, int idx)
+unsigned int t4_get_mps_bg_map(struct adapter *adap, int idx)
 {
 	u32 n = NUMPORTS_G(t4_read_reg(adap, MPS_CMN_CTL_A));
 
@@ -3460,7 +3460,7 @@ const char *t4_get_port_type_description(enum fw_port_type port_type)
  */
 void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p)
 {
-	u32 bgmap = get_mps_bg_map(adap, idx);
+	u32 bgmap = t4_get_mps_bg_map(adap, idx);
 
 #define GET_STAT(name) \
 	t4_read_reg64(adap, \
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 03fbfd1..e34efb7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1377,6 +1377,7 @@ struct fw_iq_cmd {
 
 #define FW_IQ_CMD_IQFLINTCONGEN_S	27
 #define FW_IQ_CMD_IQFLINTCONGEN_V(x)	((x) << FW_IQ_CMD_IQFLINTCONGEN_S)
+#define FW_IQ_CMD_IQFLINTCONGEN_F	FW_IQ_CMD_IQFLINTCONGEN_V(1U)
 
 #define FW_IQ_CMD_IQFLINTISCSIC_S	26
 #define FW_IQ_CMD_IQFLINTISCSIC_V(x)	((x) << FW_IQ_CMD_IQFLINTISCSIC_S)
@@ -1399,6 +1400,7 @@ struct fw_iq_cmd {
 
 #define FW_IQ_CMD_FL0CONGCIF_S		11
 #define FW_IQ_CMD_FL0CONGCIF_V(x)	((x) << FW_IQ_CMD_FL0CONGCIF_S)
+#define FW_IQ_CMD_FL0CONGCIF_F		FW_IQ_CMD_FL0CONGCIF_V(1U)
 
 #define FW_IQ_CMD_FL0ONCHIP_S		10
 #define FW_IQ_CMD_FL0ONCHIP_V(x)	((x) << FW_IQ_CMD_FL0ONCHIP_S)
-- 
2.3.4
