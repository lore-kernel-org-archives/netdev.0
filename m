From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH 4/6] [next-queue]net: i40e: Enable mqprio full offload mode
 in the i40e driver for configuring TCs and queue mapping
Date: Tue, 11 Jul 2017 03:18:51 -0700
Message-ID: <149976833103.2896.15800483032245869388.stgit@anamdev.jf.intel.com>
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
Received: from mga11.intel.com ([192.55.52.93]:55307 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932322AbdGKKTY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 06:19:24 -0400
In-Reply-To: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i40e driver is modified to enable the new mqprio hardware
offload mode and factor the TCs and queue configuration by
creating channel VSIs. In this mode, the priority to traffic
class mapping and the user specified queue ranges are used
to configure the traffic classes when the 'hw' option is set
to 2.

Example:
# tc qdisc add dev eth0 root mqprio num_tc 4\
  map 0 0 0 0 1 2 2 3 queues 2@0 2@2 1@4 1@5 hw 2

# tc qdisc show dev eth0

qdisc mqprio 8038: root  tc 4 map 0 0 0 0 1 2 2 3 0 0 0 0 0 0 0 0
             queues:(0:1) (2:3) (4:4) (5:5)

The HW channels created are removed and all the queue configuration
is set to default when the qdisc is detached from the root of the
device.

# tc qdisc del dev eth0 root

This patch also disables setting up channels via ethtool (ethtool -L)
when the TCs are configured using mqprio scheduler.

The patch also limits setting ethtool Rx flow hash indirection
(ethtool -X eth0 equal N) to max queues configured via mqprio.
The Rx flow hash indirection input through ethtool should be
validated so that it is within in the queue range configured via
tc/mqprio. The bound checking is achieved by reporting the current
rss size to the kernel when queues are configured via mqprio.

Example:
# tc qdisc add dev eth0 root mqprio num_tc 4\
  map 0 0 0 1 0 2 3 0 queues 2@0 4@2 8@6 11@14 hw 2

# ethtool -X eth0 equal 12
Cannot set RX flow hash configuration: Invalid argument

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |    3 
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |    8 
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  442 ++++++++++++++++++------
 3 files changed, 342 insertions(+), 111 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 93bb527..501d62e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -54,6 +54,7 @@
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#include <net/pkt_cls.h>
 #include "i40e_type.h"
 #include "i40e_prototype.h"
 #include "i40e_client.h"
@@ -697,6 +698,7 @@ struct i40e_vsi {
 	enum i40e_vsi_type type;  /* VSI type, e.g., LAN, FCoE, etc */
 	s16 vf_id;		/* Virtual function ID for SRIOV VSIs */
 
+	struct tc_mqprio_qopt_offload mqprio_qopt; /* queue parameters */
 	struct i40e_tc_configuration tc_config;
 	struct i40e_aqc_vsi_properties_data info;
 
@@ -722,6 +724,7 @@ struct i40e_vsi {
 	u16 cnt_q_avail; /* num of queues available for channel usage */
 	u16 orig_rss_size;
 	u16 current_rss_size;
+	bool reconfig_rss;
 
 	/* keeps track of next_base_queue to be used for channel setup */
 	atomic_t next_base_queue;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index a868c8d..d61af22 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2626,7 +2626,7 @@ static int i40e_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd,
 
 	switch (cmd->cmd) {
 	case ETHTOOL_GRXRINGS:
-		cmd->data = vsi->num_queue_pairs;
+		cmd->data = vsi->rss_size;
 		ret = 0;
 		break;
 	case ETHTOOL_GRXFH:
@@ -3871,6 +3871,12 @@ static int i40e_set_channels(struct net_device *dev,
 	if (vsi->type != I40E_VSI_MAIN)
 		return -EINVAL;
 
+	/* We do not support setting channels via ethtool when TCs are
+	 * configured through mqprio
+	 */
+	if (pf->flags & I40E_FLAG_TC_MQPRIO)
+		return -EINVAL;
+
 	/* verify they are not requesting separate vectors */
 	if (!count || ch->rx_count || ch->tx_count)
 		return -EINVAL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 54a6275..40084b7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1578,6 +1578,169 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 }
 
 /**
+ * i40e_config_rss_aq - Prepare for RSS using AQ commands
+ * @vsi: vsi structure
+ * @seed: RSS hash seed
+ **/
+static int i40e_config_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
+			      u8 *lut, u16 lut_size)
+{
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	int ret = 0;
+
+	if (seed) {
+		struct i40e_aqc_get_set_rss_key_data *seed_dw =
+			(struct i40e_aqc_get_set_rss_key_data *)seed;
+		ret = i40e_aq_set_rss_key(hw, vsi->id, seed_dw);
+		if (ret) {
+			dev_info(&pf->pdev->dev,
+				 "Cannot set RSS key, err %s aq_err %s\n",
+				 i40e_stat_str(hw, ret),
+				 i40e_aq_str(hw, hw->aq.asq_last_status));
+			return ret;
+		}
+	}
+	if (lut) {
+		bool pf_lut = vsi->type == I40E_VSI_MAIN ? true : false;
+
+		ret = i40e_aq_set_rss_lut(hw, vsi->id, pf_lut, lut, lut_size);
+		if (ret) {
+			dev_info(&pf->pdev->dev,
+				 "Cannot set RSS lut, err %s aq_err %s\n",
+				 i40e_stat_str(hw, ret),
+				 i40e_aq_str(hw, hw->aq.asq_last_status));
+			return ret;
+		}
+	}
+	return ret;
+}
+
+/**
+ * i40e_vsi_config_rss - Prepare for VSI(VMDq) RSS if used
+ * @vsi: VSI structure
+ **/
+static int i40e_vsi_config_rss(struct i40e_vsi *vsi)
+{
+	u8 seed[I40E_HKEY_ARRAY_SIZE];
+	struct i40e_pf *pf = vsi->back;
+	u8 *lut;
+	int ret;
+
+	if (!(pf->hw_features & I40E_HW_RSS_AQ_CAPABLE))
+		return 0;
+	if (!vsi->rss_size)
+		vsi->rss_size = min_t(int, pf->alloc_rss_size,
+				      vsi->num_queue_pairs);
+	if (!vsi->rss_size)
+		return -EINVAL;
+	lut = kzalloc(vsi->rss_table_size, GFP_KERNEL);
+	if (!lut)
+		return -ENOMEM;
+
+	/* Use the user configured hash keys and lookup table if there is one,
+	 * otherwise use default
+	 */
+	if (vsi->rss_lut_user)
+		memcpy(lut, vsi->rss_lut_user, vsi->rss_table_size);
+	else
+		i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
+	if (vsi->rss_hkey_user)
+		memcpy(seed, vsi->rss_hkey_user, I40E_HKEY_ARRAY_SIZE);
+	else
+		netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
+	ret = i40e_config_rss_aq(vsi, seed, lut, vsi->rss_table_size);
+	kfree(lut);
+	return ret;
+}
+
+/**
+ * i40e_vsi_setup_queue_map_mqprio - Prepares VSI tc_config to have queue
+ * configurations based on MQPRIO options.
+ * @vsi: the VSI being configured,
+ * @ctxt: VSI context structure
+ * @enabled_tc: number of traffic classes to enable
+ **/
+static int i40e_vsi_setup_queue_map_mqprio(struct i40e_vsi *vsi,
+					   struct i40e_vsi_context *ctxt,
+					   u8 enabled_tc)
+{
+	u16 qcount = 0, max_qcount, qmap, sections = 0;
+	int i, override_q, pow, num_qps, ret;
+	u8 netdev_tc = 0, offset = 0;
+
+	if (vsi->type != I40E_VSI_MAIN)
+		return -EINVAL;
+	sections = I40E_AQ_VSI_PROP_QUEUE_MAP_VALID;
+	sections |= I40E_AQ_VSI_PROP_SCHED_VALID;
+	vsi->tc_config.numtc = vsi->mqprio_qopt.qopt.num_tc;
+	vsi->tc_config.enabled_tc = enabled_tc ? enabled_tc : 1;
+	num_qps = vsi->mqprio_qopt.qopt.count[0];
+
+	/* find the next higher power-of-2 of num queue pairs */
+	pow = ilog2(num_qps);
+	if (!is_power_of_2(num_qps))
+		pow++;
+	qmap = (offset << I40E_AQ_VSI_TC_QUE_OFFSET_SHIFT) |
+		(pow << I40E_AQ_VSI_TC_QUE_NUMBER_SHIFT);
+
+	/* Setup queue offset/count for all TCs for given VSI */
+	max_qcount = vsi->mqprio_qopt.qopt.count[0];
+	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
+		/* See if the given TC is enabled for the given VSI */
+		if (vsi->tc_config.enabled_tc & BIT(i)) {
+			offset = vsi->mqprio_qopt.qopt.offset[i];
+			qcount = vsi->mqprio_qopt.qopt.count[i];
+			if (qcount > max_qcount)
+				max_qcount = qcount;
+			vsi->tc_config.tc_info[i].qoffset = offset;
+			vsi->tc_config.tc_info[i].qcount = qcount;
+			vsi->tc_config.tc_info[i].netdev_tc = netdev_tc++;
+		} else {
+			/* TC is not enabled so set the offset to
+			 * default queue and allocate one queue
+			 * for the given TC.
+			 */
+			vsi->tc_config.tc_info[i].qoffset = 0;
+			vsi->tc_config.tc_info[i].qcount = 1;
+			vsi->tc_config.tc_info[i].netdev_tc = 0;
+		}
+	}
+
+	/* Set actual Tx/Rx queue pairs */
+	vsi->num_queue_pairs = offset + qcount;
+
+	/* Setup queue TC[0].qmap for given VSI context */
+	ctxt->info.tc_mapping[0] = cpu_to_le16(qmap);
+	ctxt->info.mapping_flags |= cpu_to_le16(I40E_AQ_VSI_QUE_MAP_CONTIG);
+	ctxt->info.queue_mapping[0] = cpu_to_le16(vsi->base_queue);
+	ctxt->info.valid_sections |= cpu_to_le16(sections);
+
+	/* Reconfigure RSS for main VSI with max queue count */
+	vsi->rss_size = max_qcount;
+	ret = i40e_vsi_config_rss(vsi);
+	if (ret) {
+		dev_info(&vsi->back->pdev->dev,
+			 "Failed to reconfig rss for num_queues (%u)\n",
+			 max_qcount);
+		return ret;
+	}
+	vsi->reconfig_rss = true;
+	dev_dbg(&vsi->back->pdev->dev,
+		"Reconfigured rss with num_queues (%u)\n", max_qcount);
+
+	/* Find queue count available for channel VSIs and starting offset
+	 * for channel VSIs
+	 */
+	override_q = vsi->mqprio_qopt.qopt.count[0];
+	if (override_q && (override_q < vsi->num_queue_pairs)) {
+		vsi->cnt_q_avail = vsi->num_queue_pairs - override_q;
+		atomic_set(&vsi->next_base_queue, override_q);
+	}
+	return 0;
+}
+
+/**
  * i40e_vsi_setup_queue_map - Setup a VSI queue map based on enabled_tc
  * @vsi: the VSI being setup
  * @ctxt: VSI context structure
@@ -1615,7 +1778,7 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 			numtc = 1;
 		}
 	} else {
-		/* At least TC0 is enabled in case of non-DCB case */
+		/* At least TC0 is enabled in non-DCB, non-MQPRIO case */
 		numtc = 1;
 	}
 
@@ -3164,6 +3327,7 @@ static void i40e_vsi_config_dcb_rings(struct i40e_vsi *vsi)
 			rx_ring->dcb_tc = 0;
 			tx_ring->dcb_tc = 0;
 		}
