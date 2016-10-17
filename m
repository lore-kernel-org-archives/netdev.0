From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 20/28] net: bcm63xx: avoid referencing uninitialized variable
Date: Tue, 18 Oct 2016 00:16:08 +0200
Message-ID: <20161017221650.1902729-1-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        Philippe Reynes <tremyfr@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:59226 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758713AbcJQWRd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 18:17:33 -0400
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc found a reference to an uninitialized variable in the error handling
of bcm_enet_open, introduced by a recent cleanup:

drivers/net/ethernet/broadcom/bcm63xx_enet.c: In function 'bcm_enet_open'
drivers/net/ethernet/broadcom/bcm63xx_enet.c:1129:2: warning: 'phydev' may be used uninitialized in this function [-Wmaybe-uninitialized]

This makes the use of that variable conditional, so we only reference it
here after it has been used before. Unlike my normal patches, I have not
build-tested this one, as I don't currently have mips test in my
randconfig setup.

Fixes: 625eb8667d6f ("net: ethernet: broadcom: bcm63xx: use phydev from struct net_device")
Cc: Philippe Reynes <tremyfr@gmail.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index ae364c7..5370909 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1126,7 +1126,8 @@ static int bcm_enet_open(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 out_phy_disconnect:
-	phy_disconnect(phydev);
+	if (priv->has_phy)
+		phy_disconnect(phydev);
 
 	return ret;
 }
-- 
2.9.0
