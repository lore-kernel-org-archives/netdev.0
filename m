From: Rabin Vincent <rabin.vincent@axis.com>
Subject: [PATCHv2] phy: fix crash in fixed_phy_add()
Date: Tue, 17 May 2016 11:01:50 +0200
Message-ID: <1463475710-15869-1-git-send-email-rabin.vincent@axis.com>
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	Rabin Vincent <rabinv@axis.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:57357 "EHLO
	bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462AbcEQJB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 05:01:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabinv@axis.com>

Since e7f4dc3536a ("mdio: Move allocation of interrupts into core"),
platforms which call fixed_phy_add() before fixed_mdio_bus_init() is
called (for example, because the platform code and the fixed_phy driver
use the same initcall level) crash in fixed_phy_add() since the
->mii_bus is not allocated.

Also since e7f4dc3536a, these interrupts are initalized to polling by
default.  The few (old) platforms which directly use fixed_phy_add()
from their platform code all pass PHY_POLL for the irq argument, so we
can keep these platforms not crashing by simply not attempting to set
the irq if PHY_POLL is passed.

Also, even if problems have not been reported on more modern platforms
which used fixed_phy_register() from drivers' probe functions, we return
-EPROBE_DEFER if the MDIO bus is not yet registered so that the probe is
retried later.

Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
Signed-off-by: Rabin Vincent <rabinv@axis.com>
---
v2: rewrite according to Andrew's suggestions

 drivers/net/phy/fixed_phy.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index fc07a88..d9dc1f5 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -255,7 +255,8 @@ int fixed_phy_add(unsigned int irq, int phy_addr,
 
 	memset(fp->regs, 0xFF,  sizeof(fp->regs[0]) * MII_REGS_NUM);
 
-	fmb->mii_bus->irq[phy_addr] = irq;
+	if (irq != PHY_POLL)
+		fmb->mii_bus->irq[phy_addr] = irq;
 
 	fp->addr = phy_addr;
 	fp->status = *status;
@@ -314,6 +315,9 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 	int phy_addr;
 	int ret;
 
+	if (!fmb->mii_bus)
+		return ERR_PTR(-EPROBE_DEFER);
+
 	/* Get the next available PHY address, up to PHY_MAX_ADDR */
 	spin_lock(&phy_fixed_addr_lock);
 	if (phy_fixed_addr == PHY_MAX_ADDR) {
-- 
2.1.4