+		return;
 	}
 
 	for (n = 0; n < I40E_MAX_TRAFFIC_CLASS; n++) {
@@ -4872,6 +5036,24 @@ static u8 i40e_dcb_get_enabled_tc(struct i40e_dcbx_config *dcbcfg)
 }
 
 /**
+ * i40e_mqprio_get_enabled_tc - Get enabled traffic classes
+ * @pf: PF being queried
+ *
+ * Query the current MQPRIO configuration and return the number of
+ * traffic classes enabled.
+ **/
+static u8 i40e_mqprio_get_enabled_tc(struct i40e_pf *pf)
+{
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+	u8 num_tc = vsi->mqprio_qopt.qopt.num_tc;
+	u8 enabled_tc = 1, i;
+
+	for (i = 1; i < num_tc; i++)
+		enabled_tc |= BIT(i);
+	return enabled_tc;
+}
+
+/**
  * i40e_pf_get_num_tc - Get enabled traffic classes for PF
  * @pf: PF being queried
  *
@@ -4884,7 +5066,10 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
 	u8 num_tc = 0;
 	struct i40e_dcbx_config *dcbcfg = &hw->local_dcbx_config;
 
-	/* If DCB is not enabled then always in single TC */
+	if (pf->flags & I40E_FLAG_TC_MQPRIO)
+		return pf->vsi[pf->lan_vsi]->mqprio_qopt.qopt.num_tc;
+
+	/* If neither MQPRIO nor DCB is enabled, then always use single TC */
 	if (!(pf->flags & I40E_FLAG_DCB_ENABLED))
 		return 1;
 
