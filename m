From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH 1/2] sfc: Use kernel I2C system and i2c-algo-bit driver
Date: Sat, 31 May 2008 13:18:48 +0200
Message-ID: <20080531131848.24b9e465@hyperion.delvare>
References: <cover.1212182201.git.bhutchings@solarflare.com>
	<20080530212703.GG1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:21426 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbYEaLTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 07:19:05 -0400
In-Reply-To: <20080530212703.GG1743@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Fri, 30 May 2008 22:27:04 +0100, Ben Hutchings wrote:
> Remove our own implementation of I2C bit-banging.

Thanks a lot for doing this. It's always nice to see hundreds of lines
of code being removed from the kernel :) Some comments:

> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/Kconfig      |    2 +
>  drivers/net/sfc/Makefile     |    2 +-
>  drivers/net/sfc/boards.c     |    2 +-
>  drivers/net/sfc/boards.h     |    3 +-
>  drivers/net/sfc/efx.c        |    2 +
>  drivers/net/sfc/falcon.c     |   72 ++++++---
>  drivers/net/sfc/i2c-direct.c |  381 ------------------------------------------
>  drivers/net/sfc/i2c-direct.h |   91 ----------
>  drivers/net/sfc/net_driver.h |   11 +-
>  drivers/net/sfc/sfe4001.c    |  126 ++++++++-------
>  10 files changed, 133 insertions(+), 559 deletions(-)
>  delete mode 100644 drivers/net/sfc/i2c-direct.c
>  delete mode 100644 drivers/net/sfc/i2c-direct.h
> 
> (...)
> diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
> index d3f749c..8acd53d 100644
> --- a/drivers/net/sfc/falcon.c
> +++ b/drivers/net/sfc/falcon.c
> (...)
> -static struct efx_i2c_bit_operations falcon_i2c_bit_operations = {
> -	.setsda		= falcon_setsdascl,
> -	.setscl		= falcon_setsdascl,
> +static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
> +	.setsda		= falcon_setsda,
> +	.setscl		= falcon_setscl,
>  	.getsda		= falcon_getsda,
>  	.getscl		= falcon_getscl,
>  	.udelay		= 100,
> -	.mdelay		= 10,
> +	/*
> +	 * This is the number of system clock ticks after which
> +	 * i2c-algo-bit gives up waiting for SCL to become high.
> +	 * It must be at least 2 since the first tick can happen
> +	 * immediately after it starts waiting.
> +	 */
> +	.timeout	= 2,

This is unreasonably low at HZ=1000 (2 ms). The SMBus specification
states that clients can hold the clock line low for up to 50 ms if they
need additional time to process the previous commands. So I would use
msecs_to_jiffies(50) (don't forget to include <linux/jiffies.h>.)

>  };
>  
>  /**************************************************************************
> @@ -2403,12 +2425,6 @@ int falcon_probe_nic(struct efx_nic *efx)
>  	struct falcon_nic_data *nic_data;
>  	int rc;
>  
> -	/* Initialise I2C interface state */
> -	efx->i2c.efx = efx;
> -	efx->i2c.op = &falcon_i2c_bit_operations;
> -	efx->i2c.sda = 1;
> -	efx->i2c.scl = 1;
> -
>  	/* Allocate storage for hardware specific data */
>  	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
>  	efx->nic_data = nic_data;
> @@ -2459,6 +2475,18 @@ int falcon_probe_nic(struct efx_nic *efx)
>  	if (rc)
>  		goto fail5;
>  
> +	/* Initialise I2C adapter */
> + 	efx->i2c_adap.owner = THIS_MODULE;
> + 	efx->i2c_adap.class = I2C_CLASS_HWMON;

I doubt you want to do this. This would let any hardware monitoring
driver probe your bus for a device, while presumably you already know
which hardware monitoring device is present and you want to instantiate
the i2c client yourself. This will probably become clearer when you
start using the lm87 driver and modify it to support new-style i2c
binding.

> +	nic_data->i2c_data = falcon_i2c_bit_operations;
> +	nic_data->i2c_data.data = efx;
> + 	efx->i2c_adap.algo_data = &nic_data->i2c_data;
> +	efx->i2c_adap.dev.parent = &efx->pci_dev->dev;
> +	strcpy(efx->i2c_adap.name, "SFC4000 GPIO");

Please always use strlcpy.

> +	rc = i2c_bit_add_bus(&efx->i2c_adap);
> +	if (rc)
> +		goto fail5;
> +
>  	return 0;
>  
>   fail5:
> @@ -2633,6 +2661,10 @@ int falcon_init_nic(struct efx_nic *efx)
>  void falcon_remove_nic(struct efx_nic *efx)
>  {
>  	struct falcon_nic_data *nic_data = efx->nic_data;
> +	int rc;
> +
> +	rc = i2c_del_adapter(&efx->i2c_adap);
> +	BUG_ON(rc);

That's pretty aggressive and probably not needed.

>  
>  	falcon_free_buffer(efx, &efx->irq_status);
>  

-- 
Jean Delvare
