From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40evf: Allow PF driver to configure RSS
Date: Tue, 26 Apr 2016 13:55:40 -0700
Message-ID: <1461704148-114349-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:22840 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785AbcDZUzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 16:55:54 -0400
In-Reply-To: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the PF driver reports proper support, allow the PF driver to
configure RSS on the behalf of the VF driver. This will allow for RSS
support on future hardware without changes to the VF driver.

Unfortunately, the old RSS code still needs to stay as the driver needs
to be compatible with PF drivers that don't support this interface. But
this change still simplifies the data structures a bunch and makes this
code simpler to read and maintain.

Change-ID: I0375aad40788ecdc0cb24d5cfeccf07804e69771
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  30 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 121 ++++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 308 +++++++--------------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 119 ++++++++
 4 files changed, 294 insertions(+), 284 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 017c83b..63f7aae 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -67,8 +67,6 @@ struct i40e_vsi {
 	u16 rx_itr_setting;
 	u16 tx_itr_setting;
 	u16 qs_handle;
-	u8 *rss_hkey_user; /* User configured hash keys */
-	u8 *rss_lut_user;  /* User configured lookup table entries */
 };
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
@@ -239,8 +237,13 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_AQ_CONFIGURE_QUEUES		BIT(6)
 #define I40EVF_FLAG_AQ_MAP_VECTORS		BIT(7)
 #define I40EVF_FLAG_AQ_HANDLE_RESET		BIT(8)
-#define I40EVF_FLAG_AQ_CONFIGURE_RSS		BIT(9)
+#define I40EVF_FLAG_AQ_CONFIGURE_RSS		BIT(9)	/* direct AQ config */
 #define I40EVF_FLAG_AQ_GET_CONFIG		BIT(10)
+/* Newer style, RSS done by the PF so we can ignore hardware vagaries. */
+#define I40EVF_FLAG_AQ_GET_HENA			BIT(11)
+#define I40EVF_FLAG_AQ_SET_HENA			BIT(12)
+#define I40EVF_FLAG_AQ_SET_RSS_KEY		BIT(13)
+#define I40EVF_FLAG_AQ_SET_RSS_LUT		BIT(14)
 
 	/* OS defined structs */
 	struct net_device *netdev;
@@ -260,8 +263,14 @@ struct i40evf_adapter {
 			    (_a)->vf_res->vf_offload_flags & \
 				I40E_VIRTCHNL_VF_OFFLOAD_IWARP : \
 			    0)
+/* RSS by the PF should be preferred over RSS via other methods. */
+#define RSS_PF(_a) ((_a)->vf_res->vf_offload_flags & \
+		    I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF)
 #define RSS_AQ(_a) ((_a)->vf_res->vf_offload_flags & \
 		    I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ)
+#define RSS_REG(_a) (!((_a)->vf_res->vf_offload_flags & \
+		       (I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ | \
+			I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF)))
 #define VLAN_ALLOWED(_a) ((_a)->vf_res->vf_offload_flags & \
 			  I40E_VIRTCHNL_VF_OFFLOAD_VLAN)
 	struct i40e_virtchnl_vf_resource *vf_res; /* incl. all VSIs */
@@ -273,6 +282,12 @@ struct i40evf_adapter {
 	struct i40e_eth_stats current_stats;
 	struct i40e_vsi vsi;
 	u32 aq_wait_count;
+	/* RSS stuff */
+	u64 hena;
+	u16 rss_key_size;
+	u16 rss_lut_size;
+	u8 *rss_key;
+	u8 *rss_lut;
 };
 
 
@@ -316,11 +331,12 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter);
 void i40evf_set_promiscuous(struct i40evf_adapter *adapter, int flags);
 void i40evf_request_stats(struct i40evf_adapter *adapter);
 void i40evf_request_reset(struct i40evf_adapter *adapter);
+void i40evf_get_hena(struct i40evf_adapter *adapter);
+void i40evf_set_hena(struct i40evf_adapter *adapter);
+void i40evf_set_rss_key(struct i40evf_adapter *adapter);
+void i40evf_set_rss_lut(struct i40evf_adapter *adapter);
 void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 				enum i40e_virtchnl_ops v_opcode,
 				i40e_status v_retval, u8 *msg, u16 msglen);
