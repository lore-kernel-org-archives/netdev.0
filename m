From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH 3/3] ixgbe: Add new ndo to allow VF multicast
 promiscuous mode
Date: Fri, 30 Jan 2015 11:38:44 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E190CA@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
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

Implements the new netdev op to allow VF multicast promiscuous mode.

The administrator can allow to VF multicast promiscuous mode for only
trusted VM. After allowing multicast promiscuous mode from the host,
we can use over 30 IPv6 addresses on VM.
 # ./ip link set dev eth0 vf 1 mc_promisc on

When disallowing multicast promiscuous mode, we can only use 30 IPv6 addresses.
 # ./ip link set dev eth0 vf 1 mc_promisc off

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 35 ++++++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  1 +
 4 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index bf3333e..33fde2e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -150,6 +150,7 @@ struct vf_data_storage {
 	u16 tx_rate;
 	u16 vlan_count;
 	u8 spoofchk_enabled;
+	u8 mc_promisc_allowed;
 	unsigned int vf_api;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2ed2c7d..34924f7 100644
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
+					adapter->vfinfo[i].mc_promisc_allowed);
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
index c19b7b8..9f39a26 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -111,8 +111,11 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		for (i = 0; i < adapter->num_vfs; i++) {
 			/* Enable spoof checking for all VFs */
 			adapter->vfinfo[i].spoofchk_enabled = true;
-			/* Turn multicast promiscuous mode off for all VFs */
+			/*
+			 * Disallow VF multicast promiscuous capability
+			 * and turn it off for all VFs */
 			adapter->vfinfo[i].mc_promisc = false;
+			adapter->vfinfo[i].mc_promisc_allowed = false;
 		}
 		return 0;
 	}
@@ -1019,7 +1022,7 @@ static int ixgbe_set_vf_mc_promisc(struct ixgbe_adapter *adapter,
 
 	adapter->vfinfo[vf].mc_promisc = enable;
 
-	if (enable)
+	if (enable && adapter->vfinfo[vf].mc_promisc_allowed)
 		return ixgbe_enable_vf_mc_promisc(adapter, vf);
 	else
 		return ixgbe_disable_vf_mc_promisc(adapter, vf);
@@ -1415,6 +1418,32 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
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
+	/* nothing to do */
+	if (adapter->vfinfo[vf].mc_promisc_allowed == setting)
+		return 0;
+
+	adapter->vfinfo[vf].mc_promisc_allowed = setting;
+
+	/* if VF requests multicast promiscuous */
+	if (adapter->vfinfo[vf].mc_promisc) {
+		if (setting)
+			ixgbe_enable_vf_mc_promisc(adapter, vf);
+		else
+			ixgbe_disable_vf_mc_promisc(adapter, vf);
+	}
+
+	return 0;
+}
+
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi)
 {
@@ -1428,5 +1457,7 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	ivi->vlan = adapter->vfinfo[vf].pf_vlan;
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
+	ivi->mc_promisc = adapter->vfinfo[vf].mc_promisc_allowed;
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
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
