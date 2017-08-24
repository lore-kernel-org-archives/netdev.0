From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 3/4] net: mvpp2: fix use of the random mac address for PPv2.2
Date: Thu, 24 Aug 2017 11:46:57 +0200
Message-ID: <20170824094658.1296-4-antoine.tenart@free-electrons.com>
References: <20170824094658.1296-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net, thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824094658.1296-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MAC retrieval logic is using a variable to store an h/w stored mac
address and checks this mac against invalid ones before using it. But
the mac address is only read from h/w when using PPv2.1. So when using
PPv2.2 it defaults to its init state.

This patches fixes the logic to only check if the h/w mac is valid when
actually retrieving a mac from h/w.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 908e5b148fd7..fe8309124a09 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -7466,15 +7466,17 @@ static void mvpp2_port_copy_mac_addr(struct net_device *dev, struct mvpp2 *priv,
 		*mac_from = "device tree";
 		ether_addr_copy(dev->dev_addr, dt_mac_addr);
 	} else {
-		if (priv->hw_version == MVPP21)
+		if (priv->hw_version == MVPP21) {
 			mvpp21_get_mac_address(port, hw_mac_addr);
-		if (is_valid_ether_addr(hw_mac_addr)) {
-			*mac_from = "hardware";
-			ether_addr_copy(dev->dev_addr, hw_mac_addr);
-		} else {
-			*mac_from = "random";
-			eth_hw_addr_random(dev);
+			if (is_valid_ether_addr(hw_mac_addr)) {
+				*mac_from = "hardware";
+				ether_addr_copy(dev->dev_addr, hw_mac_addr);
+				return;
+			}
 		}
+
+		*mac_from = "random";
+		eth_hw_addr_random(dev);
 	}
 }
 
-- 
2.13.5