-int i40evf_config_rss(struct i40e_vsi *vsi, const u8 *seed, u8 *lut,
-		      u16 lut_size);
-int i40evf_get_rss(struct i40e_vsi *vsi, const u8 *seed, u8 *lut,
-		   u16 lut_size);
+int i40evf_config_rss(struct i40evf_adapter *adapter);
 #endif /* _I40EVF_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index dd4430a..9f7657c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -387,20 +387,16 @@ static int i40evf_set_coalesce(struct net_device *netdev,
 static int i40evf_get_rss_hash_opts(struct i40evf_adapter *adapter,
 				    struct ethtool_rxnfc *cmd)
 {
-	struct i40e_hw *hw = &adapter->hw;
-	u64 hena = (u64)rd32(hw, I40E_VFQF_HENA(0)) |
-		   ((u64)rd32(hw, I40E_VFQF_HENA(1)) << 32);
-
 	/* We always hash on IP src and dest addresses */
 	cmd->data = RXH_IP_SRC | RXH_IP_DST;
 
 	switch (cmd->flow_type) {
 	case TCP_V4_FLOW:
-		if (hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP))
+		if (adapter->hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP))
 			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	case UDP_V4_FLOW:
-		if (hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP))
+		if (adapter->hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP))
 			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 
@@ -412,11 +408,11 @@ static int i40evf_get_rss_hash_opts(struct i40evf_adapter *adapter,
 		break;
 
 	case TCP_V6_FLOW:
-		if (hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP))
+		if (adapter->hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP))
 			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	case UDP_V6_FLOW:
-		if (hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP))
+		if (adapter->hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP))
 			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 
@@ -476,9 +472,6 @@ static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
 	struct i40e_hw *hw = &adapter->hw;
 	u32 flags = adapter->vf_res->vf_offload_flags;
 
-	u64 hena = (u64)rd32(hw, I40E_VFQF_HENA(0)) |
-		   ((u64)rd32(hw, I40E_VFQF_HENA(1)) << 32);
-
 	/* RSS does not support anything other than hashing
 	 * to queues on src and dst IPs and ports
 	 */
@@ -495,10 +488,11 @@ static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
 	case TCP_V4_FLOW:
 		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 			if (flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-				hena |=
+				adapter->hena |=
 			   BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK);
 
-			hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
+			adapter->hena |=
+		 BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
 		} else {
 			return -EINVAL;
 		}
@@ -506,10 +500,11 @@ static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
 	case TCP_V6_FLOW:
 		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 			if (flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-				hena |=
+				adapter->hena |=
 			   BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN_NO_ACK);
 
-			hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
+			adapter->hena |=
+		 BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
 		} else {
 			return -EINVAL;
 		}
@@ -517,11 +512,12 @@ static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
 	case UDP_V4_FLOW:
 		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 			if (flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-				hena |=
+				adapter->hena |=
 			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
 			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP);
 
-			hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
+			adapter->hena |=
+				(BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
 				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
 		} else {
 			return -EINVAL;
@@ -530,11 +526,12 @@ static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
 	case UDP_V6_FLOW:
 		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 			if (flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-				hena |=
+				adapter->hena |=
 			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
 			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP);
 
-			hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
+			adapter->hena |=
+				(BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
 				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
 		} else {
 			return -EINVAL;
@@ -547,7 +544,7 @@ static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
 		if ((nfc->data & RXH_L4_B_0_1) ||
 		    (nfc->data & RXH_L4_B_2_3))
 			return -EINVAL;
-		hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_OTHER);
+		adapter->hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_OTHER);
 		break;
 	case AH_ESP_V6_FLOW:
 	case AH_V6_FLOW:
@@ -556,23 +553,27 @@ static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
 		if ((nfc->data & RXH_L4_B_0_1) ||
 		    (nfc->data & RXH_L4_B_2_3))
 			return -EINVAL;
-		hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_OTHER);
+		adapter->hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_OTHER);
 		break;
 	case IPV4_FLOW:
-		hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) |
-			 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
+		adapter->hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) |
+				  BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
 		break;
 	case IPV6_FLOW:
-		hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) |
-			 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
+		adapter->hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) |
+				  BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
 		break;
 	default:
 		return -EINVAL;
 	}
 
-	wr32(hw, I40E_VFQF_HENA(0), (u32)hena);
-	wr32(hw, I40E_VFQF_HENA(1), (u32)(hena >> 32));
-	i40e_flush(hw);
+	if (RSS_PF(adapter)) {
+		adapter->aq_required = I40EVF_FLAG_AQ_SET_HENA;
+	} else {
+		wr32(hw, I40E_VFQF_HENA(0), (u32)adapter->hena);
+		wr32(hw, I40E_VFQF_HENA(1), (u32)(adapter->hena >> 32));
+		i40e_flush(hw);
+	}
 
 	return 0;
 }
