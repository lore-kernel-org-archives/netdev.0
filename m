From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/macb: manage carrier state with call to netif_carrier_{on|off}()
Date: Wed, 4 Jul 2012 11:14:13 +0200
Message-ID: <1341393253-6531-1-git-send-email-nicolas.ferre@atmel.com>
References: <1341361835.2839.21.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, <shemminger@vyatta.com>,
	<linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:25589 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073Ab2GDJOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 05:14:21 -0400
In-Reply-To: <1341361835.2839.21.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OFF carrier state is setup in probe() open() and suspend() functions.
The carrier ON state is managed in macb_handle_link_change().

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Hi,

This patch follows the discussion about IPv6 and macb interface
("ADDRCONF(NETDEV_UP): eth0: link is not ready" with IPv6)
It may not address all aspects of the discussion, so please do comments...

I am still wondering if netif_carrier_off() is needed in macb_probe() *after*
the call to register_netdev() in addition to its inclusion in the open()
function. As I saw it in sevral drivers, I kept it.

I have tested several suspend/resume loops, and I think that just calling
netif_carrier_off() in suspend() function is sufficient: am I right?

Thanks for your help,
Best regards,

 drivers/net/ethernet/cadence/macb.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 1466bc4..033064b 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -179,13 +179,16 @@ static void macb_handle_link_change(struct net_device *dev)
 	spin_unlock_irqrestore(&bp->lock, flags);
 
 	if (status_change) {
-		if (phydev->link)
+		if (phydev->link) {
+			netif_carrier_on(dev);
 			netdev_info(dev, "link up (%d/%s)\n",
 				    phydev->speed,
 				    phydev->duplex == DUPLEX_FULL ?
 				    "Full" : "Half");
-		else
+		} else {
+			netif_carrier_off(dev);
 			netdev_info(dev, "link down\n");
+		}
 	}
 }
 
@@ -1033,6 +1036,9 @@ static int macb_open(struct net_device *dev)
 
 	netdev_dbg(bp->dev, "open\n");
 
+	/* carrier starts down */
+	netif_carrier_off(dev);
+
 	/* if the phy is not yet register, retry later*/
 	if (!bp->phy_dev)
 		return -EAGAIN;
@@ -1406,6 +1412,8 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dev);
 
+	netif_carrier_off(dev);
+
 	netdev_info(dev, "Cadence %s at 0x%08lx irq %d (%pM)\n",
 		    macb_is_gem(bp) ? "GEM" : "MACB", dev->base_addr,
 		    dev->irq, dev->dev_addr);
@@ -1469,6 +1477,7 @@ static int macb_suspend(struct platform_device *pdev, pm_message_t state)
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct macb *bp = netdev_priv(netdev);
 
+	netif_carrier_off(netdev);
 	netif_device_detach(netdev);
 
 	clk_disable(bp->hclk);
-- 
1.7.10
