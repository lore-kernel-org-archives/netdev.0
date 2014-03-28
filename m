From: Lucas Stach <dev@lynxeye.de>
Subject: [PATCH] net: fec: make sure to init MAC address
Date: Sat, 29 Mar 2014 00:19:24 +0100
Message-ID: <1396048764-3301-1-git-send-email-dev@lynxeye.de>
Cc: kernel@pengutronix.de, Lucas Stach <l.stach@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.lynxeye.de ([87.118.118.114]:43898 "EHLO lynxeye.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750864AbaC1X2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 19:28:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>

Though we made sure to acquire a valid MAC for
the netdevice we never actually programmed it
into the hardware.
So if the bootloader did not set the MAC,
network operation would only work if userspace
explicitly asked to transfer the MAC to hardware.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e19315eaf2dd..a8958cc12ef3 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1898,10 +1898,11 @@ fec_set_mac_address(struct net_device *ndev, void *p)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+	if (p) {
+		if (!is_valid_ether_addr(addr->sa_data))
+			return -EADDRNOTAVAIL;
+		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+	}
 
 	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
 		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24),
@@ -2000,6 +2001,8 @@ static int fec_enet_init(struct net_device *ndev)
 
 	/* Get the Ethernet address */
 	fec_get_mac(ndev);
+	/* make sure MAC we just acquired is programmed into the hw */
+	fec_set_mac_address(ndev, NULL);
 
 	/* init the tx & rx ring size */
 	fep->tx_ring_size = TX_RING_SIZE;
-- 
1.8.5.3
