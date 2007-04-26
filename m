From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 04/12] r8169: merge with version 8.001.00 of Realtek's r8168 driver
Date: Thu, 26 Apr 2007 23:48:21 +0200
Message-ID: <20070426214821.GE7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58565 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755154AbXDZVv4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:51:56 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This one includes:

- more tweaks to rtl_hw_start_8168

- a work around for a Rx FiFO overflow issue on the 8168Bb
  - rtl8169_{intr_mask/napi_event} are replaced with per-device fields,
    namely tp->{intr/napi}_event
  - rtl_cfg_info is converted to C99 for readability but the values are
    not changed for the 8169/8110 and the 8101

Includes ChipCmd fix from Bernhard Walle <bwalle@suse.de> (2007/02/24).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |  119 ++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 89 insertions(+), 30 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 74973ef..241e204 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -205,16 +205,6 @@ static void rtl_hw_start_8169(struct net_device *);
 static void rtl_hw_start_8168(struct net_device *);
 static void rtl_hw_start_8101(struct net_device *);
 
-static const struct {
-	void (*hw_start)(struct net_device *);
-	unsigned int region;
-	unsigned int align;
-} rtl_cfg_info[] = {
-	[RTL_CFG_0] = { rtl_hw_start_8169, 1, NET_IP_ALIGN },
-	[RTL_CFG_1] = { rtl_hw_start_8168, 2, 8 },
-	[RTL_CFG_2] = { rtl_hw_start_8101, 2, 8 }
-};
-
 static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
@@ -354,10 +344,15 @@ enum RTL8169_register_content {
 	TBINwComplete	= 0x01000000,
 
 	/* CPlusCmd p.31 */
+	PktCntrDisable	= (1 << 7),	// 8168
 	RxVlan		= (1 << 6),
 	RxChkSum	= (1 << 5),
 	PCIDAC		= (1 << 4),
 	PCIMulRW	= (1 << 3),
+	INTT_0		= 0x0000,	// 8168
+	INTT_1		= 0x0001,	// 8168
+	INTT_2		= 0x0002,	// 8168
+	INTT_3		= 0x0003,	// 8168
 
 	/* rtl8169_PHYstatus */
 	TBI_Enable = 0x80,
@@ -457,6 +452,8 @@ struct rtl8169_private {
 	unsigned rx_buf_sz;
 	struct timer_list timer;
 	u16 cp_cmd;
+	u16 intr_event;
+	u16 napi_event;
 	u16 intr_mask;
 	int phy_auto_nego_reg;
 	int phy_1000_ctrl_reg;
@@ -505,10 +502,6 @@ static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
 
-static const u16 rtl8169_intr_mask =
-	SYSErr | LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
-static const u16 rtl8169_napi_event =
-	RxOK | RxOverflow | RxFIFOOver | TxOK | TxErr;
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
@@ -1176,6 +1169,13 @@ static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg, int bitnum
 
 static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *ioaddr)
 {
+	/*
+	 * The driver currently handles the 8168Bf and the 8168Be identically
+	 * but they can be identified more specifically through the test below
+	 * if needed:
+	 *
+	 * (RTL_R32(TxConfig) & 0x700000) == 0x500000 ? 8168Bf : 8168Be
+	 */
 	const struct {
 		u32 mask;
 		int mac_version;
@@ -1490,10 +1490,44 @@ static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+static const struct rtl_cfg_info {
+	void (*hw_start)(struct net_device *);
+	unsigned int region;
+	unsigned int align;
+	u16 intr_event;
+	u16 napi_event;
+} rtl_cfg_infos [] = {
+	[RTL_CFG_0] = {
+		.hw_start	= rtl_hw_start_8169,
+		.region		= 1,
+		.align		= NET_IP_ALIGN,
+		.intr_event	= SYSErr | LinkChg | RxOverflow |
+				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+	},
+	[RTL_CFG_1] = {
+		.hw_start	= rtl_hw_start_8168,
+		.region		= 2,
+		.align		= 8,
+		.intr_event	= SYSErr | LinkChg | RxOverflow |
+				  TxErr | TxOK | RxOK | RxErr,
+		.napi_event	= TxErr | TxOK | RxOK | RxOverflow
+	},
+	[RTL_CFG_2] = {
+		.hw_start	= rtl_hw_start_8101,
+		.region		= 2,
+		.align		= 8,
+		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
+				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+	}
+};
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	const unsigned int region = rtl_cfg_info[ent->driver_data].region;
+	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
+	const unsigned int region = cfg->region;
 	struct rtl8169_private *tp;
 	struct net_device *dev;
 	void __iomem *ioaddr;
@@ -1694,14 +1728,15 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->intr_mask = 0xffff;
 	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
-	tp->align = rtl_cfg_info[ent->driver_data].align;
+	tp->align = cfg->align;
+	tp->hw_start = cfg->hw_start;
+	tp->intr_event = cfg->intr_event;
+	tp->napi_event = cfg->napi_event;
 
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
 
-	tp->hw_start = rtl_cfg_info[ent->driver_data].hw_start;
-
 	spin_lock_init(&tp->lock);
 
 	rc = register_netdev(dev);
@@ -1977,7 +2012,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	RTL_W16(IntrMask, rtl8169_intr_mask);
+	RTL_W16(IntrMask, tp->intr_event);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 }
@@ -1986,6 +2021,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+	u8 ctl;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -1993,16 +2030,26 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_max_size(ioaddr);
 
-	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
+	rtl_set_rx_tx_config_registers(tp);
+
+	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	RTL_W16(IntrMitigate, 0x0000);
+	/* Tx performance tweak. */
+	pci_read_config_byte(pdev, 0x69, &ctl);
+	ctl = (ctl & ~0x70) | 0x50;
+	pci_write_config_byte(pdev, 0x69, ctl);
 
-	rtl_set_rx_tx_desc_registers(tp, ioaddr);
+	RTL_W16(IntrMitigate, 0x5151);
 
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-	rtl_set_rx_tx_config_registers(tp);
+	/* Work around for RxFIFO overflow. */
+	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
+		tp->intr_event |= RxFIFOOver | PCSTimeout;
+		tp->intr_event &= ~RxOverflow;
+	}
+
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
@@ -2012,9 +2059,11 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_mode(dev);
 
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 
-	RTL_W16(IntrMask, rtl8169_intr_mask);
+	RTL_W16(IntrMask, tp->intr_event);
 }
 
 static void rtl_hw_start_8101(struct net_device *dev)
