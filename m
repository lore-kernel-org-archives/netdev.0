From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 3/6] cxgb4: Pass in a Congestion Channel Map to t4_sge_alloc_rxq()
Date: Tue,  5 May 2015 14:59:53 +0530
Message-ID: <1430818196-26508-4-git-send-email-hariprasad@chelsio.com>
References: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15508 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751528AbbEEER3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 00:17:29 -0400
In-Reply-To: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passes a Congestion Channel Map to t4_sge_alloc_rxq()
for the Ethernet RX Queues based on the MPS Buffer Group Map
of the TX Channel rather than just the TX Channel Map.
Also, in t4_sge_alloc_rxq() for T5, setting up the
Congestion Manager values of the new RX Ethernet Queue is
done by firmware now.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c       | 35 ++++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h |  9 +++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h  |  1 +
 3 files changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 6397d6c..a9002b1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2551,6 +2551,41 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 					     &fl->bar2_qid);
 		refill_fl(adap, fl, fl_cap(fl), GFP_KERNEL);
 	}
+
+	/* For T5 and later we attempt to set up the Congestion Manager values
+	 * of the new RX Ethernet Queue.  This should really be handled by
+	 * firmware because it's more complex than any host driver wants to
+	 * get involved with and it's different per chip and this is almost
+	 * certainly wrong.  Firmware would be wrong as well, but it would be
+	 * a lot easier to fix in one place ...  For now we do something very
+	 * simple (and hopefully less wrong).
+	 */
+	if (!is_t4(adap->params.chip) && cong >= 0) {
+		u32 param, val;
+		int i;
+
+		param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
+			 FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DMAQ_CONM_CTXT) |
+			 FW_PARAMS_PARAM_YZ_V(iq->cntxt_id));
+		if (cong == 0) {
+			val = CONMCTXT_CNGTPMODE_V(CONMCTXT_CNGTPMODE_QUEUE_X);
+		} else {
+			val =
+			    CONMCTXT_CNGTPMODE_V(CONMCTXT_CNGTPMODE_CHANNEL_X);
+			for (i = 0; i < 4; i++) {
+				if (cong & (1 << i))
+					val |=
+					     CONMCTXT_CNGCHMAP_V(1 << (i << 2));
+			}
+		}
+		ret = t4_set_params(adap, adap->mbox, adap->fn, 0, 1,
+				    &param, &val);
+		if (ret)
+			dev_warn(adap->pdev_dev, "Failed to set Congestion"
+				 " Manager Context for Ingress Queue %d: %d\n",
+				 iq->cntxt_id, -ret);
+	}
+
 	return 0;
 
 fl_nomem:
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index 19b2dcf..c4d9952 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -61,6 +61,15 @@
 #define SGE_TIMERREGS			6
 #define TIMERREG_COUNTER0_X		0
 
+/* Congestion Manager Definitions.
+ */
+#define CONMCTXT_CNGTPMODE_S		19
+#define CONMCTXT_CNGTPMODE_V(x)		((x) << CONMCTXT_CNGTPMODE_S)
+#define CONMCTXT_CNGCHMAP_S		0
+#define CONMCTXT_CNGCHMAP_V(x)		((x) << CONMCTXT_CNGCHMAP_S)
+#define CONMCTXT_CNGTPMODE_CHANNEL_X	2
+#define CONMCTXT_CNGTPMODE_QUEUE_X	1
+
 /* T5 and later support a new BAR2-based doorbell mechanism for Egress Queues.
  * The User Doorbells are each 128 bytes in length with a Simple Doorbell at
  * offsets 8x and a Write Combining single 64-byte Egress Queue Unit
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index e34efb7..d75fca7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1123,6 +1123,7 @@ enum fw_params_param_dmaq {
 	FW_PARAMS_PARAM_DMAQ_EQ_CMPLIQID_CTRL = 0x11,
 	FW_PARAMS_PARAM_DMAQ_EQ_SCHEDCLASS_ETH = 0x12,
 	FW_PARAMS_PARAM_DMAQ_EQ_DCBPRIO_ETH = 0x13,
+	FW_PARAMS_PARAM_DMAQ_CONM_CTXT = 0x20,
 };
 
 enum fw_params_param_dev_diag {
-- 
2.3.4
