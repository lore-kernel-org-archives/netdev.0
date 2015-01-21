From: Dick Hollenbeck <dick@softplc.com>
Subject: [PATCH net 1/1]: ks8695net.c and supporting files
Date: Wed, 21 Jan 2015 17:51:27 -0600
Message-ID: <54C03B7F.10906@softplc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_softplc-vm-5222-1421884289-0001-2"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.softplc.com ([205.238.213.17]:42144 "EHLO mail.softplc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbbAUX4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 18:56:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_softplc-vm-5222-1421884289-0001-2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

This patch is against a 3.14 kernel, but I think this should apply to most new kernels
very easily.

We make a board with this chip on it, so I am willing to be the maintainer of this driver
if it not made too difficult.  This will be the case for a few more years.

I don't know all your rules but I've been writing interrupt handlers and C code longer
than Linus, please go easy on me.  I will not be a regular contributor.

Thanks,

Dick Hollenbeck




--=_softplc-vm-5222-1421884289-0001-2
Content-Type: text/x-patch; name="ks8695net.patch"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ks8695net.patch"

The ks8695 SOC rx_ring was overflowing under heavy network or cpu load.
This confused the rx DMA engine into sporadic behaviour, and a reboot was
required.

Increase the rx_ring size.

Interleave replentishment of the rx_ring descriptors as they are drained
making any given number of descriptors more effective.

Add ISRs for significant MAC DMA events so that the interrupt
status register does not have to be polled on every interrupt.

Add comments and improve style.


Signed-off-by: Dick Hollenbeck <dick@softplc.com>

