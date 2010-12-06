From: Roger Luethi <rl@hellgate.ch>
Subject: [PATCH v2] via-rhine: hardware VLAN support
Date: Mon, 6 Dec 2010 11:59:40 +0100
Message-ID: <20101206105940.GA17817@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail16.bluewin.ch ([195.186.19.63]:32541 "EHLO
	mail16.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab0LFLGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 06:06:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds VLAN hardware support for Rhine chips.

The driver uses up to 3 additional bytes of buffer space when extracting
802.1Q headers; PKT_BUF_SZ should still be sufficient.

The initial code was provided by David Lv. I reworked it to use standard
kernel facilities. Coding style clean up mostly follows via-velocity.

Adapted to new interface for VLAN acceleration (per request of Jesse Gross).

Signed-off-by: David Lv <DavidLv@viatech.com.cn>
Signed-off-by: Roger Luethi <rl@hellgate.ch>

 drivers/net/via-rhine.c |  326 +++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 312 insertions(+), 14 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 4930f9d..5e7f069 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -30,8 +30,8 @@
 */
 
 #define DRV_NAME	"via-rhine"
-#define DRV_VERSION	"1.4.3"
-#define DRV_RELDATE	"2007-03-06"
+#define DRV_VERSION	"1.5.0"
+#define DRV_RELDATE	"2010-10-09"
 
 
 /* A few user-configurable values.
@@ -100,6 +100,7 @@ static const int multicast_filter_limit = 32;
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/crc32.h>
+#include <linux/if_vlan.h>
 #include <linux/bitops.h>
 #include <linux/workqueue.h>
 #include <asm/processor.h>	/* Processor type for cache alignment. */
@@ -133,6 +134,9 @@ MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for broken BIOSes)");
 