@@ -4913,7 +5098,12 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
  **/
 static u8 i40e_pf_get_tc_map(struct i40e_pf *pf)
 {
-	/* If DCB is not enabled for this PF then just return default TC */
+	if (pf->flags & I40E_FLAG_TC_MQPRIO)
+		return i40e_mqprio_get_enabled_tc(pf);
+
+	/* If neither MQPRIO nor DCB is enabled for this PF then just return
+	 * default TC
+	 */
 	if (!(pf->flags & I40E_FLAG_DCB_ENABLED))
 		return I40E_DEFAULT_TRAFFIC_CLASS;
 
@@ -5003,6 +5193,9 @@ static int i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi, u8 enabled_tc,
 	i40e_status ret;
 	int i;
 
+	if ((vsi->back->flags & I40E_FLAG_TC_MQPRIO) ||
+	    !vsi->mqprio_qopt.qopt.hw)
+		return 0;
 	bw_data.tc_valid_bits = enabled_tc;
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++)
 		bw_data.tc_bw_credits[i] = bw_share[i];
@@ -5065,6 +5258,9 @@ static void i40e_vsi_config_netdev_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 					vsi->tc_config.tc_info[i].qoffset);
 	}
 
+	if (pf->flags & I40E_FLAG_TC_MQPRIO)
+		return;
+
 	/* Assign UP2TC map for the VSI */
 	for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
 		/* Get the actual TC# for the UP */
