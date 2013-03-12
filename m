From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH net-next 1/2] phy: add set_wol/get_wol functions
Date: Tue, 12 Mar 2013 11:54:45 +0100
Message-ID: <513F0975.7020801@openwrt.org>
References: <1363046205-17239-1-git-send-email-michael@stapelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Michael Stapelberg <michael@stapelberg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:57565 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933Ab3CLK6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 06:58:19 -0400
Received: by mail-bk0-f42.google.com with SMTP id jk7so2174913bkc.1
        for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 03:58:18 -0700 (PDT)
In-Reply-To: <1363046205-17239-1-git-send-email-michael@stapelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Michael,

This is looking good from my perspective, just a minor nitpick with 
repsect to your comment below.

On 03/12/2013 12:56 AM, Michael Stapelberg wrote:
> This allows ethernet drivers (such as the mv643xx_eth) to support
> Wake on LAN on platforms where PHY registers have to be configured
> for Wake on LAN (e.g. the Marvell Kirkwood based qnap TS-119P II).
>
> Signed-off-by: Michael Stapelberg <michael@stapelberg.de>
> ---
>   drivers/net/phy/phy.c |   16 ++++++++++++++++
>   include/linux/phy.h   |   10 ++++++++++
>   2 files changed, 26 insertions(+)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index ef9ea92..298b4c2 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1188,3 +1188,19 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
>   	return 0;
>   }
>   EXPORT_SYMBOL(phy_ethtool_set_eee);
> +
> +int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
> +{
> +	if (phydev->drv->set_wol)
> +		return phydev->drv->set_wol(phydev, wol);
> +
> +	return -EOPNOTSUPP;
> +}
> +EXPORT_SYMBOL(phy_ethtool_set_wol);
> +
> +void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
> +{
> +	if (phydev->drv->get_wol)
> +		phydev->drv->get_wol(phydev, wol);
> +}
> +EXPORT_SYMBOL(phy_ethtool_get_wol);
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 33999ad..9e11039 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -455,6 +455,14 @@ struct phy_driver {
>   	 */
>   	void (*txtstamp)(struct phy_device *dev, struct sk_buff *skb, int type);
>
> +	/* Some devices (e.g. qnap TS-119P II) require PHY register changes to
> +	 * enable Wake on LAN, so set_wol is provided to be called in the
> +	 * ethernet driver's set_wol function. */

I would just mention here that some PHY chip needs to be configured to 
enable WoL at the PHY level (such as the Marvell 88E1318S PHY).

> +	int (*set_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
> +
> +	/* See set_wol, but for checking whether Wake on LAN is enabled. */
> +	void (*get_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
> +
>   	struct device_driver driver;
>   };
>   #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
> @@ -560,6 +568,8 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable);
>   int phy_get_eee_err(struct phy_device *phydev);
>   int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data);
>   int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data);
> +int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
> +void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
>
>   int __init mdio_bus_init(void);
>   void mdio_bus_exit(void);
>