+#define MCAM_SIZE	32
+#define VCAM_SIZE	32
+
 /*
 		Theory of Operation
 
@@ -279,15 +283,16 @@ MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
 /* Offsets to the device registers. */
 enum register_offsets {
 	StationAddr=0x00, RxConfig=0x06, TxConfig=0x07, ChipCmd=0x08,
-	ChipCmd1=0x09,
+	ChipCmd1=0x09, TQWake=0x0A,
 	IntrStatus=0x0C, IntrEnable=0x0E,
 	MulticastFilter0=0x10, MulticastFilter1=0x14,
 	RxRingPtr=0x18, TxRingPtr=0x1C, GFIFOTest=0x54,
-	MIIPhyAddr=0x6C, MIIStatus=0x6D, PCIBusConfig=0x6E,
+	MIIPhyAddr=0x6C, MIIStatus=0x6D, PCIBusConfig=0x6E, PCIBusConfig1=0x6F,
 	MIICmd=0x70, MIIRegAddr=0x71, MIIData=0x72, MACRegEEcsr=0x74,
 	ConfigA=0x78, ConfigB=0x79, ConfigC=0x7A, ConfigD=0x7B,
 	RxMissed=0x7C, RxCRCErrs=0x7E, MiscCmd=0x81,
 	StickyHW=0x83, IntrStatus2=0x84,
+	CamMask=0x88, CamCon=0x92, CamAddr=0x93,
 	WOLcrSet=0xA0, PwcfgSet=0xA1, WOLcgSet=0xA3, WOLcrClr=0xA4,
 	WOLcrClr1=0xA6, WOLcgClr=0xA7,
 	PwrcsrSet=0xA8, PwrcsrSet1=0xA9, PwrcsrClr=0xAC, PwrcsrClr1=0xAD,
@@ -299,6 +304,40 @@ enum backoff_bits {
 	BackCaptureEffect=0x04, BackRandom=0x08
 };
 
+/* Bits in the TxConfig (TCR) register */
+enum tcr_bits {
+	TCR_PQEN=0x01,
+	TCR_LB0=0x02,		/* loopback[0] */
+	TCR_LB1=0x04,		/* loopback[1] */
+	TCR_OFSET=0x08,
+	TCR_RTGOPT=0x10,
+	TCR_RTFT0=0x20,
+	TCR_RTFT1=0x40,
+	TCR_RTSF=0x80,
+};
+
+/* Bits in the CamCon (CAMC) register */
+enum camcon_bits {
+	CAMC_CAMEN=0x01,
+	CAMC_VCAMSL=0x02,
+	CAMC_CAMWR=0x04,
+	CAMC_CAMRD=0x08,
+};
+
+/* Bits in the PCIBusConfig1 (BCR1) register */
+enum bcr1_bits {
+	BCR1_POT0=0x01,
+	BCR1_POT1=0x02,
+	BCR1_POT2=0x04,
+	BCR1_CTFT0=0x08,
+	BCR1_CTFT1=0x10,
+	BCR1_CTSF=0x20,
+	BCR1_TXQNOBK=0x40,	/* for VT6105 */
+	BCR1_VIDFR=0x80,	/* for VT6105 */
+	BCR1_MED0=0x40,		/* for VT6102 */
+	BCR1_MED1=0x80,		/* for VT6102 */
+};
+
 #ifdef USE_MMIO
 /* Registers we check that mmio and reg are the same. */
 static const int mmio_verify_registers[] = {
@@ -356,6 +395,11 @@ enum desc_status_bits {
 	DescOwn=0x80000000
 };
 
+/* Bits in *_desc.*_length */
+enum desc_length_bits {
+	DescTag=0x00010000
+};
+
 /* Bits in ChipCmd. */
 enum chip_cmd_bits {
 	CmdInit=0x01, CmdStart=0x02, CmdStop=0x04, CmdRxOn=0x08,
@@ -365,6 +409,9 @@ enum chip_cmd_bits {
 };
 
 struct rhine_private {
+	/* Bit mask for configured VLAN ids */
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+
 	/* Descriptor rings */
 	struct rx_desc *rx_ring;
 	struct tx_desc *tx_ring;
@@ -405,6 +452,23 @@ struct rhine_private {
 	void __iomem *base;
 };
 
+#define BYTE_REG_BITS_ON(x, p)      do { iowrite8((ioread8((p))|(x)), (p)); } while (0)
+#define WORD_REG_BITS_ON(x, p)      do { iowrite16((ioread16((p))|(x)), (p)); } while (0)
+#define DWORD_REG_BITS_ON(x, p)     do { iowrite32((ioread32((p))|(x)), (p)); } while (0)
+
+#define BYTE_REG_BITS_IS_ON(x, p)   (ioread8((p)) & (x))
+#define WORD_REG_BITS_IS_ON(x, p)   (ioread16((p)) & (x))
+#define DWORD_REG_BITS_IS_ON(x, p)  (ioread32((p)) & (x))
+
+#define BYTE_REG_BITS_OFF(x, p)     do { iowrite8(ioread8((p)) & (~(x)), (p)); } while (0)
+#define WORD_REG_BITS_OFF(x, p)     do { iowrite16(ioread16((p)) & (~(x)), (p)); } while (0)
+#define DWORD_REG_BITS_OFF(x, p)    do { iowrite32(ioread32((p)) & (~(x)), (p)); } while (0)
+
+#define BYTE_REG_BITS_SET(x, m, p)   do { iowrite8((ioread8((p)) & (~(m)))|(x), (p)); } while (0)
+#define WORD_REG_BITS_SET(x, m, p)   do { iowrite16((ioread16((p)) & (~(m)))|(x), (p)); } while (0)
+#define DWORD_REG_BITS_SET(x, m, p)  do { iowrite32((ioread32((p)) & (~(m)))|(x), (p)); } while (0)
+
+
 static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int  rhine_open(struct net_device *dev);
@@ -422,6 +486,14 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
 static void rhine_shutdown (struct pci_dev *pdev);
+static void rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
+static void rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
+static void rhine_set_cam(void __iomem *ioaddr, int idx, u8 *addr);
+static void rhine_set_vlan_cam(void __iomem *ioaddr, int idx, u8 *addr);
+static void rhine_set_cam_mask(void __iomem *ioaddr, u32 mask);
+static void rhine_set_vlan_cam_mask(void __iomem *ioaddr, u32 mask);
+static void rhine_init_cam_filter(struct net_device *dev);
+static void rhine_update_vcam(struct net_device *dev);
 
 #define RHINE_WAIT_FOR(condition) do {					\
 	int i=1024;							\
@@ -629,6 +701,8 @@ static const struct net_device_ops rhine_netdev_ops = {
 	.ndo_set_mac_address 	 = eth_mac_addr,
 	.ndo_do_ioctl		 = netdev_ioctl,
 	.ndo_tx_timeout 	 = rhine_tx_timeout,
+	.ndo_vlan_rx_add_vid	 = rhine_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	 = rhine_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	 = rhine_poll,
 #endif
@@ -795,6 +869,10 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
+	if (pdev->revision >= VT6105M)
+		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
+		NETIF_F_HW_VLAN_FILTER;
+
 	/* dev->name not defined before register_netdev()! */
 	rc = register_netdev(dev);
 	if (rc)
@@ -1040,6 +1118,167 @@ static void rhine_set_carrier(struct mii_if_info *mii)
 		       netif_carrier_ok(mii->dev));
 }
 
+/**
+ * rhine_set_cam - set CAM multicast filters
+ * @ioaddr: register block of this Rhine
+ * @idx: multicast CAM index [0..MCAM_SIZE-1]
+ * @addr: multicast address (6 bytes)
+ *
+ * Load addresses into multicast filters.
+ */
+static void rhine_set_cam(void __iomem *ioaddr, int idx, u8 *addr)
+{
+	int i;
+
+	iowrite8(CAMC_CAMEN, ioaddr + CamCon);
+	wmb();
+
+	/* Paranoid -- idx out of range should never happen */
+	idx &= (MCAM_SIZE - 1);
+
+	iowrite8((u8) idx, ioaddr + CamAddr);
+
+	for (i = 0; i < 6; i++, addr++)
+		iowrite8(*addr, ioaddr + MulticastFilter0 + i);
+	udelay(10);
+	wmb();
+
+	iowrite8(CAMC_CAMWR | CAMC_CAMEN, ioaddr + CamCon);
+	udelay(10);
+
+	iowrite8(0, ioaddr + CamCon);
+}
+
+/**
+ * rhine_set_vlan_cam - set CAM VLAN filters
+ * @ioaddr: register block of this Rhine
+ * @idx: VLAN CAM index [0..VCAM_SIZE-1]
+ * @addr: VLAN ID (2 bytes)
+ *
+ * Load addresses into VLAN filters.
+ */
+static void rhine_set_vlan_cam(void __iomem *ioaddr, int idx, u8 *addr)
+{
+	iowrite8(CAMC_CAMEN | CAMC_VCAMSL, ioaddr + CamCon);
+	wmb();
+
+	/* Paranoid -- idx out of range should never happen */
+	idx &= (VCAM_SIZE - 1);
+
+	iowrite8((u8) idx, ioaddr + CamAddr);
+
+	iowrite16(*((u16 *) addr), ioaddr + MulticastFilter0 + 6);
+	udelay(10);
+	wmb();
+
+	iowrite8(CAMC_CAMWR | CAMC_CAMEN, ioaddr + CamCon);
+	udelay(10);
+
+	iowrite8(0, ioaddr + CamCon);
+}
+
+/**
+ * rhine_set_cam_mask - set multicast CAM mask
+ * @ioaddr: register block of this Rhine
+ * @mask: multicast CAM mask
+ *
+ * Mask sets multicast filters active/inactive.
+ */
+static void rhine_set_cam_mask(void __iomem *ioaddr, u32 mask)
+{
+	iowrite8(CAMC_CAMEN, ioaddr + CamCon);
+	wmb();
+
+	/* write mask */
+	iowrite32(mask, ioaddr + CamMask);
+
+	/* disable CAMEN */
+	iowrite8(0, ioaddr + CamCon);
+}
+
+/**
+ * rhine_set_vlan_cam_mask - set VLAN CAM mask
+ * @ioaddr: register block of this Rhine
+ * @mask: VLAN CAM mask
+ *
+ * Mask sets VLAN filters active/inactive.
+ */
+static void rhine_set_vlan_cam_mask(void __iomem *ioaddr, u32 mask)
+{
+	iowrite8(CAMC_CAMEN | CAMC_VCAMSL, ioaddr + CamCon);
+	wmb();
+
+	/* write mask */
+	iowrite32(mask, ioaddr + CamMask);
+
+	/* disable CAMEN */
+	iowrite8(0, ioaddr + CamCon);
+}
+
+/**
+ * rhine_init_cam_filter - initialize CAM filters
+ * @dev: network device
+ *
+ * Initialize (disable) hardware VLAN and multicast support on this
+ * Rhine.
+ */
+static void rhine_init_cam_filter(struct net_device *dev)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	void __iomem *ioaddr = rp->base;
+
+	/* Disable all CAMs */
+	rhine_set_vlan_cam_mask(ioaddr, 0);
+	rhine_set_cam_mask(ioaddr, 0);
+
+	/* disable hardware VLAN support */
+	BYTE_REG_BITS_ON(TCR_PQEN, ioaddr + TxConfig);
+	BYTE_REG_BITS_OFF(BCR1_VIDFR, ioaddr + PCIBusConfig1);
+}
+
+/**
+ * rhine_update_vcam - update VLAN CAM filters
+ * @rp: rhine_private data of this Rhine
+ *
+ * Update VLAN CAM filters to match configuration change.
+ */
+static void rhine_update_vcam(struct net_device *dev)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	void __iomem *ioaddr = rp->base;
+	u16 vid;
+	u32 vCAMmask = 0;	/* 32 vCAMs (6105M and better) */
+	unsigned int i = 0;
+
+	for_each_set_bit(vid, rp->active_vlans, VLAN_N_VID) {
+		rhine_set_vlan_cam(ioaddr, i, (u8 *)&vid);
+		vCAMmask |= 1 << i;
+		if (++i >= VCAM_SIZE)
+			break;
+	}
+	rhine_set_vlan_cam_mask(ioaddr, vCAMmask);
+}
+
+static void rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+
+	spin_lock_irq(&rp->lock);
+	set_bit(vid, rp->active_vlans);
+	rhine_update_vcam(dev);
+	spin_unlock_irq(&rp->lock);
+}
+
+static void rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+
+	spin_lock_irq(&rp->lock);
+	clear_bit(vid, rp->active_vlans);
+	rhine_update_vcam(dev);
+	spin_unlock_irq(&rp->lock);
+}
+
 static void init_registers(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -1061,6 +1300,9 @@ static void init_registers(struct net_device *dev)
 
 	rhine_set_rx_mode(dev);
 
+	if (rp->pdev->revision >= VT6105M)
+		rhine_init_cam_filter(dev);
+
 	napi_enable(&rp->napi);
 
 	/* Enable interrupts by setting the interrupt mask. */
@@ -1276,16 +1518,28 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	rp->tx_ring[entry].desc_length =
 		cpu_to_le32(TXDESC | (skb->len >= ETH_ZLEN ? skb->len : ETH_ZLEN));
 
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		rp->tx_ring[entry].tx_status = cpu_to_le32((vlan_tx_tag_get(skb)) << 16);
+		/* request tagging */
+		rp->tx_ring[entry].desc_length |= cpu_to_le32(0x020000);
+	}
+	else
+		rp->tx_ring[entry].tx_status = 0;
+
 	/* lock eth irq */
 	spin_lock_irqsave(&rp->lock, flags);
 	wmb();
