From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Thu, 21 Oct 2004 22:11:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022021103.GA21829@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The day's net driver merges.

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/8139cp.c                          |    1=20
 drivers/net/b44.c                             |  131 +++--
 drivers/net/b44.h                             |  113 ----
 drivers/net/depca.c                           |    8=20
 drivers/net/forcedeth.c                       |   31 +
 drivers/net/sis900.c                          |  258 +++++-----
 drivers/net/smc91x.c                          |  484 ++++++++++---------
 drivers/net/smc91x.h                          |   33 -
 drivers/net/tokenring/lanstreamer.c           |    2=20
 drivers/net/tulip/dmfe.c                      |    1=20
 drivers/net/via-rhine.c                       |    4=20
 drivers/net/wireless/prism54/isl_38xx.c       |   15=20
 drivers/net/wireless/prism54/isl_38xx.h       |    4=20
 drivers/net/wireless/prism54/isl_ioctl.c      |  639 +++++++++++++++++++=
+++----
 drivers/net/wireless/prism54/isl_ioctl.h      |    2=20
 drivers/net/wireless/prism54/isl_oid.h        |    9=20
 drivers/net/wireless/prism54/islpci_dev.c     |   49 +
 drivers/net/wireless/prism54/islpci_dev.h     |    4=20
 drivers/net/wireless/prism54/islpci_eth.c     |    5=20
 drivers/net/wireless/prism54/islpci_hotplug.c |    3=20
 drivers/net/wireless/prism54/islpci_mgt.c     |    1=20
 drivers/net/wireless/prism54/islpci_mgt.h     |    2=20
 drivers/net/wireless/prism54/oid_mgt.c        |  126 ++++-
 drivers/net/wireless/prism54/oid_mgt.h        |    5=20
 24 files changed, 1273 insertions(+), 657 deletions(-)

through these ChangeSets:

<jolt:tuxbox.org>:
  o [netdrvr b44] clean up SiliconBackplane definitions/functions
  o [netdrvr b44] ignore carrier lost errors

Alexander Viro:
  o depca removal of bogus virt_to_bus() uses
  o missing includes of asm/irq.h
  o lanstreamer fix

Andrew Morton:
  o typhoon build fix

Con Kolivas:
  o b44poll - whitespace
  o netconsole support for b44

Daniele Venzano:
  o [netdrvr sis900] whitespace and codingstyle updates

Hirokazu Takata:
  o m32r: trivial fix of smc91x.h

Jeff Garzik:
  o [netdrvr b44] update MODULE_AUTHORS

Manfred Spraul:
  o rx checksum support for gige nForce ethernet

Margit Schubert-While:
  o prism54 bug initialization/mgt_commit
  o prism54 print firmware version
  o prism54 Bug in timeout scheduling
  o prism54 remove TRACE
  o prism54 fix wpa_supplicant frequency parsing
  o prism54 initial WPA support
  o prism54 add WE17 support
  o prism54 remove module params
  o prism54 Code cleanup

Nicolas Pitre:
  o smc91x: release on-chip RX packet memory ASAP
  o smc91x: receives two bytes too many
  o smc91x: fix compilation with DMA on PXA2xx
  o smc91x: more SMP locking fixes
  o smc91x: fix SMP lock usage
  o smc91x: cosmetics
  o smc91x: straighten SMP locking
  o smc91x: display pertinent register values from the  timeout function
  o smc91x: fix possible leak of the skb waiting for mem  allocation
  o smc91x: use a work queue to reconfigure the phy from  smc_timeout()
  o smc91x: move TX processing out of IRQ context entirely
  o smc91x: simplify register bank usage
  o smc91x: fold smc_setmulticast() into smc_set_multicast_list()
  o smc91x: set the MAC addr from the smc_enable function
  o smc91x: Assorted minor cleanups
  o smc91x: Revert 1.1923.3.58: "m32r: modify drivers/net/smc91x.c for m3=
2r"

Pavel Machek:
  o Fix suspend/resume support in via-rhine2

Pekka Pietik=E4inen:
  o b44: use bounce buffers to workaround chip DMA bug/limitations

Stephen Hemminger:
  o b44: use netdev_priv
  o b44: replace MODULE_PARM

diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/8139cp.c	2004-10-21 22:09:44 -04:00
@@ -71,6 +71,7 @@
 #include <linux/udp.h>
 #include <linux/cache.h>
 #include <asm/io.h>
+#include <asm/irq.h>
 #include <asm/uaccess.h>
=20
 /* VLAN tagging feature enable/disable */
diff -Nru a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/b44.c	2004-10-21 22:09:44 -04:00
@@ -8,6 +8,7 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
@@ -27,8 +28,8 @@
=20
 #define DRV_MODULE_NAME		"b44"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"0.94"
-#define DRV_MODULE_RELDATE	"May 4, 2004"
+#define DRV_MODULE_VERSION	"0.95"
+#define DRV_MODULE_RELDATE	"Aug 3, 2004"
=20
 #define B44_DEF_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
@@ -57,6 +58,7 @@
 #define B44_DEF_TX_RING_PENDING		(B44_TX_RING_SIZE - 1)
 #define B44_TX_RING_BYTES	(sizeof(struct dma_desc) * \
 				 B44_TX_RING_SIZE)
+#define B44_DMA_MASK 0x3fffffff
=20
 #define TX_RING_GAP(BP)	\
 	(B44_TX_RING_SIZE - (BP)->tx_pending)
@@ -67,6 +69,7 @@
 #define NEXT_TX(N)		(((N) + 1) & (B44_TX_RING_SIZE - 1))
=20
 #define RX_PKT_BUF_SZ		(1536 + bp->rx_offset + 64)
+#define TX_PKT_BUF_SZ		(B44_MAX_MTU + ETH_HLEN + 8)
=20
 /* minimum number of free TX descriptors required to wake up TX process =
*/
 #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)
@@ -74,13 +77,13 @@
 static char version[] __devinitdata =3D
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n"=
;
=20
-MODULE_AUTHOR("David S. Miller (davem@redhat.com)");
+MODULE_AUTHOR("Florian Schirmer, Pekka Pietikainen, David S. Miller");
 MODULE_DESCRIPTION("Broadcom 4400 10/100 PCI ethernet driver");
 MODULE_LICENSE("GPL");
-MODULE_PARM(b44_debug, "i");
-MODULE_PARM_DESC(b44_debug, "B44 bitmapped debugging message enable valu=
e");
=20
 static int b44_debug =3D -1;	/* -1 =3D=3D use B44_DEF_MSG_ENABLE as valu=
e */
+module_param(b44_debug, int, 0);
+MODULE_PARM_DESC(b44_debug, "B44 bitmapped debugging message enable valu=
e");
=20
 static struct pci_device_id b44_pci_tbl[] =3D {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401,
@@ -97,6 +100,10 @@
 static void b44_halt(struct b44 *);
 static void b44_init_rings(struct b44 *);
 static void b44_init_hw(struct b44 *);
+static int b44_poll(struct net_device *dev, int *budget);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void b44_poll_controller(struct net_device *dev);
+#endif
=20
 static inline unsigned long br32(const struct b44 *bp, unsigned long reg=
)
 {
@@ -141,41 +148,8 @@
  * interrupts disabled.
  */
=20
-#define SBID_SDRAM		0
-#define SBID_PCI_MEM		1
-#define SBID_PCI_CFG		2
-#define SBID_PCI_DMA		3
-#define	SBID_SDRAM_SWAPPED	4
-#define SBID_ENUM		5
-#define SBID_REG_SDRAM		6
-#define SBID_REG_ILINE20	7
-#define SBID_REG_EMAC		8
-#define SBID_REG_CODEC		9
-#define SBID_REG_USB		10
-#define SBID_REG_PCI		11
-#define SBID_REG_MIPS		12
-#define SBID_REG_EXTIF		13
-#define	SBID_EXTIF		14
-#define	SBID_EJTAG		15
-#define	SBID_MAX		16
-
-static u32 ssb_get_addr(struct b44 *bp, u32 id, u32 instance)
-{
-	switch (id) {
-	case SBID_PCI_DMA:
-		return 0x40000000;
-	case SBID_ENUM:
-		return 0x18000000;
-	case SBID_REG_EMAC:
-		return 0x18000000;
-	case SBID_REG_CODEC:
-		return 0x18001000;
-	case SBID_REG_PCI:
-		return 0x18002000;
-	default:
-		return 0;
-	};
-}
+#define SB_PCI_DMA             0x40000000      /* Client Mode PCI memory=
 access space (1 GB) */
+#define BCM4400_PCI_CORE_ADDR  0x18002000      /* Address of PCI core on=
 BCM4400 cards */
=20
 static u32 ssb_get_core_rev(struct b44 *bp)
 {
@@ -187,8 +161,7 @@
 	u32 bar_orig, pci_rev, val;
=20
 	pci_read_config_dword(bp->pdev, SSB_BAR0_WIN, &bar_orig);
-	pci_write_config_dword(bp->pdev, SSB_BAR0_WIN,
-			       ssb_get_addr(bp, SBID_REG_PCI, 0));
+	pci_write_config_dword(bp->pdev, SSB_BAR0_WIN, BCM4400_PCI_CORE_ADDR);
 	pci_rev =3D ssb_get_core_rev(bp);
=20
 	val =3D br32(bp, B44_SBINTVEC);
@@ -649,10 +622,30 @@
 	if (skb =3D=3D NULL)
 		return -ENOMEM;
=20
-	skb->dev =3D bp->dev;
 	mapping =3D pci_map_single(bp->pdev, skb->data,
 				 RX_PKT_BUF_SZ,
 				 PCI_DMA_FROMDEVICE);
+
+	/* Hardware bug work-around, the chip is unable to do PCI DMA
+	   to/from anything above 1GB :-( */
+	if(mapping+RX_PKT_BUF_SZ > B44_DMA_MASK) {
+		/* Sigh... */
+		pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+		dev_kfree_skb_any(skb);
+		skb =3D __dev_alloc_skb(RX_PKT_BUF_SZ,GFP_DMA);
+		if (skb =3D=3D NULL)
+			return -ENOMEM;
+		mapping =3D pci_map_single(bp->pdev, skb->data,
+					 RX_PKT_BUF_SZ,
+					 PCI_DMA_FROMDEVICE);
+		if(mapping+RX_PKT_BUF_SZ > B44_DMA_MASK) {
+			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE)=
;
+			dev_kfree_skb_any(skb);
+			return -ENOMEM;
+		}
+	}
+
+	skb->dev =3D bp->dev;
 	skb_reserve(skb, bp->rx_offset);
=20
 	rh =3D (struct rx_header *)
@@ -930,6 +923,12 @@
=20
 	entry =3D bp->tx_prod;
 	mapping =3D pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if(mapping+len > B44_DMA_MASK) {
+		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
+		pci_unmap_single(bp->pdev, mapping, len,PCI_DMA_TODEVICE);
+		memcpy(bp->tx_bufs+entry*TX_PKT_BUF_SZ,skb->data,skb->len);
+		mapping =3D pci_map_single(bp->pdev, bp->tx_bufs+entry*TX_PKT_BUF_SZ, =
len, PCI_DMA_TODEVICE);
+	}
=20
 	bp->tx_buffers[entry].skb =3D skb;
 	pci_unmap_addr_set(&bp->tx_buffers[entry], mapping, mapping);
@@ -1077,6 +1076,11 @@
 				    bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring =3D NULL;
 	}
+	if (bp->tx_bufs) {
+		pci_free_consistent(bp->pdev, B44_TX_RING_SIZE * TX_PKT_BUF_SZ,
+				    bp->tx_bufs, bp->tx_bufs_dma);
+		bp->tx_bufs =3D NULL;
+	}
 }
=20
 /*
@@ -1099,6 +1103,12 @@
 		goto out_err;
 	memset(bp->tx_buffers, 0, size);
=20
+	size =3D B44_TX_RING_SIZE * TX_PKT_BUF_SZ;
+	bp->tx_bufs =3D pci_alloc_consistent(bp->pdev, size, &bp->tx_bufs_dma);
+	if (!bp->tx_bufs)
+		goto out_err;
+	memset(bp->tx_bufs, 0, size);
+
 	size =3D DMA_TABLE_BYTES;
 	bp->rx_ring =3D pci_alloc_consistent(bp->pdev, size, &bp->rx_ring_dma);
 	if (!bp->rx_ring)
@@ -1297,6 +1307,19 @@
 }
 #endif
=20
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void b44_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	b44_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 static int b44_close(struct net_device *dev)
 {
 	struct b44 *bp =3D netdev_priv(dev);
@@ -1358,7 +1381,10 @@
 				   hwstat->rx_symbol_errs);
=20
 	nstat->tx_aborted_errors =3D hwstat->tx_underruns;
+#if 0
+	/* Carrier lost counter seems to be broken for some devices */
 	nstat->tx_carrier_errors =3D hwstat->tx_carrier_lost;
+#endif
=20
 	return nstat;
 }
@@ -1684,7 +1710,6 @@
 	bp->dev->dev_addr[5] =3D eeprom[82];
=20
 	bp->phy_addr =3D eeprom[90] & 0x1f;
-	bp->mdc_port =3D (eeprom[90] >> 14) & 0x1;
=20
 	/* With this, plus the rx_header prepended to the data by the
 	 * hardware, we'll land the ethernet header on a 2-byte boundary.
@@ -1694,7 +1719,7 @@
 	bp->imask =3D IMASK_DEF;
=20
 	bp->core_unit =3D ssb_core_unit(bp);
-	bp->dma_offset =3D ssb_get_addr(bp, SBID_PCI_DMA, 0);
+	bp->dma_offset =3D SB_PCI_DMA;
=20
 	/* XXX - really required?=20
 	   bp->flags |=3D B44_FLAG_BUGGY_TXPTR;
@@ -1738,12 +1763,19 @@
=20
 	pci_set_master(pdev);
=20
-	err =3D pci_set_dma_mask(pdev, (u64) 0xffffffff);
+	err =3D pci_set_dma_mask(pdev, (u64) B44_DMA_MASK);
 	if (err) {
 		printk(KERN_ERR PFX "No usable DMA configuration, "
 		       "aborting.\n");
 		goto err_out_free_res;
 	}
+=09
+	err =3D pci_set_consistent_dma_mask(pdev, (u64) B44_DMA_MASK);
+	if (err) {
+	  printk(KERN_ERR PFX "No usable DMA configuration, "
+		 "aborting.\n");
+	  goto err_out_free_res;
+	}
=20
 	b44reg_base =3D pci_resource_start(pdev, 0);
 	b44reg_len =3D pci_resource_len(pdev, 0);
@@ -1793,6 +1825,9 @@
 	dev->poll =3D b44_poll;
 	dev->weight =3D 64;
 	dev->watchdog_timeo =3D B44_TX_TIMEOUT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =3D b44_poll_controller;
+#endif
 	dev->change_mtu =3D b44_change_mtu;
 	dev->irq =3D pdev->irq;
 	SET_ETHTOOL_OPS(dev, &b44_ethtool_ops);
@@ -1870,7 +1905,7 @@
 static int b44_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct b44 *bp =3D dev->priv;
+	struct b44 *bp =3D netdev_priv(dev);
=20
         if (!netif_running(dev))
                  return 0;
@@ -1891,7 +1926,7 @@
 static int b44_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct b44 *bp =3D dev->priv;
+	struct b44 *bp =3D netdev_priv(dev);
=20
 	pci_restore_state(pdev);
=20
diff -Nru a/drivers/net/b44.h b/drivers/net/b44.h
--- a/drivers/net/b44.h	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/b44.h	2004-10-21 22:09:44 -04:00
@@ -223,21 +223,8 @@
 #define B44_RX_SYM	0x05D0UL /* MIB RX Symbol Errors */
 #define B44_RX_PAUSE	0x05D4UL /* MIB RX Pause Packets */
 #define B44_RX_NPAUSE	0x05D8UL /* MIB RX Non-Pause Packets */
-#define B44_SBIPSFLAG	0x0F08UL /* SB Initiator Port OCP Slave Flag */
-#define  SBIPSFLAG_IMASK1	0x0000003f /* Which sbflags --> mips interrupt=
 1 */
-#define  SBIPSFLAG_ISHIFT1	0
-#define  SBIPSFLAG_IMASK2	0x00003f00 /* Which sbflags --> mips interrupt=
 2 */
-#define  SBIPSFLAG_ISHIFT2	8
-#define  SBIPSFLAG_IMASK3	0x003f0000 /* Which sbflags --> mips interrupt=
 3 */
-#define  SBIPSFLAG_ISHIFT3	16
-#define  SBIPSFLAG_IMASK4	0x3f000000 /* Which sbflags --> mips interrupt=
 4 */
-#define  SBIPSFLAG_ISHIFT4	24
-#define B44_SBTPSFLAG	0x0F18UL /* SB Target Port OCP Slave Flag */
-#define  SBTPS_NUM0_MASK	0x0000003f
-#define  SBTPS_F0EN0		0x00000040
-#define B44_SBADMATCH3	0x0F60UL /* SB Address Match 3 */
-#define B44_SBADMATCH2	0x0F68UL /* SB Address Match 2 */
-#define B44_SBADMATCH1	0x0F70UL /* SB Address Match 1 */
+
+/* Silicon backplane register definitions */
 #define B44_SBIMSTATE	0x0F90UL /* SB Initiator Agent State */
 #define  SBIMSTATE_PC		0x0000000f /* Pipe Count */
 #define  SBIMSTATE_AP_MASK	0x00000030 /* Arbitration Priority */
@@ -269,86 +256,6 @@
 #define  SBTMSHIGH_GCR		0x20000000 /* Gated Clock Request */
 #define  SBTMSHIGH_BISTF	0x40000000 /* BIST Failed */
 #define  SBTMSHIGH_BISTD	0x80000000 /* BIST Done */
-#define B44_SBBWA0	0x0FA0UL /* SB Bandwidth Allocation Table 0 */
-#define  SBBWA0_TAB0_MASK	0x0000ffff /* Lookup Table 0 */
-#define  SBBWA0_TAB0_SHIFT	0
-#define  SBBWA0_TAB1_MASK	0xffff0000 /* Lookup Table 0 */
-#define  SBBWA0_TAB1_SHIFT	16
-#define B44_SBIMCFGLOW	0x0FA8UL /* SB Initiator Configuration Low */
-#define  SBIMCFGLOW_STO_MASK	0x00000003 /* Service Timeout */
-#define  SBIMCFGLOW_RTO_MASK	0x00000030 /* Request Timeout */
-#define  SBIMCFGLOW_RTO_SHIFT	4
-#define  SBIMCFGLOW_CID_MASK	0x00ff0000 /* Connection ID */
-#define  SBIMCFGLOW_CID_SHIFT	16
-#define B44_SBIMCFGHIGH	0x0FACUL /* SB Initiator Configuration High */
-#define  SBIMCFGHIGH_IEM_MASK	0x0000000c /* Inband Error Mode */
-#define  SBIMCFGHIGH_TEM_MASK	0x00000030 /* Timeout Error Mode */
-#define  SBIMCFGHIGH_TEM_SHIFT	4
-#define  SBIMCFGHIGH_BEM_MASK	0x000000c0 /* Bus Error Mode */
-#define  SBIMCFGHIGH_BEM_SHIFT	6
-#define B44_SBADMATCH0	0x0FB0UL /* SB Address Match 0 */
-#define  SBADMATCH0_TYPE_MASK	0x00000003 /* Address Type */
-#define  SBADMATCH0_AD64	0x00000004 /* Reserved */
-#define  SBADMATCH0_AI0_MASK	0x000000f8 /* Type0 Size */
-#define  SBADMATCH0_AI0_SHIFT	3
-#define  SBADMATCH0_AI1_MASK	0x000001f8 /* Type1 Size */
-#define  SBADMATCH0_AI1_SHIFT	3
-#define  SBADMATCH0_AI2_MASK	0x000001f8 /* Type2 Size */
-#define  SBADMATCH0_AI2_SHIFT	3
-#define  SBADMATCH0_ADEN	0x00000400 /* Enable */
-#define  SBADMATCH0_ADNEG	0x00000800 /* Negative Decode */
-#define  SBADMATCH0_BS0_MASK	0xffffff00 /* Type0 Base Address */
-#define  SBADMATCH0_BS0_SHIFT	8
-#define  SBADMATCH0_BS1_MASK	0xfffff000 /* Type1 Base Address */
-#define  SBADMATCH0_BS1_SHIFT	12
-#define  SBADMATCH0_BS2_MASK	0xffff0000 /* Type2 Base Address */
-#define  SBADMATCH0_BS2_SHIFT	16
-#define B44_SBTMCFGLOW	0x0FB8UL /* SB Target Configuration Low */
-#define  SBTMCFGLOW_CD_MASK	0x000000ff /* Clock Divide Mask */
-#define  SBTMCFGLOW_CO_MASK	0x0000f800 /* Clock Offset Mask */
-#define  SBTMCFGLOW_CO_SHIFT	11
-#define  SBTMCFGLOW_IF_MASK	0x00fc0000 /* Interrupt Flags Mask */
-#define  SBTMCFGLOW_IF_SHIFT	18
-#define  SBTMCFGLOW_IM_MASK	0x03000000 /* Interrupt Mode Mask */
-#define  SBTMCFGLOW_IM_SHIFT	24
-#define B44_SBTMCFGHIGH	0x0FBCUL /* SB Target Configuration High */
-#define  SBTMCFGHIGH_BM_MASK	0x00000003 /* Busy Mode */
-#define  SBTMCFGHIGH_RM_MASK	0x0000000C /* Retry Mode */
-#define  SBTMCFGHIGH_RM_SHIFT	2
-#define  SBTMCFGHIGH_SM_MASK	0x00000030 /* Stop Mode */
-#define  SBTMCFGHIGH_SM_SHIFT	4
-#define  SBTMCFGHIGH_EM_MASK	0x00000300 /* Error Mode */
-#define  SBTMCFGHIGH_EM_SHIFT	8
-#define  SBTMCFGHIGH_IM_MASK	0x00000c00 /* Interrupt Mode */
-#define  SBTMCFGHIGH_IM_SHIFT	10
-#define B44_SBBCFG	0x0FC0UL /* SB Broadcast Configuration */
-#define  SBBCFG_LAT_MASK	0x00000003 /* SB Latency */
-#define  SBBCFG_MAX0_MASK	0x000f0000 /* MAX Counter 0 */
-#define  SBBCFG_MAX0_SHIFT	16
-#define  SBBCFG_MAX1_MASK	0x00f00000 /* MAX Counter 1 */
-#define  SBBCFG_MAX1_SHIFT	20
-#define B44_SBBSTATE	0x0FC8UL /* SB Broadcast State */
-#define  SBBSTATE_SRD		0x00000001 /* ST Reg Disable */
-#define  SBBSTATE_HRD		0x00000002 /* Hold Reg Disable */
-#define B44_SBACTCNFG	0x0FD8UL /* SB Activate Configuration */
-#define B44_SBFLAGST	0x0FE8UL /* SB Current SBFLAGS */
-#define B44_SBIDLOW	0x0FF8UL /* SB Identification Low */
-#define  SBIDLOW_CS_MASK	0x00000003 /* Config Space Mask */
-#define  SBIDLOW_AR_MASK	0x00000038 /* Num Address Ranges Supported */
-#define  SBIDLOW_AR_SHIFT	3
-#define  SBIDLOW_SYNCH		0x00000040 /* Sync */
-#define  SBIDLOW_INIT		0x00000080 /* Initiator */
-#define  SBIDLOW_MINLAT_MASK	0x00000f00 /* Minimum Backplane Latency */
-#define  SBIDLOW_MINLAT_SHIFT	8
-#define  SBIDLOW_MAXLAT_MASK	0x0000f000 /* Maximum Backplane Latency */
-#define  SBIDLOW_MAXLAT_SHIFT	12
-#define  SBIDLOW_FIRST		0x00010000 /* This Initiator is First */
-#define  SBIDLOW_CW_MASK	0x000c0000 /* Cycle Counter Width */
-#define  SBIDLOW_CW_SHIFT	18
-#define  SBIDLOW_TP_MASK	0x00f00000 /* Target Ports */
-#define  SBIDLOW_TP_SHIFT	20
-#define  SBIDLOW_IP_MASK	0x0f000000 /* Initiator Ports */
-#define  SBIDLOW_IP_SHIFT	24
 #define B44_SBIDHIGH	0x0FFCUL /* SB Identification High */
 #define  SBIDHIGH_RC_MASK	0x0000000f /* Revision Code */
 #define  SBIDHIGH_CC_MASK	0x0000fff0 /* Core Code */
@@ -356,23 +263,13 @@
 #define  SBIDHIGH_VC_MASK	0xffff0000 /* Vendor Code */
 #define  SBIDHIGH_VC_SHIFT	16
=20
-#define  CORE_CODE_ILINE20	0x801
-#define  CORE_CODE_SDRAM	0x803
-#define  CORE_CODE_PCI		0x804
-#define  CORE_CODE_MIPS		0x805
-#define  CORE_CODE_ENET		0x806
-#define  CORE_CODE_CODEC	0x807
-#define  CORE_CODE_USB		0x808
-#define  CORE_CODE_ILINE100	0x80a
-#define  CORE_CODE_EXTIF	0x811
-
 /* SSB PCI config space registers.  */
 #define	SSB_BAR0_WIN		0x80
 #define	SSB_BAR1_WIN		0x84
 #define	SSB_SPROM_CONTROL	0x88
 #define	SSB_BAR1_CONTROL	0x8c
=20
-/* SSB core and hsot control registers.  */
+/* SSB core and host control registers.  */
 #define SSB_CONTROL		0x0000UL
 #define SSB_ARBCONTROL		0x0010UL
 #define SSB_ISTAT		0x0020UL
@@ -500,6 +397,7 @@
=20
 	struct ring_info	*rx_buffers;
 	struct ring_info	*tx_buffers;
+	unsigned char		*tx_bufs;=20
=20
 	u32			dma_offset;
 	u32			flags;
@@ -531,12 +429,11 @@
 	struct pci_dev		*pdev;
 	struct net_device	*dev;
=20
-	dma_addr_t		rx_ring_dma, tx_ring_dma;
+	dma_addr_t		rx_ring_dma, tx_ring_dma,tx_bufs_dma;
=20
 	u32			rx_pending;
 	u32			tx_pending;
 	u8			phy_addr;
-	u8			mdc_port;
 	u8			core_unit;
=20
 	struct mii_if_info	mii_if;
diff -Nru a/drivers/net/depca.c b/drivers/net/depca.c
--- a/drivers/net/depca.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/depca.c	2004-10-21 22:09:44 -04:00
@@ -1222,10 +1222,10 @@
 		/* clear IDON by writing a "1", enable interrupts and start lance */
 		outw(IDON | INEA | STRT, DEPCA_DATA);
 		if (depca_debug > 2) {
-			printk("%s: DEPCA open after %d ticks, init block 0x%08lx csr0 %4.4x.=
\n", dev->name, i, virt_to_phys(lp->sh_mem), inw(DEPCA_DATA));
+			printk("%s: DEPCA open after %d ticks, init block 0x%08lx csr0 %4.4x.=
\n", dev->name, i, lp->mem_start, inw(DEPCA_DATA));
 		}
 	} else {
-		printk("%s: DEPCA unopen after %d ticks, init block 0x%08lx csr0 %4.4x=
.\n", dev->name, i, virt_to_phys(lp->sh_mem), inw(DEPCA_DATA));
+		printk("%s: DEPCA unopen after %d ticks, init block 0x%08lx csr0 %4.4x=
.\n", dev->name, i, lp->mem_start, inw(DEPCA_DATA));
 		status =3D -1;
 	}
=20
@@ -1901,7 +1901,7 @@
 			}
 		}
 		printk("...0x%8.8x\n", readl(&lp->tx_ring[i].base));
-		printk("Initialisation block at 0x%8.8lx(Phys)\n", virt_to_phys(lp->sh=
_mem));
+		printk("Initialisation block at 0x%8.8lx(Phys)\n", lp->mem_start);
 		printk("        mode: 0x%4.4x\n", p->mode);
 		printk("        physical address: ");
 		for (i =3D 0; i < ETH_ALEN - 1; i++) {
@@ -1915,7 +1915,7 @@
 		printk("%2.2x\n", p->mcast_table[i]);
 		printk("        rx_ring at: 0x%8.8x\n", p->rx_ring);
 		printk("        tx_ring at: 0x%8.8x\n", p->tx_ring);
-		printk("buffers (Phys): 0x%8.8lx\n", virt_to_phys(lp->sh_mem) + lp->bu=
ffs_offset);
+		printk("buffers (Phys): 0x%8.8lx\n", lp->mem_start + lp->buffs_offset)=
;
 		printk("Ring size:\nRX: %d  Log2(rxRingMask): 0x%8.8x\n", (int) lp->rx=
RingMask + 1, lp->rx_rlen);
 		printk("TX: %d  Log2(txRingMask): 0x%8.8x\n", (int) lp->txRingMask + 1=
, lp->tx_rlen);
 		outw(CSR2, DEPCA_ADDR);
diff -Nru a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/forcedeth.c	2004-10-21 22:09:44 -04:00
@@ -76,6 +76,9 @@
  *			   for registers, link status and other minor fixes.
  *	0.28: 21 Jun 2004: Big cleanup, making driver mostly endian safe
  *	0.29: 31 Aug 2004: Add backup timer for link change notification.
+ *	0.30: 25 Sep 2004: rx checksum support for nf 250 Gb. Add rx reset
+ *			   into nv_close, otherwise reenabling for wol can
+ *			   cause DMA to kfree'd memory.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -87,7 +90,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating=
 a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.29"
+#define FORCEDETH_VERSION		"0.30"
 #define DRV_NAME			"forcedeth"
=20
 #include <linux/module.h>
@@ -217,6 +220,7 @@
 #define NVREG_TXRXCTL_BIT2	0x0004
 #define NVREG_TXRXCTL_IDLE	0x0008
 #define NVREG_TXRXCTL_RESET	0x0010
+#define NVREG_TXRXCTL_RXCHECK	0x0400
 	NvRegMIIStatus =3D 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
@@ -313,6 +317,10 @@
 #define NV_RX_ERROR		(1<<30)
 #define NV_RX_AVAIL		(1<<31)
=20
+#define NV_RX2_CHECKSUMMASK	(0x1C000000)
+#define NV_RX2_CHECKSUMOK1	(0x10000000)
+#define NV_RX2_CHECKSUMOK2	(0x14000000)
+#define NV_RX2_CHECKSUMOK3	(0x18000000)
 #define NV_RX2_DESCRIPTORVALID	(1<<29)
 #define NV_RX2_SUBSTRACT1	(1<<25)
 #define NV_RX2_ERROR1		(1<<18)
@@ -371,8 +379,15 @@
 #define POLL_WAIT	(1+HZ/100)
 #define LINK_TIMEOUT	(3*HZ)
=20
+/*=20
+ * desc_ver values:
+ * This field has two purposes:
+ * - Newer nics uses a different ring layout. The layout is selected by
+ *   comparing np->desc_ver with DESC_VER_xy.
+ * - It contains bits that are forced on when writing to NvRegTxRxContro=
l.
+ */
 #define DESC_VER_1	0x0
-#define DESC_VER_2	0x02100
+#define DESC_VER_2	(0x02100|NVREG_TXRXCTL_RXCHECK)
=20
 /* PHY defines */
 #define PHY_OUI_MARVELL	0x5043
@@ -1142,6 +1157,15 @@
 					goto next_pkt;
 				}
 			}
+			Flags &=3D NV_RX2_CHECKSUMMASK;
+			if (Flags =3D=3D NV_RX2_CHECKSUMOK1 ||
+					Flags =3D=3D NV_RX2_CHECKSUMOK2 ||
+					Flags =3D=3D NV_RX2_CHECKSUMOK3) {
+				dprintk(KERN_DEBUG "%s: hw checksum hit!.\n", dev->name);
+				np->rx_skbuff[i]->ip_summed =3D CHECKSUM_UNNECESSARY;
+			} else {
+				dprintk(KERN_DEBUG "%s: hwchecksum miss!.\n", dev->name);
+			}
 		}
 		/* got a valid packet - forward it to the network core */
 		skb =3D np->rx_skbuff[i];
