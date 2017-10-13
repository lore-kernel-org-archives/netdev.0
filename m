From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] i40e: Refactor VF BW rate limiting
Date: Fri, 13 Oct 2017 14:52:45 -0700
Message-ID: <20171013215249.61286-6-jeffrey.t.kirsher@intel.com>
References: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:48069 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753016AbdJMVxU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 17:53:20 -0400
In-Reply-To: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amritha Nambiar <amritha.nambiar@intel.com>

This patch refactors the BW rate limiting for Tx traffic
on the VF to be reused in the next patch for rate limiting Tx
traffic for the VSIs on the PF as well.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  5 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 64 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 45 +--------------
 3 files changed, 71 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 024c88474951..524aa06a9e0e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -128,6 +128,10 @@
 /* default to trying for four seconds */
 #define I40E_TRY_LINK_TIMEOUT	(4 * HZ)
 
+/* BW rate limiting */
+#define I40E_BW_CREDIT_DIVISOR		50 /* 50Mbps per BW credit */
+#define I40E_MAX_BW_INACTIVE_ACCUM	4  /* accumulate 4 credits max */
+
 /* driver state flags */
 enum i40e_state_t {
 	__I40E_TESTING,
@@ -1039,4 +1043,5 @@ static inline bool i40e_enabled_xdp_vsi(struct i40e_vsi *vsi)
 }
 
 int i40e_create_queue_channel(struct i40e_vsi *vsi, struct i40e_channel *ch);
+int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate);
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e803aa1552c6..fc6eaf44d87c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5399,6 +5399,70 @@ static int i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 	return ret;
 }
 
+/**
+ * i40e_get_link_speed - Returns link speed for the interface
+ * @vsi: VSI to be configured
+ *
+ **/
+int i40e_get_link_speed(struct i40e_vsi *vsi)
+{
+	struct i40e_pf *pf = vsi->back;
+
+	switch (pf->hw.phy.link_info.link_speed) {
+	case I40E_LINK_SPEED_40GB:
+		return 40000;
+	case I40E_LINK_SPEED_25GB:
+		return 25000;
+	case I40E_LINK_SPEED_20GB:
+		return 20000;
+	case I40E_LINK_SPEED_10GB:
+		return 10000;
+	case I40E_LINK_SPEED_1GB:
+		return 1000;
+	default:
+		return -EINVAL;
+	}
+}
+
+/**
+ * i40e_set_bw_limit - setup BW limit for Tx traffic based on max_tx_rate
+ * @vsi: VSI to be configured
+ * @seid: seid of the channel/VSI
+ * @max_tx_rate: max TX rate to be configured as BW limit
+ *
+ * Helper function to set BW limit for a given VSI
+ **/
+int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate)
+{
+	struct i40e_pf *pf = vsi->back;
+	int speed = 0;
+	int ret = 0;
+
+	speed = i40e_get_link_speed(vsi);
+	if (max_tx_rate > speed) {
+		dev_err(&pf->pdev->dev,
+			"Invalid max tx rate %llu specified for VSI seid %d.",
+			max_tx_rate, seid);
+		return -EINVAL;
+	}
+	if (max_tx_rate && max_tx_rate < 50) {
+		dev_warn(&pf->pdev->dev,
+			 "Setting max tx rate to minimum usable value of 50Mbps.\n");
+		max_tx_rate = 50;
+	}
+
+	/* Tx rate credits are in values of 50Mbps, 0 is disabled */
+	ret = i40e_aq_config_vsi_bw_limit(&pf->hw, seid,
+					  max_tx_rate / I40E_BW_CREDIT_DIVISOR,
+					  I40E_MAX_BW_INACTIVE_ACCUM, NULL);
+	if (ret)
+		dev_err(&pf->pdev->dev,
+			"Failed set tx rate (%llu Mbps) for vsi->seid %u, err %s aq_err %s\n",
+			max_tx_rate, seid, i40e_stat_str(&pf->hw, ret),
+			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
+	return ret;
+}
+
 /**
  * i40e_remove_queue_channels - Remove queue channels for the TCs
  * @vsi: VSI to be configured
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index e7f98e306554..ce0981e2f605 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -3117,8 +3117,6 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 	return ret;
 }
 
-#define I40E_BW_CREDIT_DIVISOR 50     /* 50Mbps per BW credit */
-#define I40E_MAX_BW_INACTIVE_ACCUM 4  /* device can accumulate 4 credits max */
 /**
  * i40e_ndo_set_vf_bw
  * @netdev: network interface device structure
@@ -3134,7 +3132,6 @@ int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 	struct i40e_pf *pf = np->vsi->back;
 	struct i40e_vsi *vsi;
 	struct i40e_vf *vf;
-	int speed = 0;
 	int ret = 0;
 
 	/* validate the request */
@@ -3159,48 +3156,10 @@ int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 		goto error;
 	}
 
-	switch (pf->hw.phy.link_info.link_speed) {
-	case I40E_LINK_SPEED_40GB:
-		speed = 40000;
-		break;
-	case I40E_LINK_SPEED_25GB:
-		speed = 25000;
-		break;
-	case I40E_LINK_SPEED_20GB:
-		speed = 20000;
-		break;
-	case I40E_LINK_SPEED_10GB:
-		speed = 10000;
-		break;
-	case I40E_LINK_SPEED_1GB:
-		speed = 1000;
-		break;
-	default:
-		break;
-	}
-
-	if (max_tx_rate > speed) {
-		dev_err(&pf->pdev->dev, "Invalid max tx rate %d specified for VF %d.\n",
-			max_tx_rate, vf->vf_id);
-		ret = -EINVAL;
+	ret = i40e_set_bw_limit(vsi, vsi->seid, max_tx_rate);
+	if (ret)
 		goto error;
-	}
 
-	if ((max_tx_rate < 50) && (max_tx_rate > 0)) {
-		dev_warn(&pf->pdev->dev, "Setting max Tx rate to minimum usable value of 50Mbps.\n");
-		max_tx_rate = 50;
-	}
-
-	/* Tx rate credits are in values of 50Mbps, 0 is disabled*/
-	ret = i40e_aq_config_vsi_bw_limit(&pf->hw, vsi->seid,
-					  max_tx_rate / I40E_BW_CREDIT_DIVISOR,
-					  I40E_MAX_BW_INACTIVE_ACCUM, NULL);
-	if (ret) {
-		dev_err(&pf->pdev->dev, "Unable to set max tx rate, error code %d.\n",
-			ret);
-		ret = -EIO;
-		goto error;
-	}
 	vf->tx_rate = max_tx_rate;
 error:
 	return ret;
-- 
2.14.2
