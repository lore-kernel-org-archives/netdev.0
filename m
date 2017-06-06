From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH] net: ethoc: enable NAPI before poll may be scheduled
Date: Mon,  5 Jun 2017 18:31:16 -0700
Message-ID: <1496712676-11862-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thierry Reding <thierry.reding@gmail.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Max Filippov <jcmvbkbc@gmail.com>, stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ethoc_reset enables device interrupts, ethoc_interrupt may schedule a
NAPI poll before NAPI is enabled in the ethoc_open, which results in
device being unable to send or receive anything until it's closed and
reopened. In case the device is flooded with ingress packets it may be
unable to recover at all.
Move napi_enable above ethoc_reset in the ethoc_open to fix that.

Cc: stable@vger.kernel.org
Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 23d8274..4f33660 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -739,6 +739,8 @@ static int ethoc_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
+	napi_enable(&priv->napi);
+
 	ethoc_init_ring(priv, dev->mem_start);
 	ethoc_reset(priv);
 
@@ -754,7 +756,6 @@ static int ethoc_open(struct net_device *dev)
 	priv->old_duplex = -1;
 
 	phy_start(dev->phydev);
-	napi_enable(&priv->napi);
 
 	if (netif_msg_ifup(priv)) {
 		dev_info(&dev->dev, "I/O: %08lx Memory: %08lx-%08lx\n",
-- 
2.1.4
