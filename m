From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH] sfc: I2C adapter initialisation fixes
Date: Mon, 9 Jun 2008 21:05:46 +0200
Message-ID: <20080609210546.5a848333@hyperion.delvare>
References: <cover.1213035602.git.bhutchings@solarflare.com>
	<20080609182509.GJ11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:29945 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbYFITGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 15:06:01 -0400
In-Reply-To: <20080609182509.GJ11300@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Mon, 9 Jun 2008 19:25:10 +0100, Ben Hutchings wrote:
> As recommended by Jean Delvare:
> - Increase timeout to 50 ms
> - Leave adapter class clear so that unwanted drivers do not probe our bus
> - Use strlcpy() for name initialisation
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/falcon.c |   12 +++---------
>  1 files changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
> index 630406e..e086100 100644
> --- a/drivers/net/sfc/falcon.c
> +++ b/drivers/net/sfc/falcon.c
> @@ -223,13 +223,8 @@ static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
>  	.getsda		= falcon_getsda,
>  	.getscl		= falcon_getscl,
>  	.udelay		= 5,
> -	/*
> -	 * This is the number of system clock ticks after which
> -	 * i2c-algo-bit gives up waiting for SCL to become high.
> -	 * It must be at least 2 since the first tick can happen
> -	 * immediately after it starts waiting.
> -	 */
> -	.timeout	= 2,
> +	/* Wait up to 50 ms to begin command */

The timeout value affects every bit sent on the wire, it doesn't have
much to do with "begin command". The first half of the previous comment
was IMHO better.

> +	.timeout	= DIV_ROUND_UP(HZ, 20),
>  };
>  
>  /**************************************************************************
> @@ -2479,12 +2474,11 @@ int falcon_probe_nic(struct efx_nic *efx)
>  
>  	/* Initialise I2C adapter */
>   	efx->i2c_adap.owner = THIS_MODULE;
> - 	efx->i2c_adap.class = I2C_CLASS_HWMON;
>  	nic_data->i2c_data = falcon_i2c_bit_operations;
>  	nic_data->i2c_data.data = efx;
>   	efx->i2c_adap.algo_data = &nic_data->i2c_data;
>  	efx->i2c_adap.dev.parent = &efx->pci_dev->dev;
> -	strcpy(efx->i2c_adap.name, "SFC4000 GPIO");
> +	strlcpy(efx->i2c_adap.name, "SFC4000 GPIO", sizeof(efx->i2c_adap.name));
>  	rc = i2c_bit_add_bus(&efx->i2c_adap);
>  	if (rc)
>  		goto fail5;
> 

But other than that, patch looks good, thanks.

-- 
Jean Delvare
