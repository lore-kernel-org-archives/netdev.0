From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 2/6] net: mvmdio: fix interrupt disable in remove path
Date: Mon, 10 Apr 2017 16:28:09 +0100
Message-ID: <E1cxbEf-0006gC-TV@rmk-PC.armlinux.org.uk>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37654 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753665AbdDJP2R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:28:17 -0400
In-Reply-To: <20170410152728.GT17774@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pre-existing write to disable interrupts on the remove path happens
whether we have an interrupt or not.  While this may seem to be a good
idea, this driver is re-used in many different implementations, some
where the binding only specifies four bytes of register space.  This
access causes us to access registers outside of the binding.

Make it conditional on the interrupt being present, which is the same
condition used when enabling the interrupt in the first place.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 7aea0beca56e..6ea5caddca62 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -263,7 +263,8 @@ static int orion_mdio_remove(struct platform_device *pdev)
 	struct mii_bus *bus = platform_get_drvdata(pdev);
 	struct orion_mdio_dev *dev = bus->priv;
 
-	writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
+	if (dev->err_interrupt > 0)
+		writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
 	mdiobus_unregister(bus);
 	if (!IS_ERR(dev->clk))
 		clk_disable_unprepare(dev->clk);
-- 
2.7.4
