From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e: Add RSS configuration to virtual channel
Date: Wed,  6 Apr 2016 20:29:35 -0700
Message-ID: <1459999779-22254-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47670 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754663AbcDGD3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:46 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add opcodes and structures to support RSS configuration by PF driver on
behalf of the VF drivers. This reduces complexity in the VF driver and
allows us to support future hardware designs without modifying the VF
driver.

Change-ID: I8c75765c630eacb71f95967f1109a198542593ac
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   | 45 +++++++++++++++++++++--
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 45 +++++++++++++++++++++--
 2 files changed, 84 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index ab866cf..c92a3bd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -80,10 +80,15 @@ enum i40e_virtchnl_ops {
 	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE = 14,
 	I40E_VIRTCHNL_OP_GET_STATS = 15,
 	I40E_VIRTCHNL_OP_FCOE = 16,
-	I40E_VIRTCHNL_OP_EVENT = 17,
+	I40E_VIRTCHNL_OP_EVENT = 17, /* must ALWAYS be 17 */
 	I40E_VIRTCHNL_OP_IWARP = 20,
 	I40E_VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP = 21,
 	I40E_VIRTCHNL_OP_RELEASE_IWARP_IRQ_MAP = 22,
+	I40E_VIRTCHNL_OP_CONFIG_RSS_KEY = 23,
+	I40E_VIRTCHNL_OP_CONFIG_RSS_LUT = 24,
+	I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS = 25,
+	I40E_VIRTCHNL_OP_SET_RSS_HENA = 26,
+
 };
 
 /* Virtual channel message descriptor. This overlays the admin queue
@@ -157,6 +162,7 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2	0x00040000
+#define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
 
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
@@ -165,8 +171,8 @@ struct i40e_virtchnl_vf_resource {
 	u16 max_mtu;
 
 	u32 vf_offload_flags;
-	u32 max_fcoe_contexts;
-	u32 max_fcoe_filters;
+	u32 rss_key_size;
+	u32 rss_lut_size;
 
 	struct i40e_virtchnl_vsi_resource vsi_res[1];
 };
@@ -325,6 +331,39 @@ struct i40e_virtchnl_promisc_info {
  * PF replies with struct i40e_eth_stats in an external buffer.
  */
 
+/* I40E_VIRTCHNL_OP_CONFIG_RSS_KEY
+ * I40E_VIRTCHNL_OP_CONFIG_RSS_LUT
+ * VF sends these messages to configure RSS. Only supported if both PF
+ * and VF drivers set the I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF bit during
+ * configuration negotiation. If this is the case, then the RSS fields in
+ * the VF resource struct are valid.
+ * Both the key and LUT are initialized to 0 by the PF, meaning that
+ * RSS is effectively disabled until set up by the VF.
+ */
+struct i40e_virtchnl_rss_key {
+	u16 vsi_id;
+	u16 key_len;
+	u8 key[1];         /* RSS hash key, packed bytes */
+};
+
+struct i40e_virtchnl_rss_lut {
+	u16 vsi_id;
+	u16 lut_entries;
+	u8 lut[1];        /* RSS lookup table*/
+};
+
+/* I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS
+ * I40E_VIRTCHNL_OP_SET_RSS_HENA
+ * VF sends these messages to get and set the hash filter enable bits for RSS.
+ * By default, the PF sets these to all possible traffic types that the
+ * hardware supports. The VF can query this value if it wants to change the
+ * traffic types that are hashed by the hardware.
+ * Traffic types are defined in the i40e_filter_pctype enum in i40e_type.h
+ */
+struct i40e_virtchnl_rss_hena {
+	u64 hena;
+};
+
 /* I40E_VIRTCHNL_OP_EVENT
  * PF sends this message to inform the VF driver of events that may affect it.
  * No direct response is expected from the VF, though it may generate other
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index 3b9d203..f04ce6c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -80,7 +80,12 @@ enum i40e_virtchnl_ops {
 	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE = 14,
 	I40E_VIRTCHNL_OP_GET_STATS = 15,
 	I40E_VIRTCHNL_OP_FCOE = 16,
-	I40E_VIRTCHNL_OP_EVENT = 17,
+	I40E_VIRTCHNL_OP_EVENT = 17, /* must ALWAYS be 17 */
+	I40E_VIRTCHNL_OP_CONFIG_RSS_KEY = 23,
+	I40E_VIRTCHNL_OP_CONFIG_RSS_LUT = 24,
+	I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS = 25,
+	I40E_VIRTCHNL_OP_SET_RSS_HENA = 26,
+
 };
 
 /* Virtual channel message descriptor. This overlays the admin queue
@@ -154,6 +159,7 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2	0x00040000
+#define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
 
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
@@ -162,8 +168,8 @@ struct i40e_virtchnl_vf_resource {
 	u16 max_mtu;
 
 	u32 vf_offload_flags;
-	u32 max_fcoe_contexts;
-	u32 max_fcoe_filters;
+	u32 rss_key_size;
+	u32 rss_lut_size;
 
 	struct i40e_virtchnl_vsi_resource vsi_res[1];
 };
@@ -322,6 +328,39 @@ struct i40e_virtchnl_promisc_info {
  * PF replies with struct i40e_eth_stats in an external buffer.
  */
 
+/* I40E_VIRTCHNL_OP_CONFIG_RSS_KEY
+ * I40E_VIRTCHNL_OP_CONFIG_RSS_LUT
+ * VF sends these messages to configure RSS. Only supported if both PF
+ * and VF drivers set the I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF bit during
+ * configuration negotiation. If this is the case, then the RSS fields in
+ * the VF resource struct are valid.
+ * Both the key and LUT are initialized to 0 by the PF, meaning that
+ * RSS is effectively disabled until set up by the VF.
+ */
+struct i40e_virtchnl_rss_key {
+	u16 vsi_id;
+	u16 key_len;
+	u8 key[1];         /* RSS hash key, packed bytes */
+};
+
+struct i40e_virtchnl_rss_lut {
+	u16 vsi_id;
+	u16 lut_entries;
+	u8 lut[1];        /* RSS lookup table*/
+};
+
+/* I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS
+ * I40E_VIRTCHNL_OP_SET_RSS_HENA
+ * VF sends these messages to get and set the hash filter enable bits for RSS.
+ * By default, the PF sets these to all possible traffic types that the
+ * hardware supports. The VF can query this value if it wants to change the
+ * traffic types that are hashed by the hardware.
+ * Traffic types are defined in the i40e_filter_pctype enum in i40e_type.h
+ */
+struct i40e_virtchnl_rss_hena {
+	u64 hena;
+};
+
 /* I40E_VIRTCHNL_OP_EVENT
  * PF sends this message to inform the VF driver of events that may affect it.
  * No direct response is expected from the VF, though it may generate other
-- 
2.5.5
