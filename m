From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net v2 4/4] net: mvpp2: fallback using h/w and random mac if the dt one isn't valid
Date: Fri, 25 Aug 2017 16:14:20 +0200
Message-ID: <20170825141420.14027-5-antoine.tenart@free-electrons.com>
References: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net, thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using a mac address described in the device tree, a check is made
to see if it is valid. When it's not, no fallback is defined. This
patches tries to get the mac address from h/w (or use a random one if
the h/w one isn't valid) when the dt mac address isn't valid.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 162e334fda37..2f1284f23e66 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6504,19 +6504,20 @@ static void mvpp2_port_copy_mac_addr(struct net_device *dev, struct mvpp2 *priv,
 	if (dt_mac_addr && is_valid_ether_addr(dt_mac_addr)) {
 		*mac_from = "device tree";
 		ether_addr_copy(dev->dev_addr, dt_mac_addr);
-	} else {
-		if (priv->hw_version == MVPP21) {
-			mvpp21_get_mac_address(port, hw_mac_addr);
-			if (is_valid_ether_addr(hw_mac_addr)) {
-				*mac_from = "hardware";
-				ether_addr_copy(dev->dev_addr, hw_mac_addr);
-				return;
-			}
-		}
+		return;
+	}
 
-		*mac_from = "random";
-		eth_hw_addr_random(dev);
+	if (priv->hw_version == MVPP21) {
+		mvpp21_get_mac_address(port, hw_mac_addr);
+		if (is_valid_ether_addr(hw_mac_addr)) {
+			*mac_from = "hardware";
+			ether_addr_copy(dev->dev_addr, hw_mac_addr);
+			return;
+		}
 	}
+
+	*mac_from = "random";
+	eth_hw_addr_random(dev);
 }
 
 /* Ports initialization */
-- 
2.13.5
