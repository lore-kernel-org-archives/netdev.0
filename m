From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH 4/4] [next-queue]net: i40e: Add support to set max bandwidth
 rates for TCs offloaded via tc/mqprio
Date: Fri, 19 May 2017 17:58:38 -0700
Message-ID: <149524191856.11022.14942959596600821849.stgit@anamdev.jf.intel.com>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, sridhar.samudrala@intel.com,
        mitch.a.williams@intel.com, neerav.parikh@intel.com,
        jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:40569 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756547AbdESU2f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 16:28:35 -0400
In-Reply-To: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables setting up maximum Tx rates for the traffic
classes in i40e. The maximum rate offloaded to the hardware through
the mqprio framework is configured for the VSI. Configuring
minimum Tx rate limit is not supported in the device. The minimum
usable value for Tx rate is 50Mbps.

Example:
# tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
  queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2

To dump the bandwidth rates:

# tc qdisc show dev eth0
qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
             queues:(0:3) (4:7)
             min rates:0bit 0bit
             max rates:55Mbit 60Mbit

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |    2 +
 drivers/net/ethernet/intel/i40e/i40e_main.c |  102 ++++++++++++++++++++++++++-
 2 files changed, 100 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index a62f65a..83a060d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -346,6 +346,8 @@ struct i40e_channel {
 	u8 enabled_tc;
 	struct i40e_aqc_vsi_properties_data info;
 
+	u32 max_tx_rate;
+
 	/* track this channel belongs to which VSI */
 	struct i40e_vsi *parent_vsi;
 };
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7f61d4f..3261dab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -69,6 +69,8 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired);
 static void i40e_fdir_sb_setup(struct i40e_pf *pf);
 static int i40e_veb_get_bw_info(struct i40e_veb *veb);
 static int i40e_vsi_config_rss(struct i40e_vsi *vsi);
