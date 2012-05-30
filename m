From: Lee Jones <lee.jones@linaro.org>
Subject: [PATCH 19/22] net/smsc911x: Repair broken failure paths
Date: Wed, 30 May 2012 12:47:37 +0800
Message-ID: <1338353260-10097-20-git-send-email-lee.jones@linaro.org>
References: <1338353260-10097-1-git-send-email-lee.jones@linaro.org>
Cc: Lee Jones <lee.jones@linaro.org>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
	linus.walleij@stericsson.com, grant.likely@secretlab.ca,
	cjb@laptop.org, broonie@opensource.wolfsonmicro.com,
	sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61499 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314Ab2E3Es5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 00:48:57 -0400
Received: by pbbrp8 with SMTP id rp8so6916834pbb.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 21:48:57 -0700 (PDT)
In-Reply-To: <1338353260-10097-1-git-send-email-lee.jones@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current failure paths attempt to free resources which we failed to request
and disable resources which we failed to enable ones. This leads to kernel
oops/panic. This patch does some simple re-ordering to prevent this from
happening.

Cc: netdev@vger.kernel.org
Signed-off-by: Lee Jones <lee.jones@linaro.org>
---
 drivers/net/ethernet/smsc/smsc911x.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index dab9c6f..1466e5d 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2390,11 +2390,11 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	retval = smsc911x_request_resources(pdev);
 	if (retval)
-		goto out_return_resources;
+		goto out_request_resources_fail;
 
 	retval = smsc911x_enable_resources(pdev);
 	if (retval)
-		goto out_disable_resources;
+		goto out_enable_resources_fail;
 
 	if (pdata->ioaddr == NULL) {
 		SMSC_WARN(pdata, probe, "Error smsc911x base address invalid");
@@ -2501,8 +2501,9 @@ out_free_irq:
 	free_irq(dev->irq, dev);
 out_disable_resources:
 	(void)smsc911x_disable_resources(pdev);
-out_return_resources:
+out_enable_resources_fail:
 	smsc911x_free_resources(pdev);
+out_request_resources_fail:
 	platform_set_drvdata(pdev, NULL);
 	iounmap(pdata->ioaddr);
 	free_netdev(dev);
-- 
1.7.9.5
