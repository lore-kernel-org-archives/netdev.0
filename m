From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Refactor sky2_get_regs into two functions
Date: Sun, 25 Oct 2009 18:42:32 +0900
Message-ID: <4AE41D88.4000100@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:36043 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbZJYJno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 05:43:44 -0400
Received: by pxi9 with SMTP id 9so639726pxi.4
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2009 02:43:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate code deciding which registers can be accessed out of sky2_get_regs.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   94 ++++++++++++++++++++++++++-------------------------
 1 files changed, 48 insertions(+), 46 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 2ab5c39..9713527 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3730,6 +3730,50 @@ static int sky2_get_regs_len(struct net_device *dev)
 	return 0x4000;
 }
 
+static int sky2_reg_access_ok(struct sky2_hw *hw, unsigned int b)
+{
+	/* This complicated switch statement is to make sure and
+	 * only access regions that are unreserved.
+	 * Some blocks are only valid on dual port cards.
+	 */
+	switch (b) {
+	/* second port */
+	case 5:		/* Tx Arbiter 2 */
+	case 9:		/* RX2 */
+	case 14 ... 15:	/* TX2 */
+	case 17: case 19: /* Ram Buffer 2 */
+	case 22 ... 23: /* Tx Ram Buffer 2 */
+	case 25:	/* Rx MAC Fifo 1 */
+	case 27:	/* Tx MAC Fifo 2 */
+	case 31:	/* GPHY 2 */
+	case 40 ... 47: /* Pattern Ram 2 */
+	case 52: case 54: /* TCP Segmentation 2 */
+	case 112 ... 116: /* GMAC 2 */
+		return hw->ports > 1;
+
+	case 0:		/* Control */
+	case 2:		/* Mac address */
+	case 4:		/* Tx Arbiter 1 */
+	case 7:		/* PCI express reg */
+	case 8:		/* RX1 */
+	case 12 ... 13: /* TX1 */
+	case 16: case 18:/* Rx Ram Buffer 1 */
+	case 20 ... 21: /* Tx Ram Buffer 1 */
+	case 24:	/* Rx MAC Fifo 1 */
+	case 26:	/* Tx MAC Fifo 1 */
+	case 28 ... 29: /* Descriptor and status unit */
+	case 30:	/* GPHY 1*/
+	case 32 ... 39: /* Pattern Ram 1 */
+	case 48: case 50: /* TCP Segmentation 1 */
+	case 56 ... 60:	/* PCI space */
+	case 80 ... 84:	/* GMAC 1 */
+		return 1;
+
+	default:
+		return 0;
+	}
+}
+
 /*
  * Returns copy of control register region
  * Note: ethtool_get_regs always provides full size (16k) buffer
@@ -3744,55 +3788,13 @@ static void sky2_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	regs->version = 1;
 
 	for (b = 0; b < 128; b++) {
-		/* This complicated switch statement is to make sure and
-		 * only access regions that are unreserved.
-		 * Some blocks are only valid on dual port cards.
-		 * and block 3 has some special diagnostic registers that
-		 * are poison.
-		 */
-		switch (b) {
-		case 3:
-			/* skip diagnostic ram region */
+		/* skip poisonous diagnostic ram region in block 3 */
+		if (b == 3)
 			memcpy_fromio(p + 0x10, io + 0x10, 128 - 0x10);
-			break;
-
-		/* dual port cards only */
-		case 5:		/* Tx Arbiter 2 */
-		case 9: 	/* RX2 */
-		case 14 ... 15:	/* TX2 */
-		case 17: case 19: /* Ram Buffer 2 */
-		case 22 ... 23: /* Tx Ram Buffer 2 */
-		case 25: 	/* Rx MAC Fifo 1 */
-		case 27: 	/* Tx MAC Fifo 2 */
-		case 31:	/* GPHY 2 */
-		case 40 ... 47: /* Pattern Ram 2 */
-		case 52: case 54: /* TCP Segmentation 2 */
-		case 112 ... 116: /* GMAC 2 */
-			if (sky2->hw->ports == 1)
-				goto reserved;
-			/* fall through */
-		case 0:		/* Control */
-		case 2:		/* Mac address */
-		case 4:		/* Tx Arbiter 1 */
-		case 7:		/* PCI express reg */
-		case 8:		/* RX1 */
-		case 12 ... 13: /* TX1 */
-		case 16: case 18:/* Rx Ram Buffer 1 */
-		case 20 ... 21: /* Tx Ram Buffer 1 */
-		case 24: 	/* Rx MAC Fifo 1 */
-		case 26: 	/* Tx MAC Fifo 1 */
-		case 28 ... 29: /* Descriptor and status unit */
-		case 30:	/* GPHY 1*/
-		case 32 ... 39: /* Pattern Ram 1 */
-		case 48: case 50: /* TCP Segmentation 1 */
-		case 56 ... 60:	/* PCI space */
-		case 80 ... 84:	/* GMAC 1 */
+		else if (sky2_reg_access_ok(sky2->hw, b))
 			memcpy_fromio(p, io, 128);
-			break;
-		default:
-reserved:
+		else
 			memset(p, 0, 128);
-		}
 
 		p += 128;
 		io += 128;
-- 
1.5.6.5