+static int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 ch_seid,
+			     u32 max_tx_rate);
 
 /* i40e_pci_tbl - PCI Device ID Table
  *
@@ -5033,7 +5035,7 @@ static int i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi, u8 enabled_tc,
 				       u8 *bw_share)
 {
 	struct i40e_aqc_configure_vsi_tc_bw_data bw_data;
-	i40e_status ret;
+	i40e_status ret = 0;
 	int i;
 
 	bw_data.tc_valid_bits = enabled_tc;
@@ -5041,8 +5043,20 @@ static int i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi, u8 enabled_tc,
 		bw_data.tc_bw_credits[i] = bw_share[i];
 
 	if ((vsi->back->flags & I40E_FLAG_TC_MQPRIO) ||
-	    !vsi->mqprio_qopt.qopt.hw)
-		return 0;
+	    !vsi->mqprio_qopt.qopt.hw) {
+		if (vsi->mqprio_qopt.max_rate[0]) {
+			u32 max_tx_rate = vsi->mqprio_qopt.max_rate[0];
+
+			max_tx_rate = (max_tx_rate * 8) / 1000000;
+
+			ret = i40e_set_bw_limit(vsi, vsi->seid, max_tx_rate);
+			if (ret)
+				dev_err(&vsi->back->pdev->dev,
+					"Failed to set tx rate (%u Mbps) for vsi->seid %u, error code %d.\n",
+					max_tx_rate, vsi->seid, ret);
+		}
+		return ret;
+	}
 
 	ret = i40e_aq_config_vsi_tc_bw(&vsi->back->hw, vsi->seid, &bw_data,
 				       NULL);
@@ -5297,6 +5311,71 @@ static void i40e_remove_queue_channel(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_set_bw_limit - setup BW limit based on max_tx_rate
+ * @vsi: the VSI being setup
+ * @ch_seid: seid of the channel (VSI)
+ * @max_tx_rate: max TX rate to be configured as BW limit
+ *
+ * This function sets up BW limit for a given channel (ch_seid)
+ * based on max TX rate specified.
+ **/
+static int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 ch_seid, u32 max_tx_rate)
+{
+	struct i40e_pf *pf = vsi->back;
+	int speed = 0;
+	int ret = 0;
+
+	switch (pf->hw.phy.link_info.link_speed) {
+	case I40E_LINK_SPEED_40GB:
+		speed = 40000;
+		break;
+	case I40E_LINK_SPEED_20GB:
+		speed = 20000;
+		break;
+	case I40E_LINK_SPEED_10GB:
+		speed = 10000;
+		break;
+	case I40E_LINK_SPEED_1GB:
+		speed = 1000;
+		break;
+	default:
+		break;
+	}
+
+	if (max_tx_rate > speed) {
+		dev_err(&pf->pdev->dev,
+			"Invalid tx rate %d specified for channel seid %d.",
+			max_tx_rate, ch_seid);
+		return -EINVAL;
+	}
+
+	if ((max_tx_rate < 50) && (max_tx_rate > 0)) {
+		dev_warn(&pf->pdev->dev,
+			 "Setting tx rate to minimum usable value of 50Mbps.\n");
+		max_tx_rate = 50;
+	}
+
+#define I40E_BW_CREDIT_DIVISOR 50     /* 50Mbps per BW credit */
+#define I40E_MAX_BW_INACTIVE_ACCUM 1
+
+	/* TX rate credits are in values of 50Mbps, 0 is disabled*/
+	ret = i40e_aq_config_vsi_bw_limit(&pf->hw, ch_seid,
+					  max_tx_rate / I40E_BW_CREDIT_DIVISOR,
+					  I40E_MAX_BW_INACTIVE_ACCUM,
+					  NULL);
+	if (ret)
+		dev_err(&pf->pdev->dev,
+			"Failed set tx rate (%u Mbps) for vsi->seid %u, error code %d.\n",
+			max_tx_rate, ch_seid, ret);
+	else
+		dev_info(&pf->pdev->dev,
+			 "Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
+			 max_tx_rate, max_tx_rate / I40E_BW_CREDIT_DIVISOR,
+			 ch_seid);
+	return ret;
+}
+
+/**
  * i40e_is_any_channel - channel exist or not
  * @vsi: ptr to VSI to which channels are associated with
  *
@@ -5882,6 +5961,11 @@ int i40e_create_queue_channel(struct i40e_vsi *vsi,
 		 "Setup channel (id:%u) utilizing num_queues %d\n",
 		 ch->seid, ch->num_queue_pairs);
 
+	/* configure VSI for BW limit */
+	if (ch->max_tx_rate)
+		if (i40e_set_bw_limit(vsi, ch->seid, ch->max_tx_rate))
+			return -EINVAL;
+
 	/* in case of VF, this will be main SRIOV VSI */
 	ch->parent_vsi = vsi;
 
@@ -5918,6 +6002,13 @@ static int i40e_configure_queue_channel(struct i40e_vsi *vsi)
 				vsi->tc_config.tc_info[i].qcount;
 			ch->base_queue =
 				vsi->tc_config.tc_info[i].qoffset;
+			ch->max_tx_rate =
+				vsi->mqprio_qopt.max_rate[i];
+
+			/* Bandwidth limit through tc interface is in bytes/s,
+			 * change to Mbit/s
+			 */
+			ch->max_tx_rate = (ch->max_tx_rate * 8) / 1000000;
 
 			list_add_tail(&ch->list, &vsi->ch_list);
 
@@ -6346,8 +6437,11 @@ int i40e_validate_mqprio_queue_mapping(struct i40e_vsi *vsi,
 		if (!mqprio_qopt->qopt.count[i])
 			return -EINVAL;
 
-		if (mqprio_qopt->min_rate[i] || mqprio_qopt->max_rate[i])
+		if (mqprio_qopt->min_rate[i]) {
+			dev_err(&vsi->back->pdev->dev,
+				"Invalid min tx rate (greater than 0) specified\n");
 			return -EINVAL;
+		}
 
 		if (i >= mqprio_qopt->qopt.num_tc - 1)
 			break;
