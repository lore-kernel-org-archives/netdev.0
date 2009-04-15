From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 3/5] au1000: convert to net_device_ops
Date: Wed, 15 Apr 2009 08:30:23 +0400
Message-ID: <1239769825-12413-3-git-send-email-a.beregalov@gmail.com>
References: <1239769825-12413-1-git-send-email-a.beregalov@gmail.com>
 <1239769825-12413-2-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:53338 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbZDOEaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 00:30:39 -0400
Received: by bwz17 with SMTP id 17so2712604bwz.37
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 21:30:36 -0700 (PDT)
In-Reply-To: <1239769825-12413-2-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/au1000_eth.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 4274e4a..d58c105 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1004,12 +1004,12 @@ static void au1000_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static void set_rx_mode(struct net_device *dev)
+static void au1000_multicast_list(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
-		printk("%s: set_rx_mode: flags=%x\n", dev->name, dev->flags);
+		printk("%s: au1000_multicast_list: flags=%x\n", dev->name, dev->flags);
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		aup->mac->control |= MAC_PROMISCUOUS;
@@ -1047,6 +1047,18 @@ static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(aup->phy_dev, if_mii(rq), cmd);
 }
 
+static const struct net_device_ops au1000_netdev_ops = {
+	.ndo_open		= au1000_open,
+	.ndo_stop		= au1000_close,
+	.ndo_start_xmit		= au1000_tx,
+	.ndo_set_multicast_list	= au1000_multicast_list,
+	.ndo_do_ioctl		= au1000_ioctl,
+	.ndo_tx_timeout		= au1000_tx_timeout,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 static struct net_device * au1000_probe(int port_num)
 {
 	static unsigned version_printed = 0;
@@ -1197,13 +1209,8 @@ static struct net_device * au1000_probe(int port_num)
 
 	dev->base_addr = base;
 	dev->irq = irq;
-	dev->open = au1000_open;
-	dev->hard_start_xmit = au1000_tx;
-	dev->stop = au1000_close;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &au1000_ioctl;
+	dev->netdev_ops = &au1000_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
-	dev->tx_timeout = au1000_tx_timeout;
 	dev->watchdog_timeo = ETH_TX_TIMEOUT;
 
 	/*
-- 
1.6.2.3

