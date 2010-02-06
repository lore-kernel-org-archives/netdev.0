From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 1/6] dmfe: trivial cleanups:
Date: Sat,  6 Feb 2010 22:18:57 +0200
Message-ID: <1265487542-4447-2-git-send-email-maximlevitsky@gmail.com>
References: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Create header file
* Add dmfe_ prefix to all functions
* Move functions to be in more logical order
* Remove useless DEVICE define

This patch doesn't bring any functional changes

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/net/tulip/dmfe.c | 1706 +++++++++++++++++++++-------------------------
 drivers/net/tulip/dmfe.h |  305 +++++++++
 2 files changed, 1077 insertions(+), 934 deletions(-)
 create mode 100644 drivers/net/tulip/dmfe.h

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 6f44ebf..158ffc2 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -61,10 +61,6 @@
     Test and make sure PCI latency is now correct for all cases.
 */
 
-#define DRV_NAME	"dmfe"
-#define DRV_VERSION	"1.36.4"
-#define DRV_RELDATE	"2002-01-17"
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -87,210 +83,16 @@
 #include <linux/bitops.h>
 
 #include <asm/processor.h>
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/dma.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <asm/irq.h>
+#include "dmfe.h"
 
 #ifdef CONFIG_TULIP_DM910X
 #include <linux/of.h>
 #endif
 
-
-/* Board/System/Debug information/definition ---------------- */
-#define PCI_DM9132_ID   0x91321282      /* Davicom DM9132 ID */
-#define PCI_DM9102_ID   0x91021282      /* Davicom DM9102 ID */
-#define PCI_DM9100_ID   0x91001282      /* Davicom DM9100 ID */
-#define PCI_DM9009_ID   0x90091282      /* Davicom DM9009 ID */
-
-#define DM9102_IO_SIZE  0x80
-#define DM9102A_IO_SIZE 0x100
-#define TX_MAX_SEND_CNT 0x1             /* Maximum tx packet per time */
-#define TX_DESC_CNT     0x10            /* Allocated Tx descriptors */
-#define RX_DESC_CNT     0x20            /* Allocated Rx descriptors */
-#define TX_FREE_DESC_CNT (TX_DESC_CNT - 2)	/* Max TX packet count */
-#define TX_WAKE_DESC_CNT (TX_DESC_CNT - 3)	/* TX wakeup count */
-#define DESC_ALL_CNT    (TX_DESC_CNT + RX_DESC_CNT)
-#define TX_BUF_ALLOC    0x600
-#define RX_ALLOC_SIZE   0x620
-#define DM910X_RESET    1
-#define CR0_DEFAULT     0x00E00000      /* TX & RX burst mode */
-#define CR6_DEFAULT     0x00080000      /* HD */
-#define CR7_DEFAULT     0x180c1
-#define CR15_DEFAULT    0x06            /* TxJabber RxWatchdog */
-#define TDES0_ERR_MASK  0x4302          /* TXJT, LC, EC, FUE */
-#define MAX_PACKET_SIZE 1514
-#define DMFE_MAX_MULTICAST 14
-#define RX_COPY_SIZE	100
-#define MAX_CHECK_PACKET 0x8000
-#define DM9801_NOISE_FLOOR 8
-#define DM9802_NOISE_FLOOR 5
-
-#define DMFE_WOL_LINKCHANGE	0x20000000
-#define DMFE_WOL_SAMPLEPACKET	0x10000000
-#define DMFE_WOL_MAGICPACKET	0x08000000
-
-
-#define DMFE_10MHF      0
-#define DMFE_100MHF     1
-#define DMFE_10MFD      4
-#define DMFE_100MFD     5
-#define DMFE_AUTO       8
-#define DMFE_1M_HPNA    0x10
-
-#define DMFE_TXTH_72	0x400000	/* TX TH 72 byte */
-#define DMFE_TXTH_96	0x404000	/* TX TH 96 byte */
-#define DMFE_TXTH_128	0x0000		/* TX TH 128 byte */
-#define DMFE_TXTH_256	0x4000		/* TX TH 256 byte */
-#define DMFE_TXTH_512	0x8000		/* TX TH 512 byte */
-#define DMFE_TXTH_1K	0xC000		/* TX TH 1K  byte */
-
-#define DMFE_TIMER_WUT  (jiffies + HZ * 1)/* timer wakeup time : 1 second */
-#define DMFE_TX_TIMEOUT ((3*HZ)/2)	/* tx packet time-out time 1.5 s" */
-#define DMFE_TX_KICK 	(HZ/2)	/* tx packet Kick-out time 0.5 s" */
-
-#define DMFE_DBUG(dbug_now, msg, value) \
-	do { \
- 		if (dmfe_debug || (dbug_now)) \
-			printk(KERN_ERR DRV_NAME ": %s %lx\n",\
- 				(msg), (long) (value)); \
-	} while (0)
-
-#define SHOW_MEDIA_TYPE(mode) \
-	printk (KERN_INFO DRV_NAME ": Change Speed to %sMhz %s duplex\n" , \
-		(mode & 1) ? "100":"10", (mode & 4) ? "full":"half");
-
-
-/* CR9 definition: SROM/MII */
-#define CR9_SROM_READ   0x4800
-#define CR9_SRCS        0x1
-#define CR9_SRCLK       0x2
-#define CR9_CRDOUT      0x8
-#define SROM_DATA_0     0x0
-#define SROM_DATA_1     0x4
-#define PHY_DATA_1      0x20000
-#define PHY_DATA_0      0x00000
-#define MDCLKH          0x10000
-
-#define PHY_POWER_DOWN	0x800
-
-#define SROM_V41_CODE   0x14
-
-#define SROM_CLK_WRITE(data, ioaddr) \
-	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
-	udelay(5); \
-	outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr); \
-	udelay(5); \
-	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
-	udelay(5);
-
-#define __CHK_IO_SIZE(pci_id, dev_rev) \
- (( ((pci_id)==PCI_DM9132_ID) || ((dev_rev) >= 0x30) ) ? \
-	DM9102A_IO_SIZE: DM9102_IO_SIZE)
-
-#define CHK_IO_SIZE(pci_dev) \
-	(__CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_dev)->vendor, \
-	(pci_dev)->revision))
-
-/* Sten Check */
-#define DEVICE net_device
-
-/* Structure/enum declaration ------------------------------- */
-struct tx_desc {
-        __le32 tdes0, tdes1, tdes2, tdes3; /* Data for the card */
-        char *tx_buf_ptr;               /* Data for us */
-        struct tx_desc *next_tx_desc;
-} __attribute__(( aligned(32) ));
-
-struct rx_desc {
-	__le32 rdes0, rdes1, rdes2, rdes3; /* Data for the card */
-	struct sk_buff *rx_skb_ptr;	/* Data for us */
-	struct rx_desc *next_rx_desc;
-} __attribute__(( aligned(32) ));
-
-struct dmfe_board_info {
-	u32 chip_id;			/* Chip vendor/Device ID */
-	u8 chip_revision;		/* Chip revision */
-	struct DEVICE *next_dev;	/* next device */
-	struct pci_dev *pdev;		/* PCI device */
-	spinlock_t lock;
-
-	long ioaddr;			/* I/O base address */
-	u32 cr0_data;
-	u32 cr5_data;
-	u32 cr6_data;
-	u32 cr7_data;
-	u32 cr15_data;
-
-	/* pointer for memory physical address */
-	dma_addr_t buf_pool_dma_ptr;	/* Tx buffer pool memory */
-	dma_addr_t buf_pool_dma_start;	/* Tx buffer pool align dword */
-	dma_addr_t desc_pool_dma_ptr;	/* descriptor pool memory */
-	dma_addr_t first_tx_desc_dma;
-	dma_addr_t first_rx_desc_dma;
-
-	/* descriptor pointer */
-	unsigned char *buf_pool_ptr;	/* Tx buffer pool memory */
-	unsigned char *buf_pool_start;	/* Tx buffer pool align dword */
-	unsigned char *desc_pool_ptr;	/* descriptor pool memory */
-	struct tx_desc *first_tx_desc;
-	struct tx_desc *tx_insert_ptr;
-	struct tx_desc *tx_remove_ptr;
-	struct rx_desc *first_rx_desc;
-	struct rx_desc *rx_insert_ptr;
-	struct rx_desc *rx_ready_ptr;	/* packet come pointer */
-	unsigned long tx_packet_cnt;	/* transmitted packet count */
-	unsigned long tx_queue_cnt;	/* wait to send packet count */
-	unsigned long rx_avail_cnt;	/* available rx descriptor count */
-	unsigned long interval_rx_cnt;	/* rx packet count a callback time */
-
-	u16 HPNA_command;		/* For HPNA register 16 */
-	u16 HPNA_timer;			/* For HPNA remote device check */
-	u16 dbug_cnt;
-	u16 NIC_capability;		/* NIC media capability */
-	u16 PHY_reg4;			/* Saved Phyxcer register 4 value */
-
-	u8 HPNA_present;		/* 0:none, 1:DM9801, 2:DM9802 */
-	u8 chip_type;			/* Keep DM9102A chip type */
-	u8 media_mode;			/* user specify media mode */
-	u8 op_mode;			/* real work media mode */
-	u8 phy_addr;
-	u8 wait_reset;			/* Hardware failed, need to reset */
-	u8 dm910x_chk_mode;		/* Operating mode check */
-	u8 first_in_callback;		/* Flag to record state */
-	u8 wol_mode;			/* user WOL settings */
-	struct timer_list timer;
-
-	/* Driver defined statistic counter */
-	unsigned long tx_fifo_underrun;
-	unsigned long tx_loss_carrier;
-	unsigned long tx_no_carrier;
-	unsigned long tx_late_collision;
-	unsigned long tx_excessive_collision;
-	unsigned long tx_jabber_timeout;
-	unsigned long reset_count;
-	unsigned long reset_cr8;
-	unsigned long reset_fatal;
-	unsigned long reset_TXtimeout;
-
-	/* NIC SROM data */
-	unsigned char srom[128];
-};
-
-enum dmfe_offsets {
-	DCR0 = 0x00, DCR1 = 0x08, DCR2 = 0x10, DCR3 = 0x18, DCR4 = 0x20,
-	DCR5 = 0x28, DCR6 = 0x30, DCR7 = 0x38, DCR8 = 0x40, DCR9 = 0x48,
-	DCR10 = 0x50, DCR11 = 0x58, DCR12 = 0x60, DCR13 = 0x68, DCR14 = 0x70,
-	DCR15 = 0x78
-};
-
-enum dmfe_CR6_bits {
-	CR6_RXSC = 0x2, CR6_PBF = 0x8, CR6_PM = 0x40, CR6_PAM = 0x80,
-	CR6_FDM = 0x200, CR6_TXSC = 0x2000, CR6_STI = 0x100000,
-	CR6_SFT = 0x200000, CR6_RXA = 0x40000000, CR6_NO_PURGE = 0x20000000
-};
-
-/* Global variable declaration ----------------------------- */
 static int __devinitdata printed_version;
 static const char version[] __devinitconst =
 	KERN_INFO DRV_NAME ": Davicom DM9xxx net driver, version "
@@ -313,251 +115,11 @@ static u8 SF_mode;		/* Special Function: 1:VLAN, 2:RX Flow Control
 				   4: TX pause packet */
 
 
-/* function declaration ------------------------------------- */
-static int dmfe_open(struct DEVICE *);
-static netdev_tx_t dmfe_start_xmit(struct sk_buff *, struct DEVICE *);
-static int dmfe_stop(struct DEVICE *);
-static void dmfe_set_filter_mode(struct DEVICE *);
-static const struct ethtool_ops netdev_ethtool_ops;
-static u16 read_srom_word(long ,int);
-static irqreturn_t dmfe_interrupt(int , void *);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static void poll_dmfe (struct net_device *dev);
-#endif
-static void dmfe_descriptor_init(struct dmfe_board_info *, unsigned long);
-static void allocate_rx_buffer(struct dmfe_board_info *);
-static void update_cr6(u32, unsigned long);
-static void send_filter_frame(struct DEVICE * ,int);
-static void dm9132_id_table(struct DEVICE * ,int);
-static u16 phy_read(unsigned long, u8, u8, u32);
-static void phy_write(unsigned long, u8, u8, u16, u32);
-static void phy_write_1bit(unsigned long, u32);
-static u16 phy_read_1bit(unsigned long);
-static u8 dmfe_sense_speed(struct dmfe_board_info *);
-static void dmfe_process_mode(struct dmfe_board_info *);
-static void dmfe_timer(unsigned long);
-static inline u32 cal_CRC(unsigned char *, unsigned int, u8);
-static void dmfe_rx_packet(struct DEVICE *, struct dmfe_board_info *);
-static void dmfe_free_tx_pkt(struct DEVICE *, struct dmfe_board_info *);
-static void dmfe_reuse_skb(struct dmfe_board_info *, struct sk_buff *);
-static void dmfe_dynamic_reset(struct DEVICE *);
-static void dmfe_free_rxbuffer(struct dmfe_board_info *);
-static void dmfe_init_dm910x(struct DEVICE *);
-static void dmfe_parse_srom(struct dmfe_board_info *);
-static void dmfe_program_DM9801(struct dmfe_board_info *, int);
-static void dmfe_program_DM9802(struct dmfe_board_info *);
-static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * );
-static void dmfe_set_phyxcer(struct dmfe_board_info *);
-
-/* DM910X network board routine ---------------------------- */
-
-static const struct net_device_ops netdev_ops = {
-	.ndo_open 		= dmfe_open,
-	.ndo_stop		= dmfe_stop,
-	.ndo_start_xmit		= dmfe_start_xmit,
-	.ndo_set_multicast_list = dmfe_set_filter_mode,
-	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_validate_addr	= eth_validate_addr,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= poll_dmfe,
-#endif
-};
-
 /*
- *	Search DM910X board ,allocate space and register it
+ * Open routine, called on first access to the device
  */
 
