From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH net-next] net: stmmac: allow changing the MTU while the interface is running
Date: Tue, 4 Apr 2017 14:18:54 +0200
Message-ID: <20170404121854.606-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Niklas Cassel <niklass@axis.com>
To: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <Joao.Pinto@synopsys.com>, <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

Setting ethtool ops for stmmac is only allowed when the interface is up.
Setting MTU (a netdev op) for stmmac is only allowed when the interface
is down.

It seems that the only reason why MTU cannot be changed when running is
that we have not bothered to implement a nice way to dealloc/alloc the
descriptor rings.

To make it less confusing for the user, call ndo_stop() and ndo_open()
from ndo_change_mtu(). This is not a nice way to dealloc/alloc the
descriptor rings, since it will announce that the interface is being
brought down/up to user space, but there are several other drivers doing
it this way, and it is arguably better than just returning -EBUSY.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c1c63197ff73..fd268dc0df02 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3109,17 +3109,15 @@ static void stmmac_set_rx_mode(struct net_device *dev)
  */
 static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct stmmac_priv *priv = netdev_priv(dev);
-
-	if (netif_running(dev)) {
-		netdev_err(priv->dev, "must be stopped to change its MTU\n");
-		return -EBUSY;
-	}
-
 	dev->mtu = new_mtu;
 
 	netdev_update_features(dev);
 
+	if (netif_running(dev)) {
+		stmmac_release(dev);
+		stmmac_open(dev);
+	}
+
 	return 0;
 }
 
-- 
2.11.0
