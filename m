From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH v4 1/3] ixgbe,
 ixgbevf: Add new mbox API to enable MC promiscuous mode
Date: Fri, 10 Apr 2015 01:04:04 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EBE2@BPXM14GP.gisp.nec.co.jp>
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
	Or Gerlitz <gerlitz.or@gmail.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
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
enable/disable multicast promiscuous mode in VF. If multicast
promiscuous mode is enabled the VF can receive all multicast packets.

With this patch, the ixgbevf driver automatically enable multicast
promiscuous mode when the number of multicast addresses is over than 30
if possible.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 76 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  2 +
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 27 +++++++-
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
 7 files changed, 111 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 636f9e3..08e65b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -146,6 +146,7 @@ struct vf_data_storage {
 	u16 vlans_enabled;
 	bool clear_to_send;
 	bool pf_set_mac;
+	bool mc_promisc;
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
 	u16 tx_rate;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index b1e4703..dd623ca 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -102,6 +102,8 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
 #define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS key */
 
+#define IXGBE_VF_SET_MC_PROMISC	0x0c	/* VF requests PF to set MC promiscuous */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 1d17b58..615f651 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -116,6 +116,9 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 			 * we want to disable the querying by default.
 			 */
 			adapter->vfinfo[i].rss_query_enabled = 0;
+
+			/* Turn multicast promiscuous mode off for all VFs */
+			adapter->vfinfo[i].mc_promisc = false;
 		}
 
 		return 0;
@@ -318,6 +321,40 @@ int ixgbe_pci_sriov_configure(struct pci_dev *dev, int num_vfs)
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
@@ -332,6 +369,12 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
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
 
@@ -718,6 +761,12 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
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
@@ -1001,6 +1050,30 @@ static int ixgbe_get_vf_rss_key(struct ixgbe_adapter *adapter,
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
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -1063,6 +1136,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	case IXGBE_VF_GET_RSS_KEY:
 		retval = ixgbe_get_vf_rss_key(adapter, msgbuf, vf);
 		break;
+	case IXGBE_VF_SET_MC_PROMISC:
+		retval = ixgbe_set_vf_mc_promisc(adapter, msgbuf, vf);
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a16d267..2b30da9 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2215,6 +2215,9 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 				IXGBE_TXDCTL_SWFLSH);
 	}
 
+	/* drop multicast promiscuous mode flag */
+	adapter->hw.mac.mc_promisc = false;
+
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbevf_reset(adapter);
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 82f44e0..53fba25 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -112,6 +112,8 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
 #define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS hash key */
 
+#define IXGBE_VF_SET_MC_PROMISC	0x0c	/* VF requests PF to set MC promiscuous */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN	4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index d1339b0..b5aac76 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -120,6 +120,9 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 	ether_addr_copy(hw->mac.perm_addr, addr);
 	hw->mac.mc_filter_type = msgbuf[IXGBE_VF_MC_TYPE_WORD];
 
+	/* after reset, MC promiscuous mode is disabled */
+	hw->mac.mc_promisc = false;
+
 	return 0;
 }
 
@@ -448,8 +451,28 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 	 */
 
 	cnt = netdev_mc_count(netdev);
-	if (cnt > 30)
+	if (cnt > 30) {
+		/* If the API has the capability to handle MC promiscuous
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
 
@@ -465,6 +488,8 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 
 	ixgbevf_write_msg_read_ack(hw, msgbuf, IXGBE_VFMAILBOX_SIZE);
 
+	hw->mac.mc_promisc = false;
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index d40f036..f910b78 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -86,6 +86,7 @@ struct ixgbe_mac_info {
 	enum ixgbe_mac_type type;
 
 	s32  mc_filter_type;
+	bool mc_promisc;
 
 	bool get_link_status;
 	u32  max_tx_queues;
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
