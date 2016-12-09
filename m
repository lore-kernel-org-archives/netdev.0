From: Linus Walleij <linus.walleij@linaro.org>
Subject: [PATCH] net: smsc911x: back out silently on probe deferrals
Date: Fri,  9 Dec 2016 14:18:00 +0100
Message-ID: <1481289480-22096-1-git-send-email-linus.walleij@linaro.org>
Cc: Guenter Roeck <linux@roeck-us.net>,
        Jeremy Linton <jeremy.linton@arm.com>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>,
        Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35102 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932595AbcLINSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 08:18:18 -0500
Received: by mail-wm0-f41.google.com with SMTP id a197so26673639wmd.0
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 05:18:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to get a regulator we may get deferred and we see
this noise:

smsc911x 1b800000.ethernet-ebi2 (unnamed net_device) (uninitialized):
   couldn't get regulators -517

Then the driver continues anyway. Which means that the regulator
may not be properly retrieved and reference counted, and may be
switched off in case noone else is using it.

Fix this by returning silently on deferred probe and let the
system work it out.

Cc: Jeremy Linton <jeremy.linton@arm.com>
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/ethernet/smsc/smsc911x.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 86b7c04e3738..c492e4ffd9e7 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -442,9 +442,16 @@ static int smsc911x_request_resources(struct platform_device *pdev)
 	ret = regulator_bulk_get(&pdev->dev,
 			ARRAY_SIZE(pdata->supplies),
 			pdata->supplies);
-	if (ret)
+	if (ret) {
+		/*
+		 * Retry on deferrals, else just report the error
+		 * and try to continue.
+		 */
+		if (ret == -EPROBE_DEFER)
+			return ret;
 		netdev_err(ndev, "couldn't get regulators %d\n",
 				ret);
+	}
 
 	/* Request optional RESET GPIO */
 	pdata->reset_gpiod = devm_gpiod_get_optional(&pdev->dev,
-- 
2.7.4
