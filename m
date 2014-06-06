From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40e: print full link message
Date: Fri,  6 Jun 2014 02:04:19 -0700
Message-ID: <1402045462-10304-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5078 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751870AbaFFJFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:05:32 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The i40e driver should print link messages like all the
other Intel Ethernet drivers.

Change-ID: Ia88bdb96794e17a3962fcea94db176de01f921f7
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 56 ++++++++++++++++++++++++++---
 1 file changed, 51 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e9cd9bb..484ada97 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4135,6 +4135,54 @@ out:
 	return err;
 }
 #endif /* CONFIG_I40E_DCB */
+#define SPEED_SIZE 14
+#define FC_SIZE 8
+/**
+ * i40e_print_link_message - print link up or down
+ * @vsi: the VSI for which link needs a message
+ */
+static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
+{
+	char speed[SPEED_SIZE] = "Unknown";
+	char fc[FC_SIZE] = "RX/TX";
+
+	if (!isup) {
+		netdev_info(vsi->netdev, "NIC Link is Down\n");
+		return;
+	}
+
+	switch (vsi->back->hw.phy.link_info.link_speed) {
+	case I40E_LINK_SPEED_40GB:
+		strncpy(speed, "40 Gbps", SPEED_SIZE);
+		break;
+	case I40E_LINK_SPEED_10GB:
+		strncpy(speed, "10 Gbps", SPEED_SIZE);
+		break;
+	case I40E_LINK_SPEED_1GB:
+		strncpy(speed, "1000 Mbps", SPEED_SIZE);
+		break;
+	default:
+		break;
+	}
+
+	switch (vsi->back->hw.fc.current_mode) {
+	case I40E_FC_FULL:
+		strncpy(fc, "RX/TX", FC_SIZE);
+		break;
+	case I40E_FC_TX_PAUSE:
+		strncpy(fc, "TX", FC_SIZE);
+		break;
+	case I40E_FC_RX_PAUSE:
+		strncpy(fc, "RX", FC_SIZE);
+		break;
+	default:
+		strncpy(fc, "None", FC_SIZE);
+		break;
+	}
+
+	netdev_info(vsi->netdev, "NIC Link is Up %s Full Duplex, Flow Control: %s\n",
+		    speed, fc);
+}
 
 /**
  * i40e_up_complete - Finish the last steps of bringing up a connection
@@ -4161,11 +4209,11 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 
 	if ((pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP) &&
 	    (vsi->netdev)) {
-		netdev_info(vsi->netdev, "NIC Link is Up\n");
+		i40e_print_link_message(vsi, true);
 		netif_tx_start_all_queues(vsi->netdev);
 		netif_carrier_on(vsi->netdev);
 	} else if (vsi->netdev) {
-		netdev_info(vsi->netdev, "NIC Link is Down\n");
+		i40e_print_link_message(vsi, false);
 	}
 
 	/* replay FDIR SB filters */
@@ -4886,10 +4934,8 @@ static void i40e_link_event(struct i40e_pf *pf)
 
 	if (new_link == old_link)
 		return;
-
 	if (!test_bit(__I40E_DOWN, &pf->vsi[pf->lan_vsi]->state))
-		netdev_info(pf->vsi[pf->lan_vsi]->netdev,
-			    "NIC Link is %s\n", (new_link ? "Up" : "Down"));
+		i40e_print_link_message(pf->vsi[pf->lan_vsi], new_link);
 
 	/* Notify the base of the switch tree connected to
 	 * the link.  Floating VEBs are not notified.
-- 
1.9.3
