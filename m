From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/7] sky2: Yukon Extreme (88e8071) support.
Date: Mon, 04 Jun 2007 17:23:26 -0700
Message-ID: <20070605002739.044311464@linux-foundation.org>
References: <20070605002320.868185090@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60331 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759317AbXFEAnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:43:22 -0400
Content-Disposition: inline; filename=sky2-ex-support.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable support for Yukon EX chipset (88e8071).
Most of changes are related to new commands to chip for transmit,
and change in status and checksumming.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |  176 +++++++++++++++++++++++++++++++----------------------
 drivers/net/sky2.h |   43 ++++++++++++
 2 files changed, 148 insertions(+), 71 deletions(-)

--- a/drivers/net/sky2.c	2007-06-04 08:46:47.000000000 -0700
+++ b/drivers/net/sky2.c	2007-06-04 08:46:54.000000000 -0700
@@ -130,7 +130,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) }, /* 88EC042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
-//	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
 	{ 0 }
 };
 
@@ -661,6 +661,30 @@ static void sky2_wol_init(struct sky2_po
 
 }
 
+static void sky2_set_tx_stfwd(struct sky2_hw *hw, unsigned port)
+{
+	if (hw->chip_id == CHIP_ID_YUKON_EX && hw->chip_rev != CHIP_REV_YU_EX_A0) {
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_STFW_ENA |
+			     (hw->dev[port]->mtu > ETH_DATA_LEN) ? TX_JUMBO_ENA : TX_JUMBO_DIS);
+	} else {
+		if (hw->dev[port]->mtu > ETH_DATA_LEN) {
+			/* set Tx GMAC FIFO Almost Empty Threshold */
+			sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
+				     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
+
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_ENA | TX_STFW_DIS);
+
+			/* Can't do offload because of lack of store/forward */
+			hw->dev[port]->features &= ~(NETIF_F_TSO | NETIF_F_SG
+						     | NETIF_F_ALL_CSUM);
+		} else
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     TX_JUMBO_DIS | TX_STFW_ENA);
+	}
+}
+
 static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 {
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
@@ -741,8 +765,11 @@ static void sky2_mac_init(struct sky2_hw
 
 	/* Configure Rx MAC FIFO */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_CLR);
-	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
-		     GMF_OPER_ON | GMF_RX_F_FL_ON);
+	reg = GMF_OPER_ON | GMF_RX_F_FL_ON;
+	if (hw->chip_id == CHIP_ID_YUKON_EX)
+		reg |= GMF_RX_OVER_ON;
+
+	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), reg);
 
 	/* Flush Rx MAC FIFO on any flow control or error */
 	sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
@@ -758,16 +785,7 @@ static void sky2_mac_init(struct sky2_hw
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 
-		/* set Tx GMAC FIFO Almost Empty Threshold */
-		sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
-			     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
-
-		if (hw->dev[port]->mtu > ETH_DATA_LEN)
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_ENA | TX_STFW_DIS);
-		else
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_DIS | TX_STFW_ENA);
+		sky2_set_tx_stfwd(hw, port);
 	}
 
 }