-static int __devinit dmfe_init_one (struct pci_dev *pdev,
-				    const struct pci_device_id *ent)
-{
-	struct dmfe_board_info *db;	/* board information structure */
-	struct net_device *dev;
-	u32 pci_pmr;
-	int i, err;
-
-	DMFE_DBUG(0, "dmfe_init_one()", 0);
-
-	if (!printed_version++)
-		printk(version);
-
-	/*
-	 *	SPARC on-board DM910x chips should be handled by the main
-	 *	tulip driver, except for early DM9100s.
-	 */
-#ifdef CONFIG_TULIP_DM910X
-	if ((ent->driver_data == PCI_DM9100_ID && pdev->revision >= 0x30) ||
-	    ent->driver_data == PCI_DM9102_ID) {
-		struct device_node *dp = pci_device_to_OF_node(pdev);
-
-		if (dp && of_get_property(dp, "local-mac-address", NULL)) {
-			printk(KERN_INFO DRV_NAME
-			       ": skipping on-board DM910x (use tulip)\n");
-			return -ENODEV;
-		}
-	}
-#endif
-
-	/* Init network device */
-	dev = alloc_etherdev(sizeof(*db));
-	if (dev == NULL)
-		return -ENOMEM;
-	SET_NETDEV_DEV(dev, &pdev->dev);
-
-	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		printk(KERN_WARNING DRV_NAME
-			": 32-bit PCI DMA not available.\n");
-		err = -ENODEV;
-		goto err_out_free;
-	}
-
-	/* Enable Master/IO access, Disable memory access */
-	err = pci_enable_device(pdev);
-	if (err)
-		goto err_out_free;
-
-	if (!pci_resource_start(pdev, 0)) {
-		printk(KERN_ERR DRV_NAME ": I/O base is zero\n");
-		err = -ENODEV;
-		goto err_out_disable;
-	}
-
-	if (pci_resource_len(pdev, 0) < (CHK_IO_SIZE(pdev)) ) {
-		printk(KERN_ERR DRV_NAME ": Allocated I/O size too small\n");
-		err = -ENODEV;
-		goto err_out_disable;
-	}
-
-#if 0	/* pci_{enable_device,set_master} sets minimum latency for us now */
-
-	/* Set Latency Timer 80h */
-	/* FIXME: setting values > 32 breaks some SiS 559x stuff.
-	   Need a PCI quirk.. */
-
-	pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0x80);
-#endif
-
-	if (pci_request_regions(pdev, DRV_NAME)) {
-		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
-		err = -ENODEV;
-		goto err_out_disable;
-	}
-
-	/* Init system & device */
-	db = netdev_priv(dev);
-
-	/* Allocate Tx/Rx descriptor memory */
-	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) *
-			DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
-	if (!db->desc_pool_ptr)
-		goto err_out_res;
-
-	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC *
-			TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
-	if (!db->buf_pool_ptr)
-		goto err_out_free_desc;
-
-	db->first_tx_desc = (struct tx_desc *) db->desc_pool_ptr;
-	db->first_tx_desc_dma = db->desc_pool_dma_ptr;
-	db->buf_pool_start = db->buf_pool_ptr;
-	db->buf_pool_dma_start = db->buf_pool_dma_ptr;
-
-	db->chip_id = ent->driver_data;
-	db->ioaddr = pci_resource_start(pdev, 0);
-	db->chip_revision = pdev->revision;
-	db->wol_mode = 0;
-
-	db->pdev = pdev;
-
-	dev->base_addr = db->ioaddr;
-	dev->irq = pdev->irq;
-	pci_set_drvdata(pdev, dev);
-	dev->netdev_ops = &netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
-	netif_carrier_off(dev);
-	spin_lock_init(&db->lock);
-
-	pci_read_config_dword(pdev, 0x50, &pci_pmr);
-	pci_pmr &= 0x70000;
-	if ( (pci_pmr == 0x10000) && (db->chip_revision == 0x31) )
-		db->chip_type = 1;	/* DM9102A E3 */
-	else
-		db->chip_type = 0;
-
-	/* read 64 word srom data */
-	for (i = 0; i < 64; i++)
-		((__le16 *) db->srom)[i] =
-			cpu_to_le16(read_srom_word(db->ioaddr, i));
-
-	/* Set Node address */
-	for (i = 0; i < 6; i++)
-		dev->dev_addr[i] = db->srom[20 + i];
-
-	err = register_netdev (dev);
-	if (err)
-		goto err_out_free_buf;
-
-	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, %pM, irq %d.\n",
-	       dev->name,
-	       ent->driver_data >> 16,
-	       pci_name(pdev),
-	       dev->dev_addr,
-	       dev->irq);
-
-	pci_set_master(pdev);
-
-	return 0;
-
-err_out_free_buf:
-	pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
-			    db->buf_pool_ptr, db->buf_pool_dma_ptr);
-err_out_free_desc:
-	pci_free_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20,
-			    db->desc_pool_ptr, db->desc_pool_dma_ptr);
-err_out_res:
-	pci_release_regions(pdev);
-err_out_disable:
-	pci_disable_device(pdev);
-err_out_free:
-	pci_set_drvdata(pdev, NULL);
-	free_netdev(dev);
-
-	return err;
-}
-
-
-static void __devexit dmfe_remove_one (struct pci_dev *pdev)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct dmfe_board_info *db = netdev_priv(dev);
-
-	DMFE_DBUG(0, "dmfe_remove_one()", 0);
-
- 	if (dev) {
-
-		unregister_netdev(dev);
-
-		pci_free_consistent(db->pdev, sizeof(struct tx_desc) *
-					DESC_ALL_CNT + 0x20, db->desc_pool_ptr,
- 					db->desc_pool_dma_ptr);
-		pci_free_consistent(db->pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
-					db->buf_pool_ptr, db->buf_pool_dma_ptr);
-		pci_release_regions(pdev);
-		free_netdev(dev);	/* free board information */
-
-		pci_set_drvdata(pdev, NULL);
-	}
-
-	DMFE_DBUG(0, "dmfe_remove_one() exit", 0);
-}
-
-
-/*
- *	Open the interface.
- *	The interface is opened whenever "ifconfig" actives it.
- */
-
-static int dmfe_open(struct DEVICE *dev)
+static int dmfe_open(struct net_device *dev)
 {
 	int ret;
 	struct dmfe_board_info *db = netdev_priv(dev);
@@ -581,19 +143,19 @@ static int dmfe_open(struct DEVICE *dev)
 	db->PHY_reg4 = 0x1e0;
 
 	/* CR6 operation mode decision */
-	if ( !chkmode || (db->chip_id == PCI_DM9132_ID) ||
-		(db->chip_revision >= 0x30) ) {
-    		db->cr6_data |= DMFE_TXTH_256;
+	if (!chkmode || (db->chip_id == PCI_DM9132_ID) ||
+		(db->chip_revision >= 0x30)) {
+		db->cr6_data |= DMFE_TXTH_256;
 		db->cr0_data = CR0_DEFAULT;
-		db->dm910x_chk_mode=4;		/* Enter the normal mode */
- 	} else {
+		db->dm910x_chk_mode = 4;	/* Enter the normal mode */
+	} else {
 		db->cr6_data |= CR6_SFT;	/* Store & Forward mode */
 		db->cr0_data = 0;
 		db->dm910x_chk_mode = 1;	/* Enter the check mode */
 	}
 
 	/* Initilize DM910X board */
-	dmfe_init_dm910x(dev);
+	dmfe_hardware_init(dev);
 
 	/* Active System Interface */
 	netif_wake_queue(dev);
@@ -609,6 +171,40 @@ static int dmfe_open(struct DEVICE *dev)
 }
 
 
+/*
+ *	Stop the interface.
+ *	The interface is stopped when it is brought.
+ */
+
+static int dmfe_stop(struct net_device *dev)
+{
+	struct dmfe_board_info *db = netdev_priv(dev);
+	unsigned long ioaddr = dev->base_addr;
+
+	DMFE_DBUG(0, "dmfe_stop", 0);
+
+	/* disable system */
+	netif_stop_queue(dev);
+
+	/* deleted timer */
+	del_timer_sync(&db->timer);
+
+	/* Reset & stop DM910X board */
+	outl(DM910X_RESET, ioaddr + DCR0);
+	udelay(5);
+	phy_write(db->ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
+
+	/* free interrupt */
+	free_irq(dev->irq, dev);
+
+	/* free allocated rx buffer */
+	dmfe_free_rxbuffer(db);
+
+	return 0;
+}
+
+
+
 /*	Initilize DM910X board
  *	Reset DM910X board
  *	Initilize TX/Rx descriptor chain structure
@@ -616,12 +212,12 @@ static int dmfe_open(struct DEVICE *dev)
  *	Enable Tx/Rx machine
  */
 
-static void dmfe_init_dm910x(struct DEVICE *dev)
+static void dmfe_hardware_init(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = db->ioaddr;
 
-	DMFE_DBUG(0, "dmfe_init_dm910x()", 0);
+	DMFE_DBUG(0, "dmfe_hardware_init()", 0);
 
 	/* Reset DM910x MAC controller */
 	outl(DM910X_RESET, ioaddr + DCR0);	/* RESET MAC */
@@ -645,24 +241,24 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 	outl(0x0, ioaddr + DCR12);	/* Clear RESET signal */
 
 	/* Process Phyxcer Media Mode */
-	if ( !(db->media_mode & 0x10) )	/* Force 1M mode */
+	if (!(db->media_mode & 0x10))	/* Force 1M mode */
 		dmfe_set_phyxcer(db);
 
 	/* Media Mode Process */
-	if ( !(db->media_mode & DMFE_AUTO) )
+	if (!(db->media_mode & DMFE_AUTO))
 		db->op_mode = db->media_mode; 	/* Force Mode */
 
 	/* Initiliaze Transmit/Receive decriptor and CR3/4 */
-	dmfe_descriptor_init(db, ioaddr);
+	dmfe_descriptor_init(db);
 
 	/* Init CR6 to program DM910x operation */
-	update_cr6(db->cr6_data, ioaddr);
+	dmfe_update_cr6(db->cr6_data, ioaddr);
 
 	/* Send setup frame */
 	if (db->chip_id == PCI_DM9132_ID)
 		dm9132_id_table(dev, dev->mc_count);	/* DM9132 */
 	else
-		send_filter_frame(dev, dev->mc_count);	/* DM9102/DM9102A */
+		dmfe_send_filter_frame(dev, dev->mc_count); /* DM9102/DM9102A */
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
@@ -673,7 +269,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 
 	/* Enable DM910X Tx/Rx function */
 	db->cr6_data |= CR6_RXSC | CR6_TXSC | 0x40000;
-	update_cr6(db->cr6_data, ioaddr);
+	dmfe_update_cr6(db->cr6_data, ioaddr);
 }
 
 
@@ -683,7 +279,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
  */
 
 static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
-					 struct DEVICE *dev)
+					 struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	struct tx_desc *txptr;
@@ -723,7 +319,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 	db->tx_insert_ptr = txptr->next_tx_desc;
 
 	/* Transmit Packet Process */
-	if ( (!db->tx_queue_cnt) && (db->tx_packet_cnt < TX_MAX_SEND_CNT) ) {
+	if ((!db->tx_queue_cnt) && (db->tx_packet_cnt < TX_MAX_SEND_CNT)) {
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
 		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
@@ -734,7 +330,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 	}
 
 	/* Tx resource check */
-	if ( db->tx_queue_cnt < TX_FREE_DESC_CNT )
+	if (db->tx_queue_cnt < TX_FREE_DESC_CNT)
 		netif_wake_queue(dev);
 
 	/* Restore CR7 to enable interrupt */
@@ -749,56 +345,13 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 
 
 /*
- *	Stop the interface.
- *	The interface is stopped when it is brought.
- */
-
-static int dmfe_stop(struct DEVICE *dev)
-{
-	struct dmfe_board_info *db = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
-
-	DMFE_DBUG(0, "dmfe_stop", 0);
-
-	/* disable system */
-	netif_stop_queue(dev);
-
-	/* deleted timer */
-	del_timer_sync(&db->timer);
-
-	/* Reset & stop DM910X board */
-	outl(DM910X_RESET, ioaddr + DCR0);
-	udelay(5);
-	phy_write(db->ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
-
-	/* free interrupt */
-	free_irq(dev->irq, dev);
-
-	/* free allocated rx buffer */
-	dmfe_free_rxbuffer(db);
-
-#if 0
-	/* show statistic counter */
-	printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx"
-		" LOC:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
-		db->tx_fifo_underrun, db->tx_excessive_collision,
-		db->tx_late_collision, db->tx_no_carrier, db->tx_loss_carrier,
-		db->tx_jabber_timeout, db->reset_count, db->reset_cr8,
-		db->reset_fatal, db->reset_TXtimeout);
-#endif
-
-	return 0;
-}
-
-
-/*
  *	DM9102 insterrupt handler
  *	receive the packet to upper layer, free the transmitted packet
  */
 
 static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 {
-	struct DEVICE *dev = dev_id;
+	struct net_device *dev = dev_id;
 	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -810,7 +363,7 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 	/* Got DM910X status */
 	db->cr5_data = inl(ioaddr + DCR5);
 	outl(db->cr5_data, ioaddr + DCR5);
-	if ( !(db->cr5_data & 0xc1) ) {
+	if (!(db->cr5_data & 0xc1)) {
 		spin_unlock_irqrestore(&db->lock, flags);
 		return IRQ_HANDLED;
 	}
@@ -829,22 +382,22 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 	}
 
 	 /* Received the coming packet */
-	if ( (db->cr5_data & 0x40) && db->rx_avail_cnt )
+	if ((db->cr5_data & 0x40) && db->rx_avail_cnt)
 		dmfe_rx_packet(dev, db);
 
 	/* reallocate rx descriptor buffer */
-	if (db->rx_avail_cnt<RX_DESC_CNT)
-		allocate_rx_buffer(db);
+	if (db->rx_avail_cnt < RX_DESC_CNT)
+		dmfe_allocate_rx_buffer(db);
 
 	/* Free the transmitted descriptor */
-	if ( db->cr5_data & 0x01)
+	if (db->cr5_data & 0x01)
 		dmfe_free_tx_pkt(dev, db);
 
 	/* Mode Check */
 	if (db->dm910x_chk_mode & 0x2) {
 		db->dm910x_chk_mode = 0x4;
 		db->cr6_data |= 0x100;
-		update_cr6(db->cr6_data, db->ioaddr);
+		dmfe_update_cr6(db->cr6_data, db->ioaddr);
 	}
 
 	/* Restore CR7 to enable interrupt mask */
@@ -862,12 +415,12 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
  * the interrupt routine is executing.
  */
 
-static void poll_dmfe (struct net_device *dev)
+static void dmfe_poll(struct net_device *dev)
 {
 	/* disable_irq here is not very nice, but with the lockless
 	   interrupt handler we have no other choice. */
 	disable_irq(dev->irq);
-	dmfe_interrupt (dev->irq, dev);
+	dmfe_interrupt(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
@@ -876,16 +429,18 @@ static void poll_dmfe (struct net_device *dev)
  *	Free TX resource after TX complete
  */
 
-static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
+static void dmfe_free_tx_pkt(struct net_device *dev,
+					struct dmfe_board_info *db)
 {
 	struct tx_desc *txptr;
 	unsigned long ioaddr = dev->base_addr;
 	u32 tdes0;
 
-	txptr = db->tx_remove_ptr;
-	while(db->tx_packet_cnt) {
+	for (txptr = db->tx_remove_ptr; db->tx_packet_cnt;
+					txptr = txptr->next_tx_desc) {
+
 		tdes0 = le32_to_cpu(txptr->tdes0);
-		/* printk(DRV_NAME ": tdes0=%x\n", tdes0); */
+
 		if (tdes0 & 0x80000000)
 			break;
 
@@ -894,41 +449,43 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 		dev->stats.tx_packets++;
 
 		/* Transmit statistic counter */
-		if ( tdes0 != 0x7fffffff ) {
-			/* printk(DRV_NAME ": tdes0=%x\n", tdes0); */
-			dev->stats.collisions += (tdes0 >> 3) & 0xf;
-			dev->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
-			if (tdes0 & TDES0_ERR_MASK) {
-				dev->stats.tx_errors++;
-
-				if (tdes0 & 0x0002) {	/* UnderRun */
-					db->tx_fifo_underrun++;
-					if ( !(db->cr6_data & CR6_SFT) ) {
-						db->cr6_data = db->cr6_data | CR6_SFT;
-						update_cr6(db->cr6_data, db->ioaddr);
-					}
-				}
-				if (tdes0 & 0x0100)
-					db->tx_excessive_collision++;
-				if (tdes0 & 0x0200)
-					db->tx_late_collision++;
-				if (tdes0 & 0x0400)
-					db->tx_no_carrier++;
-				if (tdes0 & 0x0800)
-					db->tx_loss_carrier++;
-				if (tdes0 & 0x4000)
-					db->tx_jabber_timeout++;
+		if (tdes0 == 0x7fffffff)
+			continue;
+
+		dev->stats.collisions += (tdes0 >> 3) & 0xf;
+		dev->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
+
+		if (!(tdes0 & TDES0_ERR_MASK))
+			continue;
+
+		dev->stats.tx_errors++;
+
+		if (tdes0 & 0x0002) {	/* UnderRun */
+			db->tx_fifo_underrun++;
+
+			if (!(db->cr6_data & CR6_SFT)) {
+				db->cr6_data = db->cr6_data | CR6_SFT;
+				dmfe_update_cr6(db->cr6_data, db->ioaddr);
 			}
 		}
 
-    		txptr = txptr->next_tx_desc;
-	}/* End of while */
+		if (tdes0 & 0x0100)
+			db->tx_excessive_collision++;
+		if (tdes0 & 0x0200)
+			db->tx_late_collision++;
+		if (tdes0 & 0x0400)
+			db->tx_no_carrier++;
+		if (tdes0 & 0x0800)
+			db->tx_loss_carrier++;
+		if (tdes0 & 0x4000)
+			db->tx_jabber_timeout++;
+	}
 
 	/* Update TX remove pointer to next */
 	db->tx_remove_ptr = txptr;
 
 	/* Send the Tx packet in queue */
-	if ( (db->tx_packet_cnt < TX_MAX_SEND_CNT) && db->tx_queue_cnt ) {
+	if ((db->tx_packet_cnt < TX_MAX_SEND_CNT) && db->tx_queue_cnt) {
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
 		db->tx_queue_cnt--;
@@ -937,40 +494,27 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 	}
 
 	/* Resource available check */
-	if ( db->tx_queue_cnt < TX_WAKE_DESC_CNT )
+	if (db->tx_queue_cnt < TX_WAKE_DESC_CNT)
 		netif_wake_queue(dev);	/* Active upper layer, send again */
 }
 
 
 /*
- *	Calculate the CRC valude of the Rx packet
- *	flag = 	1 : return the reverse CRC (for the received packet CRC)
- *		0 : return the normal CRC (for Hash Table index)
- */
-
-static inline u32 cal_CRC(unsigned char * Data, unsigned int Len, u8 flag)
-{
-	u32 crc = crc32(~0, Data, Len);
-	if (flag) crc = ~crc;
-	return crc;
-}
-
-
-/*
  *	Receive the come packet and pass to upper layer
  */
 
-static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
+static void dmfe_rx_packet(struct net_device *dev, struct dmfe_board_info *db)
 {
 	struct rx_desc *rxptr;
 	struct sk_buff *skb, *newskb;
 	int rxlen;
 	u32 rdes0;
 
-	rxptr = db->rx_ready_ptr;
-
-	while(db->rx_avail_cnt) {
+	for (rxptr = db->rx_ready_ptr; db->rx_avail_cnt;
+					rxptr = rxptr->next_rx_desc) {
 		rdes0 = le32_to_cpu(rxptr->rdes0);
+
+
 		if (rdes0 & 0x80000000)	/* packet owner check */
 			break;
 
@@ -980,71 +524,75 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 		pci_unmap_single(db->pdev, le32_to_cpu(rxptr->rdes2),
 				 RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
 
-		if ( (rdes0 & 0x300) != 0x300) {
-			/* A packet without First/Last flag */
-			/* reuse this SKB */
+
+		/* A packet without First/Last flag */
+		/* reuse this SKB */
+		if ((rdes0 & 0x300) != 0x300) {
 			DMFE_DBUG(0, "Reuse SK buffer, rdes0", rdes0);
 			dmfe_reuse_skb(db, rxptr->rx_skb_ptr);
-		} else {
-			/* A packet with First/Last flag */
-			rxlen = ( (rdes0 >> 16) & 0x3fff) - 4;
-
-			/* error summary bit check */
-			if (rdes0 & 0x8000) {
-				/* This is a error packet */
-				//printk(DRV_NAME ": rdes0: %lx\n", rdes0);
-				dev->stats.rx_errors++;
-				if (rdes0 & 1)
-					dev->stats.rx_fifo_errors++;
-				if (rdes0 & 2)
-					dev->stats.rx_crc_errors++;
-				if (rdes0 & 0x80)
-					dev->stats.rx_length_errors++;
-			}
+			continue;
+		}
+
+		/* A packet with First/Last flag */
+		rxlen = ((rdes0 >> 16) & 0x3fff) - 4;
 
-			if ( !(rdes0 & 0x8000) ||
-				((db->cr6_data & CR6_PM) && (rxlen>6)) ) {
-				skb = rxptr->rx_skb_ptr;
-
-				/* Received Packet CRC check need or not */
-				if ( (db->dm910x_chk_mode & 1) &&
-					(cal_CRC(skb->data, rxlen, 1) !=
-					(*(u32 *) (skb->data+rxlen) ))) { /* FIXME (?) */
-					/* Found a error received packet */
-					dmfe_reuse_skb(db, rxptr->rx_skb_ptr);
-					db->dm910x_chk_mode = 3;
-				} else {
-					/* Good packet, send to upper layer */
-					/* Shorst packet used new SKB */
-					if ((rxlen < RX_COPY_SIZE) &&
-						((newskb = dev_alloc_skb(rxlen + 2))
-						!= NULL)) {
-
-						skb = newskb;
-						/* size less than COPY_SIZE, allocate a rxlen SKB */
-						skb_reserve(skb, 2); /* 16byte align */
-						skb_copy_from_linear_data(rxptr->rx_skb_ptr,
-							  skb_put(skb, rxlen),
-									  rxlen);
-						dmfe_reuse_skb(db, rxptr->rx_skb_ptr);
-					} else
-						skb_put(skb, rxlen);
-
-					skb->protocol = eth_type_trans(skb, dev);
-					netif_rx(skb);
-					dev->stats.rx_packets++;
-					dev->stats.rx_bytes += rxlen;
-				}
-			} else {
-				/* Reuse SKB buffer when the packet is error */
+
+		/* This is a error packet */
+		if (rdes0 & 0x8000) {
+			dev->stats.rx_errors++;
+			if (rdes0 & 1)
+				dev->stats.rx_fifo_errors++;
+			if (rdes0 & 2)
+				dev->stats.rx_crc_errors++;
+			if (rdes0 & 0x80)
+				dev->stats.rx_length_errors++;
+
+			if (!(db->cr6_data & CR6_PM) || rxlen <= 6) {
 				DMFE_DBUG(0, "Reuse SK buffer, rdes0", rdes0);
 				dmfe_reuse_skb(db, rxptr->rx_skb_ptr);
 			}
+			continue;
 		}
 
-		rxptr = rxptr->next_rx_desc;
-	}
 
+		/* Received Packet CRC check need or not */
+		if (db->dm910x_chk_mode & 1) {
+
+			/* FIXME (?) */
+			if (cal_CRC(skb->data, rxlen, 1)
+				!= (*(u32 *) (skb->data+rxlen))) {
+				/* Found a error received packet */
+				dmfe_reuse_skb(db, rxptr->rx_skb_ptr);
+				db->dm910x_chk_mode = 3;
+			}
+			continue;
+		}
+
+		skb = rxptr->rx_skb_ptr;
+
+		/* Good packet, send to upper layer */
+		/* Shorst packet used new SKB */
+		if (rxlen < RX_COPY_SIZE)
+			newskb = dev_alloc_skb(rxlen + 2);
+
+
+		if (rxlen < RX_COPY_SIZE && newskb) {
+
+			skb = newskb;
+			/* size less than COPY_SIZE, allocate a rxlen SKB */
+			skb_reserve(skb, 2); /* 16byte align */
+			skb_copy_from_linear_data(rxptr->rx_skb_ptr,
+				  skb_put(skb, rxlen),
+						  rxlen);
+			dmfe_reuse_skb(db, rxptr->rx_skb_ptr);
+		} else
+			skb_put(skb, rxlen);
+
+		skb->protocol = eth_type_trans(skb, dev);
+		netif_rx(skb);
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += rxlen;
+	}
 	db->rx_ready_ptr = rxptr;
 }
 
@@ -1052,7 +600,7 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
  * Set DM910X multicast address
  */
 
-static void dmfe_set_filter_mode(struct DEVICE * dev)
+static void dmfe_set_filter_mode(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long flags;
@@ -1063,7 +611,7 @@ static void dmfe_set_filter_mode(struct DEVICE * dev)
 	if (dev->flags & IFF_PROMISC) {
 		DMFE_DBUG(0, "Enable PROM Mode", 0);
 		db->cr6_data |= CR6_PM | CR6_PBF;
-		update_cr6(db->cr6_data, db->ioaddr);
+		dmfe_update_cr6(db->cr6_data, db->ioaddr);
 		spin_unlock_irqrestore(&db->lock, flags);
 		return;
 	}
@@ -1080,60 +628,11 @@ static void dmfe_set_filter_mode(struct DEVICE * dev)
 	if (db->chip_id == PCI_DM9132_ID)
 		dm9132_id_table(dev, dev->mc_count);	/* DM9132 */
 	else
-		send_filter_frame(dev, dev->mc_count); 	/* DM9102/DM9102A */
+		dmfe_send_filter_frame(dev, dev->mc_count); /* DM9102/DM9102A */
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
 /*
- * 	Ethtool interace
- */
-
-static void dmfe_ethtool_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
-{
-	struct dmfe_board_info *np = netdev_priv(dev);
-
-	strcpy(info->driver, DRV_NAME);
-	strcpy(info->version, DRV_VERSION);
-	if (np->pdev)
-		strcpy(info->bus_info, pci_name(np->pdev));
-	else
-		sprintf(info->bus_info, "EISA 0x%lx %d",
-			dev->base_addr, dev->irq);
-}
-
-static int dmfe_ethtool_set_wol(struct net_device *dev,
-				struct ethtool_wolinfo *wolinfo)
-{
-	struct dmfe_board_info *db = netdev_priv(dev);
-
-	if (wolinfo->wolopts & (WAKE_UCAST | WAKE_MCAST | WAKE_BCAST |
-		   		WAKE_ARP | WAKE_MAGICSECURE))
-		   return -EOPNOTSUPP;
-
-	db->wol_mode = wolinfo->wolopts;
-	return 0;
-}
-
-static void dmfe_ethtool_get_wol(struct net_device *dev,
-				 struct ethtool_wolinfo *wolinfo)
-{
-	struct dmfe_board_info *db = netdev_priv(dev);
-
-	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
-	wolinfo->wolopts = db->wol_mode;
-	return;
-}
-
-
-static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo		= dmfe_ethtool_get_drvinfo,
-	.get_link               = ethtool_op_get_link,
-	.set_wol		= dmfe_ethtool_set_wol,
-	.get_wol		= dmfe_ethtool_get_wol,
-};
-
-/*
  *	A periodic timer routine
  *	Dynamic media sense, allocate Rx buffer...
  */
@@ -1142,9 +641,9 @@ static void dmfe_timer(unsigned long data)
 {
 	u32 tmp_cr8;
 	unsigned char tmp_cr12;
-	struct DEVICE *dev = (struct DEVICE *) data;
+	struct net_device *dev = (struct net_device *) data;
 	struct dmfe_board_info *db = netdev_priv(dev);
- 	unsigned long flags;
+	unsigned long flags;
 
 	int link_ok, link_ok_phy;
 
@@ -1154,13 +653,13 @@ static void dmfe_timer(unsigned long data)
 	/* Media mode process when Link OK before enter this route */
 	if (db->first_in_callback == 0) {
 		db->first_in_callback = 1;
-		if (db->chip_type && (db->chip_id==PCI_DM9102_ID)) {
+		if (db->chip_type && (db->chip_id == PCI_DM9102_ID)) {
 			db->cr6_data &= ~0x40000;
-			update_cr6(db->cr6_data, db->ioaddr);
+			dmfe_update_cr6(db->cr6_data, db->ioaddr);
 			phy_write(db->ioaddr,
 				  db->phy_addr, 0, 0x1000, db->chip_id);
 			db->cr6_data |= 0x40000;
-			update_cr6(db->cr6_data, db->ioaddr);
+			dmfe_update_cr6(db->cr6_data, db->ioaddr);
 			db->timer.expires = DMFE_TIMER_WUT + HZ * 2;
 			add_timer(&db->timer);
 			spin_unlock_irqrestore(&db->lock, flags);
@@ -1168,27 +667,26 @@ static void dmfe_timer(unsigned long data)
 		}
 	}
 
-
 	/* Operating Mode Check */
-	if ( (db->dm910x_chk_mode & 0x1) &&
-		(dev->stats.rx_packets > MAX_CHECK_PACKET) )
+	if ((db->dm910x_chk_mode & 0x1) &&
+		(dev->stats.rx_packets > MAX_CHECK_PACKET))
 		db->dm910x_chk_mode = 0x4;
 
 	/* Dynamic reset DM910X : system error or transmit time-out */
 	tmp_cr8 = inl(db->ioaddr + DCR8);
-	if ( (db->interval_rx_cnt==0) && (tmp_cr8) ) {
+	if ((db->interval_rx_cnt == 0) && (tmp_cr8)) {
 		db->reset_cr8++;
 		db->wait_reset = 1;
 	}
 	db->interval_rx_cnt = 0;
 
 	/* TX polling kick monitor */
-	if ( db->tx_packet_cnt &&
-	     time_after(jiffies, dev->trans_start + DMFE_TX_KICK) ) {
+	if (db->tx_packet_cnt &&
+	     time_after(jiffies, dev->trans_start + DMFE_TX_KICK)) {
 		outl(0x1, dev->base_addr + DCR1);   /* Tx polling again */
 
 		/* TX Timeout */
-		if ( time_after(jiffies, dev->trans_start + DMFE_TX_TIMEOUT) ) {
+		if (time_after(jiffies, dev->trans_start + DMFE_TX_TIMEOUT)) {
 			db->reset_TXtimeout++;
 			db->wait_reset = 1;
 			printk(KERN_WARNING "%s: Tx timeout - resetting\n",
@@ -1213,17 +711,16 @@ static void dmfe_timer(unsigned long data)
 	else
 		tmp_cr12 = inb(db->ioaddr + DCR12);	/* DM9102/DM9102A */
 
-	if ( ((db->chip_id == PCI_DM9102_ID) &&
+	if (((db->chip_id == PCI_DM9102_ID) &&
 		(db->chip_revision == 0x30)) ||
 		((db->chip_id == PCI_DM9132_ID) &&
-		(db->chip_revision == 0x10)) ) {
+		(db->chip_revision == 0x10))) {
 		/* DM9102A Chip */
 		if (tmp_cr12 & 2)
 			link_ok = 0;
 		else
 			link_ok = 1;
-	}
-	else
+	} else
 		/*0x43 is used instead of 0x3 because bit 6 should represent
 			link status of external PHY */
 		link_ok = (tmp_cr12 & 0x43) ? 1 : 0;
@@ -1235,39 +732,39 @@ static void dmfe_timer(unsigned long data)
 	*/
 
 	/* need a dummy read because of PHY's register latch*/
-	phy_read (db->ioaddr, db->phy_addr, 1, db->chip_id);
-	link_ok_phy = (phy_read (db->ioaddr,
+	phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
+	link_ok_phy = (phy_read(db->ioaddr,
 		       db->phy_addr, 1, db->chip_id) & 0x4) ? 1 : 0;
 
 	if (link_ok_phy != link_ok) {
-		DMFE_DBUG (0, "PHY and chip report different link status", 0);
+		DMFE_DBUG(0, "PHY and chip report different link status", 0);
 		link_ok = link_ok | link_ok_phy;
- 	}
+	}
 
-	if ( !link_ok && netif_carrier_ok(dev)) {
+	if (!link_ok && netif_carrier_ok(dev)) {
 		/* Link Failed */
 		DMFE_DBUG(0, "Link Failed", tmp_cr12);
 		netif_carrier_off(dev);
 
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO or force 1M Homerun/Longrun don't need */
-		if ( !(db->media_mode & 0x38) )
+		if (!(db->media_mode & 0x38))
 			phy_write(db->ioaddr, db->phy_addr,
 				  0, 0x1000, db->chip_id);
 
 		/* AUTO mode, if INT phyxcer link failed, select EXT device */
 		if (db->media_mode & DMFE_AUTO) {
 			/* 10/100M link failed, used 1M Home-Net */
-			db->cr6_data|=0x00040000;	/* bit18=1, MII */
-			db->cr6_data&=~0x00000200;	/* bit9=0, HD mode */
-			update_cr6(db->cr6_data, db->ioaddr);
+			db->cr6_data |= 0x00040000;	/* bit18=1, MII */
+			db->cr6_data &= ~0x00000200;	/* bit9=0, HD mode */
+			dmfe_update_cr6(db->cr6_data, db->ioaddr);
 		}
 	} else if (!netif_carrier_ok(dev)) {
 
-		DMFE_DBUG(0, "Link link OK", tmp_cr12);
+		DMFE_DBUG(0, "Link OK", tmp_cr12);
 
 		/* Auto Sense Speed */
-		if ( !(db->media_mode & DMFE_AUTO) || !dmfe_sense_speed(db)) {
+		if (!(db->media_mode & DMFE_AUTO) || !dmfe_sense_speed(db)) {
 			netif_carrier_on(dev);
 			SHOW_MEDIA_TYPE(db->op_mode);
 		}
@@ -1297,7 +794,7 @@ static void dmfe_timer(unsigned long data)
  *	Re-initilize DM910X board
  */
 
-static void dmfe_dynamic_reset(struct DEVICE *dev)
+static void dmfe_dynamic_reset(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 
@@ -1305,7 +802,7 @@ static void dmfe_dynamic_reset(struct DEVICE *dev)
 
 	/* Sopt MAC controller */
 	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);	/* Disable Tx/Rx */
-	update_cr6(db->cr6_data, dev->base_addr);
+	dmfe_update_cr6(db->cr6_data, dev->base_addr);
 	outl(0, dev->base_addr + DCR7);		/* Disable Interrupt */
 	outl(inl(dev->base_addr + DCR5), dev->base_addr + DCR5);
 
@@ -1323,7 +820,7 @@ static void dmfe_dynamic_reset(struct DEVICE *dev)
 	db->wait_reset = 0;
 
 	/* Re-initilize DM910X board */
-	dmfe_init_dm910x(dev);
+	dmfe_hardware_init(dev);
 
 	/* Restart upper layer interface */
 	netif_wake_queue(dev);
@@ -1331,23 +828,6 @@ static void dmfe_dynamic_reset(struct DEVICE *dev)
 
 
 /*
- *	free all allocated rx buffer
- */
-
-static void dmfe_free_rxbuffer(struct dmfe_board_info * db)
-{
-	DMFE_DBUG(0, "dmfe_free_rxbuffer()", 0);
-
-	/* free allocated rx buffer */
-	while (db->rx_avail_cnt) {
-		dev_kfree_skb(db->rx_ready_ptr->rx_skb_ptr);
-		db->rx_ready_ptr = db->rx_ready_ptr->next_rx_desc;
-		db->rx_avail_cnt--;
-	}
-}
-
-
-/*
  *	Reuse the SK buffer
  */
 
@@ -1357,8 +837,8 @@ static void dmfe_reuse_skb(struct dmfe_board_info *db, struct sk_buff * skb)
 
 	if (!(rxptr->rdes0 & cpu_to_le32(0x80000000))) {
 		rxptr->rx_skb_ptr = skb;
-		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev,
-			    skb->data, RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
+		rxptr->rdes2 = cpu_to_le32(pci_map_single(db->pdev,
+			    skb->data, RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE));
 		wmb();
 		rxptr->rdes0 = cpu_to_le32(0x80000000);
 		db->rx_avail_cnt++;
@@ -1373,13 +853,14 @@ static void dmfe_reuse_skb(struct dmfe_board_info *db, struct sk_buff * skb)
  *	Using Chain structure, and allocate Tx/Rx buffer
  */
 
-static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioaddr)
+static void dmfe_descriptor_init(struct dmfe_board_info *db)
 {
 	struct tx_desc *tmp_tx;
 	struct rx_desc *tmp_rx;
 	unsigned char *tmp_buf;
 	dma_addr_t tmp_tx_dma, tmp_rx_dma;
 	dma_addr_t tmp_buf_dma;
+	unsigned long ioaddr = db->ioaddr;
 	int i;
 
 	DMFE_DBUG(0, "dmfe_descriptor_init()", 0);
@@ -1403,7 +884,9 @@ static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioadd
 	tmp_buf = db->buf_pool_start;
 	tmp_buf_dma = db->buf_pool_dma_start;
 	tmp_tx_dma = db->first_tx_desc_dma;
-	for (tmp_tx = db->first_tx_desc, i = 0; i < TX_DESC_CNT; i++, tmp_tx++) {
+	tmp_tx = db->first_tx_desc;
+
+	for (i = 0; i < TX_DESC_CNT ; i++, tmp_tx++) {
 		tmp_tx->tx_buf_ptr = tmp_buf;
 		tmp_tx->tdes0 = cpu_to_le32(0);
 		tmp_tx->tdes1 = cpu_to_le32(0x81000000);	/* IC, chain */
@@ -1418,19 +901,70 @@ static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioadd
 	tmp_tx->next_tx_desc = db->first_tx_desc;
 
 	 /* Init Receive descriptor chain */
-	tmp_rx_dma=db->first_rx_desc_dma;
-	for (tmp_rx = db->first_rx_desc, i = 0; i < RX_DESC_CNT; i++, tmp_rx++) {
+	tmp_rx_dma = db->first_rx_desc_dma;
+	tmp_rx = db->first_rx_desc;
+	for (i = 0; i < RX_DESC_CNT; i++, tmp_rx++) {
 		tmp_rx->rdes0 = cpu_to_le32(0);
 		tmp_rx->rdes1 = cpu_to_le32(0x01000600);
 		tmp_rx_dma += sizeof(struct rx_desc);
 		tmp_rx->rdes3 = cpu_to_le32(tmp_rx_dma);
 		tmp_rx->next_rx_desc = tmp_rx + 1;
 	}
+
 	(--tmp_rx)->rdes3 = cpu_to_le32(db->first_rx_desc_dma);
 	tmp_rx->next_rx_desc = db->first_rx_desc;
 
 	/* pre-allocate Rx buffer */
-	allocate_rx_buffer(db);
+	dmfe_allocate_rx_buffer(db);
+}
+
+/*
+ *	Allocate rx buffer,
+ *	As possible as allocate maxiumn Rx buffer
+ */
+
+static void dmfe_allocate_rx_buffer(struct dmfe_board_info *db)
+{
+	struct rx_desc *rxptr;
+	struct sk_buff *skb;
+
+	rxptr = db->rx_insert_ptr;
+
+	while (db->rx_avail_cnt < RX_DESC_CNT) {
+
+		skb = dev_alloc_skb(RX_ALLOC_SIZE);
+
+		if (!skb)
+			break;
+
+		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
+		rxptr->rdes2 = cpu_to_le32(pci_map_single(db->pdev, skb->data,
+				    RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE));
+		wmb();
+
+		rxptr->rdes0 = cpu_to_le32(0x80000000);
+		rxptr = rxptr->next_rx_desc;
+		db->rx_avail_cnt++;
+	}
+
+	db->rx_insert_ptr = rxptr;
+}
+
+
+/*
+ *	free all allocated rx buffer
+ */
+
+static void dmfe_free_rxbuffer(struct dmfe_board_info *db)
+{
+	DMFE_DBUG(0, "dmfe_free_rxbuffer()", 0);
+
+	/* free allocated rx buffer */
+	while (db->rx_avail_cnt) {
+		dev_kfree_skb(db->rx_ready_ptr->rx_skb_ptr);
+		db->rx_ready_ptr = db->rx_ready_ptr->next_rx_desc;
+		db->rx_avail_cnt--;
+	}
 }
 
 
@@ -1439,7 +973,7 @@ static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioadd
  *	Firstly stop DM910X , then written value and start
  */
 
-static void update_cr6(u32 cr6_data, unsigned long ioaddr)
+static void dmfe_update_cr6(u32 cr6_data, unsigned long ioaddr)
 {
 	u32 cr6_tmp;
 
@@ -1456,10 +990,10 @@ static void update_cr6(u32 cr6_data, unsigned long ioaddr)
  *	This setup frame initilize DM910X address filter mode
 */
 
-static void dm9132_id_table(struct DEVICE *dev, int mc_cnt)
+static void dm9132_id_table(struct net_device *dev, int mc_cnt)
 {
 	struct dev_mc_list *mcptr;
-	u16 * addrptr;
+	u16 *addrptr;
 	unsigned long ioaddr = dev->base_addr+0xc0;		/* ID Table */
 	u32 hash_val;
 	u16 i, hash_table[4];
@@ -1483,8 +1017,9 @@ static void dm9132_id_table(struct DEVICE *dev, int mc_cnt)
 	hash_table[3] = 0x8000;
 
 	/* the multicast address in Hash Table : 64 bits */
-	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
-		hash_val = cal_CRC( (char *) mcptr->dmi_addr, 6, 0) & 0x3f;
+	mcptr = dev->mc_list;
+	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+		hash_val = cal_CRC((char *)mcptr->dmi_addr, 6, 0) & 0x3f;
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
@@ -1499,16 +1034,16 @@ static void dm9132_id_table(struct DEVICE *dev, int mc_cnt)
  *	This setup frame initilize DM910X address filter mode
  */
 
-static void send_filter_frame(struct DEVICE *dev, int mc_cnt)
+static void dmfe_send_filter_frame(struct net_device *dev, int mc_cnt)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	struct dev_mc_list *mcptr;
 	struct tx_desc *txptr;
-	u16 * addrptr;
-	u32 * suptr;
+	u16 *addrptr;
+	u32 *suptr;
 	int i;
 
-	DMFE_DBUG(0, "send_filter_frame()", 0);
+	DMFE_DBUG(0, "dmfe_send_filter_frame()", 0);
 
 	txptr = db->tx_insert_ptr;
 	suptr = (u32 *) txptr->tx_buf_ptr;
@@ -1525,14 +1060,16 @@ static void send_filter_frame(struct DEVICE *dev, int mc_cnt)
 	*suptr++ = 0xffff;
 
 	/* fit the multicast address */
-	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+	mcptr = dev->mc_list;
+
+	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
 		addrptr = (u16 *) mcptr->dmi_addr;
 		*suptr++ = addrptr[0];
 		*suptr++ = addrptr[1];
 		*suptr++ = addrptr[2];
 	}
 
-	for (; i<14; i++) {
+	for (; i < 14; i++) {
 		*suptr++ = 0xffff;
 		*suptr++ = 0xffff;
 		*suptr++ = 0xffff;
@@ -1547,9 +1084,9 @@ static void send_filter_frame(struct DEVICE *dev, int mc_cnt)
 		/* Resource Empty */
 		db->tx_packet_cnt++;
 		txptr->tdes0 = cpu_to_le32(0x80000000);
-		update_cr6(db->cr6_data | 0x2000, dev->base_addr);
+		dmfe_update_cr6(db->cr6_data | 0x2000, dev->base_addr);
 		outl(0x1, dev->base_addr + DCR1);	/* Issue Tx polling */
-		update_cr6(db->cr6_data, dev->base_addr);
+		dmfe_update_cr6(db->cr6_data, dev->base_addr);
 		dev->trans_start = jiffies;
 	} else
 		db->tx_queue_cnt++;	/* Put in TX queue */
@@ -1557,107 +1094,54 @@ static void send_filter_frame(struct DEVICE *dev, int mc_cnt)
 
 
 /*
- *	Allocate rx buffer,
- *	As possible as allocate maxiumn Rx buffer
- */
-
-static void allocate_rx_buffer(struct dmfe_board_info *db)
-{
-	struct rx_desc *rxptr;
-	struct sk_buff *skb;
-
-	rxptr = db->rx_insert_ptr;
-
-	while(db->rx_avail_cnt < RX_DESC_CNT) {
-		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
-			break;
-		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
-		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data,
-				    RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
-		wmb();
-		rxptr->rdes0 = cpu_to_le32(0x80000000);
-		rxptr = rxptr->next_rx_desc;
-		db->rx_avail_cnt++;
-	}
-
-	db->rx_insert_ptr = rxptr;
-}
-
-
-/*
- *	Read one word data from the serial ROM
- */
-
-static u16 read_srom_word(long ioaddr, int offset)
-{
-	int i;
-	u16 srom_data = 0;
-	long cr9_ioaddr = ioaddr + DCR9;
-
-	outl(CR9_SROM_READ, cr9_ioaddr);
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
-
-	/* Send the Read Command 110b */
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_0, cr9_ioaddr);
-
-	/* Send the offset */
-	for (i = 5; i >= 0; i--) {
-		srom_data = (offset & (1 << i)) ? SROM_DATA_1 : SROM_DATA_0;
-		SROM_CLK_WRITE(srom_data, cr9_ioaddr);
-	}
-
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
-
-	for (i = 16; i > 0; i--) {
-		outl(CR9_SROM_READ | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
-		udelay(5);
-		srom_data = (srom_data << 1) |
-				((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
-		outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
-		udelay(5);
-	}
-
-	outl(CR9_SROM_READ, cr9_ioaddr);
-	return srom_data;
-}
-
-
-/*
  *	Auto sense the media mode
  */
 
-static u8 dmfe_sense_speed(struct dmfe_board_info * db)
+static u8 dmfe_sense_speed(struct dmfe_board_info *db)
 {
 	u8 ErrFlag = 0;
 	u16 phy_mode;
 
 	/* CR6 bit18=0, select 10/100M */
-	update_cr6( (db->cr6_data & ~0x40000), db->ioaddr);
+	dmfe_update_cr6((db->cr6_data & ~0x40000), db->ioaddr);
 
 	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
 	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
 
-	if ( (phy_mode & 0x24) == 0x24 ) {
+
+	if ((phy_mode & 0x24) == 0x24) {
+
 		if (db->chip_id == PCI_DM9132_ID)	/* DM9132 */
 			phy_mode = phy_read(db->ioaddr,
 				    db->phy_addr, 7, db->chip_id) & 0xf000;
 		else 				/* DM9102/DM9102A */
 			phy_mode = phy_read(db->ioaddr,
 				    db->phy_addr, 17, db->chip_id) & 0xf000;
+
 		/* printk(DRV_NAME ": Phy_mode %x ",phy_mode); */
+
 		switch (phy_mode) {
-		case 0x1000: db->op_mode = DMFE_10MHF; break;
-		case 0x2000: db->op_mode = DMFE_10MFD; break;
-		case 0x4000: db->op_mode = DMFE_100MHF; break;
-		case 0x8000: db->op_mode = DMFE_100MFD; break;
-		default: db->op_mode = DMFE_10MHF;
+		case 0x1000:
+			db->op_mode = DMFE_10MHF;
+			break;
+		case 0x2000:
+			db->op_mode = DMFE_10MFD;
+			break;
+		case 0x4000:
+			db->op_mode = DMFE_100MHF;
+			break;
+		case 0x8000:
+			db->op_mode = DMFE_100MFD;
+			break;
+		default:
+			db->op_mode = DMFE_10MHF;
 			ErrFlag = 1;
 			break;
 		}
+
 	} else {
 		db->op_mode = DMFE_10MHF;
+
 		DMFE_DBUG(0, "Link Failed :", phy_mode);
 		ErrFlag = 1;
 	}
@@ -1665,7 +1149,6 @@ static u8 dmfe_sense_speed(struct dmfe_board_info * db)
 	return ErrFlag;
 }
 
-
 /*
  *	Set 10/100 phyxcer capability
  *	AUTO mode : phyxcer register4 is NIC capability
@@ -1678,7 +1161,7 @@ static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 
 	/* Select 10/100M phyxcer */
 	db->cr6_data &= ~0x40000;
-	update_cr6(db->cr6_data, db->ioaddr);
+	dmfe_update_cr6(db->cr6_data, db->ioaddr);
 
 	/* DM9009 Chip: Phyxcer reg18 bit12=0 */
 	if (db->chip_id == PCI_DM9009_ID) {
@@ -1696,27 +1179,38 @@ static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 		/* AUTO Mode */
 		phy_reg |= db->PHY_reg4;
 	} else {
+
 		/* Force Mode */
-		switch(db->media_mode) {
-		case DMFE_10MHF: phy_reg |= 0x20; break;
-		case DMFE_10MFD: phy_reg |= 0x40; break;
-		case DMFE_100MHF: phy_reg |= 0x80; break;
-		case DMFE_100MFD: phy_reg |= 0x100; break;
+		switch (db->media_mode) {
+		case DMFE_10MHF:
+			phy_reg |= 0x20;
+			break;
+		case DMFE_10MFD:
+			phy_reg |= 0x40;
+			break;
+		case DMFE_100MHF:
+			phy_reg |= 0x80;
+			break;
+		case DMFE_100MFD:
+			phy_reg |= 0x100;
+			break;
 		}
-		if (db->chip_id == PCI_DM9009_ID) phy_reg &= 0x61;
+
+		if (db->chip_id == PCI_DM9009_ID)
+			phy_reg &= 0x61;
 	}
 
-  	/* Write new capability to Phyxcer Reg4 */
-	if ( !(phy_reg & 0x01e0)) {
-		phy_reg|=db->PHY_reg4;
-		db->media_mode|=DMFE_AUTO;
+	/* Write new capability to Phyxcer Reg4 */
+	if (!(phy_reg & 0x01e0)) {
+		phy_reg |= db->PHY_reg4;
+		db->media_mode |= DMFE_AUTO;
 	}
 	phy_write(db->ioaddr, db->phy_addr, 4, phy_reg, db->chip_id);
 
- 	/* Restart Auto-Negotiation */
-	if ( db->chip_type && (db->chip_id == PCI_DM9102_ID) )
+	/* Restart Auto-Negotiation */
+	if (db->chip_type && (db->chip_id == PCI_DM9102_ID))
 		phy_write(db->ioaddr, db->phy_addr, 0, 0x1800, db->chip_id);
-	if ( !db->chip_type )
+	if (!db->chip_type)
 		phy_write(db->ioaddr, db->phy_addr, 0, 0x1200, db->chip_id);
 }
 
@@ -1744,24 +1238,34 @@ static void dmfe_process_mode(struct dmfe_board_info *db)
 	else
 		db->cr6_data &= ~0x40000;/* Internal 10/100 transciver */
 
-	update_cr6(db->cr6_data, db->ioaddr);
+	dmfe_update_cr6(db->cr6_data, db->ioaddr);
 
 	/* 10/100M phyxcer force mode need */
-	if ( !(db->media_mode & 0x18)) {
-		/* Forece Mode */
+	if (!(db->media_mode & 0x18)) {
+		/* Force Mode */
 		phy_reg = phy_read(db->ioaddr, db->phy_addr, 6, db->chip_id);
-		if ( !(phy_reg & 0x1) ) {
+		if (!(phy_reg & 0x1)) {
 			/* parter without N-Way capability */
 			phy_reg = 0x0;
-			switch(db->op_mode) {
-			case DMFE_10MHF: phy_reg = 0x0; break;
-			case DMFE_10MFD: phy_reg = 0x100; break;
-			case DMFE_100MHF: phy_reg = 0x2000; break;
-			case DMFE_100MFD: phy_reg = 0x2100; break;
+
+			switch (db->op_mode) {
+			case DMFE_10MHF:
+				phy_reg = 0x0;
+				break;
+			case DMFE_10MFD:
+				phy_reg = 0x100;
+				break;
+			case DMFE_100MHF:
+				phy_reg = 0x2000;
+				break;
+			case DMFE_100MFD:
+				phy_reg = 0x2100;
+				break;
 			}
+
 			phy_write(db->ioaddr,
 				  db->phy_addr, 0, phy_reg, db->chip_id);
-       			if ( db->chip_type && (db->chip_id == PCI_DM9102_ID) )
+			if (db->chip_type && (db->chip_id == PCI_DM9102_ID))
 				mdelay(20);
 			phy_write(db->ioaddr,
 				  db->phy_addr, 0, phy_reg, db->chip_id);
@@ -1814,7 +1318,7 @@ static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
 		phy_write_1bit(ioaddr, PHY_DATA_0);
 
 		/* Write a word data to PHY controller */
-		for ( i = 0x8000; i > 0; i >>= 1)
+		for (i = 0x8000; i > 0; i >>= 1)
 			phy_write_1bit(ioaddr,
 				       phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
 	}
@@ -1900,7 +1404,7 @@ static u16 phy_read_1bit(unsigned long ioaddr)
 
 	outl(0x50000, ioaddr);
 	udelay(1);
-	phy_data = ( inl(ioaddr) >> 19 ) & 0x1;
+	phy_data = (inl(ioaddr) >> 19) & 0x1;
 	outl(0x40000, ioaddr);
 	udelay(1);
 
@@ -1909,12 +1413,52 @@ static u16 phy_read_1bit(unsigned long ioaddr)
 
 
 /*
+ *	Read one word data from the serial ROM
+ */
+
+static u16 dmfe_read_srom_word(long ioaddr, int offset)
+{
+	int i;
+	u16 srom_data = 0;
+	long cr9_ioaddr = ioaddr + DCR9;
+
+	outl(CR9_SROM_READ, cr9_ioaddr);
+	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+
+	/* Send the Read Command 110b */
+	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
+	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
+	SROM_CLK_WRITE(SROM_DATA_0, cr9_ioaddr);
+
+	/* Send the offset */
+	for (i = 5; i >= 0; i--) {
+		srom_data = (offset & (1 << i)) ? SROM_DATA_1 : SROM_DATA_0;
+		SROM_CLK_WRITE(srom_data, cr9_ioaddr);
+	}
+
+	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+
+	for (i = 16; i > 0; i--) {
+		outl(CR9_SROM_READ | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
+		udelay(5);
+		srom_data = (srom_data << 1) |
+				((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
+		outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+		udelay(5);
+	}
+
+	outl(CR9_SROM_READ, cr9_ioaddr);
+	return srom_data;
+}
+
+
+/*
  *	Parser SROM and media mode
  */
 
-static void dmfe_parse_srom(struct dmfe_board_info * db)
+static void dmfe_parse_srom(struct dmfe_board_info *db)
 {
-	char * srom = db->srom;
+	char *srom = db->srom;
 	int dmfe_mode, tmp_reg;
 
 	DMFE_DBUG(0, "dmfe_parse_srom() ", 0);
@@ -1923,42 +1467,63 @@ static void dmfe_parse_srom(struct dmfe_board_info * db)
 	db->cr15_data = CR15_DEFAULT;
 
 	/* Check SROM Version */
-	if ( ( (int) srom[18] & 0xff) == SROM_V41_CODE) {
+	if (((int) srom[18] & 0xff) == SROM_V41_CODE) {
 		/* SROM V4.01 */
 		/* Get NIC support media mode */
 		db->NIC_capability = le16_to_cpup((__le16 *) (srom + 34));
 		db->PHY_reg4 = 0;
+
 		for (tmp_reg = 1; tmp_reg < 0x10; tmp_reg <<= 1) {
-			switch( db->NIC_capability & tmp_reg ) {
-			case 0x1: db->PHY_reg4 |= 0x0020; break;
-			case 0x2: db->PHY_reg4 |= 0x0040; break;
-			case 0x4: db->PHY_reg4 |= 0x0080; break;
-			case 0x8: db->PHY_reg4 |= 0x0100; break;
+
+			switch (db->NIC_capability & tmp_reg) {
+			case 0x1:
+				db->PHY_reg4 |= 0x0020;
+				break;
+			case 0x2:
+				db->PHY_reg4 |= 0x0040;
+				break;
+			case 0x4:
+				db->PHY_reg4 |= 0x0080;
+				break;
+			case 0x8:
+				db->PHY_reg4 |= 0x0100;
+				break;
 			}
 		}
 
 		/* Media Mode Force or not check */
 		dmfe_mode = (le32_to_cpup((__le32 *) (srom + 34)) &
 			     le32_to_cpup((__le32 *) (srom + 36)));
-		switch(dmfe_mode) {
-		case 0x4: dmfe_media_mode = DMFE_100MHF; break;	/* 100MHF */
-		case 0x2: dmfe_media_mode = DMFE_10MFD; break;	/* 10MFD */
-		case 0x8: dmfe_media_mode = DMFE_100MFD; break;	/* 100MFD */
-		case 0x100:
-		case 0x200: dmfe_media_mode = DMFE_1M_HPNA; break;/* HomePNA */
+
+		switch (dmfe_mode) {
+
+		case 0x4: /* 100MHF */
+			dmfe_media_mode = DMFE_100MHF;
+			break;
+		case 0x2: /* 10MFD */
+			dmfe_media_mode = DMFE_10MFD;
+			break;
+		case 0x8: /* 100MFD */
+			dmfe_media_mode = DMFE_100MFD;
+			break;
+
+		case 0x100: /* HomePNA */
+		case 0x200:
+			dmfe_media_mode = DMFE_1M_HPNA;
+			break;
 		}
 
 		/* Special Function setting */
 		/* VLAN function */
-		if ( (SF_mode & 0x1) || (srom[43] & 0x80) )
+		if ((SF_mode & 0x1) || (srom[43] & 0x80))
 			db->cr15_data |= 0x40;
 
 		/* Flow Control */
-		if ( (SF_mode & 0x2) || (srom[40] & 0x1) )
+		if ((SF_mode & 0x2) || (srom[40] & 0x1))
 			db->cr15_data |= 0x400;
 
 		/* TX pause packet */
-		if ( (SF_mode & 0x4) || (srom[40] & 0xe) )
+		if ((SF_mode & 0x4) || (srom[40] & 0xe))
 			db->cr15_data |= 0x9800;
 	}
 
@@ -1971,28 +1536,45 @@ static void dmfe_parse_srom(struct dmfe_board_info * db)
 
 	 /* Issue remote command & operation mode */
 	if (HPNA_tx_cmd == 1)
-		switch(HPNA_mode) {	/* Issue Remote Command */
-		case 0: db->HPNA_command |= 0x0904; break;
-		case 1: db->HPNA_command |= 0x0a00; break;
-		case 2: db->HPNA_command |= 0x0506; break;
-		case 3: db->HPNA_command |= 0x0602; break;
+		switch (HPNA_mode) {	/* Issue Remote Command */
+		case 0:
+			db->HPNA_command |= 0x0904;
+			break;
+		case 1:
+			db->HPNA_command |= 0x0a00;
+			break;
+		case 2:
+			db->HPNA_command |= 0x0506;
+			break;
+		case 3:
+			db->HPNA_command |= 0x0602;
+			break;
 		}
 	else
-		switch(HPNA_mode) {	/* Don't Issue */
-		case 0: db->HPNA_command |= 0x0004; break;
-		case 1: db->HPNA_command |= 0x0000; break;
-		case 2: db->HPNA_command |= 0x0006; break;
-		case 3: db->HPNA_command |= 0x0002; break;
+		switch (HPNA_mode) {	/* Don't Issue */
+		case 0:
+			db->HPNA_command |= 0x0004;
+			break;
+		case 1:
+			db->HPNA_command |= 0x0000;
+			break;
+		case 2:
+			db->HPNA_command |= 0x0006;
+			break;
+		case 3:
+			db->HPNA_command |= 0x0002;
+			break;
 		}
 
 	/* Check DM9801 or DM9802 present or not */
 	db->HPNA_present = 0;
-	update_cr6(db->cr6_data|0x40000, db->ioaddr);
+	dmfe_update_cr6(db->cr6_data|0x40000, db->ioaddr);
 	tmp_reg = phy_read(db->ioaddr, db->phy_addr, 3, db->chip_id);
-	if ( ( tmp_reg & 0xfff0 ) == 0xb900 ) {
+	if ((tmp_reg & 0xfff0) == 0xb900) {
 		/* DM9801 or DM9802 present */
 		db->HPNA_timer = 8;
-		if ( phy_read(db->ioaddr, db->phy_addr, 31, db->chip_id) == 0x4404) {
+		if (phy_read(db->ioaddr, db->phy_addr, 31,
+						db->chip_id) == 0x4404) {
 			/* DM9801 HomeRun */
 			db->HPNA_present = 1;
 			dmfe_program_DM9801(db, tmp_reg);
@@ -2010,16 +1592,18 @@ static void dmfe_parse_srom(struct dmfe_board_info * db)
  *	Init HomeRun DM9801
  */
 
-static void dmfe_program_DM9801(struct dmfe_board_info * db, int HPNA_rev)
+static void dmfe_program_DM9801(struct dmfe_board_info *db, int HPNA_rev)
 {
 	uint reg17, reg25;
 
-	if ( !HPNA_NoiseFloor ) HPNA_NoiseFloor = DM9801_NOISE_FLOOR;
-	switch(HPNA_rev) {
+	if (!HPNA_NoiseFloor)
+		HPNA_NoiseFloor = DM9801_NOISE_FLOOR;
+
+	switch (HPNA_rev) {
 	case 0xb900: /* DM9801 E3 */
 		db->HPNA_command |= 0x1000;
 		reg25 = phy_read(db->ioaddr, db->phy_addr, 24, db->chip_id);
-		reg25 = ( (reg25 + HPNA_NoiseFloor) & 0xff) | 0xf000;
+		reg25 = ((reg25 + HPNA_NoiseFloor) & 0xff) | 0xf000;
 		reg17 = phy_read(db->ioaddr, db->phy_addr, 17, db->chip_id);
 		break;
 	case 0xb901: /* DM9801 E4 */
@@ -2048,14 +1632,16 @@ static void dmfe_program_DM9801(struct dmfe_board_info * db, int HPNA_rev)
  *	Init HomeRun DM9802
  */
 
-static void dmfe_program_DM9802(struct dmfe_board_info * db)
+static void dmfe_program_DM9802(struct dmfe_board_info *db)
 {
 	uint phy_reg;
 
-	if ( !HPNA_NoiseFloor ) HPNA_NoiseFloor = DM9802_NOISE_FLOOR;
+	if (!HPNA_NoiseFloor)
+		HPNA_NoiseFloor = DM9802_NOISE_FLOOR;
+
 	phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command, db->chip_id);
 	phy_reg = phy_read(db->ioaddr, db->phy_addr, 25, db->chip_id);
-	phy_reg = ( phy_reg & 0xff00) + HPNA_NoiseFloor;
+	phy_reg = (phy_reg & 0xff00) + HPNA_NoiseFloor;
 	phy_write(db->ioaddr, db->phy_addr, 25, phy_reg, db->chip_id);
 }
 
@@ -2065,38 +1651,283 @@ static void dmfe_program_DM9802(struct dmfe_board_info * db)
  *	issue command again.
 */
 
-static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * db)
+static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info *db)
 {
 	uint phy_reg;
 
 	/* Got remote device status */
 	phy_reg = phy_read(db->ioaddr, db->phy_addr, 17, db->chip_id) & 0x60;
-	switch(phy_reg) {
-	case 0x00: phy_reg = 0x0a00;break; /* LP/LS */
-	case 0x20: phy_reg = 0x0900;break; /* LP/HS */
-	case 0x40: phy_reg = 0x0600;break; /* HP/LS */
-	case 0x60: phy_reg = 0x0500;break; /* HP/HS */
+	switch (phy_reg) {
+
+	case 0x00:  /* LP/LS */
+		phy_reg = 0x0a00;
+		break;
+	case 0x20:  /* LP/HS */
+		phy_reg = 0x0900;
+		break;
+	case 0x40:  /* HP/LS */
+		phy_reg = 0x0600;
+		break;
+	case 0x60:  /* HP/HS */
+		phy_reg = 0x0500;
+		break;
 	}
 
 	/* Check remote device status match our setting ot not */
-	if ( phy_reg != (db->HPNA_command & 0x0f00) ) {
+	if (phy_reg != (db->HPNA_command & 0x0f00)) {
 		phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command,
 			  db->chip_id);
-		db->HPNA_timer=8;
+		db->HPNA_timer = 8;
 	} else
-		db->HPNA_timer=600;	/* Match, every 10 minutes, check */
+		db->HPNA_timer = 600;	/* Match, every 10 minutes, check */
 }
 
 
+/*
+ * 	Ethtool interace
+ */
 
-static struct pci_device_id dmfe_pci_tbl[] = {
-	{ 0x1282, 0x9132, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9132_ID },
-	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9102_ID },
-	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9100_ID },
-	{ 0x1282, 0x9009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9009_ID },
-	{ 0, }
+static void dmfe_ethtool_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	struct dmfe_board_info *np = netdev_priv(dev);
+
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	if (np->pdev)
+		strcpy(info->bus_info, pci_name(np->pdev));
+	else
+		sprintf(info->bus_info, "EISA 0x%lx %d",
+			dev->base_addr, dev->irq);
+}
+
+static int dmfe_ethtool_set_wol(struct net_device *dev,
+				struct ethtool_wolinfo *wolinfo)
+{
+	struct dmfe_board_info *db = netdev_priv(dev);
+
+	if (wolinfo->wolopts & (WAKE_UCAST | WAKE_MCAST | WAKE_BCAST |
+						WAKE_ARP | WAKE_MAGICSECURE))
+		return -EOPNOTSUPP;
+
+	db->wol_mode = wolinfo->wolopts;
+	return 0;
+}
+
+static void dmfe_ethtool_get_wol(struct net_device *dev,
+				 struct ethtool_wolinfo *wolinfo)
+{
+	struct dmfe_board_info *db = netdev_priv(dev);
+
+	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
+	wolinfo->wolopts = db->wol_mode;
+	return;
+}
+
+
+static const struct ethtool_ops netdev_ethtool_ops = {
+	.get_drvinfo		= dmfe_ethtool_get_drvinfo,
+	.get_link               = ethtool_op_get_link,
+	.set_wol		= dmfe_ethtool_set_wol,
+	.get_wol		= dmfe_ethtool_get_wol,
+};
+
+
+static const struct net_device_ops netdev_ops = {
+	.ndo_open 		= dmfe_open,
+	.ndo_stop		= dmfe_stop,
+	.ndo_start_xmit		= dmfe_start_xmit,
+	.ndo_set_multicast_list = dmfe_set_filter_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= dmfe_poll,
+#endif
 };
-MODULE_DEVICE_TABLE(pci, dmfe_pci_tbl);
+
+
+static int __devinit dmfe_probe(struct pci_dev *pdev,
+				    const struct pci_device_id *ent)
+{
+	struct dmfe_board_info *db;	/* board information structure */
+	struct net_device *dev;
+	u32 pci_pmr;
+	int i, err;
+
+	DMFE_DBUG(0, "dmfe_probe()", 0);
+
+	if (!printed_version++)
+		printk(version);
+
+	/*
+	 *	SPARC on-board DM910x chips should be handled by the main
+	 *	tulip driver, except for early DM9100s.
+	 */
+#ifdef CONFIG_TULIP_DM910X
+	if ((ent->driver_data == PCI_DM9100_ID && pdev->revision >= 0x30) ||
+	    ent->driver_data == PCI_DM9102_ID) {
+		struct device_node *dp = pci_device_to_OF_node(pdev);
+
+		if (dp && of_get_property(dp, "local-mac-address", NULL)) {
+			printk(KERN_INFO DRV_NAME
+			       ": skipping on-board DM910x (use tulip)\n");
+			return -ENODEV;
+		}
+	}
+#endif
+
+	/* Init network device */
+	dev = alloc_etherdev(sizeof(*db));
+	if (dev == NULL)
+		return -ENOMEM;
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
+		printk(KERN_WARNING DRV_NAME
+			": 32-bit PCI DMA not available.\n");
+		err = -ENODEV;
+		goto err_out_free;
+	}
+
+	/* Enable Master/IO access, Disable memory access */
+	err = pci_enable_device(pdev);
+	if (err)
+		goto err_out_free;
+
+	if (!pci_resource_start(pdev, 0)) {
+		printk(KERN_ERR DRV_NAME ": I/O base is zero\n");
+		err = -ENODEV;
+		goto err_out_disable;
+	}
+
+	if (pci_resource_len(pdev, 0) < (CHK_IO_SIZE(pdev))) {
+		printk(KERN_ERR DRV_NAME ": Allocated I/O size too small\n");
+		err = -ENODEV;
+		goto err_out_disable;
+	}
+
+#if 0	/* pci_{enable_device,set_master} sets minimum latency for us now */
+
+	/* Set Latency Timer 80h */
+	/* FIXME: setting values > 32 breaks some SiS 559x stuff.
+	   Need a PCI quirk.. */
+
+	pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0x80);
+#endif
+
+	if (pci_request_regions(pdev, DRV_NAME)) {
+		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
+		err = -ENODEV;
+		goto err_out_disable;
+	}
+
+	/* Init system & device */
+	db = netdev_priv(dev);
+
+	/* Allocate Tx/Rx descriptor memory */
+	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) *
+			DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
+	if (!db->desc_pool_ptr)
+		goto err_out_res;
+
+	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC *
+			TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
+	if (!db->buf_pool_ptr)
+		goto err_out_free_desc;
+
+	db->first_tx_desc = (struct tx_desc *) db->desc_pool_ptr;
+	db->first_tx_desc_dma = db->desc_pool_dma_ptr;
+	db->buf_pool_start = db->buf_pool_ptr;
+	db->buf_pool_dma_start = db->buf_pool_dma_ptr;
+
+	db->chip_id = ent->driver_data;
+	db->ioaddr = pci_resource_start(pdev, 0);
+	db->chip_revision = pdev->revision;
+	db->wol_mode = 0;
+
+	db->pdev = pdev;
+
+	dev->base_addr = db->ioaddr;
+	dev->irq = pdev->irq;
+	pci_set_drvdata(pdev, dev);
+	dev->netdev_ops = &netdev_ops;
+	dev->ethtool_ops = &netdev_ethtool_ops;
+	netif_carrier_off(dev);
+	spin_lock_init(&db->lock);
+
+	pci_read_config_dword(pdev, 0x50, &pci_pmr);
+	pci_pmr &= 0x70000;
+	if ((pci_pmr == 0x10000) && (db->chip_revision == 0x31))
+		db->chip_type = 1;	/* DM9102A E3 */
+	else
+		db->chip_type = 0;
+
+	/* read 64 word srom data */
+	for (i = 0; i < 64; i++)
+		((__le16 *) db->srom)[i] =
+			cpu_to_le16(dmfe_read_srom_word(db->ioaddr, i));
+
+	/* Set Node address */
+	for (i = 0; i < 6; i++)
+		dev->dev_addr[i] = db->srom[20 + i];
+
+	err = register_netdev(dev);
+	if (err)
+		goto err_out_free_buf;
+
+	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, %pM, irq %d.\n",
+	       dev->name,
+	       ent->driver_data >> 16,
+	       pci_name(pdev),
+	       dev->dev_addr,
+	       dev->irq);
+
+	pci_set_master(pdev);
+
+	return 0;
+
+err_out_free_buf:
+	pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
+			    db->buf_pool_ptr, db->buf_pool_dma_ptr);
+err_out_free_desc:
+	pci_free_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20,
+			    db->desc_pool_ptr, db->desc_pool_dma_ptr);
+err_out_res:
+	pci_release_regions(pdev);
+err_out_disable:
+	pci_disable_device(pdev);
+err_out_free:
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(dev);
+
+	return err;
+}
+
+static void __devexit dmfe_remove(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct dmfe_board_info *db = netdev_priv(dev);
+
+	DMFE_DBUG(0, "dmfe_remove_one()", 0);
+
+	if (dev) {
+
+		unregister_netdev(dev);
+
+		pci_free_consistent(db->pdev, sizeof(struct tx_desc) *
+					DESC_ALL_CNT + 0x20, db->desc_pool_ptr,
+					db->desc_pool_dma_ptr);
+		pci_free_consistent(db->pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
+					db->buf_pool_ptr, db->buf_pool_dma_ptr);
+		pci_release_regions(pdev);
+		free_netdev(dev);	/* free board information */
+
+		pci_set_drvdata(pdev, NULL);
+	}
+
+	DMFE_DBUG(0, "dmfe_remove_one() exit", 0);
+}
 
 
 #ifdef CONFIG_PM
@@ -2111,11 +1942,11 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 
 	/* Disable Tx/Rx */
 	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);
-	update_cr6(db->cr6_data, dev->base_addr);
+	dmfe_update_cr6(db->cr6_data, dev->base_addr);
 
 	/* Disable Interrupt */
 	outl(0, dev->base_addr + DCR7);
-	outl(inl (dev->base_addr + DCR5), dev->base_addr + DCR5);
+	outl(inl(dev->base_addr + DCR5), dev->base_addr + DCR5);
 
 	/* Fre RX buffers */
 	dmfe_free_rxbuffer(db);
@@ -2136,7 +1967,7 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 
 	/* Power down device*/
 	pci_save_state(pci_dev);
-	pci_set_power_state(pci_dev, pci_choose_state (pci_dev, state));
+	pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state));
 
 	return 0;
 }
@@ -2150,7 +1981,7 @@ static int dmfe_resume(struct pci_dev *pci_dev)
 	pci_restore_state(pci_dev);
 
 	/* Re-initilize DM910X board */
-	dmfe_init_dm910x(dev);
+	dmfe_hardware_init(dev);
 
 	/* Disable WOL */
 	pci_read_config_dword(pci_dev, 0x40, &tmp);
@@ -2166,44 +1997,33 @@ static int dmfe_resume(struct pci_dev *pci_dev)
 
 	return 0;
 }
-#else
-#define dmfe_suspend NULL
-#define dmfe_resume NULL
 #endif
 
+
+static struct pci_device_id dmfe_pci_tbl[] = {
+	{ 0x1282, 0x9132, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9132_ID },
+	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9102_ID },
+	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9100_ID },
+	{ 0x1282, 0x9009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9009_ID },
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, dmfe_pci_tbl);
+
+
 static struct pci_driver dmfe_driver = {
 	.name		= "dmfe",
 	.id_table	= dmfe_pci_tbl,
-	.probe		= dmfe_init_one,
-	.remove		= __devexit_p(dmfe_remove_one),
+	.probe		= dmfe_probe,
+	.remove		= __devexit_p(dmfe_remove),
+#ifdef CONFIG_PM
 	.suspend        = dmfe_suspend,
 	.resume         = dmfe_resume
+#endif
 };
 
-MODULE_AUTHOR("Sten Wang, sten_wang@davicom.com.tw");
-MODULE_DESCRIPTION("Davicom DM910X fast ethernet driver");
-MODULE_LICENSE("GPL");
-MODULE_VERSION(DRV_VERSION);
 
-module_param(debug, int, 0);
-module_param(mode, byte, 0);
-module_param(cr6set, int, 0);
-module_param(chkmode, byte, 0);
-module_param(HPNA_mode, byte, 0);
-module_param(HPNA_rx_cmd, byte, 0);
-module_param(HPNA_tx_cmd, byte, 0);
-module_param(HPNA_NoiseFloor, byte, 0);
-module_param(SF_mode, byte, 0);
-MODULE_PARM_DESC(debug, "Davicom DM9xxx enable debugging (0-1)");
-MODULE_PARM_DESC(mode, "Davicom DM9xxx: "
-		"Bit 0: 10/100Mbps, bit 2: duplex, bit 8: HomePNA");
-
-MODULE_PARM_DESC(SF_mode, "Davicom DM9xxx special function "
-		"(bit 0: VLAN, bit 1 Flow Control, bit 2: TX pause packet)");
-
-/*	Description:
- *	when user used insmod to add module, system invoked init_module()
- *	to initilize and register.
+/*
+ *	Search DM910X board ,allocate space and register it
  */
 
 static int __init dmfe_init_module(void)
@@ -2220,15 +2040,16 @@ static int __init dmfe_init_module(void)
 	if (cr6set)
 		dmfe_cr6_user_set = cr6set;
 
- 	switch(mode) {
-   	case DMFE_10MHF:
+	switch (mode) {
+	case DMFE_10MHF:
 	case DMFE_100MHF:
 	case DMFE_10MFD:
 	case DMFE_100MFD:
 	case DMFE_1M_HPNA:
 		dmfe_media_mode = mode;
 		break;
-	default:dmfe_media_mode = DMFE_AUTO;
+	default:
+		dmfe_media_mode = DMFE_AUTO;
 		break;
 	}
 
@@ -2249,12 +2070,6 @@ static int __init dmfe_init_module(void)
 }
 
 
-/*
- *	Description:
- *	when user used rmmod to delete module, system invoked clean_module()
- *	to un-register all registered services.
- */
-
 static void __exit dmfe_cleanup_module(void)
 {
 	DMFE_DBUG(0, "dmfe_clean_module() ", debug);
@@ -2263,3 +2078,26 @@ static void __exit dmfe_cleanup_module(void)
 
 module_init(dmfe_init_module);
 module_exit(dmfe_cleanup_module);
+
+
+module_param(debug, int, 0);
+module_param(mode, byte, 0);
+module_param(cr6set, int, 0);
+module_param(chkmode, byte, 0);
+module_param(HPNA_mode, byte, 0);
+module_param(HPNA_rx_cmd, byte, 0);
+module_param(HPNA_tx_cmd, byte, 0);
+module_param(HPNA_NoiseFloor, byte, 0);
+module_param(SF_mode, byte, 0);
+MODULE_PARM_DESC(debug, "Davicom DM9xxx enable debugging (0-1)");
+MODULE_PARM_DESC(mode, "Davicom DM9xxx: "
+		"Bit 0: 10/100Mbps, bit 2: duplex, bit 8: HomePNA");
+
+MODULE_PARM_DESC(SF_mode, "Davicom DM9xxx special function "
+		"(bit 0: VLAN, bit 1 Flow Control, bit 2: TX pause packet)");
+
+
+MODULE_AUTHOR("Sten Wang, sten_wang@davicom.com.tw");
+MODULE_DESCRIPTION("Davicom DM910X fast ethernet driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
diff --git a/drivers/net/tulip/dmfe.h b/drivers/net/tulip/dmfe.h
new file mode 100644
index 0000000..363e822
--- /dev/null
+++ b/drivers/net/tulip/dmfe.h
@@ -0,0 +1,305 @@
+/*
+    A Davicom DM9102/DM9102A/DM9102A+DM9801/DM9102A+DM9802 NIC fast
+    ethernet driver for Linux.
+    Copyright (C) 1997  Sten Wang
+
+    This program is free software; you can redistribute it and/or
+    modify it under the terms of the GNU General Public License
+    as published by the Free Software Foundation; either version 2
+    of the License, or (at your option) any later version.
+
+    This program is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    DAVICOM Web-Site: www.davicom.com.tw
+
+    Author: Sten Wang, 886-3-5798797-8517, E-mail: sten_wang@davicom.com.tw
+    Maintainer: Tobias Ringstrom <tori@unhappy.mine.nu>
+
+    (C)Copyright 1997-1998 DAVICOM Semiconductor,Inc. All Rights Reserved.
+
+    Marcelo Tosatti <marcelo@conectiva.com.br> :
+    Made it compile in 2.3 (device to net_device)
+
+    Alan Cox <alan@lxorguk.ukuu.org.uk> :
+    Cleaned up for kernel merge.
+    Removed the back compatibility support
+    Reformatted, fixing spelling etc as I went
+    Removed IRQ 0-15 assumption
+
+    Jeff Garzik <jgarzik@pobox.com> :
+    Updated to use new PCI driver API.
+    Resource usage cleanups.
+    Report driver version to user.
+
+    Tobias Ringstrom <tori@unhappy.mine.nu> :
+    Cleaned up and added SMP safety.  Thanks go to Jeff Garzik,
+    Andrew Morton and Frank Davis for the SMP safety fixes.
+
+    Vojtech Pavlik <vojtech@suse.cz> :
+    Cleaned up pointer arithmetics.
+    Fixed a lot of 64bit issues.
+    Cleaned up printk()s a bit.
+    Fixed some obvious big endian problems.
+
+    Tobias Ringstrom <tori@unhappy.mine.nu> :
+    Use time_after for jiffies calculation.  Added ethtool
+    support.  Updated PCI resource allocation.  Do not
+    forget to unmap PCI mapped skbs.
+
+    Alan Cox <alan@lxorguk.ukuu.org.uk>
+    Added new PCI identifiers provided by Clear Zhang at ALi
+    for their 1563 ethernet device.
+
+    TODO
+
+    Check on 64 bit boxes.
+    Check and fix on big endian boxes.
+
+    Test and make sure PCI latency is now correct for all cases.
+*/
+#define DRV_NAME	"dmfe"
+#define DRV_VERSION	"1.36.4"
+#define DRV_RELDATE	"2002-01-17"
+
+#define PCI_DM9132_ID   0x91321282      /* Davicom DM9132 ID */
+#define PCI_DM9102_ID   0x91021282      /* Davicom DM9102 ID */
+#define PCI_DM9100_ID   0x91001282      /* Davicom DM9100 ID */
+#define PCI_DM9009_ID   0x90091282      /* Davicom DM9009 ID */
+
+#define DM9102_IO_SIZE  0x80
+#define DM9102A_IO_SIZE 0x100
+#define TX_MAX_SEND_CNT 0x1             /* Maximum tx packet per time */
+#define TX_DESC_CNT     0x10            /* Allocated Tx descriptors */
+#define RX_DESC_CNT     0x20            /* Allocated Rx descriptors */
+#define TX_FREE_DESC_CNT (TX_DESC_CNT - 2)	/* Max TX packet count */
+#define TX_WAKE_DESC_CNT (TX_DESC_CNT - 3)	/* TX wakeup count */
+#define DESC_ALL_CNT    (TX_DESC_CNT + RX_DESC_CNT)
+#define TX_BUF_ALLOC    0x600
+#define RX_ALLOC_SIZE   0x620
+#define DM910X_RESET    1
+#define CR0_DEFAULT     0x00E00000      /* TX & RX burst mode */
+#define CR6_DEFAULT     0x00080000      /* HD */
+#define CR7_DEFAULT     0x180c1
+#define CR15_DEFAULT    0x06            /* TxJabber RxWatchdog */
+#define TDES0_ERR_MASK  0x4302          /* TXJT, LC, EC, FUE */
+#define MAX_PACKET_SIZE 1514
+#define DMFE_MAX_MULTICAST 14
+#define RX_COPY_SIZE	100
+#define MAX_CHECK_PACKET 0x8000
+#define DM9801_NOISE_FLOOR 8
+#define DM9802_NOISE_FLOOR 5
+
+#define DMFE_WOL_LINKCHANGE	0x20000000
+#define DMFE_WOL_SAMPLEPACKET	0x10000000
+#define DMFE_WOL_MAGICPACKET	0x08000000
+
+
+#define DMFE_10MHF      0
+#define DMFE_100MHF     1
+#define DMFE_10MFD      4
+#define DMFE_100MFD     5
+#define DMFE_AUTO       8
+#define DMFE_1M_HPNA    0x10
+
+#define DMFE_TXTH_72	0x400000	/* TX TH 72 byte */
+#define DMFE_TXTH_96	0x404000	/* TX TH 96 byte */
+#define DMFE_TXTH_128	0x0000		/* TX TH 128 byte */
+#define DMFE_TXTH_256	0x4000		/* TX TH 256 byte */
+#define DMFE_TXTH_512	0x8000		/* TX TH 512 byte */
+#define DMFE_TXTH_1K	0xC000		/* TX TH 1K  byte */
+
+#define DMFE_TIMER_WUT  (jiffies + HZ * 1)/* timer wakeup time : 1 second */
+#define DMFE_TX_TIMEOUT ((3*HZ)/2)	/* tx packet time-out time 1.5 s" */
+#define DMFE_TX_KICK 	(HZ/2)	/* tx packet Kick-out time 0.5 s" */
+
+#define DMFE_DBUG(dbug_now, msg, value) \
+	do { \
+		if (dmfe_debug || (dbug_now)) \
+			printk(KERN_ERR DRV_NAME ": %s %lx\n",\
+				(msg), (long) (value)); \
+	} while (0)
+
+#define SHOW_MEDIA_TYPE(mode) \
+	printk(KERN_INFO DRV_NAME " : Change Speed to %sMhz %s duplex\n" , \
+		(mode & 1) ? "100" : "10", (mode & 4) ? "full" : "half");
+
+
+/* CR9 definition: SROM/MII */
+#define CR9_SROM_READ   0x4800
+#define CR9_SRCS        0x1
+#define CR9_SRCLK       0x2
+#define CR9_CRDOUT      0x8
+#define SROM_DATA_0     0x0
+#define SROM_DATA_1     0x4
+#define PHY_DATA_1      0x20000
+#define PHY_DATA_0      0x00000
+#define MDCLKH          0x10000
+
+#define PHY_POWER_DOWN	0x800
+
+#define SROM_V41_CODE   0x14
+
+#define SROM_CLK_WRITE(data, ioaddr) \
+	do { \
+		outl(data|CR9_SROM_READ|CR9_SRCS , ioaddr); \
+		udelay(5); \
+		outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK , ioaddr); \
+		udelay(5); \
+		outl(data|CR9_SROM_READ|CR9_SRCS , ioaddr); \
+		udelay(5); \
+	} while (0);
+
+#define __CHK_IO_SIZE(pci_id, dev_rev) \
+ ((((pci_id) == PCI_DM9132_ID) || ((dev_rev) >= 0x30)) ? \
+	DM9102A_IO_SIZE : DM9102_IO_SIZE)
+
+#define CHK_IO_SIZE(pci_dev) \
+	(__CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_dev)->vendor, \
+	(pci_dev)->revision))
+
+
+/* Structure/enum declaration ------------------------------- */
+struct tx_desc {
+	__le32 tdes0, tdes1, tdes2, tdes3; /* Data for the card */
+	char *tx_buf_ptr;               /* Data for us */
+	struct tx_desc *next_tx_desc;
+} __attribute__((aligned(32)));
+
+struct rx_desc {
+	__le32 rdes0, rdes1, rdes2, rdes3; /* Data for the card */
+	struct sk_buff *rx_skb_ptr;	/* Data for us */
+	struct rx_desc *next_rx_desc;
+} __attribute__((aligned(32)));
+
+struct dmfe_board_info {
+	u32 chip_id;			/* Chip vendor/Device ID */
+	u8 chip_revision;		/* Chip revision */
+	struct net_device *next_dev;	/* next device */
+	struct pci_dev *pdev;		/* PCI device */
+	spinlock_t lock;
+
+	long ioaddr;			/* I/O base address */
+	u32 cr0_data;
+	u32 cr5_data;
+	u32 cr6_data;
+	u32 cr7_data;
+	u32 cr15_data;
+
+	/* pointer for memory physical address */
+	dma_addr_t buf_pool_dma_ptr;	/* Tx buffer pool memory */
+	dma_addr_t buf_pool_dma_start;	/* Tx buffer pool align dword */
+	dma_addr_t desc_pool_dma_ptr;	/* descriptor pool memory */
+	dma_addr_t first_tx_desc_dma;
+	dma_addr_t first_rx_desc_dma;
+
+	/* descriptor pointer */
+	unsigned char *buf_pool_ptr;	/* Tx buffer pool memory */
+	unsigned char *buf_pool_start;	/* Tx buffer pool align dword */
+	unsigned char *desc_pool_ptr;	/* descriptor pool memory */
+	struct tx_desc *first_tx_desc;
+	struct tx_desc *tx_insert_ptr;
+	struct tx_desc *tx_remove_ptr;
+	struct rx_desc *first_rx_desc;
+	struct rx_desc *rx_insert_ptr;
+	struct rx_desc *rx_ready_ptr;	/* packet come pointer */
+	unsigned long tx_packet_cnt;	/* transmitted packet count */
+	unsigned long tx_queue_cnt;	/* wait to send packet count */
+	unsigned long rx_avail_cnt;	/* available rx descriptor count */
+	unsigned long interval_rx_cnt;	/* rx packet count a callback time */
+
+	u16 HPNA_command;		/* For HPNA register 16 */
+	u16 HPNA_timer;			/* For HPNA remote device check */
+	u16 dbug_cnt;
+	u16 NIC_capability;		/* NIC media capability */
+	u16 PHY_reg4;			/* Saved Phyxcer register 4 value */
+
+	u8 HPNA_present;		/* 0:none, 1:DM9801, 2:DM9802 */
+	u8 chip_type;			/* Keep DM9102A chip type */
+	u8 media_mode;			/* user specify media mode */
+	u8 op_mode;			/* real work media mode */
+	u8 phy_addr;
+	u8 wait_reset;			/* Hardware failed, need to reset */
+	u8 dm910x_chk_mode;		/* Operating mode check */
+	u8 first_in_callback;		/* Flag to record state */
+	u8 wol_mode;			/* user WOL settings */
+	struct timer_list timer;
+
+	/* Driver defined statistic counter */
+	unsigned long tx_fifo_underrun;
+	unsigned long tx_loss_carrier;
+	unsigned long tx_no_carrier;
+	unsigned long tx_late_collision;
+	unsigned long tx_excessive_collision;
+	unsigned long tx_jabber_timeout;
+	unsigned long reset_count;
+	unsigned long reset_cr8;
+	unsigned long reset_fatal;
+	unsigned long reset_TXtimeout;
+
+	/* NIC SROM data */
+	unsigned char srom[128];
+};
+
+enum dmfe_offsets {
+	DCR0 = 0x00, DCR1 = 0x08, DCR2 = 0x10, DCR3 = 0x18, DCR4 = 0x20,
+	DCR5 = 0x28, DCR6 = 0x30, DCR7 = 0x38, DCR8 = 0x40, DCR9 = 0x48,
+	DCR10 = 0x50, DCR11 = 0x58, DCR12 = 0x60, DCR13 = 0x68, DCR14 = 0x70,
+	DCR15 = 0x78
+};
+
+enum dmfe_CR6_bits {
+	CR6_RXSC = 0x2, CR6_PBF = 0x8, CR6_PM = 0x40, CR6_PAM = 0x80,
+	CR6_FDM = 0x200, CR6_TXSC = 0x2000, CR6_STI = 0x100000,
+	CR6_SFT = 0x200000, CR6_RXA = 0x40000000, CR6_NO_PURGE = 0x20000000
+};
+
+static int dmfe_open(struct net_device *);
+static netdev_tx_t dmfe_start_xmit(struct sk_buff *, struct net_device *);
+static int dmfe_stop(struct net_device *);
+static void dmfe_set_filter_mode(struct net_device *);
+static const struct ethtool_ops netdev_ethtool_ops;
+static u16 dmfe_read_srom_word(long , int);
+static irqreturn_t dmfe_interrupt(int , void *);
+static void dmfe_poll(struct net_device *dev);
+static void dmfe_descriptor_init(struct dmfe_board_info *);
+static void dmfe_allocate_rx_buffer(struct dmfe_board_info *);
+static void dmfe_update_cr6(u32, unsigned long);
+static void dmfe_send_filter_frame(struct net_device* , int);
+static void dm9132_id_table(struct net_device * , int);
+static u16 phy_read(unsigned long, u8, u8, u32);
+static void phy_write(unsigned long, u8, u8, u16, u32);
+static void phy_write_1bit(unsigned long, u32);
+static u16 phy_read_1bit(unsigned long);
+static u8 dmfe_sense_speed(struct dmfe_board_info *);
+static void dmfe_process_mode(struct dmfe_board_info *);
+static void dmfe_timer(unsigned long);
+static void dmfe_rx_packet(struct net_device *, struct dmfe_board_info *);
+static void dmfe_free_tx_pkt(struct net_device *, struct dmfe_board_info *);
+static void dmfe_reuse_skb(struct dmfe_board_info *, struct sk_buff *);
+static void dmfe_dynamic_reset(struct net_device *);
+static void dmfe_free_rxbuffer(struct dmfe_board_info *);
+static void dmfe_hardware_init(struct net_device *);
+static void dmfe_parse_srom(struct dmfe_board_info *);
+static void dmfe_program_DM9801(struct dmfe_board_info *, int);
+static void dmfe_program_DM9802(struct dmfe_board_info *);
+static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info *);
+static void dmfe_set_phyxcer(struct dmfe_board_info *);
+
+/*
+ *	Calculate the CRC valude of the Rx packet
+ *	flag = 	1 : return the reverse CRC (for the received packet CRC)
+ *		0 : return the normal CRC (for Hash Table index)
+ */
+
+static inline u32 cal_CRC(unsigned char *Data, unsigned int Len, u8 flag)
+{
+	u32 crc = crc32(~0, Data, Len);
+
+	if (flag)
+		crc = ~crc;
+
+	return crc;
+}
-- 
1.6.3.3
