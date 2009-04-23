From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] gianfar: irq_of_parse_and_map() error unnoticed
Date: Thu, 23 Apr 2009 14:52:44 +0200
Message-ID: <49F0649C.8030908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:34256 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755315AbZDWMwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 08:52:47 -0400
Received: by ewy24 with SMTP id 24so484656ewy.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 05:52:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure which irq_of_parse_and_map() is used, but I found definitions here:

vi arch/microblaze/kernel/irq.c +23
vi arch/powerpc/kernel/irq.c +727
vi arch/sparc/kernel/of_device_32.c +33
vi arch/sparc/kernel/of_device_64.c +59

They either return 0 or NO_IRQ - either defined 0, -1, 255 or INT_MAX.
------------------------------>8-------------8<---------------------------------
priv->interruptTransmit, -Receive and -Error are unsigned, so the error path
wasn't taken when irq_of_parse_and_map() returned an incorrect irq.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com> 
---
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b2c4967..e30d158 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -203,9 +203,12 @@ static int gfar_of_init(struct net_device *dev)
 
 		priv->interruptError = irq_of_parse_and_map(np, 2);
 
-		if (priv->interruptTransmit < 0 ||
-				priv->interruptReceive < 0 ||
-				priv->interruptError < 0) {
+		if (priv->interruptTransmit == 0 ||
+				priv->interruptTransmit > 254 ||
+				priv->interruptReceive == 0 ||
+				priv->interruptReceive > 254 ||
+				priv->interruptError == 0 ||
+				priv->interruptReceive > 254) {
 			err = -EINVAL;
 			goto err_out;
 		}
