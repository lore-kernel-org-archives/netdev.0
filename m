From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,BISECTED] mvneta: second interface no more usable on mirabox
Date: Wed, 17 Jun 2015 01:05:24 +0200
Message-ID: <874mm71cgb.fsf@natisbad.org>
References: <87a8vz72hr.fsf@natisbad.org> <5580A4C3.1020509@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 36.223.133.77.rev.sfr.net ([77.133.223.36]:58412 "EHLO
	smtp.natisbad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757467AbbFPXFm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 19:05:42 -0400
In-Reply-To: <5580A4C3.1020509@list.ru> (Stas Sergeev's message of "Wed, 17
	Jun 2015 01:35:47 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Stas Sergeev <stsp@list.ru> writes:

> 17.06.2015 00:44, Arnaud Ebalard =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Hi,
>>
>> On Mirabox, the second ethernet interface is no more usable on 4.1-r=
c*
>> series (no packets coming out of the interface, when using dhclient =
for
>> instance). It works as expected on 4.0.
>>
>> Bisecting the issue, I ended up on 898b2970e2c9 ("mvneta: implement
>> SGMII-based in-band link state signaling"). Reverting that commit gi=
ves
>> me back the second interface.
>>
>> Then, I also tested on a NETGEAR ReadyNAS 104, which is also powered=
 by
>> the same SoC (Armada 370) and also has two (mvneta-supported) ethern=
et
>> interfaces. With an unmodified 4.1-rc8, only one of the two interfac=
es
>> is available. Reverting 898b2970e2c9 makes both usable again.
>>
>> FWIW, mirabox and RN104 ethernet interfaces use RGMII.
> Hi, hope someone who can reproduce the problem,
> can provide a better help.
> I looked into a patch, and it seems most things are done
> under "if (pp->use_inband_status)", which is not your case.

Looking at the patch, yes. Both platforms I have which encounter the
problem use RGMII and "if (pp->use_inband_status)" changes are for
SGMII.

> But it seems the patch can still change a couple of flags
> for you, and maybe that makes a problem?

AFAICT, autoneg config register (MVNETA_GMAC_AUTONEG_CONFIG) is
modified. And the logic when link status changes is also modified:
 - MVNETA_GMAC_FORCE_LINK_DOWN flag cleared when there is carrier. It w=
as
   previously set when that event occured.
 - The link down event logic is also modified.

>
> Please try the attached (absolutely untested) patch.
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethe=
rnet/marvell/mvneta.c
> index ce5f7f9..74176ec 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -1013,6 +1013,12 @@ static void mvneta_defaults_set(struct mvneta_=
port *pp)
>  		val =3D mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
>  		val |=3D MVNETA_GMAC_1MS_CLOCK_ENABLE;
>  		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
> +	} else {
> +		val =3D mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
> +		val &=3D ~(MVNETA_GMAC_INBAND_AN_ENABLE |
> +		       MVNETA_GMAC_AN_SPEED_EN |
> +		       MVNETA_GMAC_AN_DUPLEX_EN);
> +		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
>  	}
> =20
>  	mvneta_set_ucast_table(pp, -1);

*Second interface is back w/ that patch applied*. Cannot tell if it is =
a
 proper fix, though or a valid workaround.

Thanks for your feedback.

a+
