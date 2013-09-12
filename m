From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 14/52] net: cxgb4vf: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 10:19:22 +0900
Message-ID: <000001ceaf56$1cdf7d60$569e7820$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
 <005801ceaec1$6b8d3320$42a79960$%han@samsung.com>
 <5230A740.4020503@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Casey Leedom' <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:19657 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab3ILBTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 21:19:24 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSZ000DFNNXJ360@mailout1.samsung.com> for
 netdev@vger.kernel.org; Thu, 12 Sep 2013 10:19:23 +0900 (KST)
In-reply-to: <5230A740.4020503@chelsio.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, September 12, 2013 2:24 AM, Casey Leedom wrote:
> 
>    I agree that the redundant pci_set_drvdata(pdev, NULL) in
> cxgb4vf_pci_probe() under the err_release_regions: label is unneeded,
> but don't we need to NULL out the PCI Driver Data under the
> err_free_adapter: label and also in cxgb4vf_pci_remove()?  Or is that
> handled automatically in the PCI infrastructure code which calls the
> Device Probe and Remove routines?  Mostly I was just being an
> obsessively clean housewife assuming that we'd want to clean up these
> references ...


No, 'pci_set_drvdata(pdev, NULL) under err_free_adapter label' is not
necessary.

As you know, pci_set_drvdata(pdev, NULL) calls dev_set_drvdata() as below:
pci_set_drvdata(pdev, NULL) is dev_set_drvdata(&pdev->dev, NULL).

./include/linux/pci.h
1504:static inline void pci_set_drvdata(struct pci_dev *pdev, void *data)
1505{
1506	dev_set_drvdata(&pdev->dev, data);
1507}


However, when the driver goes to err_free_adapter label,
The following sequence will be done.
    kfree(adapter) -> .... -> return -ENOMEM;

In this case,
when probe() returns error value such as '-ENOMEM',
really_probe() of driver core automatically calls 'dev_set_drvdata(dev, NULL)'
as below:

./drivers/base/dd.c
303-probe_failed:
304	devres_release_all(dev);
305	driver_sysfs_remove(dev);
306	dev->driver = NULL;
307	dev_set_drvdata(dev, NULL);

Thus, without 'pci_set_drvdata(pdev, NULL) under err_free_adapter label',
dev_set_drvdata(dev, NULL) can be called.

I already tested this with other drivers such as e1000e LAN card driver.

Best regards,
Jingoo Han
