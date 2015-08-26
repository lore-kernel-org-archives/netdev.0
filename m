From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH -next v2 2/2] smsc911x: Ignore error return from
 device_get_phy_mode()
Date: Wed, 26 Aug 2015 14:39:56 -0700
Message-ID: <20150826213955.GV4215@atomide.com>
References: <1440620445-14413-1-git-send-email-linux@roeck-us.net>
 <1440620445-14413-2-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440620445-14413-2-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Guenter Roeck <linux@roeck-us.net> [150826 13:24]:
> Commit 62ee783bf1f8 ("smsc911x: Fix crash seen if neither ACPI nor OF is
> configured or used") introduces an error check for the return value from
> device_get_phy_mode() and bails out if there is an error. Unfortunately,
> there are configurations where no phy is configured. Those configurations
> now fail.
> 
> To fix the problem, accept error returns from device_get_phy_mode(),
> and use the return value from device_property_read_u32() to determine
> if there is a suitable firmware interface to read the configuration.
> 
> Fixes: 62ee783bf1f8 ("smsc911x: Fix crash seen if neither ACPI nor OF is configured or used")
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> v2: Dropped RFC
>     Removed check for -ENODATA
>     Depends on patch 1/2
> 
> Tested with non-devicetree configuration. Should be tested with ACPI
> and FDT configurations.

Thanks this fixes smsc911x regression in Linux next for me with FDT:

Tested-by: Tony Lindgren <tony@atomide.com>
 
>  drivers/net/ethernet/smsc/smsc911x.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 6eef3251d833..c8b26259c9cf 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -2369,23 +2369,25 @@ static int smsc911x_probe_config(struct smsc911x_platform_config *config,
>  {
>  	int phy_interface;
>  	u32 width = 0;
> +	int err;
>  
>  	phy_interface = device_get_phy_mode(dev);
>  	if (phy_interface < 0)
> -		return phy_interface;
> -
> +		phy_interface = PHY_INTERFACE_MODE_NA;
>  	config->phy_interface = phy_interface;
>  
>  	device_get_mac_address(dev, config->mac, ETH_ALEN);
>  
> -	device_property_read_u32(dev, "reg-shift", &config->shift);
> -
> -	device_property_read_u32(dev, "reg-io-width", &width);
> -	if (width == 4)
> +	err = device_property_read_u32(dev, "reg-io-width", &width);
> +	if (err == -ENXIO)
> +		return err;
> +	if (!err && width == 4)
>  		config->flags |= SMSC911X_USE_32BIT;
>  	else
>  		config->flags |= SMSC911X_USE_16BIT;
>  
> +	device_property_read_u32(dev, "reg-shift", &config->shift);
> +
>  	if (device_property_present(dev, "smsc,irq-active-high"))
>  		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
>  
> -- 
> 2.1.4
> 
