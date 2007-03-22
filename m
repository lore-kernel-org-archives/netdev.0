From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] Fix crash in tg3 when using irqpoll
Date: Thu, 22 Mar 2007 14:04:27 -0800
Message-ID: <1174601067.9753.42.camel@dell>
References: <20070322204635.GA27152@strauss.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Bernhard Walle" <bwalle@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3454 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932234AbXCVV1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 17:27:45 -0400
In-Reply-To: <20070322204635.GA27152@strauss.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-22 at 21:46 +0100, Bernhard Walle wrote:

> 
> This patch makes sure that even the tr32() instruction in the interrupt handler
> is not executed which accesses PCI memory. Accessing PCI memory when
> pci_restore_state() is called is a bad idea because that function modifies
> the BARs of the PCI device.

It is not caused by the BAR as it doesn't get changed in this case.  The
pci_restore_state() call is to restore the memory enable bit in the PCI
command register.  The tr32() call in tg3_interrupt() will cause a
master abort if it is called before the memory enable bit has been
restored.

> --- mainline-msi-init.orig/drivers/net/tg3.c
> +++ mainline-msi-init/drivers/net/tg3.c
> @@ -3561,7 +3561,10 @@ static irqreturn_t tg3_interrupt(int irq
>  	struct net_device *dev = dev_id;
>  	struct tg3 *tp = netdev_priv(dev);
>  	struct tg3_hw_status *sblk = tp->hw_status;
> -	unsigned int handled = 1;
> +	unsigned int handled = 0;
> +
> +	if (tg3_irq_sync(tp))
> +		goto out;


This will break other things.  When we disable interrupts, we set the
irq_sync flag but allow one more interrupt to be generated.  The irq
handler will simply mask off the interrupt when it sees the irq_sync
flag.  With the above change, the irq handler can no longer mask off
this trailing interrupt and you may get screaming interrupts as a
result.

Thanks for reporting this.  I'll try to come up with a good solution.



