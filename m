From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: bcmgenet: Remove excessive PHY reset
Date: Thu, 16 Jul 2015 12:25:15 -0700
Message-ID: <55A8051B.4060506@gmail.com>
References: <1436902678-19028-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36053 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbbGPT1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 15:27:03 -0400
Received: by pdjr16 with SMTP id r16so49234366pdj.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 12:27:02 -0700 (PDT)
In-Reply-To: <1436902678-19028-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/07/15 12:37, Florian Fainelli wrote:
> We are currently issuing multiple PHY resets during a suspend/resume,
> first during bcmgenet_power_up() which does a hardware reset, then a
> software reset by calling bcmgenet_mii_reset(). This is both unnecessary
> and can take as long as 10ms per MDIO transactions while we re-apply
> workarounds because we do not yet have MDIO interrupts enabled.
> 
> phy_resume() takes care of re-apply our workarounds in case we need any,
> and bcmgenet_power_up() does a PHY hardware reset, all of this is more
> than enough to guarantee that the PHY operates correctly.

David, please discard this version, I will send one which actually
compiles, sorry about that.

> 
> Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c |  3 ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 -
>  drivers/net/ethernet/broadcom/genet/bcmmii.c   | 10 ----------
>  3 files changed, 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 64c1e9db6b0b..674f374dceee 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -907,9 +907,6 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
>  	}
>  
>  	bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
> -
> -	if (mode == GENET_POWER_PASSIVE)
> -		bcmgenet_mii_reset(priv->dev);
>  }
>  
>  /* ioctl handle special commands that are not present in ethtool. */
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> index 6159deab8c98..9f9ac0089d4d 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> @@ -672,7 +672,6 @@ GENET_IO_MACRO(rbuf, GENET_RBUF_OFF);
>  int bcmgenet_mii_init(struct net_device *dev);
>  int bcmgenet_mii_config(struct net_device *dev, bool init);
>  void bcmgenet_mii_exit(struct net_device *dev);
> -void bcmgenet_mii_reset(struct net_device *dev);
>  void bcmgenet_phy_power_set(struct net_device *dev, bool enable);
>  void bcmgenet_mii_setup(struct net_device *dev);
>  
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> index adf23d2ac488..2a8f97299b13 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> @@ -163,16 +163,6 @@ void bcmgenet_mii_setup(struct net_device *dev)
>  	phy_print_status(phydev);
>  }
>  
> -void bcmgenet_mii_reset(struct net_device *dev)
> -{
> -	struct bcmgenet_priv *priv = netdev_priv(dev);
> -
> -	if (priv->phydev) {
> -		phy_init_hw(priv->phydev);
> -		phy_start_aneg(priv->phydev);
> -	}
> -}
> -
>  void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
>  {
>  	struct bcmgenet_priv *priv = netdev_priv(dev);
> 


-- 
Florian
