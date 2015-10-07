From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/18] i40e/i40evf: fix unicast mac address add
Date: Wed,  7 Oct 2015 15:47:08 -0700
Message-ID: <1444258032-41476-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3926 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753727AbbJGWrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:25 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When using something like "ip maddr add ..." to add another unicast mac
address to the netdev, the mac address comes into the set_rx_mode handler
in the multicast list whether it is a unicast or multicast address.
This was confusing the code when it was trying to search for addresses
that needed to be deleted from the VSI, because it was looking for the
VSI unicast address in the netdev unicast list.  The result was that a
new unicast address would get added to the VSI list and then immediately
removed, and would never actually make it down into the hardware.

This patch removes the separation from unicast and multicast in the search
for filters to be deleted.  It also simplifies the logic a little with a
jump to the bottom of the loop when an address is found.  Now it doesn't
matter which netdev list the address is hiding in, we'll check them all.

Change-ID: Ie3685a92427ae7d2212bf948919ce295bc7a874c
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 41 +++++++++-------------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 45 ++++++++++++-------------
 2 files changed, 38 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f205e18..84f9dd9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1726,36 +1726,27 @@ static void i40e_set_rx_mode(struct net_device *netdev)
 
 	/* remove filter if not in netdev list */
 	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
-		bool found = false;
 
 		if (!f->is_netdev)
 			continue;
 
-		if (is_multicast_ether_addr(f->macaddr)) {
-			netdev_for_each_mc_addr(mca, netdev) {
-				if (ether_addr_equal(mca->addr, f->macaddr)) {
-					found = true;
-					break;
-				}
-			}
-		} else {
-			netdev_for_each_uc_addr(uca, netdev) {
-				if (ether_addr_equal(uca->addr, f->macaddr)) {
-					found = true;
-					break;
-				}
-			}
+		netdev_for_each_mc_addr(mca, netdev)
+			if (ether_addr_equal(mca->addr, f->macaddr))
+				goto bottom_of_search_loop;
 
-			for_each_dev_addr(netdev, ha) {
-				if (ether_addr_equal(ha->addr, f->macaddr)) {
-					found = true;
-					break;
-				}
-			}
-		}
-		if (!found)
-			i40e_del_filter(
-			   vsi, f->macaddr, I40E_VLAN_ANY, false, true);
+		netdev_for_each_uc_addr(uca, netdev)
+			if (ether_addr_equal(uca->addr, f->macaddr))
+				goto bottom_of_search_loop;
+
+		for_each_dev_addr(netdev, ha)
+			if (ether_addr_equal(ha->addr, f->macaddr))
+				goto bottom_of_search_loop;
+
+		/* f->macaddr wasn't found in uc, mc, or ha list so delete it */
+		i40e_del_filter(vsi, f->macaddr, I40E_VLAN_ANY, false, true);
+
+bottom_of_search_loop:
+		continue;
 	}
 
 	/* check for other flag changes */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f3a61c4..cc78fdf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -855,6 +855,7 @@ static void i40evf_set_rx_mode(struct net_device *netdev)
 	struct i40evf_mac_filter *f, *ftmp;
 	struct netdev_hw_addr *uca;
 	struct netdev_hw_addr *mca;
+	struct netdev_hw_addr *ha;
 	int count = 50;
 
 	/* add addr if not already in the filter list */
@@ -876,29 +877,27 @@ static void i40evf_set_rx_mode(struct net_device *netdev)
 	}
 	/* remove filter if not in netdev list */
 	list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list, list) {
-		bool found = false;
-
-		if (is_multicast_ether_addr(f->macaddr)) {
-			netdev_for_each_mc_addr(mca, netdev) {
-				if (ether_addr_equal(mca->addr, f->macaddr)) {
-					found = true;
-					break;
-				}
-			}
-		} else {
-			netdev_for_each_uc_addr(uca, netdev) {
-				if (ether_addr_equal(uca->addr, f->macaddr)) {
-					found = true;
-					break;
-				}
-			}
-			if (ether_addr_equal(f->macaddr, adapter->hw.mac.addr))
-				found = true;
-		}
-		if (!found) {
-			f->remove = true;
-			adapter->aq_required |= I40EVF_FLAG_AQ_DEL_MAC_FILTER;
-		}
+		netdev_for_each_mc_addr(mca, netdev)
+			if (ether_addr_equal(mca->addr, f->macaddr))
+				goto bottom_of_search_loop;
+
+		netdev_for_each_uc_addr(uca, netdev)
+			if (ether_addr_equal(uca->addr, f->macaddr))
+				goto bottom_of_search_loop;
+
+		for_each_dev_addr(netdev, ha)
+			if (ether_addr_equal(ha->addr, f->macaddr))
+				goto bottom_of_search_loop;
+
+		if (ether_addr_equal(f->macaddr, adapter->hw.mac.addr))
+			goto bottom_of_search_loop;
+
+		/* f->macaddr wasn't found in uc, mc, or ha list so delete it */
+		f->remove = true;
+		adapter->aq_required |= I40EVF_FLAG_AQ_DEL_MAC_FILTER;
+
+bottom_of_search_loop:
+		continue;
 	}
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 }
-- 
2.4.3
