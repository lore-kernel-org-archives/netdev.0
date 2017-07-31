From: Doug Berger <opendmb@gmail.com>
Subject: Re: [PATCH net] Revert "net: bcmgenet: Remove init parameter from
 bcmgenet_mii_config"
Date: Mon, 31 Jul 2017 12:55:09 -0700
Message-ID: <9afc7a49-639a-1cfc-82c1-3f619c2bb0cf@gmail.com>
References: <20170731180532.19884-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:38393 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdGaTzO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:55:14 -0400
Received: by mail-wm0-f66.google.com with SMTP id y206so71929wmd.5
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:55:14 -0700 (PDT)
In-Reply-To: <20170731180532.19884-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2017 11:05 AM, Florian Fainelli wrote:
> This reverts commit 28b45910ccda ("net: bcmgenet: Remove init parameter
> from bcmgenet_mii_config") because in the process of moving from
> dev_info() to dev_info_once() we essentially lost the helpful printed
> messages once the second instance of the driver is loaded.
> dev_info_once() does not actually print the message once per device
> instance, but once period.
> 
> Fixes: 28b45910ccda ("net: bcmgenet: Remove init parameter from bcmgenet_mii_config")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 +-
>  drivers/net/ethernet/broadcom/genet/bcmmii.c   | 7 ++++---
>  3 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 7b0b399aaedd..a981c4ee9d72 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -3669,7 +3669,7 @@ static int bcmgenet_resume(struct device *d)
>  
>  	phy_init_hw(priv->phydev);
>  	/* Speed settings must be restored */
> -	bcmgenet_mii_config(priv->dev);
> +	bcmgenet_mii_config(priv->dev, false);
>  
>  	/* disable ethernet MAC while updating its registers */
>  	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, false);
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> index b9344de669f8..3a34fdba5301 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> @@ -698,7 +698,7 @@ GENET_IO_MACRO(rbuf, GENET_RBUF_OFF);
>  
>  /* MDIO routines */
>  int bcmgenet_mii_init(struct net_device *dev);
> -int bcmgenet_mii_config(struct net_device *dev);
> +int bcmgenet_mii_config(struct net_device *dev, bool init);
>  int bcmgenet_mii_probe(struct net_device *dev);
>  void bcmgenet_mii_exit(struct net_device *dev);
>  void bcmgenet_mii_reset(struct net_device *dev);
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> index 071fcbd14e6a..30cb97b4a1d7 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> @@ -238,7 +238,7 @@ static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
>  					  bcmgenet_fixed_phy_link_update);
>  }
>  
> -int bcmgenet_mii_config(struct net_device *dev)
> +int bcmgenet_mii_config(struct net_device *dev, bool init)
>  {
>  	struct bcmgenet_priv *priv = netdev_priv(dev);
>  	struct phy_device *phydev = priv->phydev;
> @@ -327,7 +327,8 @@ int bcmgenet_mii_config(struct net_device *dev)
>  		bcmgenet_ext_writel(priv, reg, EXT_RGMII_OOB_CTRL);
>  	}
>  
> -	dev_info_once(kdev, "configuring instance for %s\n", phy_name);
> +	if (init)
> +		dev_info(kdev, "configuring instance for %s\n", phy_name);
>  
>  	return 0;
>  }
> @@ -375,7 +376,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
>  	 * PHY speed which is needed for bcmgenet_mii_config() to configure
>  	 * things appropriately.
>  	 */
> -	ret = bcmgenet_mii_config(dev);
> +	ret = bcmgenet_mii_config(dev, true);
>  	if (ret) {
>  		phy_disconnect(priv->phydev);
>  		return ret;
> 

Looks good to me.

Reviewed-by: Doug Berger <opendmb@gmail.com>