@@ -1634,9 +1658,10 @@
 	spin_lock_irq(&np->lock);
 	nv_stop_tx(dev);
 	nv_stop_rx(dev);
-	base =3D get_hwbase(dev);
+	nv_txrx_reset(dev);
=20
 	/* disable interrupts on the nic or we will lock up */
+	base =3D get_hwbase(dev);
 	writel(0, base + NvRegIrqMask);
 	pci_push(base);
 	dprintk(KERN_INFO "%s: Irqmask is zero again\n", dev->name);
diff -Nru a/drivers/net/sis900.c b/drivers/net/sis900.c
--- a/drivers/net/sis900.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/sis900.c	2004-10-21 22:09:44 -04:00
@@ -140,9 +140,9 @@
 };
=20
 typedef struct _BufferDesc {
-	u32	link;
-	u32	cmdsts;
-	u32	bufptr;
+	u32 link;
+	u32 cmdsts;
+	u32 bufptr;
 } BufferDesc;
=20
 struct sis900_private {
@@ -156,7 +156,7 @@
 	unsigned int cur_phy;
=20
 	struct timer_list timer; /* Link status detection timer. */
-	u8     autong_complete; /* 1: auto-negotiate complete  */
+	u8 autong_complete; /* 1: auto-negotiate complete  */
=20
 	unsigned int cur_rx, dirty_rx; /* producer/comsumer pointers for Tx/Rx =
ring */
 	unsigned int cur_tx, dirty_tx;
@@ -170,7 +170,7 @@
 	dma_addr_t tx_ring_dma;
 	dma_addr_t rx_ring_dma;
=20
-	unsigned int tx_full;			/* The Tx queue is full.    */
+	unsigned int tx_full; /* The Tx queue is full. */
 	u8 host_bridge_rev;
 };
=20
@@ -255,7 +255,8 @@
  *	MAC address is read into @net_dev->dev_addr.
  */
