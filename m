From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] i40e: Set defport behavior for the Main VSI when in promiscuous mode
Date: Wed, 19 Aug 2015 17:57:51 -0700
Message-ID: <1440032286-30054-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, stable <stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37880 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbbHTA6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:58:08 -0400
In-Reply-To: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This fixes bugs where the port is not receiving multicast or vlan tagged
packets when in promiscuous mode. This can occur when a SW bridge is
created on top of the device.

This also fixes issues where the promiscuous behavior setting was not
being preserved across a reset caused by features being enabled or
disabled.

We are using defport instead of doing a true promiscuous mode because we do
not need to receive the SRIOV or VMDq VSI directed traffic which would suck
up bandwidth and is really not intended for the SW bridge.

In addition, with defport we get VLAN promiscuous behavior which is not
possible from the VSI level promiscuous setting.

Change-ID: Ie21985eac32d5af1c02e9d71c6430a90d5bab40f
CC: stable <stable@vger.kernel.org>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 42 ++++++++++++++++++++++-------
 2 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 0f97883..7a55bca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -372,6 +372,7 @@ struct i40e_pf {
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *i40e_dbg_pf;
 #endif /* CONFIG_DEBUG_FS */
+	bool cur_promisc;
 
 	u16 instance; /* A unique number per i40e_pf instance in the system */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3bb832a..6a6694f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1906,15 +1906,36 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		cur_promisc = (!!(vsi->current_netdev_flags & IFF_PROMISC) ||
 			       test_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 					&vsi->state));
-		ret = i40e_aq_set_vsi_unicast_promiscuous(&vsi->back->hw,
-							  vsi->seid,
-							  cur_promisc, NULL);
-		if (ret)
-			dev_info(&pf->pdev->dev,
-				 "set uni promisc failed, err %s, aq_err %s\n",
-				 i40e_stat_str(&pf->hw, ret),
-				 i40e_aq_str(&pf->hw,
-					     pf->hw.aq.asq_last_status));
+		if (vsi->type == I40E_VSI_MAIN && pf->lan_veb != I40E_NO_VEB) {
+			/* set defport ON for Main VSI instead of true promisc
+			 * this way we will get all unicast/multicast and vlan
+			 * promisc behavior but will not get VF or VMDq traffic
+			 * replicated on the Main VSI.
+			 */
+			if (pf->cur_promisc != cur_promisc) {
+				pf->cur_promisc = cur_promisc;
+				i40e_do_reset_safe(pf,
+						BIT(__I40E_PF_RESET_REQUESTED));
+			}
+		} else {
+			ret = i40e_aq_set_vsi_unicast_promiscuous(&vsi->back->hw,
+								  vsi->seid,
+								  cur_promisc,
+								  NULL);
+			if (ret)
+				dev_info(&pf->pdev->dev,
+					 "set uni promisc failed, err %d, aq_err %d\n",
+					 ret, pf->hw.aq.asq_last_status);
+			ret = i40e_aq_set_vsi_multicast_promiscuous(
+								&vsi->back->hw,
+								vsi->seid,
+								cur_promisc,
+								NULL);
+			if (ret)
+				dev_info(&pf->pdev->dev,
+					 "set multicast promisc failed, err %d, aq_err %d\n",
+					 ret, pf->hw.aq.asq_last_status);
+		}
 		ret = i40e_aq_set_vsi_broadcast(&vsi->back->hw,
 						vsi->seid,
 						cur_promisc, NULL);
@@ -3970,6 +3991,7 @@ static void i40e_vsi_close(struct i40e_vsi *vsi)
 	i40e_vsi_free_irq(vsi);
 	i40e_vsi_free_tx_resources(vsi);
 	i40e_vsi_free_rx_resources(vsi);
+	vsi->current_netdev_flags = 0;
 }
 
 /**
@@ -9278,7 +9300,7 @@ void i40e_veb_release(struct i40e_veb *veb)
 static int i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = veb->pf;
-	bool is_default = false;
+	bool is_default = veb->pf->cur_promisc;
 	bool is_cloud = false;
 	int ret;
 
-- 
2.4.3
