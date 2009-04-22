From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Wed, 22 Apr 2009 09:59:31 +0200
Message-ID: <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
Cc: Lennert Buytenhek <kernel@wantstofly.org>,
	Ivo Clarysse <ivo.clarysse@gmail.com>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60490 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487AbZDVH7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 03:59:55 -0400
In-Reply-To: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The in Kernel driver is far beyond its age. it still does not use
driver model and its mere presence in the Kernel image prevents
booting my board. The CS8900 still is in use on some embedded
boards, so this patch adds an alternative driver to the tree
designed to replace the old one.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/Kconfig         |   12 +
 drivers/net/Makefile        |    1 +
 drivers/net/cirrus-cs89x0.c |  847 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 860 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/cirrus-cs89x0.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9e92154..1d358b1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1454,6 +1454,18 @@ config CS89x0_NONISA_IRQ
 	depends on CS89x0 != n
 	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X || MACH_MX31ADS
 
+config CIRRUS_CS89X0
+	tristate "CS89x0 support alternative"
+	---help---
+	  This is an alternate version of the cs89x0 driver with platform_device
+	  support.
+	  Support for CS89x0 chipset based Ethernet cards. If you have a non-ISA
+	  network card of this type, say Y here
+
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>.  The module will be
+	  called cirrus-cs89x0.
+
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
 	depends on NET_PCI && PCI && MIPS
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 1fc4602..41b524c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -210,6 +210,7 @@ obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_HYDRA) += hydra.o 8390.o
 obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_CS89x0) += cs89x0.o
+obj-$(CONFIG_CIRRUS_CS89X0) += cirrus-cs89x0.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
 obj-$(CONFIG_MACMACE) += macmace.o
 obj-$(CONFIG_MAC89x0) += mac89x0.o
