From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e: Fix multiple link up messages
Date: Thu,  8 Oct 2015 18:32:45 -0700
Message-ID: <1444354374-24351-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matt Jared <matthew.a.jared@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47722 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755507AbbJIBc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:59 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Jared <matthew.a.jared@intel.com>

This patch addresses an issue where multiple link up messages can be logged
resulting from aq link status timing when link properties are changed (fc,
speed, etc.); solved by using a single function to handle status printing
and adding a mechanism to track whether link state (up or down) has
actually changed.

Change-ID: Ied6ed6e49dc397c77d992adc0bc9ed3767152b9d
Signed-off-by: Matt Jared <matthew.a.jared@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 5 ++++-
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index a662e39..0c73404 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -537,6 +537,7 @@ struct i40e_vsi {
 	u16 idx;               /* index in pf->vsi[] */
 	u16 veb_idx;           /* index of VEB parent */
 	struct kobject *kobj;  /* sysfs object */
+	bool current_isup;     /* Sync 'link up' logging */
 
 	/* VSI specific handlers */
 	irqreturn_t (*irq_handler)(int irq, void *data);
@@ -791,4 +792,5 @@ int i40e_is_vsi_uplink_mode_veb(struct i40e_vsi *vsi);
 i40e_status i40e_get_npar_bw_setting(struct i40e_pf *pf);
 i40e_status i40e_set_npar_bw_setting(struct i40e_pf *pf);
 i40e_status i40e_commit_npar_bw_setting(struct i40e_pf *pf);
+void i40e_print_link_message(struct i40e_vsi *vsi, bool isup);
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index ef471fc..f2b4f8b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -690,7 +690,7 @@ static int i40e_set_settings(struct net_device *netdev,
 			/* Tell the OS link is going down, the link will go
 			 * back up when fw says it is ready asynchronously
 			 */
-			netdev_info(netdev, "PHY settings change requested, NIC Link is going down.\n");
+			i40e_print_link_message(vsi, false);
 			netif_carrier_off(netdev);
 			netif_tx_stop_all_queues(netdev);
 		}
@@ -834,7 +834,7 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 	/* Tell the OS link is going down, the link will go back up when fw
 	 * says it is ready asynchronously
 	 */
-	netdev_info(netdev, "Flow control settings change requested, NIC Link is going down.\n");
+	i40e_print_link_message(vsi, false);
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 94953568..e05e6aa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4837,11 +4837,14 @@ out:
  * i40e_print_link_message - print link up or down
  * @vsi: the VSI for which link needs a message
  */
-static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
+void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 {
 	char speed[SPEED_SIZE] = "Unknown";
 	char fc[FC_SIZE] = "RX/TX";
 
+	if (vsi->current_isup == isup)
+		return;
+	vsi->current_isup = isup;
 	if (!isup) {
 		netdev_info(vsi->netdev, "NIC Link is Down\n");
 		return;
-- 
2.4.3
