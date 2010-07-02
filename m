From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] usbnet: remove direct access to urb->status
Date: Fri, 2 Jul 2010 15:58:25 +0200
Message-ID: <201007021558.25774.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42024 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756247Ab0GBN7e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 09:59:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From a2e8da61490cba876b1b4814c4832822527c43dd Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oliver@neukum.org>
Date: Fri, 2 Jul 2010 15:51:55 +0200
Subject: [PATCH] usbnet: remove direct access to urb->status

USB drivers should not use urb->status directly because
it is scheduled to become a parameter. This does the conversion
for drivers/net/usb

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/cdc-phonet.c |    8 +++++---
 drivers/net/usb/ipheth.c     |   13 +++++++------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index dc94445..109751b 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -97,8 +97,9 @@ static void tx_complete(struct urb *req)
 	struct sk_buff *skb = req->context;
 	struct net_device *dev = skb->dev;
 	struct usbpn_dev *pnd = netdev_priv(dev);
+	int status = req->status;
 
-	switch (req->status) {
+	switch (status) {
 	case 0:
 		dev->stats.tx_bytes += skb->len;
 		break;
@@ -109,7 +110,7 @@ static void tx_complete(struct urb *req)
 		dev->stats.tx_aborted_errors++;
 	default:
 		dev->stats.tx_errors++;
-		dev_dbg(&dev->dev, "TX error (%d)\n", req->status);
+		dev_dbg(&dev->dev, "TX error (%d)\n", status);
 	}
 	dev->stats.tx_packets++;
 
@@ -150,8 +151,9 @@ static void rx_complete(struct urb *req)
 	struct page *page = virt_to_page(req->transfer_buffer);
 	struct sk_buff *skb;
 	unsigned long flags;
+	int status = req->status;
 
-	switch (req->status) {
+	switch (status) {
 	case 0:
 		spin_lock_irqsave(&pnd->rx_lock, flags);
 		skb = pnd->rx_skb;
diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 197c352..08e7b6a 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -193,7 +193,7 @@ static void ipheth_rcvbulk_callback(struct urb *urb)
 	case 0:
 		break;
 	default:
-		err("%s: urb status: %d", __func__, urb->status);
+		err("%s: urb status: %d", __func__, status);
 		return;
 	}
 
@@ -222,16 +222,17 @@ static void ipheth_rcvbulk_callback(struct urb *urb)
 static void ipheth_sndbulk_callback(struct urb *urb)
 {
 	struct ipheth_device *dev;
+	int status = urb->status;
 
 	dev = urb->context;
 	if (dev == NULL)
 		return;
 
-	if (urb->status != 0 &&
-	    urb->status != -ENOENT &&
-	    urb->status != -ECONNRESET &&
-	    urb->status != -ESHUTDOWN)
-		err("%s: urb status: %d", __func__, urb->status);
+	if (status != 0 &&
+	    status != -ENOENT &&
+	    status != -ECONNRESET &&
+	    status != -ESHUTDOWN)
+		err("%s: urb status: %d", __func__, status);
 
 	dev_kfree_skb_irq(dev->tx_skb);
 	netif_wake_queue(dev->net);
-- 
1.7.1

