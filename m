From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/14] i40e: allow user to set LAA again
Date: Tue, 24 Jun 2014 18:26:21 -0700
Message-ID: <1403659585-32055-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35161 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389AbaFYB0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 21:26:45 -0400
In-Reply-To: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Don't short-circuit the LAA assignment when the driver thinks it has
already been done - it is possible that the user might want to force
the address setting again.  At the same time, this requires a little
re-ordering of the filter management.

Change-ID: Ia0d71e3bc04edd7b68cf67edecc00abe7b9f6639
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 31 +++++++++++++++--------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 44789c2..81cbea7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1327,9 +1327,6 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 
 	netdev_info(netdev, "set mac address=%pM\n", addr->sa_data);
 
-	if (ether_addr_equal(netdev->dev_addr, addr->sa_data))
-		return 0;
-
 	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
 	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
 		return -EADDRNOTAVAIL;
@@ -1345,22 +1342,26 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 				    ret);
 			return -EADDRNOTAVAIL;
 		}
-
-		ether_addr_copy(vsi->back->hw.mac.addr, addr->sa_data);
 	}
 
-	/* In order to be sure to not drop any packets, add the new address
-	 * then delete the old one.
-	 */
-	f = i40e_add_filter(vsi, addr->sa_data, I40E_VLAN_ANY, false, false);
-	if (!f)
-		return -ENOMEM;
+	if (!i40e_find_mac(vsi, addr->sa_data, false, true)) {
 
-	i40e_sync_vsi_filters(vsi);
-	i40e_del_filter(vsi, netdev->dev_addr, I40E_VLAN_ANY, false, false);
-	i40e_sync_vsi_filters(vsi);
+		/* In order to be sure to not drop any packets, add the
+		 * new address first then delete the old one.
+		 */
+		f = i40e_add_filter(vsi, addr->sa_data, I40E_VLAN_ANY,
+				    false, false);
+		if (!f)
+			return -ENOMEM;
+
+		i40e_sync_vsi_filters(vsi);
+		i40e_del_filter(vsi, netdev->dev_addr, I40E_VLAN_ANY,
+				false, false);
+		i40e_sync_vsi_filters(vsi);
+	}
 
-	ether_addr_copy(netdev->dev_addr, addr->sa_data);
+	if (!ether_addr_equal(netdev->dev_addr, addr->sa_data))
+		ether_addr_copy(netdev->dev_addr, addr->sa_data);
 
 	return 0;
 }
-- 
1.9.3
