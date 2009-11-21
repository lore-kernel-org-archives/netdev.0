From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] Au1x00: fix crash when trying register_netdev()
Date: Sat, 21 Nov 2009 06:07:35 +0300
Message-ID: <1258772855-9141-1-git-send-email-a.beregalov@gmail.com>
Cc: netdev@vger.kernel.org, alohre@gmail.com,
	Alexander Beregalov <a.beregalov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:46053 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766AbZKUDNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 22:13:36 -0500
Received: by fxm21 with SMTP id 21so4330403fxm.21
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 19:13:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Lohre reported that the driver crashes when trying
to register_netdev(), he sugessted to move dev->netdev_ops initialization
before calling register_netdev(), it worked for him.

Reported-by: Andreas Lohre <alohre@gmail.com>
Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

David, please send it to stable@ for 2.6.31


 drivers/net/au1000_eth.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index ce6f1ac..3f4b430 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1088,7 +1088,14 @@ static struct net_device * au1000_probe(int port_num)
 		return NULL;
 	}
 
-	if ((err = register_netdev(dev)) != 0) {
+	dev->base_addr = base;
+	dev->irq = irq;
+	dev->netdev_ops = &au1000_netdev_ops;
+	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
+	dev->watchdog_timeo = ETH_TX_TIMEOUT;
+
+	err = register_netdev(dev);
+	if (err != 0) {
 		printk(KERN_ERR "%s: Cannot register net device, error %d\n",
 				DRV_NAME, err);
 		free_netdev(dev);
@@ -1209,12 +1216,6 @@ static struct net_device * au1000_probe(int port_num)
 		aup->tx_db_inuse[i] = pDB;
 	}
 
-	dev->base_addr = base;
-	dev->irq = irq;
-	dev->netdev_ops = &au1000_netdev_ops;
-	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
-	dev->watchdog_timeo = ETH_TX_TIMEOUT;
-
 	/*
 	 * The boot code uses the ethernet controller, so reset it to start
 	 * fresh.  au1000_init() expects that the device is in reset state.
-- 
1.6.5.3