@@ -624,6 +625,19 @@ static void i40evf_get_channels(struct net_device *netdev,
 }
 
 /**
+ * i40evf_get_rxfh_key_size - get the RSS hash key size
+ * @netdev: network interface device structure
+ *
+ * Returns the table size.
+ **/
+static u32 i40evf_get_rxfh_key_size(struct net_device *netdev)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+
+	return adapter->rss_key_size;
+}
+
+/**
  * i40evf_get_rxfh_indir_size - get the rx flow hash indirection table size
  * @netdev: network interface device structure
  *
@@ -631,7 +645,9 @@ static void i40evf_get_channels(struct net_device *netdev,
  **/
 static u32 i40evf_get_rxfh_indir_size(struct net_device *netdev)
 {
-	return (I40E_VFQF_HLUT_MAX_INDEX + 1) * 4;
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+
+	return adapter->rss_lut_size;
 }
 
 /**
@@ -646,9 +662,6 @@ static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 			   u8 *hfunc)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
-	struct i40e_vsi *vsi = &adapter->vsi;
-	u8 *seed = NULL, *lut;
-	int ret;
 	u16 i;
 
 	if (hfunc)
@@ -656,24 +669,13 @@ static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	if (!indir)
 		return 0;
 
-	seed = key;
-
-	lut = kzalloc(I40EVF_HLUT_ARRAY_SIZE, GFP_KERNEL);
-	if (!lut)
-		return -ENOMEM;
-
-	ret = i40evf_get_rss(vsi, seed, lut, I40EVF_HLUT_ARRAY_SIZE);
-	if (ret)
-		goto out;
+	memcpy(key, adapter->rss_key, adapter->rss_key_size);
 
 	/* Each 32 bits pointed by 'indir' is stored with a lut entry */
-	for (i = 0; i < I40EVF_HLUT_ARRAY_SIZE; i++)
-		indir[i] = (u32)lut[i];
+	for (i = 0; i < adapter->rss_lut_size; i++)
+		indir[i] = (u32)adapter->rss_lut[i];
 
-out:
-	kfree(lut);
-
-	return ret;
+	return 0;
 }
 
 /**
@@ -689,8 +691,6 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
 			   const u8 *key, const u8 hfunc)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
-	struct i40e_vsi *vsi = &adapter->vsi;
-	u8 *seed = NULL;
 	u16 i;
 
 	/* We do not allow change in unsupported parameters */
@@ -701,28 +701,14 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
 		return 0;
 
 	if (key) {
-		if (!vsi->rss_hkey_user) {
-			vsi->rss_hkey_user = kzalloc(I40EVF_HKEY_ARRAY_SIZE,
-						     GFP_KERNEL);
-			if (!vsi->rss_hkey_user)
-				return -ENOMEM;
-		}
-		memcpy(vsi->rss_hkey_user, key, I40EVF_HKEY_ARRAY_SIZE);
-		seed = vsi->rss_hkey_user;
-	}
-	if (!vsi->rss_lut_user) {
-		vsi->rss_lut_user = kzalloc(I40EVF_HLUT_ARRAY_SIZE,
-					    GFP_KERNEL);
-		if (!vsi->rss_lut_user)
-			return -ENOMEM;
+		memcpy(adapter->rss_key, key, adapter->rss_key_size);
 	}
 
 	/* Each 32 bits pointed by 'indir' is stored with a lut entry */
-	for (i = 0; i < I40EVF_HLUT_ARRAY_SIZE; i++)
-		vsi->rss_lut_user[i] = (u8)(indir[i]);
+	for (i = 0; i < adapter->rss_lut_size; i++)
+		adapter->rss_lut[i] = (u8)(indir[i]);
 
-	return i40evf_config_rss(vsi, seed, vsi->rss_lut_user,
-				 I40EVF_HLUT_ARRAY_SIZE);
+	return i40evf_config_rss(adapter);
 }
 
 /**
@@ -794,6 +780,7 @@ static const struct ethtool_ops i40evf_ethtool_ops = {
 	.get_rxfh		= i40evf_get_rxfh,
 	.set_rxfh		= i40evf_set_rxfh,
 	.get_channels		= i40evf_get_channels,
+	.get_rxfh_key_size	= i40evf_get_rxfh_key_size,
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 806da26..af53159 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1224,24 +1224,18 @@ out:
 }
 
 /**
- * i40e_config_rss_aq - Prepare for RSS using AQ commands
- * @vsi: vsi structure
- * @seed: RSS hash seed
- * @lut: Lookup table
- * @lut_size: Lookup table size
+ * i40e_config_rss_aq - Configure RSS keys and lut by using AQ commands
+ * @adapter: board private structure
  *
  * Return 0 on success, negative on failure
  **/
