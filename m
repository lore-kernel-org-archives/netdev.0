From: dfoley <dfoley@telus.net>
Subject: smsc911x unloading crash
Date: Thu, 18 Dec 2008 14:50:34 -0800
Message-ID: <494AD3BA.9030602@telus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:56243 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681AbYLRWzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 17:55:07 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1LDRlm-0000gq-T5
	for netdev@vger.kernel.org; Thu, 18 Dec 2008 22:55:03 +0000
Received: from d75-157-1-250.bchsia.telus.net ([75.157.1.250])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 22:55:02 +0000
Received: from dfoley by d75-157-1-250.bchsia.telus.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 22:55:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am testing out the new smsc911x driver that is in the linux-next tree.
I get a crash when unloading the module. I've got this patch to fix it. 
I noticed that the dev_set_drvdata is clobbering the data when
the driver's ..._remove function calls dev = platform_get_drvdata(pdev);
I've back ported this to run on 2.6.27, so this patch may or
may not be needed. Sorry if it's a matter of not having the latest version.

diff -purN a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
--- a/drivers/net/smsc911x.c    2008-12-18 10:03:27.000000000 -0800
+++ b/drivers/net/smsc911x.c    2008-12-18 12:03:52.000000000 -0800
@@ -822,7 +822,6 @@ static int __devinit smsc911x_mii_init(s
                 pdata->mii_bus->irq[i] = PHY_POLL;

         pdata->mii_bus->parent = &pdev->dev;
-       dev_set_drvdata(&pdev->dev, &pdata->mii_bus);

         pdata->using_extphy = 0;

@@ -1872,7 +1871,7 @@ static int __devexit smsc911x_drv_remove
         res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
                                            "smsc911x-memory");
         if (!res)
-               platform_get_resource(pdev, IORESOURCE_MEM, 0);
+               res = platform_get_resource(pdev, IORESOURCE_MEM, 0);

         release_mem_region(res->start, res->end - res->start);

