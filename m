From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH 1/3] ixgbe,
 ixgbevf: Add new mbox API to enable MC promiscuous mode
Date: Fri, 30 Jan 2015 11:37:02 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E1908D@BPXM14GP.gisp.nec.co.jp>
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

The limitation of the number of multicast address for VF is not enough
for the large scale server with SR-IOV feature.
IPv6 requires the multicast MAC address for each IP address to handle
the Neighbor Solicitation message.
We couldn't assign over 30 IPv6 addresses to a single VF interface.

The easy way to solve this is enabling multicast promiscuous mode.
It is good to have a functionality to enable multicast promiscuous mode
for each VF from VF driver.

This patch introduces the new mbox API, IXGBE_VF_SET_MC_PROMISC, to
enable/disable multicast promiscuous mode in VF. If multicast promiscuous
mode is enabled the VF can receive all multicast packets.

With this patch, the ixgbevf driver automatically enable multicast
promiscuous mode when the number of multicast addresses is over than 30
if possible.

This also bump the API version up to 1.2 to check whether the API,
IXGBE_VF_SET_MC_PROMISC is available.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 89 ++++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 13 +++-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  4 +
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 29 +++++++-
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
 7 files changed, 137 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index b6137be..bf3333e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -144,6 +144,7 @@ struct vf_data_storage {
 	u16 vlans_enabled;
 	bool clear_to_send;
 	bool pf_set_mac;
+	bool mc_promisc;
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
 	u16 tx_rate;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index a5cb755..2963557 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -73,6 +73,7 @@ enum ixgbe_pfvf_api_rev {
 	ixgbe_mbox_api_10,	/* API version 1.0, linux/freebsd VF driver */
 	ixgbe_mbox_api_20,	/* API version 2.0, solaris Phase1 VF driver */
 	ixgbe_mbox_api_11,	/* API version 1.1, linux/freebsd VF driver */
+	ixgbe_mbox_api_12,	/* API version 1.2, linux/freebsd VF driver */
 	/* This value should always be last */
 	ixgbe_mbox_api_unknown,	/* indicates that API version is not known */
 };
@@ -91,6 +92,9 @@ enum ixgbe_pfvf_api_rev {
 /* mailbox API, version 1.1 VF requests */
 #define IXGBE_VF_GET_QUEUES	0x09 /* get queue configuration */
 
+/* mailbox API, version 1.2 VF requests */
+#define IXGBE_VF_SET_MC_PROMISC	0x0a /* VF requests PF to set MC promiscuous */
+
 /* GET_QUEUES return data indices within the mailbox */
 #define IXGBE_VF_TX_QUEUES	1	/* number of Tx queues supported */
 #define IXGBE_VF_RX_QUEUES	2	/* number of Rx queues supported */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c76ba90..c19b7b8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -108,9 +108,12 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
 				     IXGBE_FLAG2_RSC_ENABLED);
 
-		/* enable spoof checking for all VFs */
-		for (i = 0; i < adapter->num_vfs; i++)
+		for (i = 0; i < adapter->num_vfs; i++) {
+			/* Enable spoof checking for all VFs */
 			adapter->vfinfo[i].spoofchk_enabled = true;
+			/* Turn multicast promiscuous mode off for all VFs */
+			adapter->vfinfo[i].mc_promisc = false;
+		}
 		return 0;
 	}
 
@@ -311,6 +314,40 @@ int ixgbe_pci_sriov_configure(struct pci_dev *dev, int num_vfs)
 		return ixgbe_pci_sriov_enable(dev, num_vfs);
 }
 