-static int i40evf_config_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
-				u8 *lut, u16 lut_size)
+static int i40evf_config_rss_aq(struct i40evf_adapter *adapter)
 {
-	struct i40evf_adapter *adapter = vsi->back;
+	struct i40e_aqc_get_set_rss_key_data *rss_key =
+		(struct i40e_aqc_get_set_rss_key_data *)adapter->rss_key;
 	struct i40e_hw *hw = &adapter->hw;
 	int ret = 0;
 
-	if (!vsi->id)
-		return -EINVAL;
-
 	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
 		/* bail because we already have a command pending */
 		dev_err(&adapter->pdev->dev, "Cannot configure RSS, command %d pending\n",
@@ -1249,198 +1243,82 @@ static int i40evf_config_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
 		return -EBUSY;
 	}
 
-	if (seed) {
-		struct i40e_aqc_get_set_rss_key_data *rss_key =
-			(struct i40e_aqc_get_set_rss_key_data *)seed;
-		ret = i40evf_aq_set_rss_key(hw, vsi->id, rss_key);
-		if (ret) {
-			dev_err(&adapter->pdev->dev, "Cannot set RSS key, err %s aq_err %s\n",
-				i40evf_stat_str(hw, ret),
-				i40evf_aq_str(hw, hw->aq.asq_last_status));
-			return ret;
-		}
+	ret = i40evf_aq_set_rss_key(hw, adapter->vsi.id, rss_key);
+	if (ret) {
+		dev_err(&adapter->pdev->dev, "Cannot set RSS key, err %s aq_err %s\n",
+			i40evf_stat_str(hw, ret),
+			i40evf_aq_str(hw, hw->aq.asq_last_status));
+		return ret;
+
 	}
 
-	if (lut) {
-		ret = i40evf_aq_set_rss_lut(hw, vsi->id, false, lut, lut_size);
-		if (ret) {
-			dev_err(&adapter->pdev->dev,
-				"Cannot set RSS lut, err %s aq_err %s\n",
-				i40evf_stat_str(hw, ret),
-				i40evf_aq_str(hw, hw->aq.asq_last_status));
-			return ret;
-		}
+	ret = i40evf_aq_set_rss_lut(hw, adapter->vsi.id, false,
+				    adapter->rss_lut, adapter->rss_lut_size);
+	if (ret) {
+		dev_err(&adapter->pdev->dev, "Cannot set RSS lut, err %s aq_err %s\n",
+			i40evf_stat_str(hw, ret),
+			i40evf_aq_str(hw, hw->aq.asq_last_status));
 	}
 
 	return ret;
+
 }
 
 /**
  * i40evf_config_rss_reg - Configure RSS keys and lut by writing registers
- * @vsi: Pointer to vsi structure
- * @seed: RSS hash seed
- * @lut: Lookup table
- * @lut_size: Lookup table size
+ * @adapter: board private structure
  *
  * Returns 0 on success, negative on failure
  **/
-static int i40evf_config_rss_reg(struct i40e_vsi *vsi, const u8 *seed,
-				 const u8 *lut, u16 lut_size)
+static int i40evf_config_rss_reg(struct i40evf_adapter *adapter)
 {
-	struct i40evf_adapter *adapter = vsi->back;
 	struct i40e_hw *hw = &adapter->hw;
+	u32 *dw;
 	u16 i;
 
-	if (seed) {
-		u32 *seed_dw = (u32 *)seed;
-
-		for (i = 0; i <= I40E_VFQF_HKEY_MAX_INDEX; i++)
-			wr32(hw, I40E_VFQF_HKEY(i), seed_dw[i]);
-	}
-
-	if (lut) {
-		u32 *lut_dw = (u32 *)lut;
+	dw = (u32 *)adapter->rss_key;
+	for (i = 0; i <= adapter->rss_key_size / 4; i++)
+		wr32(hw, I40E_VFQF_HKEY(i), dw[i]);
 
-		if (lut_size != I40EVF_HLUT_ARRAY_SIZE)
-			return -EINVAL;
+	dw = (u32 *)adapter->rss_lut;
+	for (i = 0; i <= adapter->rss_lut_size / 4; i++)
+		wr32(hw, I40E_VFQF_HLUT(i), dw[i]);
 
-		for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++)
-			wr32(hw, I40E_VFQF_HLUT(i), lut_dw[i]);
-	}
 	i40e_flush(hw);
 
 	return 0;
 }
 
 /**
- *  * i40evf_get_rss_aq - Get RSS keys and lut by using AQ commands
- *  @vsi: Pointer to vsi structure
- *  @seed: RSS hash seed
- *  @lut: Lookup table
- *  @lut_size: Lookup table size
- *
- *  Return 0 on success, negative on failure
- **/
-static int i40evf_get_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
-			     u8 *lut, u16 lut_size)
-{
-	struct i40evf_adapter *adapter = vsi->back;
-	struct i40e_hw *hw = &adapter->hw;
-	int ret = 0;
-
-	if (seed) {
-		ret = i40evf_aq_get_rss_key(hw, vsi->id,
-			(struct i40e_aqc_get_set_rss_key_data *)seed);
-		if (ret) {
-			dev_err(&adapter->pdev->dev,
-				"Cannot get RSS key, err %s aq_err %s\n",
-				i40evf_stat_str(hw, ret),
-				i40evf_aq_str(hw, hw->aq.asq_last_status));
-			return ret;
-		}
-	}
-
-	if (lut) {
-		ret = i40evf_aq_get_rss_lut(hw, vsi->id, false, lut, lut_size);
-		if (ret) {
-			dev_err(&adapter->pdev->dev,
-				"Cannot get RSS lut, err %s aq_err %s\n",
-				i40evf_stat_str(hw, ret),
-				i40evf_aq_str(hw, hw->aq.asq_last_status));
-			return ret;
-		}
-	}
-
-	return ret;
-}
-
-/**
- *  * i40evf_get_rss_reg - Get RSS keys and lut by reading registers
- *  @vsi: Pointer to vsi structure
- *  @seed: RSS hash seed
- *  @lut: Lookup table
- *  @lut_size: Lookup table size
- *
- *  Returns 0 on success, negative on failure
- **/
-static int i40evf_get_rss_reg(struct i40e_vsi *vsi, const u8 *seed,
-			      const u8 *lut, u16 lut_size)
-{
-	struct i40evf_adapter *adapter = vsi->back;
-	struct i40e_hw *hw = &adapter->hw;
-	u16 i;
-
-	if (seed) {
-		u32 *seed_dw = (u32 *)seed;
-
-		for (i = 0; i <= I40E_VFQF_HKEY_MAX_INDEX; i++)
-			seed_dw[i] = rd32(hw, I40E_VFQF_HKEY(i));
-	}
-
-	if (lut) {
-		u32 *lut_dw = (u32 *)lut;
-
-		if (lut_size != I40EVF_HLUT_ARRAY_SIZE)
-			return -EINVAL;
-
-		for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++)
-			lut_dw[i] = rd32(hw, I40E_VFQF_HLUT(i));
-	}
-
-	return 0;
-}
-
-/**
  * i40evf_config_rss - Configure RSS keys and lut
- * @vsi: Pointer to vsi structure
- * @seed: RSS hash seed
- * @lut: Lookup table
- * @lut_size: Lookup table size
- *
- * Returns 0 on success, negative on failure
- **/
-int i40evf_config_rss(struct i40e_vsi *vsi, const u8 *seed,
-		      u8 *lut, u16 lut_size)
-{
-	struct i40evf_adapter *adapter = vsi->back;
-
-	if (RSS_AQ(adapter))
-		return i40evf_config_rss_aq(vsi, seed, lut, lut_size);
-	else
-		return i40evf_config_rss_reg(vsi, seed, lut, lut_size);
-}
-
-/**
- * i40evf_get_rss - Get RSS keys and lut
- * @vsi: Pointer to vsi structure
- * @seed: RSS hash seed
- * @lut: Lookup table
- * @lut_size: Lookup table size
+ * @adapter: board private structure
  *
  * Returns 0 on success, negative on failure
  **/
