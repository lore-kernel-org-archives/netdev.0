From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 8/8] net: phy: Use threaded IRQ, to allow IRQ from sleeping devices
Date: Mon, 14 Mar 2016 01:33:51 +0100
Message-ID: <1457915631-16696-9-git-send-email-andrew@lunn.ch>
References: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55944 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298AbcCNAep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2016 20:34:45 -0400
In-Reply-To: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt lines from PHYs maybe connected to I2C bus expanders, or
from switches on MDIO busses. Such interrupts are sourced from devices
which sleep, so use threaded interrupts. Threaded require that the
interrupt requester also uses the threaded API. Change the phylib to
use the threaded API, which is backwards compatible with none-threaded
IRQs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/phy.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 5590b9c182c9..54a623c93e49 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -641,8 +641,9 @@ phy_err:
 int phy_start_interrupts(struct phy_device *phydev)
 {
 	atomic_set(&phydev->irq_disable, 0);
-	if (request_irq(phydev->irq, phy_interrupt, 0, "phy_interrupt",
-			phydev) < 0) {
+	if (request_threaded_irq(phydev->irq, NULL, phy_interrupt,
+				 IRQF_ONESHOT, "phy_interrupt",
+				 phydev) < 0) {
 		pr_warn("%s: Can't get IRQ %d (PHY)\n",
 			phydev->mdio.bus->name, phydev->irq);
 		phydev->irq = PHY_POLL;
-- 
2.7.0
