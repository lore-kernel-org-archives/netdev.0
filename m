From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] sis190: fix gigabit negotiation
Date: Tue, 2 Jun 2009 23:38:57 +0200
Message-ID: <20090602213857.GB26871@electric-eye.fr.zoreil.com>
References: <cover.1244012631.git.birrachiara@tin.it> <20090603095252.GA15419@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Riccardo Ghetta <birrachiara@tin.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57607 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750871AbZFBVhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:37:12 -0400
Content-Disposition: inline
In-Reply-To: <20090603095252.GA15419@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Riccardo Ghetta <birrachiara@tin.it> :
> Fixes an initialization error; the chip negotiates gigabit, but
> the driver mistakenly handled it as 100Mb.

Did you draw some inspiration from SiS own driver ? If so it would
deserve to be quoted.

> Hopefully should fix bugs 9735 and 11149

http://bugzilla.kernel.org/show_bug.cgi?id=9735
http://bugzilla.kernel.org/show_bug.cgi?id=11149

> 
> Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>
> ---
>  drivers/net/sis190.c |   37 +++++++++++++++++++++++++------------
>  1 files changed, 25 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
> index 3d4542e..8322e28 100644
> --- a/drivers/net/sis190.c
> +++ b/drivers/net/sis190.c
[...]
> @@ -956,22 +956,35 @@ static void sis190_phy_task(struct work_struct *work)
>  			{ LPA_10HALF, 0x04000400,
>  				"10 Mbps Half Duplex" },
>  			{ 0, 0x04000400, "unknown" }
> - 		}, *p;
> -		u16 adv;
> +		}, *p = NULL;
> +		u16 adv, autoexp, gigadv, gigrec;
>  
>  		val = mdio_read(ioaddr, phy_id, 0x1f);
>  		net_link(tp, KERN_INFO "%s: mii ext = %04x.\n", dev->name, val);
>  
>  		val = mdio_read(ioaddr, phy_id, MII_LPA);
>  		adv = mdio_read(ioaddr, phy_id, MII_ADVERTISE);
> -		net_link(tp, KERN_INFO "%s: mii lpa = %04x adv = %04x.\n",
> -			 dev->name, val, adv);
> -
> -		val &= adv;
> +		autoexp = mdio_read(ioaddr, phy_id, MII_EXPANSION);
> +		net_link(tp, KERN_INFO "%s: mii lpa=%04x adv=%04x exp=%04x.\n",
> +			 dev->name, val, adv, autoexp);
> +
> +		if (val & ADVERTISE_NPAGE && autoexp & EXPANSION_NWAY) {

val has been read from the LPA register.

s/ADVERTISE_NPAGE/LPA_NPAGE/ ?

> +			/* check for gigabit speed */
> +			gigadv = mdio_read(ioaddr, phy_id, MII_CTRL1000);
> +			gigrec = mdio_read(ioaddr, phy_id, MII_STAT1000);
> +			val = (gigadv & (gigrec >> 2));
> +			if (val & ADVERTISE_1000FULL)
> +				p = reg31;
> +			else if (val & ADVERTISE_1000HALF)
> +				p = reg31+1;
                                    ^^^^^^^ reg31 + 1

Otherwise ok.

-- 
Ueimor
