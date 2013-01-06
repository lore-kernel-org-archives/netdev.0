From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] ethoc: fix mac address set
Date: Sun,  6 Jan 2013 14:25:45 +0100
Message-ID: <1357478745-19923-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:40539 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755572Ab3AFNZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 08:25:52 -0500
Received: by mail-ee0-f54.google.com with SMTP id c13so9090851eek.13
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2013 05:25:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function ethoc_set_mac_address() was incorrectly using passed pointer as
pointer to address, that is not correct.
Struct sockaddr have to be be used here.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/ethoc.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index b93062d..b51c81a 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -771,20 +771,24 @@ static int ethoc_config(struct net_device *dev, struct ifmap *map)
 	return -ENOSYS;
 }
 
-static int ethoc_set_mac_address(struct net_device *dev, void *addr)
+static void ethoc_do_set_mac_address(struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
-	u8 *mac = (u8 *)addr;
-
-	if (!is_valid_ether_addr(mac))
-		return -EADDRNOTAVAIL;
+	unsigned char *mac = dev->dev_addr;
 
 	ethoc_write(priv, MAC_ADDR0, (mac[2] << 24) | (mac[3] << 16) |
 				     (mac[4] <<  8) | (mac[5] <<  0));
 	ethoc_write(priv, MAC_ADDR1, (mac[0] <<  8) | (mac[1] <<  0));
+}
 
-	memcpy(dev->dev_addr, mac, ETH_ALEN);
+static int ethoc_set_mac_address(struct net_device *dev, void *p)
+{
+	const struct sockaddr *addr = p;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	ethoc_do_set_mac_address(dev);
 	return 0;
 }
 
@@ -1060,11 +1064,7 @@ static int ethoc_probe(struct platform_device *pdev)
 		random_mac = true;
 	}
 
-	ret = ethoc_set_mac_address(netdev, netdev->dev_addr);
-	if (ret) {
-		dev_err(&netdev->dev, "failed to set MAC address\n");
-		goto error;
-	}
+	ethoc_do_set_mac_address(netdev);
 
 	if (random_mac)
 		netdev->addr_assign_type = NET_ADDR_RANDOM;
-- 
1.8.1
