From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH] ixgbe: make VLAN filter conditional in SR-IOV
	case
Date: Thu, 13 Nov 2014 08:28:20 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05D9D336@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>, Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "e1000-devel@lists.sourceforge.net"
 <e1000-devel@lists.sourceforge.net>
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
VF can receive only 63 VLANs. It means that only 63 VLANs can be used
and it's not enough at all for building a virtual router.

With this patch, if the user turns VLAN filtering off on the host, VF
can receive every VLAN packet.
The behavior is changed only if VLAN filtering is turned off by ethtool.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 10 ++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  4 ++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3..91ce3a8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3948,6 +3948,12 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		hw->addr_ctrl.user_set_promisc = false;
 	}
 
+	/* Disable hardware VLAN filter if the feature flag is dropped */
+	if (!(netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
+		dev_info(&adapter->pdev->dev, "Disable HW VLAN filter\n");
+		vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
+	}
+
 	/*
 	 * Write addresses to available RAR registers, if there is not
 	 * sufficient space to store all the addresses then enable
@@ -7634,6 +7640,10 @@ static int ixgbe_set_features(struct net_device *netdev,
 	else
 		ixgbe_vlan_strip_disable(adapter);
 
+	/* reset if HW VLAN filter is changed */
+	if (changed & NETIF_F_HW_VLAN_CTAG_FILTER)
+		need_reset = true;
+
 	if (changed & NETIF_F_RXALL)
 		need_reset = true;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 13916d8..5508d8a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -776,6 +776,10 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
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
1.9.0


------------------------------------------------------------------------------
Comprehensive Server Monitoring with Site24x7.
Monitor 10 servers for $9/Month.
Get alerted through email, SMS, voice calls or mobile push notifications.
Take corrective actions from your mobile device.
http://pubads.g.doubleclick.net/gampad/clk?id=154624111&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
