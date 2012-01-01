From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: [PATCH 1/1] via-rhine: Split driver into .c and .h files.
Date: Sun,  1 Jan 2012 21:15:24 +0000
Message-ID: <1325452525-23476-1-git-send-email-gurligebis@gentoo.org>
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch,
	Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Split the driver into via-rhine.c and via-rhine.h like it should be.

There is also a bit of cleanup of checkpatch warnings, other than that,
there is no changes to how the code works, it is plain refactoring.

Signed-off-by: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
---
 drivers/net/ethernet/via/via-rhine.c |  449 ++--------------------------------
 drivers/net/ethernet/via/via-rhine.h |  440 +++++++++++++++++++++++++++++++++
 2 files changed, 466 insertions(+), 423 deletions(-)
 create mode 100644 drivers/net/ethernet/via/via-rhine.h

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 89ced1b..6c1651e 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -68,25 +68,6 @@ static bool avoid_D3;
    The Rhine has a 64 element 8390-like hash table. */
 static const int multicast_filter_limit = 32;
 
-
-/* Operational parameters that are set at compile time. */
-
-/* Keep the ring sizes a power of two for compile efficiency.
-   The compiler will convert <unsigned>'%'<2^N> into a bit mask.
-   Making the Tx ring too large decreases the effectiveness of channel
-   bonding and packet priority.
-   There are no ill effects from too-large receive rings. */
-#define TX_RING_SIZE	16
-#define TX_QUEUE_LEN	10	/* Limit ring entries actually used. */
-#define RX_RING_SIZE	64
-
-/* Operational parameters that usually are not changed. */
-
-/* Time in jiffies before concluding the transmitter is hung. */
-#define TX_TIMEOUT	(2*HZ)
-
-#define PKT_BUF_SZ	1536	/* Size of each temporary Rx buffer.*/
-
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
@@ -114,16 +95,7 @@ static const int multicast_filter_limit = 32;
 #include <asm/uaccess.h>
 #include <linux/dmi.h>
 
-/* These identify the driver base version and may not be removed. */
-static const char version[] __devinitconst =
-	"v1.10-LK" DRV_VERSION " " DRV_RELDATE " Written by Donald Becker";
-
-/* This driver was written to use PCI memory space. Some early versions
-   of the Rhine may only work correctly with I/O space accesses. */
-#ifdef CONFIG_VIA_RHINE_MMIO
-#define USE_MMIO
-#else
-#endif
+#include "via-rhine.h"
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("VIA Rhine PCI Fast Ethernet driver");
@@ -136,9 +108,6 @@ MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for broken BIOSes)");
 
-#define MCAM_SIZE	32
-#define VCAM_SIZE	32
-
 /*
 		Theory of Operation
 
@@ -232,290 +201,6 @@ The chip does not pad to minimum transmit length.
 
 */
 
