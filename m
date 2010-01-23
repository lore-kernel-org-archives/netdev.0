From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/7] ixgbe: Set the correct pool when VLANs are
	added in SR-IOV mode.
Date: Sat, 23 Jan 2010 00:45:43 -0800
Message-ID: <20100123084457.9865.51853.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:34083 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011Ab0AWIqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 03:46:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When VFs are allocated (as indicated by adapter->num_vfs is non-zero) then
the PF pool is no longer zero.  Instead it will be the same as the number
of VFs allocated.  When setting the VLVF entry for the PF we need to use
the correct pool otherwise the PF will get VLAN packets from the wire
because the packet will pass VFTA filtering and the PF has the default
pool, but it will not get VLAN packets from the VFs because it has
not set the correct pool bit in the VLVF entry.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 81971ed..2091658 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2432,15 +2432,17 @@ static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	int pool_ndx = adapter->num_vfs;
 
 	/* add VID to filter table */
-	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, true);
+	hw->mac.ops.set_vfta(&adapter->hw, vid, pool_ndx, true);
 }
 
 static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	int pool_ndx = adapter->num_vfs;
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		ixgbe_irq_disable(adapter);
@@ -2451,7 +2453,7 @@ static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 		ixgbe_irq_enable(adapter);
 
 	/* remove VID from filter table */
-	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, false);
+	hw->mac.ops.set_vfta(&adapter->hw, vid, pool_ndx, false);
 }
 
 static void ixgbe_vlan_rx_register(struct net_device *netdev,

