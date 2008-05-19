From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/4] e1000e: Allow TSO to trickle down to VLAN device
Date: Mon, 19 May 2008 15:47:29 -0700
Message-ID: <20080519224652.7175.74105.stgit@localhost.localdomain>
References: <20080519224303.7175.71980.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33806 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755554AbYESWra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 18:47:30 -0400
In-Reply-To: <20080519224303.7175.71980.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix TSO over VLAN's by propagating settings to our VLAN devices.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |   16 ++++++++++++++++
 drivers/net/e1000e/netdev.c  |    8 ++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index ce045ac..23e9703 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -32,6 +32,7 @@
 #include <linux/ethtool.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
+#include <linux/if_vlan.h>
 
 #include "e1000.h"
 
@@ -371,6 +372,8 @@ static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
 static int e1000_set_tso(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int i;
+	struct net_device *v_netdev;
 
 	if (data) {
 		netdev->features |= NETIF_F_TSO;
@@ -378,8 +381,21 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
 	} else {
 		netdev->features &= ~NETIF_F_TSO;
 		netdev->features &= ~NETIF_F_TSO6;
+		/* disable TSO on all VLANs if they're present */
+		if (!adapter->vlgrp)
+			goto tso_out;
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			v_netdev = vlan_group_get_device(adapter->vlgrp, i);
+			if (!v_netdev)
+				continue;
+
+			v_netdev->features &= ~NETIF_F_TSO;
+			v_netdev->features &= ~NETIF_F_TSO6;
+			vlan_group_set_device(adapter->vlgrp, i, v_netdev);
+		}
 	}
 
+tso_out:
 	ndev_info(netdev, "TSO is %s\n",
 		  data ? "Enabled" : "Disabled");
 	adapter->flags |= FLAG_TSO_FORCE;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8991ab8..5110382 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1432,6 +1432,7 @@ static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 vfta, index;
+	struct net_device *v_netdev;
 
 	/* don't update vlan cookie if already programmed */
 	if ((adapter->hw.mng_cookie.status &
@@ -1443,6 +1444,13 @@ static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	vfta = E1000_READ_REG_ARRAY(hw, E1000_VFTA, index);
 	vfta |= (1 << (vid & 0x1F));
 	e1000e_write_vfta(hw, index, vfta);
+	/*
+	 * Copy feature flags from netdev to the vlan netdev for this vid.
+	 * This allows things like TSO to bubble down to our vlan device.
+	 */
+	v_netdev = vlan_group_get_device(adapter->vlgrp, vid);
+	v_netdev->features |= adapter->netdev->features;
+	vlan_group_set_device(adapter->vlgrp, vid, v_netdev);
 }
 
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)

