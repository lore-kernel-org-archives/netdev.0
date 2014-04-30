From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v2 for v3.15] net: mvmdio: Check for a valid interrupt
 instead of an error
Date: Wed, 30 Apr 2014 21:40:57 +0200
Message-ID: <536151C9.4090802@gmail.com>
References: <1398875331-18925-1-git-send-email-ezequiel.garcia@free-electrons.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:34229 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964977AbaD3TlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 15:41:03 -0400
Received: by mail-ee0-f46.google.com with SMTP id t10so1692673eei.5
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 12:41:01 -0700 (PDT)
In-Reply-To: <1398875331-18925-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2014 06:28 PM, Ezequiel Garcia wrote:
> The following commit:
> 
> commit 9ec36cafe43bf835f8f29273597a5b0cbc8267ef
> Author: Rob Herring <robh@kernel.org>
> Date:   Wed Apr 23 17:57:41 2014 -0500
> 
>     of/irq: do irq resolution in platform_get_irq
> 
> changed platform_get_irq() which now returns EINVAL and EPROBE_DEFER,
> in addition to ENXIO. If there's no interrupt for mvmdio, platform_get_irq()
> returns EINVAL, but we currently check only for ENXIO.
> 
> Fix this by looking for a positive integer, which is the proper way of
> validating a virtual interrupt number.
> 
> While at it, add a proper handling for the deferral probe case.
> 
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Reviewed-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Thanks!

> ---
> Changes from v1: Handle the deferral probe as well.
> 
>  drivers/net/ethernet/marvell/mvmdio.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
> index b161a52..9d5ced2 100644
> --- a/drivers/net/ethernet/marvell/mvmdio.c
> +++ b/drivers/net/ethernet/marvell/mvmdio.c
> @@ -232,7 +232,7 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  		clk_prepare_enable(dev->clk);
>  
>  	dev->err_interrupt = platform_get_irq(pdev, 0);
> -	if (dev->err_interrupt != -ENXIO) {
> +	if (dev->err_interrupt > 0) {
>  		ret = devm_request_irq(&pdev->dev, dev->err_interrupt,
>  					orion_mdio_err_irq,
>  					IRQF_SHARED, pdev->name, dev);
> @@ -241,6 +241,9 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  
>  		writel(MVMDIO_ERR_INT_SMI_DONE,
>  			dev->regs + MVMDIO_ERR_INT_MASK);
> +
> +	} else if (dev->err_interrupt == -EPROBE_DEFER) {
> +		return -EPROBE_DEFER;
>  	}
>  
>  	mutex_init(&dev->lock);
> 