@@ -950,14 +968,16 @@ static void rx_set_checksum(struct sky2_
 {
 	struct sky2_rx_le *le;
 
-	le = sky2_next_rx(sky2);
-	le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
-	le->ctrl = 0;
-	le->opcode = OP_TCPSTART | HW_OWNER;
-
-	sky2_write32(sky2->hw,
-		     Q_ADDR(rxqaddr[sky2->port], Q_CSR),
-		     sky2->rx_csum ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
+	if (sky2->hw->chip_id != CHIP_ID_YUKON_EX) {
+		le = sky2_next_rx(sky2);
+		le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
+		le->ctrl = 0;
+		le->opcode = OP_TCPSTART | HW_OWNER;
+
+		sky2_write32(sky2->hw,
+			     Q_ADDR(rxqaddr[sky2->port], Q_CSR),
+			     sky2->rx_csum ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
+	}
 
 }
 
@@ -1296,6 +1316,10 @@ static int sky2_up(struct net_device *de
 
 	sky2_qset(hw, txqaddr[port]);
 
+	/* This is copied from sk98lin 10.0.5.3; no one tells me about erratta's */
+	if (hw->chip_id == CHIP_ID_YUKON_EX && hw->chip_rev == CHIP_REV_YU_EX_B0)
+		sky2_write32(hw, Q_ADDR(txqaddr[port], Q_TEST), F_TX_CHK_AUTO_OFF);
+
 	/* Set almost empty threshold */
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U
 	    && hw->chip_rev == CHIP_REV_YU_EC_U_A0)
@@ -1404,14 +1428,16 @@ static int sky2_xmit_frame(struct sk_buf
 	/* Check for TCP Segmentation Offload */
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss != 0) {
-		mss += tcp_optlen(skb); /* TCP options */
-		mss += ip_hdrlen(skb) + sizeof(struct tcphdr);
-		mss += ETH_HLEN;
+		if (hw->chip_id != CHIP_ID_YUKON_EX)
+			mss += ETH_HLEN + ip_hdrlen(skb) + tcp_hdrlen(skb);
 
-		if (mss != sky2->tx_last_mss) {
-			le = get_tx_le(sky2);
-			le->addr = cpu_to_le32(mss);
-			le->opcode = OP_LRGLEN | HW_OWNER;
+  		if (mss != sky2->tx_last_mss) {
+  			le = get_tx_le(sky2);
+  			le->addr = cpu_to_le32(mss);
+ 			if (hw->chip_id == CHIP_ID_YUKON_EX)
+				le->opcode = OP_MSS | HW_OWNER;
+			else
+				le->opcode = OP_LRGLEN | HW_OWNER;
 			sky2->tx_last_mss = mss;
 		}
 	}
@@ -1433,24 +1459,30 @@ static int sky2_xmit_frame(struct sk_buf
 
 	/* Handle TCP checksum offload */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		const unsigned offset = skb_transport_offset(skb);
-		u32 tcpsum;
-
-		tcpsum = offset << 16;		/* sum start */
-		tcpsum |= offset + skb->csum_offset;	/* sum write */
-
-		ctrl |= CALSUM | WR_SUM | INIT_SUM | LOCK_SUM;
-		if (ip_hdr(skb)->protocol == IPPROTO_UDP)
-			ctrl |= UDPTCP;
-
-		if (tcpsum != sky2->tx_tcpsum) {
-			sky2->tx_tcpsum = tcpsum;
-
-			le = get_tx_le(sky2);
-			le->addr = cpu_to_le32(tcpsum);
-			le->length = 0;	/* initial checksum value */
-			le->ctrl = 1;	/* one packet */
-			le->opcode = OP_TCPLISW | HW_OWNER;
+		/* On Yukon EX (some versions) encoding change. */
+ 		if (hw->chip_id == CHIP_ID_YUKON_EX
+		    && hw->chip_rev != CHIP_REV_YU_EX_B0)
+ 			ctrl |= CALSUM;	/* auto checksum */
+		else {
+			const unsigned offset = skb_transport_offset(skb);
+			u32 tcpsum;
+
+			tcpsum = offset << 16;			/* sum start */
+			tcpsum |= offset + skb->csum_offset;	/* sum write */
+
+			ctrl |= CALSUM | WR_SUM | INIT_SUM | LOCK_SUM;
+			if (ip_hdr(skb)->protocol == IPPROTO_UDP)
+				ctrl |= UDPTCP;
+
+			if (tcpsum != sky2->tx_tcpsum) {
+				sky2->tx_tcpsum = tcpsum;
+
+				le = get_tx_le(sky2);
+				le->addr = cpu_to_le32(tcpsum);
+				le->length = 0;	/* initial checksum value */
+				le->ctrl = 1;	/* one packet */
+				le->opcode = OP_TCPLISW | HW_OWNER;
+			}
 		}
 	}
 
@@ -1924,15 +1956,8 @@ static int sky2_change_mtu(struct net_de
 
 	synchronize_irq(hw->pdev->irq);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
-		if (new_mtu > ETH_DATA_LEN) {
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_ENA | TX_STFW_DIS);
-			dev->features &= NETIF_F_TSO | NETIF_F_SG | NETIF_F_IP_CSUM;
-		} else
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_DIS | TX_STFW_ENA);
-	}
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX)
+		sky2_set_tx_stfwd(hw, port);
 
 	ctl = gma_read16(hw, port, GM_GP_CTRL);
 	gma_write16(hw, port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
@@ -2129,6 +2154,7 @@ static int sky2_status_intr(struct sky2_
 
 	while (hw->st_idx != hwidx) {
 		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
+		unsigned port = le->css & CSS_LINK_BIT;
 		struct net_device *dev;
 		struct sk_buff *skb;
 		u32 status;
@@ -2136,9 +2162,7 @@ static int sky2_status_intr(struct sky2_
 
 		hw->st_idx = RING_NEXT(hw->st_idx, STATUS_RING_SIZE);
 
-		BUG_ON(le->link >= 2);
-		dev = hw->dev[le->link];
-
+		dev = hw->dev[port];
 		sky2 = netdev_priv(dev);
 		length = le16_to_cpu(le->length);
 		status = le32_to_cpu(le->status);
@@ -2151,6 +2175,16 @@ static int sky2_status_intr(struct sky2_
 				goto force_update;
 			}
 
+			/* This chip reports checksum status differently */
+			if (hw->chip_id == CHIP_ID_YUKON_EX) {
+				if (sky2->rx_csum &&
+				    (le->css & (CSS_ISIPV4 | CSS_ISIPV6)) &&
+				    (le->css & CSS_TCPUDPCSOK))
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+				else
+					skb->ip_summed = CHECKSUM_NONE;
+			}
+
 			skb->protocol = eth_type_trans(skb, dev);
 			sky2->net_stats.rx_packets++;
 			sky2->net_stats.rx_bytes += skb->len;
@@ -2166,10 +2200,10 @@ static int sky2_status_intr(struct sky2_
 				netif_receive_skb(skb);
 
 			/* Update receiver after 16 frames */
-			if (++buf_write[le->link] == RX_BUF_WRITE) {
+			if (++buf_write[port] == RX_BUF_WRITE) {
 force_update:
-				sky2_put_idx(hw, rxqaddr[le->link], sky2->rx_put);
-				buf_write[le->link] = 0;
+				sky2_put_idx(hw, rxqaddr[port], sky2->rx_put);
+				buf_write[port] = 0;
 			}
 
 			/* Stop after net poll weight */
@@ -2190,6 +2224,9 @@ force_update:
 			if (!sky2->rx_csum)
 				break;
 
+			if (hw->chip_id == CHIP_ID_YUKON_EX)
+				break;
+
 			/* Both checksum counters are programmed to start at
 			 * the same offset, so unless there is a problem they
 			 * should match. This failure is an early indication that
@@ -2205,7 +2242,7 @@ force_update:
 				       dev->name, status);
 				sky2->rx_csum = 0;
 				sky2_write32(sky2->hw,
-					     Q_ADDR(rxqaddr[le->link], Q_CSR),
+					     Q_ADDR(rxqaddr[port], Q_CSR),
 					     BMU_DIS_RX_CHKSUM);
 			}
 			break;
@@ -2536,10 +2573,6 @@ static int __devinit sky2_init(struct sk
 		return -EOPNOTSUPP;
 	}
 
-	if (hw->chip_id == CHIP_ID_YUKON_EX)
-		dev_warn(&hw->pdev->dev, "this driver not yet tested on this chip type\n"
-			 "Please report success or failure to <netdev@vger.kernel.org>\n");
-
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
 	/* This rev is really old, and requires untested workarounds */
@@ -2599,6 +2632,11 @@ static void sky2_reset(struct sky2_hw *h
 	for (i = 0; i < hw->ports; i++) {
 		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_SET);
 		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_CLR);
+
+		if (hw->chip_id == CHIP_ID_YUKON_EX)
+			sky2_write16(hw, SK_REG(i, GMAC_CTRL),
+				     GMC_BYP_MACSECRX_ON | GMC_BYP_MACSECTX_ON
+				     | GMC_BYP_RETR_ON);
 	}
 
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
@@ -2745,7 +2783,7 @@ static int sky2_set_wol(struct net_devic
 
 	sky2->wol = wol->wolopts;
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U)
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX)
 		sky2_write32(hw, B0_CTST, sky2->wol
 			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
 
@@ -3371,9 +3409,7 @@ static int no_tx_offload(struct net_devi
 	const struct sky2_port *sky2 = netdev_priv(dev);
 	const struct sky2_hw *hw = sky2->hw;
 
-	return dev->mtu > ETH_DATA_LEN &&
-		(hw->chip_id == CHIP_ID_YUKON_EX
-		 || hw->chip_id == CHIP_ID_YUKON_EC_U);
+	return dev->mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_EC_U;
 }
 
 static int sky2_set_tx_csum(struct net_device *dev, u32 data)
--- a/drivers/net/sky2.h	2007-06-04 08:46:47.000000000 -0700
+++ b/drivers/net/sky2.h	2007-06-04 08:46:54.000000000 -0700
@@ -483,6 +483,11 @@ enum {
 	CHIP_REV_YU_FE_A2    = 2,
 
 };
+enum yukon_ex_rev {
+	CHIP_REV_YU_EX_A0    = 1,
+	CHIP_REV_YU_EX_B0    = 2,
+};
+
 
 /*	B2_Y2_CLK_GATE	 8 bit	Clock Gating (Yukon-2 only) */
 enum {
@@ -1692,6 +1697,16 @@ enum {
 	RX_VLAN_STRIP_ON = 1<<25,	/* enable  VLAN stripping */
 	RX_VLAN_STRIP_OFF = 1<<24,	/* disable VLAN stripping */
 
+	RX_MACSEC_FLUSH_ON  = 1<<23,
+	RX_MACSEC_FLUSH_OFF = 1<<22,
+	RX_MACSEC_ASF_FLUSH_ON = 1<<21,
+	RX_MACSEC_ASF_FLUSH_OFF = 1<<20,
+
+	GMF_RX_OVER_ON      = 1<<19,	/* enable flushing on receive overrun */
+	GMF_RX_OVER_OFF     = 1<<18,	/* disable flushing on receive overrun */
+	GMF_ASF_RX_OVER_ON  = 1<<17,	/* enable flushing of ASF when overrun */
+	GMF_ASF_RX_OVER_OFF = 1<<16,	/* disable flushing of ASF when overrun */
+
 	GMF_WP_TST_ON	= 1<<14,	/* Write Pointer Test On */
 	GMF_WP_TST_OFF	= 1<<13,	/* Write Pointer Test Off */
 	GMF_WP_STEP	= 1<<12,	/* Write Pointer Step/Increment */
@@ -1804,6 +1819,15 @@ enum {
 
 /*	GMAC_CTRL		32 bit	GMAC Control Reg (YUKON only) */
 enum {
+	GMC_SET_RST	    = 1<<15,/* MAC SEC RST */
+	GMC_SEC_RST_OFF     = 1<<14,/* MAC SEC RSt OFF */
+	GMC_BYP_MACSECRX_ON = 1<<13,/* Bypass macsec RX */
+	GMC_BYP_MACSECRX_OFF= 1<<12,/* Bypass macsec RX off */
+	GMC_BYP_MACSECTX_ON = 1<<11,/* Bypass macsec TX */
+	GMC_BYP_MACSECTX_OFF= 1<<10,/* Bypass macsec TX  off*/
+	GMC_BYP_RETR_ON	= 1<<9, /* Bypass retransmit FIFO On */
+	GMC_BYP_RETR_OFF= 1<<8, /* Bypass retransmit FIFO Off */
+
 	GMC_H_BURST_ON	= 1<<7,	/* Half Duplex Burst Mode On */
 	GMC_H_BURST_OFF	= 1<<6,	/* Half Duplex Burst Mode Off */
 	GMC_F_LOOPB_ON	= 1<<5,	/* FIFO Loopback On */
@@ -1889,9 +1913,13 @@ enum {
 	OP_ADDR64VLAN	= OP_ADDR64 | OP_VLAN,
 	OP_LRGLEN	= 0x24,
 	OP_LRGLENVLAN	= OP_LRGLEN | OP_VLAN,
+	OP_MSS		= 0x28,
+	OP_MSSVLAN	= OP_MSS | OP_VLAN,
+
 	OP_BUFFER	= 0x40,
 	OP_PACKET	= 0x41,
 	OP_LARGESEND	= 0x43,
+	OP_LSOV2	= 0x45,
 
 /* YUKON-2 STATUS opcodes defines */
 	OP_RXSTAT	= 0x60,
@@ -1902,6 +1930,19 @@ enum {
 	OP_RXTIMEVLAN	= OP_RXTIMESTAMP | OP_RXVLAN,
 	OP_RSS_HASH	= 0x65,
 	OP_TXINDEXLE	= 0x68,
+	OP_MACSEC	= 0x6c,
+	OP_PUTIDX	= 0x70,
+};
+
+enum status_css {
+	CSS_TCPUDPCSOK	= 1<<7,	/* TCP / UDP checksum is ok */
+	CSS_ISUDP	= 1<<6, /* packet is a UDP packet */
+	CSS_ISTCP	= 1<<5, /* packet is a TCP packet */
+	CSS_ISIPFRAG	= 1<<4, /* packet is a TCP/UDP frag, CS calc not done */
+	CSS_ISIPV6	= 1<<3, /* packet is a IPv6 packet */
+	CSS_IPV4CSUMOK	= 1<<2, /* IP v4: TCP header checksum is ok */
+	CSS_ISIPV4	= 1<<1, /* packet is a IPv4 packet */
+	CSS_LINK_BIT	= 1<<0, /* port number (legacy) */
 };
 
 /* Yukon 2 hardware interface */
@@ -1922,7 +1963,7 @@ struct sky2_rx_le {
 struct sky2_status_le {
 	__le32	status;	/* also checksum */
 	__le16	length;	/* also vlan tag */
-	u8	link;
+	u8	css;
 	u8	opcode;
 } __attribute((packed));
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