=20
-static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev, stru=
ct net_device *net_dev)
+static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev,
+					struct net_device *net_dev)
 {
 	struct pci_dev *isa_bridge =3D NULL;
 	u8 reg;
@@ -292,7 +293,8 @@
  *	@net_dev->dev_addr.
  */
=20
-static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev, struc=
t net_device *net_dev)
+static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
+					struct net_device *net_dev)
 {
 	long ioaddr =3D net_dev->base_addr;
 	u32 rfcrSave;
@@ -334,7 +336,8 @@
  *	MAC address is read into @net_dev->dev_addr.
  */
=20
-static int __devinit sis96x_get_mac_addr(struct pci_dev * pci_dev, struc=
t net_device *net_dev)
+static int __devinit sis96x_get_mac_addr(struct pci_dev * pci_dev,
+					struct net_device *net_dev)
 {
 	long ioaddr =3D net_dev->base_addr;
 	long ee_addr =3D ioaddr + mear;
@@ -371,7 +374,8 @@
  *	ie: sis900_open(), sis900_start_xmit(), sis900_close(), etc.
  */
=20
-static int __devinit sis900_probe (struct pci_dev *pci_dev, const struct=
 pci_device_id *pci_id)
+static int __devinit sis900_probe(struct pci_dev *pci_dev,
+				const struct pci_device_id *pci_id)
 {
 	struct sis900_private *sis_priv;
 	struct net_device *net_dev;
@@ -522,7 +526,7 @@
  *	return error if it failed to found.
  */
=20
-static int __init sis900_mii_probe (struct net_device * net_dev)
+static int __init sis900_mii_probe(struct net_device * net_dev)
 {
 	struct sis900_private * sis_priv =3D net_dev->priv;
 	u16 poll_bit =3D MII_STAT_LINK, status =3D 0;
@@ -572,9 +576,10 @@
 				mii_phy->phy_types =3D mii_chip_table[i].phy_types;
 				if (mii_chip_table[i].phy_types =3D=3D MIX)
 					mii_phy->phy_types =3D
-						(mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HOM=
E;
+					    (mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : =
HOME;
 				printk(KERN_INFO "%s: %s transceiver found at address %d.\n",
-				       net_dev->name, mii_chip_table[i].name, phy_addr);
+				       net_dev->name, mii_chip_table[i].name,
+				       phy_addr);
 				break;
 			}
 		=09
@@ -587,7 +592,7 @@
 =09
 	if (sis_priv->mii =3D=3D NULL) {
 		printk(KERN_INFO "%s: No MII transceivers found!\n",
-		       net_dev->name);
+			net_dev->name);
 		return 0;
 	}
=20
@@ -611,7 +616,8 @@
=20
 			poll_bit ^=3D (mdio_read(net_dev, sis_priv->cur_phy, MII_STATUS) & po=
ll_bit);
 			if (time_after_eq(jiffies, timeout)) {
-				printk(KERN_WARNING "%s: reset phy and link down now\n", net_dev->na=
me);
+				printk(KERN_WARNING "%s: reset phy and link down now\n",
+					net_dev->name);
 				return -ETIME;
 			}
 		}
@@ -647,38 +653,41 @@
 static u16 sis900_default_phy(struct net_device * net_dev)
 {
 	struct sis900_private * sis_priv =3D net_dev->priv;
- 	struct mii_phy *phy =3D NULL, *phy_home =3D NULL, *default_phy =3D NUL=
L, *phy_lan =3D NULL;
+ 	struct mii_phy *phy =3D NULL, *phy_home =3D NULL,=20
+		*default_phy =3D NULL, *phy_lan =3D NULL;
 	u16 status;
=20
-        for( phy=3Dsis_priv->first_mii; phy; phy=3Dphy->next ){
+        for (phy=3Dsis_priv->first_mii; phy; phy=3Dphy->next) {
 		status =3D mdio_read(net_dev, phy->phy_addr, MII_STATUS);
 		status =3D mdio_read(net_dev, phy->phy_addr, MII_STATUS);
=20
 		/* Link ON & Not select default PHY & not ghost PHY */
-		 if ( (status & MII_STAT_LINK) && !default_phy && (phy->phy_types !=3D=
 UNKNOWN) )
+		 if ((status & MII_STAT_LINK) && !default_phy &&
+					(phy->phy_types !=3D UNKNOWN))
 		 	default_phy =3D phy;
-		 else{
+		 else {
 			status =3D mdio_read(net_dev, phy->phy_addr, MII_CONTROL);
 			mdio_write(net_dev, phy->phy_addr, MII_CONTROL,
 				status | MII_CNTL_AUTO | MII_CNTL_ISOLATE);
-			if( phy->phy_types =3D=3D HOME )
+			if (phy->phy_types =3D=3D HOME)
 				phy_home =3D phy;
-			else if (phy->phy_types =3D=3D LAN)
+			else if(phy->phy_types =3D=3D LAN)
 				phy_lan =3D phy;
 		 }
 	}
=20
-	if( !default_phy && phy_home )
+	if (!default_phy && phy_home)
 		default_phy =3D phy_home;
-	else if( !default_phy && phy_lan )
+	else if (!default_phy && phy_lan)
 		default_phy =3D phy_lan;
-	else if ( !default_phy )
+	else if (!default_phy)
 		default_phy =3D sis_priv->first_mii;
=20
-	if( sis_priv->mii !=3D default_phy ){
+	if (sis_priv->mii !=3D default_phy) {
 		sis_priv->mii =3D default_phy;
 		sis_priv->cur_phy =3D default_phy->phy_addr;
-		printk(KERN_INFO "%s: Using transceiver found at address %d as default=
\n", net_dev->name,sis_priv->cur_phy);
+		printk(KERN_INFO "%s: Using transceiver found at address %d as default=
\n",
+					net_dev->name,sis_priv->cur_phy);
 	}
 =09
 	status =3D mdio_read(net_dev, sis_priv->cur_phy, MII_CONTROL);
@@ -701,7 +710,7 @@
  *	mii status register. It's necessary before auto-negotiate.
  */
 =20
-static void sis900_set_capability( struct net_device *net_dev , struct m=
ii_phy *phy )
+static void sis900_set_capability(struct net_device *net_dev, struct mii=
_phy *phy)
 {
 	u16 cap;
 	u16 status;
@@ -851,7 +860,8 @@
  *	please see SiS7014 or ICS spec
  */
=20
-static void mdio_write(struct net_device *net_dev, int phy_id, int locat=
ion, int value)
+static void mdio_write(struct net_device *net_dev, int phy_id, int locat=
ion,
+			int value)
 {
 	long mdio_addr =3D net_dev->base_addr + mear;
 	int mii_cmd =3D MIIwrite|(phy_id<<MIIpmdShift)|(location<<MIIregShift);
@@ -939,7 +949,8 @@
 	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
 	sis630_set_eq(net_dev, revision);
=20
-	ret =3D request_irq(net_dev->irq, &sis900_interrupt, SA_SHIRQ, net_dev-=
>name, net_dev);
+	ret =3D request_irq(net_dev->irq, &sis900_interrupt, SA_SHIRQ,
+						net_dev->name, net_dev);
 	if (ret)
 		return ret;
=20
@@ -1136,48 +1147,55 @@
 		return;
=20
 	if (netif_carrier_ok(net_dev)) {
-		reg14h=3Dmdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
-		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, (0x2200 | reg14h) & 0=
xBFFF);
+		reg14h =3D mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
+		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
+					(0x2200 | reg14h) & 0xBFFF);
 		for (i=3D0; i < maxcount; i++) {
-			eq_value=3D(0x00F8 & mdio_read(net_dev, sis_priv->cur_phy, MII_RESV))=
 >> 3;
+			eq_value =3D (0x00F8 & mdio_read(net_dev,
+					sis_priv->cur_phy, MII_RESV)) >> 3;
 			if (i =3D=3D 0)
 				max_value=3Dmin_value=3Deq_value;
-			max_value=3D(eq_value > max_value) ? eq_value : max_value;
-			min_value=3D(eq_value < min_value) ? eq_value : min_value;
+			max_value =3D (eq_value > max_value) ?
+						eq_value : max_value;
+			min_value =3D (eq_value < min_value) ?
+						eq_value : min_value;
 		}
 		/* 630E rule to determine the equalizer value */
 		if (revision =3D=3D SIS630E_900_REV || revision =3D=3D SIS630EA1_900_R=
EV ||
 		    revision =3D=3D SIS630ET_900_REV) {
 			if (max_value < 5)
-				eq_value=3Dmax_value;
+				eq_value =3D max_value;
 			else if (max_value >=3D 5 && max_value < 15)
-				eq_value=3D(max_value =3D=3D min_value) ? max_value+2 : max_value+1;
+				eq_value =3D (max_value =3D=3D min_value) ?
+						max_value+2 : max_value+1;
 			else if (max_value >=3D 15)
-				eq_value=3D(max_value =3D=3D min_value) ? max_value+6 : max_value+5;
+				eq_value=3D(max_value =3D=3D min_value) ?
+						max_value+6 : max_value+5;
 		}
 		/* 630B0&B1 rule to determine the equalizer value */
 		if (revision =3D=3D SIS630A_900_REV &&=20
 		    (sis_priv->host_bridge_rev =3D=3D SIS630B0 ||=20
 		     sis_priv->host_bridge_rev =3D=3D SIS630B1)) {
 			if (max_value =3D=3D 0)
-				eq_value=3D3;
+				eq_value =3D 3;
 			else
-				eq_value=3D(max_value+min_value+1)/2;
+				eq_value =3D (max_value + min_value + 1)/2;
 		}
 		/* write equalizer value and setting */
-		reg14h=3Dmdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
-		reg14h=3D(reg14h & 0xFF07) | ((eq_value << 3) & 0x00F8);
-		reg14h=3D(reg14h | 0x6000) & 0xFDFF;
+		reg14h =3D mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
+		reg14h =3D (reg14h & 0xFF07) | ((eq_value << 3) & 0x00F8);
+		reg14h =3D (reg14h | 0x6000) & 0xFDFF;
 		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, reg14h);
-	}
-	else {
-		reg14h=3Dmdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
+	} else {
+		reg14h =3D mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
 		if (revision =3D=3D SIS630A_900_REV &&=20
 		    (sis_priv->host_bridge_rev =3D=3D SIS630B0 ||=20
 		     sis_priv->host_bridge_rev =3D=3D SIS630B1))=20
-			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, (reg14h | 0x2200) & =
0xBFFF);
+			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
+						(reg14h | 0x2200) & 0xBFFF);
 		else
-			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, (reg14h | 0x2000) & =
0xBFFF);
+			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
+						(reg14h | 0x2000) & 0xBFFF);
 	}
 	return;
 }
@@ -1205,7 +1223,8 @@
 		sis900_read_mode(net_dev, &speed, &duplex);
 		if (duplex){
 			sis900_set_mode(net_dev->base_addr, speed, duplex);
-			pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision=
);
+			pci_read_config_byte(sis_priv->pci_dev,
+						PCI_CLASS_REVISION, &revision);
 			sis630_set_eq(net_dev, revision);
 			netif_start_queue(net_dev);
 		}
@@ -1229,9 +1248,8 @@
 			sis900_check_mode(net_dev, mii_phy);
 			netif_carrier_on(net_dev);
 		}