-int i40evf_get_rss(struct i40e_vsi *vsi, const u8 *seed, u8 *lut, u16 lut_size)
+int i40evf_config_rss(struct i40evf_adapter *adapter)
 {
-	struct i40evf_adapter *adapter = vsi->back;
 
-	if (RSS_AQ(adapter))
-		return i40evf_get_rss_aq(vsi, seed, lut, lut_size);
-	else
-		return i40evf_get_rss_reg(vsi, seed, lut, lut_size);
+	if (RSS_PF(adapter)) {
+		adapter->aq_required |= I40EVF_FLAG_AQ_SET_RSS_LUT |
+					I40EVF_FLAG_AQ_SET_RSS_KEY;
+		return 0;
+	} else if (RSS_AQ(adapter)) {
+		return i40evf_config_rss_aq(adapter);
+	} else {
+		return i40evf_config_rss_reg(adapter);
+	}
 }
 
 /**
  * i40evf_fill_rss_lut - Fill the lut with default values
- * @lut: Lookup table to be filled with
- * @rss_table_size: Lookup table size
- * @rss_size: Range of queue number for hashing
+ * @adapter: board private structure
  **/
-static void i40evf_fill_rss_lut(u8 *lut, u16 rss_table_size, u16 rss_size)
+static void i40evf_fill_rss_lut(struct i40evf_adapter *adapter)
 {
 	u16 i;
 
-	for (i = 0; i < rss_table_size; i++)
-		lut[i] = i % rss_size;
+	for (i = 0; i < adapter->rss_lut_size; i++)
+		adapter->rss_lut[i] = i % adapter->num_active_queues;
 }
 
 /**
@@ -1451,42 +1329,25 @@ static void i40evf_fill_rss_lut(u8 *lut, u16 rss_table_size, u16 rss_size)
  **/
 static int i40evf_init_rss(struct i40evf_adapter *adapter)
 {
-	struct i40e_vsi *vsi = &adapter->vsi;
 	struct i40e_hw *hw = &adapter->hw;
-	u8 seed[I40EVF_HKEY_ARRAY_SIZE];
-	u64 hena;
-	u8 *lut;
 	int ret;
 
-	/* Enable PCTYPES for RSS, TCP/UDP with IPv4/IPv6 */
-	if (adapter->vf_res->vf_offload_flags &
-					I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-		hena = I40E_DEFAULT_RSS_HENA_EXPANDED;
-	else
-		hena = I40E_DEFAULT_RSS_HENA;
-	wr32(hw, I40E_VFQF_HENA(0), (u32)hena);
-	wr32(hw, I40E_VFQF_HENA(1), (u32)(hena >> 32));
+	if (!RSS_PF(adapter)) {
+		/* Enable PCTYPES for RSS, TCP/UDP with IPv4/IPv6 */
+		if (adapter->vf_res->vf_offload_flags &
+		    I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
+			adapter->hena = I40E_DEFAULT_RSS_HENA_EXPANDED;
+		else
+			adapter->hena = I40E_DEFAULT_RSS_HENA;
 
-	lut = kzalloc(I40EVF_HLUT_ARRAY_SIZE, GFP_KERNEL);
-	if (!lut)
-		return -ENOMEM;
+		wr32(hw, I40E_VFQF_HENA(0), (u32)adapter->hena);
+		wr32(hw, I40E_VFQF_HENA(1), (u32)(adapter->hena >> 32));
+	}
 
-	/* Use user configured lut if there is one, otherwise use default */
-	if (vsi->rss_lut_user)
-		memcpy(lut, vsi->rss_lut_user, I40EVF_HLUT_ARRAY_SIZE);
-	else
-		i40evf_fill_rss_lut(lut, I40EVF_HLUT_ARRAY_SIZE,
-				    adapter->num_active_queues);
+	i40evf_fill_rss_lut(adapter);
 
-	/* Use user configured hash key if there is one, otherwise
-	 * user default.
-	 */
-	if (vsi->rss_hkey_user)
-		memcpy(seed, vsi->rss_hkey_user, I40EVF_HKEY_ARRAY_SIZE);
-	else
-		netdev_rss_key_fill((void *)seed, I40EVF_HKEY_ARRAY_SIZE);
-	ret = i40evf_config_rss(vsi, seed, lut, I40EVF_HLUT_ARRAY_SIZE);
-	kfree(lut);
+	netdev_rss_key_fill((void *)adapter->rss_key, adapter->rss_key_size);
+	ret = i40evf_config_rss(adapter);
 
 	return ret;
 }
@@ -1601,19 +1462,16 @@ err_set_interrupt:
 }
 
 /**
- * i40evf_clear_rss_config_user - Clear user configurations of RSS
- * @vsi: Pointer to VSI structure
+ * i40evf_free_rss - Free memory used by RSS structs
+ * @adapter: board private structure
  **/
-static void i40evf_clear_rss_config_user(struct i40e_vsi *vsi)
+static void i40evf_free_rss(struct i40evf_adapter *adapter)
 {
-	if (!vsi)
-		return;
-
-	kfree(vsi->rss_hkey_user);
-	vsi->rss_hkey_user = NULL;
+	kfree(adapter->rss_key);
+	adapter->rss_key = NULL;
 
-	kfree(vsi->rss_lut_user);
-	vsi->rss_lut_user = NULL;
+	kfree(adapter->rss_lut);
+	adapter->rss_lut = NULL;
 }
 
 /**
@@ -1747,6 +1605,22 @@ static void i40evf_watchdog_task(struct work_struct *work)
 		adapter->aq_required &= ~I40EVF_FLAG_AQ_CONFIGURE_RSS;
 		goto watchdog_done;
 	}
+	if (adapter->aq_required & I40EVF_FLAG_AQ_GET_HENA) {
+		i40evf_get_hena(adapter);
+		goto watchdog_done;
+	}
+	if (adapter->aq_required & I40EVF_FLAG_AQ_SET_HENA) {
+		i40evf_set_hena(adapter);
+		goto watchdog_done;
+	}
+	if (adapter->aq_required & I40EVF_FLAG_AQ_SET_RSS_KEY) {
+		i40evf_set_rss_key(adapter);
+		goto watchdog_done;
+	}
+	if (adapter->aq_required & I40EVF_FLAG_AQ_SET_RSS_LUT) {
+		i40evf_set_rss_lut(adapter);
+		goto watchdog_done;
+	}
 
 	if (adapter->state == __I40EVF_RUNNING)
 		i40evf_request_stats(adapter);
@@ -2325,6 +2199,7 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 {
 	struct i40e_virtchnl_vf_resource *vfres = adapter->vf_res;
 	struct net_device *netdev = adapter->netdev;
+	struct i40e_vsi *vsi = &adapter->vsi;
 	int i;
 
 	/* got VF config message back from PF, now we can parse it */
@@ -2381,8 +2256,16 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 				       ITR_REG_TO_USEC(I40E_ITR_RX_DEF));
 	adapter->vsi.tx_itr_setting = (I40E_ITR_DYNAMIC |
 				       ITR_REG_TO_USEC(I40E_ITR_TX_DEF));
