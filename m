From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH] mrf24j40: seperate mrf24j40 h/w init and add checkings
Date: Wed, 23 Apr 2014 09:51:33 -0400
Message-ID: <5357C565.8080009@signal11.us>
References: <1398258716-18319-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>, alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56162 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751463AbaDWNvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 09:51:43 -0400
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id D167E20E51
	for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 09:51:40 -0400 (EDT)
In-Reply-To: <1398258716-18319-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2014 09:11 AM, Varka Bhadram wrote:
> I followed the process that you mailed earlier, thnks for that.
>
> I am expecting the mail from Alan about the changes.

Hi Varka,

Is there a specific problem you're seeing? Typically in the kernel we 
expect the SPI controller to succeed for a couple reasons:
1. It's part of the basic, core functionality of a system. Checking for 
errors on SPI transfers is analogous to making sure RAM you wrote 
actually got written.
2. Most of the time an SPI failure is not something we can detect 
anyway. (disconnect one of the lines and see what you get).
3. The code to check for it just adds a lot of bloat without much 
measurable benefit.

I've read the above in the comments in other drivers, but I can't 
remember exactly where right now. There are plenty of examples in the 
kernel of SPI being done this way, as it seems to be accepted practice 
in the kernel.

If there is a specific issue that you're seeing, then let's talk about 
it, otherwise I'm going to NAK this change.

Alan.

>
>
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>   drivers/net/ieee802154/mrf24j40.c |  115 ++++++++++++++++++++++++++++---------
>   1 file changed, 89 insertions(+), 26 deletions(-)
>
> diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
> index 246befa..4a9a1ee 100644
> --- a/drivers/net/ieee802154/mrf24j40.c
> +++ b/drivers/net/ieee802154/mrf24j40.c
> @@ -609,10 +609,95 @@ out:
>   	return IRQ_HANDLED;
>   }
>   
> +static int mrf24j40_hw_init(struct mrf24j40 *devrec)
> +{
> +	int ret;
> +	u8 val;
> +
> +	/* Initialize the device.
> +		From datasheet section 3.2: Initialization. */
> +	ret = write_short_reg(devrec, REG_SOFTRST, 0x07);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_short_reg(devrec, REG_PACON2, 0x98);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_short_reg(devrec, REG_TXSTBL, 0x95);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_long_reg(devrec, REG_RFCON0, 0x03);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_long_reg(devrec, REG_RFCON1, 0x01);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_long_reg(devrec, REG_RFCON2, 0x80);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_long_reg(devrec, REG_RFCON6, 0x90);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_long_reg(devrec, REG_RFCON7, 0x80);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_long_reg(devrec, REG_RFCON8, 0x10);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_long_reg(devrec, REG_SLPCON1, 0x21);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_short_reg(devrec, REG_BBREG2, 0x80);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_short_reg(devrec, REG_CCAEDTH, 0x60);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_short_reg(devrec, REG_BBREG6, 0x40);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_short_reg(devrec, REG_RFCTL, 0x04);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = write_short_reg(devrec, REG_RFCTL, 0x0);
> +	if (ret)
> +		goto err_ret;
> +
> +	udelay(192);
> +
> +	/* Set RX Mode. RXMCR<1:0>: 0x0 normal, 0x1 promisc, 0x2 error */
> +	ret = read_short_reg(devrec, REG_RXMCR, &val);
> +	if (ret)
> +		goto err_ret;
> +
> +	val &= ~0x3; /* Clear RX mode (normal) */
> +
> +	ret = write_short_reg(devrec, REG_RXMCR, val);
> +	if (ret)
> +		goto err_ret;
> +
> +	return 0;
> +
> +err_ret:
> +	return ret;
> +}
> +
>   static int mrf24j40_probe(struct spi_device *spi)
>   {
>   	int ret = -ENOMEM;
> -	u8 val;
>   	struct mrf24j40 *devrec;
>   
>   	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
> @@ -649,31 +734,9 @@ static int mrf24j40_probe(struct spi_device *spi)
>   	if (ret)
>   		goto err_register_device;
>   
> -	/* Initialize the device.
> -		From datasheet section 3.2: Initialization. */
> -	write_short_reg(devrec, REG_SOFTRST, 0x07);
> -	write_short_reg(devrec, REG_PACON2, 0x98);
> -	write_short_reg(devrec, REG_TXSTBL, 0x95);
> -	write_long_reg(devrec, REG_RFCON0, 0x03);
> -	write_long_reg(devrec, REG_RFCON1, 0x01);
> -	write_long_reg(devrec, REG_RFCON2, 0x80);
> -	write_long_reg(devrec, REG_RFCON6, 0x90);
> -	write_long_reg(devrec, REG_RFCON7, 0x80);
> -	write_long_reg(devrec, REG_RFCON8, 0x10);
> -	write_long_reg(devrec, REG_SLPCON1, 0x21);
> -	write_short_reg(devrec, REG_BBREG2, 0x80);
> -	write_short_reg(devrec, REG_CCAEDTH, 0x60);
> -	write_short_reg(devrec, REG_BBREG6, 0x40);
> -	write_short_reg(devrec, REG_RFCTL, 0x04);
> -	write_short_reg(devrec, REG_RFCTL, 0x0);
> -	udelay(192);
> -
> -	/* Set RX Mode. RXMCR<1:0>: 0x0 normal, 0x1 promisc, 0x2 error */
> -	ret = read_short_reg(devrec, REG_RXMCR, &val);
> +	ret = mrf24j40_hw_init(devrec);
>   	if (ret)
> -		goto err_read_reg;
> -	val &= ~0x3; /* Clear RX mode (normal) */
> -	write_short_reg(devrec, REG_RXMCR, val);
> +		goto err_hw_init;
>   
>   	ret = request_threaded_irq(spi->irq,
>   				   NULL,
> @@ -690,7 +753,7 @@ static int mrf24j40_probe(struct spi_device *spi)
>   	return 0;
>   
>   err_irq:
> -err_read_reg:
> +err_hw_init:
>   	ieee802154_unregister_device(devrec->dev);
>   err_register_device:
>   	ieee802154_free_device(devrec->dev);
