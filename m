From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 3/4] net: phy: Force PHY_HALTED during phy_disconnect()
Date: Wed, 25 Oct 2017 16:21:23 -0700
Message-ID: <20171025232124.14120-4-f.fainelli@gmail.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        andrew@lunn.ch, opendmb@gmail.com,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        slash.tmp@free.fr, david.daney@cavium.com, geert+renesas@glider.be
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:54886 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751949AbdJYXVp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 19:21:45 -0400
Received: by mail-qt0-f193.google.com with SMTP id z19so2143826qtg.11
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 16:21:44 -0700 (PDT)
In-Reply-To: <20171025232124.14120-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While debugging a crash reported by David Daney, we discovered that the
offending driver was calling phy_disconnect() without a prior call to
phy_stop() although it should have.

Add a WARN_ON() to catch such drivers, in order to invite their
maintainers to fix them, and also force the PHY state machine to
PHY_HALTED since we are about to disconnect anyway, there is nothing we
will be doing.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 67f25ac29025..69eb985c26fe 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -797,6 +797,11 @@ void phy_disconnect(struct phy_device *phydev)
 	if (phydev->irq > 0)
 		phy_stop_interrupts(phydev);
 
+	mutex_lock(&phydev->lock);
+	WARN_ON(phydev->state != PHY_HALTED);
+	phydev->state = PHY_HALTED;
+	mutex_unlock(&phydev->lock);
+
 	phy_stop_machine(phydev);
 
 	phydev->adjust_link = NULL;
-- 
2.9.3
