From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH 6/6] [next-queue]net: i40e: Add support to set max bandwidth
 rates for TCs offloaded via tc/mqprio
Date: Tue, 11 Jul 2017 03:19:01 -0700
Message-ID: <149976834155.2896.1061095686386969972.stgit@anamdev.jf.intel.com>
References: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, sridhar.samudrala@intel.com,
        carolyn.wyborny@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:55861 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932506AbdGKKTf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 06:19:35 -0400
In-Reply-To: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
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
---
 drivers/net/ethernet/intel/i40e/i40e.h      |    2 +
 drivers/net/ethernet/intel/i40e/i40e_main.c |   99 +++++++++++++++++++++++++--
 2 files changed, 92 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c545be6..7a4a338 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -357,6 +357,8 @@ struct i40e_channel {
 	u8 enabled_tc;
 	struct i40e_aqc_vsi_properties_data info;
 
+	u64 max_tx_rate;
+
 	/* track this channel belongs to which VSI */
 	struct i40e_vsi *parent_vsi;
 };
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 409ef09..c5a625c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5193,9 +5193,16 @@ static int i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi, u8 enabled_tc,
 	i40e_status ret;
 	int i;
 
-	if ((vsi->back->flags & I40E_FLAG_TC_MQPRIO) ||
-	    !vsi->mqprio_qopt.qopt.hw)
+	if (vsi->back->flags & I40E_FLAG_TC_MQPRIO)
 		return 0;
+	if (!vsi->mqprio_qopt.qopt.hw) {
+		ret = i40e_set_bw_limit(vsi, vsi->seid, 0);
+		if (ret)
+			dev_info(&vsi->back->pdev->dev,
+				 "Failed to reset tx rate for vsi->seid %u\n",
+				 vsi->seid);
+		return ret;
+	}
 	bw_data.tc_valid_bits = enabled_tc;
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++)
 		bw_data.tc_bw_credits[i] = bw_share[i];
@@ -5501,6 +5508,13 @@ static void i40e_remove_queue_channels(struct i40e_vsi *vsi)
 			rx_ring->ch = NULL;
 		}
 
+		/* Reset BW configured for this VSI via mqprio */
+		ret = i40e_set_bw_limit(vsi, ch->seid, 0);
+		if (ret)
+			dev_info(&vsi->back->pdev->dev,
+				 "Failed to reset tx rate for ch->seid %u\n",
+				 ch->seid);
+
 		/* delete VSI from FW */
 		ret = i40e_aq_delete_element(&vsi->back->hw, ch->seid,
 					     NULL);
@@ -6073,6 +6087,17 @@ int i40e_create_queue_channel(struct i40e_vsi *vsi,
 		 "Setup channel (id:%u) utilizing num_queues %d\n",
 		 ch->seid, ch->num_queue_pairs);
 
+	/* configure VSI for BW limit */
+	if (ch->max_tx_rate) {
+		if (i40e_set_bw_limit(vsi, ch->seid, ch->max_tx_rate))
+			return -EINVAL;
+
+		dev_dbg(&pf->pdev->dev,
+			"Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
+			ch->max_tx_rate,
+			ch->max_tx_rate / I40E_BW_CREDIT_DIVISOR, ch->seid);
+	}
+
 	/* in case of VF, this will be main SRIOV VSI */
 	ch->parent_vsi = vsi;
 
@@ -6108,6 +6133,12 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
 			ch->base_queue =
 				vsi->tc_config.tc_info[i].qoffset;
 
+			/* Bandwidth limit through tc interface is in bytes/s,
+			 * change to Mbit/s
+			 */
+			ch->max_tx_rate =
+				(vsi->mqprio_qopt.max_rate[i] * 8) / 1000000;
+
 			list_add_tail(&ch->list, &vsi->ch_list);
 
 			ret = i40e_create_queue_channel(vsi, ch);