-	}
+	} else {
 	/* Link ON -> OFF */
-	else {
                 if (!(status & MII_STAT_LINK)){
                 	netif_carrier_off(net_dev);
                 	printk(KERN_INFO "%s: Media Link Off\n", net_dev->name)=
;
@@ -1241,7 +1259,8 @@
 			    ((mii_phy->phy_id1 & 0xFFF0) =3D=3D 0x8000))
                			sis900_reset_phy(net_dev,  sis_priv->cur_phy);
  =20
-                	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVIS=
ION, &revision);
+                	pci_read_config_byte(sis_priv->pci_dev,
+					PCI_CLASS_REVISION, &revision);
 			sis630_set_eq(net_dev, revision);
  =20
                 	goto LookForLink;
@@ -1264,18 +1283,18 @@
  *	and autong_complete should be set to 1.
  */
=20
-static void sis900_check_mode (struct net_device *net_dev, struct mii_ph=
y *mii_phy)
+static void sis900_check_mode(struct net_device *net_dev, struct mii_phy=
 *mii_phy)
 {
 	struct sis900_private *sis_priv =3D net_dev->priv;
 	long ioaddr =3D net_dev->base_addr;
 	int speed, duplex;
=20
-	if( mii_phy->phy_types =3D=3D LAN  ){
-		outl( ~EXD & inl( ioaddr + cfg ), ioaddr + cfg);
+	if (mii_phy->phy_types =3D=3D LAN) {
+		outl(~EXD & inl(ioaddr + cfg), ioaddr + cfg);
 		sis900_set_capability(net_dev , mii_phy);
 		sis900_auto_negotiate(net_dev, sis_priv->cur_phy);
-	}else{
-		outl(EXD | inl( ioaddr + cfg ), ioaddr + cfg);
+	} else {
+		outl(EXD | inl(ioaddr + cfg), ioaddr + cfg);
 		speed =3D HW_SPEED_HOME;
 		duplex =3D FDX_CAPABLE_HALF_SELECTED;
 		sis900_set_mode(ioaddr, speed, duplex);
@@ -1300,20 +1319,20 @@
 {
 	u32 tx_flags =3D 0, rx_flags =3D 0;
=20
-	if( inl(ioaddr + cfg) & EDB_MASTER_EN ){
-		tx_flags =3D TxATP | (DMA_BURST_64 << TxMXDMA_shift) | (TX_FILL_THRESH=
 << TxFILLT_shift);
+	if (inl(ioaddr + cfg) & EDB_MASTER_EN) {
+		tx_flags =3D TxATP | (DMA_BURST_64 << TxMXDMA_shift) |
+					(TX_FILL_THRESH << TxFILLT_shift);
 		rx_flags =3D DMA_BURST_64 << RxMXDMA_shift;
-	}
-	else{
-		tx_flags =3D TxATP | (DMA_BURST_512 << TxMXDMA_shift) | (TX_FILL_THRES=
H << TxFILLT_shift);
+	} else {
+		tx_flags =3D TxATP | (DMA_BURST_512 << TxMXDMA_shift) |
+					(TX_FILL_THRESH << TxFILLT_shift);
 		rx_flags =3D DMA_BURST_512 << RxMXDMA_shift;
 	}
=20
-	if (speed =3D=3D HW_SPEED_HOME || speed =3D=3D HW_SPEED_10_MBPS ) {
+	if (speed =3D=3D HW_SPEED_HOME || speed =3D=3D HW_SPEED_10_MBPS) {
 		rx_flags |=3D (RxDRNT_10 << RxDRNT_shift);
 		tx_flags |=3D (TxDRNT_10 << TxDRNT_shift);
-	}
-	else {
+	} else {
 		rx_flags |=3D (RxDRNT_100 << RxDRNT_shift);
 		tx_flags |=3D (TxDRNT_100 << TxDRNT_shift);
 	}
@@ -1403,19 +1422,19 @@
 	sis_priv->autong_complete =3D 1;
=20
 	/* Workaround for Realtek RTL8201 PHY issue */
-	if((phy->phy_id0 =3D=3D 0x0000) && ((phy->phy_id1 & 0xFFF0) =3D=3D 0x82=
00)){
-		if(mdio_read(net_dev, phy_addr, MII_CONTROL) & MII_CNTL_FDX)
+	if ((phy->phy_id0 =3D=3D 0x0000) && ((phy->phy_id1 & 0xFFF0) =3D=3D 0x8=
200)) {
+		if (mdio_read(net_dev, phy_addr, MII_CONTROL) & MII_CNTL_FDX)
 			*duplex =3D FDX_CAPABLE_FULL_SELECTED;
-		if(mdio_read(net_dev, phy_addr, 0x0019) & 0x01)
+		if (mdio_read(net_dev, phy_addr, 0x0019) & 0x01)
 			*speed =3D HW_SPEED_100_MBPS;
 	}
=20
 	printk(KERN_INFO "%s: Media Link On %s %s-duplex \n",
-	       net_dev->name,
-	       *speed =3D=3D HW_SPEED_100_MBPS ?
-	       "100mbps" : "10mbps",
-	       *duplex =3D=3D FDX_CAPABLE_FULL_SELECTED ?
-	       "full" : "half");
+	       				net_dev->name,
+	       				*speed =3D=3D HW_SPEED_100_MBPS ?
+	       					"100mbps" : "10mbps",
+	       				*duplex =3D=3D FDX_CAPABLE_FULL_SELECTED ?
+	       					"full" : "half");
 }
=20
 /**
@@ -1677,13 +1696,13 @@
 			sis_priv->stats.rx_bytes +=3D rx_size;
 			sis_priv->stats.rx_packets++;
=20
-			/* refill the Rx buffer, what if there is not enought memory for
-			   new socket buffer ?? */
+			/* refill the Rx buffer, what if there is not enought
+			 * memory for new socket buffer ?? */
 			if ((skb =3D dev_alloc_skb(RX_BUF_SIZE)) =3D=3D NULL) {
-				/* not enough memory for skbuff, this makes a "hole"
-				   on the buffer ring, it is not clear how the
-				   hardware will react to this kind of degenerated
-				   buffer */
+				/* not enough memory for skbuff, this makes a
+				 * "hole" on the buffer ring, it is not clear
+				 * how the hardware will react to this kind
+				 * of degenerated buffer */
 				printk(KERN_INFO "%s: Memory squeeze,"
 				       "deferring packet.\n",
 				       net_dev->name);
@@ -1707,8 +1726,8 @@
 		rx_status =3D sis_priv->rx_ring[entry].cmdsts;
 	} // while
=20
-	/* refill the Rx buffer, what if the rate of refilling is slower than=20
-	   consuming ?? */
+	/* refill the Rx buffer, what if the rate of refilling is slower
+	 * than consuming ?? */
 	for (;sis_priv->cur_rx - sis_priv->dirty_rx > 0; sis_priv->dirty_rx++) =
{
 		struct sk_buff *skb;
=20
@@ -1716,10 +1735,10 @@
=20
 		if (sis_priv->rx_skbuff[entry] =3D=3D NULL) {
 			if ((skb =3D dev_alloc_skb(RX_BUF_SIZE)) =3D=3D NULL) {
-				/* not enough memory for skbuff, this makes a "hole"
-				   on the buffer ring, it is not clear how the=20
-				   hardware will react to this kind of degenerated=20
-				   buffer */
+				/* not enough memory for skbuff, this makes a
+				 * "hole" on the buffer ring, it is not clear
+				 * how the hardware will react to this kind
+				 * of degenerated buffer */
 				printk(KERN_INFO "%s: Memory squeeze,"
 				       "deferring packet.\n",
 				       net_dev->name);
@@ -1764,8 +1783,8 @@
=20
 		if (tx_status & OWN) {
 			/* The packet is not transmitted yet (owned by hardware) !
-			   Note: the interrupt is generated only when Tx Machine
-			   is idle, so this is an almost impossible case */
+			 * Note: the interrupt is generated only when Tx Machine
+			 * is idle, so this is an almost impossible case */
 			break;
 		}
=20
@@ -1803,8 +1822,8 @@
=20
 	if (sis_priv->tx_full && netif_queue_stopped(net_dev) &&
 	    sis_priv->cur_tx - sis_priv->dirty_tx < NUM_TX_DESC - 4) {
-		/* The ring is no longer full, clear tx_full and schedule more transmi=
ssion
-		   by netif_wake_queue(net_dev) */
+		/* The ring is no longer full, clear tx_full and schedule
+		 * more transmission by netif_wake_queue(net_dev) */
 		sis_priv->tx_full =3D 0;
 		netif_wake_queue (net_dev);
 	}
@@ -1818,8 +1837,7 @@
  *	free Tx and RX socket buffer
  */
=20
-static int
-sis900_close(struct net_device *net_dev)
+static int sis900_close(struct net_device *net_dev)
 {
 	long ioaddr =3D net_dev->base_addr;
 	struct sis900_private *sis_priv =3D net_dev->priv;
@@ -1955,27 +1973,28 @@
=20
 	if ((map->port !=3D (u_char)(-1)) && (map->port !=3D dev->if_port)) {
 		/* we switch on the ifmap->port field. I couldn't find anything
-		   like a definition or standard for the values of that field.
-		   I think the meaning of those values is device specific. But
-		   since I would like to change the media type via the ifconfig
-		   command I use the definition from linux/netdevice.h=20
-		   (which seems to be different from the ifport(pcmcia) definition)=20
-		*/
+		 * like a definition or standard for the values of that field.
+		 * I think the meaning of those values is device specific. But
+		 * since I would like to change the media type via the ifconfig
+		 * command I use the definition from linux/netdevice.h=20
+		 * (which seems to be different from the ifport(pcmcia) definition) */
 		switch(map->port){
 		case IF_PORT_UNKNOWN: /* use auto here */  =20
 			dev->if_port =3D map->port;
-			/* we are going to change the media type, so the Link will
-			   be temporary down and we need to reflect that here. When
-			   the Link comes up again, it will be sensed by the sis_timer
-			   procedure, which also does all the rest for us */
+			/* we are going to change the media type, so the Link
+			 * will be temporary down and we need to reflect that
+			 * here. When the Link comes up again, it will be
+			 * sensed by the sis_timer procedure, which also does
+			 * all the rest for us */
 			netif_carrier_off(dev);
                =20
 			/* read current state */
 			status =3D mdio_read(dev, mii_phy->phy_addr, MII_CONTROL);
                =20
 			/* enable auto negotiation and reset the negotioation
-			   (I don't really know what the auto negatiotiation reset
-			   really means, but it sounds for me right to do one here)*/
+			 * (I don't really know what the auto negatiotiation
+			 * reset really means, but it sounds for me right to
+			 * do one here) */
 			mdio_write(dev, mii_phy->phy_addr,
 				   MII_CONTROL, status | MII_CNTL_AUTO | MII_CNTL_RST_AUTO);
=20
@@ -1984,10 +2003,11 @@
 		case IF_PORT_10BASET: /* 10BaseT */        =20
 			dev->if_port =3D map->port;
                =20
-			/* we are going to change the media type, so the Link will
-			   be temporary down and we need to reflect that here. When
-			   the Link comes up again, it will be sensed by the sis_timer
-			   procedure, which also does all the rest for us */
+			/* we are going to change the media type, so the Link
+			 * will be temporary down and we need to reflect that
+			 * here. When the Link comes up again, it will be
+			 * sensed by the sis_timer procedure, which also does
+			 * all the rest for us */
 			netif_carrier_off(dev);
        =20
 			/* set Speed to 10Mbps */
@@ -1996,24 +2016,27 @@
                =20
 			/* disable auto negotiation and force 10MBit mode*/
 			mdio_write(dev, mii_phy->phy_addr,
-				   MII_CONTROL, status & ~(MII_CNTL_SPEED | MII_CNTL_AUTO));
+				   MII_CONTROL, status & ~(MII_CNTL_SPEED |
+					MII_CNTL_AUTO));
 			break;
            =20
 		case IF_PORT_100BASET: /* 100BaseT */
 		case IF_PORT_100BASETX: /* 100BaseTx */=20
 			dev->if_port =3D map->port;
                =20
-			/* we are going to change the media type, so the Link will
-			   be temporary down and we need to reflect that here. When
-			   the Link comes up again, it will be sensed by the sis_timer
-			   procedure, which also does all the rest for us */
+			/* we are going to change the media type, so the Link
+			 * will be temporary down and we need to reflect that
+			 * here. When the Link comes up again, it will be
+			 * sensed by the sis_timer procedure, which also does
+			 * all the rest for us */
 			netif_carrier_off(dev);
                =20
 			/* set Speed to 100Mbps */
 			/* disable auto negotiation and enable 100MBit Mode */
 			status =3D mdio_read(dev, mii_phy->phy_addr, MII_CONTROL);
 			mdio_write(dev, mii_phy->phy_addr,
-				   MII_CONTROL, (status & ~MII_CNTL_SPEED) | MII_CNTL_SPEED);
+				   MII_CONTROL, (status & ~MII_CNTL_SPEED) |
+				   MII_CNTL_SPEED);
                =20
 			break;
            =20
@@ -2093,12 +2116,14 @@
 		for (i =3D 0; i < table_entries; i++)
 			mc_filter[i] =3D 0xffff;
 	} else {
-		/* Accept Broadcast packet, destination address matchs our MAC address=
,
-		   use Receive Filter to reject unwanted MCAST packet */
+		/* Accept Broadcast packet, destination address matchs our
+		 * MAC address, use Receive Filter to reject unwanted MCAST
+		 * packets */
 		struct dev_mc_list *mclist;
 		rx_mode =3D RFAAB;
-		for (i =3D 0, mclist =3D net_dev->mc_list; mclist && i < net_dev->mc_c=
ount;
-		     i++, mclist =3D mclist->next) {
+		for (i =3D 0, mclist =3D net_dev->mc_list;
+			mclist && i < net_dev->mc_count;
+			i++, mclist =3D mclist->next) {
 			unsigned int bit_nr =3D
 				sis900_mcast_bitnr(mclist->dmi_addr, revision);
 			mc_filter[bit_nr >> 4] |=3D (1 << (bit_nr & 0xf));
@@ -2114,7 +2139,8 @@
=20
 	outl(RFEN | rx_mode, ioaddr + rfcr);
=20
-	/* sis900 is capatable of looping back packet at MAC level for debuggin=
g purpose */
+	/* sis900 is capable of looping back packets at MAC level for
+	 * debugging purpose */
 	if (net_dev->flags & IFF_LOOPBACK) {
 		u32 cr_saved;
 		/* We must disable Tx/Rx before setting loopback mode */
diff -Nru a/drivers/net/smc91x.c b/drivers/net/smc91x.c
--- a/drivers/net/smc91x.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/smc91x.c	2004-10-21 22:09:44 -04:00
@@ -55,12 +55,10 @@
  *                                  smc_phy_configure
  *                                - clean up (and fix stack overrun) in =
PHY
  *                                  MII read/write functions
- *   09/15/04  Hayato Fujiwara    - Add m32r support.
- *                                - Modify for SMP kernel; Change spin-l=
ocked
- *                                  regions.
+ *   22/09/04  Nicolas Pitre      big update (see commit log for details=
)
  */
 static const char version[] =3D
-	"smc91x.c: v1.0, mar 07 2003 by Nicolas Pitre <nico@cam.org>\n";
+	"smc91x.c: v1.1, sep 22 2004 by Nicolas Pitre <nico@cam.org>\n";
=20
 /* Debugging level */
 #ifndef SMC_DEBUG
@@ -75,7 +73,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
-#include <linux/timer.h>
+#include <linux/interrupt.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/crc32.h>
@@ -83,6 +81,7 @@
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/workqueue.h>
=20
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -177,7 +176,8 @@
 	 * packet, I will store the skbuff here, until I get the
 	 * desired memory.  Then, I'll send it out and free it.
 	 */
-	struct sk_buff *saved_skb;
+	struct sk_buff *pending_tx_skb;
+	struct tasklet_struct tx_task;
=20
  	/*
 	 * these are things that the kernel wants me to keep, so users
@@ -203,6 +203,8 @@
 	u32	msg_enable;
 	u32	phy_type;
 	struct mii_if_info mii;
+	struct work_struct phy_configure;
+
 	spinlock_t lock;
=20
 #ifdef SMC_USE_PXA_DMA
@@ -215,7 +217,7 @@
 #define DBG(n, args...)					\
 	do {						\
 		if (SMC_DEBUG >=3D (n))			\
-			printk(KERN_DEBUG args);	\
+			printk(args);	\
 	} while (0)
=20
 #define PRINTK(args...)   printk(args)
@@ -260,17 +262,21 @@
 /* this enables an interrupt in the interrupt mask register */
 #define SMC_ENABLE_INT(x) do {						\
 	unsigned char mask;						\
+	spin_lock_irq(&lp->lock);					\
 	mask =3D SMC_GET_INT_MASK();					\
 	mask |=3D (x);							\
 	SMC_SET_INT_MASK(mask);						\
+	spin_unlock_irq(&lp->lock);					\
 } while (0)
=20
 /* this disables an interrupt from the interrupt mask register */
 #define SMC_DISABLE_INT(x) do {						\
 	unsigned char mask;						\
+	spin_lock_irq(&lp->lock);					\
 	mask =3D SMC_GET_INT_MASK();					\
 	mask &=3D ~(x);							\
 	SMC_SET_INT_MASK(mask);						\
+	spin_unlock_irq(&lp->lock);					\
 } while (0)
=20
 /*
@@ -299,10 +305,17 @@
 static void smc_reset(struct net_device *dev)
 {
 	unsigned long ioaddr =3D dev->base_addr;
+	struct smc_local *lp =3D netdev_priv(dev);
 	unsigned int ctl, cfg;
=20
 	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
=20
+	/* Disable all interrupts */
+	spin_lock(&lp->lock);
+	SMC_SELECT_BANK(2);
+	SMC_SET_INT_MASK(0);
+	spin_unlock(&lp->lock);
+
 	/*
 	 * This resets the registers mostly to defaults, but doesn't
 	 * affect EEPROM.  That seems unnecessary
@@ -358,20 +371,24 @@
 	 * transmitted packets, to make the best use out of our limited
 	 * memory
 	 */
-#if ! THROTTLE_TX_PKTS
-	ctl |=3D CTL_AUTO_RELEASE;
-#else
-	ctl &=3D ~CTL_AUTO_RELEASE;
-#endif
+	if(!THROTTLE_TX_PKTS)
+		ctl |=3D CTL_AUTO_RELEASE;
+	else
+		ctl &=3D ~CTL_AUTO_RELEASE;
 	SMC_SET_CTL(ctl);
=20
-	/* Disable all interrupts */
-	SMC_SELECT_BANK(2);
-	SMC_SET_INT_MASK(0);
-
 	/* Reset the MMU */
+	SMC_SELECT_BANK(2);
 	SMC_SET_MMU_CMD(MC_RESET);
 	SMC_WAIT_MMU_BUSY();
+
+	/* clear anything saved */
+	if (lp->pending_tx_skb !=3D NULL) {
+		dev_kfree_skb (lp->pending_tx_skb);
+		lp->pending_tx_skb =3D NULL;
+		lp->stats.tx_errors++;
+		lp->stats.tx_aborted_errors++;
+	}
 }
=20
 /*
@@ -390,24 +407,39 @@
 	SMC_SET_TCR(lp->tcr_cur_mode);
 	SMC_SET_RCR(lp->rcr_cur_mode);
=20
+	SMC_SELECT_BANK(1);
+	SMC_SET_MAC_ADDR(dev->dev_addr);
+
 	/* now, enable interrupts */
 	mask =3D IM_EPH_INT|IM_RX_OVRN_INT|IM_RCV_INT;
 	if (lp->version >=3D (CHIP_91100 << 4))
 		mask |=3D IM_MDINT;
 	SMC_SELECT_BANK(2);
 	SMC_SET_INT_MASK(mask);
+
+	/*
+	 * From this point the register bank must _NOT_ be switched away
+	 * to something else than bank 2 without proper locking against
+	 * races with any tasklet or interrupt handlers until smc_shutdown()
+	 * or smc_reset() is called.
+	 */
 }
=20
 /*
  * this puts the device in an inactive state
  */
-static void smc_shutdown(unsigned long ioaddr)
+static void smc_shutdown(struct net_device *dev)
 {
+	unsigned long ioaddr =3D dev->base_addr;
+	struct smc_local *lp =3D netdev_priv(dev);
+
 	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
=20
 	/* no more interrupts for me */
+	spin_lock(&lp->lock);
 	SMC_SELECT_BANK(2);
 	SMC_SET_INT_MASK(0);
+	spin_unlock(&lp->lock);
=20
 	/* and tell the card to stay away from that nasty outside world */
 	SMC_SELECT_BANK(0);
@@ -449,6 +481,8 @@
 		packet_len, packet_len);
=20
 	if (unlikely(status & RS_ERRORS)) {
+		SMC_WAIT_MMU_BUSY();
+		SMC_SET_MMU_CMD(MC_RELEASE);
 		lp->stats.rx_errors++;
 		if (status & RS_ALGNERR)
 			lp->stats.rx_frame_errors++;
@@ -466,17 +500,21 @@
 			lp->stats.multicast++;
=20
 		/*
-		 * Actual payload is packet_len - 4 (or 3 if odd byte).
+		 * Actual payload is packet_len - 6 (or 5 if odd byte).
 		 * We want skb_reserve(2) and the final ctrl word
 		 * (2 bytes, possibly containing the payload odd byte).
-		 * Ence packet_len - 4 + 2 + 2.
+		 * Furthermore, we add 2 bytes to allow rounding up to
+		 * multiple of 4 bytes on 32 bit buses.
+		 * Ence packet_len - 6 + 2 + 2 + 2.
 		 */
 		skb =3D dev_alloc_skb(packet_len);
 		if (unlikely(skb =3D=3D NULL)) {
 			printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
 				dev->name);
+			SMC_WAIT_MMU_BUSY();
+			SMC_SET_MMU_CMD(MC_RELEASE);
 			lp->stats.rx_dropped++;
-			goto done;
+			return;
 		}
=20
 		/* Align IP header to 32 bits */
@@ -487,14 +525,18 @@
 			status |=3D RS_ODDFRAME;
=20
 		/*
-		 * If odd length: packet_len - 3,
-		 * otherwise packet_len - 4.
+		 * If odd length: packet_len - 5,
+		 * otherwise packet_len - 6.
+		 * With the trailing ctrl byte it's packet_len - 4.
 		 */
-		data_len =3D packet_len - ((status & RS_ODDFRAME) ? 3 : 4);
+		data_len =3D packet_len - ((status & RS_ODDFRAME) ? 5 : 6);
 		data =3D skb_put(skb, data_len);
-		SMC_PULL_DATA(data, packet_len - 2);
+		SMC_PULL_DATA(data, packet_len - 4);
=20
-		PRINT_PKT(data, packet_len - 2);
+		SMC_WAIT_MMU_BUSY();
+		SMC_SET_MMU_CMD(MC_RELEASE);
+
+		PRINT_PKT(data, packet_len - 4);
=20
 		dev->last_rx =3D jiffies;
 		skb->dev =3D dev;
@@ -503,34 +545,76 @@
 		lp->stats.rx_packets++;
 		lp->stats.rx_bytes +=3D data_len;
 	}
-
-done:
-	SMC_WAIT_MMU_BUSY();
-	SMC_SET_MMU_CMD(MC_RELEASE);
 }
=20
+#ifdef CONFIG_SMP
+/*
+ * On SMP we have the following problem:
+ *
+ * 	A =3D smc_hardware_send_pkt()
+ * 	B =3D smc_hard_start_xmit()
+ * 	C =3D smc_interrupt()
+ *
+ * A and B can never be executed simultaneously.  However, at least on U=
P,
+ * it is possible (and even desirable) for C to interrupt execution of
+ * A or B in order to have better RX reliability and avoid overruns.
+ * C, just like A and B, must have exclusive access to the chip and
+ * each of them must lock against any other concurrent access.
+ * Unfortunately this is not possible to have C suspend execution of A o=
r
+ * B taking place on another CPU. On UP this is no an issue since A and =
B
+ * are run from softirq context and C from hard IRQ context, and there i=
s
+ * no other CPU where concurrent access can happen.
+ * If ever there is a way to force at least B and C to always be execute=
d
+ * on the same CPU then we could use read/write locks to protect against
+ * any other concurrent access and C would always interrupt B. But life
+ * isn't that easy in a SMP world...
+ */
+#define smc_special_trylock(lock)					\
+({									\
+	int __ret;							\
+	local_irq_disable();						\
+	__ret =3D spin_trylock(lock);					\
+	if (!__ret)							\
+		local_irq_enable();					\
+	__ret;								\
+})
+#define smc_special_lock(lock)		spin_lock_irq(lock)
+#define smc_special_unlock(lock)	spin_unlock_irq(lock)
+#else
+#define smc_special_trylock(lock)	(1)
+#define smc_special_lock(lock)		do { } while (0)
+#define smc_special_unlock(lock)	do { } while (0)
+#endif
+
 /*
  * This is called to actually send a packet to the chip.
- * Returns non-zero when successful.
  */
-static void smc_hardware_send_packet(struct net_device *dev)
+static void smc_hardware_send_pkt(unsigned long data)
 {
+	struct net_device *dev =3D (struct net_device *)data;
 	struct smc_local *lp =3D netdev_priv(dev);
 	unsigned long ioaddr =3D dev->base_addr;
-	struct sk_buff *skb =3D lp->saved_skb;
+	struct sk_buff *skb;
 	unsigned int packet_no, len;
 	unsigned char *buf;
=20
 	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
=20
+	if (!smc_special_trylock(&lp->lock)) {
+		netif_stop_queue(dev);
+		tasklet_schedule(&lp->tx_task);
+		return;
+	}
+
+	skb =3D lp->pending_tx_skb;
+	lp->pending_tx_skb =3D NULL;
 	packet_no =3D SMC_GET_AR();
 	if (unlikely(packet_no & AR_FAILED)) {
 		printk("%s: Memory allocation failed.\n", dev->name);
-		lp->saved_skb =3D NULL;
 		lp->stats.tx_errors++;
 		lp->stats.tx_fifo_errors++;
-		dev_kfree_skb_any(skb);
-		return;
+		smc_special_unlock(&lp->lock);
+		goto done;
 	}
=20
 	/* point to the beginning of the packet */
@@ -555,15 +639,33 @@
 	/* Send final ctl word with the last byte if there is one */
 	SMC_outw(((len & 1) ? (0x2000 | buf[len-1]) : 0), ioaddr, DATA_REG);
=20
-	/* and let the chipset deal with it */
+	/*
+	 * If THROTTLE_TX_PKTS is set, we look at the TX_EMPTY flag
+	 * before queueing this packet for TX, and if it's clear then
+	 * we stop the queue here.  This will have the effect of
+	 * having at most 2 packets queued for TX in the chip's memory
+	 * at all time. If THROTTLE_TX_PKTS is not set then the queue
+	 * is stopped only when memory allocation (MC_ALLOC) does not
+	 * succeed right away.
+	 */
+	if (THROTTLE_TX_PKTS && !(SMC_GET_INT() & IM_TX_EMPTY_INT))
+		netif_stop_queue(dev);
+
+	/* queue the packet for TX */
 	SMC_SET_MMU_CMD(MC_ENQUEUE);
 	SMC_ACK_INT(IM_TX_EMPTY_INT);
+	smc_special_unlock(&lp->lock);
=20
 	dev->trans_start =3D jiffies;
-	dev_kfree_skb_any(skb);
-	lp->saved_skb =3D NULL;
 	lp->stats.tx_packets++;
 	lp->stats.tx_bytes +=3D len;
+
+	SMC_ENABLE_INT(IM_TX_INT | IM_TX_EMPTY_INT);
+
+done:	if (!THROTTLE_TX_PKTS)
+		netif_wake_queue(dev);
+
+	dev_kfree_skb(skb);
 }
=20
 /*
@@ -576,15 +678,12 @@
 {
 	struct smc_local *lp =3D netdev_priv(dev);
 	unsigned long ioaddr =3D dev->base_addr;
-	unsigned int numPages, poll_count, status, saved_bank;
-	unsigned long flags;
+	unsigned int numPages, poll_count, status;
=20
 	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
=20
-	spin_lock_irqsave(&lp->lock, flags);
-
-	BUG_ON(lp->saved_skb !=3D NULL);
-	lp->saved_skb =3D skb;
+	BUG_ON(lp->pending_tx_skb !=3D NULL);
+	lp->pending_tx_skb =3D skb;
=20
 	/*
 	 * The MMU wants the number of pages to be the number of 256 bytes
@@ -600,17 +699,16 @@
 	numPages =3D ((skb->len & ~1) + (6 - 1)) >> 8;
 	if (unlikely(numPages > 7)) {
 		printk("%s: Far too big packet error.\n", dev->name);
-		lp->saved_skb =3D NULL;
+		lp->pending_tx_skb =3D NULL;
 		lp->stats.tx_errors++;
 		lp->stats.tx_dropped++;
 		dev_kfree_skb(skb);
-		spin_unlock_irqrestore(&lp->lock, flags);
 		return 0;
 	}
=20
+	smc_special_lock(&lp->lock);
+
 	/* now, try to allocate the memory */
-	saved_bank =3D SMC_CURRENT_BANK();
-	SMC_SELECT_BANK(2);
 	SMC_SET_MMU_CMD(MC_ALLOC | numPages);
=20
 	/*
@@ -626,6 +724,8 @@
 		}
    	} while (--poll_count);
=20
+	smc_special_unlock(&lp->lock);
+
    	if (!poll_count) {
 		/* oh well, wait until the chip finds memory later */
 		netif_stop_queue(dev);
@@ -635,25 +735,10 @@
 		/*
 		 * Allocation succeeded: push packet to the chip's own memory
 		 * immediately.
-		 *
-		 * If THROTTLE_TX_PKTS is selected that means we don't want
-		 * more than a single TX packet taking up space in the chip's
-		 * internal memory at all time, in which case we stop the
-		 * queue right here until we're notified of TX completion.
-		 *
-		 * Otherwise we're quite happy to feed more TX packets right
-		 * away for better TX throughput, in which case the queue is
-		 * left active.
 		 */ =20
-#if THROTTLE_TX_PKTS
-		netif_stop_queue(dev);
-#endif
-		smc_hardware_send_packet(dev);
-		SMC_ENABLE_INT(IM_TX_INT | IM_TX_EMPTY_INT);
+		smc_hardware_send_pkt((unsigned long)dev);
 	}
=20
-	SMC_SELECT_BANK(saved_bank);
-	spin_unlock_irqrestore(&lp->lock, flags);
 	return 0;
 }
=20
@@ -767,10 +852,8 @@
 static int smc_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 {
 	unsigned long ioaddr =3D dev->base_addr;
-	unsigned int phydata, old_bank;
+	unsigned int phydata;
=20
-	/* Save the current bank, and select bank 3 */
-	old_bank =3D SMC_CURRENT_BANK();
 	SMC_SELECT_BANK(3);
=20
 	/* Idle - 32 ones */
@@ -785,12 +868,10 @@
 	/* Return to idle state */
 	SMC_SET_MII(SMC_GET_MII() & ~(MII_MCLK|MII_MDOE|MII_MDO));
=20
-	/* And select original bank */
-	SMC_SELECT_BANK(old_bank);
-
 	DBG(3, "%s: phyaddr=3D0x%x, phyreg=3D0x%x, phydata=3D0x%x\n",
 		__FUNCTION__, phyaddr, phyreg, phydata);
=20
+	SMC_SELECT_BANK(2);
 	return phydata;
 }
=20
@@ -801,10 +882,7 @@
 			  int phydata)
 {
 	unsigned long ioaddr =3D dev->base_addr;
-	unsigned int old_bank;
=20
-	/* Save the current bank, and select bank 3 */
-	old_bank =3D SMC_CURRENT_BANK();
 	SMC_SELECT_BANK(3);
=20
 	/* Idle - 32 ones */
@@ -816,11 +894,10 @@
 	/* Return to idle state */
 	SMC_SET_MII(SMC_GET_MII() & ~(MII_MCLK|MII_MDOE|MII_MDO));
=20
-	/* And select original bank */
-	SMC_SELECT_BANK(old_bank);
-
 	DBG(3, "%s: phyaddr=3D0x%x, phyreg=3D0x%x, phydata=3D0x%x\n",
 		__FUNCTION__, phyaddr, phyreg, phydata);
+
+	SMC_SELECT_BANK(2);
 }
=20
 /*
@@ -893,7 +970,9 @@
 	smc_phy_write(dev, phyaddr, MII_BMCR, bmcr);
=20
 	/* Re-Configure the Receive/Phy Control register */
+	SMC_SELECT_BANK(0);
 	SMC_SET_RPC(lp->rpc_cur_mode);
+	SMC_SELECT_BANK(2);
=20
 	return 1;
 }
@@ -941,13 +1020,10 @@
  */
 static void smc_phy_powerdown(struct net_device *dev, int phy)
 {
-	struct smc_local *lp =3D netdev_priv(dev);
 	unsigned int bmcr;
=20
-	spin_lock_irq(&lp->lock);
 	bmcr =3D smc_phy_read(dev, phy, MII_BMCR);
 	smc_phy_write(dev, phy, MII_BMCR, bmcr | BMCR_PDOWN);
-	spin_unlock_irq(&lp->lock);
 }
=20
 /*
@@ -964,8 +1040,6 @@
 	unsigned long ioaddr =3D dev->base_addr;
=20
 	if (mii_check_media(&lp->mii, netif_msg_link(lp), init)) {
-		unsigned int old_bank;
-
 		/* duplex state has changed */
 		if (lp->mii.full_duplex) {
 			lp->tcr_cur_mode |=3D TCR_SWFDUP;
@@ -973,10 +1047,8 @@
 			lp->tcr_cur_mode &=3D ~TCR_SWFDUP;
 		}
=20
-		old_bank =3D SMC_CURRENT_BANK();
 		SMC_SELECT_BANK(0);
 		SMC_SET_TCR(lp->tcr_cur_mode);
-		SMC_SELECT_BANK(old_bank);
 	}
 }
=20
@@ -989,8 +1061,9 @@
  * of autonegotiation.)  If the RPC ANEG bit is cleared, the selection
  * is controlled by the RPC SPEED and RPC DPLX bits.
  */
