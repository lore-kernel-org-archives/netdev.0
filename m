From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 5/8] macb: handle HW address registers for GEM devices
Date: Thu, 10 Mar 2011 10:10:40 +0000
Message-ID: <1299751843-9743-6-git-send-email-jamie@jamieiles.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34325 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab1CJKLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:11:08 -0500
Received: by mail-wy0-f174.google.com with SMTP id 21so1289541wya.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:11:08 -0800 (PST)
In-Reply-To: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GEM has it's hardware address registers in a different location
to MACB so we need to make this conditional on type.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c |   19 +++++++++++++++----
 drivers/net/macb.h |    4 ++++
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 204afa6..2541e3b 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -57,9 +57,15 @@ static void __macb_set_hwaddr(struct macb *bp)
 	u16 top;
 
 	bottom = cpu_to_le32(*((u32 *)bp->dev->dev_addr));
-	macb_writel(bp, SA1B, bottom);
 	top = cpu_to_le16(*((u16 *)(bp->dev->dev_addr + 4)));
-	macb_writel(bp, SA1T, top);
+
+	if (!bp->is_gem) {
+		macb_writel(bp, SA1B, bottom);
+		macb_writel(bp, SA1T, top);
+	} else {
+		gem_writel(bp, SA1B, bottom);
+		gem_writel(bp, SA1T, top);
+	}
 }
 
 static void __init macb_get_hwaddr(struct macb *bp)
@@ -68,8 +74,13 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	u16 top;
 	u8 addr[6];
 
-	bottom = macb_readl(bp, SA1B);
-	top = macb_readl(bp, SA1T);
+	if (!bp->is_gem) {
+		bottom = macb_readl(bp, SA1B);
+		top = macb_readl(bp, SA1T);
+	} else {
+		bottom = gem_readl(bp, SA1B);
+		top = gem_readl(bp, SA1T);
+	}
 
 	addr[0] = bottom & 0xff;
 	addr[1] = (bottom >> 8) & 0xff;
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index f838615..6248af6 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -60,6 +60,10 @@
 #define MACB_USRIO				0x00c0
 #define MACB_WOL				0x00c4
 
+/* GEM register offsets. */
+#define GEM_SA1B				0x0088
+#define GEM_SA1T				0x008C
+
 /* Bitfields in NCR */
 #define MACB_LB_OFFSET				0
 #define MACB_LB_SIZE				1
-- 
1.7.4