-
-/* This table drives the PCI probe routines. It's mostly boilerplate in all
-   of the drivers, and will likely be provided by some future kernel.
-   Note the matching code -- the first table entry matchs all 56** cards but
-   second only the 1234 card.
-*/
-
-enum rhine_revs {
-	VT86C100A	= 0x00,
-	VTunknown0	= 0x20,
-	VT6102		= 0x40,
-	VT8231		= 0x50,	/* Integrated MAC */
-	VT8233		= 0x60,	/* Integrated MAC */
-	VT8235		= 0x74,	/* Integrated MAC */
-	VT8237		= 0x78,	/* Integrated MAC */
-	VTunknown1	= 0x7C,
-	VT6105		= 0x80,
-	VT6105_B0	= 0x83,
-	VT6105L		= 0x8A,
-	VT6107		= 0x8C,
-	VTunknown2	= 0x8E,
-	VT6105M		= 0x90,	/* Management adapter */
-};
-
-enum rhine_quirks {
-	rqWOL		= 0x0001,	/* Wake-On-LAN support */
-	rqForceReset	= 0x0002,
-	rq6patterns	= 0x0040,	/* 6 instead of 4 patterns for WOL */
-	rqStatusWBRace	= 0x0080,	/* Tx Status Writeback Error possible */
-	rqRhineI	= 0x0100,	/* See comment below */
-};
-/*
- * rqRhineI: VT86C100A (aka Rhine-I) uses different bits to enable
- * MMIO as well as for the collision counter and the Tx FIFO underflow
- * indicator. In addition, Tx and Rx buffers need to 4 byte aligned.
- */
-
-/* Beware of PCI posted writes */
-#define IOSYNC	do { ioread8(ioaddr + StationAddr); } while (0)
-
-static DEFINE_PCI_DEVICE_TABLE(rhine_pci_tbl) = {
-	{ 0x1106, 0x3043, PCI_ANY_ID, PCI_ANY_ID, },	/* VT86C100A */
-	{ 0x1106, 0x3065, PCI_ANY_ID, PCI_ANY_ID, },	/* VT6102 */
-	{ 0x1106, 0x3106, PCI_ANY_ID, PCI_ANY_ID, },	/* 6105{,L,LOM} */
-	{ 0x1106, 0x3053, PCI_ANY_ID, PCI_ANY_ID, },	/* VT6105M */
-	{ }	/* terminate list */
-};
-MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
-
-
-/* Offsets to the device registers. */
-enum register_offsets {
-	StationAddr=0x00, RxConfig=0x06, TxConfig=0x07, ChipCmd=0x08,
-	ChipCmd1=0x09, TQWake=0x0A,
-	IntrStatus=0x0C, IntrEnable=0x0E,
-	MulticastFilter0=0x10, MulticastFilter1=0x14,
-	RxRingPtr=0x18, TxRingPtr=0x1C, GFIFOTest=0x54,
-	MIIPhyAddr=0x6C, MIIStatus=0x6D, PCIBusConfig=0x6E, PCIBusConfig1=0x6F,
-	MIICmd=0x70, MIIRegAddr=0x71, MIIData=0x72, MACRegEEcsr=0x74,
-	ConfigA=0x78, ConfigB=0x79, ConfigC=0x7A, ConfigD=0x7B,
-	RxMissed=0x7C, RxCRCErrs=0x7E, MiscCmd=0x81,
-	StickyHW=0x83, IntrStatus2=0x84,
-	CamMask=0x88, CamCon=0x92, CamAddr=0x93,
-	WOLcrSet=0xA0, PwcfgSet=0xA1, WOLcgSet=0xA3, WOLcrClr=0xA4,
-	WOLcrClr1=0xA6, WOLcgClr=0xA7,
-	PwrcsrSet=0xA8, PwrcsrSet1=0xA9, PwrcsrClr=0xAC, PwrcsrClr1=0xAD,
-};
-
-/* Bits in ConfigD */
-enum backoff_bits {
-	BackOptional=0x01, BackModify=0x02,
-	BackCaptureEffect=0x04, BackRandom=0x08
-};
-
-/* Bits in the TxConfig (TCR) register */
-enum tcr_bits {
-	TCR_PQEN=0x01,
-	TCR_LB0=0x02,		/* loopback[0] */
-	TCR_LB1=0x04,		/* loopback[1] */
-	TCR_OFSET=0x08,
-	TCR_RTGOPT=0x10,
-	TCR_RTFT0=0x20,
-	TCR_RTFT1=0x40,
-	TCR_RTSF=0x80,
-};
-
-/* Bits in the CamCon (CAMC) register */
-enum camcon_bits {
-	CAMC_CAMEN=0x01,
-	CAMC_VCAMSL=0x02,
-	CAMC_CAMWR=0x04,
-	CAMC_CAMRD=0x08,
-};
-
-/* Bits in the PCIBusConfig1 (BCR1) register */
-enum bcr1_bits {
-	BCR1_POT0=0x01,
-	BCR1_POT1=0x02,
-	BCR1_POT2=0x04,
-	BCR1_CTFT0=0x08,
-	BCR1_CTFT1=0x10,
-	BCR1_CTSF=0x20,
-	BCR1_TXQNOBK=0x40,	/* for VT6105 */
-	BCR1_VIDFR=0x80,	/* for VT6105 */
-	BCR1_MED0=0x40,		/* for VT6102 */
-	BCR1_MED1=0x80,		/* for VT6102 */
-};
-
-#ifdef USE_MMIO
-/* Registers we check that mmio and reg are the same. */
-static const int mmio_verify_registers[] = {
-	RxConfig, TxConfig, IntrEnable, ConfigA, ConfigB, ConfigC, ConfigD,
-	0
-};
-#endif
-
-/* Bits in the interrupt status/mask registers. */
-enum intr_status_bits {
-	IntrRxDone	= 0x0001,
-	IntrTxDone	= 0x0002,
-	IntrRxErr	= 0x0004,
-	IntrTxError	= 0x0008,
-	IntrRxEmpty	= 0x0020,
-	IntrPCIErr	= 0x0040,
-	IntrStatsMax	= 0x0080,
-	IntrRxEarly	= 0x0100,
-	IntrTxUnderrun	= 0x0210,
-	IntrRxOverflow	= 0x0400,
-	IntrRxDropped	= 0x0800,
-	IntrRxNoBuf	= 0x1000,
-	IntrTxAborted	= 0x2000,
-	IntrLinkChange	= 0x4000,
-	IntrRxWakeUp	= 0x8000,
-	IntrTxDescRace		= 0x080000,	/* mapped from IntrStatus2 */
-	IntrNormalSummary	= IntrRxDone | IntrTxDone,
-	IntrTxErrSummary	= IntrTxDescRace | IntrTxAborted | IntrTxError |
-				  IntrTxUnderrun,
-};
-
-/* Bits in WOLcrSet/WOLcrClr and PwrcsrSet/PwrcsrClr */
-enum wol_bits {
-	WOLucast	= 0x10,
-	WOLmagic	= 0x20,
-	WOLbmcast	= 0x30,
-	WOLlnkon	= 0x40,
-	WOLlnkoff	= 0x80,
-};
-
-/* The Rx and Tx buffer descriptors. */
-struct rx_desc {
-	__le32 rx_status;
-	__le32 desc_length; /* Chain flag, Buffer/frame length */
-	__le32 addr;
-	__le32 next_desc;
-};
-struct tx_desc {
-	__le32 tx_status;
-	__le32 desc_length; /* Chain flag, Tx Config, Frame length */
-	__le32 addr;
-	__le32 next_desc;
-};
-
-/* Initial value for tx_desc.desc_length, Buffer size goes to bits 0-10 */
-#define TXDESC		0x00e08000
-
-enum rx_status_bits {
-	RxOK=0x8000, RxWholePkt=0x0300, RxErr=0x008F
-};
-
-/* Bits in *_desc.*_status */
-enum desc_status_bits {
-	DescOwn=0x80000000
-};
-
-/* Bits in *_desc.*_length */
-enum desc_length_bits {
-	DescTag=0x00010000
-};
-
-/* Bits in ChipCmd. */
-enum chip_cmd_bits {
-	CmdInit=0x01, CmdStart=0x02, CmdStop=0x04, CmdRxOn=0x08,
-	CmdTxOn=0x10, Cmd1TxDemand=0x20, CmdRxDemand=0x40,
-	Cmd1EarlyRx=0x01, Cmd1EarlyTx=0x02, Cmd1FDuplex=0x04,
-	Cmd1NoTxPoll=0x08, Cmd1Reset=0x80,
-};
-
-struct rhine_private {
-	/* Bit mask for configured VLAN ids */
-	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
-
-	/* Descriptor rings */
-	struct rx_desc *rx_ring;
-	struct tx_desc *tx_ring;
-	dma_addr_t rx_ring_dma;
-	dma_addr_t tx_ring_dma;
-
-	/* The addresses of receive-in-place skbuffs. */
-	struct sk_buff *rx_skbuff[RX_RING_SIZE];
-	dma_addr_t rx_skbuff_dma[RX_RING_SIZE];
-
-	/* The saved address of a sent-in-place packet/buffer, for later free(). */
-	struct sk_buff *tx_skbuff[TX_RING_SIZE];
-	dma_addr_t tx_skbuff_dma[TX_RING_SIZE];
-
-	/* Tx bounce buffers (Rhine-I only) */
-	unsigned char *tx_buf[TX_RING_SIZE];
-	unsigned char *tx_bufs;
-	dma_addr_t tx_bufs_dma;
-
-	struct pci_dev *pdev;
-	long pioaddr;
-	struct net_device *dev;
-	struct napi_struct napi;
-	spinlock_t lock;
-	struct mutex task_lock;
-	bool task_enable;
-	struct work_struct slow_event_task;
-	struct work_struct reset_task;
-
-	u32 msg_enable;
-
-	/* Frequently used values: keep some adjacent for cache effect. */
-	u32 quirks;
-	struct rx_desc *rx_head_desc;
-	unsigned int cur_rx, dirty_rx;	/* Producer/consumer ring indices */
-	unsigned int cur_tx, dirty_tx;
-	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
-	u8 wolopts;
-
-	u8 tx_thresh, rx_thresh;
-
-	struct mii_if_info mii_if;
-	void __iomem *base;
-};
-
-#define BYTE_REG_BITS_ON(x, p)      do { iowrite8((ioread8((p))|(x)), (p)); } while (0)
-#define WORD_REG_BITS_ON(x, p)      do { iowrite16((ioread16((p))|(x)), (p)); } while (0)
-#define DWORD_REG_BITS_ON(x, p)     do { iowrite32((ioread32((p))|(x)), (p)); } while (0)
-
-#define BYTE_REG_BITS_IS_ON(x, p)   (ioread8((p)) & (x))
-#define WORD_REG_BITS_IS_ON(x, p)   (ioread16((p)) & (x))
-#define DWORD_REG_BITS_IS_ON(x, p)  (ioread32((p)) & (x))
-
-#define BYTE_REG_BITS_OFF(x, p)     do { iowrite8(ioread8((p)) & (~(x)), (p)); } while (0)
-#define WORD_REG_BITS_OFF(x, p)     do { iowrite16(ioread16((p)) & (~(x)), (p)); } while (0)
-#define DWORD_REG_BITS_OFF(x, p)    do { iowrite32(ioread32((p)) & (~(x)), (p)); } while (0)
-
-#define BYTE_REG_BITS_SET(x, m, p)   do { iowrite8((ioread8((p)) & (~(m)))|(x), (p)); } while (0)
-#define WORD_REG_BITS_SET(x, m, p)   do { iowrite16((ioread16((p)) & (~(m)))|(x), (p)); } while (0)
-#define DWORD_REG_BITS_SET(x, m, p)  do { iowrite32((ioread32((p)) & (~(m)))|(x), (p)); } while (0)
-
-
-static int  mdio_read(struct net_device *dev, int phy_id, int location);
-static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
-static int  rhine_open(struct net_device *dev);
-static void rhine_reset_task(struct work_struct *work);
-static void rhine_slow_event_task(struct work_struct *work);
-static void rhine_tx_timeout(struct net_device *dev);
-static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
-				  struct net_device *dev);
-static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
-static void rhine_tx(struct net_device *dev);
-static int rhine_rx(struct net_device *dev, int limit);
-static void rhine_set_rx_mode(struct net_device *dev);
-static struct net_device_stats *rhine_get_stats(struct net_device *dev);
-static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static const struct ethtool_ops netdev_ethtool_ops;
-static int  rhine_close(struct net_device *dev);
-static void rhine_shutdown (struct pci_dev *pdev);
-static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
-static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
-static void rhine_restart_tx(struct net_device *dev);
-
-#define RHINE_WAIT_FOR(condition)				\
-do {								\
-	int i = 1024;						\
-	while (!(condition) && --i)				\
-		;						\
-	if (debug > 1 && i < 512)				\
-		pr_info("%4d cycles used @ %s:%d\n",		\
-			1024 - i, __func__, __LINE__);		\
-} while (0)
-
 static u32 rhine_get_events(struct rhine_private *rp)
 {
 	void __iomem *ioaddr = rp->base;
@@ -731,26 +416,6 @@ static void rhine_update_rx_crc_and_missed_errord(struct rhine_private *rp)
 	ioread16(ioaddr + RxMissed);
 }
 
