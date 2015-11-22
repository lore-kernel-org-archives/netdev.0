From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Utilize FW 7.13.1.0.
Date: Sun, 22 Nov 2015 15:01:29 +0200
Message-ID: <1448197289-18906-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:5078 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751458AbbKVNBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 08:01:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 46e8a249423ff "bnx2x: Add FW 7.13.1.0" added said .bin FW to
linux-firmware; This patch incorporates the FW in the bnx2x driver.

This introduces 2 fixes/enhancements:
 - In some management protocols there are outer-vlan configurations
that can be dynamically changed while device is running. This fixes
some corner cases where such a change did not take effect.

 - Prevent VFs from sending MAC control frames; FW would treat a VF
sending such a packet as malicious and block any further communication
done by the VF.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h | 43 +++++++++++++------------
 1 file changed, 23 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index cafd5de..27aa080 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -3013,8 +3013,8 @@ struct afex_stats {
 };
 
 #define BCM_5710_FW_MAJOR_VERSION			7
-#define BCM_5710_FW_MINOR_VERSION			12
-#define BCM_5710_FW_REVISION_VERSION		30
+#define BCM_5710_FW_MINOR_VERSION			13
+#define BCM_5710_FW_REVISION_VERSION		1
 #define BCM_5710_FW_ENGINEERING_VERSION		0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
@@ -3583,7 +3583,7 @@ enum classify_rule {
 	CLASSIFY_RULE_OPCODE_MAC,
 	CLASSIFY_RULE_OPCODE_VLAN,
 	CLASSIFY_RULE_OPCODE_PAIR,
-	CLASSIFY_RULE_OPCODE_VXLAN,
+	CLASSIFY_RULE_OPCODE_IMAC_VNI,
 	MAX_CLASSIFY_RULE
 };
 
@@ -3826,6 +3826,17 @@ struct eth_classify_header {
 	__le32 echo;
 };
 
+/*
+ * Command for adding/removing a Inner-MAC/VNI classification rule
+ */
+struct eth_classify_imac_vni_cmd {
+	struct eth_classify_cmd_header header;
+	__le32 vni;
+	__le16 imac_lsb;
+	__le16 imac_mid;
+	__le16 imac_msb;
+	__le16 reserved1;
+};
 
 /*
  * Command for adding/removing a MAC classification rule
@@ -3869,14 +3880,6 @@ struct eth_classify_vlan_cmd {
 /*
  * Command for adding/removing a VXLAN classification rule
  */
-struct eth_classify_vxlan_cmd {
-	struct eth_classify_cmd_header header;
-	__le32 vni;
-	__le16 inner_mac_lsb;
-	__le16 inner_mac_mid;
-	__le16 inner_mac_msb;
-	__le16 reserved1;
-};
 
 /*
  * union for eth classification rule
@@ -3885,7 +3888,7 @@ union eth_classify_rule_cmd {
 	struct eth_classify_mac_cmd mac;
 	struct eth_classify_vlan_cmd vlan;
 	struct eth_classify_pair_cmd pair;
-	struct eth_classify_vxlan_cmd vxlan;
+	struct eth_classify_imac_vni_cmd imac_vni;
 };
 
 /*
@@ -5623,6 +5626,14 @@ enum igu_mode {
 	MAX_IGU_MODE
 };
 
+/*
+ * Inner Headers Classification Type
+ */
+enum inner_clss_type {
+	INNER_CLSS_DISABLED,
+	INNER_CLSS_USE_VLAN,
+	INNER_CLSS_USE_VNI,
+	MAX_INNER_CLSS_TYPE};
 
 /*
  * IP versions
@@ -5953,14 +5964,6 @@ enum ts_offset_cmd {
 	MAX_TS_OFFSET_CMD
 };
 
-/* Tunnel Mode */
-enum tunnel_mode {
-	TUNN_MODE_NONE,
-	TUNN_MODE_VXLAN,
-	TUNN_MODE_GRE,
-	MAX_TUNNEL_MODE
-};
-
  /* zone A per-queue data */
 struct ustorm_queue_zone_data {
 	struct ustorm_eth_rx_producers eth_rx_producers;
-- 
1.9.3
