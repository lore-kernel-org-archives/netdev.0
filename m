From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/3] bcm63xx_enet: avoid uninitialized variable warning
Date: Wed, 18 Jan 2017 15:52:53 +0100
Message-ID: <20170118145306.1004008-3-arnd@arndb.de>
References: <20170118145306.1004008-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, "xypron.glpk@gmx.de" <xypron.glpk@gmx.de>,
 linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
 netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Philippe Reynes <tremyfr@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
 "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170118145306.1004008-1-arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

gcc-7 and probably earlier versions get confused by this function
and print a harmless warning:

drivers/net/ethernet/broadcom/bcm63xx_enet.c: In function 'bcm_enet_open':
drivers/net/ethernet/broadcom/bcm63xx_enet.c:1130:3: error: 'phydev' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This adds an initialization for the 'phydev' variable when it is unused
and changes the check to test for that NULL pointer to make it clear
that we always pass a valid pointer here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 1ad904680ca6..f0a0bcb31b7e 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -913,6 +913,8 @@ static int bcm_enet_open(struct net_device *dev)
 		priv->old_link = 0;
 		priv->old_duplex = -1;
 		priv->old_pause = -1;
+	} else {
+		phydev = NULL;
 	}
 
 	/* mask all interrupts and request them */
@@ -1083,7 +1085,7 @@ static int bcm_enet_open(struct net_device *dev)
 	enet_dmac_writel(priv, priv->dma_chan_int_mask,
 			 ENETDMAC_IRMASK, priv->tx_chan);
 
-	if (priv->has_phy)
+	if (phydev)
 		phy_start(phydev);
 	else
 		bcm_enet_adjust_link(dev);
@@ -1126,7 +1128,7 @@ static int bcm_enet_open(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 out_phy_disconnect:
-	if (priv->has_phy)
+	if (phydev)
 		phy_disconnect(phydev);
 
 	return ret;
-- 
2.9.0
