From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] sky2: ethtool register reserved area blackout
Date: Thu, 11 Oct 2007 18:19:53 -0700
Message-ID: <20071012012125.079644427@linux-foundation.org>
References: <20071012011951.575936605@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48809 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753699AbXJLBW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:22:27 -0400
Content-Disposition: inline; filename=sky2-ethdump.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure and not dump reserved areas of device space.
Touching some of these causes machine check exceptions on boards
like D-Link DGE-550SX. 

Coding note, used a complex switch statement rather than bitmap
because it is easier to relate the block values to the documentation
rather than looking at a encoded bitmask.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-10-11 18:12:50.000000000 -0700
+++ b/drivers/net/sky2.c	2007-10-11 18:12:56.000000000 -0700
@@ -3569,20 +3569,64 @@ static void sky2_get_regs(struct net_dev
 {
 	const struct sky2_port *sky2 = netdev_priv(dev);
 	const void __iomem *io = sky2->hw->regs;
+	unsigned int b;
 
 	regs->version = 1;
-	memset(p, 0, regs->len);
 
-	memcpy_fromio(p, io, B3_RAM_ADDR);
-
-	/* skip diagnostic ram region */
-	memcpy_fromio(p + B3_RI_WTO_R1, io + B3_RI_WTO_R1, 0x2000 - B3_RI_WTO_R1);
+	for (b = 0; b < 128; b++) {
+		/* This complicated switch statement is to make sure and
+		 * only access regions that are unreserved.
+		 * Some blocks are only valid on dual port cards.
+		 * and block 3 has some special diagnostic registers that
+		 * are poison.
+		 */
+		switch (b) {
+		case 3:
+			/* skip diagnostic ram region */
+			memcpy_fromio(p + 0x10, io + 0x10, 128 - 0x10);
+			break;
 
-	/* copy GMAC registers */
-	memcpy_fromio(p + BASE_GMAC_1, io + BASE_GMAC_1, 0x1000);
-	if (sky2->hw->ports > 1)
-		memcpy_fromio(p + BASE_GMAC_2, io + BASE_GMAC_2, 0x1000);
+		/* dual port cards only */
+		case 5:		/* Tx Arbiter 2 */
+		case 9: 	/* RX2 */
+		case 14 ... 15:	/* TX2 */
+		case 17: case 19: /* Ram Buffer 2 */
+		case 22 ... 23: /* Tx Ram Buffer 2 */
+		case 25: 	/* Rx MAC Fifo 1 */
+		case 27: 	/* Tx MAC Fifo 2 */
+		case 31:	/* GPHY 2 */
+		case 40 ... 47: /* Pattern Ram 2 */
+		case 52: case 54: /* TCP Segmentation 2 */
+		case 112 ... 116: /* GMAC 2 */
+			if (sky2->hw->ports == 1)
+				goto reserved;
+			/* fall through */
+		case 0:		/* Control */
+		case 2:		/* Mac address */
+		case 4:		/* Tx Arbiter 1 */
+		case 7:		/* PCI express reg */
+		case 8:		/* RX1 */
+		case 12 ... 13: /* TX1 */
+		case 16: case 18:/* Rx Ram Buffer 1 */
+		case 20 ... 21: /* Tx Ram Buffer 1 */
+		case 24: 	/* Rx MAC Fifo 1 */
+		case 26: 	/* Tx MAC Fifo 1 */
+		case 28 ... 29: /* Descriptor and status unit */
+		case 30:	/* GPHY 1*/
+		case 32 ... 39: /* Pattern Ram 1 */
+		case 48: case 50: /* TCP Segmentation 1 */
+		case 56 ... 60:	/* PCI space */
+		case 80 ... 84:	/* GMAC 1 */
+			memcpy_fromio(p, io, 128);
+			break;
+		default:
+reserved:
+			memset(p, 0, 128);
+		}
 
+		p += 128;
+		io += 128;
+	}
 }
 
 /* In order to do Jumbo packets on these chips, need to turn off the

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

