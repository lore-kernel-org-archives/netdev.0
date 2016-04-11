From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Stop Rx Queues before freeing it up
Date: Mon, 11 Apr 2016 11:07:58 +0530
Message-ID: <1460353078-949-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:34339 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750760AbcDKFeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 01:34:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stop all Ethernet RX Queues before freeing up various Ingress/Egress
Queues, etc. We were seeing cases of Ingress Queues not getting serviced
during the shutdown process leading to Ingress Paths jamming up through
the chip and blocking the shutdown effort itself.

One such case involved the Firmware sending a "Flush Token" through the
ULP-TX -> ULP-RX path for an Ethernet TX Queue being freed in order to
make sure there weren't any remaining TX Work Requests in the pipeline.
But the return path was stalled by Ingress Data unable to be delivered to
the Host because those Ingress Queues were no longer being serviced.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |  3 +++
 drivers/net/ethernet/chelsio/cxgb4/sge.c   | 20 +++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 33 ++++++++++++++++++++++++++++++
 3 files changed, 53 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 984a3cc26f86..326d4009525e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1451,6 +1451,9 @@ int t4_mdio_rd(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 	       unsigned int mmd, unsigned int reg, u16 *valp);
 int t4_mdio_wr(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
 	       unsigned int mmd, unsigned int reg, u16 val);
+int t4_iq_stop(struct adapter *adap, unsigned int mbox, unsigned int pf,
+	       unsigned int vf, unsigned int iqtype, unsigned int iqid,
+	       unsigned int fl0id, unsigned int fl1id);
 int t4_iq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	       unsigned int vf, unsigned int iqtype, unsigned int iqid,
 	       unsigned int fl0id, unsigned int fl1id);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 13b144bcf725..6278e5a74b74 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2981,14 +2981,28 @@ void t4_free_ofld_rxqs(struct adapter *adap, int n, struct sge_ofld_rxq *q)
 void t4_free_sge_resources(struct adapter *adap)
 {
 	int i;
-	struct sge_eth_rxq *eq = adap->sge.ethrxq;
-	struct sge_eth_txq *etq = adap->sge.ethtxq;
+	struct sge_eth_rxq *eq;
+	struct sge_eth_txq *etq;
+
+	/* stop all Rx queues in order to start them draining */
+	for (i = 0; i < adap->sge.ethqsets; i++) {
+		eq = &adap->sge.ethrxq[i];
+		if (eq->rspq.desc)
+			t4_iq_stop(adap, adap->mbox, adap->pf, 0,
+				   FW_IQ_TYPE_FL_INT_CAP,
+				   eq->rspq.cntxt_id,
+				   eq->fl.size ? eq->fl.cntxt_id : 0xffff,
+				   0xffff);
+	}
 
 	/* clean up Ethernet Tx/Rx queues */
-	for (i = 0; i < adap->sge.ethqsets; i++, eq++, etq++) {
+	for (i = 0; i < adap->sge.ethqsets; i++) {
+		eq = &adap->sge.ethrxq[i];
 		if (eq->rspq.desc)
 			free_rspq_fl(adap, &eq->rspq,
 				     eq->fl.size ? &eq->fl : NULL);
+
+		etq = &adap->sge.ethtxq[i];
 		if (etq->q.desc) {
 			t4_eth_eq_free(adap, adap->mbox, adap->pf, 0,
 				       etq->q.cntxt_id);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index cc1736bece0f..520ffcaef6d8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -6940,6 +6940,39 @@ int t4_identify_port(struct adapter *adap, unsigned int mbox, unsigned int viid,
 }
 
 /**
+ *	t4_iq_stop - stop an ingress queue and its FLs
+ *	@adap: the adapter
+ *	@mbox: mailbox to use for the FW command
+ *	@pf: the PF owning the queues
+ *	@vf: the VF owning the queues
+ *	@iqtype: the ingress queue type (FW_IQ_TYPE_FL_INT_CAP, etc.)
+ *	@iqid: ingress queue id
+ *	@fl0id: FL0 queue id or 0xffff if no attached FL0
+ *	@fl1id: FL1 queue id or 0xffff if no attached FL1
+ *
+ *	Stops an ingress queue and its associated FLs, if any.  This causes
+ *	any current or future data/messages destined for these queues to be
+ *	tossed.
+ */
+int t4_iq_stop(struct adapter *adap, unsigned int mbox, unsigned int pf,
+	       unsigned int vf, unsigned int iqtype, unsigned int iqid,
+	       unsigned int fl0id, unsigned int fl1id)
+{
+	struct fw_iq_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_IQ_CMD) | FW_CMD_REQUEST_F |
+				  FW_CMD_EXEC_F | FW_IQ_CMD_PFN_V(pf) |
+				  FW_IQ_CMD_VFN_V(vf));
+	c.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_IQSTOP_F | FW_LEN16(c));
+	c.type_to_iqandstindex = cpu_to_be32(FW_IQ_CMD_TYPE_V(iqtype));
+	c.iqid = cpu_to_be16(iqid);
+	c.fl0id = cpu_to_be16(fl0id);
+	c.fl1id = cpu_to_be16(fl1id);
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
  *	t4_iq_free - free an ingress queue and its FLs
  *	@adap: the adapter
  *	@mbox: mailbox to use for the FW command
-- 
2.3.4
