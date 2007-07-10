From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] PHY fixed driver: rework release path and update phy_id
 notation
Date: Tue, 10 Jul 2007 13:01:26 -0400
Message-ID: <4693BB66.1040102@garzik.org>
References: <20070609162118.2680.99019.stgit@ACA800FC.ipt.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60444 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437AbXGJRB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 13:01:29 -0400
In-Reply-To: <20070609162118.2680.99019.stgit@ACA800FC.ipt.aol.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Bordug wrote:
> device_bind_driver() error code returning has been fixed. 
> release() function has been written, so that to free resources
> in correct way; the release path is now clean.
> 
> Before the rework, it used to cause
>  Device 'fixed@100:1' does not have a release() function, it is broken
>  and must be fixed.
>  BUG: at drivers/base/core.c:104 device_release()
>  
>  Call Trace:  
>   [<ffffffff802ec380>] kobject_cleanup+0x53/0x7e
>   [<ffffffff802ec3ab>] kobject_release+0x0/0x9
>   [<ffffffff802ecf3f>] kref_put+0x74/0x81
>   [<ffffffff8035493b>] fixed_mdio_register_device+0x230/0x265
>   [<ffffffff80564d31>] fixed_init+0x1f/0x35
>   [<ffffffff802071a4>] init+0x147/0x2fb
>   [<ffffffff80223b6e>] schedule_tail+0x36/0x92
>   [<ffffffff8020a678>] child_rip+0xa/0x12
>   [<ffffffff80311714>] acpi_ds_init_one_object+0x0/0x83
>   [<ffffffff8020705d>] init+0x0/0x2fb
>   [<ffffffff8020a66e>] child_rip+0x0/0x12  
> 
> 
> Also changed the notation of the fixed phy definition on
> mdio bus to the form of <speed>+<duplex> to make it able to be used by
> gianfar and ucc_geth that define phy_id strictly as "%d:%d"
> 
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> 
> ---
> 
>  drivers/net/phy/Kconfig |    4 ++
>  drivers/net/phy/fixed.c |   93 +++++++++++++++++++++++++++--------------------
>  2 files changed, 57 insertions(+), 40 deletions(-)
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 09b6f25..a938c48 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -71,4 +71,8 @@ config FIXED_MII_100_FDX
>  	bool "Emulation for 100M Fdx fixed PHY behavior"
>  	depends on FIXED_PHY
>  
> +config FIXED_MII_1000_FDX
> +	bool "Emulation for 1000M Fdx fixed PHY behavior"
> +	depends on FIXED_PHY
> +
>  endif # PHYLIB
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index 68c99b4..34b9111 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -187,12 +187,29 @@ static struct phy_driver fixed_mdio_driver = {
>  	.driver 	= { .owner = THIS_MODULE,},
>  };
>  
> +static void fixed_mdio_release (struct device * dev)
> +{
> +	struct phy_device *phydev = container_of(dev, struct phy_device, dev);
> +	struct mii_bus *bus = phydev->bus;
> +	struct fixed_info *fixed = bus->priv;
> +
> +	kfree(phydev);
> +	kfree(bus->dev);
> +	kfree(bus);
> +	kfree(fixed->regs);
> +	kfree(fixed);
> +}
> +
>  /*-----------------------------------------------------------------------------
>   *  This func is used to create all the necessary stuff, bind
>   * the fixed phy driver and register all it on the mdio_bus_type.
> - * speed is either 10 or 100, duplex is boolean.
> + * speed is either 10 or 100 or 1000, duplex is boolean.
>   * number is used to create multiple fixed PHYs, so that several devices can
>   * utilize them simultaneously.
> + *
> + * The device on mdio bus will look like <bus_id>:<phy_id>,
> + * bus_id = number 
> + * phy_id = speed+duplex.
>   *-----------------------------------------------------------------------------*/
>  static int fixed_mdio_register_device(int number, int speed, int duplex)
>  {
> @@ -221,6 +238,12 @@ static int fixed_mdio_register_device(int number, int speed, int duplex)
>  	}
>  
>  	fixed->regs = kzalloc(MII_REGS_NUM*sizeof(int), GFP_KERNEL);
> +	if (NULL == fixed->regs) {
> +		kfree(dev);
> +		kfree(new_bus);
> +		kfree(fixed);
> +		return -ENOMEM;
> +	}
>  	fixed->regs_num = MII_REGS_NUM;
>  	fixed->phy_status.speed = speed;
>  	fixed->phy_status.duplex = duplex;
> @@ -249,57 +272,43 @@ static int fixed_mdio_register_device(int number, int speed, int duplex)
>  	fixed->phydev = phydev;
>  
>  	if(NULL == phydev) {
> -		err = -ENOMEM;
> -		goto device_create_fail;
> +		kfree(dev);
> +		kfree(new_bus);
> +		kfree(fixed->regs);
> +		kfree(fixed);
> +		return -ENOMEM;
>  	}
>  
>  	phydev->irq = PHY_IGNORE_INTERRUPT;
>  	phydev->dev.bus = &mdio_bus_type;
>  
> -	if(number)
> -		snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
> -				"fixed_%d@%d:%d", number, speed, duplex);
> -	else
> -		snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
> -				"fixed@%d:%d", speed, duplex);
> +	snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
> +				"%d:%d", number, speed + duplex);
> +
>  	phydev->bus = new_bus;
>  
> +	phydev->dev.driver = &fixed_mdio_driver.driver;
> + 	phydev->dev.release = fixed_mdio_release;
> + 
> + 	err = phydev->dev.driver->probe(&phydev->dev);
> + 	if(err < 0) {
> + 		printk(KERN_ERR "Phy %s: problems with fixed driver\n",
> +				phydev->dev.bus_id);
> + 		kfree(phydev);
> + 		kfree(dev);
> + 		kfree(new_bus);
> + 		kfree(fixed->regs);
> + 		kfree(fixed);
> + 		return err;
> + 	}
> + 
>  	err = device_register(&phydev->dev);
>  	if(err) {
>  		printk(KERN_ERR "Phy %s failed to register\n",
>  				phydev->dev.bus_id);
> -		goto bus_register_fail;
> -	}

use the standard 'goto' style found in the kernel, rather than repeating 
all these kfree's.


