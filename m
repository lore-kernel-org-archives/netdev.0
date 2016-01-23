From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] lan78xx: changed to use updated phy-ignore-interrupts
Date: Fri, 22 Jan 2016 19:33:40 -0800
Message-ID: <56A2F494.50900@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D4049C34C@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33920 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755232AbcAWDdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 22:33:43 -0500
Received: by mail-ob0-f174.google.com with SMTP id vt7so78389133obb.1
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 19:33:43 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4049C34C@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/01/2016 12:15, Woojung.Huh@microchip.com wrote:
> Update lan78xx to use patch of commit 4f2aaf7dd95b
> ("Merge branch 'fix-phy-ignore-interrupts'")

Looks fine, just one nit below:

> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/usb/lan78xx.c | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index 2ed5333..85ca7de 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -36,7 +36,7 @@
>  #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
>  #define DRIVER_DESC	"LAN78XX USB 3.0 Gigabit Ethernet Devices"
>  #define DRIVER_NAME	"lan78xx"
> -#define DRIVER_VERSION	"1.0.1"
> +#define DRIVER_VERSION	"1.0.2"
>  
>  #define TX_TIMEOUT_JIFFIES		(5 * HZ)
>  #define THROTTLE_JIFFIES		(HZ / 8)
> @@ -914,6 +914,8 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
>  		ret = lan78xx_write_reg(dev, MAC_CR, buf);
>  		if (unlikely(ret < 0))
>  			return -EIO;
> +
> +		phy_mac_interrupt(phydev, 0);
>  	} else if (phydev->link && !dev->link_on) {
>  		dev->link_on = true;
>  
> @@ -954,6 +956,7 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
>  
>  		ret = lan78xx_update_flowcontrol(dev, ecmd.duplex, ladv, radv);
>  		netif_carrier_on(dev->net);

Do you need this netif_carrier_on() call here? PHYLIB should set that
already.

> +		phy_mac_interrupt(phydev, 1);
>  	}
>  
>  	return ret;
> @@ -1495,7 +1498,6 @@ done:
>  static int lan78xx_mdio_init(struct lan78xx_net *dev)
>  {
>  	int ret;
> -	int i;
>  
>  	dev->mdiobus = mdiobus_alloc();
>  	if (!dev->mdiobus) {
> @@ -1511,10 +1513,6 @@ static int lan78xx_mdio_init(struct lan78xx_net *dev)
>  	snprintf(dev->mdiobus->id, MII_BUS_ID_SIZE, "usb-%03d:%03d",
>  		 dev->udev->bus->busnum, dev->udev->devnum);
>  
> -	/* handle our own interrupt */
> -	for (i = 0; i < PHY_MAX_ADDR; i++)
> -		dev->mdiobus->irq[i] = PHY_IGNORE_INTERRUPT;
> -
>  	switch (dev->devid & ID_REV_CHIP_ID_MASK_) {
>  	case 0x78000000:
>  	case 0x78500000:
> @@ -1558,6 +1556,16 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
>  		return -EIO;
>  	}
>  
> +	/* Enable PHY interrupts.
> +	 * We handle our own interrupt
> +	 */
> +	ret = phy_read(phydev, LAN88XX_INT_STS);
> +	ret = phy_write(phydev, LAN88XX_INT_MASK,
> +			LAN88XX_INT_MASK_MDINTPIN_EN_ |
> +			LAN88XX_INT_MASK_LINK_CHANGE_);
> +
> +	phydev->irq = PHY_IGNORE_INTERRUPT;
> +
>  	ret = phy_connect_direct(dev->net, phydev,
>  				 lan78xx_link_status_change,
>  				 PHY_INTERFACE_MODE_GMII);
> @@ -1580,14 +1588,6 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
>  			      SUPPORTED_Pause | SUPPORTED_Asym_Pause);
>  	genphy_config_aneg(phydev);
>  
> -	/* Workaround to enable PHY interrupt.
> -	 * phy_start_interrupts() is API for requesting and enabling
> -	 * PHY interrupt. However, USB-to-Ethernet device can't use
> -	 * request_irq() called in phy_start_interrupts().
> -	 * Set PHY to PHY_HALTED and call phy_start()
> -	 * to make a call to phy_enable_interrupts()
> -	 */
> -	phy_stop(phydev);
>  	phy_start(phydev);
>  
>  	netif_dbg(dev, ifup, dev->net, "phy initialised successfully");
> 