@@ -5115,7 +5311,8 @@ static int i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 	int i;
 
 	/* Check if enabled_tc is same as existing or new TCs */
-	if (vsi->tc_config.enabled_tc == enabled_tc)
+	if (vsi->tc_config.enabled_tc == enabled_tc &&
+	    vsi->mqprio_qopt.qopt.hw != TC_MQPRIO_HW_OFFLOAD)
 		return ret;
 
 	/* Enable ETS TCs with equal BW Share for now across all VSIs */
@@ -5138,15 +5335,37 @@ static int i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 	ctxt.vf_num = 0;
 	ctxt.uplink_seid = vsi->uplink_seid;
 	ctxt.info = vsi->info;
-	i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, false);
+	if (vsi->back->flags & I40E_FLAG_TC_MQPRIO) {
+		ret = i40e_vsi_setup_queue_map_mqprio(vsi, &ctxt, enabled_tc);
+		if (ret)
+			goto out;
+	} else {
+		i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, false);
+	}
 
+	/* On destroying the qdisc, reset vsi->rss_size, as number of enabled
+	 * queues changed.
+	 */
+	if (!vsi->mqprio_qopt.qopt.hw && vsi->reconfig_rss) {
+		vsi->rss_size = min_t(int, vsi->back->alloc_rss_size,
+				      vsi->num_queue_pairs);
+		ret = i40e_vsi_config_rss(vsi);
+		if (ret) {
+			dev_info(&vsi->back->pdev->dev,
+				 "Failed to reconfig rss for num_queues\n");
+			return ret;
+		}
+		vsi->reconfig_rss = false;
+	}
 	if (vsi->back->flags & I40E_FLAG_IWARP_ENABLED) {
 		ctxt.info.valid_sections |=
 				cpu_to_le16(I40E_AQ_VSI_PROP_QUEUE_OPT_VALID);
 		ctxt.info.queueing_opt_flags |= I40E_AQ_VSI_QUE_OPT_TCP_ENA;
 	}
 
