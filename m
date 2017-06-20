From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v4 net-next 2/7] qed: RoCE EDPM to honor PFC
Date: Tue, 20 Jun 2017 16:00:01 +0300
Message-ID: <20170620130006.307-3-Yuval.Mintz@cavium.com>
References: <20170620130006.307-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Michal.Kalderon@cavium.com>, <linux-rdma@vger.kernel.org>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0057.outbound.protection.outlook.com ([104.47.40.57]:28889
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751090AbdFTNBb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 09:01:31 -0400
In-Reply-To: <20170620130006.307-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configure device according to DCBx results so that EDPMs
made by RoCE would honor flow-control.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c     | 16 ++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |  6 ++++++
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index e2a62c0..15b516a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -896,6 +896,22 @@ qed_dcbx_mib_update_event(struct qed_hwfn *p_hwfn,
 	}
 
 	qed_dcbx_get_params(p_hwfn, &p_hwfn->p_dcbx_info->get, type);
+
+	if (type == QED_DCBX_OPERATIONAL_MIB) {
+		struct qed_dcbx_results *p_data;
+		u16 val;
+
+		/* Configure in NIG which protocols support EDPM and should
+		 * honor PFC.
+		 */
+		p_data = &p_hwfn->p_dcbx_info->results;
+		val = (0x1 << p_data->arr[DCBX_PROTOCOL_ROCE].tc) |
+		      (0x1 << p_data->arr[DCBX_PROTOCOL_ROCE_V2].tc);
+		val <<= NIG_REG_TX_EDPM_CTRL_TX_EDPM_TC_EN_SHIFT;
+		val |= NIG_REG_TX_EDPM_CTRL_TX_EDPM_EN;
+		qed_wr(p_hwfn, p_ptt, NIG_REG_TX_EDPM_CTRL, val);
+	}
+
 	qed_dcbx_aen(p_hwfn, type);
 
 	return rc;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index 7e4639c..0cdb433 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -1564,6 +1564,12 @@
 #define NIG_REG_TSGEN_FREECNT_UPDATE_K2 0x509008UL
 #define CNIG_REG_NIG_PORT0_CONF_K2 0x218200UL
 
+#define NIG_REG_TX_EDPM_CTRL 0x501f0cUL
+#define NIG_REG_TX_EDPM_CTRL_TX_EDPM_EN (0x1 << 0)
+#define NIG_REG_TX_EDPM_CTRL_TX_EDPM_EN_SHIFT 0
+#define NIG_REG_TX_EDPM_CTRL_TX_EDPM_TC_EN (0xff << 1)
+#define NIG_REG_TX_EDPM_CTRL_TX_EDPM_TC_EN_SHIFT 1
+
 #define PRS_REG_SEARCH_GFT 0x1f11bcUL
 #define PRS_REG_CM_HDR_GFT 0x1f11c8UL
 #define PRS_REG_GFT_CAM 0x1f1100UL
-- 
2.9.4
