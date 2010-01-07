From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next v4 1/3] can: mscan: fix improper return if dlc < 8 in
	start_xmit function
Date: Thu,  7 Jan 2010 20:43:06 +0100
Message-ID: <1262893388-16218-2-git-send-email-wg@grandegger.com>
References: <1262893388-16218-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
To: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1262893388-16218-1-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>

The start_xmit function of the MSCAN Driver did return improperly if
the CAN dlc check failed (skb not freed and invalid return code). This
patch adds a proper check of the frame lenght and data size and returns
now correctly. The invalid skb packets are dropped silently as suggested
by David Miller in the thread "[RFC] ndo_validate_skb: Let the netdev
check a valid skb content" on the netdev mailing list.

Furthermore, a typo has been fixed.

Signed-off-by: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
Reviewed-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/mscan/mscan.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 07346f8..0dcbe8c 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2005-2006 Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>,
  *                         Varma Electronics Oy
  * Copyright (C) 2008-2009 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
- * Copytight (C) 2008-2009 Pengutronix <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
+ * Copyright (C) 2008-2009 Pengutronix <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the version 2 of the GNU General Public License
@@ -177,8 +177,11 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i, rtr, buf_id;
 	u32 can_id;
 
-	if (frame->can_dlc > 8)
-		return -EINVAL;
+	if (skb->len != sizeof(*frame) || frame->can_dlc > 8) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
 
 	out_8(&regs->cantier, 0);
 
-- 
1.6.2.5
