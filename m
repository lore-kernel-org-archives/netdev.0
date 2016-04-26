From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40evf: Add driver support for promiscuous mode
Date: Tue, 26 Apr 2016 13:55:48 -0700
Message-ID: <1461704148-114349-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:39724 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbcDZU4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 16:56:21 -0400
In-Reply-To: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Add necessary Linux Ethernet driver support for promiscuous mode
operation. Add a flag so the VF knows it is in promiscuous mode
and two state flags to discreetly track multicast and unicast
promiscuous states.

Change-Id: Ib2f2dc7a7582304fec90fc917ebb7ded21ba1de4
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c  | 14 +++++++-------
 drivers/net/ethernet/intel/i40evf/i40evf.h          |  3 +++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 19 +++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 11 +++++++++++
 4 files changed, 40 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index f47b0e8..c226c2d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1489,13 +1489,13 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 							    NULL);
 	} else if (i40e_getnum_vf_vsi_vlan_filters(vsi)) {
 		list_for_each_entry(f, &vsi->mac_filter_list, list) {
-			if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID)
-				aq_ret = i40e_aq_set_vsi_mc_promisc_on_vlan
-								   (hw,
-								   vsi->seid,
-								   allmulti,
-								   f->vlan,
-								   NULL);
+			if (f->vlan < 0 || f->vlan > I40E_MAX_VLANID)
+				continue;
+			aq_ret = i40e_aq_set_vsi_mc_promisc_on_vlan(hw,
+								    vsi->seid,
+								    allmulti,
+								    f->vlan,
+								    NULL);
 			aq_err = pf->hw.aq.asq_last_status;
 			if (aq_ret) {
 				dev_err(&pf->pdev->dev,
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 63f7aae..25afabf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -220,6 +220,7 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_WB_ON_ITR_CAPABLE		BIT(11)
 #define I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE	BIT(12)
 #define I40EVF_FLAG_ADDR_SET_BY_PF		BIT(13)
+#define I40EVF_FLAG_PROMISC_ON			BIT(15)
 /* duplicates for common code */
 #define I40E_FLAG_FDIR_ATR_ENABLED		 0
 #define I40E_FLAG_DCB_ENABLED			 0
@@ -244,6 +245,8 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_AQ_SET_HENA			BIT(12)
 #define I40EVF_FLAG_AQ_SET_RSS_KEY		BIT(13)
 #define I40EVF_FLAG_AQ_SET_RSS_LUT		BIT(14)
+#define I40EVF_FLAG_AQ_REQUEST_PROMISC		BIT(15)
+#define I40EVF_FLAG_AQ_RELEASE_PROMISC		BIT(16)
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index af53159..d1c4afd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -943,6 +943,14 @@ static void i40evf_set_rx_mode(struct net_device *netdev)
 bottom_of_search_loop:
 		continue;
 	}
+
+	if (netdev->flags & IFF_PROMISC &&
+	    !(adapter->flags & I40EVF_FLAG_PROMISC_ON))
+		adapter->aq_required |= I40EVF_FLAG_AQ_REQUEST_PROMISC;
+	else if (!(netdev->flags & IFF_PROMISC) &&
+		 adapter->flags & I40EVF_FLAG_PROMISC_ON)
+		adapter->aq_required |= I40EVF_FLAG_AQ_RELEASE_PROMISC;
+
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 }
 
@@ -1622,6 +1630,17 @@ static void i40evf_watchdog_task(struct work_struct *work)
 		goto watchdog_done;
 	}
 
+	if (adapter->aq_required & I40EVF_FLAG_AQ_REQUEST_PROMISC) {
+		i40evf_set_promiscuous(adapter, I40E_FLAG_VF_UNICAST_PROMISC |
+				       I40E_FLAG_VF_MULTICAST_PROMISC);
+		goto watchdog_done;
+	}
+
+	if (adapter->aq_required & I40EVF_FLAG_AQ_RELEASE_PROMISC) {
+		i40evf_set_promiscuous(adapter, 0);
+		goto watchdog_done;
+	}
+
 	if (adapter->state == __I40EVF_RUNNING)
 		i40evf_request_stats(adapter);
 watchdog_done:
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index e62c56b..ba7fbc0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -652,6 +652,17 @@ void i40evf_set_promiscuous(struct i40evf_adapter *adapter, int flags)
 			adapter->current_op);
 		return;
 	}
+
+	if (flags) {
+		adapter->flags |= I40EVF_FLAG_PROMISC_ON;
+		adapter->aq_required &= ~I40EVF_FLAG_AQ_REQUEST_PROMISC;
+		dev_info(&adapter->pdev->dev, "Entering promiscuous mode\n");
+	} else {
+		adapter->flags &= ~I40EVF_FLAG_PROMISC_ON;
+		adapter->aq_required &= ~I40EVF_FLAG_AQ_RELEASE_PROMISC;
+		dev_info(&adapter->pdev->dev, "Leaving promiscuous mode\n");
+	}
+
 	adapter->current_op = I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE;
 	vpi.vsi_id = adapter->vsi_res->vsi_id;
 	vpi.flags = flags;
-- 
2.5.5
