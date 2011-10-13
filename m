From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 1/3] phylib: Convert MDIO and PHY Lib drivers to
 support 10G
Date: Thu, 13 Oct 2011 16:46:00 +0100
Message-ID: <1318520760.2745.6.camel@bwh-desktop>
References: <1318516660-25452-1-git-send-email-afleming@freescale.com>
	 <1318516660-25452-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17306 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612Ab1JMPqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 11:46:03 -0400
In-Reply-To: <1318516660-25452-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-13 at 09:37 -0500, Andy Fleming wrote:
> 10G MDIO is a totally different protocol (clause 45 of 802.3).
> Supporting this new protocol requires a couple of changes:
> 
> * Add a new parameter to the mdiobus_read functions to specify the
>   "device address" inside the PHY.
> * Add a phy45_read/write function which takes advantage of that
>   new parameter
> * Convert all of the existing drivers to use the new format
> 
> I created a new clause-45-specific read/write functions because:
> 1) phy_read and phy_write are highly overloaded functions, and
>    finding every instance which is actually the PHY Lib version
>    was quite difficult
> 2) Most code which invokes phy_read/phy_write inside PHY Lib is
>    Clause-22-specific. None of the phy_read/phy_write invocations
>    were useable on 10G PHYs
[...]
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 3cbda08..00f5cfe 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -322,7 +322,8 @@ int phy_mii_ioctl(struct phy_device *phydev,
>  
>  	case SIOCGMIIREG:
>  		mii_data->val_out = mdiobus_read(phydev->bus, mii_data->phy_id,
> -						 mii_data->reg_num);
> +						MDIO_DEVAD_NONE,
> +						mii_data->reg_num);
>  		break;
>  
>  	case SIOCSMIIREG:
> @@ -354,7 +355,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
>  		}
>  
>  		mdiobus_write(phydev->bus, mii_data->phy_id,
> -			      mii_data->reg_num, val);
> +				MDIO_DEVAD_NONE, mii_data->reg_num, val);
>  
>  		if (mii_data->reg_num == MII_BMCR &&
>  		    val & BMCR_RESET &&

What about c45 support here?  It's not terribly difficult to do...

> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 83a5a5a..22281d4 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -4,9 +4,11 @@
>   * Framework for finding and configuring PHYs.
>   * Also contains generic PHY driver
>   *
> + * 10G PHY Driver support mostly appropriated from drivers/net/mdio.c
> + *

If you're saying you copied a significant amount of code, shouldn't you
add the copyright notice too?

[...]
> @@ -640,7 +660,6 @@ static int genphy_setup_forced(struct phy_device *phydev)
>  	return err;
>  }
>  
> -
>  /**
>   * genphy_restart_aneg - Enable and Restart Autonegotiation
>   * @phydev: target phy_device struct
> @@ -665,7 +684,6 @@ int genphy_restart_aneg(struct phy_device *phydev)
>  }
>  EXPORT_SYMBOL(genphy_restart_aneg);
>  
> -
>  /**
>   * genphy_config_aneg - restart auto-negotiation or write BMCR
>   * @phydev: target phy_device struct
> @@ -882,6 +900,7 @@ static int genphy_config_init(struct phy_device *phydev)
>  
>  	return 0;
>  }
> +
>  int genphy_suspend(struct phy_device *phydev)
>  {
>  	int value;
> @@ -1022,7 +1041,7 @@ static struct phy_driver genphy_driver = {
>  	.read_status	= genphy_read_status,
>  	.suspend	= genphy_suspend,
>  	.resume		= genphy_resume,
> -	.driver		= {.owner= THIS_MODULE, },
> +	.driver		= {.owner = THIS_MODULE, },
>  };
>  
>  static int __init phy_init(void)
> @@ -1035,7 +1054,12 @@ static int __init phy_init(void)
>  
>  	rc = phy_driver_register(&genphy_driver);
>  	if (rc)
> -		mdio_bus_exit();
> +		goto genphy_register_failed;
> +
> +	return rc;
> +
> +genphy_register_failed:
> +	mdio_bus_exit();
>  
>  	return rc;
>  }

These changes are unrelated to c45.

> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 54fc413..ae1fdd8 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
[...]
> @@ -65,6 +66,7 @@ typedef enum {
>  	PHY_INTERFACE_MODE_RGMII_TXID,
>  	PHY_INTERFACE_MODE_RTBI,
>  	PHY_INTERFACE_MODE_SMII,
> +	PHY_INTERFACE_MODE_XGMII
>  } phy_interface_t;
[...]

XAUI, XFI?

(Maybe the distinction doesn't matter in this context.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
