From: Olof Johansson <olof@lixom.net>
Subject: [patch 4/6] pasemi_mac: jumbo frame support
Date: Wed, 20 Feb 2008 20:57:57 -0600
Message-ID: <20080221025929.959207000@lixom.net>
References: <20080221025753.903665000@lixom.net>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:44455 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357AbYBUDPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 22:15:10 -0500
Content-Disposition: inline; filename=in-progress/pasemi_mac-jumbo-frames
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First cut at jumbo frame support. To support large MTU, one or several
separate channels must be allocated to calculate the TCP/UDP checksum
separately, since the mac lacks enough buffers to hold a whole packet
while it's being calculated.

Furthermore, it seems that a single function channel is not quite
enough to feed one of the 10Gig links, so allocate two channels for
XAUI interfaces.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: 2.6.25/drivers/net/pasemi_mac.c
===================================================================
--- 2.6.25.orig/drivers/net/pasemi_mac.c
+++ 2.6.25/drivers/net/pasemi_mac.c
@@ -59,11 +59,12 @@
 /* Must be a power of two */
 #define RX_RING_SIZE 2048
 #define TX_RING_SIZE 4096
+#define CS_RING_SIZE (TX_RING_SIZE*2)
 
 #define LRO_MAX_AGGR 64
 
 #define PE_MIN_MTU	64
-#define PE_MAX_MTU	1500
+#define PE_MAX_MTU	9000
 #define PE_DEF_MTU	ETH_DATA_LEN
 
 #define DEFAULT_MSG_ENABLE	  \
@@ -81,6 +82,7 @@
 #define RX_DESC(rx, num)	((rx)->chan.ring_virt[(num) & (RX_RING_SIZE-1)])
 #define RX_DESC_INFO(rx, num)	((rx)->ring_info[(num) & (RX_RING_SIZE-1)])
 #define RX_BUFF(rx, num)	((rx)->buffers[(num) & (RX_RING_SIZE-1)])
+#define CS_DESC(cs, num)	((cs)->chan.ring_virt[(num) & (CS_RING_SIZE-1)])
 
 #define RING_USED(ring)		(((ring)->next_to_fill - (ring)->next_to_clean) \
 				 & ((ring)->size - 1))
@@ -322,6 +324,103 @@ static int pasemi_mac_unmap_tx_skb(struc
 	return (nfrags + 3) & ~1;
 }
 