@@ -6527,6 +6558,7 @@ void i40e_down(struct i40e_vsi *vsi)
 static int i40e_validate_mqprio_qopt(struct i40e_vsi *vsi,
 				     struct tc_mqprio_qopt_offload *mqprio_qopt)
 {
+	u64 sum_max_rate = 0;
 	int i;
 
 	if ((mqprio_qopt->qopt.offset[0] != 0) ||
@@ -6536,8 +6568,13 @@ static int i40e_validate_mqprio_qopt(struct i40e_vsi *vsi,
 	for (i = 0; ; i++) {
 		if (!mqprio_qopt->qopt.count[i])
 			return -EINVAL;
-		if (mqprio_qopt->min_rate[i] || mqprio_qopt->max_rate[i])
+		if (mqprio_qopt->min_rate[i]) {
+			dev_err(&vsi->back->pdev->dev,
+				"Invalid min tx rate (greater than 0) specified\n");
 			return -EINVAL;
+		}
+		sum_max_rate += ((mqprio_qopt->max_rate[i] * 8) / 1000000);
+
 		if (i >= mqprio_qopt->qopt.num_tc - 1)
 			break;
 		if (mqprio_qopt->qopt.offset[i + 1] !=
@@ -6548,6 +6585,11 @@ static int i40e_validate_mqprio_qopt(struct i40e_vsi *vsi,
 	    (mqprio_qopt->qopt.offset[i] + mqprio_qopt->qopt.count[i])) {
 		return -EINVAL;
 	}
+	if (sum_max_rate > i40e_get_link_speed(vsi)) {
+		dev_err(&vsi->back->pdev->dev,
+			"Invalid max tx rate specified\n");
+		return -EINVAL;
+	}
 	return 0;
 }
 
@@ -6654,6 +6696,19 @@ static int i40e_setup_tc(struct net_device *netdev, struct tc_to_netdev *tc)
 	}
 
 	if (pf->flags & I40E_FLAG_TC_MQPRIO) {
+		if (vsi->mqprio_qopt.max_rate[0]) {
+			u64 max_tx_rate = (vsi->mqprio_qopt.max_rate[0] * 8) /
+								1000000;
+			ret = i40e_set_bw_limit(vsi, vsi->seid, max_tx_rate);
+			if (!ret)
+				dev_dbg(&vsi->back->pdev->dev,
+					"Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
+					max_tx_rate,
+					max_tx_rate / I40E_BW_CREDIT_DIVISOR,
+					vsi->seid);
+			else
+				goto exit;
+		}
 		ret = i40e_configure_queue_channels(vsi);
 		if (ret) {
 			netdev_info(netdev,
@@ -8088,6 +8143,18 @@ static int i40e_rebuild_channels(struct i40e_vsi *vsi)
 				 vsi->uplink_seid);
 			return ret;
 		}
+		if (ch->max_tx_rate) {
+			if (i40e_set_bw_limit(vsi, ch->seid,
+					      ch->max_tx_rate))
+				return -EINVAL;
+
+			dev_dbg(&vsi->back->pdev->dev,
+				"Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
+				ch->max_tx_rate,
+				ch->max_tx_rate /
+						I40E_BW_CREDIT_DIVISOR,
+				ch->seid);
+		}
 	}
 	return 0;
 }
@@ -8228,6 +8295,7 @@ static int i40e_reset(struct i40e_pf *pf)
  **/
 static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 {
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 	struct i40e_hw *hw = &pf->hw;
 	u8 set_fc_aq_fail = 0;
 	i40e_status ret;
@@ -8310,7 +8378,7 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 	 * If there were VEBs but the reconstitution failed, we'll try
 	 * try to recover minimal use by getting the basic PF VSI working.
 	 */
-	if (pf->vsi[pf->lan_vsi]->uplink_seid != pf->mac_seid) {
+	if (vsi->uplink_seid != pf->mac_seid) {
 		dev_dbg(&pf->pdev->dev, "attempting to rebuild switch\n");
 		/* find the one VEB connected to the MAC, and find orphans */
 		for (v = 0; v < I40E_MAX_VEB; v++) {
@@ -8334,8 +8402,7 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 					dev_info(&pf->pdev->dev,
 						 "rebuild of switch failed: %d, will try to set up simple PF connection\n",
 						 ret);
-					pf->vsi[pf->lan_vsi]->uplink_seid
-								= pf->mac_seid;
+					vsi->uplink_seid = pf->mac_seid;
 					break;
 				} else if (pf->veb[v]->uplink_seid == 0) {
 					dev_info(&pf->pdev->dev,
@@ -8346,10 +8413,10 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 		}
 	}
 
-	if (pf->vsi[pf->lan_vsi]->uplink_seid == pf->mac_seid) {
+	if (vsi->uplink_seid == pf->mac_seid) {
 		dev_dbg(&pf->pdev->dev, "attempting to rebuild PF VSI\n");
 		/* no VEB, so rebuild only the Main VSI */
-		ret = i40e_add_vsi(pf->vsi[pf->lan_vsi]);
+		ret = i40e_add_vsi(vsi);
 		if (ret) {
 			dev_info(&pf->pdev->dev,
 				 "rebuild of Main VSI failed: %d\n", ret);
@@ -8357,10 +8424,24 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 		}
 	}
 
+	if (vsi->mqprio_qopt.max_rate[0]) {
+		u64 max_tx_rate = (vsi->mqprio_qopt.max_rate[0] * 8) / 1000000;
+
+		ret = i40e_set_bw_limit(vsi, vsi->seid, max_tx_rate);
+		if (!ret)
+			dev_dbg(&vsi->back->pdev->dev,
+				"Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
+				max_tx_rate,
+				max_tx_rate / I40E_BW_CREDIT_DIVISOR,
+				vsi->seid);
+		else
+			goto end_unlock;
+	}
+
 	/* PF Main VSI is rebuild by now, go ahead and rebuild channel VSIs
 	 * for this main VSI if they exist
 	 */
-	ret = i40e_rebuild_channels(pf->vsi[pf->lan_vsi]);
+	ret = i40e_rebuild_channels(vsi);
 	if (ret)
 		goto end_unlock;
 