-#define RHINE_EVENT_NAPI_RX	(IntrRxDone | \
-				 IntrRxErr | \
-				 IntrRxEmpty | \
-				 IntrRxOverflow	| \
-				 IntrRxDropped | \
-				 IntrRxNoBuf | \
-				 IntrRxWakeUp)
-
-#define RHINE_EVENT_NAPI_TX_ERR	(IntrTxError | \
-				 IntrTxAborted | \
-				 IntrTxUnderrun | \
-				 IntrTxDescRace)
-#define RHINE_EVENT_NAPI_TX	(IntrTxDone | RHINE_EVENT_NAPI_TX_ERR)
-
-#define RHINE_EVENT_NAPI	(RHINE_EVENT_NAPI_RX | \
-				 RHINE_EVENT_NAPI_TX | \
-				 IntrStatsMax)
-#define RHINE_EVENT_SLOW	(IntrPCIErr | IntrLinkChange)
-#define RHINE_EVENT		(RHINE_EVENT_NAPI | RHINE_EVENT_SLOW)
-
 static int rhine_napipoll(struct napi_struct *napi, int budget)
 {
 	struct rhine_private *rp = container_of(napi, struct rhine_private, napi);
@@ -814,24 +479,6 @@ static void __devinit rhine_hw_init(struct net_device *dev, long pioaddr)
 	rhine_reload_eeprom(pioaddr, dev);
 }
 
