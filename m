From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 14/52] net: cxgb4vf: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 08:59:07 -0700
Message-ID: <5231E4CB.2060901@chelsio.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com> <005801ceaec1$6b8d3320$42a79960$%han@samsung.com> <5230A740.4020503@chelsio.com> <000001ceaf56$1cdf7d60$569e7820$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:42011
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754375Ab3ILP7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:59:24 -0400
In-Reply-To: <000001ceaf56$1cdf7d60$569e7820$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Ah, okay.  And I presume the same is true of the PCI Remove path. I 
wasn't aware of this but if it's the Linux pattern to let the 
surrounding support code do this work, then go for it.

   As I said, I'm something of a Mad Housewife when it comes to cleaning 
things up which were allocated/assigned in a particular routine.  
Basically I program like I drive, practising defensive programming ... :-)

Casey

On 09/11/13 18:19, Jingoo Han wrote:
> On Thursday, September 12, 2013 2:24 AM, Casey Leedom wrote:
>>     I agree that the redundant pci_set_drvdata(pdev, NULL) in
>> cxgb4vf_pci_probe() under the err_release_regions: label is unneeded,
>> but don't we need to NULL out the PCI Driver Data under the
>> err_free_adapter: label and also in cxgb4vf_pci_remove()?  Or is that
>> handled automatically in the PCI infrastructure code which calls the
>> Device Probe and Remove routines?  Mostly I was just being an
>> obsessively clean housewife assuming that we'd want to clean up these
>> references ...
>
> No, 'pci_set_drvdata(pdev, NULL) under err_free_adapter label' is not
> necessary.
>
> As you know, pci_set_drvdata(pdev, NULL) calls dev_set_drvdata() as below:
> pci_set_drvdata(pdev, NULL) is dev_set_drvdata(&pdev->dev, NULL).
>
> ./include/linux/pci.h
> 1504:static inline void pci_set_drvdata(struct pci_dev *pdev, void *data)
> 1505{
> 1506	dev_set_drvdata(&pdev->dev, data);
> 1507}
>
>
> However, when the driver goes to err_free_adapter label,
> The following sequence will be done.
>      kfree(adapter) -> .... -> return -ENOMEM;
>
> In this case,
> when probe() returns error value such as '-ENOMEM',
> really_probe() of driver core automatically calls 'dev_set_drvdata(dev, NULL)'
> as below:
>
> ./drivers/base/dd.c
> 303-probe_failed:
> 304	devres_release_all(dev);
> 305	driver_sysfs_remove(dev);
> 306	dev->driver = NULL;
> 307	dev_set_drvdata(dev, NULL);
>
> Thus, without 'pci_set_drvdata(pdev, NULL) under err_free_adapter label',
> dev_set_drvdata(dev, NULL) can be called.
>
> I already tested this with other drivers such as e1000e LAN card driver.
>
> Best regards,
> Jingoo Han
>
>
