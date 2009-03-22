From: Daniel Mack <daniel@caiaq.de>
Subject: [PATCH 2/2] ax88796: Add method to take MAC from platform data
Date: Sun, 22 Mar 2009 17:12:41 +0100
Message-ID: <1237738361-10184-2-git-send-email-daniel@caiaq.de>
References: <1237738361-10184-1-git-send-email-daniel@caiaq.de>
Cc: linux-kernel@vger.kernel.org, Daniel Mack <daniel@caiaq.de>,
	David Miller <davem@davemloft.net>,
	Ben Dooks <ben@simtec.co.uk>,
	Matthias Meier <matthias.j.meier@gmx.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:36446 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbZCVQNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 12:13:06 -0400
In-Reply-To: <1237738361-10184-1-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a way to provide the MAC address for ax88796 devices from
their platform data. Boards might decide to set the address
programmatically, taken from boot tags or other sources.

Signed-off-by: Daniel Mack <daniel@caiaq.de>
Cc: David Miller <davem@davemloft.net>
Cc: Ben Dooks <ben@simtec.co.uk>
Cc: Matthias Meier <matthias.j.meier@gmx.net>
---
 drivers/net/ax88796.c |   17 ++++++++++++-----
 include/net/ax88796.h |   13 ++++++++-----
 2 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index e7c9748..62d9c9c 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -733,12 +733,19 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 	/* load the mac-address from the device if this is the
 	 * first time we've initialised */
 
-	if (first_init && ax->plat->flags & AXFLG_MAC_FROMDEV) {
-		ei_outb(E8390_NODMA + E8390_PAGE1 + E8390_STOP,
-			ei_local->mem + E8390_CMD); /* 0x61 */
+	if (first_init) {
+		if (ax->plat->flags & AXFLG_MAC_FROMDEV) {
+			ei_outb(E8390_NODMA + E8390_PAGE1 + E8390_STOP,
+				ei_local->mem + E8390_CMD); /* 0x61 */
+			for (i = 0; i < ETHER_ADDR_LEN; i++)
+				dev->dev_addr[i] =
+					ei_inb(ioaddr + EN1_PHYS_SHIFT(i));
+		}
 
-		for (i = 0 ; i < ETHER_ADDR_LEN ; i++)
-			dev->dev_addr[i] = ei_inb(ioaddr + EN1_PHYS_SHIFT(i));
+		if ((ax->plat->flags & AXFLG_MAC_FROMPLATFORM) &&
+		     ax->plat->mac_addr)
+			memcpy(dev->dev_addr, ax->plat->mac_addr,
+				ETHER_ADDR_LEN);
 	}
 
 	ax_reset_8390(dev);
diff --git a/include/net/ax88796.h b/include/net/ax88796.h
index 51329da..b9a3bec 100644
--- a/include/net/ax88796.h
+++ b/include/net/ax88796.h
@@ -15,14 +15,17 @@
 #define AXFLG_HAS_EEPROM		(1<<0)
 #define AXFLG_MAC_FROMDEV		(1<<1)	/* device already has MAC */
 #define AXFLG_HAS_93CX6			(1<<2)	/* use eeprom_93cx6 driver */
+#define AXFLG_MAC_FROMPLATFORM		(1<<3)	/* MAC given by platform data */
 
 struct ax_plat_data {
 	unsigned int	 flags;
-	unsigned char	 wordlength;		/* 1 or 2 */
-	unsigned char	 dcr_val;		/* default value for DCR */
-	unsigned char	 rcr_val;		/* default value for RCR */
-	unsigned char	 gpoc_val;		/* default value for GPOC */
-	u32		*reg_offsets;		/* register offsets */
+	unsigned char	 wordlength;	/* 1 or 2 */
+	unsigned char	 dcr_val;	/* default value for DCR */
+	unsigned char	 rcr_val;	/* default value for RCR */
+	unsigned char	 gpoc_val;	/* default value for GPOC */
+	u32		*reg_offsets;	/* register offsets */
+	u8		*mac_addr;	/* MAC addr (only used when
+					   AXFLG_MAC_FROMPLATFORM is used */
 };
 
 #endif /* __NET_AX88796_PLAT_H */
-- 
1.6.2

