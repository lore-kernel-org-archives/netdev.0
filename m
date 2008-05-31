From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] sfc: Use kernel I2C system and i2c-algo-bit driver
Date: Sat, 31 May 2008 12:27:02 +0100
Message-ID: <20080531112700.GL1743@solarflare.com>
References: <cover.1212182201.git.bhutchings@solarflare.com> <20080530212703.GG1743@solarflare.com> <20080531131848.24b9e465@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jean Delvare <khali@linux-fr.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:36815 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751869AbYEaL1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 07:27:20 -0400
Content-Disposition: inline
In-Reply-To: <20080531131848.24b9e465@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Delvare wrote:
[...]
> > diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
> > index d3f749c..8acd53d 100644
> > --- a/drivers/net/sfc/falcon.c
> > +++ b/drivers/net/sfc/falcon.c
> > (...)
> > -static struct efx_i2c_bit_operations falcon_i2c_bit_operations = {
> > -	.setsda		= falcon_setsdascl,
> > -	.setscl		= falcon_setsdascl,
> > +static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
> > +	.setsda		= falcon_setsda,
> > +	.setscl		= falcon_setscl,
> >  	.getsda		= falcon_getsda,
> >  	.getscl		= falcon_getscl,
> >  	.udelay		= 100,
> > -	.mdelay		= 10,
> > +	/*
> > +	 * This is the number of system clock ticks after which
> > +	 * i2c-algo-bit gives up waiting for SCL to become high.
> > +	 * It must be at least 2 since the first tick can happen
> > +	 * immediately after it starts waiting.
> > +	 */
> > +	.timeout	= 2,
> 
> This is unreasonably low at HZ=1000 (2 ms). The SMBus specification
> states that clients can hold the clock line low for up to 50 ms if they
> need additional time to process the previous commands. So I would use
> msecs_to_jiffies(50) (don't forget to include <linux/jiffies.h>.)

OK.  We can't use msecs_to_jiffies() in a static initialiser, though.

[...]
> > @@ -2459,6 +2475,18 @@ int falcon_probe_nic(struct efx_nic *efx)
> >  	if (rc)
> >  		goto fail5;
> >  
> > +	/* Initialise I2C adapter */
> > + 	efx->i2c_adap.owner = THIS_MODULE;
> > + 	efx->i2c_adap.class = I2C_CLASS_HWMON;
> 
> I doubt you want to do this. This would let any hardware monitoring
> driver probe your bus for a device, while presumably you already know
> which hardware monitoring device is present and you want to instantiate
> the i2c client yourself. This will probably become clearer when you
> start using the lm87 driver and modify it to support new-style i2c
> binding.
 
So the class should be, what, 0?

> > +	nic_data->i2c_data = falcon_i2c_bit_operations;
> > +	nic_data->i2c_data.data = efx;
> > + 	efx->i2c_adap.algo_data = &nic_data->i2c_data;
> > +	efx->i2c_adap.dev.parent = &efx->pci_dev->dev;
> > +	strcpy(efx->i2c_adap.name, "SFC4000 GPIO");
> 
> Please always use strlcpy.
 
OK.  I thought about it but it didn't seem worthwhile for a short constant
string.

> > +	rc = i2c_bit_add_bus(&efx->i2c_adap);
> > +	if (rc)
> > +		goto fail5;
> > +
> >  	return 0;
> >  
> >   fail5:
> > @@ -2633,6 +2661,10 @@ int falcon_init_nic(struct efx_nic *efx)
> >  void falcon_remove_nic(struct efx_nic *efx)
> >  {
> >  	struct falcon_nic_data *nic_data = efx->nic_data;
> > +	int rc;
> > +
> > +	rc = i2c_del_adapter(&efx->i2c_adap);
> > +	BUG_ON(rc);
> 
> That's pretty aggressive and probably not needed.

We have no way of cancelling the removal at this point, so if the
adapter is not properly deleted then it will hang around referring to
a NIC structure that has gone away.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
