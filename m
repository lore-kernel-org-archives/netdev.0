From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [REGRESSION, BISECTED] Broken networking with net/phy/marvell
Date: Thu, 26 Oct 2017 16:12:32 +0300
Message-ID: <20171026131232.3bj236va56mawse4@mwanda>
References: <20171026122836.zoggs44rkasflr3m@darkstar.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18570 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932204AbdJZNM6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 09:12:58 -0400
Content-Disposition: inline
In-Reply-To: <20171026122836.zoggs44rkasflr3m@darkstar.musicnaut.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 03:28:36PM +0300, Aaro Koskinen wrote:
> Hi,
> 
> When upgrading from v4.13 to v4.14-rc6 on OpenRD Client, the box loses
> network connectivity.
> 
> Bisection points to:
> 
> commit 5987feb38aa55e035ce5376c02aba88a604cc881
> Author: Dan Carpenter <dan.carpenter@oracle.com>
> Date:   Fri Aug 4 11:17:21 2017 +0300
> 
>     net: phy: marvell: logical vs bitwise OR typo
>     
> However, it seems this commit just unhides another issue in the original
> commit 864dc729d528 ("net: phy: marvell: Refactor m88e1121 RGMII delay
> configuration"): when we are configuring the MSCR delay bits, we are
> probably clearing the bits with a wrong mask (i.e. we might be disabling
> something else not intended)...
> 
> I have tested the below change and it seems to fix the networking. Any
> comments?
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 15cbcdb..500d7c1 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -474,7 +474,7 @@ static int m88e1121_config_aneg_rgmii_delays(struct phy_device *phydev)
>  		goto out;
>  	}
>  
> -	mscr &= MII_88E1121_PHY_MSCR_DELAY_MASK;
> +	mscr &= ~MII_88E1121_PHY_MSCR_DELAY_MASK;
>  

I don't think your fix is right.  That mask was like that in the
original m88e1121_config_aneg() code before commit 864dc729d528 ("net:
phy: marvell: Refactor m88e1121 RGMII delay configuration").  Perhaps
the bug is that m88e1116r_config_init() used to not have the mask and
now it does?

Another difference I see is that we also didn't used to call
marvell_set_page(phydev, oldpage); on error, but I think that's a bugfix
and not related to what you're seeing.

I don't know the code well enough to write a fix.

regards,
dan carpenter