@@ -2053,9 +2102,11 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	rtl_set_rx_mode(dev);
 
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 
-	RTL_W16(IntrMask, rtl8169_intr_mask);
+	RTL_W16(IntrMask, tp->intr_event);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
@@ -2770,8 +2821,16 @@ rtl8169_interrupt(int irq, void *dev_instance)
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 
-		if (!(status & rtl8169_intr_mask))
+		if (!(status & tp->intr_event))
+			break;
+
+                /* Work around for rx fifo overflow */
+                if (unlikely(status & RxFIFOOver) &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+			netif_stop_queue(dev);
+			rtl8169_tx_timeout(dev);
 			break;
+		}
 
 		if (unlikely(status & SYSErr)) {
 			rtl8169_pcierr_interrupt(dev);
@@ -2782,8 +2841,8 @@ rtl8169_interrupt(int irq, void *dev_instance)
 			rtl8169_check_link_status(dev, tp, ioaddr);
 
 #ifdef CONFIG_R8169_NAPI
-		RTL_W16(IntrMask, rtl8169_intr_mask & ~rtl8169_napi_event);
-		tp->intr_mask = ~rtl8169_napi_event;
+		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+		tp->intr_mask = ~tp->napi_event;
 
 		if (likely(netif_rx_schedule_prep(dev)))
 			__netif_rx_schedule(dev);
@@ -2840,7 +2899,7 @@ static int rtl8169_poll(struct net_device *dev, int *budget)
 		 * write is safe - FR
 		 */
 		smp_wmb();
-		RTL_W16(IntrMask, rtl8169_intr_mask);
+		RTL_W16(IntrMask, tp->intr_event);
 	}
 
 	return (work_done >= work_to_do);
-- 
1.4.4.2