-	/* Update the VSI after updating the VSI queue-mapping information */
+	/* Update the VSI after updating the VSI queue-mapping
+	 * information
+	 */
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret) {
 		dev_info(&vsi->back->pdev->dev,
@@ -6238,48 +6457,131 @@ void i40e_down(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_validate_mqprio_qopt- validate queue mapping info
+ * @vsi: the VSI being configured
+ * @mqprio_qopt: queue parametrs
+ **/
+static int i40e_validate_mqprio_qopt(struct i40e_vsi *vsi,
+				     struct tc_mqprio_qopt_offload *mqprio_qopt)
+{
+	int i;
+
+	if ((mqprio_qopt->qopt.offset[0] != 0) ||
+	    (mqprio_qopt->qopt.num_tc < 1) ||
+	    (mqprio_qopt->qopt.num_tc > I40E_MAX_TRAFFIC_CLASS))
+		return -EINVAL;
+	for (i = 0; ; i++) {
+		if (!mqprio_qopt->qopt.count[i])
+			return -EINVAL;
+		if (mqprio_qopt->min_rate[i] || mqprio_qopt->max_rate[i])
+			return -EINVAL;
+		if (i >= mqprio_qopt->qopt.num_tc - 1)
+			break;
+		if (mqprio_qopt->qopt.offset[i + 1] !=
+		    (mqprio_qopt->qopt.offset[i] + mqprio_qopt->qopt.count[i]))
+			return -EINVAL;
+	}
+	if (vsi->num_queue_pairs <
+	    (mqprio_qopt->qopt.offset[i] + mqprio_qopt->qopt.count[i])) {
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/**
  * i40e_setup_tc - configure multiple traffic classes
  * @netdev: net device to configure
- * @tc: number of traffic classes to enable
+ * @tc: pointer to struct tc_to_netdev
  **/
-static int i40e_setup_tc(struct net_device *netdev, u8 tc)
+static int i40e_setup_tc(struct net_device *netdev, struct tc_to_netdev *tc)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
-	u8 enabled_tc = 0;
+	u8 enabled_tc = 0, num_tc = 0, hw = 0;
 	int ret = -EINVAL;
 	int i;
 
-	/* Check if DCB enabled to continue */
-	if (!(pf->flags & I40E_FLAG_DCB_ENABLED)) {
-		netdev_info(netdev, "DCB is not enabled for adapter\n");
-		goto exit;
-	}
+	if (tc->type == TC_SETUP_MQPRIO) {
+		hw = tc->mqprio->hw;
+		num_tc = tc->mqprio->num_tc;
+	} else if (tc->type == TC_SETUP_MQPRIO_EXT) {
+		hw = tc->mqprio_qopt->qopt.hw;
+		num_tc = tc->mqprio_qopt->qopt.num_tc;
+	}
+	if (!hw) {
+		pf->flags &= ~I40E_FLAG_TC_MQPRIO;
+		if (tc->type == TC_SETUP_MQPRIO_EXT)
+			memcpy(&vsi->mqprio_qopt, tc->mqprio_qopt,
+			       sizeof(*tc->mqprio_qopt));
+		goto config_tc;
+	}
+	switch (hw) {
+	case TC_MQPRIO_HW_OFFLOAD_TCS:
+		pf->flags &= ~I40E_FLAG_TC_MQPRIO;
+
+		/* Check if DCB enabled to continue */
+		if (!(pf->flags & I40E_FLAG_DCB_ENABLED)) {
+			netdev_info(netdev,
+				    "DCB is not enabled for adapter\n");
+			goto exit;
+		}
 
-	/* Check if MFP enabled */
-	if (pf->flags & I40E_FLAG_MFP_ENABLED) {
-		netdev_info(netdev, "Configuring TC not supported in MFP mode\n");
-		goto exit;
-	}
+		/* Check if MFP enabled */
+		if (pf->flags & I40E_FLAG_MFP_ENABLED) {
+			netdev_info(netdev,
+				    "Configuring TC not supported in MFP mode\n");
+			goto exit;
+		}
 
-	/* Check whether tc count is within enabled limit */
-	if (tc > i40e_pf_get_num_tc(pf)) {
-		netdev_info(netdev, "TC count greater than enabled on link for adapter\n");
-		goto exit;
+		/* Check whether tc count is within enabled limit */
+		if (num_tc > i40e_pf_get_num_tc(pf)) {
+			netdev_info(netdev,
+				    "TC count greater than enabled on link for adapter\n");
+			goto exit;
+		}
+		break;
+	case TC_MQPRIO_HW_OFFLOAD:
+		if (pf->flags & I40E_FLAG_DCB_ENABLED) {
+			netdev_info(netdev,
+				    "Full offload of TC Mqprio options is not supported when DCB is enabled\n");
+			goto exit;
+		}
+
+		/* Check if MFP enabled */
+		if (pf->flags & I40E_FLAG_MFP_ENABLED) {
+			netdev_info(netdev,
+				    "Configuring TC not supported in MFP mode\n");
+			goto exit;
+		}
+		ret = i40e_validate_mqprio_qopt(vsi, tc->mqprio_qopt);
+		if (ret)
+			goto exit;
+		memcpy(&vsi->mqprio_qopt, tc->mqprio_qopt,
+		       sizeof(*tc->mqprio_qopt));
+		pf->flags |= I40E_FLAG_TC_MQPRIO;
+		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
+		break;
+	default:
+		return -EINVAL;
 	}
 
+config_tc:
 	/* Generate TC map for number of tc requested */
-	for (i = 0; i < tc; i++)
+	for (i = 0; i < num_tc; i++)
 		enabled_tc |= BIT(i);
 
 	/* Requesting same TC configuration as already enabled */
-	if (enabled_tc == vsi->tc_config.enabled_tc)
+	if (enabled_tc == vsi->tc_config.enabled_tc &&
+	    hw != TC_MQPRIO_HW_OFFLOAD)
 		return 0;
 
 	/* Quiesce VSI queues */
 	i40e_quiesce_vsi(vsi);
 
+	if (!hw && !(pf->flags & I40E_FLAG_TC_MQPRIO))
+		i40e_remove_queue_channels(vsi);
+
 	/* Configure VSI for enabled TCs */
 	ret = i40e_vsi_config_tc(vsi, enabled_tc);
 	if (ret) {
@@ -6297,7 +6599,11 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
 		}
 	}
 
+	goto out;
 exit:
+	/* Reset the configuration data */
+	memset(&vsi->tc_config, 0, sizeof(vsi->tc_config));
+out:
 	/* Unquiesce VSI */
 	i40e_unquiesce_vsi(vsi);
 	return ret;
@@ -6307,12 +6613,7 @@ static int __i40e_setup_tc(struct net_device *netdev, u32 handle,
 			   u32 chain_index, __be16 proto,
 			   struct tc_to_netdev *tc)
 {
-	if (tc->type != TC_SETUP_MQPRIO)
-		return -EINVAL;
-
-	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
-
-	return i40e_setup_tc(netdev, tc->mqprio->num_tc);
+	return i40e_setup_tc(netdev, tc);
 }
 
 /**
@@ -9110,45 +9411,6 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 }
 
 /**
- * i40e_config_rss_aq - Prepare for RSS using AQ commands
- * @vsi: vsi structure
- * @seed: RSS hash seed
- **/
-static int i40e_config_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
-			      u8 *lut, u16 lut_size)
-{
-	struct i40e_pf *pf = vsi->back;
-	struct i40e_hw *hw = &pf->hw;
-	int ret = 0;
-
-	if (seed) {
-		struct i40e_aqc_get_set_rss_key_data *seed_dw =
-			(struct i40e_aqc_get_set_rss_key_data *)seed;
-		ret = i40e_aq_set_rss_key(hw, vsi->id, seed_dw);
-		if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "Cannot set RSS key, err %s aq_err %s\n",
-				 i40e_stat_str(hw, ret),
-				 i40e_aq_str(hw, hw->aq.asq_last_status));
-			return ret;
-		}
-	}
-	if (lut) {
-		bool pf_lut = vsi->type == I40E_VSI_MAIN ? true : false;
-
-		ret = i40e_aq_set_rss_lut(hw, vsi->id, pf_lut, lut, lut_size);
-		if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "Cannot set RSS lut, err %s aq_err %s\n",
-				 i40e_stat_str(hw, ret),
-				 i40e_aq_str(hw, hw->aq.asq_last_status));
-			return ret;
-		}
-	}
-	return ret;
-}
-
-/**
  * i40e_get_rss_aq - Get RSS keys and lut by using AQ commands
  * @vsi: Pointer to vsi structure
  * @seed: Buffter to store the hash keys
@@ -9195,46 +9457,6 @@ static int i40e_get_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
 }
 
 /**
- * i40e_vsi_config_rss - Prepare for VSI(VMDq) RSS if used
- * @vsi: VSI structure
- **/
-static int i40e_vsi_config_rss(struct i40e_vsi *vsi)
-{
-	u8 seed[I40E_HKEY_ARRAY_SIZE];
-	struct i40e_pf *pf = vsi->back;
-	u8 *lut;
-	int ret;
-
-	if (!(pf->hw_features & I40E_HW_RSS_AQ_CAPABLE))
-		return 0;
-
-	if (!vsi->rss_size)
-		vsi->rss_size = min_t(int, pf->alloc_rss_size,
-				      vsi->num_queue_pairs);
-	if (!vsi->rss_size)
-		return -EINVAL;
-
-	lut = kzalloc(vsi->rss_table_size, GFP_KERNEL);
-	if (!lut)
-		return -ENOMEM;
-	/* Use the user configured hash keys and lookup table if there is one,
-	 * otherwise use default
-	 */
-	if (vsi->rss_lut_user)
-		memcpy(lut, vsi->rss_lut_user, vsi->rss_table_size);
-	else
-		i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
-	if (vsi->rss_hkey_user)
-		memcpy(seed, vsi->rss_hkey_user, I40E_HKEY_ARRAY_SIZE);
-	else
-		netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
-	ret = i40e_config_rss_aq(vsi, seed, lut, vsi->rss_table_size);
-	kfree(lut);
-
-	return ret;
-}
-
-/**
  * i40e_config_rss_reg - Configure RSS keys and lut by writing registers
  * @vsi: Pointer to vsi structure
  * @seed: RSS hash seed
