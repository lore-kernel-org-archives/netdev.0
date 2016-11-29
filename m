From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-netx] net: lan78xx: add LAN7801 MAC-only support
Date: Tue, 29 Nov 2016 09:54:12 -0800
Message-ID: <007d0bc0-378c-da93-d730-28f7b5b5073a@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D4096E268@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, davem@davemloft.net, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33575 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753214AbcK2RyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:54:15 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so17033843pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 09:54:15 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4096E268@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 12:03 PM, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <woojung.huh@microchip.com>
> 
> Add LAN7801 MAC-only configuration support.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/usb/Kconfig   |   5 +++
>  drivers/net/usb/lan78xx.c | 111 +++++++++++++++++++++++++++++++++++++++++++++-
>  drivers/net/usb/lan78xx.h |  14 ++++++
>  3 files changed, 128 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index cdde590..3dd490f5 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -114,6 +114,11 @@ config USB_LAN78XX
>  	help
>  	  This option adds support for Microchip LAN78XX based USB 2
>  	  & USB 3 10/100/1000 Ethernet adapters.
> +	  LAN7800 : USB 3 to 10/100/1000 Ethernet adapter
> +	  LAN7850 : USB 2 to 10/100/1000 Ethernet adapter
> +	  LAN7801 : USB 3 to 10/100/1000 Ethernet adapter (MAC only)
> +
> +	  Proper PHY driver is required for LAN7801.
>  
>  	  To compile this driver as a module, choose M here: the
>  	  module will be called lan78xx.
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index 0c459e9..08f2895 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -40,7 +40,7 @@
>  #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
>  #define DRIVER_DESC	"LAN78XX USB 3.0 Gigabit Ethernet Devices"
>  #define DRIVER_NAME	"lan78xx"
> -#define DRIVER_VERSION	"1.0.5"
> +#define DRIVER_VERSION	"1.0.6"
>  
>  #define TX_TIMEOUT_JIFFIES		(5 * HZ)
>  #define THROTTLE_JIFFIES		(HZ / 8)
> @@ -67,6 +67,7 @@
>  #define LAN78XX_USB_VENDOR_ID		(0x0424)
>  #define LAN7800_USB_PRODUCT_ID		(0x7800)
>  #define LAN7850_USB_PRODUCT_ID		(0x7850)
> +#define LAN7801_USB_PRODUCT_ID		(0x7801)
>  #define LAN78XX_EEPROM_MAGIC		(0x78A5)
>  #define LAN78XX_OTP_MAGIC		(0x78F3)
>  
> @@ -400,6 +401,21 @@ struct lan78xx_net {
>  	struct irq_domain_data	domain_data;
>  };
>  
> +/* define external phy id */
> +#define	PHY_LAN8835			(0x0007C130)
> +#define	PHY_KSZ9031RNX			(0x00221620)
> +
> +/* phyid : masked external phy id
> + * pre_config : if needed, configure MAC and/or external PHY
> + *		such as irq pin mux and RGMII timing.
> + */
> +struct ext_phy_config_table {
> +	int phyid;
> +	void (*pre_config)(struct lan78xx_net *dev,
> +			   struct phy_device *phydev,
> +			   phy_interface_t *interface);
> +};
> +
>  /* use ethtool to change the level for any given device */
>  static int msg_level = -1;
>  module_param(msg_level, int, 0);
> @@ -1697,6 +1713,7 @@ static int lan78xx_mdiobus_read(struct mii_bus *bus, int phy_id, int idx)
>  done:
>  	mutex_unlock(&dev->phy_mutex);
>  	usb_autopm_put_interface(dev->intf);
> +
>  	return ret;
>  }
>  
> @@ -1759,6 +1776,10 @@ static int lan78xx_mdio_init(struct lan78xx_net *dev)
>  		/* set to internal PHY id */
>  		dev->mdiobus->phy_mask = ~(1 << 1);
>  		break;
> +	case ID_REV_CHIP_ID_7801_:
> +		/* scan thru PHYAD[2..0] */
> +		dev->mdiobus->phy_mask = ~(0xFF);
> +		break;
>  	}
>  
>  	ret = mdiobus_register(dev->mdiobus);
> @@ -1933,11 +1954,58 @@ static void lan78xx_remove_irq_domain(struct lan78xx_net *dev)
>  	dev->domain_data.irqdomain = NULL;
>  }
>  
> +static void lan8835_pre_config(struct lan78xx_net *dev,
> +			       struct phy_device *phydev,
> +			       phy_interface_t *interface)
> +{
> +	int buf;
> +	int ret;
> +
> +	/* LED2/PME_N/IRQ_N/RGMII_ID pin to IRQ_N mode */
> +	buf = phy_read_mmd_indirect(phydev, 32784, 3);
> +	buf &= ~0x1800;
> +	buf |= 0x0800;
> +	phy_write_mmd_indirect(phydev, 32784, 3, buf);

Using decimal numbers for register addresses is a bit unusual.

> +
> +	/* RGMII MAC TXC Delay Enable */
> +	ret = lan78xx_write_reg(dev, MAC_RGMII_ID,
> +				MAC_RGMII_ID_TXC_DELAY_EN_);
> +
> +	/* RGMII TX DLL Tune Adjust */
> +	ret = lan78xx_write_reg(dev, RGMII_TX_BYP_DLL, 0x3D00);
> +
> +	*interface = PHY_INTERFACE_MODE_RGMII_TXID;
> +}
> +
> +static void ksz9031rnx_pre_config(struct lan78xx_net *dev,
> +				  struct phy_device *phydev,
> +				  phy_interface_t *interface)
> +{
> +	/* Micrel9301RNX PHY configuration */
> +	/* RGMII Control Signal Pad Skew */
> +	phy_write_mmd_indirect(phydev, 4, 2, 0x0077);
> +	/* RGMII RX Data Pad Skew */
> +	phy_write_mmd_indirect(phydev, 5, 2, 0x7777);
> +	/* RGMII RX Clock Pad Skew */
> +	phy_write_mmd_indirect(phydev, 8, 2, 0x1FF);
> +
> +	*interface = PHY_INTERFACE_MODE_RGMII_RXID;
> +}

This should really belong in the respective PHY drivers for these PHYs,
is there a particular reason you decided to do this here?

-- 
Florian
