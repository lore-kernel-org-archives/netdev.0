From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 07/13] net: mvpp2: improve the link management function
Date: Thu, 24 Aug 2017 10:38:17 +0200
Message-ID: <20170824083823.16826-8-antoine.tenart@free-electrons.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:60539 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752215AbdHXIiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 04:38:52 -0400
In-Reply-To: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the link status changes, the phylib calls the link_event function
in the mvpp2 driver. Before this patch only the egress/ingress transmit
was enabled/disabled. This patch adds more functionality to the link
status management code by enabling/disabling the port per-cpu
interrupts, and the port itself. The queues are now stopped as well, and
the netif carrier helpers are called.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index ebcc89b8f792..99847fec1c5a 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5753,14 +5753,24 @@ static void mvpp2_link_event(struct net_device *dev)
 		port->link = phydev->link;
 
 		if (phydev->link) {
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
