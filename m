From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH v2] ixgbe: make VLAN filter conditional
Date: Fri, 27 Feb 2015 07:29:25 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E45319@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Disable hardware VLAN filtering if netdev->features VLAN flag is dropped.

In SR-IOV case, there is a use case which needs to disable VLAN filter.
For example, we need to make a network function with VF in virtualized
environment. That network function may be a software switch, a router
or etc. It means that that network function will be an end point which
terminates many VLANs.

In the current implementation, VLAN filtering always be turned on and
VF can receive only 63 VLANs. It means that only 63 VLANs can be terminated
in one NIC.

With this patch, if the user turns VLAN filtering off on the host, VF
can receive every VLAN packet.

This VLAN filtering can be turned on or off when SR-IOV is disabled, if not
the operation is rejected.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 23 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  4 ++++
 2 files changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f690f5d..9593366 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4081,6 +4081,10 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		hw->addr_ctrl.user_set_promisc = false;
 	}
 
+	/* Disable hardware VLAN filter if the feature flag is dropped */
+	if (!(netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
+		vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
+
 	/*
 	 * Write addresses to available RAR registers, if there is not
 	 * sufficient space to store all the addresses then enable
@@ -7734,6 +7738,26 @@ static int ixgbe_set_features(struct net_device *netdev,
 	netdev_features_t changed = netdev->features ^ features;
 	bool need_reset = false;
 
+	if (changed & NETIF_F_HW_VLAN_CTAG_FILTER) {
+		int vlan_filter = features & NETIF_F_HW_VLAN_CTAG_FILTER;
+
+		/* Prevent controlling VLAN filter if VFs exist */
+		if (adapter->num_vfs > 0) {
+			e_dev_info("%s HW VLAN filter is not allowed when "
+				   "SR-IOV enabled.\n",
+				   vlan_filter ? "Enabling" : "Disabling");
+			return -EINVAL;
+		}
+		if (!vlan_filter) {
+			e_dev_warn("Disabling HW VLAN filter. All VFs cannot "
+				   "set VLAN filter from VF driver.\n");
+			e_dev_warn("All VLAN packets are delivered to "
+				   "every VF.\n");
+		}
+		/* reset if HW VLAN filter is changed */
+		need_reset = true;
+	}
+
 	/* Make sure RSC matches LRO, reset if change */
 	if (!(features & NETIF_F_LRO)) {
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 288f39f..9ad45738 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -839,6 +839,10 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
 	u32 bits;
 	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
+	/* Ignore if VLAN filter is disabled */
+	if (!(adapter->netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
+		return 0;
+
 	if (adapter->vfinfo[vf].pf_vlan || tcs) {
 		e_warn(drv,
 		       "VF %d attempted to override administratively set VLAN configuration\n"
-- 
2.1.0

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
