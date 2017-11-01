From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 1/7] cxgb4: save additional filter tuple field shifts in tp_params
Date: Wed,  1 Nov 2017 08:52:59 +0530
Message-ID: <d930a7b7d79824fcbc9cbcb20cf75f7ede5e5a04.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:28909 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdKADYp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:24:45 -0400
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Save additional filter tuple field shifts in tp_params based on
configured filter tuple fields.

Also, save the combined filter tuple mask based on configured
filter tuple fields.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h   | 12 ++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c   | 18 ++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |  3 +++
 3 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index a57761b28edc..e2c75b73595f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -287,10 +287,18 @@ struct tp_params {
 	 * places we store their offsets here, or a -1 if the field isn't
 	 * present.
 	 */
-	int vlan_shift;
-	int vnic_shift;
+	int fcoe_shift;
 	int port_shift;
+	int vnic_shift;
+	int vlan_shift;
+	int tos_shift;
 	int protocol_shift;
+	int ethertype_shift;
+	int macmatch_shift;
+	int matchtype_shift;
+	int frag_shift;
+
+	u64 hash_filter_mask;
 };
 
 struct vpd_params {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c289ca1efc1b..efe9d3a20135 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -8816,11 +8816,21 @@ int t4_init_tp_params(struct adapter *adap, bool sleep_ok)
 	 * shift positions of several elements of the Compressed Filter Tuple
 	 * for this adapter which we need frequently ...
 	 */
-	adap->params.tp.vlan_shift = t4_filter_field_shift(adap, VLAN_F);
-	adap->params.tp.vnic_shift = t4_filter_field_shift(adap, VNIC_ID_F);
+	adap->params.tp.fcoe_shift = t4_filter_field_shift(adap, FCOE_F);
 	adap->params.tp.port_shift = t4_filter_field_shift(adap, PORT_F);
+	adap->params.tp.vnic_shift = t4_filter_field_shift(adap, VNIC_ID_F);
+	adap->params.tp.vlan_shift = t4_filter_field_shift(adap, VLAN_F);
+	adap->params.tp.tos_shift = t4_filter_field_shift(adap, TOS_F);
 	adap->params.tp.protocol_shift = t4_filter_field_shift(adap,
 							       PROTOCOL_F);
+	adap->params.tp.ethertype_shift = t4_filter_field_shift(adap,
+								ETHERTYPE_F);
+	adap->params.tp.macmatch_shift = t4_filter_field_shift(adap,
+							       MACMATCH_F);
+	adap->params.tp.matchtype_shift = t4_filter_field_shift(adap,
+								MPSHITTYPE_F);
+	adap->params.tp.frag_shift = t4_filter_field_shift(adap,
+							   FRAGMENTATION_F);
 
 	/* If TP_INGRESS_CONFIG.VNID == 0, then TP_VLAN_PRI_MAP.VNIC_ID
 	 * represents the presence of an Outer VLAN instead of a VNIC ID.
@@ -8828,6 +8838,10 @@ int t4_init_tp_params(struct adapter *adap, bool sleep_ok)
 	if ((adap->params.tp.ingress_config & VNIC_F) == 0)
 		adap->params.tp.vnic_shift = -1;
 
+	v = t4_read_reg(adap, LE_3_DB_HASH_MASK_GEN_IPV4_T6_A);
+	adap->params.tp.hash_filter_mask = v;
+	v = t4_read_reg(adap, LE_4_DB_HASH_MASK_GEN_IPV4_T6_A);
+	adap->params.tp.hash_filter_mask |= ((u64)v << 32);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 483fb7644355..44713bad0045 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2933,6 +2933,9 @@
 #define SSRAMINTPERR_V(x) ((x) << SSRAMINTPERR_S)
 #define SSRAMINTPERR_F    SSRAMINTPERR_V(1U)
 
+#define LE_3_DB_HASH_MASK_GEN_IPV4_T6_A	0x19eac
+#define LE_4_DB_HASH_MASK_GEN_IPV4_T6_A	0x19eb0
+
 #define NCSI_INT_CAUSE_A 0x1a0d8
 
 #define CIM_DM_PRTY_ERR_S    8
-- 
2.14.1
