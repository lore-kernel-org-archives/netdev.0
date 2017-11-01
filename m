From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 2/7] cxgb4: initialize hash-filter configuration
Date: Wed,  1 Nov 2017 08:53:00 +0530
Message-ID: <82377e2ad48428096fbd315111f9967d10398e5f.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:22086 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdKADYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:24:48 -0400
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Add support for hash-filter configuration on T6. Also, do basic
checks for the related initialization.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        |  6 ++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c | 22 ++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   | 14 ++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h      | 14 ++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h     |  1 +
 6 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index e2c75b73595f..5f021e6062b0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -366,6 +366,7 @@ struct adapter_params {
 	unsigned char crypto;		/* HW capability for crypto */
 
 	unsigned char bypass;
+	unsigned char hash_filter;
 
 	unsigned int ofldq_wr_cred;
 	bool ulptx_memwrite_dsgl;          /* use of T5 DSGL allowed */
@@ -1140,6 +1141,11 @@ static inline int is_offload(const struct adapter *adap)
 	return adap->params.offload;
 }
 
+static inline int is_hashfilter(const struct adapter *adap)
+{
+	return adap->params.hash_filter;
+}
+
 static inline int is_pci_uld(const struct adapter *adap)
 {
 	return adap->params.crypto;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index 89272f29f807..566bd2d3737c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -915,3 +915,25 @@ void filter_rpl(struct adapter *adap, const struct cpl_set_tcb_rpl *rpl)
 			complete(&ctx->completion);
 	}
 }
+
+int init_hash_filter(struct adapter *adap)
+{
+	/* On T6, verify the necessary register configs and warn the user in
+	 * case of improper config
+	 */
+	if (is_t6(adap->params.chip)) {
+		if (TCAM_ACTV_HIT_G(t4_read_reg(adap, LE_DB_RSP_CODE_0_A)) != 4)
+			goto err;
+
+		if (HASH_ACTV_HIT_G(t4_read_reg(adap, LE_DB_RSP_CODE_1_A)) != 4)
+			goto err;
+	} else {
+		dev_err(adap->pdev_dev, "Hash filter supported only on T6\n");
+		return -EINVAL;
+	}
+	adap->params.hash_filter = 1;
+	return 0;
+err:
+	dev_warn(adap->pdev_dev, "Invalid hash filter config!\n");
+	return -EINVAL;
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
index 23742cb1c69f..d3c1a8fafd32 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
@@ -45,4 +45,5 @@ int delete_filter(struct adapter *adapter, unsigned int fidx);
 
 int writable_filter(struct filter_entry *f);
 void clear_all_filters(struct adapter *adapter);
+int init_hash_filter(struct adapter *adap);
 #endif /* __CXGB4_FILTER_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e16078ddb39f..4b07cfe8c66c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3963,7 +3963,8 @@ static int adap_init0(struct adapter *adap)
 	if (ret < 0)
 		goto bye;
 
-	if (caps_cmd.ofldcaps) {
+	if (caps_cmd.ofldcaps ||
+	    (caps_cmd.niccaps & htons(FW_CAPS_CONFIG_NIC_HASHFILTER))) {
 		/* query offload-related parameters */
 		params[0] = FW_PARAM_DEV(NTID);
 		params[1] = FW_PARAM_PFVF(SERVER_START);
@@ -4000,8 +4001,13 @@ static int adap_init0(struct adapter *adap)
 		adap->vres.ddp.size = val[4] - val[3] + 1;
 		adap->params.ofldq_wr_cred = val[5];
 
-		adap->params.offload = 1;
-		adap->num_ofld_uld += 1;
+		if (caps_cmd.niccaps & htons(FW_CAPS_CONFIG_NIC_HASHFILTER)) {
+			if (init_hash_filter(adap) < 0)
+				goto bye;
+		} else {
+			adap->params.offload = 1;
+			adap->num_ofld_uld += 1;
+		}
 	}
 	if (caps_cmd.rdmacaps) {
 		params[0] = FW_PARAM_PFVF(STAG_START);
@@ -5171,7 +5177,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		cxgb4_init_tc_flower(adapter);
 	}
 
-	if (is_offload(adapter)) {
+	if (is_offload(adapter) || is_hashfilter(adapter)) {
 		if (t4_read_reg(adapter, LE_DB_CONFIG_A) & HASHEN_F) {
 			u32 hash_base, hash_reg;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 44713bad0045..623f453bd327 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2933,6 +2933,20 @@
 #define SSRAMINTPERR_V(x) ((x) << SSRAMINTPERR_S)
 #define SSRAMINTPERR_F    SSRAMINTPERR_V(1U)
 
+#define LE_DB_RSP_CODE_0_A	0x19c74
+
+#define TCAM_ACTV_HIT_S		0
+#define TCAM_ACTV_HIT_M		0x1fU
+#define TCAM_ACTV_HIT_V(x)	((x) << TCAM_ACTV_HIT_S)
+#define TCAM_ACTV_HIT_G(x)	(((x) >> TCAM_ACTV_HIT_S) & TCAM_ACTV_HIT_M)
+
+#define LE_DB_RSP_CODE_1_A     0x19c78
+
+#define HASH_ACTV_HIT_S		25
+#define HASH_ACTV_HIT_M		0x1fU
+#define HASH_ACTV_HIT_V(x)	((x) << HASH_ACTV_HIT_S)
+#define HASH_ACTV_HIT_G(x)	(((x) >> HASH_ACTV_HIT_S) & HASH_ACTV_HIT_M)
+
 #define LE_3_DB_HASH_MASK_GEN_IPV4_T6_A	0x19eac
 #define LE_4_DB_HASH_MASK_GEN_IPV4_T6_A	0x19eb0
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 2ba890926c73..57eb4ad3485d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1092,6 +1092,7 @@ enum fw_caps_config_switch {
 enum fw_caps_config_nic {
 	FW_CAPS_CONFIG_NIC		= 0x00000001,
 	FW_CAPS_CONFIG_NIC_VM		= 0x00000002,
+	FW_CAPS_CONFIG_NIC_HASHFILTER	= 0x00000020,
 };
 
 enum fw_caps_config_ofld {
-- 
2.14.1
