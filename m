From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 3/5] tc35815: Increase timeout for mdio
Date: Thu,  6 Aug 2009 23:41:47 +0900
Message-ID: <1249569709-21403-3-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:56606 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756AbZHFPbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 11:31:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current timeout value is too short for very high-load condition
which jiffies might jump up in busy-loop.
Also add minimum delay before checking completion of MDIO.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 801d201..1adb150 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -594,9 +594,10 @@ static int tc_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	struct net_device *dev = bus->priv;
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
-	unsigned long timeout = jiffies + 10;
+	unsigned long timeout = jiffies + HZ;
 
 	tc_writel(MD_CA_Busy | (mii_id << 5) | (regnum & 0x1f), &tr->MD_CA);
+	udelay(12); /* it takes 32 x 400ns at least */
 	while (tc_readl(&tr->MD_CA) & MD_CA_Busy) {
 		if (time_after(jiffies, timeout))
 			return -EIO;
@@ -610,11 +611,12 @@ static int tc_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 val)
 	struct net_device *dev = bus->priv;
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
-	unsigned long timeout = jiffies + 10;
+	unsigned long timeout = jiffies + HZ;
 
 	tc_writel(val, &tr->MD_Data);
 	tc_writel(MD_CA_Busy | MD_CA_Wr | (mii_id << 5) | (regnum & 0x1f),
 		  &tr->MD_CA);
+	udelay(12); /* it takes 32 x 400ns at least */
 	while (tc_readl(&tr->MD_CA) & MD_CA_Busy) {
 		if (time_after(jiffies, timeout))
 			return -EIO;
-- 
1.5.6.5