-static void smc_phy_configure(struct net_device *dev)
+static void smc_phy_configure(void *data)
 {
+	struct net_device *dev =3D data;
 	struct smc_local *lp =3D netdev_priv(dev);
 	unsigned long ioaddr =3D dev->base_addr;
 	int phyaddr =3D lp->mii.phy_id;
@@ -1117,12 +1190,13 @@
 {
 	struct smc_local *lp =3D netdev_priv(dev);
 	unsigned long ioaddr =3D dev->base_addr;
-	unsigned int old_carrier, new_carrier, old_bank;
+	unsigned int old_carrier, new_carrier;
=20
-	old_bank =3D SMC_CURRENT_BANK();
-	SMC_SELECT_BANK(0);
 	old_carrier =3D netif_carrier_ok(dev) ? 1 : 0;
+
+	SMC_SELECT_BANK(0);
 	new_carrier =3D SMC_inw(ioaddr, EPH_STATUS_REG) & ES_LINK_OK ? 1 : 0;
+	SMC_SELECT_BANK(2);
=20
 	if (init || (old_carrier !=3D new_carrier)) {
 		if (!new_carrier) {
@@ -1134,24 +1208,20 @@
 			printk(KERN_INFO "%s: link %s\n", dev->name,
 			       new_carrier ? "up" : "down");
 	}
-	SMC_SELECT_BANK(old_bank);
 }
=20
 static void smc_eph_interrupt(struct net_device *dev)
 {
 	unsigned long ioaddr =3D dev->base_addr;
-	unsigned int old_bank, ctl;
+	unsigned int ctl;
=20
 	smc_10bt_check_media(dev, 0);
=20
-	old_bank =3D SMC_CURRENT_BANK();
 	SMC_SELECT_BANK(1);
-
 	ctl =3D SMC_GET_CTL();
 	SMC_SET_CTL(ctl & ~CTL_LE_ENABLE);
 	SMC_SET_CTL(ctl);
-
-	SMC_SELECT_BANK(old_bank);
+	SMC_SELECT_BANK(2);
 }
=20
 /*
@@ -1164,14 +1234,12 @@
 	unsigned long ioaddr =3D dev->base_addr;
 	struct smc_local *lp =3D netdev_priv(dev);
 	int status, mask, timeout, card_stats;
-	int saved_bank, saved_pointer;
+	int saved_pointer;
=20
 	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
=20
 	spin_lock(&lp->lock);
=20
-	saved_bank =3D SMC_CURRENT_BANK();
-	SMC_SELECT_BANK(2);
 	saved_pointer =3D SMC_GET_PTR();
 	mask =3D SMC_GET_INT_MASK();
 	SMC_SET_INT_MASK(0);
@@ -1182,7 +1250,7 @@
 	do {
 		status =3D SMC_GET_INT();
=20
-		DBG(2, "%s: IRQ 0x%02x MASK 0x%02x MEM 0x%04x FIFO 0x%04x\n",
+		DBG(2, "%s: INT 0x%02x MASK 0x%02x MEM 0x%04x FIFO 0x%04x\n",
 			dev->name, status, mask,
 			({ int meminfo; SMC_SELECT_BANK(0);
 			   meminfo =3D SMC_GET_MIR();
@@ -1200,17 +1268,12 @@
 			DBG(3, "%s: TX int\n", dev->name);
 			smc_tx(dev);
 			SMC_ACK_INT(IM_TX_INT);
-#if THROTTLE_TX_PKTS
-			netif_wake_queue(dev);
-#endif
+			if (THROTTLE_TX_PKTS)
+				netif_wake_queue(dev);
 		} else if (status & IM_ALLOC_INT) {
 			DBG(3, "%s: Allocation irq\n", dev->name);
-			smc_hardware_send_packet(dev);
-			mask |=3D (IM_TX_INT | IM_TX_EMPTY_INT);
+			tasklet_hi_schedule(&lp->tx_task);
 			mask &=3D ~IM_ALLOC_INT;
-#if ! THROTTLE_TX_PKTS
-			netif_wake_queue(dev);
-#endif
 		} else if (status & IM_TX_EMPTY_INT) {
 			DBG(3, "%s: TX empty\n", dev->name);
 			mask &=3D ~IM_TX_EMPTY_INT;
@@ -1240,17 +1303,16 @@
 			SMC_ACK_INT(IM_ERCV_INT);
 			PRINTK("%s: UNSUPPORTED: ERCV INTERRUPT \n", dev->name);
 		}
-
 	} while (--timeout);
=20
 	/* restore register states */
-	SMC_SET_INT_MASK(mask);
 	SMC_SET_PTR(saved_pointer);
-	SMC_SELECT_BANK(saved_bank);
+	SMC_SET_INT_MASK(mask);
+
+	spin_unlock(&lp->lock);
=20
 	DBG(3, "%s: Interrupt done (%d loops)\n", dev->name, 8-timeout);
=20
-	spin_unlock(&lp->lock);
 	/*
 	 * We return IRQ_HANDLED unconditionally here even if there was
 	 * nothing to do.  There is a possibility that a packet might
@@ -1266,101 +1328,39 @@
 static void smc_timeout(struct net_device *dev)
 {
 	struct smc_local *lp =3D netdev_priv(dev);
-	unsigned long flags;
+	unsigned long ioaddr =3D dev->base_addr;
+	int status, mask, meminfo, fifo;
=20
-	spin_lock_irqsave(&lp->lock, flags);
 	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
=20
+	spin_lock_irq(&lp->lock);
+	status =3D SMC_GET_INT();
+	mask =3D SMC_GET_INT_MASK();
+	fifo =3D SMC_GET_FIFO();
+	SMC_SELECT_BANK(0);
+	meminfo =3D SMC_GET_MIR();
+	SMC_SELECT_BANK(2);
+	spin_unlock_irq(&lp->lock);
+	PRINTK( "%s: INT 0x%02x MASK 0x%02x MEM 0x%04x FIFO 0x%04x\n",
+		dev->name, status, mask, meminfo, fifo );
+
 	smc_reset(dev);
 	smc_enable(dev);
=20
-#if 0
 	/*
 	 * Reconfiguring the PHY doesn't seem like a bad idea here, but
-	 * it introduced a problem.  Now that this is a timeout routine,
-	 * we are getting called from within an interrupt context.
-	 * smc_phy_configure() calls msleep() which calls
-	 * schedule_timeout() which calls schedule().  When schedule()
-	 * is called from an interrupt context, it prints out
-	 * "Scheduling in interrupt" and then calls BUG().  This is
-	 * obviously not desirable.  This was worked around by removing
-	 * the call to smc_phy_configure() here because it didn't seem
-	 * absolutely necessary.  Ultimately, if msleep() is
-	 * supposed to be usable from an interrupt context (which it
-	 * looks like it thinks it should handle), it should be fixed.
+	 * smc_phy_configure() calls msleep() which calls schedule_timeout()
+	 * which calls schedule().  Ence we use a work queue.
 	 */
 	if (lp->phy_type !=3D 0)
-		smc_phy_configure(dev);
-#endif
+		schedule_work(&lp->phy_configure);
=20
-	/* clear anything saved */
-	if (lp->saved_skb !=3D NULL) {
-		dev_kfree_skb (lp->saved_skb);
-		lp->saved_skb =3D NULL;
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
-	}
 	/* We can accept TX packets again */
 	dev->trans_start =3D jiffies;
-
-	spin_unlock_irqrestore(&lp->lock, flags);
-
 	netif_wake_queue(dev);
 }
=20
 /*
- *    This sets the internal hardware table to filter out unwanted multi=
cast
- *    packets before they take up memory.
- *
- *    The SMC chip uses a hash table where the high 6 bits of the CRC of
- *    address are the offset into the table.  If that bit is 1, then the
- *    multicast packet is accepted.  Otherwise, it's dropped silently.
- *
- *    To use the 6 bits as an offset into the table, the high 3 bits are=
 the
- *    number of the 8 bit register, while the low 3 bits are the bit wit=
hin
- *    that register.
- *
- *    This routine is based very heavily on the one provided by Peter Ca=
mmaert.
- */
-static void
-smc_setmulticast(unsigned long ioaddr, int count, struct dev_mc_list *ad=
drs)
-{
-	int i;
-	unsigned char multicast_table[8];
-	struct dev_mc_list *cur_addr;
-
-	/* table for flipping the order of 3 bits */
-	static unsigned char invert3[] =3D { 0, 4, 2, 6, 1, 5, 3, 7 };
-
-	/* start with a table of all zeros: reject all */
-	memset(multicast_table, 0, sizeof(multicast_table));
-
-	cur_addr =3D addrs;
-	for (i =3D 0; i < count; i++, cur_addr =3D cur_addr->next) {
-		int position;
-
-		/* do we have a pointer here? */
-		if (!cur_addr)
-			break;
-		/* make sure this is a multicast address - shouldn't this
-		   be a given if we have it here ? */
-		if (!(*cur_addr->dmi_addr & 1))
-			continue;
-
-		/* only use the low order bits */
-		position =3D crc32_le(~0, cur_addr->dmi_addr, 6) & 0x3f;
-
-		/* do some messy swapping to put the bit in the right spot */
-		multicast_table[invert3[position&7]] |=3D
-					(1<<invert3[(position>>3)&7]);
-
-	}
-	/* now, the table can be loaded into the chipset */
-	SMC_SELECT_BANK(3);
-	SMC_SET_MCAST(multicast_table);
-}
-
-/*
  * This routine will, depending on the values passed to it,
  * either make it accept multicast packets, go into
  * promiscuous mode (for TCPDUMP and cousins) or accept
@@ -1370,14 +1370,14 @@
 {
 	struct smc_local *lp =3D netdev_priv(dev);
 	unsigned long ioaddr =3D dev->base_addr;
+	unsigned char multicast_table[8];
+	int update_multicast =3D 0;
=20
 	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
=20
-	SMC_SELECT_BANK(0);
 	if (dev->flags & IFF_PROMISC) {
 		DBG(2, "%s: RCR_PRMS\n", dev->name);
 		lp->rcr_cur_mode |=3D RCR_PRMS;
-		SMC_SET_RCR(lp->rcr_cur_mode);
 	}
=20
 /* BUG?  I never disable promiscuous mode if multicasting was turned on.
@@ -1391,38 +1391,78 @@
 	 * checked before the table is
 	 */
 	else if (dev->flags & IFF_ALLMULTI || dev->mc_count > 16) {
-		lp->rcr_cur_mode |=3D RCR_ALMUL;
-		SMC_SET_RCR(lp->rcr_cur_mode);
 		DBG(2, "%s: RCR_ALMUL\n", dev->name);
+		lp->rcr_cur_mode |=3D RCR_ALMUL;
 	}
=20
 	/*
-	 * We just get all multicast packets even if we only want them
-	 * from one source.  This will be changed at some future point.
+	 * This sets the internal hardware table to filter out unwanted
+	 * multicast packets before they take up memory.
+	 *
+	 * The SMC chip uses a hash table where the high 6 bits of the CRC of
+	 * address are the offset into the table.  If that bit is 1, then the
+	 * multicast packet is accepted.  Otherwise, it's dropped silently.
+	 *
+	 * To use the 6 bits as an offset into the table, the high 3 bits are
+	 * the number of the 8 bit register, while the low 3 bits are the bit
+	 * within that register.
 	 */
 	else if (dev->mc_count)  {
-		/* support hardware multicasting */
+		int i;
+		struct dev_mc_list *cur_addr;
+
+		/* table for flipping the order of 3 bits */
+		static const unsigned char invert3[] =3D {0, 4, 2, 6, 1, 5, 3, 7};
+
+		/* start with a table of all zeros: reject all */
+		memset(multicast_table, 0, sizeof(multicast_table));
+
+		cur_addr =3D dev->mc_list;
+		for (i =3D 0; i < dev->mc_count; i++, cur_addr =3D cur_addr->next) {
+			int position;
+
+			/* do we have a pointer here? */
+			if (!cur_addr)
+				break;
+			/* make sure this is a multicast address -
+		   	   shouldn't this be a given if we have it here ? */
+			if (!(*cur_addr->dmi_addr & 1))
+				continue;
+
+			/* only use the low order bits */
+			position =3D crc32_le(~0, cur_addr->dmi_addr, 6) & 0x3f;
+
+			/* do some messy swapping to put the bit in the right spot */
+			multicast_table[invert3[position&7]] |=3D
+				(1<<invert3[(position>>3)&7]);
+		}
=20
 		/* be sure I get rid of flags I might have set */
 		lp->rcr_cur_mode &=3D ~(RCR_PRMS | RCR_ALMUL);
-		SMC_SET_RCR(lp->rcr_cur_mode);
-		/*
-		 * NOTE: this has to set the bank, so make sure it is the
-		 * last thing called.  The bank is set to zero at the top
-		 */
-		smc_setmulticast(ioaddr, dev->mc_count, dev->mc_list);
+
+		/* now, the table can be loaded into the chipset */
+		update_multicast =3D 1;
 	} else  {
 		DBG(2, "%s: ~(RCR_PRMS|RCR_ALMUL)\n", dev->name);
 		lp->rcr_cur_mode &=3D ~(RCR_PRMS | RCR_ALMUL);
-		SMC_SET_RCR(lp->rcr_cur_mode);
=20
 		/*
 		 * since I'm disabling all multicast entirely, I need to
 		 * clear the multicast list
 		 */
+		memset(multicast_table, 0, sizeof(multicast_table));
+		update_multicast =3D 1;
+	}
+
+	spin_lock_irq(&lp->lock);
+	SMC_SELECT_BANK(0);
+	SMC_SET_RCR(lp->rcr_cur_mode);
+	if (update_multicast) {
 		SMC_SELECT_BANK(3);
-		SMC_CLEAR_MCAST();
+		SMC_SET_MCAST(multicast_table);
 	}
+	SMC_SELECT_BANK(2);
+	spin_unlock_irq(&lp->lock);
 }
=20
=20
@@ -1435,7 +1475,6 @@
 smc_open(struct net_device *dev)
 {
 	struct smc_local *lp =3D netdev_priv(dev);
-	unsigned long ioaddr =3D dev->base_addr;
=20
 	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
=20
@@ -1445,13 +1484,10 @@
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		DBG(2, "smc_open: no valid ethernet hw addr\n");
+		PRINTK("%s: no valid ethernet hw addr\n", __FUNCTION__);
 		return -EINVAL;
 	}
=20
-	/* clear out all the junk that was put here before... */
-	lp->saved_skb =3D NULL;
-
 	/* Setup the default Register Modes */
 	lp->tcr_cur_mode =3D TCR_DEFAULT;
 	lp->rcr_cur_mode =3D RCR_DEFAULT;
@@ -1468,10 +1504,7 @@
 	smc_reset(dev);
 	smc_enable(dev);
=20
-	SMC_SELECT_BANK(1);
-	SMC_SET_MAC_ADDR(dev->dev_addr);
-
-	/* Configure the PHY */
+	/* Configure the PHY, initialize the link state */
 	if (lp->phy_type !=3D 0)
 		smc_phy_configure(dev);
 	else {
@@ -1480,12 +1513,6 @@
 		spin_unlock_irq(&lp->lock);
 	}
=20
-	/*
-	 * make sure to initialize the link state with netif_carrier_off()
-	 * somewhere, too --jgarzik
-	 *
-	 * smc_phy_configure() and smc_10bt_check_media() does that. --rmk
-	 */
 	netif_start_queue(dev);
 	return 0;
 }
@@ -1507,10 +1534,17 @@
 	netif_carrier_off(dev);
=20
 	/* clear everything */
-	smc_shutdown(dev->base_addr);
+	smc_shutdown(dev);
=20
-	if (lp->phy_type !=3D 0)
+	if (lp->phy_type !=3D 0) {
+		flush_scheduled_work();
 		smc_phy_powerdown(dev, lp->mii.phy_id);
+	}
+
+	if (lp->pending_tx_skb) {
+		dev_kfree_skb(lp->pending_tx_skb);
+		lp->pending_tx_skb =3D NULL;
+	}
=20
 	return 0;
 }
@@ -1800,6 +1834,7 @@
 	/* fill in some of the fields */
 	dev->base_addr =3D ioaddr;
 	lp->version =3D revision_register & 0xff;
+	spin_lock_init(&lp->lock);
=20
 	/* Get the MAC address */
 	SMC_SELECT_BANK(1);
@@ -1855,7 +1890,8 @@
 	dev->set_multicast_list =3D smc_set_multicast_list;
 	dev->ethtool_ops =3D &smc_ethtool_ops;
=20
-	spin_lock_init(&lp->lock);
+	tasklet_init(&lp->tx_task, smc_hardware_send_pkt, (unsigned long)dev);
+	INIT_WORK(&lp->phy_configure, smc_phy_configure, dev);
 	lp->mii.phy_id_mask =3D 0x1f;
 	lp->mii.reg_num_mask =3D 0x1f;
 	lp->mii.force_media =3D 0;
@@ -1885,9 +1921,8 @@
       	if (retval)
       		goto err_out;
=20
-#if !defined(__m32r__)
 	set_irq_type(dev->irq, IRQT_RISING);
