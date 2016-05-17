From: Jarod Wilson <jarod@redhat.com>
Subject: [RFC PATCH net] e1000e: keep vlan interfaces functional after rxvlan off
Date: Tue, 17 May 2016 15:03:51 -0400
Message-ID: <1463511831-13684-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got a bug report about an e1000e interface, where a vlan interface is
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
lack of software vlan stripping fallback, or what, but things continue to
work if I simply don't call e1000e_vlan_strip_disable() if there are
active vlans (plagiarizing a function from the e1000 driver here) on the
interface.

Also slipped a related-ish fix to the kerneldoc text for
e1000e_vlan_strip_disable here...

CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
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
1.8.3.1
