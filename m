From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next v2 1/3] can: mscan: fix improper return if dlc < 8 in start_xmit function
Date: Tue,  5 Jan 2010 20:19:27 +0100
Message-ID: <1262719169-2350-2-git-send-email-wg@grandegger.com>
References: <1262719169-2350-1-git-send-email-wg@grandegger.com>
Cc: Socketcan-core@lists.berlios.de, Linuxppc-dev@lists.ozlabs.org,
	Devicetree-discuss@lists.ozlabs.org,
	Wolfram Sang <w.sang@pengutronix.de>,
	Wolfgang Grandegger <wg@denx.de>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1262719169-2350-1-git-send-email-wg@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@denx.de>

The start_xmit function of the MSCAN Driver did return improperly if
the CAN dlc check failed (skb not freed and invalid return code). This
patch adds a proper check of the frame lenght and data size and returns
now correctly. Furthermore, a typo has been fixed.

Signed-off-by: Wolfgang Grandegger <wg@denx.de>
Acked-by: Wolfram Sang <w.sang@pengutronix.de>
---
 drivers/net/can/mscan/mscan.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index bb06dfb..7df950e 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2005-2006 Andrey Volkov <avolkov@varma-el.com>,
  *                         Varma Electronics Oy
  * Copyright (C) 2008-2009 Wolfgang Grandegger <wg@grandegger.com>
- * Copytight (C) 2008-2009 Pengutronix <kernel@pengutronix.de>
+ * Copyright (C) 2008-2009 Pengutronix <kernel@pengutronix.de>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the version 2 of the GNU General Public License
@@ -177,8 +177,13 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i, rtr, buf_id;
 	u32 can_id;
 
-	if (frame->can_dlc > 8)
-		return -EINVAL;
+	if (skb->len != sizeof(*frame) || frame->can_dlc > 8) {
+		dev_err(dev->dev.parent,
+			"Dropping non-conform packet: len %u, can_dlc %u\n",
+			skb->len, frame->can_dlc);
+		kfree_skb(skb);
+		return  NETDEV_TX_OK;
+	}
 
 	out_8(&regs->cantier, 0);
 
-- 
1.6.2.5

