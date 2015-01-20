From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH 2/2] ixgbe: Add new ndo to control VF
 multicast promiscuous mode
Date: Tue, 20 Jan 2015 10:51:49 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E07377@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>, Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
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

Implements the new netdev op to turn VF multicast promiscuous mode on or off.

When VF multicast promiscuous mode is enabled, all multicast packets are
delivered to the VF.

After enabling multicast promiscuous mode from the host, we can use over 30
IPv6 addresses on VM.
 # ./ip link set dev eth0 vf 1 mc_promisc on

When disabling multicast promiscuous mode, we can only use 30 IPv6 addresses.
 # ./ip link set dev eth0 vf 1 mc_promisc off

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 34 ++++++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  1 +
 4 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index b6137be..1975570 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -149,6 +149,7 @@ struct vf_data_storage {
 	u16 tx_rate;
 	u16 vlan_count;
 	u8 spoofchk_enabled;
+	u8 mc_promisc_enabled;
 	unsigned int vf_api;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2ed2c7d..6fb1753 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3569,6 +3569,12 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 		if (!adapter->vfinfo[i].spoofchk_enabled)
 			ixgbe_ndo_set_vf_spoofchk(adapter->netdev, i, false);
 	}
+
+	/* Reconfigure multicast promiscuous mode */
+	for (i = 0; i < adapter->num_vfs; i++) {
+		ixgbe_ndo_set_vf_mc_promisc(adapter->netdev, i,
+					adapter->vfinfo[i].mc_promisc_enabled);
+	}
 }
 
 static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
@@ -7955,6 +7961,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
 	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
+	.ndo_set_vf_mc_promisc	= ixgbe_ndo_set_vf_mc_promisc,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c76ba90..3e83f03 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -108,9 +108,12 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
 				     IXGBE_FLAG2_RSC_ENABLED);
 
-		/* enable spoof checking for all VFs */
-		for (i = 0; i < adapter->num_vfs; i++)
+		for (i = 0; i < adapter->num_vfs; i++) {
+			/* enable spoof checking for all VFs */
 			adapter->vfinfo[i].spoofchk_enabled = true;
+			/* disable multicast promiscuous for all VFs */
+			adapter->vfinfo[i].mc_promisc_enabled = false;
+		}
 		return 0;
 	}
 
@@ -1330,6 +1333,31 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
 	return 0;
 }
 
+int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev, int vf, bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vmolr;
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	adapter->vfinfo[vf].mc_promisc_enabled = setting;
+
+	vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
+	if (setting) {
+		e_info(drv, "VF %u: enabling multicast promiscuous\n", vf);
+		vmolr |= IXGBE_VMOLR_MPE;
+	} else {
+		e_info(drv, "VF %u: disabling multicast promiscuous\n", vf);
+		vmolr &= ~IXGBE_VMOLR_MPE;
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
+
+	return 0;
+}
+
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi)
 {
@@ -1343,5 +1371,7 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	ivi->vlan = adapter->vfinfo[vf].pf_vlan;
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
+	ivi->mc_promisc = adapter->vfinfo[vf].mc_promisc_enabled;
+
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 32c26d5..0ab98e6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -47,6 +47,7 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
 			int max_tx_rate);
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
+int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
-- 
1.9.0


------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