+static struct pasemi_mac_csring *pasemi_mac_setup_csring(struct pasemi_mac *mac)
+{
+	struct pasemi_mac_csring *ring;
+	u32 val;
+	unsigned int cfg;
+	int chno;
+
+	ring = pasemi_dma_alloc_chan(TXCHAN, sizeof(struct pasemi_mac_csring),
+				       offsetof(struct pasemi_mac_csring, chan));
+
+	if (!ring) {
+		dev_err(&mac->pdev->dev, "Can't allocate checksum channel\n");
+		goto out_chan;
+	}
+
+	chno = ring->chan.chno;
+
+	ring->size = CS_RING_SIZE;
+	ring->next_to_fill = 0;
+
+	/* Allocate descriptors */
+	if (pasemi_dma_alloc_ring(&ring->chan, CS_RING_SIZE))
+		goto out_ring_desc;
+
+	write_dma_reg(PAS_DMA_TXCHAN_BASEL(chno),
+		      PAS_DMA_TXCHAN_BASEL_BRBL(ring->chan.ring_dma));
+	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->chan.ring_dma >> 32);
+	val |= PAS_DMA_TXCHAN_BASEU_SIZ(CS_RING_SIZE >> 3);
+
+	write_dma_reg(PAS_DMA_TXCHAN_BASEU(chno), val);
+
+	ring->events[0] = pasemi_dma_alloc_flag();
+	ring->events[1] = pasemi_dma_alloc_flag();
+	if (ring->events[0] < 0 || ring->events[1] < 0)
+		goto out_flags;
+
+	pasemi_dma_clear_flag(ring->events[0]);
+	pasemi_dma_clear_flag(ring->events[1]);
+
+	ring->fun = pasemi_dma_alloc_fun();
+	if (ring->fun < 0)
+		goto out_fun;
+
+	cfg = PAS_DMA_TXCHAN_CFG_TY_FUNC | PAS_DMA_TXCHAN_CFG_UP |
+	      PAS_DMA_TXCHAN_CFG_TATTR(ring->fun) |
+	      PAS_DMA_TXCHAN_CFG_LPSQ | PAS_DMA_TXCHAN_CFG_LPDQ;
+
+	if (translation_enabled())
+		cfg |= PAS_DMA_TXCHAN_CFG_TRD | PAS_DMA_TXCHAN_CFG_TRR;
+
+	write_dma_reg(PAS_DMA_TXCHAN_CFG(chno), cfg);
+
+	/* enable channel */
+	pasemi_dma_start_chan(&ring->chan, PAS_DMA_TXCHAN_TCMDSTA_SZ |
+					   PAS_DMA_TXCHAN_TCMDSTA_DB |
+					   PAS_DMA_TXCHAN_TCMDSTA_DE |
+					   PAS_DMA_TXCHAN_TCMDSTA_DA);
+
+	return ring;
+
+out_fun:
+out_flags:
+	if (ring->events[0] >= 0)
+		pasemi_dma_free_flag(ring->events[0]);
+	if (ring->events[1] >= 0)
+		pasemi_dma_free_flag(ring->events[1]);
+	pasemi_dma_free_ring(&ring->chan);
+out_ring_desc:
+	pasemi_dma_free_chan(&ring->chan);
+out_chan:
+
+	return NULL;
+}
+
+static void pasemi_mac_setup_csrings(struct pasemi_mac *mac)
+{
+	int i;
+	mac->cs[0] = pasemi_mac_setup_csring(mac);
+	if (mac->type == MAC_TYPE_XAUI)
+		mac->cs[1] = pasemi_mac_setup_csring(mac);
+	else
+		mac->cs[1] = 0;
+
+	for (i = 0; i < MAX_CS; i++)
+		if (mac->cs[i])
+			mac->num_cs++;
+}
+
+static void pasemi_mac_free_csring(struct pasemi_mac_csring *csring)
+{
+	pasemi_dma_stop_chan(&csring->chan);
+	pasemi_dma_free_flag(csring->events[0]);
+	pasemi_dma_free_flag(csring->events[1]);
+	pasemi_dma_free_ring(&csring->chan);
+	pasemi_dma_free_chan(&csring->chan);
+}
+
 static int pasemi_mac_setup_rx_resources(const struct net_device *dev)
 {
 	struct pasemi_mac_rxring *ring;
@@ -445,7 +544,7 @@ pasemi_mac_setup_tx_resources(const stru
 	cfg = PAS_DMA_TXCHAN_CFG_TY_IFACE |
 	      PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
 	      PAS_DMA_TXCHAN_CFG_UP |
-	      PAS_DMA_TXCHAN_CFG_WT(2);
+	      PAS_DMA_TXCHAN_CFG_WT(4);
 
 	if (translation_enabled())
 		cfg |= PAS_DMA_TXCHAN_CFG_TRD | PAS_DMA_TXCHAN_CFG_TRR;
@@ -810,13 +909,21 @@ restart:
 		u64 mactx = TX_DESC(txring, i);
 		struct sk_buff *skb;
 
-		skb = TX_DESC_INFO(txring, i+1).skb;
-		nr_frags = TX_DESC_INFO(txring, i).dma;
-
 		if ((mactx  & XCT_MACTX_E) ||
 		    (*chan->status & PAS_STATUS_ERROR))
 			pasemi_mac_tx_error(mac, mactx);
 
+		/* Skip over control descriptors */
+		if (!(mactx & XCT_MACTX_LLEN_M)) {
+			TX_DESC(txring, i) = 0;
+			TX_DESC(txring, i+1) = 0;
+			buf_count = 2;
+			continue;
+		}
+
+		skb = TX_DESC_INFO(txring, i+1).skb;
+		nr_frags = TX_DESC_INFO(txring, i).dma;
+
 		if (unlikely(mactx & XCT_MACTX_O))
 			/* Not yet transmitted */
 			break;
@@ -1058,6 +1165,12 @@ static int pasemi_mac_open(struct net_de
 	if (!mac->tx)
 		goto out_tx_ring;
 
+	if (dev->mtu > 1500) {
+		pasemi_mac_setup_csrings(mac);
+		if (!mac->num_cs)
+			goto out_tx_ring;
+	}
+
 	/* 0x3ff with 33MHz clock is about 31us */
 	write_iob_reg(PAS_IOB_DMA_COM_TIMEOUTCFG,
 		      PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0x3ff));
@@ -1241,7 +1354,7 @@ static int pasemi_mac_close(struct net_d
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int sta;
-	int rxch, txch;
+	int rxch, txch, i;
 
 	rxch = rx_ring(mac)->chan.chno;
 	txch = tx_ring(mac)->chan.chno;
@@ -1286,6 +1399,9 @@ static int pasemi_mac_close(struct net_d
 	free_irq(mac->tx->chan.irq, mac->tx);
 	free_irq(mac->rx->chan.irq, mac->rx);
 
+	for (i = 0; i < mac->num_cs; i++)
+		pasemi_mac_free_csring(mac->cs[i]);
+
 	/* Free resources */
 	pasemi_mac_free_rx_resources(mac);
 	pasemi_mac_free_tx_resources(mac);
@@ -1293,35 +1409,113 @@ static int pasemi_mac_close(struct net_d
 	return 0;
 }
 
+static void pasemi_mac_queue_csdesc(const struct sk_buff *skb,
+				    const dma_addr_t *map,
+				    const unsigned int *map_size,
+				    struct pasemi_mac_txring *txring,
+				    struct pasemi_mac_csring *csring)
+{
+	u64 fund;
+	dma_addr_t cs_dest;
+	const int nh_off = skb_network_offset(skb);
+	const int nh_len = skb_network_header_len(skb);
+	const int nfrags = skb_shinfo(skb)->nr_frags;
+	int cs_size, i, fill, hdr, cpyhdr, evt;
+	dma_addr_t csdma;
+
+	fund = XCT_FUN_ST | XCT_FUN_RR_8BRES |
+	       XCT_FUN_O | XCT_FUN_FUN(csring->fun) |
+	       XCT_FUN_CRM_SIG | XCT_FUN_LLEN(skb->len - nh_off) |
+	       XCT_FUN_SHL(nh_len >> 2) | XCT_FUN_SE;
+
+	switch (ip_hdr(skb)->protocol) {
+	case IPPROTO_TCP:
+		fund |= XCT_FUN_SIG_TCP4;
+		/* TCP checksum is 16 bytes into the header */
+		cs_dest = map[0] + skb_transport_offset(skb) + 16;
+		break;
+	case IPPROTO_UDP:
+		fund |= XCT_FUN_SIG_UDP4;
+		/* UDP checksum is 6 bytes into the header */
+		cs_dest = map[0] + skb_transport_offset(skb) + 6;
+		break;
+	default:
+		WARN_ON(1);
+	}
+
+	/* Do the checksum offloaded */
+	fill = csring->next_to_fill;
+	hdr = fill;
+
+	CS_DESC(csring, fill++) = fund;
+	/* Room for 8BRES. Checksum result is really 2 bytes into it */
+	csdma = csring->chan.ring_dma + (fill & (CS_RING_SIZE-1)) * 8 + 2;
+	CS_DESC(csring, fill++) = 0;
+
+	CS_DESC(csring, fill) = XCT_PTR_LEN(map_size[0]-nh_off) | XCT_PTR_ADDR(map[0]+nh_off);
+	for (i = 1; i <= nfrags; i++)
+		CS_DESC(csring, fill+i) = XCT_PTR_LEN(map_size[i]) | XCT_PTR_ADDR(map[i]);
+
+	fill += i;
+	if (fill & 1)
+		fill++;
+
+	/* Copy the result into the TCP packet */
+	cpyhdr = fill;
+	CS_DESC(csring, fill++) = XCT_FUN_O | XCT_FUN_FUN(csring->fun) |
+				  XCT_FUN_LLEN(2) | XCT_FUN_SE;
+	CS_DESC(csring, fill++) = XCT_PTR_LEN(2) | XCT_PTR_ADDR(cs_dest) | XCT_PTR_T;
+	CS_DESC(csring, fill++) = XCT_PTR_LEN(2) | XCT_PTR_ADDR(csdma);
+	fill++;
+
+	evt = !csring->last_event;
+	csring->last_event = evt;
+
+	/* Event handshaking with MAC TX */
+	CS_DESC(csring, fill++) = CTRL_CMD_T | CTRL_CMD_META_EVT | CTRL_CMD_O |
+				  CTRL_CMD_ETYPE_SET | CTRL_CMD_REG(csring->events[evt]);
+	CS_DESC(csring, fill++) = 0;
+	CS_DESC(csring, fill++) = CTRL_CMD_T | CTRL_CMD_META_EVT | CTRL_CMD_O |
+				  CTRL_CMD_ETYPE_WCLR | CTRL_CMD_REG(csring->events[!evt]);
+	CS_DESC(csring, fill++) = 0;
+	csring->next_to_fill = fill & (CS_RING_SIZE-1);
+
+	cs_size = fill - hdr;
+	write_dma_reg(PAS_DMA_TXCHAN_INCR(csring->chan.chno), (cs_size) >> 1);
+
+	/* TX-side event handshaking */
+	fill = txring->next_to_fill;
+	TX_DESC(txring, fill++) = CTRL_CMD_T | CTRL_CMD_META_EVT | CTRL_CMD_O |
+				  CTRL_CMD_ETYPE_WSET | CTRL_CMD_REG(csring->events[evt]);
+	TX_DESC(txring, fill++) = 0;
+	TX_DESC(txring, fill++) = CTRL_CMD_T | CTRL_CMD_META_EVT | CTRL_CMD_O |
+				  CTRL_CMD_ETYPE_CLR | CTRL_CMD_REG(csring->events[!evt]);
+	TX_DESC(txring, fill++) = 0;
+	txring->next_to_fill = fill;
+
+	write_dma_reg(PAS_DMA_TXCHAN_INCR(txring->chan.chno), 2);
+
+	return;
+}
+
 static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct pasemi_mac *mac = netdev_priv(dev);
-	struct pasemi_mac_txring *txring;
-	u64 dflags, mactx;
+	struct pasemi_mac * const mac = netdev_priv(dev);
+	struct pasemi_mac_txring * const txring = tx_ring(mac);
+	struct pasemi_mac_csring *csring;
+	u64 dflags = 0;
+	u64 mactx;
 	dma_addr_t map[MAX_SKB_FRAGS+1];
 	unsigned int map_size[MAX_SKB_FRAGS+1];
 	unsigned long flags;
 	int i, nfrags;
 	int fill;
+	const int nh_off = skb_network_offset(skb);
+	const int nh_len = skb_network_header_len(skb);
 
-	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_CRC_PAD;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		const unsigned char *nh = skb_network_header(skb);
+	prefetch(&txring->ring_info);
 
-		switch (ip_hdr(skb)->protocol) {
-		case IPPROTO_TCP:
-			dflags |= XCT_MACTX_CSUM_TCP;
-			dflags |= XCT_MACTX_IPH(skb_network_header_len(skb) >> 2);
-			dflags |= XCT_MACTX_IPO(nh - skb->data);
-			break;
-		case IPPROTO_UDP:
-			dflags |= XCT_MACTX_CSUM_UDP;
-			dflags |= XCT_MACTX_IPH(skb_network_header_len(skb) >> 2);
-			dflags |= XCT_MACTX_IPO(nh - skb->data);
-			break;
-		}
-	}
+	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_CRC_PAD;
 
 	nfrags = skb_shinfo(skb)->nr_frags;
 
@@ -1344,24 +1538,46 @@ static int pasemi_mac_start_tx(struct sk
 		}
 	}
 
-	mactx = dflags | XCT_MACTX_LLEN(skb->len);
+	if (skb->ip_summed == CHECKSUM_PARTIAL && skb->len <= 1540) {
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_TCP:
+			dflags |= XCT_MACTX_CSUM_TCP;
+			dflags |= XCT_MACTX_IPH(nh_len >> 2);
+			dflags |= XCT_MACTX_IPO(nh_off);
+			break;
+		case IPPROTO_UDP:
+			dflags |= XCT_MACTX_CSUM_UDP;
+			dflags |= XCT_MACTX_IPH(nh_len >> 2);
+			dflags |= XCT_MACTX_IPO(nh_off);
+			break;
+		default:
+			WARN_ON(1);
+		}
+	}
 
-	txring = tx_ring(mac);
+	mactx = dflags | XCT_MACTX_LLEN(skb->len);
 
 	spin_lock_irqsave(&txring->lock, flags);
 
-	fill = txring->next_to_fill;
-
 	/* Avoid stepping on the same cache line that the DMA controller
 	 * is currently about to send, so leave at least 8 words available.
 	 * Total free space needed is mactx + fragments + 8
 	 */
-	if (RING_AVAIL(txring) < nfrags + 10) {
+	if (RING_AVAIL(txring) < nfrags + 14) {
 		/* no room -- stop the queue and wait for tx intr */
 		netif_stop_queue(dev);
 		goto out_err;
 	}
 
+	if (mac->num_cs && skb->len > 1540) {
+		csring = mac->cs[mac->last_cs];
+		mac->last_cs = (mac->last_cs+1) % mac->num_cs;
+
+		/* Queue up checksum + event descriptors, if needed */
+		pasemi_mac_queue_csdesc(skb, map, map_size, txring, csring);
+	}
+
+	fill = txring->next_to_fill;
 	TX_DESC(txring, fill) = mactx;
 	TX_DESC_INFO(txring, fill).dma = nfrags;
 	fill++;
@@ -1441,6 +1657,7 @@ static int pasemi_mac_change_mtu(struct 
 	unsigned int reg;
 	unsigned int rcmdsta;
 	int running;
+	int ret = 0;
 
 	if (new_mtu < PE_MIN_MTU || new_mtu > PE_MAX_MTU)
 		return -EINVAL;
@@ -1462,6 +1679,16 @@ static int pasemi_mac_change_mtu(struct 
 		pasemi_mac_pause_rxint(mac);
 		pasemi_mac_clean_rx(rx_ring(mac), RX_RING_SIZE);
 		pasemi_mac_free_rx_buffers(mac);
+
+	}
+
+	/* Setup checksum channels if large MTU and none already allocated */
+	if (new_mtu > 1500 && !mac->num_cs) {
+		pasemi_mac_setup_csrings(mac);
+		if (!mac->num_cs) {
+			ret = -ENOMEM;
+			goto out;
+		}
 	}
 
 	/* Change maxf, i.e. what size frames are accepted.
@@ -1476,6 +1703,7 @@ static int pasemi_mac_change_mtu(struct 
 	/* MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 	mac->bufsz = new_mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
 
+out:
 	if (running) {
 		write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
 			      rcmdsta | PAS_DMA_RXINT_RCMDSTA_EN);
@@ -1488,7 +1716,7 @@ static int pasemi_mac_change_mtu(struct 
 		pasemi_mac_intf_enable(mac);
 	}
 
-	return 0;
+	return ret;
 }
 
 static int __devinit
Index: 2.6.25/drivers/net/pasemi_mac.h
===================================================================
--- 2.6.25.orig/drivers/net/pasemi_mac.h
+++ 2.6.25/drivers/net/pasemi_mac.h
@@ -27,6 +27,7 @@
 #include <linux/phy.h>
 
 #define MAX_LRO_DESCRIPTORS 8
+#define MAX_CS	2
 
 struct pasemi_mac_txring {
 	struct pasemi_dmachan chan; /* Must be first */
@@ -51,6 +52,15 @@ struct pasemi_mac_rxring {
 	struct pasemi_mac *mac;	/* Needed in intr handler */
 };
 
+struct pasemi_mac_csring {
+	struct pasemi_dmachan chan;
+	unsigned int	size;
+	unsigned int	next_to_fill;
+	int		events[2];
+	int		last_event;
+	int		fun;
+};
+
 struct pasemi_mac {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
@@ -60,10 +70,12 @@ struct pasemi_mac {
 	struct napi_struct napi;
 
 	int		bufsz; /* RX ring buffer size */
+	int		last_cs;
+	int		num_cs;
+	u32		dma_if;
 	u8		type;
 #define MAC_TYPE_GMAC	1
 #define MAC_TYPE_XAUI	2
-	u32	dma_if;
 
 	u8		mac_addr[6];
 
@@ -74,6 +86,7 @@ struct pasemi_mac {
 
 	struct pasemi_mac_txring *tx;
 	struct pasemi_mac_rxring *rx;
+	struct pasemi_mac_csring *cs[MAX_CS];
 	char		tx_irq_name[10];		/* "eth%d tx" */
 	char		rx_irq_name[10];		/* "eth%d rx" */
 	int	link;
Index: 2.6.25/include/asm-powerpc/pasemi_dma.h
===================================================================
--- 2.6.25.orig/include/asm-powerpc/pasemi_dma.h
+++ 2.6.25/include/asm-powerpc/pasemi_dma.h
@@ -128,11 +128,16 @@ enum {
 #define    PAS_DMA_TXCHAN_TCMDSTA_DA	0x00000100
 #define PAS_DMA_TXCHAN_CFG(c)     (0x304+(c)*_PAS_DMA_TXCHAN_STRIDE)
 #define    PAS_DMA_TXCHAN_CFG_TY_IFACE	0x00000000	/* Type = interface */
+#define    PAS_DMA_TXCHAN_CFG_TY_COPY	0x00000001	/* Type = copy only */
+#define    PAS_DMA_TXCHAN_CFG_TY_FUNC	0x00000002	/* Type = function */
+#define    PAS_DMA_TXCHAN_CFG_TY_XOR	0x00000003	/* Type = xor only */
 #define    PAS_DMA_TXCHAN_CFG_TATTR_M	0x0000003c
 #define    PAS_DMA_TXCHAN_CFG_TATTR_S	2
 #define    PAS_DMA_TXCHAN_CFG_TATTR(x)	(((x) << PAS_DMA_TXCHAN_CFG_TATTR_S) & \
 					 PAS_DMA_TXCHAN_CFG_TATTR_M)
-#define    PAS_DMA_TXCHAN_CFG_WT_M	0x000001c0
+#define    PAS_DMA_TXCHAN_CFG_LPDQ	0x00000800
+#define    PAS_DMA_TXCHAN_CFG_LPSQ	0x00000400
+#define    PAS_DMA_TXCHAN_CFG_WT_M	0x000003c0
 #define    PAS_DMA_TXCHAN_CFG_WT_S	6
 #define    PAS_DMA_TXCHAN_CFG_WT(x)	(((x) << PAS_DMA_TXCHAN_CFG_WT_S) & \
 					 PAS_DMA_TXCHAN_CFG_WT_M)
@@ -399,11 +404,62 @@ enum {
 				 XCT_COPY_LLEN_M)
 #define XCT_COPY_SE		0x0000000000000001ull
 
+/* Function descriptor fields */
+#define XCT_FUN_T		0x8000000000000000ull
+#define XCT_FUN_ST		0x4000000000000000ull
+#define XCT_FUN_RR_M		0x3000000000000000ull
+#define XCT_FUN_RR_NORES	0x0000000000000000ull
+#define XCT_FUN_RR_8BRES	0x1000000000000000ull
+#define XCT_FUN_RR_24BRES	0x2000000000000000ull
+#define XCT_FUN_RR_40BRES	0x3000000000000000ull
+#define XCT_FUN_I		0x0800000000000000ull
+#define XCT_FUN_O		0x0400000000000000ull
+#define XCT_FUN_E		0x0200000000000000ull
+#define XCT_FUN_FUN_M		0x01c0000000000000ull
+#define XCT_FUN_FUN_S		54
+#define XCT_FUN_FUN(x)		((((long)(x)) << XCT_FUN_FUN_S) & XCT_FUN_FUN_M)
+#define XCT_FUN_CRM_M		0x0038000000000000ull
+#define XCT_FUN_CRM_NOP		0x0000000000000000ull
+#define XCT_FUN_CRM_SIG		0x0008000000000000ull
+#define XCT_FUN_LLEN_M		0x0007ffff00000000ull
+#define XCT_FUN_LLEN_S		32
+#define XCT_FUN_LLEN(x)		((((long)(x)) << XCT_FUN_LLEN_S) & XCT_FUN_LLEN_M)
+#define XCT_FUN_SHL_M		0x00000000f8000000ull
+#define XCT_FUN_SHL_S		27
+#define XCT_FUN_SHL(x)		((((long)(x)) << XCT_FUN_SHL_S) & XCT_FUN_SHL_M)
+#define XCT_FUN_CHL_M		0x0000000007c00000ull
+#define XCT_FUN_HSZ_M		0x00000000003c0000ull
+#define XCT_FUN_ALG_M		0x0000000000038000ull
+#define XCT_FUN_HP		0x0000000000004000ull
+#define XCT_FUN_BCM_M		0x0000000000003800ull
+#define XCT_FUN_BCP_M		0x0000000000000600ull
+#define XCT_FUN_SIG_M		0x00000000000001f0ull
+#define XCT_FUN_SIG_TCP4	0x0000000000000140ull
+#define XCT_FUN_SIG_TCP6	0x0000000000000150ull
+#define XCT_FUN_SIG_UDP4	0x0000000000000160ull
+#define XCT_FUN_SIG_UDP6	0x0000000000000170ull
+#define XCT_FUN_A		0x0000000000000008ull
+#define XCT_FUN_C		0x0000000000000004ull
+#define XCT_FUN_AL2		0x0000000000000002ull
+#define XCT_FUN_SE		0x0000000000000001ull
+
+/* Function descriptor 8byte result fields */
+#define XCT_FUNRES_8B_CS_M	0x0000ffff00000000ull
+#define XCT_FUNRES_8B_CS_S	32
+#define XCT_FUNRES_8B_CRC_M	0x00000000ffffffffull
+#define XCT_FUNRES_8B_CRC_S	0
+
 /* Control descriptor fields */
 #define CTRL_CMD_T		0x8000000000000000ull
 #define CTRL_CMD_META_EVT	0x2000000000000000ull
 #define CTRL_CMD_O		0x0400000000000000ull
-#define CTRL_CMD_REG_M		0x000000000000000full
+#define CTRL_CMD_ETYPE_M	0x0038000000000000ull
+#define CTRL_CMD_ETYPE_EXT	0x0000000000000000ull
+#define CTRL_CMD_ETYPE_WSET	0x0020000000000000ull
+#define CTRL_CMD_ETYPE_WCLR	0x0028000000000000ull
+#define CTRL_CMD_ETYPE_SET	0x0030000000000000ull
+#define CTRL_CMD_ETYPE_CLR	0x0038000000000000ull
+#define CTRL_CMD_REG_M		0x000000000000007full
 #define CTRL_CMD_REG_S		0
 #define CTRL_CMD_REG(x)		((((long)(x)) << CTRL_CMD_REG_S) & \
 				 CTRL_CMD_REG_M)

-- 