-static const struct net_device_ops rhine_netdev_ops = {
-	.ndo_open		 = rhine_open,
-	.ndo_stop		 = rhine_close,
-	.ndo_start_xmit		 = rhine_start_tx,
-	.ndo_get_stats		 = rhine_get_stats,
-	.ndo_set_rx_mode	 = rhine_set_rx_mode,
-	.ndo_change_mtu		 = eth_change_mtu,
-	.ndo_validate_addr	 = eth_validate_addr,
-	.ndo_set_mac_address 	 = eth_mac_addr,
-	.ndo_do_ioctl		 = netdev_ioctl,
-	.ndo_tx_timeout 	 = rhine_tx_timeout,
-	.ndo_vlan_rx_add_vid	 = rhine_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	 = rhine_vlan_rx_kill_vid,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	 = rhine_poll,
-#endif
-};
-
 static int __devinit rhine_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
@@ -1774,21 +1421,6 @@ static void rhine_tx(struct net_device *dev)
 		netif_wake_queue(dev);
 }
 
-/**
- * rhine_get_vlan_tci - extract TCI from Rx data buffer
- * @skb: pointer to sk_buff
- * @data_size: used data area of the buffer including CRC
- *
- * If hardware VLAN tag extraction is enabled and the chip indicates a 802.1Q
- * packet, the extracted 802.1Q header (2 bytes TPID + 2 bytes TCI) is 4-byte
- * aligned following the CRC.
- */
-static inline u16 rhine_get_vlan_tci(struct sk_buff *skb, int data_size)
-{
-	u8 *trailer = (u8 *)skb->data + ((data_size + 3) & ~3) + 2;
-	return be16_to_cpup((__be16 *)trailer);
-}
-
 /* Process up to limit frames from receive ring */
 static int rhine_rx(struct net_device *dev, int limit)
 {
@@ -1992,17 +1624,6 @@ out_unlock:
 	mutex_unlock(&rp->task_lock);
 }
 
-static struct net_device_stats *rhine_get_stats(struct net_device *dev)
-{
-	struct rhine_private *rp = netdev_priv(dev);
-
-	spin_lock_bh(&rp->lock);
-	rhine_update_rx_crc_and_missed_errord(rp);
-	spin_unlock_bh(&rp->lock);
-
-	return &dev->stats;
-}
-
 static void rhine_set_rx_mode(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -2142,18 +1763,6 @@ static int rhine_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	return 0;
 }
 
-static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo		= netdev_get_drvinfo,
-	.get_settings		= netdev_get_settings,
-	.set_settings		= netdev_set_settings,
-	.nway_reset		= netdev_nway_reset,
-	.get_link		= netdev_get_link,
-	.get_msglevel		= netdev_get_msglevel,
-	.set_msglevel		= netdev_set_msglevel,
-	.get_wol		= rhine_get_wol,
-	.set_wol		= rhine_set_wol,
-};
-
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -2339,36 +1948,6 @@ static int rhine_resume(struct pci_dev *pdev)
 }
 #endif /* CONFIG_PM */
 