-	rp->tx_ring[entry].tx_status = cpu_to_le32(DescOwn);
+	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
 	wmb();
 
 	rp->cur_tx++;
 
 	/* Non-x86 Todo: explicitly flush cache lines here. */
 
+	if (vlan_tx_tag_present(skb))
+		/* Tx queues are bits 7-0 (first Tx queue: bit 7) */
+		BYTE_REG_BITS_ON(1 << 7, ioaddr + TQWake);
+
 	/* Wake the potentially-idle transmit channel */
 	iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1TxDemand,
 	       ioaddr + ChipCmd1);
@@ -1437,6 +1691,21 @@ static void rhine_tx(struct net_device *dev)
 	spin_unlock(&rp->lock);
 }
 
+/**
+ * rhine_get_vlan_tci - extract TCI from Rx data buffer
+ * @skb: pointer to sk_buff
+ * @data_size: used data area of the buffer including CRC
+ *
+ * If hardware VLAN tag extraction is enabled and the chip indicates a 802.1Q
+ * packet, the extracted 802.1Q header (2 bytes TPID + 2 bytes TCI) is 4-byte
+ * aligned following the CRC.
+ */
+static inline u16 rhine_get_vlan_tci(struct sk_buff *skb, int data_size)
+{
+	u8 *trailer = (u8 *)skb->data + ((data_size + 3) & ~3) + 2;
+	return ntohs(*(u16 *)trailer);
+}
+
 /* Process up to limit frames from receive ring */
 static int rhine_rx(struct net_device *dev, int limit)
 {
@@ -1454,6 +1723,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 	for (count = 0; count < limit; ++count) {
 		struct rx_desc *desc = rp->rx_head_desc;
 		u32 desc_status = le32_to_cpu(desc->rx_status);
+		u32 desc_length = le32_to_cpu(desc->desc_length);
 		int data_size = desc_status >> 16;
 
 		if (desc_status & DescOwn)
@@ -1498,6 +1768,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 			struct sk_buff *skb = NULL;
 			/* Length should omit the CRC */
 			int pkt_len = data_size - 4;
+			u16 vlan_tci = 0;
 
 			/* Check if the packet is long enough to accept without
 			   copying to a minimally-sized skbuff. */
@@ -1532,7 +1803,14 @@ static int rhine_rx(struct net_device *dev, int limit)
 						 rp->rx_buf_sz,
 						 PCI_DMA_FROMDEVICE);
 			}