+static int ixgbe_enable_vf_mc_promisc(struct ixgbe_adapter *adapter, u32 vf)
+{
+	struct ixgbe_hw *hw;
+	u32 vmolr;
+
+	hw = &adapter->hw;
+	vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
+
+	e_info(drv, "VF %u: enabling multicast promiscuous\n", vf);
+
+	vmolr |= IXGBE_VMOLR_MPE;
+
+	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
+
+	return 0;
+}
+
+static int ixgbe_disable_vf_mc_promisc(struct ixgbe_adapter *adapter, u32 vf)
+{
+	struct ixgbe_hw *hw;
+	u32 vmolr;
+
+	hw = &adapter->hw;
+	vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
+
+	e_info(drv, "VF %u: disabling multicast promiscuous\n", vf);
+
+	vmolr &= ~IXGBE_VMOLR_MPE;
+
+	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
+
+	return 0;
+}
+
 static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
 				   u32 *msgbuf, u32 vf)
 {
@@ -325,6 +362,12 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
 	u32 mta_reg;
 	u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
 
+	/* Disable multicast promiscuous first */
+	if (adapter->vfinfo[vf].mc_promisc) {
+		ixgbe_disable_vf_mc_promisc(adapter, vf);
+		adapter->vfinfo[vf].mc_promisc = false;
+	}
+
 	/* only so many hash values supported */
 	entries = min(entries, IXGBE_MAX_VF_MC_ENTRIES);
 
@@ -427,6 +470,7 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
 #endif /* CONFIG_FCOE */
 		switch (adapter->vfinfo[vf].vf_api) {
 		case ixgbe_mbox_api_11:
+		case ixgbe_mbox_api_12:
 			/*
 			 * Version 1.1 supports jumbo frames on VFs if PF has
 			 * jumbo frames enabled which means legacy VFs are
@@ -710,6 +754,12 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 		IXGBE_WRITE_REG(hw, IXGBE_PVFTDWBALn(q_per_pool, vf, i), 0);
 	}
 
+	/* Disable multicast promiscuous at reset */
+	if (adapter->vfinfo[vf].mc_promisc) {
+		ixgbe_disable_vf_mc_promisc(adapter, vf);
+		adapter->vfinfo[vf].mc_promisc = false;
+	}
+
 	/* reply to reset with ack and vf mac address */
 	msgbuf[0] = IXGBE_VF_RESET;
 	if (!is_zero_ether_addr(vf_mac)) {
@@ -894,6 +944,12 @@ static int ixgbe_negotiate_vf_api(struct ixgbe_adapter *adapter,
 	switch (api) {
 	case ixgbe_mbox_api_10:
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
+		e_info(drv, "VF %d requested api_version %s\n", vf,
+			(api == ixgbe_mbox_api_12) ? "ixgbe_mbox_api_12" :
+			(api == ixgbe_mbox_api_11) ? "ixgbe_mbox_api_11" :
+			(api == ixgbe_mbox_api_10) ? "ixgbe_mbox_api_10" :
+			"unknown");
 		adapter->vfinfo[vf].vf_api = api;
 		return 0;
 	default:
@@ -917,6 +973,7 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
 	switch (adapter->vfinfo[vf].vf_api) {
 	case ixgbe_mbox_api_20:
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		break;
 	default:
 		return -1;
@@ -944,6 +1001,31 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static int ixgbe_set_vf_mc_promisc(struct ixgbe_adapter *adapter,
+				   u32 *msgbuf, u32 vf)
+{
+	bool enable = !!msgbuf[1];	/* msgbuf contains the flag to enable */
+
+	switch (adapter->vfinfo[vf].vf_api) {
+	case ixgbe_mbox_api_12:
+		break;
+	default:
+		return -1;
+	}
+
+	/* nothing to do */
+	if (adapter->vfinfo[vf].mc_promisc == enable)
+		return 0;
+
+	adapter->vfinfo[vf].mc_promisc = enable;
+
+	if (enable)
+		return ixgbe_enable_vf_mc_promisc(adapter, vf);
+	else
+		return ixgbe_disable_vf_mc_promisc(adapter, vf);
+}
+
+
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -1000,6 +1082,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	case IXGBE_VF_GET_QUEUES:
 		retval = ixgbe_get_vf_queues(adapter, msgbuf, vf);
 		break;
+	case IXGBE_VF_SET_MC_PROMISC:
+		retval = ixgbe_set_vf_mc_promisc(adapter, msgbuf, vf);
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 62a0d8e..0403e1d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1880,7 +1880,8 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
 static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int api[] = { ixgbe_mbox_api_11,
+	int api[] = { ixgbe_mbox_api_12,
+		      ixgbe_mbox_api_11,
 		      ixgbe_mbox_api_10,
 		      ixgbe_mbox_api_unknown };
 	int err = 0, idx = 0;
@@ -1894,6 +1895,12 @@ static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
 		idx++;
 	}
 
+	dev_info(&adapter->pdev->dev, "mbox api_version = %s\n",
+		(hw->api_version == ixgbe_mbox_api_12) ? "ixgbe_mbox_api_12" :
+		(hw->api_version == ixgbe_mbox_api_11) ? "ixgbe_mbox_api_11" :
+		(hw->api_version == ixgbe_mbox_api_10) ? "ixgbe_mbox_api_10" :
+		"unknown");
+
 	spin_unlock_bh(&adapter->mbx_lock);
 }
 
@@ -2072,6 +2079,9 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 
 	netif_carrier_off(netdev);
 
+	/* drop multicast promiscuous mode flag */
+	adapter->hw.mac.mc_promisc = false;
+
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbevf_reset(adapter);
 
@@ -3525,6 +3535,7 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 
 	switch (adapter->hw.api_version) {
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
 		break;
 	default:
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 0bc3005..62ef0d8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -86,6 +86,7 @@ enum ixgbe_pfvf_api_rev {
 	ixgbe_mbox_api_10,	/* API version 1.0, linux/freebsd VF driver */
 	ixgbe_mbox_api_20,	/* API version 2.0, solaris Phase1 VF driver */
 	ixgbe_mbox_api_11,	/* API version 1.1, linux/freebsd VF driver */
+	ixgbe_mbox_api_12,	/* API version 1.2, linux/freebsd VF driver */
 	/* This value should always be last */
 	ixgbe_mbox_api_unknown,	/* indicates that API version is not known */
 };
@@ -104,6 +105,9 @@ enum ixgbe_pfvf_api_rev {
 /* mailbox API, version 1.1 VF requests */
 #define IXGBE_VF_GET_QUEUE	0x09 /* get queue configuration */
 
+/* mailbox API, version 1.2 VF requests */
+#define IXGBE_VF_SET_MC_PROMISC	0x0a /* VF requests PF to set MC promiscuous */
+
 /* GET_QUEUES return data indices within the mailbox */
 #define IXGBE_VF_TX_QUEUES	1	/* number of Tx queues supported */
 #define IXGBE_VF_RX_QUEUES	2	/* number of Rx queues supported */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index cdb53be..dfc87b0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -120,6 +120,9 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 	memcpy(hw->mac.perm_addr, addr, ETH_ALEN);
 	hw->mac.mc_filter_type = msgbuf[IXGBE_VF_MC_TYPE_WORD];
 
+	/* after reset, MC promiscuous mode is disabled */
+	hw->mac.mc_promisc = false;
+
 	return 0;
 }
 
@@ -327,8 +330,29 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 	 */
 
 	cnt = netdev_mc_count(netdev);
-	if (cnt > 30)
+	if (cnt > 30) {
+		/*
+		 * If the API has the capability to handle MC promiscuous
+		 * mode, turn it on.
+		 */
+		if (hw->api_version == ixgbe_mbox_api_12) {
+			if (!hw->mac.mc_promisc) {
+				struct ixgbevf_adapter *adapter = hw->back;
+
+				dev_info(&adapter->pdev->dev, "Request MC PROMISC\n");
+
+				/* enabling multicast promiscuous */
+				msgbuf[0] = IXGBE_VF_SET_MC_PROMISC;
+				msgbuf[1] = 1;
+				ixgbevf_write_msg_read_ack(hw, msgbuf, 2);
+
+				hw->mac.mc_promisc = true;
+			}
+
+			return 0;
+		}
 		cnt = 30;
+	}
 	msgbuf[0] = IXGBE_VF_SET_MULTICAST;
 	msgbuf[0] |= cnt << IXGBE_VT_MSGINFO_SHIFT;
 
@@ -344,6 +368,8 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 
 	ixgbevf_write_msg_read_ack(hw, msgbuf, IXGBE_VFMAILBOX_SIZE);
 
+	hw->mac.mc_promisc = false;
+
 	return 0;
 }
 
@@ -545,6 +571,7 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	/* do nothing if API doesn't support ixgbevf_get_queues */
 	switch (hw->api_version) {
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		break;
 	default:
 		return 0;
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 5b17242..97790db 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -87,6 +87,7 @@ struct ixgbe_mac_info {
 	enum ixgbe_mac_type type;
 
 	s32  mc_filter_type;
+	bool mc_promisc;
 
 	bool get_link_status;
 	u32  max_tx_queues;
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
