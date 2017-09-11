From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net 1/3] lan78xx: Fix for eeprom read/write when
 device auto suspend
Date: Mon, 11 Sep 2017 22:24:28 +0200
Message-ID: <20170911202428.GB5983@lunn.ch>
References: <CE371C1263339941885964188A0225FA335C84@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37521 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751214AbdIKUYe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 16:24:34 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA335C84@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 11, 2017 at 06:51:49PM +0000, Nisar.Sayed@microchip.com wrote:
> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Fix for eeprom read/write when device auto suspend
> 
> Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
> Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
> ---
>  drivers/net/usb/lan78xx.c | 22 ++++++++++++++++++----
>  1 file changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index b99a7fb..baf91c7 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -1265,30 +1265,44 @@ static int lan78xx_ethtool_get_eeprom(struct net_device *netdev,
>  				      struct ethtool_eeprom *ee, u8 *data)
>  {
>  	struct lan78xx_net *dev = netdev_priv(netdev);
> +	int ret = -EINVAL;
> +
> +	if (usb_autopm_get_interface(dev->intf) < 0)
> +		return ret;

Hi Nisar

It is better to do

   ret = usb_autopm_get_interface(dev->intf;
   if (ret)
        return ret;

i.e. use the error code usb_autopm_get_interface() gives you.

>  	ee->magic = LAN78XX_EEPROM_MAGIC;
>  
> -	return lan78xx_read_raw_eeprom(dev, ee->offset, ee->len, data);
> +	ret = lan78xx_read_raw_eeprom(dev, ee->offset, ee->len, data);
> +
> +	usb_autopm_put_interface(dev->intf);
> +
> +	return ret;
>  }
>  
>  static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
>  				      struct ethtool_eeprom *ee, u8 *data)
>  {
>  	struct lan78xx_net *dev = netdev_priv(netdev);
> +	int ret = -EINVAL;
> +
> +	if (usb_autopm_get_interface(dev->intf) < 0)
> +		return ret;

Same here.

     Andrew