+
+			if (unlikely(desc_length & DescTag))
+				vlan_tci = rhine_get_vlan_tci(skb, data_size);
+
 			skb->protocol = eth_type_trans(skb, dev);
+
+			if (unlikely(desc_length & DescTag))
+				__vlan_hwaccel_put_tag(skb, vlan_tci);
 			netif_receive_skb(skb);
 			dev->stats.rx_bytes += pkt_len;
 			dev->stats.rx_packets++;
@@ -1596,6 +1874,11 @@ static void rhine_restart_tx(struct net_device *dev) {
 
 		iowrite8(ioread8(ioaddr + ChipCmd) | CmdTxOn,
 		       ioaddr + ChipCmd);
+
+		if (rp->tx_ring[entry].desc_length & cpu_to_le32(0x020000))
+			/* Tx queues are bits 7-0 (first Tx queue: bit 7) */
+			BYTE_REG_BITS_ON(1 << 7, ioaddr + TQWake);
+
 		iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1TxDemand,
 		       ioaddr + ChipCmd1);
 		IOSYNC;
@@ -1631,7 +1914,7 @@ static void rhine_error(struct net_device *dev, int intr_status)
 	}
 	if (intr_status & IntrTxUnderrun) {
 		if (rp->tx_thresh < 0xE0)
-			iowrite8(rp->tx_thresh += 0x20, ioaddr + TxConfig);
+			BYTE_REG_BITS_SET((rp->tx_thresh += 0x20), 0x80, ioaddr + TxConfig);
 		if (debug > 1)
 			printk(KERN_INFO "%s: Transmitter underrun, Tx "
 			       "threshold now %2.2x.\n",
@@ -1646,7 +1929,7 @@ static void rhine_error(struct net_device *dev, int intr_status)
 	    (intr_status & (IntrTxAborted |
 	     IntrTxUnderrun | IntrTxDescRace)) == 0) {
 		if (rp->tx_thresh < 0xE0) {
-			iowrite8(rp->tx_thresh += 0x20, ioaddr + TxConfig);
+			BYTE_REG_BITS_SET((rp->tx_thresh += 0x20), 0x80, ioaddr + TxConfig);
 		}
 		if (debug > 1)
 			printk(KERN_INFO "%s: Unspecified error. Tx "
@@ -1688,7 +1971,8 @@ static void rhine_set_rx_mode(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	u32 mc_filter[2];	/* Multicast hash filter */
-	u8 rx_mode;		/* Note: 0x02=accept runt, 0x01=accept errs */
+	u8 rx_mode = 0x0C;	/* Note: 0x02=accept runt, 0x01=accept errs */
+	struct netdev_hw_addr *ha;
 
 	if (dev->flags & IFF_PROMISC) {		/* Set promiscuous. */
 		rx_mode = 0x1C;
@@ -1699,10 +1983,18 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		/* Too many to match, or accept all multicasts. */
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
-		rx_mode = 0x0C;
+	} else if (rp->pdev->revision >= VT6105M) {
+		int i = 0;
+		u32 mCAMmask = 0;	/* 32 mCAMs (6105M and better) */
+		netdev_for_each_mc_addr(ha, dev) {
+			if (i == MCAM_SIZE)
+				break;
+			rhine_set_cam(ioaddr, i, ha->addr);
+			mCAMmask |= 1 << i;
+			i++;
+		}
+		rhine_set_cam_mask(ioaddr, mCAMmask);
 	} else {
-		struct netdev_hw_addr *ha;
-
 		memset(mc_filter, 0, sizeof(mc_filter));
 		netdev_for_each_mc_addr(ha, dev) {
 			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
@@ -1711,9 +2003,15 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		}
 		iowrite32(mc_filter[0], ioaddr + MulticastFilter0);
 		iowrite32(mc_filter[1], ioaddr + MulticastFilter1);
-		rx_mode = 0x0C;
 	}
-	iowrite8(rp->rx_thresh | rx_mode, ioaddr + RxConfig);
+	/* enable/disable VLAN receive filtering */
+	if (rp->pdev->revision >= VT6105M) {
+		if (dev->flags & IFF_PROMISC)
+			BYTE_REG_BITS_OFF(BCR1_VIDFR, ioaddr + PCIBusConfig1);
+		else
+			BYTE_REG_BITS_ON(BCR1_VIDFR, ioaddr + PCIBusConfig1);
+	}
+	BYTE_REG_BITS_ON(rx_mode, ioaddr + RxConfig);
 }
 
 static void netdev_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -1966,7 +2264,7 @@ static int rhine_resume(struct pci_dev *pdev)
 	if (!netif_running(dev))
 		return 0;
 
-        if (request_irq(dev->irq, rhine_interrupt, IRQF_SHARED, dev->name, dev))
+	if (request_irq(dev->irq, rhine_interrupt, IRQF_SHARED, dev->name, dev))
 		printk(KERN_ERR "via-rhine %s: request_irq failed\n", dev->name);
 
 	ret = pci_set_power_state(pdev, PCI_D0);
