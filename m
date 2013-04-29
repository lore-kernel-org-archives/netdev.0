From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net 3/3] cxgb4vf: Support CPL_SGE_EGR_UPDATEs encapsulated in a CPL_FW4_MSG
Date: Mon, 29 Apr 2013 19:34:41 +0530
Message-ID: <1367244281-23043-4-git-send-email-vipul@chelsio.com>
References: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, leedom@chelsio.com,
	swise@opengridcomputing.com, Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8512 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758468Ab3D2OLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 10:11:04 -0400
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
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  1 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 25 ++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 357e297..01d4844 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -158,6 +158,7 @@ union opcode_tid {
 };
 
 #define CPL_OPCODE(x) ((x) << 24)
+#define G_CPL_OPCODE(x) (((x) >> 24) & 0xFF)
 #define MK_OPCODE_TID(opcode, tid) (CPL_OPCODE(opcode) | (tid))
 #define OPCODE_TID(cmd) ((cmd)->ot.opcode_tid)
 #define GET_TID(cmd) (ntohl(OPCODE_TID(cmd)) & 0xFFFFFF)
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 73aef76..40c22e7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -409,6 +409,20 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		break;
 	}
 
+	case CPL_FW4_MSG: {
+		/* FW can send EGR_UPDATEs encapsulated in a CPL_FW4_MSG.
+		 */
+		const struct cpl_sge_egr_update *p = (void *)(rsp + 3);
+		opcode = G_CPL_OPCODE(ntohl(p->opcode_qid));
+		if (opcode != CPL_SGE_EGR_UPDATE) {
+			dev_err(adapter->pdev_dev, "unexpected FW4/CPL %#x on FW event queue\n"
+				, opcode);
+			break;
+		}
+		cpl = (void *)p;
+		/*FALLTHROUGH*/
+	}
+
 	case CPL_SGE_EGR_UPDATE: {
 		/*
 		 * We've received an Egress Queue Status Update message.  We
@@ -2072,6 +2086,7 @@ static int adap_init0(struct adapter *adapter)
 	struct sge *s = &adapter->sge;
 	unsigned int ethqsets;
 	int err;
+	u32 param, val = 0;
 
 	/*
 	 * Wait for the device to become ready before proceeding ...
@@ -2153,6 +2168,16 @@ static int adap_init0(struct adapter *adapter)
 		return err;
 	}
 
+	/* If we're running on newer firmware, let it know that we're
+	 * prepared to deal with encapsulated CPL messages.  Older
+	 * firmware won't understand this and we'll just get
+	 * unencapsulated messages ...
+	 */
+	param = FW_PARAMS_MNEM(FW_PARAMS_MNEM_PFVF) |
+		FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_PFVF_CPLFW4MSG_ENCAP);
+	val = 1;
+	(void) t4vf_set_params(adapter, 1, &param, &val);
+
 	/*
 	 * Retrieve our RX interrupt holdoff timer values and counter
 	 * threshold values from the SGE parameters.
-- 
1.8.0
