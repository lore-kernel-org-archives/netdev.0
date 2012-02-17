From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 03/10] davinci_emac: use eth_hw_addr_random() instead of random_ether_addr()
Date: Fri, 17 Feb 2012 16:43:24 +0100
Message-ID: <1329493411-25750-4-git-send-email-danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Richard Cochran <richard.cochran@omicron.at>,
	Julia Lawall <julia@diku.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use eth_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Remove one memcpy from emac_dev_setmac_addr() since this is a
duplicate: it's already done some lines above.

v2: use bitops, adapt to eth_hw_addr_random, remove a memcpy

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/ti/davinci_emac.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 794ac30..50adba0 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1260,10 +1260,10 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 	/* Store mac addr in priv and rx channel and set it in EMAC hw */
 	memcpy(priv->mac_addr, sa->sa_data, ndev->addr_len);
 	memcpy(ndev->dev_addr, sa->sa_data, ndev->addr_len);
+	ndev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	/* MAC address is configured only after the interface is enabled. */
 	if (netif_running(ndev)) {
-		memcpy(priv->mac_addr, sa->sa_data, ndev->addr_len);
 		emac_setmac(priv, EMAC_DEF_RX_CH, priv->mac_addr);
 	}
 
@@ -1897,7 +1897,8 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	if (!is_valid_ether_addr(priv->mac_addr)) {
 		/* Use random MAC if none passed */
-		random_ether_addr(priv->mac_addr);
+		eth_hw_addr_random(ndev);
+		memcpy(priv->mac_addr, ndev->dev_addr, ndev->addr_len);
 		dev_warn(&pdev->dev, "using random MAC addr: %pM\n",
 							priv->mac_addr);
 	}
-- 
1.7.8.3