-static struct pci_driver rhine_driver = {
-	.name		= DRV_NAME,
-	.id_table	= rhine_pci_tbl,
-	.probe		= rhine_init_one,
-	.remove		= __devexit_p(rhine_remove_one),
-#ifdef CONFIG_PM
-	.suspend	= rhine_suspend,
-	.resume		= rhine_resume,
-#endif /* CONFIG_PM */
-	.shutdown =	rhine_shutdown,
-};
-
-static struct dmi_system_id __initdata rhine_dmi_table[] = {
-	{
-		.ident = "EPIA-M",
-		.matches = {
-			DMI_MATCH(DMI_BIOS_VENDOR, "Award Software International, Inc."),
-			DMI_MATCH(DMI_BIOS_VERSION, "6.00 PG"),
-		},
-	},
-	{
-		.ident = "KV7",
-		.matches = {
-			DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies, LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "6.00 PG"),
-		},
-	},
-	{ NULL }
-};
-
 static int __init rhine_init(void)
 {
 /* when a module, this is printed whether or not devices are found in probe */
@@ -2386,12 +1965,36 @@ static int __init rhine_init(void)
 	return pci_register_driver(&rhine_driver);
 }
 
-
 static void __exit rhine_cleanup(void)
 {
 	pci_unregister_driver(&rhine_driver);
 }
 
+static struct net_device_stats *rhine_get_stats(struct net_device *dev)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+
+	spin_lock_bh(&rp->lock);
+	rhine_update_rx_crc_and_missed_errord(rp);
+	spin_unlock_bh(&rp->lock);
+
+	return &dev->stats;
+}
+
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
+	return be16_to_cpup((__be16 *)trailer);
+}
 
 module_init(rhine_init);
 module_exit(rhine_cleanup);
