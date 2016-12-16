From: henrik@austad.us
Subject: [TSN RFC v2 4/9] Adding TSN-driver to Intel I210 controller
Date: Fri, 16 Dec 2016 18:59:08 +0100
Message-ID: <1481911153-549-5-git-send-email-henrik@austad.us>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
Cc: Richard Cochran <richardcochran@gmail.com>, henrik@austad.us,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        intel-wired-lan@lists.osuosl.org,
        "David S. Miller" <davem@davemloft.net>,
        Henrik Austad <haustad@cisco.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481911153-549-1-git-send-email-henrik@austad.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Henrik Austad <henrik@austad.us>

This adds support for loading the igb.ko module with tsn
capabilities. This requires a 2-step approach. First enabling TSN in
.config, then load the module with use_tsn=1.

Once enabled and loaded, the controller will be placed in "Qav-mode"
which is when the credit-based shaper is available, 3 of the queues are
removed from regular traffic, max payload is set to 1522 octets (no
jumboframes allowed).

It dumps the registers of interest before and after, so this clutters
kern.log a bit if it is loaded with debug_tsn=1.

Regardless of number of online CPUs, it will enable *all* for Tx-queues as
2 is required for Qav traffic. This has not been tested extensively, so
there may be some instabilities in this.

Improved SR(A|B) accounting:
Use the idleslope-bins to keep track of how much time is reserved for
each class. This can then be used to strip the vlan-tag on the NIC when
the last stream goes (and also allow for reconfiguration of PCP when the
NIC is not sending TSN traffic).

Note: currently this driver is *not* stable, it is still a work in
progress, some points to keep tabs on:
- Set hicred to unlim (for testing this is ok and we avoid some nasty
  calculations)
- once we configure it for TSN, enable credit shaping, do not wait for
  first link to be configured (nobody else should use these queues after
  being configured).
- enable all Tx-/Rx-queues in TSN-mode regardless of num_online_cpus()
- Add 802.1Qav Prio-bit in adapter->flags
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: intel-wired-lan@lists.osuosl.org
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Henrik Austad <haustad@cisco.com>
---
 drivers/net/ethernet/intel/Kconfig        |  18 ++
 drivers/net/ethernet/intel/igb/Makefile   |   2 +-
 drivers/net/ethernet/intel/igb/igb.h      |  26 ++
 drivers/net/ethernet/intel/igb/igb_main.c |  39 ++-
 drivers/net/ethernet/intel/igb/igb_tsn.c  | 468 ++++++++++++++++++++++++++++++
 5 files changed, 550 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_tsn.c

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index c0e1743..d4382b4 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -99,6 +99,24 @@ config IGB
 	  To compile this driver as a module, choose M here. The module
 	  will be called igb.
 
+config IGB_TSN
+       tristate "TSN Support for Intel(R) 82575/82576 i210 Network Controller"
+       depends on IGB && TSN
+	---help---
+	  This driver supports TSN (AVB) on Intel I210 network controllers.
+
+	  When enabled, it will allow the module to be loaded with
+	  "use_tsn" which will initialize the controller to A/V-mode
+	  instead of legacy-mode. This will take 3 of the tx-queues and
+	  place them in 802.1Q QoS mode and enable the credit-based
+	  shaper for 2 of the queues.
+
+	  If built with this option, but not loaded with use_tsn, the
+	  only difference is a slightly larger module, no extra
+	  code paths are called.
+
+	  If unsure, say No
+
 config IGB_HWMON
 	bool "Intel(R) PCI-Express Gigabit adapters HWMON support"
 	default y
diff --git a/drivers/net/ethernet/intel/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
index 5bcb2de..1a9b776 100644
--- a/drivers/net/ethernet/intel/igb/Makefile
+++ b/drivers/net/ethernet/intel/igb/Makefile
@@ -33,4 +33,4 @@ obj-$(CONFIG_IGB) += igb.o
 
 igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
 	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o \
