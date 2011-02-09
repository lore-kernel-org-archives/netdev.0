From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH 1/2] atmel/macb: fix device name when SOFT/HARD_IRQ enabled
Date: Wed, 09 Feb 2011 16:41:38 +0300
Message-ID: <4D529992.7050502@ru.mvista.com>
References: <1297255416-6920-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Paul Chavent <paul.chavent@fnac.net>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63415 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755005Ab1BINm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 08:42:56 -0500
Received: by bwz15 with SMTP id 15so964699bwz.19
        for <netdev@vger.kernel.org>; Wed, 09 Feb 2011 05:42:55 -0800 (PST)
In-Reply-To: <1297255416-6920-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09-02-2011 15:43, Jean-Christophe PLAGNIOL-VILLARD wrote:

> From: Paul Chavent<paul.chavent@fnac.net>

> When listing processes on a system with SOFT/HARD_IRQ enabled,
> the name of the ethernet device is [irq/eth%d] (instead of [irq/eth0] for example).

> This patch call the request_irq function after having initialized the name of the device.

> Signed-off-by: Paul Chavent<paul.chavent@fnac.net>
> Signed-off-by: Nicolas Ferre<nicolas.ferre@atmel.com>
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD<plagnioj@jcrosoft.com>
[...]

> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index f69e73e..d642e08 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
[...]
> @@ -1219,13 +1209,23 @@ static int __init macb_probe(struct platform_device *pdev)
>   	err = register_netdev(dev);
>   	if (err) {
>   		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> -		goto err_out_free_irq;
> +		goto err_out_iounmap;
>   	}
>
> -	if (macb_mii_init(bp) != 0) {
> +	dev->irq = platform_get_irq(pdev, 0);

    platform_get_irq() can fail...

> +	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
> +			  dev->name, dev);
> +	if (err) {
> +		printk(KERN_ERR
> +		       "%s: Unable to request IRQ %d (error %d)\n",
> +		       dev->name, dev->irq, err);
>   		goto err_out_unregister_netdev;
>   	}
>
> +	if (macb_mii_init(bp) != 0) {
> +		goto err_out_free_irq;
> +	}

    {} not needed here. I think checkpatch.pl should notice this.

WBR, Sergei