-#endif
+
 #ifdef SMC_USE_PXA_DMA
 	{
 		int dma =3D pxa_request_dma(dev->name, DMA_PRIO_LOW,
@@ -2121,7 +2156,7 @@
 	if (ndev && level =3D=3D SUSPEND_DISABLE) {
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
-			smc_shutdown(ndev->base_addr);
+			smc_shutdown(ndev);
 		}
 	}
 	return 0;
@@ -2134,15 +2169,12 @@
=20
 	if (ndev && level =3D=3D RESUME_ENABLE) {
 		struct smc_local *lp =3D netdev_priv(ndev);
-		unsigned long ioaddr =3D ndev->base_addr;
=20
 		if (pdev->num_resources =3D=3D 3)
 			smc_enable_device(pdev->resource[2].start);
 		if (netif_running(ndev)) {
 			smc_reset(ndev);
 			smc_enable(ndev);
-			SMC_SELECT_BANK(1);
-			SMC_SET_MAC_ADDR(ndev->dev_addr);
 			if (lp->phy_type !=3D 0)
 				smc_phy_configure(ndev);
 			netif_device_attach(ndev);
diff -Nru a/drivers/net/smc91x.h b/drivers/net/smc91x.h
--- a/drivers/net/smc91x.h	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/smc91x.h	2004-10-21 22:09:44 -04:00
@@ -173,6 +173,11 @@
 #define SMC_insw(a, r, p, l)	insw((a) + (r) - 0xa0000000, p, l)
 #define SMC_outsw(a, r, p, l)	outsw((a) + (r) - 0xa0000000, p, l)
=20
+#define set_irq_type(irq, type)	do {} while(0)
+
+#define RPC_LSA_DEFAULT		RPC_LED_TX_RX
+#define RPC_LSB_DEFAULT		RPC_LED_100_10
+
 #else
=20
 #define SMC_CAN_USE_8BIT	1
@@ -202,8 +207,9 @@
  * different and probably not worth it for that reason, and not as criti=
cal
  * as RX which can overrun memory and lose packets.
  */
-#include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <asm/dma.h>
+#include <asm/arch/pxa-regs.h>
=20
 #ifdef SMC_insl
 #undef SMC_insl
@@ -223,19 +229,21 @@
=20
 	/* 64 bit alignment is required for memory to memory DMA */
 	if ((long)buf & 4) {
-		*((u32 *)buf)++ =3D SMC_inl(ioaddr, reg);
+		*((u32 *)buf) =3D SMC_inl(ioaddr, reg);
+		buf +=3D 4;
 		len--;
 	}
=20
 	len *=3D 4;
-	dmabuf =3D dma_map_single(NULL, buf, len, PCI_DMA_FROMDEVICE);
+	dmabuf =3D dma_map_single(NULL, buf, len, DMA_FROM_DEVICE);
 	DCSR(dma) =3D DCSR_NODESC;
 	DTADR(dma) =3D dmabuf;
 	DSADR(dma) =3D physaddr + reg;
 	DCMD(dma) =3D (DCMD_INCTRGADDR | DCMD_BURST32 |
 		     DCMD_WIDTH4 | (DCMD_LENGTH & len));
 	DCSR(dma) =3D DCSR_NODESC | DCSR_RUN;
-	while (!(DCSR(dma) & DCSR_STOPSTATE));
+	while (!(DCSR(dma) & DCSR_STOPSTATE))
+		cpu_relax();
 	DCSR(dma) =3D 0;
 	dma_unmap_single(NULL, dmabuf, len, PCI_DMA_FROMDEVICE);
 }
@@ -259,7 +267,8 @@
=20
 	/* 64 bit alignment is required for memory to memory DMA */
 	while ((long)buf & 6) {
-		*((u16 *)buf)++ =3D SMC_inw(ioaddr, reg);
+		*((u16 *)buf) =3D SMC_inw(ioaddr, reg);
+		buf +=3D 2;
 		len--;
 	}
=20
@@ -271,9 +280,10 @@
 	DCMD(dma) =3D (DCMD_INCTRGADDR | DCMD_BURST32 |
 		     DCMD_WIDTH2 | (DCMD_LENGTH & len));
 	DCSR(dma) =3D DCSR_NODESC | DCSR_RUN;
-	while (!(DCSR(dma) & DCSR_STOPSTATE));
+	while (!(DCSR(dma) & DCSR_STOPSTATE))
+		cpu_relax();
 	DCSR(dma) =3D 0;
-	dma_unmap_single(NULL, dmabuf, len, PCI_DMA_FROMDEVICE);
+	dma_unmap_single(NULL, dmabuf, len, DMA_FROM_DEVICE);
 }
 #endif
=20
@@ -762,16 +772,9 @@
 		SMC_outw( addr[4]|(addr[5] << 8), ioaddr, ADDR2_REG );	\
 	} while (0)
=20
-#define SMC_CLEAR_MCAST()						\
-	do {								\
-		SMC_outw( 0, ioaddr, MCAST_REG1 );			\
-		SMC_outw( 0, ioaddr, MCAST_REG2 );			\
-		SMC_outw( 0, ioaddr, MCAST_REG3 );			\
-		SMC_outw( 0, ioaddr, MCAST_REG4 );			\
-	} while (0)
 #define SMC_SET_MCAST(x)						\
 	do {								\
-		unsigned char *mt =3D (x);				\
+		const unsigned char *mt =3D (x);				\
 		SMC_outw( mt[0] | (mt[1] << 8), ioaddr, MCAST_REG1 );	\
 		SMC_outw( mt[2] | (mt[3] << 8), ioaddr, MCAST_REG2 );	\
 		SMC_outw( mt[4] | (mt[5] << 8), ioaddr, MCAST_REG3 );	\
diff -Nru a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/l=
anstreamer.c
--- a/drivers/net/tokenring/lanstreamer.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/tokenring/lanstreamer.c	2004-10-21 22:09:44 -04:00
@@ -1606,7 +1606,7 @@
 				i +=3D 2;
 			}
=20
-			memcpy_fromio(skb_put(mac_frame, buffer_len),
+			memcpy(skb_put(mac_frame, buffer_len),
 				      frame_data, buffer_len);
 		} while (next_ptr && (buff_off =3D next_ptr));
=20
diff -Nru a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
--- a/drivers/net/tulip/dmfe.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/tulip/dmfe.c	2004-10-21 22:09:44 -04:00
@@ -92,6 +92,7 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/uaccess.h>
+#include <asm/irq.h>
=20
=20
 /* Board/System/Debug information/definition ---------------- */
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/via-rhine.c	2004-10-21 22:09:44 -04:00
@@ -1957,6 +1957,7 @@
 	rhine_shutdown(&pdev->dev);
 	spin_unlock_irqrestore(&rp->lock, flags);
=20
+	free_irq(dev->irq, dev);
 	return 0;
 }
=20
@@ -1969,6 +1970,9 @@
=20
 	if (!netif_running(dev))
 		return 0;
+
+        if (request_irq(dev->irq, rhine_interrupt, SA_SHIRQ, dev->name, =
dev))
+		printk(KERN_ERR "via-rhine %s: request_irq failed\n", dev->name);
=20
 	ret =3D pci_set_power_state(pdev, 0);
 	if (debug > 1)
diff -Nru a/drivers/net/wireless/prism54/isl_38xx.c b/drivers/net/wireles=
s/prism54/isl_38xx.c
--- a/drivers/net/wireless/prism54/isl_38xx.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/wireless/prism54/isl_38xx.c	2004-10-21 22:09:44 -04:00
@@ -133,8 +133,8 @@
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
 		udelay(ISL38XX_WRITEIO_DELAY);
=20
-		if (reg =3D readl(device_base + ISL38XX_INT_IDENT_REG),
-		    reg =3D=3D 0xabadface) {
+		reg =3D readl(device_base + ISL38XX_INT_IDENT_REG);
+		if (reg =3D=3D 0xabadface) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
 			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
@@ -192,10 +192,8 @@
 void
 isl38xx_interface_reset(void __iomem *device_base, dma_addr_t host_addre=
ss)
 {
-	u32 reg;
-
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset\n");
 #endif
=20
 	/* load the address of the control block in the device */
@@ -203,8 +201,7 @@
 	udelay(ISL38XX_WRITEIO_DELAY);
=20
 	/* set the reset bit in the Device Interrupt Register */
-	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET,
-			  ISL38XX_DEV_INT_REG);
+	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET, ISL38XX_DEV_INT_R=
EG);
 	udelay(ISL38XX_WRITEIO_DELAY);
=20
 	/* enable the interrupt for detecting initialization */
@@ -212,9 +209,7 @@
 	/* Note: Do not enable other interrupts here. We want the
 	 * device to have come up first 100% before allowing any other=20
 	 * interrupts. */
-	reg =3D ISL38XX_INT_IDENT_INIT;
-
-	isl38xx_w32_flush(device_base, reg, ISL38XX_INT_EN_REG);
+	isl38xx_w32_flush(device_base, ISL38XX_INT_IDENT_INIT, ISL38XX_INT_EN_R=
EG);
 	udelay(ISL38XX_WRITEIO_DELAY);  /* allow complete full reset */
 }
=20
diff -Nru a/drivers/net/wireless/prism54/isl_38xx.h b/drivers/net/wireles=
s/prism54/isl_38xx.h
--- a/drivers/net/wireless/prism54/isl_38xx.h	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/wireless/prism54/isl_38xx.h	2004-10-21 22:09:44 -04:00
@@ -95,6 +95,10 @@
 #define ISL38XX_INT_SOURCES                     0x001E
=20
 /* Control/Status register bits */
+/* Looks like there are other meaningful bits
+    0x20004400 seen in normal operation,
+    0x200044db at 'timeout waiting for mgmt response'
+*/
 #define ISL38XX_CTRL_STAT_SLEEPMODE             0x00000200
 #define	ISL38XX_CTRL_STAT_CLKRUN		0x00800000
 #define ISL38XX_CTRL_STAT_RESET                 0x10000000
diff -Nru a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wirele=
ss/prism54/isl_ioctl.c
--- a/drivers/net/wireless/prism54/isl_ioctl.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/wireless/prism54/isl_ioctl.c	2004-10-21 22:09:44 -04:00
@@ -36,38 +36,6 @@
=20
 #include <net/iw_handler.h>	/* New driver API */
=20
-static int init_mode =3D CARD_DEFAULT_IW_MODE;
-static int init_channel =3D CARD_DEFAULT_CHANNEL;
-static int init_wep =3D CARD_DEFAULT_WEP;
-static int init_filter =3D CARD_DEFAULT_FILTER;
-static int init_authen =3D CARD_DEFAULT_AUTHEN;
-static int init_dot1x =3D CARD_DEFAULT_DOT1X;
-static int init_conformance =3D CARD_DEFAULT_CONFORMANCE;
-static int init_mlme =3D CARD_DEFAULT_MLME_MODE;
-
-module_param(init_mode, int, 0);
-MODULE_PARM_DESC(init_mode,
-		 "Set card mode:\n0: Auto\n1: Ad-Hoc\n2: Managed Client (Default)\n3: =
Master / Access Point\n4: Repeater (Not supported yet)\n5: Secondary (Not=
 supported yet)\n6: Monitor");
-
-module_param(init_channel, int, 0);
-MODULE_PARM_DESC(init_channel,
-		 "Check `iwpriv ethx channel` for available channels");
-
-module_param(init_wep, int, 0);
-module_param(init_filter, int, 0);
-
-module_param(init_authen, int, 0);
-MODULE_PARM_DESC(init_authen,
-		 "Authentication method. Can be of seven types:\n0 0x0000: None\n1 0x0=
001: DOT11_AUTH_OS (Default)\n2 0x0002: DOT11_AUTH_SK\n3 0x0003: DOT11_AU=
TH_BOTH");
-
-module_param(init_dot1x, int, 0);
-MODULE_PARM_DESC(init_dot1x,
-		 "\n0: None/not set	(Default)\n1: DOT11_DOT1X_AUTHENABLED\n2: DOT11_DO=
T1X_KEYTXENABLED");
-
-module_param(init_mlme, int, 0);
-MODULE_PARM_DESC(init_mlme,
-		 "Sets the MAC layer management entity (MLME) mode of operation,\n0: D=
OT11_MLME_AUTO (Default)\n1: DOT11_MLME_INTERMEDIATE\n2: DOT11_MLME_EXTEN=
DED");
-
 /**
  * prism54_mib_mode_helper - MIB change mode helper function
  * @mib: the &struct islpci_mib object to modify
@@ -141,36 +109,34 @@
 void
 prism54_mib_init(islpci_private *priv)
 {
-	u32 t;
+	u32 channel, authen, wep, filter, dot1x, mlme, conformance, power, mode=
;
 	struct obj_buffer psm_buffer =3D {
 		.size =3D PSM_BUFFER_SIZE,
 		.addr =3D priv->device_psm_buffer
 	};
=20
-	mgt_set(priv, DOT11_OID_CHANNEL, &init_channel);
-	mgt_set(priv, DOT11_OID_AUTHENABLE, &init_authen);
-	mgt_set(priv, DOT11_OID_PRIVACYINVOKED, &init_wep);
-
+	channel =3D CARD_DEFAULT_CHANNEL;
+	authen =3D CARD_DEFAULT_AUTHEN;
+	wep =3D CARD_DEFAULT_WEP;
+	filter =3D CARD_DEFAULT_FILTER; /* (0) Do not filter un-encrypted data =
*/
+	dot1x =3D CARD_DEFAULT_DOT1X;=20
+	mlme =3D CARD_DEFAULT_MLME_MODE;
+	conformance =3D CARD_DEFAULT_CONFORMANCE;
+	power =3D 127;
+	mode =3D CARD_DEFAULT_IW_MODE;
+
+	mgt_set(priv, DOT11_OID_CHANNEL, &channel);
+	mgt_set(priv, DOT11_OID_AUTHENABLE, &authen);
+	mgt_set(priv, DOT11_OID_PRIVACYINVOKED, &wep);
 	mgt_set(priv, DOT11_OID_PSMBUFFER, &psm_buffer);
-	mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &init_filter);
-	mgt_set(priv, DOT11_OID_DOT1XENABLE, &init_dot1x);
-	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &init_mlme);
-	mgt_set(priv, OID_INL_DOT11D_CONFORMANCE, &init_conformance);
-
-	t =3D 127;
-	mgt_set(priv, OID_INL_OUTPUTPOWER, &t);
-
-	/* Important: we are setting a default wireless mode and we are=20
-	 * forcing a valid one, so prism54_mib_mode_helper should just set
-	 * mib values depending on what the wireless mode given is. No need
-	 * for it save old values */
-	if (init_mode > IW_MODE_MONITOR || init_mode < IW_MODE_AUTO) {
-		printk(KERN_DEBUG "%s(): You passed a non-valid init_mode. "
-		       "Using default mode\n", __FUNCTION__);
-		init_mode =3D CARD_DEFAULT_IW_MODE;
-	}
+	mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &filter);
+	mgt_set(priv, DOT11_OID_DOT1XENABLE, &dot1x);
+	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlme);
+	mgt_set(priv, OID_INL_DOT11D_CONFORMANCE, &conformance);
+	mgt_set(priv, OID_INL_OUTPUTPOWER, &power);
+
 	/* This sets all of the mode-dependent values */
-	prism54_mib_mode_helper(priv, init_mode);
+	prism54_mib_mode_helper(priv, mode);
 }
=20
 /* this will be executed outside of atomic context thanks to
@@ -374,7 +340,10 @@
=20
 	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlmeautolevel);
=20
-	mgt_commit(priv);
+	if (mgt_commit(priv)) {
+		up_write(&priv->mib_sem);
+		return -EIO;
+	}
 	priv->ndev->type =3D (priv->iw_mode =3D=3D IW_MODE_MONITOR)
 	    ? priv->monitor_type : ARPHRD_ETHER;
 	up_write(&priv->mib_sem);
@@ -485,6 +454,15 @@
 	/* txpower is supported in dBm's */
 	range->txpower_capa =3D IW_TXPOW_DBM;
=20
+#if WIRELESS_EXT > 16
+	/* Event capability (kernel + driver) */
+	range->event_capa[0] =3D (IW_EVENT_CAPA_K_0 |
+	IW_EVENT_CAPA_MASK(SIOCGIWTHRSPY) |
+	IW_EVENT_CAPA_MASK(SIOCGIWAP));
+	range->event_capa[1] =3D IW_EVENT_CAPA_K_1;
+	range->event_capa[4] =3D IW_EVENT_CAPA_MASK(IWEVCUSTOM);
+#endif /* WIRELESS_EXT > 16 */
+
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
=20
@@ -629,8 +607,8 @@
 	current_ev =3D iwe_stream_add_point(current_ev, end_buf, &iwe, NULL);
=20
 	/* Add frequency. (short) bss->channel is the frequency in MHz */
-	iwe.u.freq.m =3D channel_of_freq(bss->channel);
-	iwe.u.freq.e =3D 0;
+	iwe.u.freq.m =3D bss->channel;
+	iwe.u.freq.e =3D 6;
 	iwe.cmd =3D SIOCGIWFREQ;
 	current_ev =3D
 	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);
@@ -690,19 +668,33 @@
 	rvalue =3D mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
 	noise =3D r.u;
=20
-	/* Ask the device for a list of known bss. We can report at most
-	 * IW_MAX_AP=3D64 to the range struct. But the device won't repport any=
thing
-	 * if you change the value of IWMAX_BSS=3D24.
-	 */
+	/* Ask the device for a list of known bss.
+	* The old API, using SIOCGIWAPLIST, had a hard limit of IW_MAX_AP=3D64.
+	* The new API, using SIOCGIWSCAN, is only limited by the buffer size.
+	* WE-14->WE-16, the buffer is limited to IW_SCAN_MAX_DATA bytes.
+	* Starting with WE-17, the buffer can be as big as needed.
+	* But the device won't repport anything if you change the value
+	* of IWMAX_BSS=3D24. */
+=09
 	rvalue |=3D mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
 	bsslist =3D r.ptr;
=20
 	/* ok now, scan the list and translate its info */
-	for (i =3D 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
+	for (i =3D 0; i < (int) bsslist->nr; i++) {
 		current_ev =3D prism54_translate_bss(ndev, current_ev,
-						   extra + IW_SCAN_MAX_DATA,
+						   extra + dwrq->length,
 						   &(bsslist->bsslist[i]),
 						   noise);
+#if WIRELESS_EXT > 16
+		/* Check if there is space for one more entry */
+		if((extra + dwrq->length - current_ev) <=3D IW_EV_ADDR_LEN) {
+			/* Ask user space to try again with a bigger buffer */
+			rvalue =3D -E2BIG;
+			break;
+		}
+#endif /* WIRELESS_EXT > 16 */
+	}
+
 	kfree(bsslist);
 	dwrq->length =3D (current_ev - extra);
 	dwrq->flags =3D 0;	/* todo */
@@ -1412,7 +1404,10 @@
 		mlmeautolevel =3D DOT11_MLME_EXTENDED;
 	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlmeautolevel);
 	/* restart the card with our new policy */
-	mgt_commit(priv);
+	if (mgt_commit(priv)) {
+		up_write(&priv->mib_sem);
+		return -EIO;
+	}
 	up_write(&priv->mib_sem);
=20
 	return 0;
