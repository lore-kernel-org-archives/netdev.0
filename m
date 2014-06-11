From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Do not accept tagged packets by default
Date: Wed, 11 Jun 2014 09:33:17 -0700
Message-ID: <1402504404-8954-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55587 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932600AbaFKQdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:31 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Remove the filter created by the firmware with the default MAC address it
reads out of the NVM storage and a promiscuous VLAN tag and replace it
with a filter that will not accept tagged packets by default.  The system
must request a VLAN tag packet filter to get packets with that tag.

Change-ID: I119e6c3603a039bd68282ba31bf26f33a575490a
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 32 +++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 676bebb..211684c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1154,6 +1154,30 @@ struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 }
 
 /**
+ * i40e_rm_default_mac_filter - Remove the default MAC filter set by NVM
+ * @vsi: the PF Main VSI - inappropriate for any other VSI
+ * @macaddr: the MAC address
+ **/
+static void i40e_rm_default_mac_filter(struct i40e_vsi *vsi, u8 *macaddr)
+{
+	struct i40e_aqc_remove_macvlan_element_data element;
+	struct i40e_pf *pf = vsi->back;
+	i40e_status aq_ret;
+
+	/* Only appropriate for the PF main VSI */
+	if (vsi->type != I40E_VSI_MAIN)
+		return;
+
+	ether_addr_copy(element.mac_addr, macaddr);
+	element.vlan_tag = 0;
+	element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH |
+			I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
+	aq_ret = i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
+	if (aq_ret)
+		dev_err(&pf->pdev->dev, "Could not remove default MAC-VLAN\n");
+}
+
+/**
  * i40e_add_filter - Add a mac/vlan filter to the VSI
  * @vsi: the VSI to be searched
  * @macaddr: the MAC address
@@ -6980,6 +7004,14 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	if (vsi->type == I40E_VSI_MAIN) {
 		SET_NETDEV_DEV(netdev, &pf->pdev->dev);
 		memcpy(mac_addr, hw->mac.perm_addr, ETH_ALEN);
+		/* The following two steps are necessary to prevent reception
+		 * of tagged packets - by default the NVM loads a MAC-VLAN
+		 * filter that will accept any tagged packet.  This is to
+		 * prevent that during normal operations until a specific
+		 * VLAN tag filter has been set.
+		 */
+		i40e_rm_default_mac_filter(vsi, mac_addr);
+		i40e_add_filter(vsi, mac_addr, I40E_VLAN_ANY, false, true);
 	} else {
 		/* relate the VSI_VMDQ name to the VSI_MAIN name */
 		snprintf(netdev->name, IFNAMSIZ, "%sv%%d",
-- 
1.9.3
