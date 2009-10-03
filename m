From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] ibmtr: possible Read buffer overflow?
Date: Sat, 03 Oct 2009 23:26:55 +0200
Message-ID: <4AC7C19F.2080800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:63472 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754969AbZJCVTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 17:19:02 -0400
Received: by ewy7 with SMTP id 7so2365591ewy.17
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2009 14:18:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent read outside array bounds.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Is this maybe required?

build tested

diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 525bbc5..6a3c751 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -1143,9 +1143,16 @@ static void dir_open_adapter (struct net_device *dev)
                 } else {
 			char **prphase = printphase;
 			char **prerror = printerror;
+			int pnr = err / 16 - 1;
+			int enr = err % 16 - 1;
 			DPRINTK("TR Adapter misc open failure, error code = ");
-			printk("0x%x, Phase: %s, Error: %s\n",
-				err, prphase[err/16 -1], prerror[err%16 -1]);
+			if (pnr < 0 || pnr >= ARRAY_SIZE(printphase) ||
+					enr < 0 ||
+					enr >= ARRAY_SIZE(printerror))
+				printk("0x%x, invalid Phase/Error.", err);
+			else
+				printk("0x%x, Phase: %s, Error: %s\n", err,
+						prphase[pnr], prerror[enr]);
 			printk(" retrying after %ds delay...\n",
 					TR_RETRY_INTERVAL/HZ);
                 }