diff --git a/drivers/net/cirrus-cs89x0.c b/drivers/net/cirrus-cs89x0.c
new file mode 100644
index 0000000..1d98c18
--- /dev/null
+++ b/drivers/net/cirrus-cs89x0.c
@@ -0,0 +1,847 @@
+/*
+ * linux/drivers/net/cirrus.c
+ *
+ * Author: Abraham van der Merwe <abraham@2d3d.co.za>
+ *
+ * A Cirrus Logic CS8900A driver for Linux
+ * based on the cs89x0 driver written by Russell Nelson,
+ * Donald Becker, and others.
+ *
+ * This source code is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/spinlock.h>
+#include <linux/ioport.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/irq.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/platform_device.h>
+
+#define CS89X0_ADDRESS	0x0a	/* PacketPage Pointer Port (Section 4.10.10) */
+#define CS89X0_DATA	0x0c	/* PacketPage Data Port (Section 4.10.10) */
+
+/*
+ * Registers
+ */
+#define PRODUCTID	0x0000	/* Section 4.3.1   Identification Code */
+#define MEMBASE		0x002c	/* Section 4.9.2   Base Address Register */
+#define INTNUM		0x0022	/* Section 3.2.3   Interrupt Number */
+#define EEPROMCMD	0x0040	/* Section 4.3.11  EEPROM Command */
+#define EEPROMDAT	0x0042	/* Section 4.3.12  EEPROM Data */
+#define RXCFG		0x0102	/* Section 4.4.6   Receiver Configuration */
+#define RXCTL		0x0104	/* Section 4.4.8   Receiver Control */
+#define TXCFG		0x0106	/* Section 4.4.9   Transmit Configuration */
+#define BUFCFG		0x010a	/* Section 4.4.12  Buffer Configuration */
+#define LINECTL		0x0112	/* Section 4.4.16  Line Control */
+#define SELFCTL		0x0114	/* Section 4.4.18  Self Control */
+#define BUSCTL		0x0116	/* Section 4.4.20  Bus Control */
+#define TESTCTL		0x0118	/* Section 4.4.22  Test Control */
+#define ISQ		0x0120	/* Section 4.4.5   Interrupt Status Queue */
+#define TXEVENT		0x0128	/* Section 4.4.10  Transmitter Event */
+#define BUFEVENT	0x012c	/* Section 4.4.13  Buffer Event */
+#define RXMISS		0x0130	/* Section 4.4.14  Receiver Miss Counter */
+#define TXCOL		0x0132	/* Section 4.4.15  Transmit Collision Counter */
+#define SELFST		0x0136	/* Section 4.4.19  Self Status */
+#define BUSST		0x0138	/* Section 4.4.21  Bus Status */
+#define TXCMD		0x0144	/* Section 4.4.11  Transmit Command */
+#define TXLENGTH	0x0146	/* Section 4.5.2   Transmit Length */
+#define IA		0x0158	/* Section 4.6.2   Individual Address */
+#define RXSTATUS	0x0400	/* Section 4.7.1   Receive Status */
+#define RXLENGTH	0x0402	/* Section 4.7.1   Receive Length (in bytes) */
+#define RXFRAME		0x0404	/* Section 4.7.2   Receive Frame Location */
+#define TXFRAME		0x0a00	/* Section 4.7.2   Transmit Frame Location */
+
+/*
+ * Values
+ */
+
+/* INTNUM */
+#define INTRQ0			0x0000
+#define INTRQ1			0x0001
+#define INTRQ2			0x0002
+#define INTRQ3			0x0003
+
+/* ProductID */
+#define EISA_REG_CODE		0x630e
+#define REVISION(x)		(((x) & 0x1f00) >> 8)
+#define VERSION(x)		((x) & ~0x1f00)
+
+#define CS8900A			0x0000
+#define REV_B			7
+#define REV_C			8
+#define REV_D			9
+
+/* RXCFG */
+#define RXCFG_SKIP_1		0x0040
+#define RXCFG_STREAME		0x0080
+#define RXCFG_RXOKIE		0x0100
+#define RXCFG_RXDMAONLY		0x0200
+#define RXCFG_AUTORXDMAE	0x0400
+#define RXCFG_BUFFERCRC		0x0800
+#define RXCFG_CRCERRORIE	0x1000
+#define RXCFG_RUNTIE		0x2000
+#define RXCFG_EXTRADATAIE	0x4000
+
+/* RxCTL */
+#define RXCTL_IAHASHA		0x0040
+#define RXCTL_PROMISCUOUSA	0x0080
+#define RXCTL_RXOKA		0x0100
+#define RXCTL_MULTICASTA	0x0200
+#define RXCTL_INDIVIDUALA	0x0400
+#define RXCTL_BROADCASTA	0x0800
+#define RXCTL_CRCERRORA		0x1000
+#define RXCTL_RUNTA		0x2000
+#define RXCTL_EXTRADATAA	0x4000
+
+/* TXCFG */
+#define TXCFG_LOSS_OF_CRSIE	0x0040
+#define TXCFG_SQERRORIE		0x0080
+#define TXCFG_TXOKIE		0x0100
+#define TXCFG_OUT_OF_WINDOWIE	0x0200
+#define TXCFG_JABBERIE		0x0400
+#define TXCFG_ANYCOLLIE		0x0800
+#define TXCFG_T16COLLIE		0x8000
+
+/* BUFCFG */
+#define BUFCFG_SWINT_X		0x0040
+#define BUFCFG_RXDMAIE		0x0080
+#define BUFCFG_RDY4TXIE		0x0100
+#define BUFCFG_TXUNDERRUNIE	0x0200
+#define BUFCFG_RXMISSIE		0x0400
+#define BUFCFG_RX128IE		0x0800
+#define BUFCFG_TXCOLOVFIE	0x1000
+#define BUFCFG_MISSOVFLOIE	0x2000
+#define BUFCFG_RXDESTIE		0x8000
+
+/* LINECTL */
+#define LINECTL_SERRXON		0x0040
+#define LINECTL_SERTXON		0x0080
+#define LINECTL_AUIONLY		0x0100
+#define LINECTL_AUTOAUI_10BT	0x0200
+#define LINECTL_MODBACKOFFE	0x0800
+#define LINECTL_POLARITYDIS	0x1000
+#define LINECTL_L2_PARTDEFDIS	0x2000
+#define LINECTL_LORXSQUELCH	0x4000
+
+/* SELFCTL */
+#define SELFCTL_RESET		0x0040
+#define SELFCTL_SWSUSPEND	0x0100
+#define SELFCTL_HWSLEEPE	0x0200
+#define SELFCTL_HWSTANDBYE	0x0400
+#define SELFCTL_HC0E		0x1000
+#define SELFCTL_HC1E		0x2000
+#define SELFCTL_HCB0		0x4000
+#define SELFCTL_HCB1		0x8000
+
+/* BUSCTL */
+#define BUSCTL_RESETRXDMA	0x0040
+#define BUSCTL_DMAEXTEND	0x0100
+#define BUSCTL_USESA		0x0200
+#define BUSCTL_MEMORYE		0x0400
+#define BUSCTL_DMABURST		0x0800
+#define BUSCTL_IOCHRDYE		0x1000
+#define BUSCTL_RXDMASIZE	0x2000
+#define BUSCTL_ENABLERQ		0x8000
+
+/* TESTCTL */
+#define TESTCTL_DISABLELT	0x0080
+#define TESTCTL_ENDECLOOP	0x0200
+#define TESTCTL_AUILOOP		0x0400
+#define TESTCTL_DISABLEBACKOFF	0x0800
+#define TESTCTL_FDX		0x4000
+
+/* ISQ */
+#define ISQ_REGNUM(x) ((x) & 0x3f)
+#define ISQ_REGCONTENT(x) ((x) & ~0x3d)
+
+#define ISQ_RXEVENT		0x0004
+#define ISQ_TXEVENT		0x0008
+#define ISQ_BUFEVENT		0x000c
+#define ISQ_RXMISS		0x0010
+#define ISQ_TXCOL		0x0012
+
+/* RXSTATUS */
+#define RXSTATUS_IAHASH		0x0040
+#define RXSTATUS_DRIBBLEBITS	0x0080
+#define RXSTATUS_RXOK		0x0100
+#define RXSTATUS_HASHED		0x0200
+#define RXSTATUS_INDIVIDUALADR	0x0400
+#define RXSTATUS_BROADCAST	0x0800
+#define RXSTATUS_CRCERROR	0x1000
+#define RXSTATUS_RUNT		0x2000
+#define RXSTATUS_EXTRADATA	0x4000
+
+/* TXCMD */
+#define TXCMD_AFTER5		0
+#define TXCMD_AFTER381		1
+#define TXCMD_AFTER1021		2
+#define TXCMD_AFTERALL		3
+#define TXCMD_TXSTART(x) ((x) << 6)
+
+#define TXCMD_FORCE		0x0100
+#define TXCMD_ONECOLL		0x0200
+#define TXCMD_INHIBITCRC	0x1000
+#define TXCMD_TXPADDIS		0x2000
+
+/* BUSST */
+#define BUSST_TXBIDERR		0x0080
+#define BUSST_RDY4TXNOW		0x0100
+
+/* TXEVENT */
+#define TXEVENT_LOSS_OF_CRS	0x0040
+#define TXEVENT_SQEERROR	0x0080
+#define TXEVENT_TXOK		0x0100
+#define TXEVENT_OUT_OF_WINDOW	0x0200
+#define TXEVENT_JABBER		0x0400
+#define TXEVENT_T16COLL		0x8000
+
+#define TXEVENT_TX_COLLISIONS(x) (((x) >> 0xb) & ~0x8000)
+
+/* BUFEVENT */
+#define BUFEVENT_SWINT		0x0040
+#define BUFEVENT_RXDMAFRAME	0x0080
+#define BUFEVENT_RDY4TX		0x0100
+#define BUFEVENT_TXUNDERRUN	0x0200
+#define BUFEVENT_RXMISS		0x0400
+#define BUFEVENT_RX128		0x0800
+#define BUFEVENT_RXDEST		0x8000
+
+/* RXMISS */
+#define RXMISS_MISSCOUNT(x) ((x) >> 6)
+
+/* TXCOL */
+#define TXCOL_COLCOUNT(x) ((x) >> 6)
+
+/* SELFST */
+#define SELFST_T3VACTIVE	0x0040
+#define SELFST_INITD		0x0080
+#define SELFST_SIBUSY		0x0100
+#define SELFST_EEPROMPRESENT	0x0200
+#define SELFST_EEPROMOK		0x0400
+#define SELFST_ELPRESENT	0x0800
+#define SELFST_EESIZE		0x1000
+
+/* EEPROMCOMMAND */
+#define EEPROMCOMMAND_EEWRITE	0x0100
+#define EEPROMCOMMAND_EEREAD	0x0200
+#define EEPROMCOMMAND_EEERASE	0x0300
+#define EEPROMCOMMAND_ELSEL	0x0400
+
+struct cirrus_eeprom {
+	u16 io_base;		/* I/O Base Address             */
+	u16 irq;		/* Interrupt Number             */
+	u16 dma;		/* DMA Channel Numbers          */
+	u32 mem_base;		/* Memory Base Address          */
+	u32 rom_base;		/* Boot PROM Base Address       */
+	u32 rom_mask;		/* Boot PROM Address Mask       */
+	u8 mac[6];		/* Individual Address           */
+};
+
+struct cirrus_priv {
+	u16 txlen;
+	u16 txafter;		/* Default is After5 (0) */
+	spinlock_t lock;
+	void __iomem *base_addr;
+	struct cirrus_eeprom eeprom;
+};
+
+/*
+ * I/O routines
+ */
+
+static inline u16
+cirrus_read(struct net_device *ndev, u16 reg)
+{
+	struct cirrus_priv *priv = netdev_priv(ndev);
+
+	writew(reg, priv->base_addr + CS89X0_ADDRESS);
+	return readw(priv->base_addr + CS89X0_DATA);
+}
+
+static inline void
+cirrus_write(struct net_device *ndev, u16 reg, u16 value)
+{
+	struct cirrus_priv *priv = netdev_priv(ndev);
+
+	writew(reg, priv->base_addr + CS89X0_ADDRESS);
+	writew(value, priv->base_addr + CS89X0_DATA);
+}
+
+static inline void
+cirrus_set(struct net_device *ndev, u16 reg, u16 value)
+{
+	cirrus_write(ndev, reg, cirrus_read(ndev, reg) | value);
+}
+
+static inline void
+cirrus_clear(struct net_device *ndev, u16 reg, u16 value)
+{
+	cirrus_write(ndev, reg, cirrus_read(ndev, reg) & ~value);
+}
+
+static inline void
+cirrus_frame_read(struct net_device *ndev, struct sk_buff *skb, u16 length)
+{
+	struct cirrus_priv *priv = netdev_priv(ndev);
+
+	readsw(priv->base_addr, skb_put(skb, length), (length + 1) / 2);
+}
+
+static inline void
+cirrus_frame_write(struct net_device *ndev, struct sk_buff *skb)
+{
+	struct cirrus_priv *priv = netdev_priv(ndev);
+
+	writesw(priv->base_addr, skb->data, (skb->len + 1) / 2);
+}
+
+static void
+cirrus_receive(struct net_device *ndev)
+{
+	struct sk_buff *skb;
+	u16 status, length;
+
+	status = cirrus_read(ndev, RXSTATUS);
+	length = cirrus_read(ndev, RXLENGTH);
+
+	if (!(status & RXSTATUS_RXOK)) {
+		ndev->stats.rx_errors++;
+		if ((status & (RXSTATUS_RUNT | RXSTATUS_EXTRADATA)))
+			ndev->stats.rx_length_errors++;
+		if ((status & RXSTATUS_CRCERROR))
+			ndev->stats.rx_crc_errors++;
+		return;
+	}
+
+	skb = dev_alloc_skb(length + 4);
+	if (!skb) {
+		ndev->stats.rx_dropped++;
+		return;
+	}
+
+	skb->dev = ndev;
+	skb_reserve(skb, 2);
+
+	cirrus_frame_read(ndev, skb, length);
+
+	skb->protocol = eth_type_trans(skb, ndev);
+
+	netif_rx(skb);
+	ndev->last_rx = jiffies;
+
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += length;
+}
+
+static int
+cirrus_send_start(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct cirrus_priv *priv = netdev_priv(ndev);
+	u16 status;
+
+	/* Tx start must be done with irq disabled
+	 * else status can be wrong */
+	spin_lock_irq(&priv->lock);
+
+	netif_stop_queue(ndev);
+
+	cirrus_write(ndev, TXCMD, TXCMD_TXSTART(priv->txafter));
+	cirrus_write(ndev, TXLENGTH, skb->len);
+
+	status = cirrus_read(ndev, BUSST);
+	if (!(status & BUSST_RDY4TXNOW)) {
+		ndev->stats.tx_errors++;
+		priv->txlen = 0;
+		spin_unlock_irq(&priv->lock);
+		return NETDEV_TX_BUSY;
+	}
+
+	cirrus_frame_write(ndev, skb);
+
+	ndev->trans_start = jiffies;
+	spin_unlock_irq(&priv->lock);
+
+	dev_kfree_skb(skb);
+
+	priv->txlen = skb->len;
+
+	return NETDEV_TX_OK;
+}
+
+static irqreturn_t cirrus_interrupt(int irq, void *id)
+{
+	struct net_device *ndev = (struct net_device *)id;
+	struct cirrus_priv *priv = netdev_priv(ndev);
+	u16 status;
+
+	spin_lock(&priv->lock);
+
+	while ((status = cirrus_read(ndev, ISQ))) {
+		switch (ISQ_REGNUM(status)) {
+		case ISQ_RXEVENT:
+			cirrus_receive(ndev);
+			break;
+
+		case ISQ_TXEVENT:
+			ndev->stats.collisions +=
+			    TXCOL_COLCOUNT(cirrus_read(ndev, TXCOL));
+			if (!(ISQ_REGCONTENT(status) & TXEVENT_TXOK)) {
+				ndev->stats.tx_errors++;
+				if (ISQ_REGCONTENT(status) &
+						TXEVENT_OUT_OF_WINDOW)
+					ndev->stats.tx_window_errors++;
+				if (ISQ_REGCONTENT(status) & TXEVENT_JABBER)
+					ndev->stats.tx_aborted_errors++;
+				break;
+			} else if (priv->txlen) {
+				ndev->stats.tx_packets++;
+				ndev->stats.tx_bytes += priv->txlen;
+			}
+			priv->txlen = 0;
+			netif_wake_queue(ndev);
+			break;
+
+		case ISQ_BUFEVENT:
+			if ((ISQ_REGCONTENT(status) & BUFEVENT_RXMISS)) {
+				u16 missed =
+				    RXMISS_MISSCOUNT(cirrus_read(ndev,
+							    RXMISS));
+				ndev->stats.rx_errors += missed;
+				ndev->stats.rx_missed_errors += missed;
+			}
+			if (ISQ_REGCONTENT(status) & BUFEVENT_TXUNDERRUN) {
+				ndev->stats.tx_errors++;
+				/* Shift start tx if underruns
+				 * come too often
+				 */
+				switch (ndev->stats.tx_fifo_errors++) {
+				case 3:
+					priv->txafter = TXCMD_AFTER381;
+					break;
+				case 6:
+					priv->txafter = TXCMD_AFTER1021;
+					break;
+				case 9:
+					priv->txafter = TXCMD_AFTERALL;
+					break;
+				}
+			}
+			/* Wakeup only for tx events ! */
+			if (ISQ_REGCONTENT(status) &
+				(BUFEVENT_TXUNDERRUN | BUFEVENT_RDY4TX)) {
+				priv->txlen = 0;
+				netif_wake_queue(ndev);
+			}
+			break;
+
+		case ISQ_TXCOL:
+			ndev->stats.collisions +=
+			    TXCOL_COLCOUNT(cirrus_read(ndev, TXCOL));
+			break;
+
+		case ISQ_RXMISS:
+			status = RXMISS_MISSCOUNT(cirrus_read(ndev, RXMISS));
+			ndev->stats.rx_errors += status;
+			ndev->stats.rx_missed_errors += status;
+			break;
+		}
+	}
+
+	spin_unlock(&priv->lock);
+	return IRQ_HANDLED;
+}
+
+static void
+cirrus_transmit_timeout(struct net_device *ndev)
+{
+	struct cirrus_priv *priv = netdev_priv(ndev);
+
+	ndev->stats.tx_errors++;
+	ndev->stats.tx_heartbeat_errors++;
+	priv->txlen = 0;
+	netif_wake_queue(ndev);
+}
+
+static int
+cirrus_start(struct net_device *ndev)
+{
+	int result;
+
+	/* valid ethernet address? */
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		printk(KERN_ERR "%s: invalid ethernet MAC address\n",
+		       ndev->name);
+		return -EINVAL;
+	}
+
+	/* install interrupt handler */
+	result = request_irq(ndev->irq, &cirrus_interrupt, 0, ndev->name, ndev);
+	if (result < 0) {
+		printk(KERN_ERR "%s: could not register interrupt %d\n",
+		       ndev->name, ndev->irq);
+		return result;
+	}
+
+	/* enable the ethernet controller */
+	cirrus_set(ndev, RXCFG,
+		   RXCFG_RXOKIE | RXCFG_BUFFERCRC | RXCFG_CRCERRORIE |
+		   RXCFG_RUNTIE | RXCFG_EXTRADATAIE);
+	cirrus_set(ndev, RXCTL, RXCTL_RXOKA | RXCTL_INDIVIDUALA |
+			RXCTL_BROADCASTA);
+	cirrus_set(ndev, TXCFG, TXCFG_TXOKIE | TXCFG_OUT_OF_WINDOWIE |
+			TXCFG_JABBERIE);
+	cirrus_set(ndev, BUFCFG,
+		   BUFCFG_RDY4TXIE | BUFCFG_RXMISSIE |
+		   BUFCFG_TXUNDERRUNIE | BUFCFG_TXCOLOVFIE |
+		   BUFCFG_MISSOVFLOIE);
+	cirrus_set(ndev, LINECTL, LINECTL_SERRXON | LINECTL_SERTXON);
+	cirrus_set(ndev, BUSCTL, BUSCTL_ENABLERQ);
+
+	/* start the queue */
+	netif_start_queue(ndev);
+
+	return 0;
+}
+
+static int
+cirrus_stop(struct net_device *ndev)
+{
+	/* disable ethernet controller */
+	cirrus_write(ndev, BUSCTL, 0);
+	cirrus_write(ndev, TESTCTL, 0);
+	cirrus_write(ndev, SELFCTL, 0);
+	cirrus_write(ndev, LINECTL, 0);
+	cirrus_write(ndev, BUFCFG, 0);
+	cirrus_write(ndev, TXCFG, 0);
+	cirrus_write(ndev, RXCTL, 0);
+	cirrus_write(ndev, RXCFG, 0);
+
+	/* uninstall interrupt handler */
+	free_irq(ndev->irq, ndev);
+
+	/* stop the queue */
+	netif_stop_queue(ndev);
+
+	return 0;
+}
+
+static int
+cirrus_set_mac_address(struct net_device *ndev, void *p)
+{
+	struct cirrus_priv *priv = netdev_priv(ndev);
+	struct sockaddr *addr = (struct sockaddr *) p;
+	int i;
+
+	if (netif_running(ndev))
+		return -EBUSY;
+
+	spin_lock(&priv->lock);
+
+	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+
+	/* configure MAC address */
+	for (i = 0; i < ETH_ALEN; i += 2)
+		cirrus_write(ndev, IA + i,
+			     ndev->dev_addr[i] | (ndev->dev_addr[i + 1] << 8));
+
+	spin_unlock(&priv->lock);
+
+	return 0;
+}
+
+static struct net_device_stats *
+cirrus_get_stats(struct net_device *ndev)
+{
+	return &ndev->stats;
+}
+
+static void
+cirrus_set_receive_mode(struct net_device *ndev)
+{
+	struct cirrus_priv *priv = netdev_priv(ndev);
+
+	spin_lock(&priv->lock);
+
+	if ((ndev->flags & IFF_PROMISC))
+		cirrus_set(ndev, RXCTL, RXCTL_PROMISCUOUSA);
+	else
+		cirrus_clear(ndev, RXCTL, RXCTL_PROMISCUOUSA);
+
+	if ((ndev->flags & IFF_ALLMULTI) || ndev->mc_list)
+		cirrus_set(ndev, RXCTL, RXCTL_MULTICASTA);
+	else
+		cirrus_clear(ndev, RXCTL, RXCTL_MULTICASTA);
+
+	spin_unlock(&priv->lock);
+}
+
+static int
+cirrus_eeprom_wait(struct net_device *ndev)
+{
+	int i;
+
+	for (i = 0; i < 200; i++) {
+		if (!(cirrus_read(ndev, SELFST) & SELFST_SIBUSY))
+			return 0;
+		udelay(1);
+	}
+
+	return -1;
+}
+
+static int
+cirrus_eeprom_read(struct net_device *ndev, u16 *value, u16 offset)
+{
+	if (cirrus_eeprom_wait(ndev) < 0)
+		return -1;
+
+	cirrus_write(ndev, EEPROMCMD, offset | EEPROMCOMMAND_EEREAD);
+
+	if (cirrus_eeprom_wait(ndev) < 0)
+		return -1;
+
+	*value = cirrus_read(ndev, EEPROMDAT);
+
+	return 0;
+}
+
+static int
+cirrus_eeprom(struct net_device *ndev, struct cirrus_eeprom *eeprom)
+{
+	u16 offset, buf[16], *word;
+	u8 checksum = 0, *byte;
+
+	if (cirrus_eeprom_read(ndev, buf, 0) < 0)
+		return -ETIMEDOUT;
+
+
+	if ((buf[0] >> 8) != 0xa1) {
+		printk(KERN_DEBUG "%s: No EEPROM present\n", ndev->name);
+		return -ENODEV;
+	}
+
+	if ((buf[0] & 0xff) < sizeof(buf)) {
+		printk(KERN_DEBUG "%s: EEPROM too small\n", ndev->name);
+		return -ENODEV;
+	}
+
+	for (offset = 1; offset < ((buf[0] & 0xff) >> 1); offset++) {
+		if (cirrus_eeprom_read(ndev, buf + offset, offset) < 0)
+			return -ETIMEDOUT;
+
+		if (buf[offset] == 0xffff)
+			return -ENODEV;
+	}
+
+	if (buf[1] != 0x2020) {
+		printk(KERN_DEBUG "%s: Group Header #1 mismatch\n", ndev->name);
+		return -EIO;
+	}
+
+	if (buf[5] != 0x502c) {
+		printk(KERN_DEBUG "%s: Group Header #2 mismatch\n", ndev->name);
+		return -EIO;
+	}
+
+	if (buf[12] != 0x2158) {
+		printk(KERN_DEBUG "%s: Group Header #3 mismatch\n", ndev->name);
+		return -EIO;
+	}
+
+	eeprom->io_base = buf[2];
+	eeprom->irq = buf[3];
+	eeprom->dma = buf[4];
+	eeprom->mem_base = (buf[7] << 16) | buf[6];
+	eeprom->rom_base = (buf[9] << 16) | buf[8];
+	eeprom->rom_mask = (buf[11] << 16) | buf[10];
+
+	word = (u16 *) eeprom->mac;
+	for (offset = 0; offset < 3; offset++)
+		word[offset] = buf[13 + offset];
+
+	byte = (u8 *) buf;
+	for (offset = 0; offset < sizeof(buf); offset++)
+		checksum += byte[offset];
+
+	if (cirrus_eeprom_read(ndev, &offset, 0x10) < 0)
+		return -ETIMEDOUT;
+
+	if ((offset >> 8) != (u8) (0x100 - checksum)) {
+		printk(KERN_DEBUG
+		       "%s: Checksum mismatch (expected 0x%.2x, got 0x%.2x"
+		       "instead\n",
+		       ndev->name, (u8) (0x100 - checksum), offset >> 8);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+/*
+ * Driver initialization routines
+ */
+static const struct net_device_ops cirrus_netdev_ops = {
+	.ndo_open		= cirrus_start,
+	.ndo_stop		= cirrus_stop,
+	.ndo_start_xmit		= cirrus_send_start,
+	.ndo_get_stats		= cirrus_get_stats,
+	.ndo_set_multicast_list	= cirrus_set_receive_mode,
+	.ndo_set_mac_address	= cirrus_set_mac_address,
+	.ndo_tx_timeout		= cirrus_transmit_timeout,
+};
+
+static int __init
+cirrus_probe(struct platform_device *pdev)
+{
+	struct net_device *ndev;
+	struct resource *res;
+	struct cirrus_priv *priv;
+	int ret, i;
+	u16 value;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENODEV;
+
+	/*
+	 * Request the regions.
+	 */
+	if (!request_mem_region(res->start, resource_size(res), "cs89x0"))
+		return -EBUSY;
+
+	ndev = alloc_etherdev(sizeof(struct cirrus_priv));
+	if (!ndev) {
+		ret = -ENOMEM;
+		goto failed_alloc;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	priv = netdev_priv(ndev);
+
+	ndev->irq = platform_get_irq(pdev, 0);
+
+	priv->base_addr = ioremap(res->start, resource_size(res));
+	if (!priv->base_addr) {
+		ret = -ENOMEM;
+		goto failed_ioremap;
+	}
+	ndev->base_addr = (unsigned long)priv->base_addr;
+
+	platform_set_drvdata(pdev, ndev);
+
+	ether_setup(ndev);
+
+	ndev->netdev_ops = &cirrus_netdev_ops;
+	ndev->watchdog_timeo = HZ;
+
+	ndev->if_port = IF_PORT_10BASET;
+
+	spin_lock_init(&priv->lock);
+
+	/* if an EEPROM is present, use it's MAC address */
+	if (!cirrus_eeprom(ndev, &priv->eeprom))
+		for (i = 0; i < 6; i++)
+			ndev->dev_addr[i] = priv->eeprom.mac[i];
+	else
+		random_ether_addr(ndev->dev_addr);
+
+	/* verify EISA registration number for Cirrus Logic */
+	value = cirrus_read(ndev, PRODUCTID);
+	if (value != EISA_REG_CODE) {
+		dev_err(&pdev->dev, "incorrect signature 0x%.4x\n", value);
+		ret = -ENXIO;
+		goto failed_probe;
+	}
+
+	/* verify chip version */
+	value = cirrus_read(ndev, PRODUCTID + 2);
+	if (VERSION(value) != CS8900A) {
+		dev_err(&pdev->dev, "unknown chip version 0x%.8x\n",
+				VERSION(value));
+		ret = -ENXIO;
+		goto failed_probe;
+	}
+	dev_info(&pdev->dev, "CS8900A rev %c detected\n",
+			'B' + REVISION(value) - REV_B);
+
+	/* setup interrupt number */
+	cirrus_write(ndev, INTNUM, 0);
+
+	/* configure MAC address */
+	for (i = 0; i < ETH_ALEN; i += 2)
+		cirrus_write(ndev, IA + i,
+			     ndev->dev_addr[i] | (ndev->dev_addr[i + 1] << 8));
+
+	ret = register_netdev(ndev);
+	if (ret)
+		goto failed_probe;
+
+	return 0;
+
+failed_probe:
+	platform_set_drvdata(pdev, NULL);
+	iounmap(priv->base_addr);
+failed_ioremap:
+	free_netdev(ndev);
+failed_alloc:
+	release_mem_region(res->start, resource_size(res));
+
+	return ret;
+}
+
+static int
+cirrus_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct cirrus_priv *priv = netdev_priv(ndev);
+	struct resource *res;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+
+	unregister_netdev(ndev);
+	iounmap(priv->base_addr);
+	free_netdev(ndev);
+	release_mem_region(res->start, resource_size(res));
+
+	return 0;
+}
+
+static struct platform_driver cirrus_driver = {
+	.probe = cirrus_probe,
+	.remove = cirrus_remove,
+	.driver = {
+		.name = "cirrus-cs89x0",
+	},
+};
+
+static int __init
+cirrus_init(void)
+{
+	return platform_driver_register(&cirrus_driver);
+}
+
+static void __exit
+cirrus_cleanup(void)
+{
+	platform_driver_unregister(&cirrus_driver);
+}
+
+MODULE_AUTHOR("Abraham van der Merwe <abraham@2d3d.co.za>");
+MODULE_DESCRIPTION("Cirrus Logic CS8900A driver for Linux");
+MODULE_LICENSE("GPL");
+
+module_init(cirrus_init);
+module_exit(cirrus_cleanup);
-- 
1.6.2.1

