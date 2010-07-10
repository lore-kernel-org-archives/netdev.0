From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 1/3] jazzsonic: free irq if sonic_open() fails
Date: Sat, 10 Jul 2010 15:00:35 +0400
Message-ID: <1278759635-7654-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, Julia Lawall <julia@diku.dk>,
	Finn Thain <fthain@telegraphics.com.au>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45045 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab0GJLBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 07:01:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jazzsonic_open() doesn't check sonic_open() return code. If it is error
we must free requested IRQ.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/jazzsonic.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 3e6aaf9..949c1f9 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -82,11 +82,20 @@ static unsigned short known_revisions[] =
 
 static int jazzsonic_open(struct net_device* dev)
 {
-	if (request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED, "sonic", dev)) {
-		printk(KERN_ERR "%s: unable to get IRQ %d.\n", dev->name, dev->irq);
-		return -EAGAIN;
+	int retval;
+
+	retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
+				"sonic", dev);
+	if (retval) {
+		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
+				dev->name, dev->irq);
+		return retval;
 	}
-	return sonic_open(dev);
+
+	retval = sonic_open(dev);
+	if (retval)
+		free_irq(dev->irq, dev);
+	return retval;
 }
 
 static int jazzsonic_close(struct net_device* dev)
-- 
1.7.0.4

