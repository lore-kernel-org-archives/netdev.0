From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] e1000e: keep VLAN interfaces functional after rxvlan off
Date: Tue, 28 Jun 2016 20:41:31 -0700
Message-ID: <1467171691-54525-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56233 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509AbcF2DmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 23:42:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>

I've got a bug report about an e1000e interface, where a VLAN interface is
set up on top of it:

$ ip link add link ens1f0 name ens1f0.99 type vlan id 99
$ ip link set ens1f0 up
$ ip link set ens1f0.99 up
$ ip addr add 192.168.99.92 dev ens1f0.99

At this point, I can ping another host on vlan 99, ip 192.168.99.91.
However, if I do the following:

$ ethtool -K ens1f0 rxvlan off

Then no traffic passes on ens1f0.99. It comes back if I toggle rxvlan on
again. I'm not sure if this is actually intended behavior, or if there's a
lack of software VLAN stripping fallback, or what, but things continue to
work if I simply don't call e1000e_vlan_strip_disable() if there are
active VLANs (plagiarizing a function from the e1000 driver here) on the
interface.

Also slipped a related-ish fix to the kerneldoc text for
e1000e_vlan_strip_disable here...

Signed-off-by: Jarod Wilson <jarod@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 75e6089..73f7452 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -154,6 +154,16 @@ void __ew32(struct e1000_hw *hw, unsigned long reg, u32 val)
 	writel(val, hw->hw_addr + reg);
 }
 
+static bool e1000e_vlan_used(struct e1000_adapter *adapter)
+{
+	u16 vid;
+
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		return true;
+
+	return false;
+}
+
 /**
  * e1000_regdump - register printout routine
  * @hw: pointer to the HW structure
@@ -2789,7 +2799,7 @@ static void e1000e_vlan_filter_enable(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000e_vlan_strip_enable - helper to disable HW VLAN stripping
+ * e1000e_vlan_strip_disable - helper to disable HW VLAN stripping
  * @adapter: board private structure to initialize
  **/
 static void e1000e_vlan_strip_disable(struct e1000_adapter *adapter)
@@ -3443,7 +3453,8 @@ static void e1000e_set_rx_mode(struct net_device *netdev)
 
 	ew32(RCTL, rctl);
 
-	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX ||
+	    e1000e_vlan_used(adapter))
 		e1000e_vlan_strip_enable(adapter);
 	else
 		e1000e_vlan_strip_disable(adapter);
-- 
2.5.5
