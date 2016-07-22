From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] i40e: Explicitly write platform-specific mac address after PF reset
Date: Fri, 22 Jul 2016 00:36:39 -0700
Message-ID: <1469172999-8969-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4223 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbcGVHgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:48 -0400
In-Reply-To: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>

i40e PF reset clears mac filters. If platform-specific mac address
is used, driver has to explicitly write default mac address to mac
filters otherwise all incoming traffic destined to default mac
address will be dropped after reset.

This issue was found on SPARC while toggling i40e ntuple via ethtool.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 87 ++++++++++++++++-------------
 1 file changed, 49 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 753c3b1..1ee45cf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2584,6 +2584,44 @@ static int i40e_vlan_rx_kill_vid(struct net_device *netdev,
 }
 
 /**
+ * i40e_macaddr_init - explicitly write the mac address filters
+ *
+ * @vsi: pointer to the vsi
+ * @macaddr: the MAC address
+ *
+ * This is needed when the macaddr has been obtained by other
+ * means than the default, e.g., from Open Firmware or IDPROM.
+ * Returns 0 on success, negative on failure
+ **/
+static int i40e_macaddr_init(struct i40e_vsi *vsi, u8 *macaddr)
+{
+	int ret;
+	struct i40e_aqc_add_macvlan_element_data element;
+
+	ret = i40e_aq_mac_address_write(&vsi->back->hw,
+					I40E_AQC_WRITE_TYPE_LAA_WOL,
+					macaddr, NULL);
+	if (ret) {
+		dev_info(&vsi->back->pdev->dev,
+			 "Addr change for VSI failed: %d\n", ret);
+		return -EADDRNOTAVAIL;
+	}
+
+	memset(&element, 0, sizeof(element));
+	ether_addr_copy(element.mac_addr, macaddr);
+	element.flags = cpu_to_le16(I40E_AQC_MACVLAN_ADD_PERFECT_MATCH);
+	ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element, 1, NULL);
+	if (ret) {
+		dev_info(&vsi->back->pdev->dev,
+			 "add filter failed err %s aq_err %s\n",
+			 i40e_stat_str(&vsi->back->hw, ret),
+			 i40e_aq_str(&vsi->back->hw,
+				     vsi->back->hw.aq.asq_last_status));
+	}
+	return ret;
+}
+
+/**
  * i40e_restore_vlan - Reinstate vlans when vsi/netdev comes back up
  * @vsi: the vsi being brought back up
  **/
@@ -3029,8 +3067,19 @@ static void i40e_vsi_config_dcb_rings(struct i40e_vsi *vsi)
  **/
 static void i40e_set_vsi_rx_mode(struct i40e_vsi *vsi)
 {
+	struct i40e_pf *pf = vsi->back;
+	int err;
+
 	if (vsi->netdev)
 		i40e_set_rx_mode(vsi->netdev);
+
+	if (!!(pf->flags & I40E_FLAG_PF_MAC)) {
+		err = i40e_macaddr_init(vsi, pf->hw.mac.addr);
+		if (err) {
+			dev_warn(&pf->pdev->dev,
+				 "could not set up macaddr; err %d\n", err);
+		}
+	}
 }
 
 /**
@@ -9592,44 +9641,6 @@ err_vsi:
 }
 
 /**
- * i40e_macaddr_init - explicitly write the mac address filters.
- *
- * @vsi: pointer to the vsi.
- * @macaddr: the MAC address
- *
- * This is needed when the macaddr has been obtained by other
- * means than the default, e.g., from Open Firmware or IDPROM.
- * Returns 0 on success, negative on failure
- **/
-static int i40e_macaddr_init(struct i40e_vsi *vsi, u8 *macaddr)
-{
-	int ret;
-	struct i40e_aqc_add_macvlan_element_data element;
-
-	ret = i40e_aq_mac_address_write(&vsi->back->hw,
-					I40E_AQC_WRITE_TYPE_LAA_WOL,
-					macaddr, NULL);
-	if (ret) {
-		dev_info(&vsi->back->pdev->dev,
-			 "Addr change for VSI failed: %d\n", ret);
-		return -EADDRNOTAVAIL;
-	}
-
-	memset(&element, 0, sizeof(element));
-	ether_addr_copy(element.mac_addr, macaddr);
-	element.flags = cpu_to_le16(I40E_AQC_MACVLAN_ADD_PERFECT_MATCH);
-	ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element, 1, NULL);
-	if (ret) {
-		dev_info(&vsi->back->pdev->dev,
-			 "add filter failed err %s aq_err %s\n",
-			 i40e_stat_str(&vsi->back->hw, ret),
-			 i40e_aq_str(&vsi->back->hw,
-				     vsi->back->hw.aq.asq_last_status));
-	}
-	return ret;
-}
-
-/**
  * i40e_vsi_setup - Set up a VSI by a given type
  * @pf: board private structure
  * @type: VSI type
-- 
2.5.5
