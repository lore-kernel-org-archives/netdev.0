From: Daniel Mack <zonque@gmail.com>
Subject: Re: question about drivers/net/ethernet/ti/cpsw.c
Date: Tue, 02 Sep 2014 18:34:43 +0200
Message-ID: <5405F1A3.2050507@gmail.com>
References: <alpine.DEB.2.02.1408282118560.2226@localhost6.localdomain6> <20140901.181101.2132157946809255487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	George Cherian <george.cherian@ti.com>
To: David Miller <davem@davemloft.net>, julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:65486 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382AbaIBQer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:34:47 -0400
Received: by mail-wg0-f41.google.com with SMTP id l18so7280546wgh.24
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 09:34:46 -0700 (PDT)
In-Reply-To: <20140901.181101.2132157946809255487.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 09/02/2014 03:11 AM, David Miller wrote:
> From: Julia Lawall <julia.lawall@lip6.fr>
> Date: Thu, 28 Aug 2014 21:26:55 +0200 (CEST)
> 
>> I wonder if the following patch:
>>
>> commit aa1a15e2d9199711cdcc9399fdb22544ab835a83
>> Author: Daniel Mack <zonque@gmail.com>
>> Date:   Sat Sep 21 00:50:38 2013 +0530
>>
>> introduced a race condition in drivers/net/ethernet/ti/cpsw.c.  I was 
>> looking at an old version of the file (Linux 3.10), and it has
>>
>>  clean_irq_ret:
>>          for (i = 0; i < priv->num_irqs; i++)
>>                  free_irq(priv->irqs_table[i], priv);
>>
>> at the beginning of the cleanup code of the probe function (cpsw_probe).  
>> The above patch replaces request_irq by devm_request_irq and gets rid of 
>> the above cleanup code.  But that moves the stopping of the interrupts 
>> after the following code at the end of the function:
>>
>> free_netdev(priv->ndev);
>>
>> The interrupt handler (cpsw_interrupt) does reference priv->ndev:
>>
>> 	if (netif_running(priv->ndev)) {
>>                 napi_schedule(&priv->napi);
>>                 return IRQ_HANDLED;
>>         }
>>
>> so perhaps this could be a problem.  The same happens in the remove 
>> function.
> 
> It could definitely be a problem.
> 
> Probably it would be better for this device to request IRQs in open
> and release them in close like so many other networking drivers do.

I had a quick look and it seems there are more issues that I don't
understand. Mugunthan, can you help here?

We have

struct cpsw_priv {
	...
	/* snapshot of IRQ numbers */
	u32 irqs_table[4];
	u32 num_irqs;
	...
};

And the code in cpsw_probe() has:

while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
	for (i = res->start; i <= res->end; i++) {
		if (devm_request_irq(&pdev->dev, i, cpsw_interrupt, 0,
				     dev_name(&pdev->dev), priv)) {
			dev_err(priv->dev, "error attaching irq\n");
			goto clean_ale_ret;
		}
		priv->irqs_table[k] = i;
		priv->num_irqs = k + 1;
	}
	k++;
}

So, first of all, we miss a bounds check, because there could be more
than 4 resources. And second, I don't understand that if a resource
describes more than one IRQ (res->start != res->end), all of them are
claimed, but only the last one is stored in priv->irqs_table. The code
as it formerly stood would also only have free'd the last one and leak
the others. Are there actually board files that have more than one IRQ
denoted in one resource for this driver? For DT, at least, this can't
happen AFAICS.

Also, cpsw_probe_dual_emac() copies the interrupt indices from one slave
instance to another, so we need to claim them at probe time. As they can
only be claimed once, we can't request/free them in open/release
unfortunately.

I guess the best we can do for now is to revert the IRQ part of aa1a15e
("net: ethernet: cpsw: switch to devres allocations"), and add some
cleanups for boundary checks on top. I'll send patches in a second.

However, I only have a BBB here for tests right now, which is not
dual-mac. Could anyone give them a try?

Please tell me if I'm missing anything.


Thanks,
Daniel
