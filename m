From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] Add checks for kmalloc allocation failures
Date: Wed, 29 Mar 2017 20:54:46 +0200
Message-ID: <58DC02F6.40009@bfs.de>
References: <20170329155447.17991-1-colin.king@canonical.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Harry Morris <h.morris@cascoda.com>, linuxdev@cascoda.com,
        Alexander Aring <aar@pengutronix.de>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02-sz.bfs.de ([194.94.69.103]:29821 "EHLO mx02-sz.bfs.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752113AbdC2Sy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 14:54:58 -0400
In-Reply-To: <20170329155447.17991-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 29.03.2017 17:54, schrieb Colin King:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Ensure we don't end up with a null pointer dereferences by checking
> for for allocation failures.  Allocate by sizeof(*ptr) rather than
> the type to fix checkpack warnings.  Also merge multiple lines into
> one line for the kmalloc call.
> 
> Detected by CoverityScan, CID#1422435 ("Dereference null return value")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ieee802154/ca8210.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ieee802154/ca8210.c b/drivers/net/ieee802154/ca8210.c
> index 53fa87bfede0..25fd3b04b3c0 100644
> --- a/drivers/net/ieee802154/ca8210.c
> +++ b/drivers/net/ieee802154/ca8210.c
> @@ -634,6 +634,8 @@ static int ca8210_test_int_driver_write(
>  		dev_dbg(&priv->spi->dev, "%#03x\n", buf[i]);
>  
>  	fifo_buffer = kmalloc(len, GFP_KERNEL);
> +	if (!fifo_buffer)
> +		return -ENOMEM;
>  	memcpy(fifo_buffer, buf, len);


perhaps kmemdup() ist the way to go ?
by replace kamlloc()+memcpy

re,
 wh

>  	kfifo_in(&test->up_fifo, &fifo_buffer, 4);
>  	wake_up_interruptible(&priv->test.readq);
> @@ -759,10 +761,10 @@ static void ca8210_rx_done(struct cas_control *cas_ctl)
>  				&priv->spi->dev,
>  				"Resetting MAC...\n");
>  
> -			mlme_reset_wpc = kmalloc(
> -				sizeof(struct work_priv_container),
> -				GFP_KERNEL
> -			);
> +			mlme_reset_wpc = kmalloc(sizeof(*mlme_reset_wpc),
> +						 GFP_KERNEL);
> +			if (!mlme_reset_wpc)
> +				goto finish;
>  			INIT_WORK(
>  				&mlme_reset_wpc->work,
>  				ca8210_mlme_reset_worker
> @@ -925,10 +927,10 @@ static int ca8210_spi_transfer(
>  
>  	dev_dbg(&spi->dev, "ca8210_spi_transfer called\n");
>  
> -	cas_ctl = kmalloc(
> -		sizeof(struct cas_control),
> -		GFP_ATOMIC
> -	);
> +	cas_ctl = kmalloc(sizeof(*cas_ctl), GFP_ATOMIC);
> +	if (!cas_ctl)
> +		return -ENOMEM;
> +
>  	cas_ctl->priv = priv;
>  	memset(cas_ctl->tx_buf, SPI_IDLE, CA8210_SPI_BUF_SIZE);
>  	memset(cas_ctl->tx_in_buf, SPI_IDLE, CA8210_SPI_BUF_SIZE);
