From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 2/5] net: phy: Use threaded IRQ, to allow IRQ from sleeping devices
Date: Sun, 16 Oct 2016 19:56:50 +0200
Message-ID: <1476640613-25365-3-git-send-email-andrew@lunn.ch>
References: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46323 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755684AbcJPR6R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 13:58:17 -0400
In-Reply-To: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt lines from PHYs maybe connected to I2C bus expanders, or
from switches on MDIO busses. Such interrupts are sourced from devices
which sleep, so use threaded interrupts. Threaded interrupts require
that the interrupt requester also uses the threaded API. Change the
phylib to use the threaded API, which is backwards compatible with
none-threaded IRQs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Add back IRQF_SHARED
---
 drivers/net/phy/phy.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f424b867f73e..25f2b296aaba 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -739,10 +739,10 @@ static int phy_disable_interrupts(struct phy_device *phydev)
 int phy_start_interrupts(struct phy_device *phydev)
 {
 	atomic_set(&phydev->irq_disable, 0);
-	if (request_irq(phydev->irq, phy_interrupt,
-				IRQF_SHARED,
-				"phy_interrupt",
-				phydev) < 0) {
+	if (request_threaded_irq(phydev->irq, NULL, phy_interrupt,
+				 IRQF_ONESHOT | IRQF_SHARED,
+				 "phy_interrupt",
+				 phydev) < 0) {
 		pr_warn("%s: Can't get IRQ %d (PHY)\n",
 			phydev->mdio.bus->name, phydev->irq);
 		phydev->irq = PHY_POLL;
-- 
2.9.3