-	    e1000_i210.o igb_ptp.o igb_hwmon.o
+	    e1000_i210.o igb_ptp.o igb_hwmon.o igb_tsn.o
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index d11093d..474a5b4 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -394,6 +394,7 @@ struct igb_nfc_filter {
 };
 
 /* board specific private data structure */
+
 struct igb_adapter {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 
@@ -519,6 +520,17 @@ struct igb_adapter {
 	/* lock for RX network flow classification filter */
 	spinlock_t nfc_lock;
 	bool etype_bitmap[MAX_ETYPE_FILTER];
+
+#if IS_ENABLED(CONFIG_IGB_TSN)
+	/* Reserved BW for class A and B */
+	s32 sra_idleslope_res;
+	s32 srb_idleslope_res;
+	u8 pcp_hi;
+	u8 pcp_lo;
+	u8 tsn_ready:1;
+	u8 tsn_vlan_added:1;
+	u8 res:6;
+#endif	/* IGB_TSN */
 };
 
 /* flags controlling PTP/1588 function */
@@ -540,6 +552,7 @@ struct igb_adapter {
 #define IGB_FLAG_HAS_MSIX		BIT(13)
 #define IGB_FLAG_EEE			BIT(14)
 #define IGB_FLAG_VLAN_PROMISC		BIT(15)
+#define IGB_FLAG_QAV_PRIO		BIT(16)
 
 /* Media Auto Sense */
 #define IGB_MAS_ENABLE_0		0X0001
@@ -603,6 +616,19 @@ void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, unsigned char *va,
 			 struct sk_buff *skb);
 int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
 int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
+/* This should be the only place where we add ifdeffery
+ * to include tsn-stuff or not. Everything else is located in igb_tsn.c
+ */
+#if IS_ENABLED(CONFIG_IGB_TSN)
+void igb_tsn_init(struct igb_adapter *adapter);
+int igb_tsn_capable(struct net_device *netdev);
+int igb_tsn_link_configure(struct net_device *netdev, enum sr_class sr_class,
+			u16 framesize, u16 vid, u8 add_link, u8 pcp_hi, u8 pcp_lo);
+u16 igb_tsn_select_queue(struct net_device *netdev, struct sk_buff *skb,
+			void *accel_priv, select_queue_fallback_t fallback);
+#else
+static inline void igb_tsn_init(struct igb_adapter *adapter) { }
+#endif	/* CONFIG_IGB_TSN */
 void igb_set_flag_queue_pairs(struct igb_adapter *, const u32);
 #ifdef CONFIG_IGB_HWMON
 void igb_sysfs_exit(struct igb_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 9affd7c..0283864 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -256,6 +256,12 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
+static int use_tsn = 0;
+#if IS_ENABLED(CONFIG_IGB_TSN)
+MODULE_PARM_DESC(use_tsn, "use_tsn (0=off, 1=enabled)");
+module_param(use_tsn, int, 0);
+#endif
+
 struct igb_reg_info {
 	u32 ofs;
 	char *name;
@@ -675,6 +681,9 @@ static int __init igb_init_module(void)
 {
 	int ret;
 
+	if (use_tsn != 1)
+		use_tsn = 0;
+
 	pr_info("%s - version %s\n",
 	       igb_driver_string, igb_driver_version);
 	pr_info("%s\n", igb_copyright);
@@ -2161,6 +2170,11 @@ static const struct net_device_ops igb_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= igb_netpoll,
 #endif
+#if IS_ENABLED(CONFIG_IGB_TSN)
+	.ndo_tsn_capable	= igb_tsn_capable,
+	.ndo_tsn_link_configure = igb_tsn_link_configure,
+	.ndo_select_queue	= igb_tsn_select_queue,
+#endif	/* CONFIG_IGB_TSN */
 	.ndo_fix_features	= igb_fix_features,
 	.ndo_set_features	= igb_set_features,
 	.ndo_fdb_add		= igb_ndo_fdb_add,
@@ -2682,6 +2696,9 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* do hw tstamp init after resetting */
 	igb_ptp_init(adapter);
 
+	if (use_tsn)
+		igb_tsn_init(adapter);
+
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info, not applicable to i354 */
 	if (hw->mac.type != e1000_i354) {
@@ -3009,6 +3026,21 @@ static void igb_init_queue_configuration(struct igb_adapter *adapter)
 
 	adapter->rss_queues = min_t(u32, max_rss_queues, num_online_cpus());
 
+#if IS_ENABLED(CONFIG_IGB_TSN)
+	/* For I210: If we are using TSN, we don't want to use num_online_cpus(),
+	 * as we need 4 Tx-queues.
+	 *
+	 * Rx is another matter, but in time we probably want to assign
+	 * Rx-0 to class A, Rx-1 to B, -2 to PTP/MSRP control etc and -3
+	 * to all other traffic.
+	 */
+	if (use_tsn && hw->mac.type == e1000_i210) {
+		adapter->rss_queues = max_rss_queues;
+		pr_info("igb_init_queue_configuration: rss_queues=%u\n",
+			adapter->rss_queues);
+	}
+#endif	/* IGB_TSN */
+
 	igb_set_flag_queue_pairs(adapter, max_rss_queues);
 }
 
@@ -3397,7 +3429,8 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	txdctl |= IGB_TX_PTHRESH;
 	txdctl |= IGB_TX_HTHRESH << 8;
 	txdctl |= IGB_TX_WTHRESH << 16;
-
+	if (ring->flags & IGB_FLAG_QAV_PRIO)
+		txdctl |= E1000_TXDCTL_PRIORITY;
 	txdctl |= E1000_TXDCTL_QUEUE_ENABLE;
 	wr32(E1000_TXDCTL(reg_idx), txdctl);
 }
@@ -5345,8 +5378,10 @@ static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
 	/* The minimum packet size with TCTL.PSP set is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
 	 */
-	if (skb_put_padto(skb, 17))
+	if (skb_put_padto(skb, 17)) {
+		pr_err("%s: skb_put_padto FAILED. skb->len < 17\n", __func__);
 		return NETDEV_TX_OK;
+	}
 
 	return igb_xmit_frame_ring(skb, igb_tx_queue_mapping(adapter, skb));
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_tsn.c b/drivers/net/ethernet/intel/igb/igb_tsn.c
new file mode 100644
index 0000000..dd5d9ed
--- /dev/null
+++ b/drivers/net/ethernet/intel/igb/igb_tsn.c
@@ -0,0 +1,468 @@
+/*
+ * Copyright(c) 2015-2016 Henrik Austad <haustad@cisco.com>
+ *                        Cisco Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+/* FIXME: This should probably be handled by some Makefile-magic */
+
+#if IS_ENABLED(CONFIG_IGB_TSN)
+#include "igb.h"
+#include <linux/module.h>
+
+/* NOTE: keep the defines not present in e1000_regs.h to avoid
+ * cluttering too many files. Once we are pretty stable, these will move
+ * into it's proper home. Until then, make merge a bit easier by
+ * avoiding it
+ */
+
+/* Qav regs */
+#define E1000_IRPBS	 0x02404 /* Rx Packet Buffer Size - RW */
+#define E1000_ITPBS	 0x03404 /* Tx buffer size assignment */
+#define E1000_TQAVCTRL   0x03570 /* Tx Qav Control */
+#define E1000_DTXMXPKTSZ 0x0355C /* DMA TX Maximum Packet Size */
+
+/* Qav defines. */
+#define E1000_TQAVCH_UNLIM_CREDIT      0xFFFFFFFF
+#define E1000_TQAVCH_ZERO_CREDIT       0x80000000
+#define E1000_LINK_RATE		       0x7735
+
+/* 0:15  idleSlope
+ * 16:29 reserved
+ * 30    reserved
+ * 31    queue mode, 0=strict, 1=SR mode
+ */
+#define E1000_TQAVCC_QUEUEMODE         0x80000000
+#define E1000_TQAVCC_IDLE_SLOPE_MASK   0x0000ffff
+
+/* Transmit mode, 0=legacy, 1=QAV */
+#define E1000_TQAVCTRL_TXMODE          0x00000001
+/* report DMA time of tx packets */
+#define E1000_TQAVCTRL_1588_STAT_EN    0x00000004
+/* data fetch arbitration */
+#define E1000_TQAVCTRL_DATA_FETCH_ARB  0x00000010
+/* data tx arbitration */
+#define E1000_TQAVCTRL_DATA_TRAN_ARB   0x00000100
+/* data launch time valid */
+#define E1000_TQAVCTRL_DATA_TRAN_TIM   0x00000200
+/* stall SP to guarantee SR */
+#define E1000_TQAVCTRL_SP_WAIT_SR      0x00000400
+
+/* ... and associated shift value */
+#define E1000_TQAVCTRL_FETCH_TM_SHIFT  (16)
+
+/* QAV Tx mode control registers where _n can be 0 or 1. */
+#define E1000_TQAVCC(_idx)			(0x03004 + 0x40 * (_idx))
+
+/* Tx Qav High Credit - See 7.2.7.6 for calculations
+ * intel 8.12.18
+ */
+#define E1000_TQAVHC(_idx)			(0x0300C + 0x40 * (_idx))
+
+/* Queues priority masks where _n and _p can be 0-3. */
+
+#define MAX_FRAME_SIZE 1522
+#define MIN_FRAME_SIZE   64
+
+static int debug_tsn = -1;
+module_param(debug_tsn, int, 0);
+MODULE_PARM_DESC(debug_tsn, "debug_tsn (0=off, 1=enabled)");
+
+/* For a full list of the registers dumped here, see sec 8.1.3 in the
+ * i210 controller datasheet.
+ */
+static inline void _tsn_dump_regs(struct igb_adapter *adapter)
+{
+	u32 val = 0;
+	struct device *dev;
+	struct e1000_hw *hw = &adapter->hw;
+
+	/* do not dump regs if we're not debugging driver */
+	if (debug_tsn != 1)
+		return;
+
+	dev = &adapter->pdev->dev;
+	dev_info(dev, "num_tx_queues=%d (netdev=%d, real=%d), num_rx_queues=%d (netdev=%d, real=%d)\n",
+		adapter->num_tx_queues, adapter->netdev->num_tx_queues, adapter->netdev->real_num_tx_queues,
+		adapter->num_rx_queues, adapter->netdev->num_rx_queues, adapter->netdev->real_num_rx_queues);
+
+	/* 0x0008 - E1000_STATUS Device status register */
+	val = rd32(E1000_STATUS);
+	dev_info(&adapter->pdev->dev, "\n");
+	dev_info(dev, "Status: FullDuplex=%s, LinkUp=%s, speed=0x%x\n",
+		 val & 0x1 ? "FD" : "HD",
+		 val & 0x2 ? "LU" : "LD",
+		 val & 0xc0 >> 6);
+
+	/* E1000_VET vlan ether type */
+	val = rd32(E1000_VET);
+	dev_info(dev, "VLAN ether type: VET.VET=0x%04x, VET.VET_EXT=0x%04x\n",
+		 val & 0xffff, (val >> 16) & 0xffff);
+
+	/* E1000_RXPBS (RXPBSIZE) Rx Packet Buffer Size */
+	val = rd32(E1000_RXPBS);
+	dev_info(dev, "Rx Packet buffer: RXPBSIZE=%dkB, Bmc2ospbsize=%dkB, cfg_ts_en=%s\n",
+		 val & 0x1f,
+		 (val >> 6) & 0x1f,
+		 (val & (1 << 31)) ? "cfg_ts_en" : "cfg_ts_dis");
+
+	/* Transmit stuff */
+	/* E1000_TXPBS (TXPBSIZE) Tx Packet Buffer Size - RW */
+	val = rd32(E1000_TXPBS);
+	dev_info(dev, "Tx Packet buffer: Txpb0size=%dkB, Txpb1size=%dkB, Txpb2size=%dkB, Txpb3size=%dkB, os2Bmcpbsize=%dkB\n",
+		 val & 0x3f, (val >> 6) & 0x3f, (val >> 12) & 0x3f,
+		 (val >> 18) & 0x3f, (val >> 24) & 0x3f);
+
+	/* E1000_TCTL (TCTL) Tx control - RW*/
+	val = rd32(E1000_TCTL);
+	dev_info(dev, "Tx control reg: TxEnable=%s, CT=0x%X\n",
+		 val & 2 ? "EN" : "DIS", (val >> 3) & 0x3F);
+
+	/* TQAVHC     : Transmit Qav High credits 0x300C + 0x40*n - RW */
+	val = rd32(E1000_TQAVHC(0));
+	dev_info(dev, "E1000_TQAVHC0: %0x08x\n", val);
+	val = rd32(E1000_TQAVHC(1));
+	dev_info(dev, "E1000_TQAVHC1: %0x08x\n", val);
+
+	/* TQAVCC[0-1]: Transmit Qav 0x3004 + 0x40*n  - RW */
+	val = rd32(E1000_TQAVCC(0));
+	dev_info(dev, "E1000_TQAVCC0: idleSlope=0x%02x, QueueMode=%s\n",
+		 val % 0xff,
+		 val > 31 ? "Stream reservation" : "Strict priority");
+	val = rd32(E1000_TQAVCC(1));
+	dev_info(dev, "E1000_TQAVCC1: idleSlope=0x%02x, QueueMode=%s\n",
+		 val % 0xff,
+		 val > 31 ? "Stream reservation" : "Strict priority");
+
+	/* TQAVCTRL   : Transmit Qav control - RW */
+	val = rd32(E1000_TQAVCTRL);
+	dev_info(dev, "E1000_TQAVCTRL: TransmitMode=%s,1588_STAT_EN=%s,DataFetchARB=%s,DataTranARB=%s,DataTranTIM=%s,SP_WAIT_SR=%s,FetchTimDelta=%dns (0x%04x)\n",
+		 (val & 0x0001) ? "Qav" : "Legacy",
+		 (val & 0x0004) ? "En" : "Dis",
+		 (val & 0x0010) ? "Most Empty" : "Round Robin",
+		 (val & 0x0100) ? "Credit Shaper" : "Strict priority",
+		 (val & 0x0200) ? "Valid" : "N/A",
+		 (val & 0x0400) ? "Wait" : "nowait",
+		 (val >> 16) * 32, (val >> 16));
+}
+
+/* Place the NIC in Qav-mode.
+ *
+ * This will result in a _single_ queue for normal BE traffic, the rest
+ * will be grabbed by the Qav-machinery and kept for strict priority
+ * transmission.
+ *
+ * I210 Datasheet Sec 7.2.7.7 gives a lot of information.
+ */
+void igb_tsn_init(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 txpbsize;
+	u32 tqavctrl;
+
+	if (debug_tsn < 0 || debug_tsn > 1)
+		debug_tsn = 0;
+
+	if (!adapter->pdev) {
+		adapter->tsn_ready = 0;
+		return;
+	}
+
+	switch (adapter->pdev->device) {
+	case 0x1533:   /* E1000_DEV_ID_I210_COPPER */
+	case 0x1536:   /* E1000_DEV_ID_I210_FIBER */
+	case 0x1537:   /* E1000_DEV_ID_I210_SERDES: */
+	case 0x1538:   /* E1000_DEV_ID_I210_SGMII: */
+	case 0x157b:   /* E1000_DEV_ID_I210_COPPER_FLASHLESS: */
+	case 0x157c:   /* E1000_DEV_ID_I210_SERDES_FLASHLESS: */
+		break;
+	default:
+		/* not a known IGB-TSN capable device */
+		adapter->tsn_ready = 0;
+		return;
+	}
+	_tsn_dump_regs(adapter);
+
+	if (adapter->num_tx_queues != 4) {
+		pr_err("IGB_TSN: ERROR, not enough TX-queues available, need 4, got %d\n",
+			adapter->num_tx_queues);
+		return;
+	}
+
+	/* setup the Transmit Descriptor Control (see 8.12.15)
+	 *
+	 * Set a flag for priority-queue and call igb_configure_tx_ring() in igb_main.c
+	 */
+	adapter->tx_ring[0]->flags |= IGB_FLAG_QAV_PRIO;
+	adapter->tx_ring[1]->flags |= IGB_FLAG_QAV_PRIO;
+	igb_configure_tx_ring(adapter, adapter->tx_ring[0]);
+	igb_configure_tx_ring(adapter, adapter->tx_ring[1]);
+
+	/* Set Tx packet buffer size assignment, see 7.2.7.7 in i210
+	 * PB0: 8kB (default 20 kB)
+	 * PB1: 8kB (default  0 pkB)
+	 * PB2: 4kB (default  0 kB)
+	 * PB3: 4kB (default  0 kB)
+	 *
+	 * os2bmcsize: 2kB (default 4 kB)
+
+	 * UPDATE: set os2bmcpbsize to 0, then we can drop setting RX
+	 * packet buffer
+	 *
+	 * sumTx: 24kB (26kB)
+	 *
+	 * Rxpbsize: 0x20 (32kB default 34kB
+	 * bmc2ossize: 0x02 (default 0x02)
+	 * sumRx: 34kB
+	 *
+	 * Total 60kB (see 4.5.9)
+	 *
+	 * See 8.3.1 && 8.3.2 for fields
+	 */
+	txpbsize = (0 << 30 | 0x00 << 24 | 0x04 << 18 | 0x04 << 12 | 0x08 << 6 | 0x08);
+	wr32(E1000_ITPBS, txpbsize);
+
+	/* Since we dropped os2bmcsize, we do not have to change the
+	 * default here after all */
+	/* wr32(E1000_IRPBS, 0x02 << 6 | 0x20); */
+
+	/* DMA Tx maximum packet size, the largest frame DMA should transport
+	 * do not allow frames larger than 1522 + preample. Reg expects
+	 * size in 64B increments. 802.1BA 6.3
+	 * Round up to 1536 to handle 64B increments
+	 *
+	 * Initial value: 0x98 (152 => 9728 bytes)
+	 */
+	wr32(E1000_DTXMXPKTSZ, 1536 >> 6);
+
+	/* For now, only set CreditBased shaper for A and B, do not set
+	 * idleSlope as we have not yet gotten any streams. Set HiCredit
+	 * to be unlimitied (this violates the 75% 'default' boundary
+	 *
+	 * 8.12.19
+	 */
+	wr32(E1000_TQAVCC(0), E1000_TQAVCC_QUEUEMODE);
+	wr32(E1000_TQAVCC(1), E1000_TQAVCC_QUEUEMODE);
+	wr32(E1000_TQAVHC(0), E1000_TQAVCH_UNLIM_CREDIT);
+	wr32(E1000_TQAVHC(1), E1000_TQAVCH_UNLIM_CREDIT);
+
+	/* Place card in Qav-mode, use tx-queue 0,1 for Qav
+	 * (Credit-based shaper), 2,3 for standard priority (and
+	 * best-effort) traffic.
+	 *
+	 * i210 8.12.19 and 8.12.21
+	 *
+	 * - Fetch: most empty and time based (not round-robin)
+	 * - Transmit: Credit based shaper for SR queues
+	 * - Data launch time valid (in Qav mode) is off (we do not want
+	 *			     time-triggered launch)
+	 * - Wait for SR queues to ensure that launch time is always valid.
+	 * - Set ~10us wait-time-delta, 32ns granularity
+	 */
+	tqavctrl = E1000_TQAVCTRL_TXMODE      | \
+		E1000_TQAVCTRL_DATA_FETCH_ARB | \
+		E1000_TQAVCTRL_DATA_TRAN_ARB  | \
+		E1000_TQAVCTRL_SP_WAIT_SR     | \
+		320 << E1000_TQAVCTRL_FETCH_TM_SHIFT;
+	wr32(E1000_TQAVCTRL, tqavctrl);
+
+	/* reset Tx Descriptor tail and head for the queues */
+	wr32(E1000_TDT(0), 0);
+	wr32(E1000_TDT(1), 0);
+	wr32(E1000_TDH(0), 0);
+	wr32(E1000_TDH(1), 0);
+
+	_tsn_dump_regs(adapter);
+	dev_info(&adapter->pdev->dev, "\n");
+
+	adapter->sra_idleslope_res = 0;
+	adapter->srb_idleslope_res = 0;
+	adapter->tsn_ready = 1;
+	adapter->tsn_vlan_added = 0;
+
+	dev_info(&adapter->pdev->dev, "%s: setup done\n", __func__);
+}
+
+int igb_tsn_capable(struct net_device *netdev)
+{
+	struct igb_adapter *adapter;
+
+	if (!netdev)
+		return -EINVAL;
+	adapter = netdev_priv(netdev);
+	return adapter->tsn_ready == 1;
+}
+
+/* igb_tsn_link_configure - configure NIC to handle a new stream
+ *
+ * @netdev: pointer to NIC device
+ * @class: the class for the stream used to find the correct queue.
+ * @framesize: size of each frame, *including* headers (not preamble)
+ * @vid: VLAN ID
+ *
+ * NOTE: the sr_class only instructs the driver which queue to use, not
+ * what priority the network expects for a given class. This is
+ * something userspace must find out and then let the tsn-driver set in
+ * the frame before xmit.
+ *
+ * FIXME: remove bw-req from a stream that goes away.
+ */
+int igb_tsn_link_configure(struct net_device *netdev, enum sr_class class,
+			   u16 framesize, u16 vid, u8 add_link, u8 pcp_hi, u8 pcp_lo)
+{
+	s32 idle_slope = 0;
+	s32 frames_pr_ms;
+	s32 new_is = 0;
+	u32 tqavcc;
+	int err;
+
+	struct igb_adapter *adapter;
+	struct e1000_hw *hw;
+
+	if (!netdev)
+		return -EINVAL;
+	adapter  = netdev_priv(netdev);
+	hw = &adapter->hw;
+
+	if (!igb_tsn_capable(netdev)) {
+		pr_err("%s:  NIC not capable\n", __func__);
+		return -EINVAL;
+	}
+
+	if (framesize > MAX_FRAME_SIZE || framesize < MIN_FRAME_SIZE) {
+		pr_err("%s: framesize (%u) must be [%d,%d]\n", __func__,
+		       framesize, MIN_FRAME_SIZE, MAX_FRAME_SIZE);
+		return -EINVAL;
+	}
+
+	/*
+	 * FIXME: This should disable EEE and (possibly) enable it when
+	 * removing the last link.
+	 *
+	 * FIXME: This is only done the first time and have the
+	 * potentional of never being reset as we do not count the
+	 * number of configured links.
+	 *
+	 * This means that if all links goes away and the network
+	 * reconfigures the domain to use different PCPs, we will drop
+	 * that.
+	 *
+	 * FIXME: this update is racy
+	 */
+	if (add_link && !adapter->tsn_vlan_added) {
+		rtnl_lock();
+		pr_info("%s: adding VLAN %u to HW filter on device %s\n",
+			__func__, vid, netdev->name);
+		err = vlan_vid_add(netdev, htons(ETH_P_8021Q), vid);
+		if (err != 0)
+			pr_err("%s: error adding vlan %u, res=%d\n",
+				__func__, vid, err);
+		rtnl_unlock();
+		adapter->pcp_hi = pcp_hi & 0x7;
+		adapter->pcp_lo = pcp_lo & 0x7;
+		adapter->tsn_vlan_added = 1;
+	}
+
+	/* we currently drop hicred (we have set this to unlim to ease calculation) */
+	/* Grab current values of idle_slope
+	 */
+	switch(class) {
+	case SR_CLASS_A:
+		tqavcc = rd32(E1000_TQAVCC(0));
+		frames_pr_ms = 8;
+		break;
+	case SR_CLASS_B:
+		tqavcc = rd32(E1000_TQAVCC(1));
+		frames_pr_ms = 4;
+		break;
+	default:
+		pr_err("igb_tsn: unknown traffic-class, aborting configuration\n");
+		return -EINVAL;
+	}
+	idle_slope = tqavcc & E1000_TQAVCC_IDLE_SLOPE_MASK;
+
+	/* Calculate new idle slope and add to appropriate idle_slope
+	 * idle_slope = BW * linkrate * 2 (0r 0.2 for 100Mbit)
+	 * BW: % of total bandwidth
+	 *
+	 * E1000_LINK_RATE: 0x7735
+	 * LINE_SPEED: 1e9
+	 */
+	new_is = (s32)framesize * frames_pr_ms * E1000_LINK_RATE * 2 * 8;
+	if (new_is % 1000000)
+		new_is += 1000000;
+	new_is /= 1000000;
+
+	pr_info("Framesize=%u,E1000_LINK_RATE=%u,class=%s,new_is=%s%d,current_is=%u\n",
+		framesize,E1000_LINK_RATE,
+		(class == SR_CLASS_A ? "A" : "B"),
+		(add_link ? "+" : "-"),
+		new_is, idle_slope);
+	if (!add_link)
+		new_is *= -1;
+	idle_slope += new_is;
+
+	tqavcc &= ~E1000_TQAVCC_IDLE_SLOPE_MASK;
+	tqavcc |= idle_slope & E1000_TQAVCC_IDLE_SLOPE_MASK;
+	if (class == SR_CLASS_A) {
+		wr32(E1000_TQAVCC(0), tqavcc);
+		adapter->sra_idleslope_res += (s16)new_is;
+	} else {
+		wr32(E1000_TQAVCC(1), tqavcc);
+		adapter->srb_idleslope_res += (s16)new_is;
+	}
+
+	if (adapter->sra_idleslope_res == 0 && adapter->srb_idleslope_res == 0) {
+		/* removing last stream going through NIC, drop vlan and
+		 * make it possible to change PCP */
+		rtnl_lock();
+		vlan_vid_del(netdev, htons(ETH_P_8021Q), vid);
+		adapter->tsn_vlan_added = 0;
+		rtnl_unlock();
+	}
+	_tsn_dump_regs(netdev_priv(netdev));
+	pr_info("igb_tsn_link_configure: done setting up TSN, idle_slope: %u,for frame: %u\n",
+		idle_slope, new_is);
+
+	return 0;
+}
+
+u16 igb_tsn_select_queue(struct net_device *netdev, struct sk_buff *skb,
+			void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	if (!adapter)
+		return fallback(netdev, skb);
+
+	/* we only return the special queue(s) for tsn-traffic, and gPTP
+	 * otherwise we pick the last queue
+	 */
+	if (igb_tsn_capable(netdev)) {
+		switch (vlan_get_protocol(skb)) {
+		case htons(ETH_P_TSN):
+			if (skb->priority == adapter->pcp_hi)
+				return 0;
+			if (skb->priority == adapter->pcp_lo)
+				return 1;
+			pr_err("igb_tsn select queu: unknown PCP:%u, expected either hi=%u or lo=%u\n",
+				skb->priority, adapter->pcp_hi, adapter->pcp_lo);
+			break;
+		case htons(ETH_P_1588):
+			/* PTP should be sent via tx-queue 2 */
+			return 2;
+		default:
+			/* rest via 3 */
+			return  3;
+		}
+	}
+	return fallback(netdev, skb);
+}
+#endif	/* #if IS_ENABLED(CONFIG_IGB_TSN) */
-- 
2.7.4
