From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net] dummy: Add ndo_uninit().
Date: Mon, 16 Apr 2012 08:26:01 +0900
Message-ID: <20120416082601.ac00a86d.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:44398 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180Ab2DOX0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 19:26:04 -0400
Received: by dake40 with SMTP id e40so6115404dak.11
        for <netdev@vger.kernel.org>; Sun, 15 Apr 2012 16:26:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In register_netdevice(), when ndo_init() is successful and later
some error occurred, ndo_uninit() will be called.
So dummy deivce is desirable to implement ndo_uninit() method
to free percpu stats for this case.
And, ndo_uninit() is also called along with dev->destructor() when
device is unregistered, so in order to prevent dev->dstats from
being freed twice, dev->destructor is modified to free_netdev().

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 drivers/net/dummy.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index d5c6d92..442d91a 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -107,14 +107,14 @@ static int dummy_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static void dummy_dev_free(struct net_device *dev)
+static void dummy_dev_uninit(struct net_device *dev)
 {
 	free_percpu(dev->dstats);
-	free_netdev(dev);
 }
 
 static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_init		= dummy_dev_init,
+	.ndo_uninit		= dummy_dev_uninit,
 	.ndo_start_xmit		= dummy_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= set_multicast_list,
@@ -128,7 +128,7 @@ static void dummy_setup(struct net_device *dev)
 
 	/* Initialize the device structure. */
 	dev->netdev_ops = &dummy_netdev_ops;
-	dev->destructor = dummy_dev_free;
+	dev->destructor = free_netdev;
 
 	/* Fill in device structure with ethernet-generic values. */
 	dev->tx_queue_len = 0;
-- 
1.7.8.5
