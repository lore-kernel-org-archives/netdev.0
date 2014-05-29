From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v3] mrf24j40: added device
 managed APIs
Date: Thu, 29 May 2014 13:06:20 +0200
Message-ID: <20140529110618.GA12439@omega>
References: <1401359258-7247-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alan@signal11.us, Varka Bhadram <varkab@cdac.in>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	alex.aing@gmail.com
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:63455 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757274AbaE2LGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 07:06:30 -0400
Received: by mail-wi0-f177.google.com with SMTP id f8so386262wiw.4
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 04:06:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1401359258-7247-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Varka,

On Thu, May 29, 2014 at 03:57:38PM +0530, Varka Bhadram wrote:
> changes since v2:
> 1. removed unwanted label implementation. 
> 
> When we use devm_* APIs ,probe() failed also the memory
> will be freed automatically. Thanks to Alex
> 
> -Varka Bhadram
> 
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ieee802154/mrf24j40.c |   30 ++++++++++++------------------
>  1 file changed, 12 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
> index 78a6552..f2b1345 100644
> --- a/drivers/net/ieee802154/mrf24j40.c
> +++ b/drivers/net/ieee802154/mrf24j40.c
> @@ -618,12 +618,12 @@ static int mrf24j40_probe(struct spi_device *spi)
>  
>  	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
>  
> -	devrec = kzalloc(sizeof(struct mrf24j40), GFP_KERNEL);
> +	devrec = devm_kzalloc(&spi->dev, sizeof(struct mrf24j40), GFP_KERNEL);
>  	if (!devrec)
> -		goto err_devrec;
> -	devrec->buf = kzalloc(3, GFP_KERNEL);
> +		goto err_ret;
> +	devrec->buf = devm_kzalloc(&spi->dev, 3, GFP_KERNEL);
>  	if (!devrec->buf)
> -		goto err_buf;
> +		goto err_ret;
>  
>  	spi->mode = SPI_MODE_0; /* TODO: Is this appropriate for right here? */
>  	if (spi->max_speed_hz > MAX_SPI_SPEED_HZ)
> @@ -676,12 +676,13 @@ static int mrf24j40_probe(struct spi_device *spi)
>  	val &= ~0x3; /* Clear RX mode (normal) */
>  	write_short_reg(devrec, REG_RXMCR, val);
>  
> -	ret = request_threaded_irq(spi->irq,
> -				   NULL,
> -				   mrf24j40_isr,
> -				   IRQF_TRIGGER_LOW|IRQF_ONESHOT,
> -				   dev_name(&spi->dev),
> -				   devrec);
> +	ret = devm_request_threaded_irq(&spi->dev,
> +					spi->irq,
> +					NULL,
> +					mrf24j40_isr,
> +					IRQF_TRIGGER_LOW|IRQF_ONESHOT,
> +					dev_name(&spi->dev),
> +					devrec);
>  
>  	if (ret) {
>  		dev_err(printdev(devrec), "Unable to get IRQ");
> @@ -696,10 +697,7 @@ err_read_reg:
>  err_register_device:
>  	ieee802154_free_device(devrec->dev);
>  err_alloc_dev:
> -	kfree(devrec->buf);
> -err_buf:
> -	kfree(devrec);
> -err_devrec:
> +err_ret:
>  	return ret;
>  }

another point is that you have now two labels for the same jump point.

err_alloc_dev:
err_ret:

- Alex