-	adapter->vsi.netdev = adapter->netdev;
-	adapter->vsi.qs_handle = adapter->vsi_res->qset_handle;
+	vsi->netdev = adapter->netdev;
+	vsi->qs_handle = adapter->vsi_res->qset_handle;
+	if (vfres->vf_offload_flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF) {
+		adapter->rss_key_size = vfres->rss_key_size;
+		adapter->rss_lut_size = vfres->rss_lut_size;
+	} else {
+		adapter->rss_key_size = I40EVF_HKEY_ARRAY_SIZE;
+		adapter->rss_lut_size = I40EVF_HLUT_ARRAY_SIZE;
+	}
+
 	return 0;
 }
 
@@ -2578,6 +2461,11 @@ static void i40evf_init_task(struct work_struct *work)
 	set_bit(__I40E_DOWN, &adapter->vsi.state);
 	i40evf_misc_irq_enable(adapter);
 
+	adapter->rss_key = kzalloc(adapter->rss_key_size, GFP_KERNEL);
+	adapter->rss_lut = kzalloc(adapter->rss_lut_size, GFP_KERNEL);
+	if (!adapter->rss_key || !adapter->rss_lut)
+		goto err_mem;
+
 	if (RSS_AQ(adapter)) {
 		adapter->aq_required |= I40EVF_FLAG_AQ_CONFIGURE_RSS;
 		mod_timer_pending(&adapter->watchdog_timer, jiffies + 1);
@@ -2588,7 +2476,8 @@ static void i40evf_init_task(struct work_struct *work)
 restart:
 	schedule_delayed_work(&adapter->init_task, msecs_to_jiffies(30));
 	return;
-
+err_mem:
+	i40evf_free_rss(adapter);
 err_register:
 	i40evf_free_misc_irq(adapter);
 err_sw_init:
@@ -2870,8 +2759,7 @@ static void i40evf_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-	/* Clear user configurations for RSS */
-	i40evf_clear_rss_config_user(&adapter->vsi);
+	i40evf_free_rss(adapter);
 
 	if (hw->aq.asq.count)
 		i40evf_shutdown_adminq(hw);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 488e738..e62c56b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -681,6 +681,115 @@ void i40evf_request_stats(struct i40evf_adapter *adapter)
 		/* if the request failed, don't lock out others */
 		adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
 }
