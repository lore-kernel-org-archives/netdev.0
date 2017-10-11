From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [jkirsher/next-queue PATCH v4 3/6] i40e: Cloud filter mode for
 set_switch_config command
Date: Tue, 10 Oct 2017 17:24:28 -0700
Message-ID: <150768146806.5320.1212910477662310789.stgit@anamdev.jf.intel.com>
References: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jiri@resnulli.us,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, alexander.duyck@gmail.com,
        xiyou.wangcong@gmail.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2904 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756588AbdJKAZy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 20:25:54 -0400
In-Reply-To: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add definitions for L4 filters and switch modes based on cloud filters
modes and extend the set switch config command to include the
additional cloud filter mode.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h |   30 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_common.c     |    4 ++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    |    2 +
 drivers/net/ethernet/intel/i40e/i40e_main.c       |    2 +
 drivers/net/ethernet/intel/i40e/i40e_prototype.h  |    2 +
 drivers/net/ethernet/intel/i40e/i40e_type.h       |    9 ++++++
 6 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 6a5db1b..729976b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -790,7 +790,35 @@ struct i40e_aqc_set_switch_config {
 	 */
 	__le16	first_tag;
 	__le16	second_tag;
-	u8	reserved[6];
+	/* Next byte is split into following:
+	 * Bit 7 : 0: No action, 1: Switch to mode defined by bits 6:0
+	 * Bit 6: 0 : Destination Port, 1: source port
+	 * Bit 5..4: L4 type
+	 * 0: rsvd
+	 * 1: TCP
+	 * 2: UDP
+	 * 3: Both TCP and UDP
+	 * Bits 3:0 Mode
+	 * 0: default mode
+	 * 1: L4 port only mode
+	 * 2: non-tunneled mode
+	 * 3: tunneled mode
+	 */
+#define I40E_AQ_SET_SWITCH_BIT7_VALID		0x80
+
+#define I40E_AQ_SET_SWITCH_L4_SRC_PORT		0x40
+
+#define I40E_AQ_SET_SWITCH_L4_TYPE_RSVD		0x00
+#define I40E_AQ_SET_SWITCH_L4_TYPE_TCP		0x10
+#define I40E_AQ_SET_SWITCH_L4_TYPE_UDP		0x20
+#define I40E_AQ_SET_SWITCH_L4_TYPE_BOTH		0x30
+
+#define I40E_AQ_SET_SWITCH_MODE_DEFAULT		0x00
+#define I40E_AQ_SET_SWITCH_MODE_L4_PORT		0x01
+#define I40E_AQ_SET_SWITCH_MODE_NON_TUNNEL	0x02
+#define I40E_AQ_SET_SWITCH_MODE_TUNNEL		0x03
+	u8	mode;
+	u8	rsvd5[5];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_set_switch_config);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 1b85eb3..0b3c5b7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2402,13 +2402,14 @@ i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
  * @hw: pointer to the hardware structure
  * @flags: bit flag values to set
  * @valid_flags: which bit flags to set
+ * @mode: cloud filter mode
  * @cmd_details: pointer to command details structure or NULL
  *
  * Set switch configuration bits
  **/
 enum i40e_status_code i40e_aq_set_switch_config(struct i40e_hw *hw,
 						u16 flags,
-						u16 valid_flags,
+						u16 valid_flags, u8 mode,
 				struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
@@ -2420,6 +2421,7 @@ enum i40e_status_code i40e_aq_set_switch_config(struct i40e_hw *hw,
 					  i40e_aqc_opc_set_switch_config);
 	scfg->flags = cpu_to_le16(flags);
 	scfg->valid_flags = cpu_to_le16(valid_flags);
+	scfg->mode = mode;
 	if (hw->flags & I40E_HW_FLAG_802_1AD_CAPABLE) {
 		scfg->switch_tag = cpu_to_le16(hw->switch_tag);
 		scfg->first_tag = cpu_to_le16(hw->first_tag);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index a760d75..37ca294 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -4341,7 +4341,7 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 			sw_flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
 		valid_flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
 		ret = i40e_aq_set_switch_config(&pf->hw, sw_flags, valid_flags,
-						NULL);
+						0, NULL);
 		if (ret && pf->hw.aq.asq_last_status != I40E_AQ_RC_ESRCH) {
 			dev_info(&pf->pdev->dev,
 				 "couldn't set switch config bits, err %s aq_err %s\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 33a8f429..0539d43 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -12165,7 +12165,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 		u16 valid_flags;
 
 		valid_flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
-		ret = i40e_aq_set_switch_config(&pf->hw, flags, valid_flags,
+		ret = i40e_aq_set_switch_config(&pf->hw, flags, valid_flags, 0,
 						NULL);
 		if (ret && pf->hw.aq.asq_last_status != I40E_AQ_RC_ESRCH) {
 			dev_info(&pf->pdev->dev,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 0150256..92869f5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -190,7 +190,7 @@ i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 enum i40e_status_code i40e_aq_set_switch_config(struct i40e_hw *hw,
 						u16 flags,
-						u16 valid_flags,
+						u16 valid_flags, u8 mode,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_request_resource(struct i40e_hw *hw,
 				enum i40e_aq_resources_ids resource,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 17a99b5..24589a4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -283,6 +283,15 @@ struct i40e_hw_capabilities {
 #define I40E_NVM_IMAGE_TYPE_CLOUD	0x2
 #define I40E_NVM_IMAGE_TYPE_UDP_CLOUD	0x3
 
+	/* Cloud filter modes:
+	 * Mode1: Filter on L4 port only
+	 * Mode2: Filter for non-tunneled traffic
+	 * Mode3: Filter for tunnel traffic
+	 */
+#define I40E_NVM_IMAGE_TYPE_MODE1	0x6
+#define I40E_NVM_IMAGE_TYPE_MODE2	0x7
+#define I40E_NVM_IMAGE_TYPE_MODE3	0x8
+
 	u32  management_mode;
 	u32  mng_protocols_over_mctp;
 #define I40E_MNG_PROTOCOL_PLDM		0x2
