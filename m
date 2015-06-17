From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH v6 2/3] ixgbe: Add new ndo to trust VF
Date: Wed, 17 Jun 2015 11:43:08 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05EE18AA@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([210.143.35.51]:32862 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756577AbbFQLqa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 07:46:30 -0400
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Implements the new netdev op to trust VF in ixgbe.

The administrator can turn on and off VF trusted by ip command which
supports trust message.
 # ip link set dev eth0 vf 1 trust on
or
 # ip link set dev eth0 vf 1 trust off

Send a ping to reset VF on changing the status of trusting.
VF driver will reconfigure its features on reset.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 45 ++++++++++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  1 +
 4 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8830c0f..7f76c12 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -152,6 +152,7 @@ struct vf_data_storage {
 	u16 vlan_count;
 	u8 spoofchk_enabled;
 	bool rss_query_enabled;
+	u8 trusted;
 	unsigned int vf_api;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5f1b06a..376b49b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8349,6 +8349,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
 	.ndo_set_vf_rss_query_en = ixgbe_ndo_set_vf_rss_query_en,
+	.ndo_set_vf_trust	= ixgbe_ndo_set_vf_trust,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 1d17b58..826f88e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -116,6 +116,9 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 			 * we want to disable the querying by default.
 			 */
 			adapter->vfinfo[i].rss_query_enabled = 0;
+
+			/* Untrust all VFs */
+			adapter->vfinfo[i].trusted = false;
 		}
 
 		return 0;
@@ -1124,18 +1127,23 @@ void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(1), 0);
 }
 
-void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
+static inline void ixgbe_ping_vf(struct ixgbe_adapter *adapter, int vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 ping;
+
+	ping = IXGBE_PF_CONTROL_MSG;
+	if (adapter->vfinfo[vf].clear_to_send)
+		ping |= IXGBE_VT_MSGTYPE_CTS;
+	ixgbe_write_mbx(hw, &ping, 1, vf);
+}
+
+void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
+{
 	int i;
 
-	for (i = 0 ; i < adapter->num_vfs; i++) {
-		ping = IXGBE_PF_CONTROL_MSG;
-		if (adapter->vfinfo[i].clear_to_send)
-			ping |= IXGBE_VT_MSGTYPE_CTS;
-		ixgbe_write_mbx(hw, &ping, 1, i);
-	}
+	for (i = 0 ; i < adapter->num_vfs; i++)
+		ixgbe_ping_vf(adapter, i);
 }
 
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
@@ -1416,6 +1424,28 @@ int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
 	return 0;
 }
 
+int ixgbe_ndo_set_vf_trust(struct net_device *netdev, int vf, bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	/* nothing to do */
+	if (adapter->vfinfo[vf].trusted == setting)
+		return 0;
+
+	adapter->vfinfo[vf].trusted = setting;
+
+	/* reset VF to reconfigure features */
+	adapter->vfinfo[vf].clear_to_send = false;
+	ixgbe_ping_vf(adapter, vf);
+
+	e_info(drv, "VF %u is %strusted\n", vf, setting ? "" : "not ");
+
+	return 0;
+}
+
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi)
 {
@@ -1430,5 +1460,6 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
 	ivi->rss_query_en = adapter->vfinfo[vf].rss_query_enabled;
+	ivi->trusted = adapter->vfinfo[vf].trusted;
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 2c197e6..dad9257 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -49,6 +49,7 @@ int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
 				  bool setting);
+int ixgbe_ndo_set_vf_trust(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
-- 
1.8.3.1