+
+/**
+ * i40evf_get_hena
+ * @adapter: adapter structure
+ *
+ * Request hash enable capabilities from PF
+ **/
+void i40evf_get_hena(struct i40evf_adapter *adapter)
+{
+	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
+		/* bail because we already have a command pending */
+		dev_err(&adapter->pdev->dev, "Cannot get RSS hash capabilities, command %d pending\n",
+			adapter->current_op);
+		return;
+	}
+	adapter->current_op = I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS;
+	adapter->aq_required &= ~I40EVF_FLAG_AQ_GET_HENA;
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS,
+			   NULL, 0);
+}
+
+/**
+ * i40evf_set_hena
+ * @adapter: adapter structure
+ *
+ * Request the PF to set our RSS hash capabilities
+ **/
+void i40evf_set_hena(struct i40evf_adapter *adapter)
+{
+	struct i40e_virtchnl_rss_hena vrh;
+
+	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
+		/* bail because we already have a command pending */
+		dev_err(&adapter->pdev->dev, "Cannot set RSS hash enable, command %d pending\n",
+			adapter->current_op);
+		return;
+	}
+	vrh.hena = adapter->hena;
+	adapter->current_op = I40E_VIRTCHNL_OP_SET_RSS_HENA;
+	adapter->aq_required &= ~I40EVF_FLAG_AQ_SET_HENA;
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_SET_RSS_HENA,
+			   (u8 *)&vrh, sizeof(vrh));
+}
+
+/**
+ * i40evf_set_rss_key
+ * @adapter: adapter structure
+ *
+ * Request the PF to set our RSS hash key
+ **/
+void i40evf_set_rss_key(struct i40evf_adapter *adapter)
+{
+	struct i40e_virtchnl_rss_key *vrk;
+	int len;
+
+	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
+		/* bail because we already have a command pending */
+		dev_err(&adapter->pdev->dev, "Cannot set RSS key, command %d pending\n",
+			adapter->current_op);
+		return;
+	}
+	len = sizeof(struct i40e_virtchnl_rss_key) +
+	      (adapter->rss_key_size * sizeof(u8)) - 1;
+	vrk = kzalloc(len, GFP_KERNEL);
+	if (!vrk)
+		return;
+	vrk->vsi_id = adapter->vsi.id;
+	vrk->key_len = adapter->rss_key_size;
+	memcpy(vrk->key, adapter->rss_key, adapter->rss_key_size);
+
+	adapter->current_op = I40E_VIRTCHNL_OP_CONFIG_RSS_KEY;
+	adapter->aq_required &= ~I40EVF_FLAG_AQ_SET_RSS_KEY;
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_CONFIG_RSS_KEY,
+			   (u8 *)vrk, len);
+	kfree(vrk);
+}
+
+/**
+ * i40evf_set_rss_lut
+ * @adapter: adapter structure
+ *
+ * Request the PF to set our RSS lookup table
+ **/
+void i40evf_set_rss_lut(struct i40evf_adapter *adapter)
+{
+	struct i40e_virtchnl_rss_lut *vrl;
+	int len;
+
+	if (adapter->current_op != I40E_VIRTCHNL_OP_UNKNOWN) {
+		/* bail because we already have a command pending */
+		dev_err(&adapter->pdev->dev, "Cannot set RSS LUT, command %d pending\n",
+			adapter->current_op);
+		return;
+	}
+	len = sizeof(struct i40e_virtchnl_rss_lut) +
+	      (adapter->rss_lut_size * sizeof(u8)) - 1;
+	vrl = kzalloc(len, GFP_KERNEL);
+	if (!vrl)
+		return;
+	vrl->vsi_id = adapter->vsi.id;
+	vrl->lut_entries = adapter->rss_lut_size;
+	memcpy(vrl->lut, adapter->rss_lut, adapter->rss_lut_size);
+	adapter->current_op = I40E_VIRTCHNL_OP_CONFIG_RSS_LUT;
+	adapter->aq_required &= ~I40EVF_FLAG_AQ_SET_RSS_LUT;
+	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_CONFIG_RSS_LUT,
+			   (u8 *)vrl, len);
+	kfree(vrl);
+}
+
 /**
  * i40evf_request_reset
  * @adapter: adapter structure
@@ -820,6 +929,16 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 		if (v_opcode != adapter->current_op)
 			return;
 		break;
+	case I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS: {
+		struct i40e_virtchnl_rss_hena *vrh =
+			(struct i40e_virtchnl_rss_hena *)msg;
+		if (msglen == sizeof(*vrh))
+			adapter->hena = vrh->hena;
+		else
+			dev_warn(&adapter->pdev->dev,
+				 "Invalid message %d from PF\n", v_opcode);
+		}
+		break;
 	default:
 		if (v_opcode != adapter->current_op)
 			dev_warn(&adapter->pdev->dev, "Expected response %d from PF, received %d\n",
-- 
2.5.5
