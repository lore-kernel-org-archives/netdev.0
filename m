From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] i40e: use ether_addr_equal_64bits
Date: Wed,  5 Mar 2014 20:21:32 -0800
Message-ID: <1394079704-1108-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51291 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886AbaCFEVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:21:48 -0500
In-Reply-To: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

All ether_addr_equal tests in i40e can use the
slightly more efficient ether_addr_equal_64bits.

All addresses passed to the various functions that
use ether_addr_equal are using structs that have 2
or more bytes of additional data after the mac addr
being tested.

struct i40e_mac_filter.macaddr[6] (followed by s16 vlan)
struct net_device.dev_addr (pointer to char array of MAX_ADDR_LEN)
struct sockaddr.sa_data (array of 14 bytes)
struct netdev_hw_addr.addr (pointer to char array of MAX_ADDR_LEN)

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 53f3ed2..5157922 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -997,7 +997,7 @@ static struct i40e_mac_filter *i40e_find_filter(struct i40e_vsi *vsi,
 		return NULL;
 
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
-		if ((ether_addr_equal(macaddr, f->macaddr)) &&
+		if (ether_addr_equal_64bits(macaddr, f->macaddr) &&
 		    (vlan == f->vlan)    &&
 		    (!is_vf || f->is_vf) &&
 		    (!is_netdev || f->is_netdev))
@@ -1025,7 +1025,7 @@ struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
 		return NULL;
 
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
-		if ((ether_addr_equal(macaddr, f->macaddr)) &&
+		if (ether_addr_equal_64bits(macaddr, f->macaddr) &&
 		    (!is_vf || f->is_vf) &&
 		    (!is_netdev || f->is_netdev))
 			return f;
@@ -1214,7 +1214,7 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 
 	netdev_info(netdev, "set mac address=%pM\n", addr->sa_data);
 
-	if (ether_addr_equal(netdev->dev_addr, addr->sa_data))
+	if (ether_addr_equal_64bits(netdev->dev_addr, addr->sa_data))
 		return 0;
 
 	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
@@ -1417,21 +1417,24 @@ static void i40e_set_rx_mode(struct net_device *netdev)
 
 		if (is_multicast_ether_addr(f->macaddr)) {
 			netdev_for_each_mc_addr(mca, netdev) {
-				if (ether_addr_equal(mca->addr, f->macaddr)) {
+				if (ether_addr_equal_64bits(mca->addr,
+							    f->macaddr)) {
 					found = true;
 					break;
 				}
 			}
 		} else {
 			netdev_for_each_uc_addr(uca, netdev) {
-				if (ether_addr_equal(uca->addr, f->macaddr)) {
+				if (ether_addr_equal_64bits(uca->addr,
+							    f->macaddr)) {
 					found = true;
 					break;
 				}
 			}
 
 			for_each_dev_addr(netdev, ha) {
-				if (ether_addr_equal(ha->addr, f->macaddr)) {
+				if (ether_addr_equal_64bits(ha->addr,
+							    f->macaddr)) {
 					found = true;
 					break;
 				}
@@ -1905,7 +1908,8 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
 		if (is_netdev) {
 			if (f->vlan &&
-			    ether_addr_equal(netdev->dev_addr, f->macaddr))
+			    ether_addr_equal_64bits(netdev->dev_addr,
+						    f->macaddr))
 				filter_count++;
 		}
 
-- 
1.8.3.1
