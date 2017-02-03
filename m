From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queu 04/19] i40e: rename i40e_put_mac_in_vlan and i40e_del_mac_all_vlan
Date: Thu,  2 Feb 2017 23:25:38 -0800
Message-ID: <20170203072553.168372-5-jeffrey.t.kirsher@intel.com>
References: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50618 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752707AbdBCHZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 02:25:57 -0500
In-Reply-To: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

These functions purpose is to add a new MAC filter correctly, whether
we're using VLANs or not. Their goal is to ensure that all active VLANs
get the new MAC filter. Rename them so that their intent is clear. They
function correctly regardless of whether we have any active VLANs or
only have I40E_VLAN_ANY filters. The new names convey how they function
in a more clear manner.

Change-ID: Iec1961f968c0223a7132724a74e26a665750b107
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  6 +++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 24 ++++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  4 ++--
 3 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c164d50..4a64884 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -855,9 +855,9 @@ int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid);
 int i40e_vsi_add_vlan(struct i40e_vsi *vsi, u16 vid);
 void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid);
 void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, u16 vid);
-struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
-					     const u8 *macaddr);
-int i40e_del_mac_all_vlan(struct i40e_vsi *vsi, const u8 *macaddr);
+struct i40e_mac_filter *i40e_add_mac_filter(struct i40e_vsi *vsi,
+					    const u8 *macaddr);
+int i40e_del_mac_filter(struct i40e_vsi *vsi, const u8 *macaddr);
 bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi);
 struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, const u8 *macaddr);
 #ifdef I40E_FCOE
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ab0a04b..da9f8d3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1477,18 +1477,19 @@ void i40e_del_filter(struct i40e_vsi *vsi, const u8 *macaddr, s16 vlan)
 }
 
 /**
- * i40e_put_mac_in_vlan - Make macvlan filters from macaddrs and vlans
+ * i40e_add_mac_filter - Add a MAC filter for all active VLANs
  * @vsi: the VSI to be searched
  * @macaddr: the mac address to be filtered
  *
- * Goes through all the macvlan filters and adds a macvlan filter for each
+ * If we're not in VLAN mode, just add the filter to I40E_VLAN_ANY. Otherwise,
+ * go through all the macvlan filters and add a macvlan filter for each
  * unique vlan that already exists. If a PVID has been assigned, instead only
  * add the macaddr to that VLAN.
  *
  * Returns last filter added on success, else NULL
  **/
-struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
-					     const u8 *macaddr)
+struct i40e_mac_filter *i40e_add_mac_filter(struct i40e_vsi *vsi,
+					    const u8 *macaddr)
 {
 	struct i40e_mac_filter *f, *add = NULL;
 	struct hlist_node *h;
@@ -1513,15 +1514,16 @@ struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
 }
 
 /**
- * i40e_del_mac_all_vlan - Remove a MAC filter from all VLANS
+ * i40e_del_mac_filter - Remove a MAC filter from all VLANs
  * @vsi: the VSI to be searched
  * @macaddr: the mac address to be removed
  *
- * Removes a given MAC address from a VSI, regardless of VLAN
+ * Removes a given MAC address from a VSI regardless of what VLAN it has been
+ * associated with.
  *
  * Returns 0 for success, or error
  **/
-int i40e_del_mac_all_vlan(struct i40e_vsi *vsi, const u8 *macaddr)
+int i40e_del_mac_filter(struct i40e_vsi *vsi, const u8 *macaddr)
 {
 	struct i40e_mac_filter *f;
 	struct hlist_node *h;
@@ -1582,8 +1584,8 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 		netdev_info(netdev, "set new mac address %pM\n", addr->sa_data);
 
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
-	i40e_del_mac_all_vlan(vsi, netdev->dev_addr);
-	i40e_put_mac_in_vlan(vsi, addr->sa_data);
+	i40e_del_mac_filter(vsi, netdev->dev_addr);
+	i40e_add_mac_filter(vsi, addr->sa_data);
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 	ether_addr_copy(netdev->dev_addr, addr->sa_data);
 	if (vsi->type == I40E_VSI_MAIN) {
@@ -1760,7 +1762,7 @@ static int i40e_addr_sync(struct net_device *netdev, const u8 *addr)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 
-	if (i40e_put_mac_in_vlan(vsi, addr))
+	if (i40e_add_mac_filter(vsi, addr))
 		return 0;
 	else
 		return -ENOMEM;
@@ -1779,7 +1781,7 @@ static int i40e_addr_unsync(struct net_device *netdev, const u8 *addr)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 
-	i40e_del_mac_all_vlan(vsi, addr);
+	i40e_del_mac_filter(vsi, addr);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 0cdbdd3..1859911 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1943,7 +1943,7 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 		f = i40e_find_mac(vsi, al->list[i].addr);
 		if (!f)
-			f = i40e_put_mac_in_vlan(vsi, al->list[i].addr);
+			f = i40e_add_mac_filter(vsi, al->list[i].addr);
 
 		if (!f) {
 			dev_err(&pf->pdev->dev,
@@ -2008,7 +2008,7 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
 	/* delete addresses from the list */
 	for (i = 0; i < al->num_elements; i++)
-		if (i40e_del_mac_all_vlan(vsi, al->list[i].addr)) {
+		if (i40e_del_mac_filter(vsi, al->list[i].addr)) {
 			ret = I40E_ERR_INVALID_MAC_ADDR;
 			spin_unlock_bh(&vsi->mac_filter_hash_lock);
 			goto error_param;
-- 
2.10.2
