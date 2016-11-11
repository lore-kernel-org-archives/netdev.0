From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: marvell: optimize logic for page changing
 during init
Date: Thu, 10 Nov 2016 18:34:19 -0800
Message-ID: <5b63b127-85e3-a866-2032-56142b3e7b91@gmail.com>
References: <20161110140301.13381-1-uwe@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35686 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965673AbcKKCeW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 21:34:22 -0500
Received: by mail-it0-f68.google.com with SMTP id b123so7586291itb.2
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 18:34:21 -0800 (PST)
In-Reply-To: <20161110140301.13381-1-uwe@kleine-koenig.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/11/2016 à 06:03, Uwe Kleine-König a écrit :
> Instead of remembering if the page was changed, just compare the current
> page to the saved one. This is easier and has the advantage to save a
> register write if the page was already restored.

Seems reasonable to me:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Signed-off-by: Uwe Kleine-König <uwe@kleine-koenig.org>
> ---
>  drivers/net/phy/marvell.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index c2dcf02df202..fa31f50824d3 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -361,7 +361,7 @@ static int m88e1111_config_aneg(struct phy_device *phydev)
>  static int marvell_of_reg_init(struct phy_device *phydev)
>  {
>  	const __be32 *paddr;
> -	int len, i, saved_page, current_page, page_changed, ret;
> +	int len, i, saved_page, current_page, ret;
>  
>  	if (!phydev->mdio.dev.of_node)
>  		return 0;
> @@ -374,7 +374,6 @@ static int marvell_of_reg_init(struct phy_device *phydev)
>  	saved_page = phy_read(phydev, MII_MARVELL_PHY_PAGE);
>  	if (saved_page < 0)
>  		return saved_page;
> -	page_changed = 0;
>  	current_page = saved_page;
>  
>  	ret = 0;
> @@ -388,7 +387,6 @@ static int marvell_of_reg_init(struct phy_device *phydev)
>  
>  		if (reg_page != current_page) {
>  			current_page = reg_page;
> -			page_changed = 1;
>  			ret = phy_write(phydev, MII_MARVELL_PHY_PAGE, reg_page);
>  			if (ret < 0)
>  				goto err;
> @@ -411,7 +409,7 @@ static int marvell_of_reg_init(struct phy_device *phydev)
>  
>  	}
>  err:
> -	if (page_changed) {
> +	if (current_page != saved_page) {
>  		i = phy_write(phydev, MII_MARVELL_PHY_PAGE, saved_page);
>  		if (ret == 0)
>  			ret = i;
> 


-- 
Florian
