From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 08/10] GRETH: avoid writing bad speed/duplex when setting transfer mode
Date: Thu, 13 Jan 2011 09:25:33 +0100
Message-ID: <1294907135-24884-8-git-send-email-daniel@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:39241 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756182Ab1AMJAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:00:05 -0500
In-Reply-To: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 888dc65..fea1e20 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1242,29 +1242,26 @@ static void greth_link_change(struct net_device *dev)
 	struct greth_private *greth = netdev_priv(dev);
 	struct phy_device *phydev = greth->phy;
 	unsigned long flags;
-
 	int status_change = 0;
+	u32 ctrl;
 
 	spin_lock_irqsave(&greth->devlock, flags);
 
 	if (phydev->link) {
 
 		if ((greth->speed != phydev->speed) || (greth->duplex != phydev->duplex)) {
-
-			GRETH_REGANDIN(greth->regs->control,
-				       ~(GRETH_CTRL_FD | GRETH_CTRL_SP | GRETH_CTRL_GB));
+			ctrl = GRETH_REGLOAD(greth->regs->control) &
+			       ~(GRETH_CTRL_FD | GRETH_CTRL_SP | GRETH_CTRL_GB);
 
 			if (phydev->duplex)
-				GRETH_REGORIN(greth->regs->control, GRETH_CTRL_FD);
-
-			if (phydev->speed == SPEED_100) {
-
-				GRETH_REGORIN(greth->regs->control, GRETH_CTRL_SP);
-			}
+				ctrl |= GRETH_CTRL_FD;
 
+			if (phydev->speed == SPEED_100)
+				ctrl |= GRETH_CTRL_SP;
 			else if (phydev->speed == SPEED_1000)
-				GRETH_REGORIN(greth->regs->control, GRETH_CTRL_GB);
+				ctrl |= GRETH_CTRL_GB;
 
+			GRETH_REGSAVE(greth->regs->control, ctrl);
 			greth->speed = phydev->speed;
 			greth->duplex = phydev->duplex;
 			status_change = 1;
-- 
1.5.4

