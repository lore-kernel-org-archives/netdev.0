From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 1/3] usbnet: smsc95xx: fix suspend failure
Date: Fri, 22 Feb 2013 21:05:03 +0800
Message-ID: <1361538305-28418-2-git-send-email-ming.lei@canonical.com>
References: <1361538305-28418-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57541 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756489Ab3BVNGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 08:06:08 -0500
In-Reply-To: <1361538305-28418-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The three below functions:

	smsc95xx_enter_suspend0()
	smsc95xx_enter_suspend1()
	smsc95xx_enter_suspend2()

return > 0 in case of success, so they will cause smsc95xx_suspend()
to return > 0 and cause suspend failure.

The bug is introduced in commit 3b9f7d(smsc95xx: fix error handling
in suspend failure case).

Cc: <stable@vger.kernel.org>		[3.8]
Cc: Steve Glendinning <steve.glendinning@shawell.net>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/smsc95xx.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index ff4fa37..b2721bc 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1247,10 +1247,12 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 
 	/* read back PM_CTRL */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
+	if (ret < 0)
+		return ret;
 
 	pdata->suspend_flags |= SUSPEND_SUSPEND0;
 
-	return ret;
+	return 0;
 }
 
 static int smsc95xx_enter_suspend1(struct usbnet *dev)
@@ -1293,10 +1295,12 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 	val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	if (ret < 0)
+		return ret;
 
 	pdata->suspend_flags |= SUSPEND_SUSPEND1;
 
-	return ret;
+	return 0;
 }
 
 static int smsc95xx_enter_suspend2(struct usbnet *dev)
@@ -1313,10 +1317,12 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
 	val |= PM_CTL_SUS_MODE_2;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	if (ret < 0)
+		return ret;
 
 	pdata->suspend_flags |= SUSPEND_SUSPEND2;
 
-	return ret;
+	return 0;
 }
 
 static int smsc95xx_enter_suspend3(struct usbnet *dev)
-- 
1.7.9.5
