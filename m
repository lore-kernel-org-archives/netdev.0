From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 1/2] bgmac: drop duplicated PHY defines
Date: Tue, 10 Dec 2013 18:36:49 +0100
Message-ID: <CACna6rzRVQYrOnnJQiHE83d+aj6Hf693gnLY-m-iWffffzD3jQ@mail.gmail.com>
References: <1386668966-24562-1-git-send-email-zajec5@gmail.com>
	<CAGVrzcYCT0QUKuRGktH-4xVrXtort-Uy4phvq8yZg3nU8SPFjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:46091 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597Ab3LJRgu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:36:50 -0500
Received: by mail-ob0-f181.google.com with SMTP id uy5so5707571obc.12
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 09:36:50 -0800 (PST)
In-Reply-To: <CAGVrzcYCT0QUKuRGktH-4xVrXtort-Uy4phvq8yZg3nU8SPFjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/10 Florian Fainelli <f.fainelli@gmail.com>:
> Hello Rafal
>
> 2013/12/10 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>> ---
>>  drivers/net/ethernet/broadcom/bgmac.c |    6 ++----
>>  drivers/net/ethernet/broadcom/bgmac.h |   21 ---------------------
>>  2 files changed, 2 insertions(+), 25 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/eth=
ernet/broadcom/bgmac.c
>> index 0452937..ad4b2f1 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>> @@ -725,11 +725,9 @@ static void bgmac_phy_reset(struct bgmac *bgmac=
)
>>         if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
>>                 return;
>>
>> -       bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL,
>> -                       BGMAC_PHY_CTL_RESET);
>> +       bgmac_phy_write(bgmac, bgmac->phyaddr, MII_BMCR, BMCR_RESET)=
;
>>         udelay(100);
>> -       if (bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL) &
>> -           BGMAC_PHY_CTL_RESET)
>> +       if (bgmac_phy_read(bgmac, bgmac->phyaddr, MII_BMCR) & BMCR_R=
ESET)
>>                 bgmac_err(bgmac, "PHY reset failed\n");
>>         bgmac_phy_init(bgmac);
>
> phy_init_hw() now issues a PHY reset through BMCR_RESET, you might
> want to use it instead of this here:
>
> - the 100 microseconds delay might not be sufficient for all PHYs out=
 there
> - any PHY fixup (although there are none for BCM47xx yet) would be
> wiped out by this "wild" PHY reset
>
> This is quite new, so I do not expect you knew about this.

Thanks for pointing that! I was looking for BMCR_RESET usages with:
http://lxr.free-electrons.com/ident?v=3D3.12;i=3DBMCR_RESET
but it didn't find any interesting (because it uses 3.12 kernel sources=
).

This udelay is from specs based on Broadcom's code. What you have in
phy_poll_reset sounds indeed much more sane.

If you take a look at bgmac_phy_init, it actually has kind of fixups.
They are just programmed per-Broadcom chip id and not per PHY id as
you normally do that with phy_register_fixup_for_uid. But I think we
should be able to workaround that.

So I fully agree we should use phy_init_hw, but I think we should
implement that in a separated patch and on top of PHY cleanups I
recently did. Just to simplify bisecting potential regressions.

Are you OK with applying this patch as-is and working on another one
cleaning PHY reset/init in a nicer way?

--=20
Rafa=C5=82
