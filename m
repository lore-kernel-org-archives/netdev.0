From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 2/3] pci: bcm43xx avoid pci_find_device
Date: Mon, 05 Jun 2006 23:08:47 +0159
Message-ID: <44849D76.3020201@gmail.com>
References: <2005123213211@nnikde.cz> <20060605202007.B464FC7B73@atrey.karlin.mff.cuni.cz> <20060605205309.GA31061@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz, jgarzik@pobox.com,
	netdev@vger.kernel.org, mb@bu3sch.de, st3@riseup.net,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:46545 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750829AbWFEVJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 17:09:05 -0400
Received: by nf-out-0910.google.com with SMTP id c31so1867981nfb
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2006 14:09:03 -0700 (PDT)
To: Greg KH <greg@kroah.com>
In-Reply-To: <20060605205309.GA31061@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH napsal(a):
> On Mon, Jun 05, 2006 at 10:20:07PM +0200, Jiri Slaby wrote:
>> bcm43xx avoid pci_find_device
>>
>> Change pci_find_device to safer pci_get_device with support for more
>> devices.
>>
>> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
>>
>> ---
>> commit 4b73c16f5411d97360d5f26f292ffddeb670ff75
>> tree 6e43c8bd02498eb1ceec6bdc64277fa8408da9e2
>> parent d59f9ea8489749f59cd0c7333a4784cab964daa8
>> author Jiri Slaby <ku@bellona.localdomain> Mon, 05 Jun 2006 22:01:03 +0159
>> committer Jiri Slaby <ku@bellona.localdomain> Mon, 05 Jun 2006 22:01:03 +0159
>>
>>  drivers/net/wireless/bcm43xx/bcm43xx_main.c |   21 ++++++++++++++++-----
>>  1 files changed, 16 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> index 22b8fa6..d1a9975 100644
>> --- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> @@ -2133,6 +2133,13 @@ out:
>>  	return err;
>>  }
>>  
>> +#ifdef CONFIG_BCM947XX
>> +static struct pci_device_id bcm43xx_47xx_ids[] = {
>> +	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4324) },
>> +	{ 0 }
>> +};
>> +#endif
>> +
>>  static int bcm43xx_initialize_irq(struct bcm43xx_private *bcm)
>>  {
>>  	int res;
>> @@ -2142,11 +2149,15 @@ static int bcm43xx_initialize_irq(struct
>>  	bcm->irq = bcm->pci_dev->irq;
>>  #ifdef CONFIG_BCM947XX
>>  	if (bcm->pci_dev->bus->number == 0) {
>> -		struct pci_dev *d = NULL;
>> -		/* FIXME: we will probably need more device IDs here... */
>> -		d = pci_find_device(PCI_VENDOR_ID_BROADCOM, 0x4324, NULL);
>> -		if (d != NULL) {
>> -			bcm->irq = d->irq;
>> +		struct pci_dev *d;
>> +		struct pci_device_id *id;
>> +		for (id = bcm43xx_47xx_ids; id->vendor; id++) {
>> +			d = pci_get_device(id->vendor, id->device, NULL);
>> +			if (d != NULL) {
>> +				bcm->irq = d->irq;
>> +				pci_dev_put(d);
>> +				break;
>> +			}
> 
> This will not work if you have more than one of the same devices in the
> system.
> 
> Well, the original code will not either :(
> 
> Why not just use the proper pci interface?  Why poke around in another
> pci device to steal an irq, when that irq might not even be valid?
> (irqs are not valid until pci_enable_device() is called on them...)
Ok, this is some bus or something, not "real" device, so no pci probing or
anything else could be done. There is only one in the system, if any, since
CONFIG_BCM947XX is set for some sort of embedded systems, but this would be
uttered by somebody more responsible.

Should I call pci_enable_device anyway, I am confused now :/? And then, should I
hold the reference all time until ifdown for this "some kind of parent"?

thanks,
-- 
Jiri Slaby         www.fi.muni.cz/~xslaby
\_.-^-._   jirislaby@gmail.com   _.-^-._/
B67499670407CE62ACC8 22A032CC55C339D47A7E
