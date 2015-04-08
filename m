From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH v3 3/3] ixgbe: Add new ndo to allow VF
 multicast promiscuous mode
Date: Wed, 8 Apr 2015 05:38:28 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CDA0@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>, Edward Cree <ecree@solarflare.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
To: "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
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

The multicast promiscuous mode is not allowed for all VFs by default.

The administrator can allow to VF multicast promiscuous mode for only
trusted VM. After allowing multicast promiscuous mode from the host,
we can use over 30 IPv6 addresses on VM.
 # ip link set dev eth0 vf 1 mc_promisc on

When disallowing multicast promiscuous mode, ixgbevf can only handle 30
IPv6 addresses at most.
 # ip link set dev eth0 vf 1 mc_promisc off

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 32 ++++++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
 4 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 08e65b6..4a9f74d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -153,6 +153,7 @@ struct vf_data_storage {
 	u16 vlan_count;
 	u8 spoofchk_enabled;
 	bool rss_query_enabled;
+	u8 mc_promisc_allowed;
 	unsigned int vf_api;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2f41403..c0e07c5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3663,6 +3663,12 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 		ixgbe_ndo_set_vf_rss_query_en(adapter->netdev, i,
 					      adapter->vfinfo[i].rss_query_enabled);
 	}
+
+	/* Reconfigure multicast promiscuous mode */
+	for (i = 0; i < adapter->num_vfs; i++) {
+		ixgbe_ndo_set_vf_mc_promisc(adapter->netdev, i,
+					adapter->vfinfo[i].mc_promisc_allowed);
+	}
 }
 
 static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
@@ -8165,6 +8171,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
 	.ndo_set_vf_rss_query_en = ixgbe_ndo_set_vf_rss_query_en,
+	.ndo_set_vf_mc_promisc	= ixgbe_ndo_set_vf_mc_promisc,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 615f651..42b24a0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -117,8 +117,11 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 			 */
 			adapter->vfinfo[i].rss_query_enabled = 0;
 
-			/* Turn multicast promiscuous mode off for all VFs */
+			/* Disallow VF multicast promiscuous capability
+			 * and turn it off for all VFs
+			 */
 			adapter->vfinfo[i].mc_promisc = false;
+			adapter->vfinfo[i].mc_promisc_allowed = false;
 		}
 
 		return 0;
@@ -1068,7 +1071,7 @@ static int ixgbe_set_vf_mc_promisc(struct ixgbe_adapter *adapter,
 
 	adapter->vfinfo[vf].mc_promisc = enable;
 
-	if (enable)
+	if (enable && adapter->vfinfo[vf].mc_promisc_allowed)
 		return ixgbe_enable_vf_mc_promisc(adapter, vf);
 	else
 		return ixgbe_disable_vf_mc_promisc(adapter, vf);
@@ -1492,6 +1495,30 @@ int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
 	return 0;
 }
 
+int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev, int vf, bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
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
@@ -1506,5 +1533,6 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
 	ivi->rss_query_en = adapter->vfinfo[vf].rss_query_enabled;
+	ivi->mc_promisc = adapter->vfinfo[vf].mc_promisc_allowed;
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 2c197e6..bf5b8f1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -49,6 +49,8 @@ int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
 				  bool setting);
+int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev,
+				int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
-- 
2.1.0

------------------------------------------------------------------------------
BPM Camp - Free Virtual Workshop May 6th at 10am PDT/1PM EDT
Develop your own process in accordance with the BPMN 2 standard
Learn Process modeling best practices with Bonita BPM through live exercises
http://www.bonitasoft.com/be-part-of-it/events/bpm-camp-virtual- event?utm_
source=Sourceforge_BPM_Camp_5_6_15&utm_medium=email&utm_campaign=VA_SF
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
