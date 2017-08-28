From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v3 06/13] net: mvpp2: improve the link management function
Date: Mon, 28 Aug 2017 16:57:18 +0200
Message-ID: <20170828145725.2539-7-antoine.tenart@free-electrons.com>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the link status changes, the phylib calls the link_event function
in the mvpp2 driver. Before this patch only the egress/ingress transmit
was enabled/disabled. This patch adds more functionality to the link
status management code by enabling/disabling the port per-cpu
interrupts, and the port itself. The queues are now stopped as well, and
the netif carrier helpers are called.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 9c0c81e68d55..09cad32734f3 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5777,14 +5777,25 @@ static void mvpp2_link_event(struct net_device *dev)
 			val |= (MVPP2_GMAC_FORCE_LINK_PASS |
 				MVPP2_GMAC_FORCE_LINK_DOWN);
 			writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
+
+			mvpp2_interrupts_enable(port);
+			mvpp2_port_enable(port);
+
 			mvpp2_egress_enable(port);
 			mvpp2_ingress_enable(port);
+			netif_carrier_on(dev);
+			netif_tx_wake_all_queues(dev);
 		} else {
 			port->duplex = -1;
 			port->speed = 0;
 
+			netif_tx_stop_all_queues(dev);
+			netif_carrier_off(dev);
 			mvpp2_ingress_disable(port);
 			mvpp2_egress_disable(port);
+
+			mvpp2_port_disable(port);
+			mvpp2_interrupts_disable(port);
 		}
 
 		phy_print_status(phydev);
-- 
2.13.5
