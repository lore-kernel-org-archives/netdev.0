From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH 3/4] phylib: Support attaching to gen10g_driver
Date: Tue, 12 Nov 2013 12:31:43 +0000
Message-ID: <ED492CCEAF882048BC2237DE806547C91511738C@039-SN2MPN1-013.039d.mgd.msft.net>
References: <1384168079-3002-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jg1.han@samsung.com" <jg1.han@samsung.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"michal.simek@xilinx.com" <michal.simek@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "shh.xie@gmail.com" <shh.xie@gmail.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:15294
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754842Ab3KLMbs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 07:31:48 -0500
In-Reply-To: <1384168079-3002-1-git-send-email-shh.xie@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added more people and list.

Best Regards, 
Shaohui Xie


> -----Original Message-----
> From: shh.xie@gmail.com [mailto:shh.xie@gmail.com]
> Sent: Monday, November 11, 2013 7:08 PM
> To: linuxppc-dev@lists.ozlabs.org; linux-kernel@vger.kernel.org
> Cc: Bucur Madalin-Cristian-B32716; Kanetkar Shruti-B44454; Xie Shaohui-B21989
> Subject: [PATCH 3/4] phylib: Support attaching to gen10g_driver
> 
> From: Andy Fleming
> 
> phy_attach_direct() may now attach to a generic 10G driver. It can also be used
> exactly as phy_connect_direct(), which will be useful when using of_mdio, as
> phy_connect (and therefore of_phy_connect) start the PHY state machine, which is
> currently irrelevant for 10G PHYs.
> 
> Signed-off-by: Andy Fleming
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>  drivers/net/phy/phy_device.c | 23 +++++++++++------------
>  include/linux/phy.h          |  2 ++
>  2 files changed, 13 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c index
> 30bf2d5..f51ea2e 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -55,15 +55,13 @@ static void phy_device_release(struct device *dev)  }
> 
>  static struct phy_driver genphy_driver;
> +static struct phy_driver gen10g_driver;
>  extern int mdio_bus_init(void);
>  extern void mdio_bus_exit(void);
> 
>  static LIST_HEAD(phy_fixup_list);
>  static DEFINE_MUTEX(phy_fixup_lock);
> 
> -static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> -			     u32 flags, phy_interface_t interface);
> -
>  /*
>   * Creates a new phy_fixup and adds it to the list
>   * @bus_id: A string which matches phydev->dev.bus_id (or PHY_ANY_ID) @@ -
> 521,12 +519,12 @@ int phy_init_hw(struct phy_device *phydev)
>   *
>   * Description: Called by drivers to attach to a particular PHY
>   *     device. The phy_device is found, and properly hooked up
> - *     to the phy_driver.  If no driver is attached, then the
> - *     genphy_driver is used.  The phy_device is given a ptr to
> + *     to the phy_driver.  If no driver is attached, then a
> + *     generic driver is used.  The phy_device is given a ptr to
>   *     the attaching device, and given a callback for link status
>   *     change.  The phy_device is returned to the attaching driver.
>   */
> -static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> +int phy_attach_direct(struct net_device *dev, struct phy_device
> +*phydev,
>  			     u32 flags, phy_interface_t interface)  {
>  	struct device *d = &phydev->dev;
> @@ -535,12 +533,10 @@ static int phy_attach_direct(struct net_device *dev,
> struct phy_device *phydev,
>  	/* Assume that if there is no driver, that it doesn't
>  	 * exist, and we should use the genphy driver. */
>  	if (NULL == d->driver) {
> -		if (phydev->is_c45) {
> -			pr_err("No driver for phy %x\n", phydev->phy_id);
> -			return -ENODEV;
> -		}
> -
> -		d->driver = &genphy_driver.driver;
> +		if (phydev->is_c45)
> +			d->driver = &gen10g_driver.driver;
> +		else
> +			d->driver = &genphy_driver.driver;
> 
>  		err = d->driver->probe(d);
>  		if (err >= 0)
> @@ -573,6 +569,7 @@ static int phy_attach_direct(struct net_device *dev, struct
> phy_device *phydev,
> 
>  	return err;
>  }
> +EXPORT_SYMBOL(phy_attach_direct);
> 
>  /**
>   * phy_attach - attach a network device to a particular PHY device @@ -623,6
> +620,8 @@ void phy_detach(struct phy_device *phydev)
>  	 * real driver could be loaded */
>  	if (phydev->dev.driver == &genphy_driver.driver)
>  		device_release_driver(&phydev->dev);
> +	else if (phydev->dev.driver == &gen10g_driver.driver)
> +		device_release_driver(&phydev->dev);
>  }
>  EXPORT_SYMBOL(phy_detach);
> 
> diff --git a/include/linux/phy.h b/include/linux/phy.h index f864004..f36a6f6
> 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -575,6 +575,8 @@ int phy_init_hw(struct phy_device *phydev);  struct
> phy_device * phy_attach(struct net_device *dev,
>  		const char *bus_id, phy_interface_t interface);  struct phy_device
> *phy_find_first(struct mii_bus *bus);
> +int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> +			     u32 flags, phy_interface_t interface);
>  int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
>  		void (*handler)(struct net_device *),
>  		phy_interface_t interface);
> --
> 1.8.4.1
