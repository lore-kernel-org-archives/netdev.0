From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH v2 2/2] net: tile: Use helpers from linux/etherdevice.h to check/set MAC
Date: Fri, 30 May 2014 09:47:17 +0200
Message-ID: <1401436037-4993-1-git-send-email-tklauser@distanz.ch>
References: <1401192245-26260-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:39034 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932568AbaE3Hrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 03:47:31 -0400
In-Reply-To: <1401192245-26260-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use is_zero_ether_addr() to check for the MAC address being all zeros instead of
open coding the check.

Also use ether_addr_copy() instead of a manual memcpy() to set the
netdev->dev_addr.

Furthermore, get rid of a redundant assignment of netdev->addr_len. This is
already set by ether_setup() which is called in tile_net_setup().

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>

---
v2: only check for zero address

 drivers/net/ethernet/tile/tilegx.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 0db40de..14389f8 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2192,7 +2192,6 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 {
 	int ret;
 	int i;
-	int nz_addr = 0;
 	struct net_device *dev;
 	struct tile_net_priv *priv;
 
@@ -2222,15 +2221,10 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 	 * be done before the device is opened.  If the MAC is all zeroes,
 	 * we use a random address, since we're probably on the simulator.
 	 */
-	for (i = 0; i < 6; i++)
-		nz_addr |= mac[i];
-
-	if (nz_addr) {
-		memcpy(dev->dev_addr, mac, ETH_ALEN);
-		dev->addr_len = 6;
-	} else {
+	if (!is_zero_ether_addr(mac))
+		ether_addr_copy(dev->dev_addr, mac);
+	else
 		eth_hw_addr_random(dev);
-	}
 
 	/* Register the network device. */
 	ret = register_netdev(dev);
-- 
1.7.9.5
