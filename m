From: Joshua Kinard <kumba@gentoo.org>
Subject: [PATCH] net: meth: Some code cleanups for meth
Date: Sat, 17 Dec 2011 20:27:42 -0500
Message-ID: <4EED418E.40501@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Linux MIPS List <linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Clean up meth.h a fair bit, including replacing the copyright header with
one more appropriate for the kernel, including the original author.  Some
minor cleanups were also done to meth.c, but more could be used down the road.

Signed-off-by: Joshua Kinard <kumba@gentoo.org>
---

 drivers/net/ethernet/sgi/meth.c |   42 ++-
 drivers/net/ethernet/sgi/meth.h |  440 ++++++++++++++++++++++++++--------------
 2 files changed, 319 insertions(+), 163 deletions(-)

--- a/drivers/net/ethernet/sgi/meth.c	2011-12-17 16:01:20.729161498 -0500
+++ b/drivers/net/ethernet/sgi/meth.c	2011-12-17 16:03:38.189160228 -0500
@@ -71,16 +71,21 @@ static int multicast_filter_limit = 32;
 struct meth_private {
 	/* in-memory copy of MAC Control register */
 	unsigned long mac_ctrl;
+
 	/* in-memory copy of DMA Control register */
 	unsigned long dma_ctrl;
+
 	/* address of PHY, used by mdio_* functions, initialized in mdio_probe */
 	unsigned long phy_addr;
+
+	/* TX stuff. */
 	tx_packet *tx_ring;
 	dma_addr_t tx_ring_dma;
 	struct sk_buff *tx_skbs[TX_RING_ENTRIES];
 	dma_addr_t tx_skb_dmas[TX_RING_ENTRIES];
 	unsigned long tx_read, tx_write, tx_count;

+	/* RX stuff. */
 	rx_packet *rx_ring[RX_RING_ENTRIES];
 	dma_addr_t rx_ring_dmas[RX_RING_ENTRIES];
 	struct sk_buff *rx_skbs[RX_RING_ENTRIES];
@@ -114,10 +119,11 @@ static inline void load_eaddr(struct net
 /*
  * Waits for BUSY status of mdio bus to clear
  */
-#define WAIT_FOR_PHY(___rval)					\
-	while ((___rval = mace->eth.phy_data) & MDIO_BUSY) {	\
-		udelay(25);					\
+#define WAIT_FOR_PHY(___rval)                               \
+	while ((___rval = mace->eth.phy_data) & MDIO_BUSY) {    \
+		udelay(25);                                         \
 	}
+
 /*read phy register, return value read */
 static unsigned long mdio_read(struct meth_private *priv, unsigned long phyreg)
 {
@@ -135,16 +141,20 @@ static int mdio_probe(struct meth_privat
 {
 	int i;
 	unsigned long p2, p3, flags;
+
 	/* check if phy is detected already */
 	if(priv->phy_addr>=0&&priv->phy_addr<32)
 		return 0;
+
 	spin_lock_irqsave(&priv->meth_lock, flags);
-	for (i=0;i<32;++i){
-		priv->phy_addr=i;
-		p2=mdio_read(priv,2);
-		p3=mdio_read(priv,3);
+
+	for (i = 0; i < 32; i++){
+		priv->phy_addr = i;
+		p2 = mdio_read(priv,2);
+		p3 = mdio_read(priv,3);
+
 #if MFE_DEBUG>=2
-		switch ((p2<<12)|(p3>>4)){
+		switch ((p2 << 12) | (p3 >> 4)) {
 		case PHY_QS6612X:
 			DPRINTK("PHY is QS6612X\n");
 			break;
@@ -159,17 +169,19 @@ static int mdio_probe(struct meth_privat
 			break;
 		}
 #endif
-		if(p2!=0xffff&&p2!=0x0000){
-			DPRINTK("PHY code: %x\n",(p2<<12)|(p3>>4));
+
+		if ((p2 != 0xffff) && (p2 != 0x0000)) {
+			DPRINTK("PHY code: %x\n",((p2 << 12) | (p3 >> 4)));
 			break;
 		}
 	}
 	spin_unlock_irqrestore(&priv->meth_lock, flags);
-	if(priv->phy_addr<32) {
+
+	if (priv->phy_addr < 32)
 		return 0;
-	}
-	DPRINTK("Oopsie! PHY is not known!\n");
-	priv->phy_addr=-1;
+
+	DPRINTK("Error: Unknown PHY chip!\n");
+	priv->phy_addr = -1;
 	return -ENODEV;
 }

@@ -276,7 +288,7 @@ int meth_reset(struct net_device *dev)
 	struct meth_private *priv = netdev_priv(dev);

 	/* Reset card */
-	mace->eth.mac_ctrl = SGI_MAC_RESET;
+	mace->eth.mac_ctrl = METH_CORE_RESET;
 	udelay(1);
 	mace->eth.mac_ctrl = 0;
 	udelay(25);
--- a/drivers/net/ethernet/sgi/meth.h	2011-12-17 16:01:30.509161408 -0500
+++ b/drivers/net/ethernet/sgi/meth.h	2011-12-17 16:02:51.279160663 -0500
@@ -1,69 +1,87 @@

 /*
- * snull.h -- definitions for the network module
+ * meth.h -- definitions for the SGI O2 Fast Ethernet device
  *
- * Copyright (C) 2001 Alessandro Rubini and Jonathan Corbet
- * Copyright (C) 2001 O'Reilly & Associates
+ * Copyright (C) 2001-2003 Ilya Volynets
+ * Copyright (C) 2011 Joshua Kinard
  *
- * The source code in this file can be freely used, adapted,
- * and redistributed in source or binary form, so long as an
- * acknowledgment appears in derived source files.  The citation
- * should list that the code comes from the book "Linux Device
- * Drivers" by Alessandro Rubini and Jonathan Corbet, published
- * by O'Reilly & Associates.   No warranty is attached;
- * we cannot take responsibility for errors or fitness for use.
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
  */
-
+
 /* version dependencies have been confined to a separate file */

 /* Tunable parameters */
 #define TX_RING_ENTRIES 64	/* 64-512?*/
+#define RX_RING_ENTRIES 16 	/* Do not change */

-#define RX_RING_ENTRIES 16 /* Do not change */
 /* Internal constants */
 #define TX_RING_BUFFER_SIZE	(TX_RING_ENTRIES*sizeof(tx_packet))
-#define RX_BUFFER_SIZE 1546 /* ethenet packet size */
-#define METH_RX_BUFF_SIZE 4096
-#define METH_RX_HEAD 34 /* status + 3 quad garbage-fill + 2 byte zero-pad */
+#define RX_BUFFER_SIZE 1546							  /* ethenet packet size */
 #define RX_BUFFER_OFFSET (sizeof(rx_status_vector)+2) /* staus vector + 2
bytes of padding */
 #define RX_BUCKET_SIZE 256
+#define METH_RX_BUFF_SIZE 4096

-/* For more detailed explanations of what each field menas,
-   see Nick's great comments to #defines below (or docs, if
-   you are lucky enough toget hold of them :)*/

-/* tx status vector is written over tx command header upon
-   dma completion. */
+/*
+ * status +
+ * 3 quad garbage-fill +
+ * 2 byte zero-pad
+ */
+#define METH_RX_HEAD 34
+

+/*
+ * For more detailed explanations of what each field menas,
+ * see Nick's great comments to #defines below (or docs, if
+ * you are lucky enough toget hold of them :)
+ */
+
+/*
+ * tx status vector is written over tx command header upon
+ * dma completion.
+ */
 typedef struct tx_status_vector {
-	u64		sent:1; /* always set to 1...*/
-	u64		pad0:34;/* always set to 0 */
-	u64		flags:9;			/*I'm too lazy to specify each one separately at the moment*/
-	u64		col_retry_cnt:4;	/*collision retry count*/
-	u64		len:16;				/*Transmit length in bytes*/
+	u64		sent:1;				/* Always set to one */
+	u64		pad0:34;			/* Always filled with zeroes */
+	u64		drp_late_coll:1;	/* Transmit dropped due to late collision */
+	u64		can_xsv_defr:1;		/* Transmit cancelled due to excessive deferral */
+	u64		drp_xs_coll:1;		/* Transmit dropped due to excess collisions */
+	u64		abrt_underrun:1;	/* Transmit aborted due to underrun */
+	u64		abrt_xsv_len:1;		/* Transmit aborted to to excessive length */
+	u64		success:1;			/* Transmit completed successfully */
+	u64		pkt_deferred:1;		/* Packet deferred on at least one TX attempt */
+	u64		crc_error:1;		/* CRC error on at least one TX attempt */
+	u64		late_coll:1;		/* Late collision on at least one TX attempt */
+	u64		col_retry_cnt:4;	/* collision retry count */
+	u64		len:16;				/* Transmit length in bytes */
 } tx_status_vector;

+
 /*
  * Each packet is 128 bytes long.
  * It consists of header, 0-3 concatination
  * buffer pointers and up to 120 data bytes.
  */
 typedef struct tx_packet_hdr {
-	u64		pad1:36; /*should be filled with 0 */
-	u64		cat_ptr3_valid:1,	/*Concatination pointer valid flags*/
-			cat_ptr2_valid:1,
-			cat_ptr1_valid:1;
-	u64		tx_int_flag:1;		/*Generate TX intrrupt when packet has been sent*/
-	u64		term_dma_flag:1;	/*Terminate transmit DMA on transmit abort conditions*/
-	u64		data_offset:7;		/*Starting byte offset in ring data block*/
-	u64		data_len:16;		/*Length of valid data in bytes-1*/
+	u64		pad1:36;			/*should be filled with 0 */
+	u64		cat_ptr3_valid:1;	/* Concatination pointer valid flags */
+	u64     cat_ptr2_valid:1;
+	u64     cat_ptr1_valid:1;
+	u64		tx_int_flag:1;		/* Generate TX intrrupt when packet has been sent */
+	u64		term_dma_flag:1;	/* Terminate transmit DMA on transmit abort
conditions */
+	u64		data_offset:7;		/* Starting byte offset in ring data block */
+	u64		data_len:16;		/* Length of valid data in bytes-1 */
 } tx_packet_hdr;
+
 typedef union tx_cat_ptr {
 	struct {
-		u64		pad2:16; /* should be 0 */
-		u64		len:16;				/*length of buffer data - 1*/
-		u64		start_addr:29;		/*Physical starting address*/
-		u64		pad1:3; /* should be zero */
+		u64		pad2:16;		/* Should be 0 */
+		u64		len:16;			/* length of buffer data - 1 */
+		u64		start_addr:29;	/* Physical starting address */
+		u64		pad1:3;			/* Should be 0 */
 	} form;
 	u64 raw;
 } tx_cat_ptr;
@@ -82,8 +100,8 @@ typedef struct tx_packet {

 typedef union rx_status_vector {
 	volatile struct {
-		u64		pad1:1;/*fill it with ones*/
-		u64		pad2:15;/*fill with 0*/
+		u64		pad1:1;					/* Fill it with ones */
+		u64		pad2:15;				/* Fill with zeros */
 		u64		ip_chk_sum:16;
 		u64		seq_num:5;
 		u64		mac_addr_match:1;
@@ -95,7 +113,7 @@ typedef union rx_status_vector {
 		u64		broadcast:1;
 		u64		multicast:1;
 		u64		crc_error:1;
-		u64		huh:1;/*???*/
+		u64		dribble:1;				/* Dribble nibble? */
 		u64		rx_code_violation:1;
 		u64		rx_len:16;
 	} parsed;
@@ -109,135 +127,261 @@ typedef struct rx_packet {
 	char
buf[METH_RX_BUFF_SIZE-sizeof(rx_status_vector)-3*sizeof(u64)-sizeof(u16)];/*
data */
 } rx_packet;

-#define TX_INFO_RPTR    0x00FF0000
-#define TX_INFO_WPTR    0x000000FF
+#define TX_INFO_RPTR    		0x00FF0000
+#define TX_INFO_WPTR    		0x000000FF
+

-	/* Bits in METH_MAC */

-#define SGI_MAC_RESET		BIT(0)	/* 0: MAC110 active in run mode, 1: Global
reset signal to MAC110 core is active */
-#define METH_PHY_FDX		BIT(1) /* 0: Disable full duplex, 1: Enable full
duplex */
-#define METH_PHY_LOOP	BIT(2) /* 0: Normal operation, follows 10/100mbit and
M10T/MII select, 1: loops internal MII bus */
-				       /*    selects ignored */
-#define METH_100MBIT		BIT(3) /* 0: 10meg mode, 1: 100meg mode */
-#define METH_PHY_MII		BIT(4) /* 0: MII selected, 1: SIA selected */
-				       /*   Note: when loopback is set this bit becomes collision
control.  Setting this bit will */
-				       /*         cause a collision to be reported. */
+/* Bits in METH_MAC */
+
+/*
+ * Core Reset:
+ *   0: MAC110 active in run mode
+ *   1: Global reset signal to MAC110 core is active
+ */
+#define METH_CORE_RESET			BIT(0)		

-				       /* Bits 5 and 6 are used to determine the Destination address
filter mode */
-#define METH_ACCEPT_MY 0			/* 00: Accept PHY address only */
-#define METH_ACCEPT_MCAST 0x20	/* 01: Accept physical, broadcast, and
multicast filter matches only */
-#define METH_ACCEPT_AMCAST 0x40	/* 10: Accept physical, broadcast, and all
multicast packets */
-#define METH_PROMISC 0x60		/* 11: Promiscious mode */
+/*
+ * Duplex:
+ *   0: Disable full duplex
+ *   1: Enable full duplex
+ */
+#define METH_PHY_FDX			BIT(1)

-#define METH_PHY_LINK_FAIL	BIT(7) /* 0: Link failure detection disabled, 1:
Hardware scans for link failure in PHY */
+/*
+ * Loopback Internal Select
+ *   0: Normal operation, follows 10/100mbit and M10T/MII select
+ *   1: loops internal MII bus, selects ignored.
+ */
+#define METH_PHY_LOOP			BIT(2)

-#define METH_MAC_IPG	0x1ffff00
+/*
+ * 10/100 Mbit Select
+ *   0: 10mb mode
+ *   1: 100mb mode
+ */
+#define METH_100MBIT			BIT(3)

-#define METH_DEFAULT_IPG ((17<<15) | (11<<22) | (21<<8))
-						/* 0x172e5c00 */ /* 23, 23, 23 */ /*0x54A9500 *//*21,21,21*/
-				       /* Bits 8 through 14 are used to determine Inter-Packet Gap
between "Back to Back" packets */
-				       /* The gap depends on the clock speed of the link, 80ns per
increment for 100baseT, 800ns  */
-				       /* per increment for 10BaseT */
+/*
+ * M10T/MII Select
+ *   0: MII selected
+ *   1: SIA selected
+ *
+ *   Note: when loopback is set this bit becomes collision
+ *   control.  Setting this bit will cause a collision to
+ *   be reported.
+ */
+#define METH_PHY_MII			BIT(4)

-				       /* Bits 15 through 21 are used to determine IPGR1 */
+/*
+ * Destination Address Filter Mode
+ *
+ * Bits 5 and 6 are written to one of the values below to
+ * set the destination address filtering.
+ */
+#define METH_ACCEPT_MY			0x00	/* 00: PHY address only */
+#define METH_ACCEPT_MCAST		0x20	/* 01: Phys, bcast, & multicast filter
matches only */
+#define METH_ACCEPT_AMCAST		0x40	/* 10: Phys, bcast, and all multicast
packets */
+#define METH_PROMISC			0x60	/* 11: Promiscious mode */

-				       /* Bits 22 through 28 are used to determine IPGR2 */
+/*
+ * Link Failure Enable
+ *   0: Link failure detection disabled
+ *   1: Hardware scans for link failure in PHY
+ */
+#define METH_PHY_LINK_FAIL		BIT(7)

-#define METH_REV_SHIFT 29       /* Bits 29 through 31 are used to determine
the revision */
-				       /* 000: Initial revision */
-				       /* 001: First revision, Improved TX concatenation */
+/*
+ * Inter-packet Gap
+ *
+ * Bits 8 through 14 are used to determine Inter-Packet Gap
+ * between "Back to Back" packets.  The gap depends on the
+ * clock speed of the link, 80ns per increment for 100baseT,
+ * 800ns per increment for 10BaseT.
+ *
+ * Bits 15 through 21 are used to determine IPGR1.
+ * Bits 22 through 28 are used to determine IPGR2.
+ *
+ */
+#define METH_MAC_IPG			0x1ffff00
+#define METH_DEFAULT_IPG		((17<<15) | (11<<22) | (21<<8))

+/*
+ * Implementation Revision (read-only)
+ *   000: Initial revision
+ *   001: First revision, Improved TX concatenation
+ *
+ * Bits 29 through 31 are used to determine the revision.
+ */
+ #define METH_REV_MASK			(BIT(29) | BIT(30) | BIT(31))

-/* DMA control bits */
-#define METH_RX_OFFSET_SHIFT 12 /* Bits 12:14 of DMA control register
indicate starting offset of packet data for RX operation */
-#define METH_RX_DEPTH_SHIFT 4 /* Bits 8:4 define RX fifo depth -- when # of
RX fifo entries != depth, interrupt is generted */

-#define METH_DMA_TX_EN BIT(1) /* enable TX DMA */
-#define METH_DMA_TX_INT_EN BIT(0) /* enable TX Buffer Empty interrupt */
-#define METH_DMA_RX_EN BIT(15) /* Enable RX */
-#define METH_DMA_RX_INT_EN BIT(9) /* Enable interrupt on RX packet */
+/* DMA control register */
+
+/*
+ * RX DMA Starting Offset
+ *
+ * Bits 12:14 of indicate starting offset of packet data
+ * for RX operation.
+ */
+#define METH_RX_OFFSET_SHIFT 	12
+
+/* RX FIFO Depth
+ *
+ * Bits 8:4 define RX fifo depth.  When the number of RX
+ * fifo entries != depth, then an interrupt is generated.
+ */
+#define METH_RX_DEPTH_SHIFT 	4
+
+/*
+ * DMA RX/TX Enable + Intr Enable
+ */
+#define METH_DMA_TX_EN			BIT(1)	/* TX DMA Enable */
+#define METH_DMA_TX_INT_EN		BIT(0)	/* TX Interrupt Enable */
+#define METH_DMA_RX_EN			BIT(15)	/* RX DMA Enable */
+#define METH_DMA_RX_INT_EN		BIT(9)	/* RX Interrupt Enable */

 /* RX FIFO MCL Info bits */
-#define METH_RX_FIFO_WPTR(x)   (((x)>>16)&0xf)
-#define METH_RX_FIFO_RPTR(x)   (((x)>>8)&0xf)
-#define METH_RX_FIFO_DEPTH(x)  ((x)&0x1f)
-
-/* RX status bits */
-
-#define METH_RX_ST_VALID BIT(63)
-#define METH_RX_ST_RCV_CODE_VIOLATION BIT(16)
-#define METH_RX_ST_DRBL_NBL BIT(17)
-#define METH_RX_ST_CRC_ERR BIT(18)
-#define METH_RX_ST_MCAST_PKT BIT(19)
-#define METH_RX_ST_BCAST_PKT BIT(20)
-#define METH_RX_ST_INV_PREAMBLE_CTX BIT(21)
-#define METH_RX_ST_LONG_EVT_SEEN BIT(22)
-#define METH_RX_ST_BAD_PACKET BIT(23)
-#define METH_RX_ST_CARRIER_EVT_SEEN BIT(24)
-#define METH_RX_ST_MCAST_FILTER_MATCH BIT(25)
-#define METH_RX_ST_PHYS_ADDR_MATCH BIT(26)
-
-#define METH_RX_STATUS_ERRORS \
-	( \
-	METH_RX_ST_RCV_CODE_VIOLATION| \
-	METH_RX_ST_CRC_ERR| \
-	METH_RX_ST_INV_PREAMBLE_CTX| \
-	METH_RX_ST_LONG_EVT_SEEN| \
-	METH_RX_ST_BAD_PACKET| \
-	METH_RX_ST_CARRIER_EVT_SEEN \
-	)
-	/* Bits in METH_INT */
-	/* Write _1_ to corresponding bit to clear */
-#define METH_INT_TX_EMPTY	BIT(0)	/* 0: No interrupt pending, 1: The TX ring
buffer is empty */
-#define METH_INT_TX_PKT		BIT(1)	/* 0: No interrupt pending */
-					      	/* 1: A TX message had the INT request bit set, the packet has
been sent. */
-#define METH_INT_TX_LINK_FAIL	BIT(2)	/* 0: No interrupt pending, 1: PHY has
reported a link failure */
-#define METH_INT_MEM_ERROR	BIT(3)	/* 0: No interrupt pending */
-						/* 1: A memory error occurred during DMA, DMA stopped, Fatal */
-#define METH_INT_TX_ABORT		BIT(4)	/* 0: No interrupt pending, 1: The TX
aborted operation, DMA stopped, FATAL */
-#define METH_INT_RX_THRESHOLD	BIT(5)	/* 0: No interrupt pending, 1:
Selected receive threshold condition Valid */
-#define METH_INT_RX_UNDERFLOW	BIT(6)	/* 0: No interrupt pending, 1: FIFO
was empty, packet could not be queued */
-#define METH_INT_RX_OVERFLOW		BIT(7)	/* 0: No interrupt pending, 1: DMA
FIFO Overflow, DMA stopped, FATAL */
-
-/*#define METH_INT_RX_RPTR_MASK 0x0001F00*/		/* Bits 8 through 12 alias of
RX read-pointer */
-#define METH_INT_RX_RPTR_MASK 0x0000F00		/* Bits 8 through 11 alias of RX
read-pointer - so, is Rx FIFO 16 or 32 entry?*/
-
-						/* Bits 13 through 15 are always 0. */
-
-#define METH_INT_TX_RPTR_MASK	0x1FF0000        /* Bits 16 through 24 alias
of TX read-pointer */
-
-#define METH_INT_RX_SEQ_MASK	0x2E000000	/* Bits 25 through 29 are the
starting seq number for the message at the */
-
-						/* top of the queue */
-
-#define METH_INT_ERROR	(METH_INT_TX_LINK_FAIL| \
-			METH_INT_MEM_ERROR| \
-			METH_INT_TX_ABORT| \
-			METH_INT_RX_OVERFLOW| \
-			METH_INT_RX_UNDERFLOW)
+#define METH_RX_FIFO_WPTR(x)	(((x) >> 16) & 0xf)
+#define METH_RX_FIFO_RPTR(x)	(((x) >> 8) & 0xf)
+#define METH_RX_FIFO_DEPTH(x)	((x) & 0x1f)
+
+
+/* RX status vector bits */
+#define METH_RX_ST_VALID				BIT(63)
+#define METH_RX_ST_RCV_CODE_VIOLATION	BIT(16)
+#define METH_RX_ST_DRBL_NBL				BIT(17)
+#define METH_RX_ST_CRC_ERR				BIT(18)
+#define METH_RX_ST_MCAST_PKT			BIT(19)
+#define METH_RX_ST_BCAST_PKT			BIT(20)
+#define METH_RX_ST_INV_PREAMBLE_CTX		BIT(21)
+#define METH_RX_ST_LONG_EVT_SEEN		BIT(22)
+#define METH_RX_ST_BAD_PACKET			BIT(23)
+#define METH_RX_ST_CARRIER_EVT_SEEN		BIT(24)
+#define METH_RX_ST_MCAST_FILTER_MATCH	BIT(25)
+#define METH_RX_ST_PHYS_ADDR_MATCH		BIT(26)
+
+#define METH_RX_STATUS_ERRORS			\
+ (METH_RX_ST_RCV_CODE_VIOLATION |		\
+  METH_RX_ST_CRC_ERR			|		\
+  METH_RX_ST_INV_PREAMBLE_CTX	|		\
+  METH_RX_ST_LONG_EVT_SEEN		|		\
+  METH_RX_ST_BAD_PACKET			|		\
+  METH_RX_ST_CARRIER_EVT_SEEN)
+

-#define METH_INT_MCAST_HASH		BIT(30) /* If RX DMA is enabled the hash
select logic output is latched here */
+/*
+ * Ethernet Interrupt Status Register
+ *
+ * Write a '1' to the corresponding bit to clear it.
+ */
+
+/*
+ * TX Ring Empty Interrupt Event
+ *   0: No interrupt pending
+ *   1: The TX ring buffer is empty
+ */
+#define METH_INT_TX_EMPTY		BIT(0)
+
+/*
+ * TX Packet User Request Interrupt Event
+ *   0: No interrupt pending
+ *   1: A TX message had the INT request bit set, the packet has been sent.
+ */
+#define METH_INT_TX_PKT			BIT(1)
+
+/*
+ * TX Link Failure Condition Detected
+ *   0: No interrupt pending
+ *   1: PHY has reported a link failure
+ */
+#define METH_INT_TX_LINK_FAIL	BIT(2)
+
+/*
+ * TX CRIME Memory Error Interrupt Event
+ *   0: No interrupt pending
+ *   1: A memory error occurred during a DMA transaction,
+ *      DMA has stopped, fatal error.
+ */
+#define METH_INT_MEM_ERROR		BIT(3)
+
+/*
+ * TX Abort Interrupt Event
+ *   0: No interrupt pending
+ *   1: The TX aborted operation, DMA has stopped, fatal error.
+ *      Examine the TX status register for the abort reason.
+ */
+#define METH_INT_TX_ABORT		BIT(4)
+
+/*
+ * RX Threshold INterrupt Event
+ *   0: No interrupt pending
+ *   1: Selected receive threshold condition is valid
+ */
+#define METH_INT_RX_THRESHOLD	BIT(5)
+
+/*
+ * RX Cluster FIFO Underflow Interrupt Event
+ *   0: No interrupt pending
+ *   1: FIFO was empty, packet could not be queued
+ */
+#define METH_INT_RX_UNDERFLOW	BIT(6)
+
+/*
+ * RX DMA FIFO Overflow Interrupt Event
+ *   0: No interrupt pending
+ *   1: DMA FIFO Overflow, DMA has stopped, fatal error
+ */
+#define METH_INT_RX_OVERFLOW	BIT(7)
+
+/* Bits 8:12 are an alias of the RX MCL FIFO Read Pointer */
+//#define METH_INT_RX_RPTR_MASK 0x0001F00
+#define METH_INT_RX_RPTR_MASK 0x0000F00
+
+/* Bits 13 through 15 are always 0. */
+
+/* Bits 16:24 are an alias of the TX Ring Buffer Read Pointer */
+#define METH_INT_TX_RPTR_MASK	0x1FF0000
+
+/* Bits 25:29 are for the RX sequence number */
+#define METH_INT_RX_SEQ_MASK	0x2E000000
+
+/* top of the queue */
+#define METH_INT_ERROR			\
+ (METH_INT_TX_LINK_FAIL	 |		\
+  METH_INT_MEM_ERROR	 |		\
+  METH_INT_TX_ABORT	 	 |		\
+  METH_INT_RX_OVERFLOW	 |		\
+  METH_INT_RX_UNDERFLOW)
+
+/*
+ * Multicast Hash Output (Debug)
+ *
+ * If RX DMA is enabled, the hash select logic output is latched here.
+ */
+#define METH_INT_MCAST_HASH		BIT(30)

 /* TX status bits */
-#define METH_TX_ST_DONE      BIT(63) /* TX complete */
-#define METH_TX_ST_SUCCESS   BIT(23) /* Packet was transmitted successfully */
-#define METH_TX_ST_TOOLONG   BIT(24) /* TX abort due to excessive length */
-#define METH_TX_ST_UNDERRUN  BIT(25) /* TX abort due to underrun (?) */
-#define METH_TX_ST_EXCCOLL   BIT(26) /* TX abort due to excess collisions */
-#define METH_TX_ST_DEFER     BIT(27) /* TX abort due to excess deferals */
-#define METH_TX_ST_LATECOLL  BIT(28) /* TX abort due to late collision */
+#define METH_TX_ST_DONE			BIT(63)		/* TX complete */
+#define METH_TX_ST_SUCCESS		BIT(23)		/* Packet was transmitted successfully */
+#define METH_TX_ST_TOOLONG		BIT(24)		/* TX abort due to excessive length */
+#define METH_TX_ST_UNDERRUN		BIT(25)		/* TX abort due to underrun (?) */
+#define METH_TX_ST_EXCCOLL		BIT(26)		/* TX abort due to excess collisions */
+#define METH_TX_ST_DEFER		BIT(27)		/* TX abort due to excess deferals */
+#define METH_TX_ST_LATECOLL		BIT(28)		/* TX abort due to late collision */


 /* Tx command header bits */
-#define METH_TX_CMD_INT_EN BIT(24) /* Generate TX interrupt when packet is
sent */
+#define METH_TX_CMD_INT_EN		BIT(24)		/* Generate TX interrupt when packet
is sent */

 /* Phy MDIO interface busy flag */
-#define MDIO_BUSY    BIT(16)
-#define MDIO_DATA_MASK 0xFFFF
+#define MDIO_BUSY				BIT(16)
+#define MDIO_DATA_MASK			0xFFFF
+
 /* PHY defines */
-#define PHY_QS6612X    0x0181441    /* Quality TX */
-#define PHY_ICS1889    0x0015F41    /* ICS FX */
-#define PHY_ICS1890    0x0015F42    /* ICS TX */
-#define PHY_DP83840    0x20005C0    /* National TX */
+#define PHY_QS6612X				0x0181441	/* Quality TX */
+#define PHY_ICS1889				0x0015F41	/* ICS FX */
+#define PHY_ICS1890				0x0015F42	/* ICS TX */
+#define PHY_DP83840				0x20005C0	/* National TX */

-#define ADVANCE_RX_PTR(x)  x=(x+1)&(RX_RING_ENTRIES-1)
+#define ADVANCE_RX_PTR(x)		(x) = ((x + 1) & (RX_RING_ENTRIES - 1))
\ No newline at end of file