diff --git a/drivers/net/ethernet/via/via-rhine.h b/drivers/net/ethernet/via/via-rhine.h
new file mode 100644
index 0000000..6add270
--- /dev/null
+++ b/drivers/net/ethernet/via/via-rhine.h
@@ -0,0 +1,440 @@
+/* via-rhine.c: A Linux Ethernet device driver for VIA Rhine family chips. */
+/*
+	Written 1998-2001 by Donald Becker.
+
+	Current Maintainer: Roger Luethi <rl@hellgate.ch>
+
+	This software may be used and distributed according to the terms of
+	the GNU General Public License (GPL), incorporated herein by reference.
+	Drivers based on or derived from this code fall under the GPL and must
+	retain the authorship, copyright and license notice.  This file is not
+	a complete program and may only be used when the entire operating
+	system is licensed under the GPL.
+
+	This driver is designed for the VIA VT86C100A Rhine-I.
+	It also works with the Rhine-II (6102) and Rhine-III (6105/6105L/6105LOM
+	and management NIC 6105M).
+
+	The author may be reached as becker@scyld.com, or C/O
+	Scyld Computing Corporation
+	410 Severn Ave., Suite 210
+	Annapolis MD 21403
+
+
+	This driver contains some changes from the original Donald Becker
+	version. He may or may not be interested in bug reports on this
+	code. You can find his versions at:
+	http://www.scyld.com/network/via-rhine.html
+	[link no longer provides useful info -jgarzik]
+
+*/
+
+/* Operational parameters that are set at compile time. */
+
+/* Keep the ring sizes a power of two for compile efficiency.
+   The compiler will convert <unsigned>'%'<2^N> into a bit mask.
+   Making the Tx ring too large decreases the effectiveness of channel
+   bonding and packet priority.
+   There are no ill effects from too-large receive rings. */
+#define TX_RING_SIZE	16
+#define TX_QUEUE_LEN	10	/* Limit ring entries actually used. */
+#define RX_RING_SIZE	64
+
+/* Operational parameters that usually are not changed. */
+
+/* Time in jiffies before concluding the transmitter is hung. */
+#define TX_TIMEOUT	(2*HZ)
+
+#define PKT_BUF_SZ	1536	/* Size of each temporary Rx buffer.*/
+
+/* These identify the driver base version and may not be removed. */
+static const char version[] __devinitconst =
+	"v1.10-LK" DRV_VERSION " " DRV_RELDATE " Written by Donald Becker";
+
+/* This driver was written to use PCI memory space. Some early versions
+   of the Rhine may only work correctly with I/O space accesses. */
+#ifdef CONFIG_VIA_RHINE_MMIO
+#define USE_MMIO
+#else
+#endif
+
+#define MCAM_SIZE	32
+#define VCAM_SIZE	32
+
+/* This table drives the PCI probe routines. It's mostly boilerplate in all
+   of the drivers, and will likely be provided by some future kernel.
+   Note the matching code -- the first table entry matchs all 56** cards but
+   second only the 1234 card.
+*/
+
+enum rhine_revs {
+	VT86C100A	= 0x00,
+	VTunknown0	= 0x20,
+	VT6102		= 0x40,
+	VT8231		= 0x50,	/* Integrated MAC */
+	VT8233		= 0x60,	/* Integrated MAC */
+	VT8235		= 0x74,	/* Integrated MAC */
+	VT8237		= 0x78,	/* Integrated MAC */
+	VTunknown1	= 0x7C,
+	VT6105		= 0x80,
+	VT6105_B0	= 0x83,
+	VT6105L		= 0x8A,
+	VT6107		= 0x8C,
+	VTunknown2	= 0x8E,
+	VT6105M		= 0x90,	/* Management adapter */
+};
+
+enum rhine_quirks {
+	rqWOL		= 0x0001,	/* Wake-On-LAN support */
+	rqForceReset	= 0x0002,
+	rq6patterns	= 0x0040,	/* 6 instead of 4 patterns for WOL */
+	rqStatusWBRace	= 0x0080,	/* Tx Status Writeback Error possible */
+	rqRhineI	= 0x0100,	/* See comment below */
+};
+/*
+ * rqRhineI: VT86C100A (aka Rhine-I) uses different bits to enable
+ * MMIO as well as for the collision counter and the Tx FIFO underflow
+ * indicator. In addition, Tx and Rx buffers need to 4 byte aligned.
+ */
+
+/* Beware of PCI posted writes */
+#define IOSYNC	do { ioread8(ioaddr + StationAddr); } while (0)
+
+static DEFINE_PCI_DEVICE_TABLE(rhine_pci_tbl) = {
+	{ 0x1106, 0x3043, PCI_ANY_ID, PCI_ANY_ID, },	/* VT86C100A */
+	{ 0x1106, 0x3065, PCI_ANY_ID, PCI_ANY_ID, },	/* VT6102 */
+	{ 0x1106, 0x3106, PCI_ANY_ID, PCI_ANY_ID, },	/* 6105{,L,LOM} */
+	{ 0x1106, 0x3053, PCI_ANY_ID, PCI_ANY_ID, },	/* VT6105M */
+	{ }	/* terminate list */
+};
+MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
+
+
+/* Offsets to the device registers. */
+enum register_offsets {
+	StationAddr = 0x00, RxConfig = 0x06, TxConfig = 0x07, ChipCmd = 0x08,
+	ChipCmd1 = 0x09, TQWake = 0x0A,
+	IntrStatus = 0x0C, IntrEnable = 0x0E,
+	MulticastFilter0 = 0x10, MulticastFilter1 = 0x14,
+	RxRingPtr = 0x18, TxRingPtr = 0x1C, GFIFOTest = 0x54,
+	MIIPhyAddr = 0x6C, MIIStatus = 0x6D, PCIBusConfig = 0x6E, PCIBusConfig1 = 0x6F,
+	MIICmd = 0x70, MIIRegAddr = 0x71, MIIData = 0x72, MACRegEEcsr = 0x74,
+	ConfigA = 0x78, ConfigB = 0x79, ConfigC = 0x7A, ConfigD = 0x7B,
+	RxMissed = 0x7C, RxCRCErrs = 0x7E, MiscCmd = 0x81,
+	StickyHW = 0x83, IntrStatus2 = 0x84,
+	CamMask = 0x88, CamCon = 0x92, CamAddr = 0x93,
+	WOLcrSet = 0xA0, PwcfgSet = 0xA1, WOLcgSet = 0xA3, WOLcrClr = 0xA4,
+	WOLcrClr1 = 0xA6, WOLcgClr = 0xA7,
+	PwrcsrSet = 0xA8, PwrcsrSet1 = 0xA9, PwrcsrClr = 0xAC, PwrcsrClr1 = 0xAD,
+};
+
+/* Bits in ConfigD */
+enum backoff_bits {
+	BackOptional = 0x01, BackModify = 0x02,
+	BackCaptureEffect = 0x04, BackRandom = 0x08
+};
+
+/* Bits in the TxConfig (TCR) register */
+enum tcr_bits {
+	TCR_PQEN = 0x01,
+	TCR_LB0 = 0x02,		/* loopback[0] */
+	TCR_LB1 = 0x04,		/* loopback[1] */
+	TCR_OFSET = 0x08,
+	TCR_RTGOPT = 0x10,
+	TCR_RTFT0 = 0x20,
+	TCR_RTFT1 = 0x40,
+	TCR_RTSF = 0x80,
+};
+
+/* Bits in the CamCon (CAMC) register */
+enum camcon_bits {
+	CAMC_CAMEN = 0x01,
+	CAMC_VCAMSL = 0x02,
+	CAMC_CAMWR = 0x04,
+	CAMC_CAMRD = 0x08,
+};
+
+/* Bits in the PCIBusConfig1 (BCR1) register */
+enum bcr1_bits {
+	BCR1_POT0 = 0x01,
+	BCR1_POT1 = 0x02,
+	BCR1_POT2 = 0x04,
+	BCR1_CTFT0 = 0x08,
+	BCR1_CTFT1 = 0x10,
+	BCR1_CTSF = 0x20,
+	BCR1_TXQNOBK = 0x40,	/* for VT6105 */
+	BCR1_VIDFR = 0x80,	/* for VT6105 */
+	BCR1_MED0 = 0x40,		/* for VT6102 */
+	BCR1_MED1 = 0x80,		/* for VT6102 */
+};
+
+#ifdef USE_MMIO
+/* Registers we check that mmio and reg are the same. */
+static const int mmio_verify_registers[] = {
+	RxConfig, TxConfig, IntrEnable, ConfigA, ConfigB, ConfigC, ConfigD,
+	0
+};
+#endif
+
+/* Bits in the interrupt status/mask registers. */
+enum intr_status_bits {
+	IntrRxDone	= 0x0001,
+	IntrTxDone	= 0x0002,
+	IntrRxErr	= 0x0004,
+	IntrTxError	= 0x0008,
+	IntrRxEmpty	= 0x0020,
+	IntrPCIErr	= 0x0040,
+	IntrStatsMax	= 0x0080,
+	IntrRxEarly	= 0x0100,
+	IntrTxUnderrun	= 0x0210,
+	IntrRxOverflow	= 0x0400,
+	IntrRxDropped	= 0x0800,
+	IntrRxNoBuf	= 0x1000,
+	IntrTxAborted	= 0x2000,
+	IntrLinkChange	= 0x4000,
+	IntrRxWakeUp	= 0x8000,
+	IntrTxDescRace		= 0x080000,	/* mapped from IntrStatus2 */
+	IntrNormalSummary	= IntrRxDone | IntrTxDone,
+	IntrTxErrSummary	= IntrTxDescRace | IntrTxAborted | IntrTxError |
+				  IntrTxUnderrun,
+};
+
+/* Bits in WOLcrSet/WOLcrClr and PwrcsrSet/PwrcsrClr */
+enum wol_bits {
+	WOLucast	= 0x10,
+	WOLmagic	= 0x20,
+	WOLbmcast	= 0x30,
+	WOLlnkon	= 0x40,
+	WOLlnkoff	= 0x80,
+};
+
+/* The Rx and Tx buffer descriptors. */
+struct rx_desc {
+	__le32 rx_status;
+	__le32 desc_length; /* Chain flag, Buffer/frame length */
+	__le32 addr;
+	__le32 next_desc;
+};
+struct tx_desc {
+	__le32 tx_status;
+	__le32 desc_length; /* Chain flag, Tx Config, Frame length */
+	__le32 addr;
+	__le32 next_desc;
+};
+
+/* Initial value for tx_desc.desc_length, Buffer size goes to bits 0-10 */
+#define TXDESC		0x00e08000
+
+enum rx_status_bits {
+	RxOK = 0x8000, RxWholePkt = 0x0300, RxErr = 0x008F
+};
+
+/* Bits in *_desc.*_status */
+enum desc_status_bits {
+	DescOwn = 0x80000000
+};
+
+/* Bits in *_desc.*_length */
+enum desc_length_bits {
+	DescTag = 0x00010000
+};
+
+/* Bits in ChipCmd. */
+enum chip_cmd_bits {
+	CmdInit = 0x01, CmdStart = 0x02, CmdStop = 0x04, CmdRxOn = 0x08,
+	CmdTxOn = 0x10, Cmd1TxDemand = 0x20, CmdRxDemand = 0x40,
+	Cmd1EarlyRx = 0x01, Cmd1EarlyTx = 0x02, Cmd1FDuplex = 0x04,
+	Cmd1NoTxPoll = 0x08, Cmd1Reset = 0x80,
+};
+
+struct rhine_private {
+	/* Bit mask for configured VLAN ids */
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+
+	/* Descriptor rings */
+	struct rx_desc *rx_ring;
+	struct tx_desc *tx_ring;
+	dma_addr_t rx_ring_dma;
+	dma_addr_t tx_ring_dma;
+
+	/* The addresses of receive-in-place skbuffs. */
+	struct sk_buff *rx_skbuff[RX_RING_SIZE];
+	dma_addr_t rx_skbuff_dma[RX_RING_SIZE];
+
+	/* The saved address of a sent-in-place packet/buffer, for later free(). */
+	struct sk_buff *tx_skbuff[TX_RING_SIZE];
+	dma_addr_t tx_skbuff_dma[TX_RING_SIZE];
+
+	/* Tx bounce buffers (Rhine-I only) */
+	unsigned char *tx_buf[TX_RING_SIZE];
+	unsigned char *tx_bufs;
+	dma_addr_t tx_bufs_dma;
+
+	struct pci_dev *pdev;
+	long pioaddr;
+	struct net_device *dev;
+	struct napi_struct napi;
+	spinlock_t lock;
+	struct mutex task_lock;
+	bool task_enable;
+	struct work_struct slow_event_task;
+	struct work_struct reset_task;
+
+	u32 msg_enable;
+
+	/* Frequently used values: keep some adjacent for cache effect. */
+	u32 quirks;
+	struct rx_desc *rx_head_desc;
+	unsigned int cur_rx, dirty_rx;	/* Producer/consumer ring indices */
+	unsigned int cur_tx, dirty_tx;
+	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
+	u8 wolopts;
+
+	u8 tx_thresh, rx_thresh;
+
+	struct mii_if_info mii_if;
+	void __iomem *base;
+};
+
+static struct dmi_system_id __initdata rhine_dmi_table[] = {
+	{
+		.ident = "EPIA-M",
+		.matches = {
+			DMI_MATCH(DMI_BIOS_VENDOR, "Award Software International, Inc."),
+			DMI_MATCH(DMI_BIOS_VERSION, "6.00 PG"),
+		},
+	},
+	{
+		.ident = "KV7",
+		.matches = {
+			DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies, LTD"),
+			DMI_MATCH(DMI_BIOS_VERSION, "6.00 PG"),
+		},
+	},
+	{ NULL }
+};
+
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
+#define RHINE_WAIT_FOR(condition)				\
+do {								\
+	int i = 1024;						\
+	while (!(condition) && --i)				\
+		;						\
+	if (debug > 1 && i < 512)				\
+		pr_info("%4d cycles used @ %s:%d\n",		\
+			1024 - i, __func__, __LINE__);		\
+} while (0)
+
+#define RHINE_EVENT_NAPI_RX	(IntrRxDone | \
+				 IntrRxErr | \
+				 IntrRxEmpty | \
+				 IntrRxOverflow	| \
+				 IntrRxDropped | \
+				 IntrRxNoBuf | \
+				 IntrRxWakeUp)
+
+#define RHINE_EVENT_NAPI_TX_ERR	(IntrTxError | \
+				 IntrTxAborted | \
+				 IntrTxUnderrun | \
+				 IntrTxDescRace)
+#define RHINE_EVENT_NAPI_TX	(IntrTxDone | RHINE_EVENT_NAPI_TX_ERR)
+
+#define RHINE_EVENT_NAPI	(RHINE_EVENT_NAPI_RX | \
+				 RHINE_EVENT_NAPI_TX | \
+				 IntrStatsMax)
+#define RHINE_EVENT_SLOW	(IntrPCIErr | IntrLinkChange)
+#define RHINE_EVENT		(RHINE_EVENT_NAPI | RHINE_EVENT_SLOW)
+
+static const struct ethtool_ops netdev_ethtool_ops;
+
+static int mdio_read(struct net_device *dev, int phy_id, int location);
+static void mdio_write(struct net_device *dev,
+					int phy_id, int location, int value);
+static int rhine_open(struct net_device *dev);
+static void rhine_update_rx_crc_and_missed_errord(struct rhine_private *rp);
+static int __devinit rhine_init_one(struct pci_dev *pdev,
+				    const struct pci_device_id *ent);
+static void __devexit rhine_remove_one(struct pci_dev *pdev);
+static void rhine_reset_task(struct work_struct *work);
+static void rhine_slow_event_task(struct work_struct *work);
+static void rhine_tx_timeout(struct net_device *dev);
+static netdev_tx_t rhine_start_tx(struct sk_buff *skb, struct net_device *dev);
+static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
+static void rhine_tx(struct net_device *dev);
+static int rhine_rx(struct net_device *dev, int limit);
+static void rhine_set_rx_mode(struct net_device *dev);
+static struct net_device_stats *rhine_get_stats(struct net_device *dev);
+static void netdev_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info);
+static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+static int netdev_nway_reset(struct net_device *dev);
+static u32 netdev_get_link(struct net_device *dev);
+static u32 netdev_get_msglevel(struct net_device *dev);
+static void netdev_set_msglevel(struct net_device *dev, u32 value);
+static void rhine_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol);
+static int rhine_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol);
+static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static void rhine_task_enable(struct rhine_private *rp);
+static int rhine_close(struct net_device *dev);
+static void rhine_shutdown(struct pci_dev *pdev);
+static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
+static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
+static void rhine_restart_tx(struct net_device *dev);
+static inline u16 rhine_get_vlan_tci(struct sk_buff *skb, int data_size);
+
+static const struct net_device_ops rhine_netdev_ops = {
+	.ndo_open		 = rhine_open,
+	.ndo_stop		 = rhine_close,
+	.ndo_start_xmit		 = rhine_start_tx,
+	.ndo_get_stats		 = rhine_get_stats,
+	.ndo_set_rx_mode	 = rhine_set_rx_mode,
+	.ndo_change_mtu		 = eth_change_mtu,
+	.ndo_validate_addr	 = eth_validate_addr,
+	.ndo_set_mac_address	 = eth_mac_addr,
+	.ndo_do_ioctl		 = netdev_ioctl,
+	.ndo_tx_timeout		 = rhine_tx_timeout,
+	.ndo_vlan_rx_add_vid	 = rhine_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	 = rhine_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	 = rhine_poll,
+#endif
+};
+
+static const struct ethtool_ops netdev_ethtool_ops = {
+	.get_drvinfo		= netdev_get_drvinfo,
+	.get_settings		= netdev_get_settings,
+	.set_settings		= netdev_set_settings,
+	.nway_reset		= netdev_nway_reset,
+	.get_link		= netdev_get_link,
+	.get_msglevel		= netdev_get_msglevel,
+	.set_msglevel		= netdev_set_msglevel,
+	.get_wol		= rhine_get_wol,
+	.set_wol		= rhine_set_wol,
+};
+
+static struct pci_driver rhine_driver = {
+	.name		= DRV_NAME,
+	.id_table	= rhine_pci_tbl,
+	.probe		= rhine_init_one,
+	.remove		= __devexit_p(rhine_remove_one),
+#ifdef CONFIG_PM
+	.suspend	= rhine_suspend,
+	.resume		= rhine_resume,
+#endif /* CONFIG_PM */
+	.shutdown =	rhine_shutdown,
+};
-- 
1.7.8.1
