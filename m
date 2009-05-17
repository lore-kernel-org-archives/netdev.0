From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 02/11] ixgbe: Add SAN MAC address to the RAR,
	return the address to DCB
Date: Sun, 17 May 2009 15:32:48 -0700
Message-ID: <20090517223247.14124.79816.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:38650
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755023AbZEQWdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 18:33:06 -0400
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com>

After acquiring the SAN MAC address from the EEPROM, we need to program it
into one of the RARs.  Also, DCB will use this MAC address to run DCBX
commands, so it doesn't have to play musical MAC addresses when things like
bonding enter the picture.  So we need to return the MAC address through
the netlink interface to userspace.

This also moves the init_rx_addrs() call out of start_hw() and into
reset_hw().  We shouldn't try to read any of the RAR information before
initializing our internal accounting of the RAR table, which was what
was happening.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c  |    6 ++++++
 drivers/net/ixgbe/ixgbe_82599.c  |   17 +++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.c |    6 ------
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    7 ++++++-
 4 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index e051964..55186dc 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -801,6 +801,12 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, hw->mac.orig_autoc);
 	}
 
+	/*
+	 * Store MAC address from RAR0, clear receive address registers, and
+	 * clear the multicast table
+	 */
+	hw->mac.ops.init_rx_addrs(hw);
+
 	/* Store the permanent mac address */
 	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 6bc964f..eaecf5e 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -816,12 +816,29 @@ s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 		}
 	}
 
+	/*
+	 * Store MAC address from RAR0, clear receive address registers, and
+	 * clear the multicast table.  Also reset num_rar_entries to 128,
+	 * since we modify this value when programming the SAN MAC address.
+	 */
+	hw->mac.num_rar_entries = 128;
+	hw->mac.ops.init_rx_addrs(hw);
+
 	/* Store the permanent mac address */
 	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
 	/* Store the permanent SAN mac address */
 	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
 
+	/* Add the SAN MAC address to the RAR only if it's a valid address */
+	if (ixgbe_validate_mac_addr(hw->mac.san_addr) == 0) {
+		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
+		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
+
+		/* Reserve the last RAR for the SAN MAC address */
+		hw->mac.num_rar_entries--;
+	}
+
 reset_hw_out:
 	return status;
 }
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 60638e2..af39275 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -71,12 +71,6 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 	/* Identify the PHY */
 	hw->phy.ops.identify(hw);
 
-	/*
-	 * Store MAC address from RAR0, clear receive address registers, and
-	 * clear the multicast table
-	 */
-	hw->mac.ops.init_rx_addrs(hw);
-
 	/* Clear the VLAN filter table */
 	hw->mac.ops.clear_vfta(hw);
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 99e0c10..5d5d390 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -155,10 +155,15 @@ static void ixgbe_dcbnl_get_perm_hw_addr(struct net_device *netdev,
 					 u8 *perm_addr)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int i;
+	int i, j;
 
 	for (i = 0; i < netdev->addr_len; i++)
 		perm_addr[i] = adapter->hw.mac.perm_addr[i];
+
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		for (j = 0; j < netdev->addr_len; j++, i++)
+			perm_addr[i] = adapter->hw.mac.san_addr[j];
+	}
 }
 
 static void ixgbe_dcbnl_set_pg_tc_cfg_tx(struct net_device *netdev, int tc,

