From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] via-rhine: fix wait-bit inversion.
Date: Mon, 2 Apr 2012 00:35:00 +0200
Message-ID: <20120401223500.GA28138@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andreas Mohr <andi@lisas.de>,
	David Lv <DavidLv@viatech.com.cn>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33401 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752933Ab2DAWiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Apr 2012 18:38:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andi@lisas.de>

Bug appeared in a384a33bb1c9ec2d99db2046b41f57023fa7d77b
("via-rhine: RHINE_WAIT_FOR macro removal). It can be noticed
during suspend/resume.

Signed-off-by: Andreas Mohr <andi@lisas.de>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: David Lv <DavidLv@viatech.com.cn>
---

 It should be fed to 3.3-stable.

 drivers/net/ethernet/via/via-rhine.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 39b8cf3..fcfa01f 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -503,30 +503,32 @@ static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
 static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
 static void rhine_restart_tx(struct net_device *dev);
 
-static void rhine_wait_bit(struct rhine_private *rp, u8 reg, u8 mask, bool high)
+static void rhine_wait_bit(struct rhine_private *rp, u8 reg, u8 mask, bool low)
 {
 	void __iomem *ioaddr = rp->base;
 	int i;
 
 	for (i = 0; i < 1024; i++) {
-		if (high ^ !!(ioread8(ioaddr + reg) & mask))
+		bool has_mask_bits = !!(ioread8(ioaddr + reg) & mask);
+
+		if (low ^ has_mask_bits)
 			break;
 		udelay(10);
 	}
 	if (i > 64) {
 		netif_dbg(rp, hw, rp->dev, "%s bit wait (%02x/%02x) cycle "
-			  "count: %04d\n", high ? "high" : "low", reg, mask, i);
+			  "count: %04d\n", low ? "low" : "high", reg, mask, i);
 	}
 }
 
 static void rhine_wait_bit_high(struct rhine_private *rp, u8 reg, u8 mask)
 {
-	rhine_wait_bit(rp, reg, mask, true);
+	rhine_wait_bit(rp, reg, mask, false);
 }
 
 static void rhine_wait_bit_low(struct rhine_private *rp, u8 reg, u8 mask)
 {
-	rhine_wait_bit(rp, reg, mask, false);
+	rhine_wait_bit(rp, reg, mask, true);
 }
 
 static u32 rhine_get_events(struct rhine_private *rp)
-- 
1.7.7.6
