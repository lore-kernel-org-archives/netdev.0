From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 09/18] net: mvpp2: use named interrupts
Date: Mon, 24 Jul 2017 15:48:39 +0200
Message-ID: <20170724134848.19330-10-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47378 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755841AbdGXNuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:06 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch update the Marvell PPv2 driver to use named interrupts. A
compatibility path is kept to allow using device trees using the old dt
bindings. This change is needed as other interrupts will be used by the
PPv2 driver at some point.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index f6eb98d38ced..77eef2cc40a1 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6789,10 +6789,20 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 
 	port = netdev_priv(dev);
 
-	port->irq = irq_of_parse_and_map(port_node, 0);
-	if (port->irq <= 0) {
-		err = -EINVAL;
-		goto err_free_netdev;
+	if (of_get_property(port_node, "interrupt-names", NULL)) {
+		port->irq = of_irq_get_byname(port_node, "rx-shared");
+		if (port->irq <= 0) {
+			err = (port->irq == -EPROBE_DEFER) ?
+			      -EPROBE_DEFER : -EINVAL;
+			goto err_free_netdev;
+		}
+	} else {
+		/* kept for dt compatibility */
+		port->irq = irq_of_parse_and_map(port_node, 0);
+		if (port->irq <= 0) {
+			err = -EINVAL;
+			goto err_free_netdev;
+		}
 	}
 
 	if (of_property_read_bool(port_node, "marvell,loopback"))
-- 
2.13.3
