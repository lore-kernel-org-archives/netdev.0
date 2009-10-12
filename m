From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 2/3] sky2: Reading registers in reset causes a hang
Date: Mon, 12 Oct 2009 23:06:37 +0900
Message-ID: <4AD337ED.4090409@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:56717 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756708AbZJLOH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 10:07:58 -0400
Received: by pzk26 with SMTP id 26so8093989pzk.4
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 07:07:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sky2 hardware is in reset, reading registers with ethtool -d
causes a hard system hang. eg.

    ifconfig eth1 down
    ethtool -d eth1

Avoid reading FIFOs, descriptor and status unit, etc. after we've
 bought the interface down, as these seem to cause the issue.

Assume the same is true for the second port, as my port only has
 one card.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 9713527..67c8478 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3735,22 +3735,27 @@ static int sky2_reg_access_ok(struct sky2_hw *hw, unsigned int b)
 	/* This complicated switch statement is to make sure and
 	 * only access regions that are unreserved.
 	 * Some blocks are only valid on dual port cards.
+	 * Some blocks can only be accessed when the hardware is not in reset,
 	 */
 	switch (b) {
-	/* second port */
+	/* second port, when it exists */
 	case 5:		/* Tx Arbiter 2 */
 	case 9:		/* RX2 */
 	case 14 ... 15:	/* TX2 */
 	case 17: case 19: /* Ram Buffer 2 */
 	case 22 ... 23: /* Tx Ram Buffer 2 */
-	case 25:	/* Rx MAC Fifo 1 */
+		return hw->ports > 1;
+
+	/* second port, when it exists and is not in reset */
+	case 25:	/* Rx MAC Fifo 2 */
 	case 27:	/* Tx MAC Fifo 2 */
 	case 31:	/* GPHY 2 */
 	case 40 ... 47: /* Pattern Ram 2 */
 	case 52: case 54: /* TCP Segmentation 2 */
 	case 112 ... 116: /* GMAC 2 */
-		return hw->ports > 1;
+		return hw->ports > 1 && netif_running(hw->dev[1]);
 
+	/* first port and common registers */
 	case 0:		/* Control */
 	case 2:		/* Mac address */
 	case 4:		/* Tx Arbiter 1 */
@@ -3759,14 +3764,19 @@ static int sky2_reg_access_ok(struct sky2_hw *hw, unsigned int b)
 	case 12 ... 13: /* TX1 */
 	case 16: case 18:/* Rx Ram Buffer 1 */
 	case 20 ... 21: /* Tx Ram Buffer 1 */
+		return 1;
+
+	/* first port, when not in reset */
 	case 24:	/* Rx MAC Fifo 1 */
 	case 26:	/* Tx MAC Fifo 1 */
 	case 28 ... 29: /* Descriptor and status unit */
 	case 30:	/* GPHY 1*/
 	case 32 ... 39: /* Pattern Ram 1 */
 	case 48: case 50: /* TCP Segmentation 1 */
-	case 56 ... 60:	/* PCI space */
 	case 80 ... 84:	/* GMAC 1 */
+		return netif_running(hw->dev[0]);
+
+	case 56 ... 60:	/* PCI space */
 		return 1;
 
 	default:
-- 
1.5.6.5


