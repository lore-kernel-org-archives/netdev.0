From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v2] mrf24j40: add managed
 API's provided by device layer
Date: Thu, 29 May 2014 10:50:02 +0200
Message-ID: <20140529084959.GA26220@omega>
References: <1401343536-20361-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alan@signal11.us, Varka Bhadram <varkab@cdac.in>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net, alex.aing@gmail.com,
	davem@davemloft.net
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1401343536-20361-1-git-send-email-varkab@cdac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Varka,

On Thu, May 29, 2014 at 11:35:35AM +0530, Varka Bhadram wrote:
> forgot to use devm_* for spi buff.
> sorry for that.
> 
> -Varka Bhadram
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ieee802154/mrf24j40.c |   21 +++++++++------------
>  1 file changed, 9 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
> index 78a6552..90aed9b 100644
> --- a/drivers/net/ieee802154/mrf24j40.c
> +++ b/drivers/net/ieee802154/mrf24j40.c
> @@ -618,10 +618,10 @@ static int mrf24j40_probe(struct spi_device *spi)
>  
>  	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
>  
> -	devrec = kzalloc(sizeof(struct mrf24j40), GFP_KERNEL);
> +	devrec = devm_kzalloc(&spi->dev, sizeof(struct mrf24j40), GFP_KERNEL);
>  	if (!devrec)
>  		goto err_devrec;
> -	devrec->buf = kzalloc(3, GFP_KERNEL);
> +	devrec->buf = devm_kzalloc(&spi->dev, 3, GFP_KERNEL);
>  	if (!devrec->buf)
>  		goto err_buf;
>  
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

when using devm_* it's also freed when the probe function failed, so you
can also remove the error path handling.

err_alloc_dev:
        kfree(devrec->buf);
err_buf:
        kfree(devrec);

and so on...

- Alex
