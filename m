From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH net-next] tg3: Fix advertisement handling
Date: Tue, 22 Nov 2011 07:40:30 +0900
Message-ID: <20111122074030.ac247a36.shimoda.hiroaki@gmail.com>
References: <20111121080720.0e68f096.shimoda.hiroaki@gmail.com>
	<20111121192908.GA1198@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mchan@broadcom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48923 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904Ab1KUWkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 17:40:35 -0500
Received: by vbbfc21 with SMTP id fc21so3099086vbb.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 14:40:34 -0800 (PST)
In-Reply-To: <20111121192908.GA1198@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Nov 2011 11:29:08 -0800
"Matt Carlson" <mcarlson@broadcom.com> wrote:

> On Sun, Nov 20, 2011 at 03:07:20PM -0800, Hiroaki SHIMODA wrote:
> > Commit 28011cf19b (net: Add ethtool to mii advertisment conversion
> > helpers) added a helper function ethtool_adv_to_mii_100bt() and
> > tg3_copper_is_advertising_all(), tg3_phy_autoneg_cfg() were
> > modified to use this.
> > Before that commit, ethtool to mii advertisement conversion was
> > done wrt speed, but now pause operation is also taken account.
> > So, in tg3_copper_is_advertising_all(), below condition becomes
> > true and this makes link up fails.
> > 
> > 	if ((adv_reg & ADVERTISE_ALL) != all_mask)
> > 		return 0;
> > 
> > To fix this add ADVERTISE_ALL bit and operation to cap speed.
> > 
> > Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> 
> The root cause of this problem can actually be fixed by the following
> patch:
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 024ca1d..53e501c 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -13192,8 +13192,7 @@ static u32 __devinit tg3_read_otp_phycfg(struct tg3 *tp)
>  
>  static void __devinit tg3_phy_init_link_config(struct tg3 *tp)
>  {
> -	u32 adv = ADVERTISED_Autoneg |
> -		  ADVERTISED_Pause;
> +	u32 adv = ADVERTISED_Autoneg;
>  
>  	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY))
>  		adv |= ADVERTISED_1000baseT_Half |
> 
> Could you add it as part of this patch?

Ok.

> 
> Technically the above patch should fix the problem, but this patch makes
> the code clearer, should the same type of error pop up in the future.
> 
> More comments below.
> 
> > ---
> >  drivers/net/ethernet/broadcom/tg3.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > index 024ca1d..c00e648 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > @@ -3594,7 +3594,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
> >  	u32 val, new_adv;
> >  
> >  	new_adv = ADVERTISE_CSMA;
> > -	new_adv |= ethtool_adv_to_mii_100bt(advertise);
> > +	new_adv |= ethtool_adv_to_mii_100bt(advertise) & ADVERTISE_ALL;
> >  	new_adv |= tg3_advert_flowctrl_1000T(flowctrl);
> >  
> >  	err = tg3_writephy(tp, MII_ADVERTISE, new_adv);
> > @@ -3783,7 +3783,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
> >  	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
> >  		return 0;
> >  
> > -	if ((adv_reg & ADVERTISE_ALL) != all_mask)
> > +	if ((adv_reg & ADVERTISE_ALL) != (all_mask & ADVERTISE_ALL))
> 
> Rather than ANDing the all_mask here, can you make it look like the 1st
> hunk of your patch by ANDing the value returned by
> ethtool_adv_to_mii_100bt()?  I plan on further changes in this area and
> the uniformity will help.

Ok.

I'll send V2 with Eric's Reported-by tag.

Thanks.

> 
> >  		return 0;
> >  
> >  	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
> > 
> 
