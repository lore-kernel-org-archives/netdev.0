From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 1/2] net: davinci_mdio: enable and disable clock
Date: Thu, 02 Aug 2012 22:17:56 +0200
Message-ID: <501AE074.8090906@gmail.com>
References: <1343936616-29318-1-git-send-email-zonque@gmail.com> <20120802195308.GZ6802@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090302070003030300010902"
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, paul@pwsan.com,
	devicetree-discuss@lists.ozlabs.org, koen@dominion.thruhere.net,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44311 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab2HBUSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 16:18:02 -0400
Received: by bkwj10 with SMTP id j10so4423026bkw.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 13:18:01 -0700 (PDT)
In-Reply-To: <20120802195308.GZ6802@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090302070003030300010902
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 02.08.2012 21:53, Russell King - ARM Linux wrote:
> On Thu, Aug 02, 2012 at 09:43:35PM +0200, Daniel Mack wrote:
>> Make the driver control the device clocks. Appearantly, the Davinci
>> platform probes this driver with the clock all powered up, but on OMAP,
>> this isn't the case.
> 
> Hmm, this looks like it could do with improvement, especially as we're
> moving everything over to a common clk API.
> 
> 1. This driver could do with clk_prepare()/clk_unprepare() calls.

Ok, done.

> 2. This driver should not be making the assumption that NULL means
>    it can avoid clk_* calls.  It should instead be using
> 	if (!IS_ERR(clk))

Well spotted. Amended patch below.


Thanks,
Daniel




--------------090302070003030300010902
Content-Type: text/x-patch;
 name="0001-net-davinci_mdio-prepare-and-unprepare-clocks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-net-davinci_mdio-prepare-and-unprepare-clocks.patch"

>From 57670e52d19218f897d835d25223bf4b4932252f Mon Sep 17 00:00:00 2001
From: Daniel Mack <zonque@gmail.com>
Date: Thu, 2 Aug 2012 21:24:36 +0200
Subject: [PATCH] net: davinci_mdio: prepare and unprepare clocks

Make the driver control the device clocks. Appearantly, the Davinci
platform probes this driver with the clock all powered up, but on OMAP,
this isn't the case.

While at it, also check for IS_ERR(data->clk) in the bail_out: label of
.probe().

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index cd7ee20..462f81d 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -332,6 +332,8 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 		goto bail_out;
 	}
 
+	clk_prepare(data->clk);
+
 	dev_set_drvdata(dev, data);
 	data->dev = dev;
 	spin_lock_init(&data->lock);
@@ -379,8 +381,11 @@ bail_out:
 	if (data->bus)
 		mdiobus_free(data->bus);
 
-	if (data->clk)
+	if (data->clk && !IS_ERR(data->clk)) {
+		clk_unprepare(data->clk);
 		clk_put(data->clk);
+	}
+
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
@@ -397,8 +402,11 @@ static int __devexit davinci_mdio_remove(struct platform_device *pdev)
 	if (data->bus)
 		mdiobus_free(data->bus);
 
-	if (data->clk)
+	if (data->clk) {
+		clk_unprepare(data->clk);
 		clk_put(data->clk);
+	}
+
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
@@ -427,6 +435,8 @@ static int davinci_mdio_suspend(struct device *dev)
 	data->suspended = true;
 	spin_unlock(&data->lock);
 
+	clk_unprepare(data->clk);
+
 	return 0;
 }
 
@@ -435,6 +445,8 @@ static int davinci_mdio_resume(struct device *dev)
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
 	u32 ctrl;
 
+	clk_prepare(data->clk);
+
 	spin_lock(&data->lock);
 	pm_runtime_put_sync(data->dev);
 
-- 
1.7.11.2


--------------090302070003030300010902--
