From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 28/49] USBNET: cdc-phonet: prepare for enabling irq in complete()
Date: Sun, 18 Aug 2013 00:24:53 +0800
Message-ID: <1376756714-25479-29-git-send-email-ming.lei@canonical.com>
References: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Ming Lei <ming.lei@canonical.com>, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:52956 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571Ab3HQQ3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 12:29:52 -0400
In-Reply-To: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: netdev@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/cdc-phonet.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 7d78669..413ec32 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -99,6 +99,7 @@ static void tx_complete(struct urb *req)
 	struct net_device *dev = skb->dev;
 	struct usbpn_dev *pnd = netdev_priv(dev);
 	int status = req->status;
+	unsigned long flags;
 
 	switch (status) {
 	case 0:
@@ -115,10 +116,10 @@ static void tx_complete(struct urb *req)
 	}
 	dev->stats.tx_packets++;
 
-	spin_lock(&pnd->tx_lock);
+	spin_lock_irqsave(&pnd->tx_lock, flags);
 	pnd->tx_queue--;
 	netif_wake_queue(dev);
-	spin_unlock(&pnd->tx_lock);
+	spin_unlock_irqrestore(&pnd->tx_lock, flags);
 
 	dev_kfree_skb_any(skb);
 	usb_free_urb(req);
-- 
1.7.9.5
