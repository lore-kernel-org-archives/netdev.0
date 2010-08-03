From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbevf: fix null pointer dereference due to
	filter being set for VLAN 0
Date: Mon, 02 Aug 2010 17:59:04 -0700
Message-ID: <20100803005849.4678.10583.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:44271
	"EHLO qmta08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076Ab0HCA7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 20:59:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects an issue that resulted in a null pointer dereference
for the addition of VLAN 0 without any VLANs being registered.  Also this
code removes some unnecessary checks for defines and the unnecessary setting
of VLAN flags since that is now handled within the kernel via the
vlan_features.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 4867440..3e291cc 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -1463,18 +1463,10 @@ static void ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct net_device *v_netdev;
 
 	/* add VID to filter table */
 	if (hw->mac.ops.set_vfta)
 		hw->mac.ops.set_vfta(hw, vid, 0, true);
-	/*
-	 * Copy feature flags from netdev to the vlan netdev for this vid.
-	 * This allows things like TSO to bubble down to our vlan device.
-	 */
-	v_netdev = vlan_group_get_device(adapter->vlgrp, vid);
-	v_netdev->features |= adapter->netdev->features;
-	vlan_group_set_device(adapter->vlgrp, vid, v_netdev);
 }
 
 static void ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -3402,7 +3394,6 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	/* setup the private structure */
 	err = ixgbevf_sw_init(adapter);
 
-#ifdef MAX_SKB_FRAGS
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
 			   NETIF_F_HW_VLAN_TX |
@@ -3416,13 +3407,12 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_IP_CSUM;
+	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-#endif /* MAX_SKB_FRAGS */
-
 	/* The HW MAC address was set and/or determined in sw_init */
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);

