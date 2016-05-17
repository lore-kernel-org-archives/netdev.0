From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/2] ixgbe: Fix VLAN features error
Date: Mon, 16 May 2016 19:25:24 -0700
Message-ID: <1463451924-96911-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463451924-96911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8392 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbcEQCZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 22:25:27 -0400
In-Reply-To: <1463451924-96911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

It looks like at some point I somehow transposed the location of setting
the VLAN features in netdev->features and the configuration of the
vlan_features.  As a result the driver is now generating a warning about
vlan_features being setup incorrectly.

This patch corrects that by placing the update of netdev->features to
include the VLAN features so that it is after the point where we write
netdev->features into netdev->vlan_features.

Fixes: b83e30104bd9 ("ixgbe/ixgbevf: Add support for GSO partial")
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7bbf9b1..9f3677c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9508,15 +9508,15 @@ skip_sriov:
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+	netdev->vlan_features |= netdev->features | NETIF_F_TSO_MANGLEID;
+	netdev->hw_enc_features |= netdev->vlan_features;
+	netdev->mpls_features |= NETIF_F_HW_CSUM;
+
 	/* set this bit last since it cannot be part of vlan_features */
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER |
 			    NETIF_F_HW_VLAN_CTAG_RX |
 			    NETIF_F_HW_VLAN_CTAG_TX;
 
-	netdev->vlan_features |= netdev->features | NETIF_F_TSO_MANGLEID;
-	netdev->hw_enc_features |= netdev->vlan_features;
-	netdev->mpls_features |= NETIF_F_HW_CSUM;
-
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
-- 
2.5.5