=== modified file 'arch/arm/mach-ks8695/devices.c'
--- old/arch/arm/mach-ks8695/devices.c	2014-10-21 19:15:28 +0000
+++ new/arch/arm/mach-ks8695/devices.c	2015-01-21 21:29:53 +0000
@@ -39,20 +39,21 @@ static u64 eth_dmamask = 0xffffffffUL;

 static struct resource ks8695_wan_resources[] = {
	[0] = {
+		.name	= "WAN REGS",
		.start	= KS8695_WAN_PA,
		.end	= KS8695_WAN_PA + 0x00ff,
		.flags	= IORESOURCE_MEM,
	},
	[1] = {
		.name	= "WAN RX",
-		.start	= KS8695_IRQ_WAN_RX_STATUS,
-		.end	= KS8695_IRQ_WAN_RX_STATUS,
+		.start	= KS8695_IRQ_WAN_RX,
+		.end	= KS8695_IRQ_WAN_RX,
		.flags	= IORESOURCE_IRQ,
	},
	[2] = {
		.name	= "WAN TX",
-		.start	= KS8695_IRQ_WAN_TX_STATUS,
-		.end	= KS8695_IRQ_WAN_TX_STATUS,
+		.start	= KS8695_IRQ_WAN_TX,
+		.end	= KS8695_IRQ_WAN_TX,
		.flags	= IORESOURCE_IRQ,
	},
	[3] = {
@@ -83,20 +84,21 @@ static struct platform_device ks8695_wan

 static struct resource ks8695_lan_resources[] = {
	[0] = {
+		.name	= "LAN REGS",
		.start	= KS8695_LAN_PA,
		.end	= KS8695_LAN_PA + 0x00ff,
		.flags	= IORESOURCE_MEM,
	},
	[1] = {
		.name	= "LAN RX",
-		.start	= KS8695_IRQ_LAN_RX_STATUS,
-		.end	= KS8695_IRQ_LAN_RX_STATUS,
+		.start	= KS8695_IRQ_LAN_RX,
+		.end	= KS8695_IRQ_LAN_RX,
		.flags	= IORESOURCE_IRQ,
	},
	[2] = {
		.name	= "LAN TX",
-		.start	= KS8695_IRQ_LAN_TX_STATUS,
-		.end	= KS8695_IRQ_LAN_TX_STATUS,
+		.start	= KS8695_IRQ_LAN_TX,
+		.end	= KS8695_IRQ_LAN_TX,
		.flags	= IORESOURCE_IRQ,
	},
	[3] = {
@@ -127,14 +129,14 @@ static struct resource ks8695_hpna_resou
	},
	[1] = {
		.name	= "HPNA RX",
-		.start	= KS8695_IRQ_HPNA_RX_STATUS,
-		.end	= KS8695_IRQ_HPNA_RX_STATUS,
+		.start	= KS8695_IRQ_HPNA_RX,
+		.end	= KS8695_IRQ_HPNA_RX,
		.flags	= IORESOURCE_IRQ,
	},
	[2] = {
		.name	= "HPNA TX",
-		.start	= KS8695_IRQ_HPNA_TX_STATUS,
-		.end	= KS8695_IRQ_HPNA_TX_STATUS,
+		.start	= KS8695_IRQ_HPNA_TX,
+		.end	= KS8695_IRQ_HPNA_TX,
		.flags	= IORESOURCE_IRQ,
	},
 };

=== modified file 'arch/arm/mach-ks8695/include/mach/irqs.h'
--- old/arch/arm/mach-ks8695/include/mach/irqs.h	2014-10-21 19:15:28 +0000
+++ new/arch/arm/mach-ks8695/include/mach/irqs.h	2015-01-20 21:24:38 +0000
@@ -30,25 +30,25 @@
 #define KS8695_IRQ_UART_RX		9
 #define KS8695_IRQ_UART_LINE_STATUS	10
 #define KS8695_IRQ_UART_MODEM_STATUS	11
-#define KS8695_IRQ_LAN_RX_STOP		12
-#define KS8695_IRQ_LAN_TX_STOP		13
-#define KS8695_IRQ_LAN_RX_BUF		14
-#define KS8695_IRQ_LAN_TX_BUF		15
-#define KS8695_IRQ_LAN_RX_STATUS	16
-#define KS8695_IRQ_LAN_TX_STATUS	17
-#define KS8695_IRQ_HPNA_RX_STOP		18
-#define KS8695_IRQ_HPNA_TX_STOP		19
-#define KS8695_IRQ_HPNA_RX_BUF		20
-#define KS8695_IRQ_HPNA_TX_BUF		21
-#define KS8695_IRQ_HPNA_RX_STATUS	22
-#define KS8695_IRQ_HPNA_TX_STATUS	23
+#define KS8695_IRQ_LAN_RPS		12
+#define KS8695_IRQ_LAN_TPS		13
+#define KS8695_IRQ_LAN_RBU		14
+#define KS8695_IRQ_LAN_TBU		15
+#define KS8695_IRQ_LAN_RX		16
+#define KS8695_IRQ_LAN_TX		17
+#define KS8695_IRQ_HPNA_RPS		18
+#define KS8695_IRQ_HPNA_TPS		19
+#define KS8695_IRQ_HPNA_RBU		20
+#define KS8695_IRQ_HPNA_TBU		21
+#define KS8695_IRQ_HPNA_RX		22
+#define KS8695_IRQ_HPNA_TX		23
 #define KS8695_IRQ_BUS_ERROR		24
-#define KS8695_IRQ_WAN_RX_STOP		25
-#define KS8695_IRQ_WAN_TX_STOP		26
-#define KS8695_IRQ_WAN_RX_BUF		27
-#define KS8695_IRQ_WAN_TX_BUF		28
-#define KS8695_IRQ_WAN_RX_STATUS	29
-#define KS8695_IRQ_WAN_TX_STATUS	30
+#define KS8695_IRQ_WAN_RPS		25
+#define KS8695_IRQ_WAN_TPS		26
+#define KS8695_IRQ_WAN_RBU		27
+#define KS8695_IRQ_WAN_TBU		28
+#define KS8695_IRQ_WAN_RX		29
+#define KS8695_IRQ_WAN_TX		30
 #define KS8695_IRQ_WAN_LINK		31

 #endif

=== modified file 'arch/arm/mach-ks8695/include/mach/regs-lan.h'
--- old/arch/arm/mach-ks8695/include/mach/regs-lan.h	2014-10-21 19:15:28 +0000
+++ new/arch/arm/mach-ks8695/include/mach/regs-lan.h	2015-01-21 22:02:41 +0000
@@ -18,6 +18,7 @@
 #define KS8695_LAN_PA		(KS8695_IO_PA + KS8695_LAN_OFFSET)


+#if 0
 /*
  * LAN registers
  */
@@ -61,5 +62,6 @@
 /* Additional Station Address High */
 #define LMAAH_E			(1    << 31)	/* Address Enabled */

+#endif

 #endif

=== modified file 'arch/arm/mach-ks8695/include/mach/regs-wan.h'
--- old/arch/arm/mach-ks8695/include/mach/regs-wan.h	2014-10-21 19:15:28 +0000
+++ new/arch/arm/mach-ks8695/include/mach/regs-wan.h	2015-01-21 22:03:42 +0000
@@ -18,6 +18,7 @@
 #define KS8695_WAN_PA		(KS8695_IO_PA + KS8695_WAN_OFFSET)


+#if 0
 /*
  * WAN registers
  */
@@ -61,5 +62,6 @@
 /* Additional Station Address High */
 #define WMAAH_E			(1    << 31)	/* Address Enabled */

+#endif

 #endif

=== modified file 'arch/arm/mach-ks8695/irq.c'
--- old/arch/arm/mach-ks8695/irq.c	2014-10-21 19:15:28 +0000
+++ new/arch/arm/mach-ks8695/irq.c	2015-01-21 21:34:18 +0000
@@ -36,29 +36,33 @@

 static void ks8695_irq_mask(struct irq_data *d)
 {
-	unsigned long inten;
+	int inten = __raw_readl(KS8695_IRQ_VA + KS8695_INTEN);
+	int mask  = 1 << d->irq;

-	inten = __raw_readl(KS8695_IRQ_VA + KS8695_INTEN);
-	inten &= ~(1 << d->irq);
-
-	__raw_writel(inten, KS8695_IRQ_VA + KS8695_INTEN);
+	__raw_writel(inten & ~mask, KS8695_IRQ_VA + KS8695_INTEN);
 }

 static void ks8695_irq_unmask(struct irq_data *d)
 {
-	unsigned long inten;
-
-	inten = __raw_readl(KS8695_IRQ_VA + KS8695_INTEN);
-	inten |= (1 << d->irq);
+	int inten = __raw_readl(KS8695_IRQ_VA + KS8695_INTEN);
+	int mask  = 1 << d->irq;

-	__raw_writel(inten, KS8695_IRQ_VA + KS8695_INTEN);
+	__raw_writel(inten | mask, KS8695_IRQ_VA + KS8695_INTEN);
 }

 static void ks8695_irq_ack(struct irq_data *d)
 {
-	__raw_writel((1 << d->irq), KS8695_IRQ_VA + KS8695_INTST);
+	__raw_writel(1 << d->irq, KS8695_IRQ_VA + KS8695_INTST);
 }

+static void ks8695_irq_mask_ack(struct irq_data *d)
+{
+	int inten = __raw_readl(KS8695_IRQ_VA + KS8695_INTEN);
+	int mask  = 1 << d->irq;
+
+	__raw_writel(inten & ~mask, KS8695_IRQ_VA + KS8695_INTEN);
+	__raw_writel(mask, KS8695_IRQ_VA + KS8695_INTST);
+}

 static struct irq_chip ks8695_irq_level_chip;
 static struct irq_chip ks8695_irq_edge_chip;
@@ -66,19 +70,19 @@ static struct irq_chip ks8695_irq_edge_c

 static int ks8695_irq_set_type(struct irq_data *d, unsigned int type)
 {
-	unsigned long ctrl, mode;
-	unsigned short level_triggered = 0;
+	bool level_triggered = false;

-	ctrl = __raw_readl(KS8695_GPIO_VA + KS8695_IOPC);
+	int mode;
+	int ctrl = __raw_readl(KS8695_GPIO_VA + KS8695_IOPC);

	switch (type) {
		case IRQ_TYPE_LEVEL_HIGH:
			mode = IOPC_TM_HIGH;
-			level_triggered = 1;
+			level_triggered = true;
			break;
		case IRQ_TYPE_LEVEL_LOW:
			mode = IOPC_TM_LOW;
-			level_triggered = 1;
+			level_triggered = true;
			break;
		case IRQ_TYPE_EDGE_RISING:
			mode = IOPC_TM_RISING;
@@ -128,6 +132,7 @@ static int ks8695_irq_set_type(struct ir
 }

 static struct irq_chip ks8695_irq_level_chip = {
+	.irq_mask_ack	= ks8695_irq_mask_ack,
	.irq_ack	= ks8695_irq_mask,
	.irq_mask	= ks8695_irq_mask,
	.irq_unmask	= ks8695_irq_unmask,
@@ -135,6 +140,7 @@ static struct irq_chip ks8695_irq_level_
 };

 static struct irq_chip ks8695_irq_edge_chip = {
+	.irq_mask_ack	= ks8695_irq_mask_ack,
	.irq_ack	= ks8695_irq_ack,
	.irq_mask	= ks8695_irq_mask,
	.irq_unmask	= ks8695_irq_unmask,
@@ -143,7 +149,7 @@ static struct irq_chip ks8695_irq_edge_c

 void __init ks8695_init_irq(void)
 {
-	unsigned int irq;
+	int irq;

	/* Disable all interrupts initially */
	__raw_writel(0, KS8695_IRQ_VA + KS8695_INTMC);

=== modified file 'drivers/net/ethernet/micrel/ks8695net.c'
--- old/drivers/net/ethernet/micrel/ks8695net.c	2014-10-23 18:05:25 +0000
+++ new/drivers/net/ethernet/micrel/ks8695net.c	2015-01-21 22:55:31 +0000
@@ -14,8 +14,13 @@
  * Copyright 2008 Simtec Electronics
  *		  Daniel Silverstone <dsilvers@simtec.co.uk>
  *		  Vincent Sanders <vince@simtec.co.uk>
+ * Copyright 2015 SoftPLC Corporation
+ *		  Dick Hollenbeck <dick@softplc.com>
  */

+/* #define DEBUG */
+
+
 #include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/ioport.h>
@@ -41,17 +46,76 @@
 #include <asm/mach/irq.h>
 #include <mach/regs-irq.h>

-#include "ks8695net.h"

 #define MODULENAME	"ks8695_ether"
-#define MODULEVERSION	"1.02"
+#define MODULEVERSION	"1.03"

-/*
- * Transmit and device reset timeout, default 5 seconds.
- */
+
+#if defined(DEBUG)
+#define DPRINT(fmt...)	printk(fmt)
+/* #define DEBUG_IO */
+#else
+#define DPRINT(fmt...)	do { } while (0)
+#endif
+
+
+/* LAN and WAN MAC Registers (offsets from KS8695_LAN_PA or KS8695_WAN_PA)
+ */
+#define MAC_DTXC	0x00		/* DMA Transmit Control */
+#define MAC_DRXC	0x04		/* DMA Receive Control */
+#define MAC_DTSC	0x08		/* DMA Transmit Start Command */
+#define MAC_DRSC	0x0c		/* DMA Receive Start Command */
+#define MAC_TDLB	0x10		/* Transmit Descr List Base Address */
+#define MAC_RDLB	0x14		/* Receive Descr List Base Address */
+#define MAC_MAL		0x18		/* MAC Station Address Low */
+#define MAC_MAH		0x1c		/* MAC Station Address High */
+#define MAC_AAL_(n)	(0x80+((n)*8))	/* MAC Additional Address (0..15) LO */
+#define MAC_AAH_(n)	(0x84+((n)*8))	/* MAC Additional Address (0..15) HI */
+
+/* DMA Transmit Control Register Bits, applicable to offset MAC_DTXC in
+ * each MAC
+ */
+#define DTXC_TRST	(1 << 31)	/* Soft Reset */
+#define DTXC_TBS	(0x3f << 24)	/* Transmit Burst Size */
+#define DTXC_TUCG	(1 << 18)	/* Transmit UDP Checksum Generate */
+#define DTXC_TTCG	(1 << 17)	/* Transmit TCP Checksum Generate */
+#define DTXC_TICG	(1 << 16)	/* Transmit IP Checksum Generate */
+#define DTXC_TFCE	(1 <<  9)	/* Transmit Flow Control Enable */
+#define DTXC_TLB	(1 <<  8)	/* Loopback mode */
+#define DTXC_TEP	(1 <<  2)	/* Transmit Enable Padding */
+#define DTXC_TAC	(1 <<  1)	/* Transmit Add CRC */
+#define DTXC_TE		(1 <<  0)	/* TX Enable */
+
+/* DMA Receive Control Register Bits, applicable to offset MAC_DRXC in
+ * each MAC
+ */
+#define DRXC_RBS	(0x3f << 24)	/* Receive Burst Size */
+#define DRXC_RUCC	(1 << 18)	/* Receive UDP Checksum check */
+#define DRXC_RTCG	(1 << 17)	/* Receive TCP Checksum check */
+#define DRXC_RICG	(1 << 16)	/* Receive IP Checksum check */
+#define DRXC_RFCE	(1 <<  9)	/* Receive Flow Control Enable */
+#define DRXC_RB		(1 <<  6)	/* Receive Broadcast */
+#define DRXC_RM		(1 <<  5)	/* Receive Multicast */
+#define DRXC_RU		(1 <<  4)	/* Receive Unicast */
+#define DRXC_RERR	(1 <<  3)	/* Receive Error Frame */
+#define DRXC_RA		(1 <<  2)	/* Receive All */
+#define DRXC_RE		(1 <<  0)	/* RX Enable */
+
+/* Additional Station Address High Bit */
+#define AAH_E		(1 << 31)	/* Address Enabled */
+
+
+/* Transmit timeout in msecs */
 static int watchdog = 5000;

-/* Hardware structures */
+/* Reset timeout in loop counts */
+static const int reset_timeout = 500000;
+
+/* Descriptor structures are all little endian regardless of code or cpu mode,
+ * and are documented in section
+ * 4.1 Descriptor Lists and Data buffers
+ * of the KS8695PX REG DESCP pdf
+ */

 /**
  *	struct rx_ring_desc - Receive descriptor ring element
@@ -62,7 +126,25 @@ static int watchdog = 5000;
  */
 struct rx_ring_desc {
	__le32	status;
+#define RDES_OWN	(1 << 31)	/* Ownership: 1:DMA, 0:CPU */
+#define RDES_FS		(1 << 30)	/* First Descriptor */
+#define RDES_LS		(1 << 29)	/* Last Descriptor */
+#define RDES_IPE	(1 << 28)	/* IP Checksum error */
+#define RDES_TCPE	(1 << 27)	/* TCP Checksum error */
+#define RDES_UDPE	(1 << 26)	/* UDP Checksum error */
+#define RDES_ES		(1 << 25)	/* Error summary */
+#define RDES_MF		(1 << 24)	/* Multicast Frame */
+#define RDES_RE		(1 << 19)	/* MII Error reported */
+#define RDES_TL		(1 << 18)	/* Frame too Long */
+#define RDES_RF		(1 << 17)	/* Runt Frame */
+#define RDES_CE		(1 << 16)	/* CRC error */
+#define RDES_FT		(1 << 15)	/* Frame Type */
+#define RDES_FLEN	0x7ff		/* Frame Length */
+
	__le32	length;
+#define RDES_RER	(1 << 25)	/* Receive End of Ring */
+#define RDES_RBS	0x7ff		/* Receive Buffer Size */
+
	__le32	data_ptr;
	__le32	next_desc;
 };
@@ -76,7 +158,18 @@ struct rx_ring_desc {
  */
 struct tx_ring_desc {
	__le32	owner;
+#define TDES_OWN		(1 << 31)	/* Ownership: 1:DMA, 0:CPU */
+
	__le32	status;
+#define TDES_IC		(1 << 31)	/* Interrupt on Completion */
+#define TDES_FS		(1 << 30)	/* First Segment */
+#define TDES_LS		(1 << 29)	/* Last Segment */
+#define TDES_IPCKG	(1 << 28)	/* IP Checksum generate */
+#define TDES_TCPCKG	(1 << 27)	/* TCP Checksum generate */
+#define TDES_UDPCKG	(1 << 26)	/* UDP Checksum generate */
+#define TDES_TER	(1 << 25)	/* Transmit End of Ring */
+#define TDES_TBS	0x7ff		/* Transmit Buffer Size */
+
	__le32	data_ptr;
	__le32	next_desc;
 };
@@ -90,24 +183,26 @@ struct tx_ring_desc {
 struct ks8695_skbuff {
	struct sk_buff	*skb;
	dma_addr_t	dma_ptr;
-	u32		length;
+	unsigned	length;
 };

 /* Private device structure */

-#define MAX_TX_DESC 8
-#define MAX_TX_DESC_MASK 0x7
-#define MAX_RX_DESC 16
-#define MAX_RX_DESC_MASK 0xf
-
-/*napi_weight have better more than rx DMA buffers*/
-#define NAPI_WEIGHT   64
-
-#define MAX_RXBUF_SIZE 0x700
-
-#define TX_RING_DMA_SIZE (sizeof(struct tx_ring_desc) * MAX_TX_DESC)
-#define RX_RING_DMA_SIZE (sizeof(struct rx_ring_desc) * MAX_RX_DESC)
-#define RING_DMA_SIZE (TX_RING_DMA_SIZE + RX_RING_DMA_SIZE)
+#define NUM_TX_DESC		8
+#if defined(DEBUG)
+#define NUM_RX_DESC		8	/* 8 causes deliberate overflows */
+#else
+#define NUM_RX_DESC		32
+#endif
+
+/* napi_weight should be slightly more than NUM_RX_DESC */
+#define NAPI_WEIGHT		(NUM_RX_DESC + NUM_RX_DESC/2)
+
+#define RXBUF_SIZE		0x700
+
+#define TX_RING_DMA_SIZE		(sizeof(struct tx_ring_desc) * NUM_TX_DESC)
+#define RX_RING_DMA_SIZE		(sizeof(struct rx_ring_desc) * NUM_RX_DESC)
+#define RING_DMA_SIZE		(TX_RING_DMA_SIZE + RX_RING_DMA_SIZE)

 /**
  *	enum ks8695_dtype - Device type
@@ -126,7 +221,6 @@ enum ks8695_dtype {
  *	@in_suspend: Flag to indicate if we're suspending/resuming
  *	@ndev: The net_device for this interface
  *	@dev: The platform device object for this interface
- *	@dtype: The type of this device
  *	@io_regs: The ioremapped registers for this interface
  *      @napi : Add support NAPI for Rx
  *	@rx_irq_name: The textual name of the RX IRQ from the platform data
@@ -159,13 +253,17 @@ struct ks8695_priv {
	int in_suspend;
	struct net_device *ndev;
	struct device *dev;
-	enum ks8695_dtype dtype;
	void __iomem *io_regs;

	struct napi_struct	napi;

-	const char *rx_irq_name, *tx_irq_name, *link_irq_name;
-	int rx_irq, tx_irq, link_irq;
+	const char *rx_irq_name, *rbu_irq_name, *rps_irq_name;
+	const char *tx_irq_name, *tps_irq_name;
+	const char *link_irq_name;
+
+	int rx_irq, rbu_irq, rps_irq;
+	int tx_irq, tps_irq;
+	int link_irq;

	struct resource *regs_req, *phyiface_req;
	void __iomem *phyiface_regs;
@@ -177,67 +275,148 @@ struct ks8695_priv {
	int tx_ring_used;
	int tx_ring_next_slot;
	dma_addr_t tx_ring_dma;
-	struct ks8695_skbuff tx_buffers[MAX_TX_DESC];
+	struct ks8695_skbuff tx_buffers[NUM_TX_DESC];
	spinlock_t txq_lock;

	struct rx_ring_desc *rx_ring;
	dma_addr_t rx_ring_dma;
-	struct ks8695_skbuff rx_buffers[MAX_RX_DESC];
+	struct ks8695_skbuff rx_buffers[NUM_RX_DESC];
	int next_rx_desc_read;
	spinlock_t rx_lock;

+	int rx_mask;
+
	int msg_enable;
 };

-/* Register access */
+
+static void
+ks8695_timeout(struct net_device *ndev);
+
+inline int next_tx(int tx_descriptor_index)
+{
+#if	NUM_TX_DESC == 2   || NUM_TX_DESC == 4  || NUM_TX_DESC == 8  || \
+	NUM_TX_DESC == 16  || NUM_TX_DESC == 32 || NUM_TX_DESC == 64 || \
+	NUM_TX_DESC == 128 || NUM_TX_DESC == 256
+	return (tx_descriptor_index + 1) & (NUM_TX_DESC-1);
+#else
+	int ret = tx_descriptor_index + 1;
+	return ret < NUM_TX_DESC ? ret : 0;
+#endif
+}
+
+
+inline int next_rx(int rx_descriptor_index)
+{
+#if	NUM_RX_DESC == 2   || NUM_RX_DESC == 4  || NUM_RX_DESC == 8  || \
+	NUM_RX_DESC == 16  || NUM_RX_DESC == 32 || NUM_RX_DESC == 64 || \
+	NUM_RX_DESC == 128 || NUM_RX_DESC == 256
+	return (rx_descriptor_index + 1) & (NUM_RX_DESC-1);
+#else
+	int ret = rx_descriptor_index + 1;
+	return ret < NUM_RX_DESC ? ret : 0;
+#endif
+}
+
+
+/* [Instrumented] Register access */

 /**
- *	ks8695_readreg - Read from a KS8695 ethernet register
+ *	ks8695_readmac - Read from a KS8695 ethernet register
  *	@ksp: The device to read from
  *	@reg: The register to read
  */
-static inline u32
-ks8695_readreg(struct ks8695_priv *ksp, int reg)
+static inline int
+ks8695_readmac(struct ks8695_priv *ksp, int reg)
 {
-	return readl(ksp->io_regs + reg);
+	int r = readl(ksp->io_regs + reg);
+#if 0 && defined(DEBUG_IO)
+	printk("r[%d]:%02x\n", reg, r);
+#endif
+	return r;
 }

 /**
- *	ks8695_writereg - Write to a KS8695 ethernet register
+ *	ks8695_writemac - Write to a KS8695 ethernet register
  *	@ksp: The device to write to
  *	@reg: The register to write
  *	@value: The value to write to the register
  */
 static inline void
-ks8695_writereg(struct ks8695_priv *ksp, int reg, u32 value)
+ks8695_writemac(struct ks8695_priv *ksp, int reg, int value)
 {
	writel(value, ksp->io_regs + reg);
+#if 0 && defined(DEBUG_IO)
+	printk("w[%d]:%02x\n", reg, value);
+#endif
+}
+
+
+/* [Instrumented] SOC (non-MAC) register accesses */
+
+static inline int read_cpu(void __iomem *addr)
+{
+	int value = readl(addr);
+#if defined(DEBUG_IO)
+	int offset = (int) addr & 0xffff;
+	if (offset == 0xe208)
+		printk("isr>%x ", value);
+	else if (offset == 0xe204)
+		printk("ier>%x ", value);
+	else
+		printk("%x>%x ", offset, value);
+#endif
+	return value;
+}
+
+static inline void write_cpu(int value, void __iomem *addr)
+{
+	writel(value, addr);
+#if defined(DEBUG_IO)
+	int offset = (int) addr & 0xffff;
+	if (offset == 0xe208)
+		printk("isr<%x ", value);
+	else if (offset == 0xe204)
+		printk("ier<%x ", value);
+	else
+		printk("%x<%x ", offset, value);
+#endif
 }

+
 /* Utility functions */

 /**
- *	ks8695_port_type - Retrieve port-type as user-friendly string
+ *	ks8695_port_name - Retrieve port-type as user-friendly string
  *	@ksp: The device to return the type for
  *
  *	Returns a string indicating which of the WAN, LAN or HPNA
  *	ports this device is likely to represent.
  */
 static const char *
-ks8695_port_type(struct ks8695_priv *ksp)
+ks8695_port_name(struct ks8695_priv *ksp)
 {
-	switch (ksp->dtype) {
-	case KS8695_DTYPE_LAN:
-		return "LAN";
-	case KS8695_DTYPE_WAN:
-		return "WAN";
-	case KS8695_DTYPE_HPNA:
-		return "HPNA";
+	switch (ksp->rx_irq) {
+	case KS8695_IRQ_LAN_RX:		return "LAN";
+	case KS8695_IRQ_WAN_RX:		return "WAN";
+	case KS8695_IRQ_HPNA_RX:		return "HPNA";
	}

	return "UNKNOWN";
 }

+static enum ks8695_dtype
+ks8695_port_type(struct ks8695_priv *ksp)
+{
+	switch (ksp->rx_irq) {
+	default:
+	case KS8695_IRQ_LAN_RX:		return KS8695_DTYPE_LAN;
+	case KS8695_IRQ_WAN_RX:		return KS8695_DTYPE_WAN;
+	case KS8695_IRQ_HPNA_RX:	return KS8695_DTYPE_HPNA;
+	}
+}
+
+
 /**
  *	ks8695_update_mac - Update the MAC registers in the device
  *	@ksp: The device to update
@@ -248,17 +427,54 @@ ks8695_port_type(struct ks8695_priv *ksp
 static void
 ks8695_update_mac(struct ks8695_priv *ksp)
 {
+	DPRINT("%s:\n", __func__+7);
+
	/* Update the HW with the MAC from the net_device */
	struct net_device *ndev = ksp->ndev;
-	u32 machigh, maclow;

-	maclow	= ((ndev->dev_addr[2] << 24) | (ndev->dev_addr[3] << 16) |
-		   (ndev->dev_addr[4] <<  8) | (ndev->dev_addr[5] <<  0));
-	machigh = ((ndev->dev_addr[0] <<  8) | (ndev->dev_addr[1] <<  0));
+	int mac_lo =	(ndev->dev_addr[2] << 24) |
+			(ndev->dev_addr[3] << 16) |
+			(ndev->dev_addr[4] <<  8) |
+			(ndev->dev_addr[5] <<  0);

-	ks8695_writereg(ksp, KS8695_MAL, maclow);
-	ks8695_writereg(ksp, KS8695_MAH, machigh);
+	int mac_hi =	(ndev->dev_addr[0] <<  8) |
+			(ndev->dev_addr[1] <<  0);

+	ks8695_writemac(ksp, MAC_MAL, mac_lo);
+	ks8695_writemac(ksp, MAC_MAH, mac_hi);
+}
+
+static void
+ks8695_refill_one_rxbuffer(struct ks8695_priv *ksp, int buff_n)
+{
+	struct sk_buff *skb = netdev_alloc_skb(ksp->ndev, RXBUF_SIZE);
+
+	ksp->rx_buffers[buff_n].skb = skb;
+
+	if (skb) {
+		dma_addr_t mapping = dma_map_single(ksp->dev,
+				skb->data, RXBUF_SIZE, DMA_FROM_DEVICE);
+
+		if (likely(!dma_mapping_error(ksp->dev, mapping))) {
+			ksp->rx_buffers[buff_n].dma_ptr = mapping;
+
+			/* Record new mapping into DMA ring */
+			ksp->rx_ring[buff_n].data_ptr = cpu_to_le32(mapping);
+
+			wmb();
+
+			/* give ownership of descriptor to DMA engine */
+			ksp->rx_ring[buff_n].status = cpu_to_le32(RDES_OWN);
+		} else {
+			/* Failed to DMA map this SKB, try later */
+			dev_kfree_skb_irq(skb);
+			ksp->rx_buffers[buff_n].skb = NULL;
+			DPRINT("refill: no dma_map\n");
+		}
+	} else {
+		/* Failed to allocate, we'll try again later. */
+		DPRINT("refill: no skb\n");
+	}
 }

 /**
@@ -273,48 +489,18 @@ ks8695_update_mac(struct ks8695_priv *ks
 static void
 ks8695_refill_rxbuffers(struct ks8695_priv *ksp)
 {
-	/* Run around the RX ring, filling in any missing sk_buff's */
	int buff_n;

-	for (buff_n = 0; buff_n < MAX_RX_DESC; ++buff_n) {
-		if (!ksp->rx_buffers[buff_n].skb) {
-			struct sk_buff *skb =
-				netdev_alloc_skb(ksp->ndev, MAX_RXBUF_SIZE);
-			dma_addr_t mapping;
-
-			ksp->rx_buffers[buff_n].skb = skb;
-			if (skb == NULL) {
-				/* Failed to allocate one, perhaps
-				 * we'll try again later.
-				 */
-				break;
-			}
+	for (buff_n = 0; buff_n < NUM_RX_DESC; ++buff_n) {

-			mapping = dma_map_single(ksp->dev, skb->data,
-						 MAX_RXBUF_SIZE,
-						 DMA_FROM_DEVICE);
-			if (unlikely(dma_mapping_error(ksp->dev, mapping))) {
-				/* Failed to DMA map this SKB, try later */
-				dev_kfree_skb_irq(skb);
-				ksp->rx_buffers[buff_n].skb = NULL;
-				break;
-			}
-			ksp->rx_buffers[buff_n].dma_ptr = mapping;
-			ksp->rx_buffers[buff_n].length = MAX_RXBUF_SIZE;
-
-			/* Record this into the DMA ring */
-			ksp->rx_ring[buff_n].data_ptr = cpu_to_le32(mapping);
-			ksp->rx_ring[buff_n].length =
-				cpu_to_le32(MAX_RXBUF_SIZE);
-
-			wmb();
-
-			/* And give ownership over to the hardware */
-			ksp->rx_ring[buff_n].status = cpu_to_le32(RDES_OWN);
+		/* fill only missing ones */
+		if (!ksp->rx_buffers[buff_n].skb) {
+			ks8695_refill_one_rxbuffer(ksp, buff_n);
		}
	}
 }

+
 /* Maximum number of multicast addresses which the KS8695 HW supports */
 #define KS8695_NR_ADDRESSES	16

@@ -332,28 +518,46 @@ static void
 ks8695_init_partial_multicast(struct ks8695_priv *ksp,
			      struct net_device *ndev)
 {
-	u32 low, high;
-	int i;
+	DPRINT("%s:\n", __func__+7);
+
	struct netdev_hw_addr *ha;

-	i = 0;
+	int hi, lo;
+
+	int i = 0;
	netdev_for_each_mc_addr(ha, ndev) {
		/* Ran out of space in chip? */
		BUG_ON(i == KS8695_NR_ADDRESSES);
+		if (i < KS8695_NR_ADDRESSES) {
+			lo =	(ha->addr[2] << 24) |
+				(ha->addr[3] << 16) |
+				(ha->addr[4] <<  8) |
+				(ha->addr[5] <<  0);
+
+			hi =	(ha->addr[0] << 8) |
+				(ha->addr[1] << 0);
+
+			DPRINT(" %02x:%02x:%02x:%02x:%02x:%02x\n",
+				ha->addr[0],
+				ha->addr[1],
+				ha->addr[2],
+				ha->addr[3],
+				ha->addr[4],
+				ha->addr[5]
+				);

-		low = (ha->addr[2] << 24) | (ha->addr[3] << 16) |
-		      (ha->addr[4] << 8) | (ha->addr[5]);
-		high = (ha->addr[0] << 8) | (ha->addr[1]);
-
-		ks8695_writereg(ksp, KS8695_AAL_(i), low);
-		ks8695_writereg(ksp, KS8695_AAH_(i), AAH_E | high);
+			ks8695_writemac(ksp, MAC_AAL_(i), lo);
+			ks8695_writemac(ksp, MAC_AAH_(i), AAH_E | hi);
+		}
		i++;
	}

+	DPRINT(" clearing %d mac addrs\n", KS8695_NR_ADDRESSES - i);
+
	/* Clear the remaining Additional Station Addresses */
	for (; i < KS8695_NR_ADDRESSES; i++) {
-		ks8695_writereg(ksp, KS8695_AAL_(i), 0);
-		ks8695_writereg(ksp, KS8695_AAH_(i), 0);
+		ks8695_writemac(ksp, MAC_AAL_(i), 0);
+		ks8695_writemac(ksp, MAC_AAH_(i), 0);
	}
 }

@@ -371,16 +575,23 @@ ks8695_init_partial_multicast(struct ks8
 static irqreturn_t
 ks8695_tx_irq(int irq, void *dev_id)
 {
+	DPRINT("T");
+
	struct net_device *ndev = (struct net_device *)dev_id;
	struct ks8695_priv *ksp = netdev_priv(ndev);
	int buff_n;

-	for (buff_n = 0; buff_n < MAX_TX_DESC; ++buff_n) {
+	spin_lock(&ksp->txq_lock);
+
+	for (buff_n = 0; buff_n < NUM_TX_DESC; ++buff_n) {
		if (ksp->tx_buffers[buff_n].skb &&
		    !(ksp->tx_ring[buff_n].owner & cpu_to_le32(TDES_OWN))) {
+
			rmb();
-			/* An SKB which is not owned by HW is present */
-			/* Update the stats for the net_device */
+
+			/* An SKB which is not owned by HW is present,
+			 * update the stats for the net_device
+			 */
			ndev->stats.tx_packets++;
			ndev->stats.tx_bytes += ksp->tx_buffers[buff_n].length;

@@ -392,36 +603,68 @@ ks8695_tx_irq(int irq, void *dev_id)
					 ksp->tx_buffers[buff_n].dma_ptr,
					 ksp->tx_buffers[buff_n].length,
					 DMA_TO_DEVICE);
+
			dev_kfree_skb_irq(ksp->tx_buffers[buff_n].skb);
			ksp->tx_buffers[buff_n].skb = NULL;
			ksp->tx_ring_used--;
		}
	}

-	netif_wake_queue(ndev);
+	spin_unlock(&ksp->txq_lock);
+
+	if (netif_queue_stopped(ndev))
+		netif_wake_queue(ndev);

	return IRQ_HANDLED;
 }

-/**
- *	ks8695_get_rx_enable_bit - Get rx interrupt enable/status bit
- *	@ksp: Private data for the KS8695 Ethernet
- *
- *    For KS8695 document:
- *    Interrupt Enable Register (offset 0xE204)
- *        Bit29 : WAN MAC Receive Interrupt Enable
- *        Bit16 : LAN MAC Receive Interrupt Enable
- *    Interrupt Status Register (Offset 0xF208)
- *        Bit29: WAN MAC Receive Status
- *        Bit16: LAN MAC Receive Status
- *    So, this Rx interrupt enable/status bit number is equal
- *    as Rx IRQ number.
- */
-static inline u32 ks8695_get_rx_enable_bit(struct ks8695_priv *ksp)
+
+static irqreturn_t
+ks8695_rbu_irq(int irq, void *dev_id)
 {
-	return ksp->rx_irq;
+	DPRINT("OOOOVERFLOWWWW\n");
+
+	struct net_device *ndev = (struct net_device *)dev_id;
+	struct ks8695_priv *ksp = netdev_priv(ndev);
+	int reg = ks8695_readmac(ksp, MAC_DRXC);
+
+	if (reg & DRXC_RE) {
+		/* Turn off the RX DMA, frames are arriving too fast
+		 * for polling to keep up.  Enable RX DMA much later,
+		 * after draining the ring. This gives the RX DMA time
+		 * to fully stop.
+		 */
+		 ks8695_writemac(ksp, MAC_DRXC, reg & ~DRXC_RE);
+
+		 ndev->stats.rx_over_errors++;
+	}
+
+	return IRQ_HANDLED;
 }

+static irqreturn_t
+ks8695_rps_irq(int irq, void *dev_id)
+{
+	DPRINT("RX_STOPPED\n");
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t
+ks8695_tps_irq(int irq, void *dev_id)
+{
+	DPRINT("TX_STOPPED\n");
+
+	struct net_device *ndev = (struct net_device *)dev_id;
+	struct ks8695_priv *ksp = netdev_priv(ndev);
+
+	/* Re-start the TX DMA */
+	ks8695_writemac(ksp, MAC_DTSC, 0);
+
+	return IRQ_HANDLED;
+}
+
+
 /**
  *	ks8695_rx_irq - Receive IRQ handler
  *	@irq: The IRQ which went off (ignored)
@@ -429,60 +672,77 @@ static inline u32 ks8695_get_rx_enable_b
  *
  *	Inform NAPI that packet reception needs to be scheduled
  */
-
 static irqreturn_t
 ks8695_rx_irq(int irq, void *dev_id)
 {
+	/* DPRINT("R%x ", read_cpu(KS8695_IRQ_VA + KS8695_INTST)); */
+	DPRINT("R");
+
	struct net_device *ndev = (struct net_device *)dev_id;
	struct ks8695_priv *ksp = netdev_priv(ndev);

	spin_lock(&ksp->rx_lock);

	if (napi_schedule_prep(&ksp->napi)) {
-		unsigned long status = readl(KS8695_IRQ_VA + KS8695_INTEN);
-		unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
-		/*disable rx interrupt*/
-		status &= ~mask_bit;
-		writel(status , KS8695_IRQ_VA + KS8695_INTEN);
+#if 1
+		/* a faster disable_irq_nosync(ksp->rx_irq); */
+		int ier  = read_cpu(KS8695_IRQ_VA + KS8695_INTEN);
+		write_cpu(ier & ~ksp->rx_mask, KS8695_IRQ_VA + KS8695_INTEN);
+#else
+		disable_irq_nosync(ksp->rx_irq);
+#endif
		__napi_schedule(&ksp->napi);
+	} else {
+		/* http://www.linuxfoundation.org/collaborate/workgroups/networking/napi#NAPI_Driver_design */
+		DPRINT("%s: why another interrupt?\n", __func__);
	}

	spin_unlock(&ksp->rx_lock);
+
	return IRQ_HANDLED;
 }

+
 /**
  *	ks8695_rx - Receive packets called by NAPI poll method
  *	@ksp: Private data for the KS8695 Ethernet
- *	@budget: Number of packets allowed to process
+ *	@budget: Number of packets allowed to process, set in here
+ *       as NAPI_WEIGHT
  */
-static int ks8695_rx(struct ks8695_priv *ksp, int budget)
+inline int ks8695_rx(struct ks8695_priv *ksp, int budget)
 {
+	/* DPRINT("X"); */
+
	struct net_device *ndev = ksp->ndev;
	struct sk_buff *skb;
	int buff_n;
-	u32 flags;
+	int flags;
	int pktlen;
	int received = 0;
+	int loop_count;

-	buff_n = ksp->next_rx_desc_read;
-	while (received < budget
-			&& ksp->rx_buffers[buff_n].skb
-			&& (!(ksp->rx_ring[buff_n].status &
-					cpu_to_le32(RDES_OWN)))) {
-			rmb();
-			flags = le32_to_cpu(ksp->rx_ring[buff_n].status);
+	buff_n = ksp->next_rx_desc_read;   /* next expected frame */

-			/* Found an SKB which we own, this means we
-			 * received a packet
-			 */
-			if ((flags & (RDES_FS | RDES_LS)) !=
-			    (RDES_FS | RDES_LS)) {
+	/* budget is NAPI_WEIGHT */
+	for (loop_count = 0; loop_count < budget;
+			++loop_count, buff_n = next_rx(buff_n)) {
+		if (unlikely(!ksp->rx_buffers[buff_n].skb)) {
+			DPRINT("refill_%u\n", buff_n);
+			ks8695_refill_one_rxbuffer(ksp, buff_n);
+		} else if (!((flags = ksp->rx_ring[buff_n].status) &
+				cpu_to_le32(RDES_OWN))) {
+
+			flags = cpu_to_le32(flags);
+
+			/* Found an SKB which we own, we received a packet */
+			if ((flags & (RDES_FS | RDES_LS)) != (RDES_FS | RDES_LS)) {
				/* This packet is not the first and
				 * the last segment.  Therefore it is
				 * a "spanning" packet and we can't
				 * handle it
				 */
+				DPRINT("rx:spanning\n");
+				ndev->stats.rx_errors++;
				goto rx_failure;
			}

@@ -497,10 +757,16 @@ static int ks8695_rx(struct ks8695_priv
					ndev->stats.rx_crc_errors++;
				if (flags & RDES_RE)
					ndev->stats.rx_missed_errors++;
-
+				DPRINT("rx:flags:%x\n", flags);
				goto rx_failure;
			}

+#if defined(DEBUG)
+			if (!flags) {
+				DPRINT("rx: empty frame!\n");
+			}
+#endif
+
			pktlen = flags & RDES_FLEN;
			pktlen -= 4; /* Drop the CRC */

@@ -522,11 +788,13 @@ static int ks8695_rx(struct ks8695_priv
			skb->protocol = eth_type_trans(skb, ndev);
			netif_receive_skb(skb);

+			ks8695_refill_one_rxbuffer(ksp, buff_n);
+
			/* Record stats */
			ndev->stats.rx_packets++;
			ndev->stats.rx_bytes += pktlen;
-			goto rx_finished;

+			goto rx_finished;
 rx_failure:
			/* This ring entry is an error, but we can
			 * re-use the skb
@@ -534,49 +802,83 @@ rx_failure:
			/* Give the ring entry back to the hardware */
			ksp->rx_ring[buff_n].status = cpu_to_le32(RDES_OWN);
 rx_finished:
+			/* Note which RX descriptor to start from next time */
+			ksp->next_rx_desc_read = next_rx(buff_n);
			received++;
-			buff_n = (buff_n + 1) & MAX_RX_DESC_MASK;
+		} else {
+			/* We've gone around ring fully once, and here we've
+			 * seen an un-filled descriptor, so we're ahead
+			 * of RX DMA, quit.
+			 */
+			if (loop_count >= NUM_RX_DESC)
+				break;
+		}
	}

-	/* And note which RX descriptor we last did */
-	ksp->next_rx_desc_read = buff_n;
-
-	/* And refill the buffers */
-	ks8695_refill_rxbuffers(ksp);
-
-	/* Kick the RX DMA engine, in case it became suspended */
-	ks8695_writereg(ksp, KS8695_DRSC, 0);
-
	return received;
 }

-
 /**
  *	ks8695_poll - Receive packet by NAPI poll method
  *	@ksp: Private data for the KS8695 Ethernet
  *	@budget: The remaining number packets for network subsystem
  *
- *     Invoked by the network core when it requests for new
+ *     Invoked by the network core when it requests new
  *     packets from the driver
  */
 static int ks8695_poll(struct napi_struct *napi, int budget)
 {
	struct ks8695_priv *ksp = container_of(napi, struct ks8695_priv, napi);
-	unsigned long  work_done;
-
-	unsigned long isr = readl(KS8695_IRQ_VA + KS8695_INTEN);
-	unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
-
-	work_done = ks8695_rx(ksp, budget);
+	int work_done = ks8695_rx(ksp, budget);

	if (work_done < budget) {
+		/* Re-enable receiver interrupts only if we have leisure
+		 * time and will stop polling.  Proof of leisure time is
+		 * having done less work than asked for.
+		 */
		unsigned long flags;
+
+		int reg;
+
		spin_lock_irqsave(&ksp->rx_lock, flags);
		__napi_complete(napi);
-		/*enable rx interrupt*/
-		writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN);
+
+		/* We sometimes intentionally turn of RX MAC,
+		 * turn it back on now if off.
+		 */
+		reg = ks8695_readmac(ksp, MAC_DRXC);
+		if (!(reg & DRXC_RE)) {
+			DPRINT("Re-enable RMAC\n");
+#if 1
+			ks8695_writemac(ksp, MAC_DRXC, reg | DRXC_RE);
+		}
+#else
+			/* does not yet recover from overflow */
+			ks8695_timeout(ksp->ndev);
+		} else
+#endif
+
+		/* Kick the RX DMA engine, in case it became suspended.  Quirky,
+		 * seems to timeout from time to time, so rather than hooking
+		 * the RX STOP isr we simply re-enable it here since that's a
+		 * leaner code path.  Also note that we _must_ renable it after
+		 * we've disabled it ourselves under hi inbound traffic.  This
+		 * seems to be the best place for that also, right after setting
+		 * DRXC_RE above.
+		 */
+		ks8695_writemac(ksp, MAC_DRSC, 0);
+
+		/* re-enable rx interrupt */
+#if 1
+		/* faster enable_irq(ksp->rx_irq); */
+		reg  = read_cpu(KS8695_IRQ_VA + KS8695_INTEN);
+		write_cpu(reg | ksp->rx_mask, KS8695_IRQ_VA + KS8695_INTEN);
+#else
+		enable_irq(ksp->rx_irq);
+#endif
		spin_unlock_irqrestore(&ksp->rx_lock, flags);
	}
+
	return work_done;
 }

@@ -591,11 +893,12 @@ static int ks8695_poll(struct napi_struc
 static irqreturn_t
 ks8695_link_irq(int irq, void *dev_id)
 {
+	DPRINT("%s:\n", __func__+7);
+
	struct net_device *ndev = (struct net_device *)dev_id;
	struct ks8695_priv *ksp = netdev_priv(ndev);
-	u32 ctrl;
+	int ctrl = read_cpu(ksp->phyiface_regs + KS8695_WMC);

-	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
	if (ctrl & WMC_WLS) {
		netif_carrier_on(ndev);
		if (netif_msg_link(ksp))
@@ -614,7 +917,6 @@ ks8695_link_irq(int irq, void *dev_id)
	return IRQ_HANDLED;
 }

-
 /* KS8695 Device functions */

 /**
@@ -627,32 +929,39 @@ ks8695_link_irq(int irq, void *dev_id)
 static void
 ks8695_reset(struct ks8695_priv *ksp)
 {
-	int reset_timeout = watchdog;
+	DPRINT("%s:\n", __func__+7);
+
+	int reset_count = reset_timeout;
+
	/* Issue the reset via the TX DMA control register */
-	ks8695_writereg(ksp, KS8695_DTXC, DTXC_TRST);
-	while (reset_timeout--) {
-		if (!(ks8695_readreg(ksp, KS8695_DTXC) & DTXC_TRST))
+	ks8695_writemac(ksp, MAC_DTXC, DTXC_TRST);
+
+	while (reset_count--) {
+		if (!(ks8695_readmac(ksp, MAC_DTXC) & DTXC_TRST))
			break;
-		msleep(1);
+
+		DPRINT("w");
+		/* msleep(1); */
	}

-	if (reset_timeout < 0) {
-		dev_crit(ksp->dev,
-			 "Timeout waiting for DMA engines to reset\n");
+	if (reset_count < 0) {
+		dev_crit(ksp->dev, "Timeout waiting for DMA engines to reset\n");
		/* And blithely carry on */
	}

	/* Definitely wait long enough before attempting to program
	 * the engines
	 */
-	msleep(10);
+	/* msleep(10); */

	/* RX: unicast and broadcast */
-	ks8695_writereg(ksp, KS8695_DRXC, DRXC_RU | DRXC_RB);
+	ks8695_writemac(ksp, MAC_DRXC, DRXC_RU | DRXC_RB);
+
	/* TX: pad and add CRC */
-	ks8695_writereg(ksp, KS8695_DTXC, DTXC_TEP | DTXC_TAC);
+	ks8695_writemac(ksp, MAC_DTXC, DTXC_TEP | DTXC_TAC);
 }

+
 /**
  *	ks8695_shutdown - Shut down a KS8695 ethernet interface
  *	@ksp: The interface to shut down
@@ -664,25 +973,30 @@ ks8695_reset(struct ks8695_priv *ksp)
 static void
 ks8695_shutdown(struct ks8695_priv *ksp)
 {
-	u32 ctrl;
+	DPRINT("%s:\n", __func__+7);
	int buff_n;

	/* Disable packet transmission */
-	ctrl = ks8695_readreg(ksp, KS8695_DTXC);
-	ks8695_writereg(ksp, KS8695_DTXC, ctrl & ~DTXC_TE);
+	int ctrl = ks8695_readmac(ksp, MAC_DTXC);
+	ks8695_writemac(ksp, MAC_DTXC, ctrl & ~DTXC_TE);

	/* Disable packet reception */
-	ctrl = ks8695_readreg(ksp, KS8695_DRXC);
-	ks8695_writereg(ksp, KS8695_DRXC, ctrl & ~DRXC_RE);
+	ctrl = ks8695_readmac(ksp, MAC_DRXC);
+	ks8695_writemac(ksp, MAC_DRXC, ctrl & ~DRXC_RE);

	/* Release the IRQs */
	free_irq(ksp->rx_irq, ksp->ndev);
+	free_irq(ksp->rbu_irq, ksp->ndev);
+	free_irq(ksp->rps_irq, ksp->ndev);
+
	free_irq(ksp->tx_irq, ksp->ndev);
+	free_irq(ksp->tps_irq, ksp->ndev);
+
	if (ksp->link_irq != -1)
		free_irq(ksp->link_irq, ksp->ndev);

	/* Throw away any pending TX packets */
-	for (buff_n = 0; buff_n < MAX_TX_DESC; ++buff_n) {
+	for (buff_n = 0; buff_n < NUM_TX_DESC; ++buff_n) {
		if (ksp->tx_buffers[buff_n].skb) {
			/* Remove this SKB from the TX ring */
			ksp->tx_ring[buff_n].owner = 0;
@@ -700,7 +1014,7 @@ ks8695_shutdown(struct ks8695_priv *ksp)
	}

	/* Purge the RX buffers */
-	for (buff_n = 0; buff_n < MAX_RX_DESC; ++buff_n) {
+	for (buff_n = 0; buff_n < NUM_RX_DESC; ++buff_n) {
		if (ksp->rx_buffers[buff_n].skb) {
			/* Remove the SKB from the RX ring */
			ksp->rx_ring[buff_n].status = 0;
@@ -731,9 +1045,8 @@ static int
 ks8695_setup_irq(int irq, const char *irq_name,
		 irq_handler_t handler, struct net_device *ndev)
 {
-	int ret;
-
-	ret = request_irq(irq, handler, IRQF_SHARED, irq_name, ndev);
+	DPRINT("%s(irq=%d, name=%s)\n", __func__+7, irq, irq_name);
+	int ret = request_irq(irq, handler, IRQF_SHARED, irq_name, ndev);

	if (ret) {
		dev_err(&ndev->dev, "failure to request IRQ %d\n", irq);
@@ -743,6 +1056,7 @@ ks8695_setup_irq(int irq, const char *ir
	return 0;
 }

+
 /**
  *	ks8695_init_net - Initialise a KS8695 ethernet interface
  *	@ksp: The interface to initialise
@@ -754,24 +1068,43 @@ ks8695_setup_irq(int irq, const char *ir
 static int
 ks8695_init_net(struct ks8695_priv *ksp)
 {
+	DPRINT("%s:\n", __func__+7);
+
	int ret;
-	u32 ctrl;
+	int ctrl;

	ks8695_refill_rxbuffers(ksp);

	/* Initialise the DMA engines */
-	ks8695_writereg(ksp, KS8695_RDLB, (u32) ksp->rx_ring_dma);
-	ks8695_writereg(ksp, KS8695_TDLB, (u32) ksp->tx_ring_dma);
+	ks8695_writemac(ksp, MAC_RDLB, (u32) ksp->rx_ring_dma);
+	ks8695_writemac(ksp, MAC_TDLB, (u32) ksp->tx_ring_dma);

	/* Request the IRQs */
-	ret = ks8695_setup_irq(ksp->rx_irq, ksp->rx_irq_name,
-			       ks8695_rx_irq, ksp->ndev);
+	ret = ks8695_setup_irq(ksp->rx_irq,
+			ksp->rx_irq_name, ks8695_rx_irq, ksp->ndev);
	if (ret)
		return ret;
-	ret = ks8695_setup_irq(ksp->tx_irq, ksp->tx_irq_name,
-			       ks8695_tx_irq, ksp->ndev);
+
+	ret = ks8695_setup_irq(ksp->rbu_irq,
+			ksp->rbu_irq_name, ks8695_rbu_irq, ksp->ndev);
+	if (ret)
+		return ret;
+
+	ret = ks8695_setup_irq(ksp->rps_irq,
+			ksp->rps_irq_name, ks8695_rps_irq, ksp->ndev);
	if (ret)
		return ret;
+
+	ret = ks8695_setup_irq(ksp->tx_irq,
+			ksp->tx_irq_name, ks8695_tx_irq, ksp->ndev);
+	if (ret)
+		return ret;
+
+	ret = ks8695_setup_irq(ksp->tps_irq,
+			ksp->tps_irq_name, ks8695_tps_irq, ksp->ndev);
+	if (ret)
+		return ret;
+
	if (ksp->link_irq != -1) {
		ret = ks8695_setup_irq(ksp->link_irq, ksp->link_irq_name,
				       ks8695_link_irq, ksp->ndev);
@@ -785,18 +1118,16 @@ ks8695_init_net(struct ks8695_priv *ksp)
	ksp->tx_ring_used = 0;

	/* Bring up transmission */
-	ctrl = ks8695_readreg(ksp, KS8695_DTXC);
-	/* Enable packet transmission */
-	ks8695_writereg(ksp, KS8695_DTXC, ctrl | DTXC_TE);
+	ctrl = ks8695_readmac(ksp, MAC_DTXC);
+	ks8695_writemac(ksp, MAC_DTXC, ctrl | DTXC_TE);

	/* Bring up the reception */
-	ctrl = ks8695_readreg(ksp, KS8695_DRXC);
-	/* Enable packet reception */
-	ks8695_writereg(ksp, KS8695_DRXC, ctrl | DRXC_RE);
-	/* And start the DMA engine */
-	ks8695_writereg(ksp, KS8695_DRSC, 0);
+	ctrl = ks8695_readmac(ksp, MAC_DRXC);
+	ks8695_writemac(ksp, MAC_DRXC, ctrl | DRXC_RE);
+
+	/* And start the RX DMA engine */
+	ks8695_writemac(ksp, MAC_DRSC, 0);

-	/* All done */
	return 0;
 }

@@ -810,6 +1141,8 @@ ks8695_init_net(struct ks8695_priv *ksp)
 static void
 ks8695_release_device(struct ks8695_priv *ksp)
 {
+	DPRINT("%s:\n", __func__+7);
+
	/* Unmap the registers */
	iounmap(ksp->io_regs);
	if (ksp->phyiface_regs)
@@ -818,6 +1151,7 @@ ks8695_release_device(struct ks8695_priv
	/* And release the request */
	release_resource(ksp->regs_req);
	kfree(ksp->regs_req);
+
	if (ksp->phyiface_req) {
		release_resource(ksp->phyiface_req);
		kfree(ksp->phyiface_req);
@@ -837,6 +1171,7 @@ ks8695_release_device(struct ks8695_priv
 static u32
 ks8695_get_msglevel(struct net_device *ndev)
 {
+	DPRINT("%s:\n", __func__+7);
	struct ks8695_priv *ksp = netdev_priv(ndev);

	return ksp->msg_enable;
@@ -850,6 +1185,7 @@ ks8695_get_msglevel(struct net_device *n
 static void
 ks8695_set_msglevel(struct net_device *ndev, u32 value)
 {
+	DPRINT("%s:\n", __func__+7);
	struct ks8695_priv *ksp = netdev_priv(ndev);

	ksp->msg_enable = value;
@@ -863,8 +1199,9 @@ ks8695_set_msglevel(struct net_device *n
 static int
 ks8695_wan_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 {
+	DPRINT("%s:\n", __func__+7);
	struct ks8695_priv *ksp = netdev_priv(ndev);
-	u32 ctrl;
+	int ctrl;

	/* All ports on the KS8695 support these... */
	cmd->supported = (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -877,7 +1214,7 @@ ks8695_wan_get_settings(struct net_devic
	cmd->supported |= (SUPPORTED_Autoneg | SUPPORTED_Pause);
	cmd->phy_address = 0;

-	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+	ctrl = read_cpu(ksp->phyiface_regs + KS8695_WMC);
	if ((ctrl & WMC_WAND) == 0) {
		/* auto-negotiation is enabled */
		cmd->advertising |= ADVERTISED_Autoneg;
@@ -918,8 +1255,9 @@ ks8695_wan_get_settings(struct net_devic
 static int
 ks8695_wan_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 {
+	DPRINT("%s:\n", __func__+7);
	struct ks8695_priv *ksp = netdev_priv(ndev);
-	u32 ctrl;
+	int ctrl;

	if ((cmd->speed != SPEED_10) && (cmd->speed != SPEED_100))
		return -EINVAL;
@@ -940,7 +1278,7 @@ ks8695_wan_set_settings(struct net_devic
				ADVERTISED_100baseT_Full)) == 0)
			return -EINVAL;

-		ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+		ctrl = read_cpu(ksp->phyiface_regs + KS8695_WMC);

		ctrl &= ~(WMC_WAND | WMC_WANA100F | WMC_WANA100H |
			  WMC_WANA10F | WMC_WANA10H);
@@ -955,9 +1293,9 @@ ks8695_wan_set_settings(struct net_devic

		/* force a re-negotiation */
		ctrl |= WMC_WANR;
-		writel(ctrl, ksp->phyiface_regs + KS8695_WMC);
+		write_cpu(ctrl, ksp->phyiface_regs + KS8695_WMC);
	} else {
-		ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+		ctrl = read_cpu(ksp->phyiface_regs + KS8695_WMC);

		/* disable auto-negotiation */
		ctrl |= WMC_WAND;
@@ -968,7 +1306,7 @@ ks8695_wan_set_settings(struct net_devic
		if (cmd->duplex == DUPLEX_FULL)
			ctrl |= WMC_WANFF;

-		writel(ctrl, ksp->phyiface_regs + KS8695_WMC);
+		write_cpu(ctrl, ksp->phyiface_regs + KS8695_WMC);
	}

	return 0;
@@ -981,14 +1319,12 @@ ks8695_wan_set_settings(struct net_devic
 static int
 ks8695_wan_nwayreset(struct net_device *ndev)
 {
+	DPRINT("%s:\n", __func__+7);
	struct ks8695_priv *ksp = netdev_priv(ndev);
-	u32 ctrl;
-
-	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+	int ctrl = read_cpu(ksp->phyiface_regs + KS8695_WMC);

	if ((ctrl & WMC_WAND) == 0)
-		writel(ctrl | WMC_WANR,
-		       ksp->phyiface_regs + KS8695_WMC);
+		write_cpu(ctrl | WMC_WANR, ksp->phyiface_regs + KS8695_WMC);
	else
		/* auto-negotiation not enabled */
		return -EINVAL;
@@ -1004,21 +1340,20 @@ ks8695_wan_nwayreset(struct net_device *
 static void
 ks8695_wan_get_pause(struct net_device *ndev, struct ethtool_pauseparam *param)
 {
+	DPRINT("%s:\n", __func__+7);
	struct ks8695_priv *ksp = netdev_priv(ndev);
-	u32 ctrl;
-
-	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
+	int ctrl = read_cpu(ksp->phyiface_regs + KS8695_WMC);

	/* advertise Pause */
-	param->autoneg = (ctrl & WMC_WANAP);
+	param->autoneg = ctrl & WMC_WANAP;

	/* current Rx Flow-control */
-	ctrl = ks8695_readreg(ksp, KS8695_DRXC);
-	param->rx_pause = (ctrl & DRXC_RFCE);
+	ctrl = ks8695_readmac(ksp, MAC_DRXC);
+	param->rx_pause = ctrl & DRXC_RFCE;

	/* current Tx Flow-control */
-	ctrl = ks8695_readreg(ksp, KS8695_DTXC);
-	param->tx_pause = (ctrl & DTXC_TFCE);
+	ctrl = ks8695_readmac(ksp, MAC_DTXC);
+	param->tx_pause = ctrl & DTXC_TFCE;
 }

 /**
@@ -1029,27 +1364,37 @@ ks8695_wan_get_pause(struct net_device *
 static void
 ks8695_get_drvinfo(struct net_device *ndev, struct ethtool_drvinfo *info)
 {
+	DPRINT("%s:\n", __func__+7);
	strlcpy(info->driver, MODULENAME, sizeof(info->driver));
	strlcpy(info->version, MODULEVERSION, sizeof(info->version));
	strlcpy(info->bus_info, dev_name(ndev->dev.parent),
		sizeof(info->bus_info));
 }

+#if 0
+static void
+ks8695_get_stats(struct net_device *ndev, struct ethtool_stats *info, u64 *what)
+{
+}
+#endif
+
 static const struct ethtool_ops ks8695_ethtool_ops = {
-	.get_msglevel	= ks8695_get_msglevel,
-	.set_msglevel	= ks8695_set_msglevel,
-	.get_drvinfo	= ks8695_get_drvinfo,
+	.get_msglevel		= ks8695_get_msglevel,
+	.set_msglevel		= ks8695_set_msglevel,
+	.get_drvinfo		= ks8695_get_drvinfo,
+//	.get_ethtool_stats  	= ks8695_get_stats,
 };

 static const struct ethtool_ops ks8695_wan_ethtool_ops = {
-	.get_msglevel	= ks8695_get_msglevel,
-	.set_msglevel	= ks8695_set_msglevel,
-	.get_settings	= ks8695_wan_get_settings,
-	.set_settings	= ks8695_wan_set_settings,
-	.nway_reset	= ks8695_wan_nwayreset,
-	.get_link	= ethtool_op_get_link,
-	.get_pauseparam = ks8695_wan_get_pause,
-	.get_drvinfo	= ks8695_get_drvinfo,
+	.get_msglevel		= ks8695_get_msglevel,
+	.set_msglevel		= ks8695_set_msglevel,
+	.get_settings		= ks8695_wan_get_settings,
+	.set_settings		= ks8695_wan_set_settings,
+	.nway_reset		= ks8695_wan_nwayreset,
+	.get_link		= ethtool_op_get_link,
+	.get_pauseparam		= ks8695_wan_get_pause,
+	.get_drvinfo		= ks8695_get_drvinfo,
+//	.get_ethtool_stats	= ks8695_get_stats,
 };

 /* Network device interface functions */
@@ -1062,6 +1407,7 @@ static const struct ethtool_ops ks8695_w
 static int
 ks8695_set_mac(struct net_device *ndev, void *addr)
 {
+	DPRINT("%s:\n", __func__+7);
	struct ks8695_priv *ksp = netdev_priv(ndev);
	struct sockaddr *address = addr;

@@ -1089,9 +1435,20 @@ static void
 ks8695_set_multicast(struct net_device *ndev)
 {
	struct ks8695_priv *ksp = netdev_priv(ndev);
-	u32 ctrl;
+	int ctrl = ks8695_readmac(ksp, MAC_DRXC);
+
+#if defined(DEBUG)
+	{
+		char  msg[128];

-	ctrl = ks8695_readreg(ksp, KS8695_DRXC);
+		msg[0] = 0;
+		/* not time critical */
+		strcat(msg, ndev->flags & IFF_PROMISC ?  " promisc=Y"   : " promisc=N");
+		strcat(msg, ndev->flags & IFF_ALLMULTI ? " multicast=Y" : " multicast=N");
+
+		DPRINT("%s:%s\n", __func__+7, msg);
+	}
+#endif

	if (ndev->flags & IFF_PROMISC) {
		/* enable promiscuous mode */
@@ -1115,7 +1472,7 @@ ks8695_set_multicast(struct net_device *
		ks8695_init_partial_multicast(ksp, ndev);
	}

-	ks8695_writereg(ksp, KS8695_DRXC, ctrl);
+	ks8695_writemac(ksp, MAC_DRXC, ctrl);
 }

 /**
@@ -1127,6 +1484,7 @@ ks8695_set_multicast(struct net_device *
 static void
 ks8695_timeout(struct net_device *ndev)
 {
+	DPRINT("%s:\n", __func__);
	struct ks8695_priv *ksp = netdev_priv(ndev);

	netif_stop_queue(ndev);
@@ -1148,6 +1506,7 @@ ks8695_timeout(struct net_device *ndev)
	netif_start_queue(ndev);
 }

+
 /**
  *	ks8695_start_xmit - Start a packet transmission
  *	@skb: The packet to transmit
@@ -1162,16 +1521,19 @@ ks8695_start_xmit(struct sk_buff *skb, s
 {
	struct ks8695_priv *ksp = netdev_priv(ndev);
	int buff_n;
+	int status;
	dma_addr_t dmap;

	spin_lock_irq(&ksp->txq_lock);

-	if (ksp->tx_ring_used == MAX_TX_DESC) {
+	if (ksp->tx_ring_used >= NUM_TX_DESC) {
		/* Somehow we got entered when we have no room */
		spin_unlock_irq(&ksp->txq_lock);
+		DPRINT("#########################\n");
		return NETDEV_TX_BUSY;
	}

+
	buff_n = ksp->tx_ring_next_slot;

	BUG_ON(ksp->tx_buffers[buff_n].skb);
@@ -1182,10 +1544,12 @@ ks8695_start_xmit(struct sk_buff *skb, s
		spin_unlock_irq(&ksp->txq_lock);
		dev_dbg(ksp->dev, "%s: Could not map DMA memory for "\
			"transmission, trying later\n", ndev->name);
+		DPRINT("!!!!!!!!!!!!!!!!!!!!!!!!!\n");
		return NETDEV_TX_BUSY;
	}

	ksp->tx_buffers[buff_n].dma_ptr = dmap;
+
	/* Mapped okay, store the buffer pointer and length for later */
	ksp->tx_buffers[buff_n].skb = skb;
	ksp->tx_buffers[buff_n].length = skb->len;
@@ -1193,25 +1557,30 @@ ks8695_start_xmit(struct sk_buff *skb, s
	/* Fill out the TX descriptor */
	ksp->tx_ring[buff_n].data_ptr =
		cpu_to_le32(ksp->tx_buffers[buff_n].dma_ptr);
-	ksp->tx_ring[buff_n].status =
-		cpu_to_le32(TDES_IC | TDES_FS | TDES_LS |
-			    (skb->len & TDES_TBS));
+
+	status = TDES_IC | TDES_FS | TDES_LS | (skb->len & TDES_TBS);
+	if (NUM_TX_DESC-1 == buff_n)
+		status |= TDES_TER;
+
+	ksp->tx_ring[buff_n].status = cpu_to_le32(status);

	wmb();

-	/* Hand it over to the hardware */
+	/* ownership to TX DMA */
	ksp->tx_ring[buff_n].owner = cpu_to_le32(TDES_OWN);

-	if (++ksp->tx_ring_used == MAX_TX_DESC)
+	if (++ksp->tx_ring_used >= NUM_TX_DESC) {
+		DPRINT("stop_queue ............................\n");
		netif_stop_queue(ndev);
+	}

-	/* Kick the TX DMA in case it decided to go IDLE */
-	ks8695_writereg(ksp, KS8695_DTSC, 0);
+	/* Kick the TX DMA back into action */
+	ks8695_writemac(ksp, MAC_DTSC, 0);

-	/* And update the next ring slot */
-	ksp->tx_ring_next_slot = (buff_n + 1) & MAX_TX_DESC_MASK;
+	ksp->tx_ring_next_slot = next_tx(buff_n);

	spin_unlock_irq(&ksp->txq_lock);
+
	return NETDEV_TX_OK;
 }

@@ -1225,6 +1594,8 @@ ks8695_start_xmit(struct sk_buff *skb, s
 static int
 ks8695_stop(struct net_device *ndev)
 {
+	DPRINT("%s:\n", __func__+7);
+
	struct ks8695_priv *ksp = netdev_priv(ndev);

	netif_stop_queue(ndev);
@@ -1246,6 +1617,7 @@ ks8695_stop(struct net_device *ndev)
 static int
 ks8695_open(struct net_device *ndev)
 {
+	DPRINT("%s:\n", __func__+7);
	struct ks8695_priv *ksp = netdev_priv(ndev);
	int ret;

@@ -1277,10 +1649,10 @@ ks8695_open(struct net_device *ndev)
 static void
 ks8695_init_switch(struct ks8695_priv *ksp)
 {
-	u32 ctrl;
+	DPRINT("%s:\n", __func__+7);

	/* Default value for SEC0 according to datasheet */
-	ctrl = 0x40819e00;
+	int ctrl = 0x40819e00;

	/* LED0 = Speed	 LED1 = Link/Activity */
	ctrl &= ~(SEC0_LLED1S | SEC0_LLED0S);
@@ -1289,10 +1661,10 @@ ks8695_init_switch(struct ks8695_priv *k
	/* Enable Switch */
	ctrl |= SEC0_ENABLE;

-	writel(ctrl, ksp->phyiface_regs + KS8695_SEC0);
+	write_cpu(ctrl, ksp->phyiface_regs + KS8695_SEC0);

	/* Defaults for SEC1 */
-	writel(0x9400100, ksp->phyiface_regs + KS8695_SEC1);
+	write_cpu(0x9400100, ksp->phyiface_regs + KS8695_SEC1);
 }

 /**
@@ -1305,11 +1677,11 @@ ks8695_init_switch(struct ks8695_priv *k
 static void
 ks8695_init_wan_phy(struct ks8695_priv *ksp)
 {
-	u32 ctrl;
+	DPRINT("%s:\n", __func__+7);

	/* Support auto-negotiation */
-	ctrl = (WMC_WANAP | WMC_WANA100F | WMC_WANA100H |
-		WMC_WANA10F | WMC_WANA10H);
+	int ctrl = (WMC_WANAP | WMC_WANA100F | WMC_WANA100H |
+			WMC_WANA10F | WMC_WANA10H);

	/* LED0 = Activity , LED1 = Link */
	ctrl |= (WLED0S_ACTIVITY | WLED1S_LINK);
@@ -1317,10 +1689,10 @@ ks8695_init_wan_phy(struct ks8695_priv *
	/* Restart Auto-negotiation */
	ctrl |= WMC_WANR;

-	writel(ctrl, ksp->phyiface_regs + KS8695_WMC);
+	write_cpu(ctrl, ksp->phyiface_regs + KS8695_WMC);

-	writel(0, ksp->phyiface_regs + KS8695_WPPM);
-	writel(0, ksp->phyiface_regs + KS8695_PPS);
+	write_cpu(0, ksp->phyiface_regs + KS8695_WPPM);
+	write_cpu(0, ksp->phyiface_regs + KS8695_PPS);
 }

 static const struct net_device_ops ks8695_netdev_ops = {
@@ -1349,13 +1721,17 @@ static const struct net_device_ops ks869
 static int
 ks8695_probe(struct platform_device *pdev)
 {
+	DPRINT("%s:\n", __func__+7);
+
	struct ks8695_priv *ksp;
	struct net_device *ndev;
	struct resource *regs_res, *phyiface_res;
-	struct resource *rxirq_res, *txirq_res, *linkirq_res;
+	struct resource *rxirq_res, *txirq_res;
+	struct resource *linkirq_res;				/* optional */
+
	int ret = 0;
	int buff_n;
-	u32 machigh, maclow;
+	u32 mac_hi, mac_lo;

	/* Initialise a net_device */
	ndev = alloc_etherdev(sizeof(struct ks8695_priv));
@@ -1374,12 +1750,12 @@ ks8695_probe(struct platform_device *pde
	ksp->msg_enable = NETIF_MSG_LINK;

	/* Retrieve resources */
-	regs_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	phyiface_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	regs_res      = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	phyiface_res  = platform_get_resource(pdev, IORESOURCE_MEM, 1);

-	rxirq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	txirq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 1);
-	linkirq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 2);
+	rxirq_res     = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	txirq_res     = platform_get_resource(pdev, IORESOURCE_IRQ, 1);
+	linkirq_res   = platform_get_resource(pdev, IORESOURCE_IRQ, 2);

	if (!(regs_res && rxirq_res && txirq_res)) {
		dev_err(ksp->dev, "insufficient resources\n");
@@ -1430,31 +1806,65 @@ ks8695_probe(struct platform_device *pde
	}

	ksp->rx_irq = rxirq_res->start;
-	ksp->rx_irq_name = rxirq_res->name ? rxirq_res->name : "Ethernet RX";
+	ksp->rx_irq_name = rxirq_res->name;
+	ksp->rx_mask = 1 << ksp->rx_irq;
+
	ksp->tx_irq = txirq_res->start;
-	ksp->tx_irq_name = txirq_res->name ? txirq_res->name : "Ethernet TX";
-	ksp->link_irq = (linkirq_res ? linkirq_res->start : -1);
-	ksp->link_irq_name = (linkirq_res && linkirq_res->name) ?
-		linkirq_res->name : "Ethernet Link";
+	ksp->tx_irq_name = txirq_res->name;
+
+	ksp->link_irq = linkirq_res ? linkirq_res->start : -1;
+	ksp->link_irq_name = linkirq_res ? linkirq_res->name : NULL;
+
+	/* The rbu, rps, and tps irq nums are at common offsets from rx_irq
+	 * accross all 3 ports
+	 */
+	ksp->rbu_irq = ksp->rx_irq - 2;
+	ksp->rps_irq = ksp->rx_irq - 4;
+	ksp->tps_irq = ksp->rx_irq - 3;
+
+	static const char * const rbu[] = {
+		[KS8695_DTYPE_WAN]  = "WAN rx_ring overflow",
+		[KS8695_DTYPE_LAN]  = "LAN rx_ring overflow",
+		[KS8695_DTYPE_HPNA] = "HPNA rx_ring overflow",
+	};
+
+	static const char * const rps[] = {
+		[KS8695_DTYPE_WAN]  = "WAN rx_MAC stopped",
+		[KS8695_DTYPE_LAN]  = "LAN rx_MAC stopped",
+		[KS8695_DTYPE_HPNA] = "HPNA rx_MAC stopped",
+	};
+
+	static const char * const tps[] = {
+		[KS8695_DTYPE_WAN]  = "WAN tx_MAC stopped",
+		[KS8695_DTYPE_LAN]  = "LAN tx_MAC stopped",
+		[KS8695_DTYPE_HPNA] = "HPNA tx_MAC stopped",
+	};
+
+	ksp->rbu_irq_name = rbu[ks8695_port_type(ksp)];
+	ksp->rps_irq_name = rps[ks8695_port_type(ksp)];
+	ksp->tps_irq_name = tps[ks8695_port_type(ksp)];

	/* driver system setup */
	ndev->netdev_ops = &ks8695_netdev_ops;
-	ndev->watchdog_timeo	 = msecs_to_jiffies(watchdog);
+	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
+
+	DPRINT("%s: watchdog:%d\n", __func__, watchdog);

	netif_napi_add(ndev, &ksp->napi, ks8695_poll, NAPI_WEIGHT);

	/* Retrieve the default MAC addr from the chip. */
	/* The bootloader should have left it in there for us. */

-	machigh = ks8695_readreg(ksp, KS8695_MAH);
-	maclow = ks8695_readreg(ksp, KS8695_MAL);
+	mac_hi = ks8695_readmac(ksp, MAC_MAH);
+	mac_lo = ks8695_readmac(ksp, MAC_MAL);
+
+	ndev->dev_addr[0] = (u8) (mac_hi >> 8);
+	ndev->dev_addr[1] = (u8) (mac_hi >> 0);

-	ndev->dev_addr[0] = (machigh >> 8) & 0xFF;
-	ndev->dev_addr[1] = machigh & 0xFF;
-	ndev->dev_addr[2] = (maclow >> 24) & 0xFF;
-	ndev->dev_addr[3] = (maclow >> 16) & 0xFF;
-	ndev->dev_addr[4] = (maclow >> 8) & 0xFF;
-	ndev->dev_addr[5] = maclow & 0xFF;
+	ndev->dev_addr[2] = (u8) (mac_lo >> 24);
+	ndev->dev_addr[3] = (u8) (mac_lo >> 16);
+	ndev->dev_addr[4] = (u8) (mac_lo >> 8);
+	ndev->dev_addr[5] = (u8) (mac_lo >> 0);

	if (!is_valid_ether_addr(ndev->dev_addr))
		dev_warn(ksp->dev, "%s: Invalid ethernet MAC address. Please "
@@ -1487,32 +1897,31 @@ ks8695_probe(struct platform_device *pde
	memset(ksp->rx_ring, 0, RX_RING_DMA_SIZE);

	/* Build the rings */
-	for (buff_n = 0; buff_n < MAX_TX_DESC; ++buff_n) {
+	for (buff_n = 0; buff_n < NUM_TX_DESC; ++buff_n) {
		ksp->tx_ring[buff_n].next_desc =
			cpu_to_le32(ksp->tx_ring_dma +
-				    (sizeof(struct tx_ring_desc) *
-				     ((buff_n + 1) & MAX_TX_DESC_MASK)));
+				(sizeof(struct tx_ring_desc) * next_tx(buff_n)));
	}

-	for (buff_n = 0; buff_n < MAX_RX_DESC; ++buff_n) {
+	for (buff_n = 0; buff_n < NUM_RX_DESC; ++buff_n) {
		ksp->rx_ring[buff_n].next_desc =
			cpu_to_le32(ksp->rx_ring_dma +
-				    (sizeof(struct rx_ring_desc) *
-				     ((buff_n + 1) & MAX_RX_DESC_MASK)));
+				(sizeof(struct rx_ring_desc) * next_rx(buff_n)));
+
+		ksp->rx_ring[buff_n].length = cpu_to_le32(RXBUF_SIZE);
+		ksp->rx_buffers[buff_n].length = RXBUF_SIZE;
	}
+	ksp->rx_ring[NUM_RX_DESC-1].length = cpu_to_le32(RDES_RER | RXBUF_SIZE);

	/* Initialise the port (physically) */
	if (ksp->phyiface_regs && ksp->link_irq == -1) {
		ks8695_init_switch(ksp);
-		ksp->dtype = KS8695_DTYPE_LAN;
		SET_ETHTOOL_OPS(ndev, &ks8695_ethtool_ops);
	} else if (ksp->phyiface_regs && ksp->link_irq != -1) {
		ks8695_init_wan_phy(ksp);
-		ksp->dtype = KS8695_DTYPE_WAN;
		SET_ETHTOOL_OPS(ndev, &ks8695_wan_ethtool_ops);
	} else {
		/* No initialisation since HPNA does not have a PHY */
-		ksp->dtype = KS8695_DTYPE_HPNA;
		SET_ETHTOOL_OPS(ndev, &ks8695_ethtool_ops);
	}

@@ -1522,7 +1931,7 @@ ks8695_probe(struct platform_device *pde

	if (ret == 0) {
		dev_info(ksp->dev, "ks8695 ethernet (%s) MAC: %pM\n",
-			 ks8695_port_type(ksp), ndev->dev_addr);
+			 ks8695_port_name(ksp), ndev->dev_addr);
	} else {
		/* Report the failure to register the net_device */
		dev_err(ksp->dev, "ks8695net: failed to register netdev.\n");
@@ -1550,6 +1959,8 @@ failure:
 static int
 ks8695_drv_suspend(struct platform_device *pdev, pm_message_t state)
 {
+	DPRINT("%s:\n", __func__+7);
+
	struct net_device *ndev = platform_get_drvdata(pdev);
	struct ks8695_priv *ksp = netdev_priv(ndev);

@@ -1573,6 +1984,8 @@ ks8695_drv_suspend(struct platform_devic
 static int
 ks8695_drv_resume(struct platform_device *pdev)
 {
+	DPRINT("%s:\n", __func__+7);
+
	struct net_device *ndev = platform_get_drvdata(pdev);
	struct ks8695_priv *ksp = netdev_priv(ndev);

@@ -1597,6 +2010,8 @@ ks8695_drv_resume(struct platform_device
 static int
 ks8695_drv_remove(struct platform_device *pdev)
 {
+	DPRINT("%s:\n", __func__+7);
+
	struct net_device *ndev = platform_get_drvdata(pdev);
	struct ks8695_priv *ksp = netdev_priv(ndev);

@@ -1629,5 +2044,5 @@ MODULE_DESCRIPTION("Micrel KS8695 (Centa
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:" MODULENAME);

-module_param(watchdog, int, 0400);
+module_param(watchdog, int, S_IRUGO);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");

=== removed file 'drivers/net/ethernet/micrel/ks8695net.h'
--- old/drivers/net/ethernet/micrel/ks8695net.h	2014-10-21 19:15:28 +0000
+++ new/drivers/net/ethernet/micrel/ks8695net.h	1970-01-01 00:00:00 +0000
@@ -1,107 +0,0 @@
-/*
- * Micrel KS8695 (Centaur) Ethernet.
- *
- * Copyright 2008 Simtec Electronics
- *		  Daniel Silverstone <dsilvers@simtec.co.uk>
- *		  Vincent Sanders <vince@simtec.co.uk>
- */
-
-#ifndef KS8695NET_H
-#define KS8695NET_H
-
-/* Receive descriptor flags */
-#define RDES_OWN	(1 << 31)	/* Ownership */
-#define RDES_FS		(1 << 30)	/* First Descriptor */
-#define RDES_LS		(1 << 29)	/* Last Descriptor */
-#define RDES_IPE	(1 << 28)	/* IP Checksum error */
-#define RDES_TCPE	(1 << 27)	/* TCP Checksum error */
-#define RDES_UDPE	(1 << 26)	/* UDP Checksum error */
-#define RDES_ES		(1 << 25)	/* Error summary */
-#define RDES_MF		(1 << 24)	/* Multicast Frame */
-#define RDES_RE		(1 << 19)	/* MII Error reported */
-#define RDES_TL		(1 << 18)	/* Frame too Long */
-#define RDES_RF		(1 << 17)	/* Runt Frame */
-#define RDES_CE		(1 << 16)	/* CRC error */
-#define RDES_FT		(1 << 15)	/* Frame Type */
-#define RDES_FLEN	(0x7ff)		/* Frame Length */
-
-#define RDES_RER	(1 << 25)	/* Receive End of Ring */
-#define RDES_RBS	(0x7ff)		/* Receive Buffer Size */
-
-/* Transmit descriptor flags */
-
-#define TDES_OWN	(1 << 31)	/* Ownership */
-
-#define TDES_IC		(1 << 31)	/* Interrupt on Completion */
-#define TDES_FS		(1 << 30)	/* First Segment */
-#define TDES_LS		(1 << 29)	/* Last Segment */
-#define TDES_IPCKG	(1 << 28)	/* IP Checksum generate */
-#define TDES_TCPCKG	(1 << 27)	/* TCP Checksum generate */
-#define TDES_UDPCKG	(1 << 26)	/* UDP Checksum generate */
-#define TDES_TER	(1 << 25)	/* Transmit End of Ring */
-#define TDES_TBS	(0x7ff)		/* Transmit Buffer Size */
-
-/*
- * Network controller register offsets
- */
-#define KS8695_DTXC		(0x00)		/* DMA Transmit Control */
-#define KS8695_DRXC		(0x04)		/* DMA Receive Control */
-#define KS8695_DTSC		(0x08)		/* DMA Transmit Start Command */
-#define KS8695_DRSC		(0x0c)		/* DMA Receive Start Command */
-#define KS8695_TDLB		(0x10)		/* Transmit Descriptor List
-						 * Base Address
-						 */
-#define KS8695_RDLB		(0x14)		/* Receive Descriptor List
-						 * Base Address
-						 */
-#define KS8695_MAL		(0x18)		/* MAC Station Address Low */
-#define KS8695_MAH		(0x1c)		/* MAC Station Address High */
-#define KS8695_AAL_(n)		(0x80 + ((n)*8))	/* MAC Additional
-							 * Station Address
-							 * (0..15) Low
-							 */
-#define KS8695_AAH_(n)		(0x84 + ((n)*8))	/* MAC Additional
-							 * Station Address
-							 * (0..15) High
-							 */
-
-
-/* DMA Transmit Control Register */
-#define DTXC_TRST		(1    << 31)	/* Soft Reset */
-#define DTXC_TBS		(0x3f << 24)	/* Transmit Burst Size */
-#define DTXC_TUCG		(1    << 18)	/* Transmit UDP
-						 * Checksum Generate
-						 */
-#define DTXC_TTCG		(1    << 17)	/* Transmit TCP
-						 * Checksum Generate
-						 */
-#define DTXC_TICG		(1    << 16)	/* Transmit IP
-						 * Checksum Generate
-						 */
-#define DTXC_TFCE		(1    <<  9)	/* Transmit Flow
-						 * Control Enable
-						 */
-#define DTXC_TLB		(1    <<  8)	/* Loopback mode */
-#define DTXC_TEP		(1    <<  2)	/* Transmit Enable Padding */
-#define DTXC_TAC		(1    <<  1)	/* Transmit Add CRC */
-#define DTXC_TE			(1    <<  0)	/* TX Enable */
-
-/* DMA Receive Control Register */
-#define DRXC_RBS		(0x3f << 24)	/* Receive Burst Size */
-#define DRXC_RUCC		(1    << 18)	/* Receive UDP Checksum check */
-#define DRXC_RTCG		(1    << 17)	/* Receive TCP Checksum check */
-#define DRXC_RICG		(1    << 16)	/* Receive IP Checksum check */
-#define DRXC_RFCE		(1    <<  9)	/* Receive Flow Control
-						 * Enable
-						 */
-#define DRXC_RB			(1    <<  6)	/* Receive Broadcast */
-#define DRXC_RM			(1    <<  5)	/* Receive Multicast */
-#define DRXC_RU			(1    <<  4)	/* Receive Unicast */
-#define DRXC_RERR		(1    <<  3)	/* Receive Error Frame */
-#define DRXC_RA			(1    <<  2)	/* Receive All */
-#define DRXC_RE			(1    <<  0)	/* RX Enable */
-
-/* Additional Station Address High */
-#define AAH_E			(1    << 31)	/* Address Enabled */
-
-#endif /* KS8695NET_H */


--=_softplc-vm-5222-1421884289-0001-2--