@@ -1746,11 +1741,13 @@
 			    char *data)
 {
 	struct obj_mlme *mlme =3D (struct obj_mlme *) data;
-	size_t len;
-	u8 *payload, *pos =3D (u8 *) (mlme + 1);
-
-	len =3D pos[0] | (pos[1] << 8);	/* little endian data length */
-	payload =3D pos + 2;
+	struct obj_mlmeex *mlmeex =3D (struct obj_mlmeex *) data;
+	struct obj_mlmeex *confirm;
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	int wpa_ie_len;
+	size_t len =3D 0; /* u16, better? */
+	u8 *payload =3D 0, *pos =3D 0;
+	int ret;
=20
 	/* I think all trapable objects are listed here.
 	 * Some oids have a EX version. The difference is that they are emitted
@@ -1760,9 +1757,14 @@
 	 * suited. We use the more flexible custom event facility.
 	 */
=20
+	if (oid >=3D DOT11_OID_BEACON) {
+		len =3D mlmeex->size;
+		payload =3D pos =3D mlmeex->data;
+	}
+
 	/* I fear prism54_process_bss_data won't work with big endian data */
 	if ((oid =3D=3D DOT11_OID_BEACON) || (oid =3D=3D DOT11_OID_PROBE))
-		prism54_process_bss_data(priv, oid, mlme->address,
+		prism54_process_bss_data(priv, oid, mlmeex->address,
 					 payload, len);
=20
 	mgt_le_to_cpu(isl_oid[oid].flags & OID_FLAG_TYPE, (void *) mlme);
@@ -1822,21 +1824,134 @@
=20
 	case DOT11_OID_AUTHENTICATEEX:
 		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Authenticate request", mlme, 1);
+		send_formatted_event(priv, "Authenticate request (ex)", mlme, 1);
+
+		if (priv->iw_mode !=3D IW_MODE_MASTER=20
+				&& mlmeex->state !=3D DOT11_STATE_AUTHING)
+			break;
+
+		confirm =3D kmalloc(sizeof(struct obj_mlmeex) + 6, GFP_ATOMIC);
+
+		if (!confirm)=20
+			break;
+
+		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
+		printk(KERN_DEBUG "Authenticate from: address:\t%02x:%02x:%02x:%02x:%0=
2x:%02x\n",=20
+				mlmeex->address[0],
+				mlmeex->address[1],
+				mlmeex->address[2],
+				mlmeex->address[3],
+				mlmeex->address[4],
+				mlmeex->address[5]
+				);
+		confirm->id =3D -1; /* or mlmeex->id ? */
+		confirm->state =3D 0; /* not used */
+		confirm->code =3D 0;
+		confirm->size =3D 6;
+		confirm->data[0] =3D 0x00;
+		confirm->data[1] =3D 0x00;
+		confirm->data[2] =3D 0x02;
+		confirm->data[3] =3D 0x00;
+		confirm->data[4] =3D 0x00;
+		confirm->data[5] =3D 0x00;
+
+		ret =3D mgt_set_varlen(priv, DOT11_OID_ASSOCIATEEX, confirm, 6);
+
+		kfree(confirm);
+		if (ret)
+			return ret;
 		break;
=20
 	case DOT11_OID_DISASSOCIATEEX:
-		send_formatted_event(priv, "Disassociate request", mlme, 0);
+		send_formatted_event(priv, "Disassociate request (ex)", mlme, 0);
 		break;
=20
 	case DOT11_OID_ASSOCIATEEX:
 		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Associate request", mlme, 1);
+		send_formatted_event(priv, "Associate request (ex)", mlme, 1);
+
+		if (priv->iw_mode !=3D IW_MODE_MASTER=20
+				&& mlmeex->state !=3D DOT11_STATE_AUTHING)
+			break;
+	=09
+		confirm =3D kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
+
+		if (!confirm)
+			break;
+
+		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
+
+		confirm->id =3D ((struct obj_mlmeex *)mlme)->id;
+		confirm->state =3D 0; /* not used */
+		confirm->code =3D 0;
+
+		wpa_ie_len =3D prism54_wpa_ie_get(priv, mlmeex->address, wpa_ie);
+
+		if (!wpa_ie_len) {
+			printk(KERN_DEBUG "No WPA IE found from "
+					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",=20
+				mlmeex->address[0],
+				mlmeex->address[1],
+				mlmeex->address[2],
+				mlmeex->address[3],
+				mlmeex->address[4],
+				mlmeex->address[5]
+				);
+			kfree(confirm);
+			break;
+		}
+
+		confirm->size =3D wpa_ie_len;
+		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
+
+		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
+
+		kfree(confirm);
+	=09
 		break;
=20
 	case DOT11_OID_REASSOCIATEEX:
 		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Reassociate request", mlme, 1);
+		send_formatted_event(priv, "Reassociate request (ex)", mlme, 1);
+
+		if (priv->iw_mode !=3D IW_MODE_MASTER=20
+				&& mlmeex->state !=3D DOT11_STATE_ASSOCING)
+			break;
+
+		confirm =3D kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
+
+		if (!confirm)
+			break;
+
+		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
+
+		confirm->id =3D mlmeex->id;
+		confirm->state =3D 0; /* not used */
+		confirm->code =3D 0;
+
+		wpa_ie_len =3D prism54_wpa_ie_get(priv, mlmeex->address, wpa_ie);
+
+		if (!wpa_ie_len) {
+			printk(KERN_DEBUG "No WPA IE found from "
+					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",=20
+				mlmeex->address[0],
+				mlmeex->address[1],
+				mlmeex->address[2],
+				mlmeex->address[3],
+				mlmeex->address[4],
+				mlmeex->address[5]
+				);
+			kfree(confirm);
+			break;
+		}
+
+		confirm->size =3D wpa_ie_len;=20
+		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
+
+		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
+
+		kfree(confirm);
+	=09
 		break;
=20
 	default:
@@ -1879,23 +1994,367 @@
 	return ret;
 }
=20
+/* Note: currently, use hostapd ioctl from the Host AP driver for WPA
+ * support. This is to be replaced with Linux wireless extensions once t=
hey
+ * get WPA support. */
+
+/* Note II: please leave all this together as it will be easier to remov=
e later,
+ * once wireless extensions add WPA support -mcgrof */
+
+/* PRISM54_HOSTAPD ioctl() cmd: */
+enum {
+	PRISM2_SET_ENCRYPTION =3D 6,
+	PRISM2_HOSTAPD_SET_GENERIC_ELEMENT =3D 12,
+	PRISM2_HOSTAPD_MLME =3D 13,
+	PRISM2_HOSTAPD_SCAN_REQ =3D 14,
+};
+
+#define PRISM54_SET_WPA			SIOCIWFIRSTPRIV+12
+#define PRISM54_HOSTAPD			SIOCIWFIRSTPRIV+25
+#define PRISM54_DROP_UNENCRYPTED	SIOCIWFIRSTPRIV+26
+
+#define PRISM2_HOSTAPD_MAX_BUF_SIZE 1024
+#define PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN \
+((int) (&((struct prism2_hostapd_param *) 0)->u.generic_elem.data))
+
+/* Maximum length for algorithm names (-1 for nul termination)=20
+ * used in ioctl() */
+#define HOSTAP_CRYPT_ALG_NAME_LEN 16
+=09
+struct prism2_hostapd_param {
+	u32 cmd;
+	u8 sta_addr[ETH_ALEN];
+	union {
+	       struct {
+		       u8 alg[HOSTAP_CRYPT_ALG_NAME_LEN];
+		       u32 flags;
+		       u32 err;
+		       u8 idx;
+		       u8 seq[8]; /* sequence counter (set: RX, get: TX) */
+		       u16 key_len;
+		       u8 key[0];
+		       } crypt;
+               struct {
+                       u8 len;
+                       u8 data[0];
+               } generic_elem;
+               struct {
+#define MLME_STA_DEAUTH 0
+#define MLME_STA_DISASSOC 1
+                       u16 cmd;
+                       u16 reason_code;
+               } mlme;
+               struct {
+                       u8 ssid_len;
+                       u8 ssid[32];
+               } scan_req;
+       } u;
+};
+
+
+static int
+prism2_ioctl_set_encryption(struct net_device *dev,
+	struct prism2_hostapd_param *param,
+	int param_len)
+{
+	islpci_private *priv =3D netdev_priv(dev);
+	int rvalue =3D 0, force =3D 0;
+	int authen =3D DOT11_AUTH_OS, invoke =3D 0, exunencrypt =3D 0;
+	union oid_res_t r;
+
+	/* with the new API, it's impossible to get a NULL pointer.
+	 * New version of iwconfig set the IW_ENCODE_NOKEY flag
+	 * when no key is given, but older versions don't. */
+
+	if (param->u.crypt.key_len > 0) {
+		/* we have a key to set */
+		int index =3D param->u.crypt.idx;
+		int current_index;
+		struct obj_key key =3D { DOT11_PRIV_TKIP, 0, "" };
+
+		/* get the current key index */
+		rvalue =3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		current_index =3D r.u;
+		/* Verify that the key is not marked as invalid */
+		if (!(param->u.crypt.flags & IW_ENCODE_NOKEY)) {
+			key.length =3D param->u.crypt.key_len > sizeof (param->u.crypt.key) ?
+			    sizeof (param->u.crypt.key) : param->u.crypt.key_len;
+			memcpy(key.key, param->u.crypt.key, key.length);
+			if (key.length =3D=3D 32)
+				/* we want WPA-PSK */
+				key.type =3D DOT11_PRIV_TKIP;
+			if ((index < 0) || (index > 3))
+				/* no index provided use the current one */
+				index =3D current_index;
+
+			/* now send the key to the card  */
+			rvalue |=3D
+			    mgt_set_request(priv, DOT11_OID_DEFKEYX, index,
+					    &key);
+		}
+		/*
+		 * If a valid key is set, encryption should be enabled=20
+		 * (user may turn it off later).
+		 * This is also how "iwconfig ethX key on" works
+		 */
+		if ((index =3D=3D current_index) && (key.length > 0))
+			force =3D 1;
+	} else {
+		int index =3D (param->u.crypt.flags & IW_ENCODE_INDEX) - 1;
+		if ((index >=3D 0) && (index <=3D 3)) {
+			/* we want to set the key index */
+			rvalue |=3D
+			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
+					    &index);
+		} else {
+			if (!param->u.crypt.flags & IW_ENCODE_MODE) {
+				/* we cannot do anything. Complain. */
+				return -EINVAL;
+			}
+		}
+	}
+	/* now read the flags */
+	if (param->u.crypt.flags & IW_ENCODE_DISABLED) {
+		/* Encoding disabled,=20
+		 * authen =3D DOT11_AUTH_OS;
+		 * invoke =3D 0;
+		 * exunencrypt =3D 0; */
+	}
+	if (param->u.crypt.flags & IW_ENCODE_OPEN)
+		/* Encode but accept non-encoded packets. No auth */
+		invoke =3D 1;
+	if ((param->u.crypt.flags & IW_ENCODE_RESTRICTED) || force) {
+		/* Refuse non-encoded packets. Auth */
+		authen =3D DOT11_AUTH_BOTH;
+		invoke =3D 1;
+		exunencrypt =3D 1;
+	}
+	/* do the change if requested  */
+	if ((param->u.crypt.flags & IW_ENCODE_MODE) || force) {
+		rvalue |=3D
+		    mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
+		rvalue |=3D
+		    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &invoke);
+		rvalue |=3D
+		    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
+				    &exunencrypt);
+	}
+	return rvalue;
+}
+
+static int
+prism2_ioctl_set_generic_element(struct net_device *ndev,
+	struct prism2_hostapd_param *param,
+	int param_len)
+{
+       islpci_private *priv =3D netdev_priv(ndev);
+       int max_len, len, alen, ret=3D0;
+       struct obj_attachment *attach;
+
+       len =3D param->u.generic_elem.len;
+       max_len =3D param_len - PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN;
+       if (max_len < 0 || max_len < len)
+               return -EINVAL;
+
+       alen =3D sizeof(*attach) + len;
+       attach =3D kmalloc(alen, GFP_KERNEL);
+       if (attach =3D=3D NULL)
+               return -ENOMEM;
+
+       memset(attach, 0, alen);
+#define WLAN_FC_TYPE_MGMT 0
+#define WLAN_FC_STYPE_ASSOC_REQ 0
+#define WLAN_FC_STYPE_REASSOC_REQ 2
+
+       /* Note: endianness is covered by mgt_set_varlen */
+
+       attach->type =3D (WLAN_FC_TYPE_MGMT << 2) |
+               (WLAN_FC_STYPE_ASSOC_REQ << 4);
+       attach->id =3D -1;
+       attach->size =3D len;
+       memcpy(attach->data, param->u.generic_elem.data, len);
+
+       ret =3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
+
+       if (ret =3D=3D 0) {
+               attach->type =3D (WLAN_FC_TYPE_MGMT << 2) |
+                       (WLAN_FC_STYPE_REASSOC_REQ << 4);
+
+	       ret =3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
+
+	       if (ret =3D=3D 0)=20
+		       printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
+				       ndev->name);
+       }
+
+       kfree(attach);
+       return ret;
+
+}
+
+static int
+prism2_ioctl_mlme(struct net_device *dev, struct prism2_hostapd_param *p=
aram)
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+prism2_ioctl_scan_req(struct net_device *ndev,
+                     struct prism2_hostapd_param *param)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	int i, rvalue;
+	struct obj_bsslist *bsslist;
+	u32 noise =3D 0;
+	char *extra =3D "";
+	char *current_ev =3D "foo";
+	union oid_res_t r;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT) {
+		/* device is not ready, fail gently */
+		return 0;
+	}
+
+	/* first get the noise value. We will use it to report the link quality=
 */
+	rvalue =3D mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
+	noise =3D r.u;
+
+	/* Ask the device for a list of known bss. We can report at most
+	 * IW_MAX_AP=3D64 to the range struct. But the device won't repport any=
thing
+	 * if you change the value of IWMAX_BSS=3D24.
+	 */
+	rvalue |=3D mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
+	bsslist =3D r.ptr;
+
+	/* ok now, scan the list and translate its info */
+	for (i =3D 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
+		current_ev =3D prism54_translate_bss(ndev, current_ev,
+						   extra + IW_SCAN_MAX_DATA,
+						   &(bsslist->bsslist[i]),
+						   noise);
+	kfree(bsslist);
+
+	return rvalue;
+}
+
+static int
+prism54_hostapd(struct net_device *ndev, struct iw_point *p)
+{
+       struct prism2_hostapd_param *param;
+       int ret =3D 0;
+       u32 uwrq;
+
+       printk(KERN_DEBUG "prism54_hostapd - len=3D%d\n", p->length);
+       if (p->length < sizeof(struct prism2_hostapd_param) ||
+           p->length > PRISM2_HOSTAPD_MAX_BUF_SIZE || !p->pointer)
+               return -EINVAL;
+
+       param =3D (struct prism2_hostapd_param *) kmalloc(p->length, GFP_=
KERNEL);
+       if (param =3D=3D NULL)
+               return -ENOMEM;
+
+       if (copy_from_user(param, p->pointer, p->length)) {
+               kfree(param);
+               return -EFAULT;
+       }
+
+       switch (param->cmd) {
+       case PRISM2_SET_ENCRYPTION:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant set encryption requ=
est\n",
+			       ndev->name);
+               ret =3D prism2_ioctl_set_encryption(ndev, param, p->lengt=
h);
+               break;
+       case PRISM2_HOSTAPD_SET_GENERIC_ELEMENT:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant set WPA IE request\=
n",
+			       ndev->name);
+               ret =3D prism2_ioctl_set_generic_element(ndev, param,
+                                                      p->length);
+               break;
+       case PRISM2_HOSTAPD_MLME:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant MLME request\n",
+			       ndev->name);
+               ret =3D prism2_ioctl_mlme(ndev, param);
+               break;
+       case PRISM2_HOSTAPD_SCAN_REQ:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant scan request\n",
+			       ndev->name);
+               ret =3D prism2_ioctl_scan_req(ndev, param);
+               break;
+	case PRISM54_SET_WPA:
+	       printk(KERN_DEBUG "%s: Caught WPA supplicant wpa init request\n"=
,
+			       ndev->name);
+	       uwrq =3D 1;
+	       ret =3D prism54_set_wpa(ndev, NULL, &uwrq, NULL);
+	       break;
+	case PRISM54_DROP_UNENCRYPTED:
+	       printk(KERN_DEBUG "%s: Caught WPA drop unencrypted request\n",
+			       ndev->name);
+#if 0
+	       uwrq =3D 0x01;
+	       mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &uwrq);
+	       down_write(&priv->mib_sem);
+	       mgt_commit(priv);
+	       up_write(&priv->mib_sem);
+#endif
+	       /* Not necessary, as set_wpa does it, should we just do it here =
though? */
+	       ret =3D 0;
+	       break;
+       default:
+	       printk(KERN_DEBUG "%s: Caught a WPA supplicant request that is n=
ot supported\n",
+			       ndev->name);
+               ret =3D -EOPNOTSUPP;
+               break;
+       }
+
+       if (ret =3D=3D 0 && copy_to_user(p->pointer, param, p->length))
+               ret =3D -EFAULT;
+
+       kfree(param);
+
+       return ret;
+}
+
 int
 prism54_set_wpa(struct net_device *ndev, struct iw_request_info *info,
 		__u32 * uwrq, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
+	u32 mlme, authen, dot1x, filter, wep;
=20
-	down_write(&priv->mib_sem);
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	wep =3D 1; /* For privacy invoked */
+	filter =3D 1; /* Filter out all unencrypted frames */
+	dot1x =3D 0x01; /* To enable eap filter */
+	mlme =3D DOT11_MLME_EXTENDED;
+	authen =3D DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
=20
+	down_write(&priv->mib_sem);
 	priv->wpa =3D *uwrq;
-	if (priv->wpa) {
-		u32 l =3D DOT11_MLME_EXTENDED;
-		mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &l);
+
+	switch (priv->wpa) {
+		default:
+		case 0: /* Clears/disables WPA and friends */
+			wep =3D 0;
+			filter =3D 0; /* Do not filter un-encrypted data */
+			dot1x =3D 0;
+			mlme =3D DOT11_MLME_AUTO;
+			printk("%s: Disabling WPA\n", ndev->name);
+			break;
+		case 2:=20
+		case 1: /* WPA */
+			printk("%s: Enabling WPA\n", ndev->name);
+			break;
 	}
-	/* restart the card with new level. Needed ? */
-	mgt_commit(priv);
 	up_write(&priv->mib_sem);
=20
+	mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
+	mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &wep);
+	mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0, &filter);
+	mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 0, &dot1x);
+	mgt_set_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, &mlme);
+
 	return 0;
 }
=20
@@ -1947,7 +2406,7 @@
 		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
-	struct islpci_mgmtframe *response =3D NULL;
+	struct islpci_mgmtframe *response;
 	int ret =3D -EIO;
=20
 	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
@@ -1983,7 +2442,7 @@
 		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
-	struct islpci_mgmtframe *response =3D NULL;
+	struct islpci_mgmtframe *response;
 	int ret =3D 0, response_op =3D PIMFOR_OP_ERROR;
=20
 	printk("%s: set_oid 0x%08X\tlen: %d\n", ndev->name, priv->priv_oid,
@@ -2256,14 +2715,24 @@
 	.standard =3D (iw_handler *) prism54_handler,
 	.private =3D (iw_handler *) prism54_private_handler,
 	.private_args =3D (struct iw_priv_args *) prism54_private_args,
+#if WIRELESS_EXT =3D=3D 16
 	.spy_offset =3D offsetof(islpci_private, spy_data),
+#endif /* WIRELESS_EXT =3D=3D 16 */
 };
=20
-/* For ioctls that don't work with the new API */
+/* For wpa_supplicant */
=20
 int
 prism54_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
