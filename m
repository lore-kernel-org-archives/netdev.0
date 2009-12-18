From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH v2 08/12] ixgbe: Add SR-IOV register,
	structure and bit defines
Date: Fri, 18 Dec 2009 14:53:07 -0800
Message-ID: <20091218225307.10698.82409.stgit@localhost.localdomain>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:40308
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933222AbZLRWxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 17:53:24 -0500
In-Reply-To: <20091218225043.10698.58897.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

This patch adds register definitions, bit definitions and structures used by
the driver to support SR-IOV features of the 82599 controller.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |   31 ++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/ixgbe/ixgbe_type.h |   53 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 8da8eb5..ed73585 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -98,6 +98,23 @@
 
 #define IXGBE_MAX_RSC_INT_RATE          162760
 
+#define IXGBE_MAX_VF_MC_ENTRIES         30
+#define IXGBE_MAX_VF_FUNCTIONS          64
+#define IXGBE_MAX_VFTA_ENTRIES          128
+#define MAX_EMULATION_MAC_ADDRS         16
+#define VMDQ_P(p)   ((p) + adapter->num_vfs)
+
+struct vf_data_storage {
+	unsigned char vf_mac_addresses[ETH_ALEN];
+	u16 vf_mc_hashes[IXGBE_MAX_VF_MC_ENTRIES];
+	u16 num_vf_mc_hashes;
+	u16 default_vf_vlan_id;
+	u16 vlans_enabled;
+	unsigned char em_mac_addresses[MAX_EMULATION_MAC_ADDRS * ETH_ALEN];
+	bool clear_to_send;
+	int rar;
+};
+
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
@@ -171,7 +188,7 @@ struct ixgbe_ring {
 enum ixgbe_ring_f_enum {
 	RING_F_NONE = 0,
 	RING_F_DCB,
-	RING_F_VMDQ,
+	RING_F_VMDQ,  /* SR-IOV uses the same ring feature */
 	RING_F_RSS,
 	RING_F_FDIR,
 #ifdef IXGBE_FCOE
@@ -183,7 +200,7 @@ enum ixgbe_ring_f_enum {
 
 #define IXGBE_MAX_DCB_INDICES   8
 #define IXGBE_MAX_RSS_INDICES  16
-#define IXGBE_MAX_VMDQ_INDICES 16
+#define IXGBE_MAX_VMDQ_INDICES 64
 #define IXGBE_MAX_FDIR_INDICES 64
 #ifdef IXGBE_FCOE
 #define IXGBE_MAX_FCOE_INDICES  8
@@ -288,6 +305,8 @@ struct ixgbe_adapter {
 	/* RX */
 	struct ixgbe_ring *rx_ring ____cacheline_aligned_in_smp; /* One per active queue */
 	int num_rx_queues;
+	int num_rx_pools;		/* == num_rx_queues in 82598 */
+	int num_rx_queues_per_pool;	/* 1 if 82598, can be many if 82599 */
 	u64 hw_csum_rx_error;
 	u64 hw_rx_no_dma_resources;
 	u64 non_eop_descs;
@@ -330,6 +349,8 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 27)
 #define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 28)
 #define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 29)
+#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 30)
+#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 31)
 
 	u32 flags2;
 #define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1)
@@ -379,6 +400,11 @@ struct ixgbe_adapter {
 	u64 rsc_total_flush;
 	u32 wol;
 	u16 eeprom_version;
+
+	/* SR-IOV */
+	DECLARE_BITMAP(active_vfs, IXGBE_MAX_VF_FUNCTIONS);
+	unsigned int num_vfs;
+	struct vf_data_storage *vfinfo;
 };
 
 enum ixbge_state_t {
@@ -440,6 +466,7 @@ extern s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input,
                                          u16 flex_byte);
 extern s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input,
                                       u8 l4type);
+extern void ixgbe_set_rx_mode(struct net_device *netdev);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index bd64387..22152c6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2409,7 +2409,7 @@ static u8 *ixgbe_addr_list_itr(struct ixgbe_hw *hw, u8 **mc_addr_ptr, u32 *vmdq)
  * responsible for configuring the hardware for proper unicast, multicast and
  * promiscuous mode.
  **/
-static void ixgbe_set_rx_mode(struct net_device *netdev)
+void ixgbe_set_rx_mode(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 84650c6..ec8ad18 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -277,6 +277,7 @@
 #define IXGBE_DTXCTL    0x07E00
 
 #define IXGBE_DMATXCTL  0x04A80
+#define IXGBE_PFDTXGSWC     0x08220
 #define IXGBE_DTXMXSZRQ     0x08100
 #define IXGBE_DTXTCPFLGL    0x04A88
 #define IXGBE_DTXTCPFLGH    0x04A8C
@@ -287,6 +288,8 @@
 #define IXGBE_DMATXCTL_NS       0x2 /* No Snoop LSO hdr buffer */
 #define IXGBE_DMATXCTL_GDV      0x8 /* Global Double VLAN */
 #define IXGBE_DMATXCTL_VT_SHIFT 16  /* VLAN EtherType */
+
+#define IXGBE_PFDTXGSWC_VT_LBEN 0x1 /* Local L2 VT switch enable */
 #define IXGBE_DCA_TXCTRL(_i)    (0x07200 + ((_i) * 4)) /* 16 of these (0-15) */
 /* Tx DCA Control register : 128 of these (0-127) */
 #define IXGBE_DCA_TXCTRL_82599(_i)  (0x0600C + ((_i) * 0x40))
@@ -497,6 +500,7 @@
 /* DCB registers */
 #define IXGBE_RTRPCS      0x02430
 #define IXGBE_RTTDCS      0x04900
+#define IXGBE_RTTDCS_ARBDIS     0x00000040 /* DCB arbiter disable */
 #define IXGBE_RTTPCS      0x0CD00
 #define IXGBE_RTRUP2TC    0x03020
 #define IXGBE_RTTUP2TC    0x0C800
@@ -730,6 +734,13 @@
 #define IXGBE_GCR_CMPL_TMOUT_RESEND     0x00010000
 #define IXGBE_GCR_CAP_VER2              0x00040000
 
+#define IXGBE_GCR_EXT_MSIX_EN           0x80000000
+#define IXGBE_GCR_EXT_VT_MODE_16        0x00000001
+#define IXGBE_GCR_EXT_VT_MODE_32        0x00000002
+#define IXGBE_GCR_EXT_VT_MODE_64        0x00000003
+#define IXGBE_GCR_EXT_SRIOV             (IXGBE_GCR_EXT_MSIX_EN | \
+                                         IXGBE_GCR_EXT_VT_MODE_64)
+
 /* Time Sync Registers */
 #define IXGBE_TSYNCRXCTL 0x05188 /* Rx Time Sync Control register - RW */
 #define IXGBE_TSYNCTXCTL 0x08C00 /* Tx Time Sync Control register - RW */
@@ -1065,6 +1076,8 @@
 /* VFRE bitmask */
 #define IXGBE_VFRE_ENABLE_ALL   0xFFFFFFFF
 
+#define IXGBE_VF_INIT_TIMEOUT   200 /* Number of retries to clear RSTI */
+
 /* RDHMPN and TDHMPN bitmasks */
 #define IXGBE_RDHMPN_RDICADDR       0x007FF800
 #define IXGBE_RDHMPN_RDICRDREQ      0x00800000
@@ -1295,6 +1308,7 @@
 /* VLAN pool filtering masks */
 #define IXGBE_VLVF_VIEN         0x80000000  /* filter is valid */
 #define IXGBE_VLVF_ENTRIES      64
+#define IXGBE_VLVF_VLANID_MASK  0x00000FFF
 
 #define IXGBE_ETHERNET_IEEE_VLAN_TYPE 0x8100  /* 802.1q protocol */
 
@@ -1843,6 +1857,12 @@
 #define IXGBE_RX_DESC_SPECIAL_PRI_SHIFT  0x000D /* Priority in upper 3 of 16 */
 #define IXGBE_TX_DESC_SPECIAL_PRI_SHIFT  IXGBE_RX_DESC_SPECIAL_PRI_SHIFT
 
+/* SR-IOV specific macros */
+#define IXGBE_MBVFICR_INDEX(vf_number)   (vf_number >> 4)
+#define IXGBE_MBVFICR(_i)                (0x00710 + (_i * 4))
+#define IXGBE_VFLRE(_i)                  (((_i & 1) ? 0x001C0 : 0x00600))
+#define IXGBE_VFLREC(_i)                 (0x00700 + (_i * 4))
+
 /* Little Endian defines */
 #ifndef __le32
 #define __le32  u32
@@ -2463,6 +2483,37 @@ struct ixgbe_phy_info {
 	bool                            multispeed_fiber;
 };
 
+#include "ixgbe_mbx.h"
+
+struct ixgbe_mbx_operations {
+	s32 (*init_params)(struct ixgbe_hw *hw);
+	s32 (*read)(struct ixgbe_hw *, u32 *, u16,  u16);
+	s32 (*write)(struct ixgbe_hw *, u32 *, u16, u16);
+	s32 (*read_posted)(struct ixgbe_hw *, u32 *, u16,  u16);
+	s32 (*write_posted)(struct ixgbe_hw *, u32 *, u16, u16);
+	s32 (*check_for_msg)(struct ixgbe_hw *, u16);
+	s32 (*check_for_ack)(struct ixgbe_hw *, u16);
+	s32 (*check_for_rst)(struct ixgbe_hw *, u16);
+};
+
+struct ixgbe_mbx_stats {
+	u32 msgs_tx;
+	u32 msgs_rx;
+
+	u32 acks;
+	u32 reqs;
+	u32 rsts;
+};
+
+struct ixgbe_mbx_info {
+	struct ixgbe_mbx_operations ops;
+	struct ixgbe_mbx_stats stats;
+	u32 timeout;
+	u32 usec_delay;
+	u32 v2p_mailbox;
+	u16 size;
+};
+
 struct ixgbe_hw {
 	u8 __iomem			*hw_addr;
 	void				*back;
@@ -2472,6 +2523,7 @@ struct ixgbe_hw {
 	struct ixgbe_phy_info		phy;
 	struct ixgbe_eeprom_info	eeprom;
 	struct ixgbe_bus_info		bus;
+	struct ixgbe_mbx_info		mbx;
 	u16				device_id;
 	u16				vendor_id;
 	u16				subsystem_device_id;
@@ -2486,6 +2538,7 @@ struct ixgbe_info {
 	struct ixgbe_mac_operations	*mac_ops;
 	struct ixgbe_eeprom_operations	*eeprom_ops;
 	struct ixgbe_phy_operations	*phy_ops;
+	struct ixgbe_mbx_operations	*mbx_ops;
 };
 
 

