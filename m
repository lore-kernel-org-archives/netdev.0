From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] net: davinci_emac: Replace devm_request_irq with
 request_irq
Date: Fri, 07 Mar 2014 12:42:28 +0100
Message-ID: <35CC5396F7326DBE44C9C624@[172.22.2.41]>
References: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
 <20140306.165736.154818699714315258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source@linux.davincidsp.com,
	f.fainelli@gmail.com, netdev@vger.kernel.org, jon@ringle.org
To: David Miller <davem@davemloft.net>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:65522 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbaCGLmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 06:42:31 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so2278799ead.38
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 03:42:30 -0800 (PST)
In-Reply-To: <20140306.165736.154818699714315258.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

--On March 06, 2014 16:57 -0500 David Miller <davem@davemloft.net> wrote:

> From: Christian Riesch <christian.riesch@omicron.at>
> Date: Wed, 5 Mar 2014 11:25:28 +0100
>
>> @@ -1641,7 +1640,15 @@ static int emac_dev_open(struct net_device *ndev)
>>
>>  rollback:
>>
>> -	dev_err(emac_dev, "DaVinci EMAC: devm_request_irq() failed");
>> +	dev_err(emac_dev, "DaVinci EMAC: request_irq() failed");
>> +
>> +	for (q = k; k >= 0; k--) {
>> +		for (m = i; m >= res->start; m--)
>> +			free_irq(m, ndev);
>> +		res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
>> +		m = res->end;
            ^^^^
So this should definitely read "i = res->end;".

>> +	}
>
> This final assignment in the loop of 'm' is unused?
>
> The inner for() loop always started with "m = i;"

But it is more than just that. The entire rollback mechanism of 
emac_dev_open is a mess. It just won't work.

1) Freeing the interrupts. Currently, the code tries to do a 
platform_get_resource(priv->pdev, IORESOURCE_IRQ, -1) in its last 
iteration. To make this work, the code should be something like

for (q = k; q >= 0; q--) {
	res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
	if (q != k)
		i = res->end;

	for (m = i; m >= res->start; m--)
		free_irq(m, ndev);
}		

2) Wrong order of err: and rollback: labels. Currently the function does 
something like this:

	pm_runtime_get
	request irq
		if requesting irqs fails, goto rollback
	setup phy
		if phy setup fails, goto err
	return 0

rollback:
	free irqs
err:
	pm_runtime_put

So if PHY initialization fails, the IRQs are never freed. So rollback and 
err must be exchanged, and some additonal code must be added to keep the 
correct values of k and i for rollback.

3) RX DMA descriptors are not freed in case of an error: Right before 
requesting the irqs, the function creates DMA descriptors for the RX 
channel. These RX descriptors are never freed when we jump to either 
rollback or err. And I think there is also no way to free them as long as 
cpdma_ctlr_start() has not been called (which is done between requesting 
irqs and phy setup in the code).

Problems 1+2 are easy to solve. Prabhakar, Mugunthan, any ideas for 3? I 
think cpsw_ndo_start() in cpsw.c has the same problem. It will also try to 
call cpdma_ctlr_stop in error handling before cpdma_ctlr_start was called 
in some cases.

Regards, Christian