-
+	struct iwreq *wrq =3D (struct iwreq *) rq;
+	int ret =3D -1;
+	switch (cmd) {
+		case PRISM54_HOSTAPD:
+		if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+		ret =3D prism54_hostapd(ndev, &wrq->u.data);
+		return ret;
+	}
 	return -EOPNOTSUPP;
 }
diff -Nru a/drivers/net/wireless/prism54/isl_ioctl.h b/drivers/net/wirele=
ss/prism54/isl_ioctl.h
--- a/drivers/net/wireless/prism54/isl_ioctl.h	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/wireless/prism54/isl_ioctl.h	2004-10-21 22:09:44 -04:00
@@ -48,6 +48,8 @@
 int prism54_set_mac_address(struct net_device *, void *);
=20
 int prism54_ioctl(struct net_device *, struct ifreq *, int);
+int prism54_set_wpa(struct net_device *, struct iw_request_info *,=20
+			__u32 *, char *);
=20
 extern const struct iw_handler_def prism54_handler_def;
=20
diff -Nru a/drivers/net/wireless/prism54/isl_oid.h b/drivers/net/wireless=
/prism54/isl_oid.h
--- a/drivers/net/wireless/prism54/isl_oid.h	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/wireless/prism54/isl_oid.h	2004-10-21 22:09:44 -04:00
@@ -91,6 +91,14 @@
 	u16 mhz[0];
 } __attribute__ ((packed));
=20
+struct obj_attachment {
+	char type;
+	char reserved;
+	short id;
+	short size;
+	char data[0];
+} __attribute__((packed));
+
 /*=20
  * in case everything's ok, the inlined function below will be
  * optimized away by the compiler...
@@ -472,6 +480,7 @@
 #define OID_TYPE_MLMEEX		0x09
 #define OID_TYPE_ADDR		0x0A
 #define OID_TYPE_RAW		0x0B
+#define OID_TYPE_ATTACH		0x0C
=20
 /* OID_TYPE_MLMEEX is special because of a variable size field when send=
ing.
  * Not yet implemented (not used in driver anyway).
diff -Nru a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wirel=
ess/prism54/islpci_dev.c
--- a/drivers/net/wireless/prism54/islpci_dev.c	2004-10-21 22:09:44 -04:0=
0
+++ b/drivers/net/wireless/prism54/islpci_dev.c	2004-10-21 22:09:44 -04:0=
0
@@ -105,7 +105,7 @@
 			       "%s: firmware '%s' size is not multiple of 32bit, aborting!\n"=
,
 			       "prism54", priv->firmware);
 			release_firmware(fw_entry);
-			return EILSEQ; /* Illegal byte sequence  */;
+			return -EILSEQ; /* Illegal byte sequence  */;
 		}
=20
 		while (fw_len > 0) {
@@ -142,6 +142,10 @@
=20
 		BUG_ON(fw_len !=3D 0);
=20
+		/* Firmware version is at offset 40 (also for "newmac") */
+		printk(KERN_DEBUG "%s: firmware version: %.8s\n",
+		       priv->ndev->name, fw_entry->data + 40);
+
 		release_firmware(fw_entry);
 	}
=20
@@ -375,8 +379,6 @@
 	u32 rc;
 	islpci_private *priv =3D netdev_priv(ndev);
=20
-	printk(KERN_DEBUG "%s: islpci_open()\n", ndev->name);
-
 	/* reset data structures, upload firmware and reset device */
 	rc =3D islpci_reset(priv,1);
 	if (rc) {
@@ -462,8 +464,7 @@
 		return rc;
 	}
=20
-	printk(KERN_DEBUG
-	       "%s: firmware uploaded done, now triggering reset...\n",
+	printk(KERN_DEBUG "%s: firmware upload complete\n",
 	       priv->ndev->name);
=20
 	islpci_set_state(priv, PRV_STATE_POSTBOOT);
@@ -489,6 +490,7 @@
 		/* The software reset acknowledge needs about 220 msec here.
 		 * Be conservative and wait for up to one second. */
 =09
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		remaining =3D schedule_timeout(HZ);
=20
 		if(remaining > 0) {
@@ -499,15 +501,16 @@
 		/* If we're here it's because our IRQ hasn't yet gone through.=20
 		 * Retry a bit more...
 		 */
-		 printk(KERN_ERR "%s: device soft reset timed out\n",
-		       priv->ndev->name);
-
+		printk(KERN_ERR "%s: no 'reset complete' IRQ seen - retrying\n",
+			priv->ndev->name);
 	}
=20
 	finish_wait(&priv->reset_done, &wait);
=20
-	if(result)
+	if (result) {
+		printk(KERN_ERR "%s: interface reset failure\n", priv->ndev->name);
 		return result;
+	}
=20
 	islpci_set_state(priv, PRV_STATE_INIT);
=20
@@ -519,11 +522,17 @@
 	isl38xx_enable_common_interrupts(priv->device_base);
=20
 	down_write(&priv->mib_sem);
-	mgt_commit(priv);
+	result =3D mgt_commit(priv);
+	if (result) {
+		printk(KERN_ERR "%s: interface reset failure\n", priv->ndev->name);
+		up_write(&priv->mib_sem);
+		return result;
+	}
 	up_write(&priv->mib_sem);
=20
 	islpci_set_state(priv, PRV_STATE_READY);
=20
+	printk(KERN_DEBUG "%s: interface reset complete\n", priv->ndev->name);
 	return 0;
 }
=20
@@ -584,18 +593,18 @@
 	/* now that the data structures are cleaned up, upload
 	 * firmware and reset interface */
 		rc =3D islpci_upload_fw(priv);
-		if (rc)=20
+		if (rc) {
+			printk(KERN_ERR "%s: islpci_reset: failure\n",
+				priv->ndev->name);
 			return rc;
+		}
 	}
=20
 	/* finally reset interface */
 	rc =3D islpci_reset_if(priv);
-	if (!rc) /* If successful */
-		return rc;
-=09
-	printk(KERN_DEBUG  "prism54: Your card/socket may be faulty, or IRQ lin=
e too busy :(\n");
+	if (rc)
+		printk(KERN_ERR "prism54: Your card/socket may be faulty, or IRQ line =
too busy :(\n");
 	return rc;
-
 }
=20
 struct net_device_stats *
@@ -604,7 +613,7 @@
 	islpci_private *priv =3D netdev_priv(ndev);
=20
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics\n");
 #endif
=20
 	return &priv->statistics;
@@ -829,6 +838,12 @@
 	priv->monitor_type =3D ARPHRD_IEEE80211;
 	priv->ndev->type =3D (priv->iw_mode =3D=3D IW_MODE_MONITOR) ?
 		priv->monitor_type : ARPHRD_ETHER;
+
+#if WIRELESS_EXT > 16
+	/* Add pointers to enable iwspy support. */
+	priv->wireless_data.spy_data =3D &priv->spy_data;
+	ndev->wireless_data =3D &priv->wireless_data;
+#endif /* WIRELESS_EXT > 16 */
=20
 	/* save the start and end address of the PCI memory area */
 	ndev->mem_start =3D (unsigned long) priv->device_base;
diff -Nru a/drivers/net/wireless/prism54/islpci_dev.h b/drivers/net/wirel=
ess/prism54/islpci_dev.h
--- a/drivers/net/wireless/prism54/islpci_dev.h	2004-10-21 22:09:44 -04:0=
0
+++ b/drivers/net/wireless/prism54/islpci_dev.h	2004-10-21 22:09:44 -04:0=
0
@@ -100,6 +100,10 @@
=20
 	struct iw_spy_data spy_data; /* iwspy support */
=20
+#if WIRELESS_EXT > 16
+	struct iw_public_data wireless_data;
+#endif /* WIRELESS_EXT > 16 */
+
 	int monitor_type; /* ARPHRD_IEEE80211 or ARPHRD_IEEE80211_PRISM */
=20
 	struct islpci_acl acl;
diff -Nru a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wirel=
ess/prism54/islpci_eth.c
--- a/drivers/net/wireless/prism54/islpci_eth.c	2004-10-21 22:09:44 -04:0=
0
+++ b/drivers/net/wireless/prism54/islpci_eth.c	2004-10-21 22:09:44 -04:0=
0
@@ -508,11 +508,12 @@
 	/* increment the transmit error counter */
 	statistics->tx_errors++;
=20
+	printk(KERN_WARNING "%s: tx_timeout", ndev->name);
 	if (!priv->reset_task_pending) {
 		priv->reset_task_pending =3D 1;
+		printk(", scheduling a reset");
 		netif_stop_queue(ndev);
 		schedule_work(&priv->reset_task);
 	}
-
-	return;
+	printk("\n");
 }
diff -Nru a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/w=
ireless/prism54/islpci_hotplug.c
--- a/drivers/net/wireless/prism54/islpci_hotplug.c	2004-10-21 22:09:44 -=
04:00
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c	2004-10-21 22:09:44 -=
04:00
@@ -107,9 +107,6 @@
 	islpci_private *priv;
 	int rvalue;
=20
-	/* TRACE(DRV_NAME); */
-=09
-=09
 	/* Enable the pci device */
 	if (pci_enable_device(pdev)) {
 		printk(KERN_ERR "%s: pci_enable_device() failed.\n", DRV_NAME);
diff -Nru a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wirel=
ess/prism54/islpci_mgt.c
--- a/drivers/net/wireless/prism54/islpci_mgt.c	2004-10-21 22:09:44 -04:0=
0
+++ b/drivers/net/wireless/prism54/islpci_mgt.c	2004-10-21 22:09:44 -04:0=
0
@@ -473,6 +473,7 @@
 		int timeleft;
 		struct islpci_mgmtframe *frame;
=20
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		timeleft =3D schedule_timeout(wait_cycle_jiffies);
 		frame =3D xchg(&priv->mgmt_received, NULL);
 		if (frame) {
diff -Nru a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wirel=
ess/prism54/islpci_mgt.h
--- a/drivers/net/wireless/prism54/islpci_mgt.h	2004-10-21 22:09:44 -04:0=
0
+++ b/drivers/net/wireless/prism54/islpci_mgt.h	2004-10-21 22:09:44 -04:0=
0
@@ -31,8 +31,6 @@
 #define K_DEBUG(f, m, args...) do { if(f & m) printk(KERN_DEBUG args); }=
 while(0)
 #define DEBUG(f, args...) K_DEBUG(f, pc_debug, args)
=20
-#define TRACE(devname)   K_DEBUG(SHOW_TRACING, VERBOSE, "%s:  -> " __FUN=
CTION__ "()\n", devname)
-
 extern int pc_debug;
 #define init_wds 0	/* help compiler optimize away dead code */
=20
diff -Nru a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless=
/prism54/oid_mgt.c
--- a/drivers/net/wireless/prism54/oid_mgt.c	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/wireless/prism54/oid_mgt.c	2004-10-21 22:09:44 -04:00
@@ -201,7 +201,8 @@
 	OID_U32(DOT11_OID_STATIMEOUT, 0x19000000),
 	OID_U32_C(DOT11_OID_MLMEAUTOLEVEL, 0x19000001),
 	OID_U32(DOT11_OID_BSSTIMEOUT, 0x19000002),
-	OID_UNKNOWN(DOT11_OID_ATTACHMENT, 0x19000003),
+	[DOT11_OID_ATTACHMENT] =3D {0x19000003, 0,
+		sizeof(struct obj_attachment), OID_TYPE_ATTACH},
 	OID_STRUCT_C(DOT11_OID_PSMBUFFER, 0x19000004, struct obj_buffer,
 		     OID_TYPE_BUFFER),
=20
@@ -329,6 +330,12 @@
 			mlme->size =3D le16_to_cpu(mlme->size);
 			break;
 		}
+	case OID_TYPE_ATTACH:{
+			struct obj_attachment *attach =3D data;
+			attach->id =3D le16_to_cpu(attach->id);
+			attach->size =3D le16_to_cpu(attach->size);;=20
+			break;
+	}
 	case OID_TYPE_SSID:
 	case OID_TYPE_KEY:
 	case OID_TYPE_ADDR:
@@ -392,6 +399,12 @@
 			mlme->size =3D cpu_to_le16(mlme->size);
 			break;
 		}
+	case OID_TYPE_ATTACH:{
+			struct obj_attachment *attach =3D data;
+			attach->id =3D cpu_to_le16(attach->id);
+			attach->size =3D cpu_to_le16(attach->size);;=20
+			break;
+	}
 	case OID_TYPE_SSID:
 	case OID_TYPE_KEY:
 	case OID_TYPE_ADDR:
@@ -465,6 +478,42 @@
 	return ret;
 }
=20
+/* None of these are cached */
+int
+mgt_set_varlen(islpci_private *priv, enum oid_num_t n, void *data, int e=
xtra_len)
+{
+	int ret =3D 0;
+	struct islpci_mgmtframe *response;
+	int response_op =3D PIMFOR_OP_ERROR;
+	int dlen;
+	u32 oid;
+
+	BUG_ON(OID_NUM_LAST <=3D n);
+
+	dlen =3D isl_oid[n].size;
+	oid =3D isl_oid[n].oid;
+
+	mgt_cpu_to_le(isl_oid[n].flags & OID_FLAG_TYPE, data);
+
+	if (islpci_get_state(priv) >=3D PRV_STATE_READY) {
+		ret =3D islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET, oid,
+					     data, dlen + extra_len, &response);
+		if (!ret) {
+			response_op =3D response->header->operation;
+			islpci_mgt_release(response);
+		}
+		if (ret || response_op =3D=3D PIMFOR_OP_ERROR)
+			ret =3D -EIO;
+	} else=20
+		ret =3D -EIO;
+
+	/* re-set given data to what it was */
+	if (data)
+		mgt_le_to_cpu(isl_oid[n].flags & OID_FLAG_TYPE, data);
+
+	return ret;
+}
+
 int
 mgt_get_request(islpci_private *priv, enum oid_num_t n, int extra, void =
*data,
 		union oid_res_t *res)
@@ -555,15 +604,18 @@
 		u32 oid =3D t->oid;
 		BUG_ON(data =3D=3D NULL);
 		while (j <=3D t->range) {
-			response =3D NULL;
-			ret |=3D islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
+			int r =3D islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
 						      oid, data, t->size,
 						      &response);
 			if (response) {
-				ret |=3D (response->header->operation =3D=3D
-					PIMFOR_OP_ERROR);
+				r |=3D (response->header->operation =3D=3D PIMFOR_OP_ERROR);
 				islpci_mgt_release(response);
 			}
+			if (r)
+				printk(KERN_ERR "%s: mgt_commit_list: failure. "
+					"oid=3D%08x err=3D%d\n",
+					priv->ndev->name, oid, r);
+			ret |=3D r;
 			j++;
 			oid++;
 			data +=3D t->size;
@@ -624,7 +676,7 @@
 static int
 mgt_update_addr(islpci_private *priv)
 {
-	struct islpci_mgmtframe *res =3D NULL;
+	struct islpci_mgmtframe *res;
 	int ret;
=20
 	ret =3D islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
@@ -638,26 +690,26 @@
 	if (res)
 		islpci_mgt_release(res);
=20
+	if (ret)
+		printk(KERN_ERR "%s: mgt_update_addr: failure\n", priv->ndev->name);
 	return ret;
 }
=20
-void
+#define VEC_SIZE(a) (sizeof(a)/sizeof(a[0]))
+
+int
 mgt_commit(islpci_private *priv)
 {
 	int rvalue;
 	u32 u;
=20
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
-		return;
+		return 0;
=20
-	rvalue =3D mgt_commit_list(priv, commit_part1,
-				 sizeof (commit_part1) /
-				 sizeof (commit_part1[0]));
+	rvalue =3D mgt_commit_list(priv, commit_part1, VEC_SIZE(commit_part1));
=20
 	if (priv->iw_mode !=3D IW_MODE_MONITOR)
-		rvalue |=3D mgt_commit_list(priv, commit_part2,
-					  sizeof (commit_part2) /
-					  sizeof (commit_part2[0]));
+		rvalue |=3D mgt_commit_list(priv, commit_part2, VEC_SIZE(commit_part2)=
);
=20
 	u =3D OID_INL_MODE;
 	rvalue |=3D mgt_commit_list(priv, &u, 1);
@@ -666,9 +718,43 @@
 	if (rvalue) {
 		/* some request have failed. The device might be in an
 		   incoherent state. We should reset it ! */
-		printk(KERN_DEBUG "%s: mgt_commit has failed. Restart the "
-		       "device \n", priv->ndev->name);
+		printk(KERN_DEBUG "%s: mgt_commit: failure\n", priv->ndev->name);
 	}
+	return rvalue;
+}
+
+/* The following OIDs need to be "unlatched":
+ *
+ * MEDIUMLIMIT,BEACONPERIOD,DTIMPERIOD,ATIMWINDOW,LISTENINTERVAL
+ * FREQUENCY,EXTENDEDRATES.
+ *
+ * The way to do this is to set ESSID. Note though that they may get=20
+ * unlatch before though by setting another OID. */
+void
+mgt_unlatch_all(islpci_private *priv)
+{
+	u32 u;
+	int rvalue =3D 0;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return;
+
+	u =3D DOT11_OID_SSID;
+	rvalue =3D mgt_commit_list(priv, &u, 1);
+	/* Necessary if in MANUAL RUN mode? */
+#if 0
+	u =3D OID_INL_MODE;
+	rvalue |=3D mgt_commit_list(priv, &u, 1);
+
+	u =3D DOT11_OID_MLMEAUTOLEVEL;
+	rvalue |=3D mgt_commit_list(priv, &u, 1);
+
+	u =3D OID_INL_MODE;
+	rvalue |=3D mgt_commit_list(priv, &u, 1);
+#endif
+
+	if (rvalue)
+		printk(KERN_DEBUG "%s: Unlatching OIDs failed\n", priv->ndev->name);
 }
=20
 /* This will tell you if you are allowed to answer a mlme(ex) request .*=
/
@@ -769,6 +855,14 @@
 					"id=3D0x%X\nstate=3D0x%X\n"
 					"code=3D0x%X\nsize=3D0x%X\n", mlme->id,
 					mlme->state, mlme->code, mlme->size);
+		}
+		break;
+	case OID_TYPE_ATTACH:{
+			struct obj_attachment *attach =3D r->ptr;
+			return snprintf(str, PRIV_STR_SIZE,
+					"id=3D%d\nsize=3D%d\n",
+					attach->id,
+					attach->size);
 		}
 		break;
 	case OID_TYPE_SSID:{
diff -Nru a/drivers/net/wireless/prism54/oid_mgt.h b/drivers/net/wireless=
/prism54/oid_mgt.h
--- a/drivers/net/wireless/prism54/oid_mgt.h	2004-10-21 22:09:44 -04:00
+++ b/drivers/net/wireless/prism54/oid_mgt.h	2004-10-21 22:09:44 -04:00
@@ -36,6 +36,8 @@
 void mgt_le_to_cpu(int, void *);
=20
 int mgt_set_request(islpci_private *, enum oid_num_t, int, void *);
+int mgt_set_varlen(islpci_private *, enum oid_num_t, void *, int);
+
=20
 int mgt_get_request(islpci_private *, enum oid_num_t, int, void *,
 		    union oid_res_t *);
@@ -46,7 +48,8 @@
=20
 void mgt_get(islpci_private *, enum oid_num_t, void *);
=20
-void mgt_commit(islpci_private *);
+int mgt_commit(islpci_private *);
+void mgt_unlatch_all(islpci_private *);
=20
 int mgt_mlme_answer(islpci_private *);
=20
