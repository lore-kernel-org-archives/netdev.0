From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 2/2] net: tilegx: Use helpers from linux/etherdevice.h to check/set MAC
Date: Tue, 27 May 2014 14:04:05 +0200
Message-ID: <1401192245-26260-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:36769 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751916AbaE0MEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 08:04:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use is_valid_ether_addr() to check for a valid MAC address to set on the
device.  This will also check for the device address being multicast,
which would have been possible previously.

Also use ether_addr_copy() instead of a manual memcpy() to set the
address.

Furthermore, get rid of a redundant assignment of dev->addr_len. This is
already set by ether_setup() which is called in tile_net_setup().

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/tile/tilegx.c |   17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 0db40de..6e978f8 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2192,7 +2192,6 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 {
 	int ret;
 	int i;
-	int nz_addr = 0;
 	struct net_device *dev;
 	struct tile_net_priv *priv;
 
@@ -2219,18 +2218,14 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 	init_ptp_dev(priv);
 
 	/* Get the MAC address and set it in the device struct; this must
-	 * be done before the device is opened.  If the MAC is all zeroes,
-	 * we use a random address, since we're probably on the simulator.
+	 * be done before the device is opened.  If the MAC is all zeroes or a
+	 * multicast address, we use a random address, since we're probably on
+	 * the simulator.
 	 */
-	for (i = 0; i < 6; i++)
-		nz_addr |= mac[i];
-
-	if (nz_addr) {
-		memcpy(dev->dev_addr, mac, ETH_ALEN);
-		dev->addr_len = 6;
-	} else {
+	if (is_valid_ether_addr(mac))
+		ether_addr_copy(dev->dev_addr, mac);
+	else
 		eth_hw_addr_random(dev);
-	}
 
 	/* Register the network device. */
 	ret = register_netdev(dev);
-- 
1.7.9.5
