From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Fri, 19 May 2006 01:56:04 +0200
Message-ID: <446D0994.8090103@myri.com>
References: <20060517220218.GA13411@myri.com> <20060517220608.GD13411@myri.com> <200605180108.32949.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:44200 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751230AbWERX4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 May 2006 19:56:35 -0400
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200605180108.32949.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
>> +	for (sleep_total = 0;
>> +	     sleep_total < (15 * 1000) && response->result == 0xffffffff;
>> +	     sleep_total += 10) {
>> +		udelay(10);
>> +	}
>>     
>
> udelay does not sleep. If you want to sleep, use msleep instead.
>   

This place is actually the only one where we don't want to use msleep.
This function (myri10ge_send_cmd) might be called from various context
(spinlocked or not) and pass orders to the NIC whose processing time
depends a lot on the command. Of course, we don't have any place where a
long operation is passed from a spinlocked context :) But, we need the
tiny udelay granularity for the spinlocked case, and the long loop for
operations that are long to process in the NIC.

Concerning all the other places where you suggested to use msleep, you
were right.

> The __iomem variable need not be volatile.

As Roland pointed out, there was too many volatile in this code. We are
reworking this together with the sparse annotations.

>> +	printk("myri10ge: %s: %s IRQ %d, tx bndry %d, fw %s, WC %s\n",
>> +	       netdev->name, (mgp->msi_enabled ? "MSI" : "xPIC"),
>> +	       pdev->irq, mgp->tx.boundary, mgp->fw_name,
>> +	       (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
>> +
>>     
>
> missing printk level (KERN_DEBUG?). Could probably use dev_printk.
>   

When are we supposed to call dev_printk or not in such a driver ?

>> +#define MYRI10GE_PCI_VENDOR_MYRICOM 	0x14c1
>> +#define MYRI10GE_PCI_DEVICE_Z8E 	0x0008
>>     
>
> Shouldn't the vendor ID go to pci_ids.h?
>   

That's what I thought but i was told that the fashion these days is to
keep the IDs with the driver that uses them. I'll happy to move as long
as everybody agrees :)


Thanks a lot for all your comments,
Brice

