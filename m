From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v5 01/13] net: mv643xx_eth: use phy_disconnect instead of phy_detach
Date: Wed, 29 May 2013 21:32:43 +0200
Message-ID: <1369855975-21489-2-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369855975-21489-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:40778 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966191Ab3E2TdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 15:33:09 -0400
In-Reply-To: <1369855975-21489-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a separated mdio bus driver with mvmdio, phy_detach on network device
removal will not stop the phy and finally lead to NULL pointer dereference
in mvmdio due to non-existent network device. Use phy_disconnect instead
to properly stop phy device from accessing network device prior removal of
the network device.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Note: I observed this behavior when removing a modular mv643xx_eth driver
after attaching it to a phy handled by (also modular) mvmdio. The mvmdio
conversion has been done in

commit c3a07134e6aa5b93a37f72ffa3d11fadf72bf757
 ("mv643xx_eth: convert to use the Marvell Orion MDIO driver")

and should go back any -stable version with that commit (propably only 3.9)

Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 2ad1494..2480a2f 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2805,7 +2805,7 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 
 	unregister_netdev(mp->dev);
 	if (mp->phy != NULL)
-		phy_detach(mp->phy);
+		phy_disconnect(mp->phy);
 	cancel_work_sync(&mp->tx_timeout_task);
 
 	if (!IS_ERR(mp->clk))
-- 
1.7.10.4
