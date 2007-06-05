From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/7] sky2: avoid reserved regions on ethtool reg dump
Date: Mon, 04 Jun 2007 17:23:21 -0700
Message-ID: <20070605002738.626584893@linux-foundation.org>
References: <20070605002320.868185090@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53402 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753822AbXFEAnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:43:11 -0400
Content-Disposition: inline; filename=sky2-reg-dump-avoid.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Yukon EX reading some of the undocumented places in the
memory space will cause a hang. Since they don't provide useful
information, just skip the reserved areas.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

--- a/drivers/net/sky2.c	2007-06-04 08:45:25.000000000 -0700
+++ b/drivers/net/sky2.c	2007-06-04 08:46:34.000000000 -0700
@@ -3330,7 +3330,7 @@ static int sky2_get_regs_len(struct net_
 
 /*
  * Returns copy of control register region
- * Note: access to the RAM address register set will cause timeouts.
+ * Note: ethtool_get_regs always provides full size (16k) buffer
  */
 static void sky2_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			  void *p)
@@ -3338,15 +3338,19 @@ static void sky2_get_regs(struct net_dev
 	const struct sky2_port *sky2 = netdev_priv(dev);
 	const void __iomem *io = sky2->hw->regs;
 
-	BUG_ON(regs->len < B3_RI_WTO_R1);
 	regs->version = 1;
 	memset(p, 0, regs->len);
 
 	memcpy_fromio(p, io, B3_RAM_ADDR);
 
-	memcpy_fromio(p + B3_RI_WTO_R1,
-		      io + B3_RI_WTO_R1,
-		      regs->len - B3_RI_WTO_R1);
+	/* skip diagnostic ram region */
+	memcpy_fromio(p + B3_RI_WTO_R1, io + B3_RI_WTO_R1, 0x2000 - B3_RI_WTO_R1);
+
+	/* copy GMAC registers */
+	memcpy_fromio(p + BASE_GMAC_1, io + BASE_GMAC_1, 0x1000);
+	if (sky2->hw->ports > 1)
+		memcpy_fromio(p + BASE_GMAC_2, io + BASE_GMAC_2, 0x1000);
+
 }
 
 /* In order to do Jumbo packets on these chips, need to turn off the

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

