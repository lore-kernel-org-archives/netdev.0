From: Stas Sergeev <stsp@list.ru>
Subject: Re: [BUG,BISECTED] mvneta: second interface no more usable on mirabox
Date: Wed, 17 Jun 2015 16:24:14 +0300
Message-ID: <558174FE.8010403@list.ru>
References: <87a8vz72hr.fsf@natisbad.org> <5580A4C3.1020509@list.ru> <874mm71cgb.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback8.mail.ru ([94.100.181.110]:36301 "EHLO
	fallback8.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754519AbbFQNow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 09:44:52 -0400
Received: from smtp22.mail.ru (smtp22.mail.ru [94.100.181.177])
	by fallback8.mail.ru (mPOP.Fallback_MX) with ESMTP id BDBA9854734A
	for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 16:24:25 +0300 (MSK)
In-Reply-To: <874mm71cgb.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

17.06.2015 02:05, Arnaud Ebalard =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> But it seems the patch can still change a couple of flags
>> for you, and maybe that makes a problem?
> AFAICT, autoneg config register (MVNETA_GMAC_AUTONEG_CONFIG) is
> modified.
Or, else, prevented from being modified at a couple of
bits that were wrongly cleared before. That code is now
used by both autoneg and mdio modes, so clearing the
autoneg bits is not possible (and not needed).
Unfortunately I haven't checked if these bits are ever
properly initialized. They are not. :( I think my u-boot did
that for me, and for you - only for the first interface.

>   And the logic when link status changes is also modified:
>   - MVNETA_GMAC_FORCE_LINK_DOWN flag cleared when there is carrier. I=
t was
>     previously set when that event occured.
>   - The link down event logic is also modified.
This was needed to properly update the MAC status
register. It wasn't used before my patch, because the
status was retrieved with MDIO, and even with my patch
it is used only for inbound status, but I felt it would be
good to have it properly updated in all cases, to avoid the
surprises in the future. AFAIK these bits are only mirrored
by the relevant bits in the status register, and nothing more.

>> Please try the attached (absolutely untested) patch.
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/eth=
ernet/marvell/mvneta.c
>> index ce5f7f9..74176ec 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -1013,6 +1013,12 @@ static void mvneta_defaults_set(struct mvneta=
_port *pp)
>>   		val =3D mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
>>   		val |=3D MVNETA_GMAC_1MS_CLOCK_ENABLE;
>>   		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
>> +	} else {
>> +		val =3D mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
>> +		val &=3D ~(MVNETA_GMAC_INBAND_AN_ENABLE |
>> +		       MVNETA_GMAC_AN_SPEED_EN |
>> +		       MVNETA_GMAC_AN_DUPLEX_EN);
>> +		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
>>   	}
>>  =20
>>   	mvneta_set_ucast_table(pp, -1);
> *Second interface is back w/ that patch applied*. Cannot tell if it i=
s a
>   proper fix, though or a valid workaround.
I think it is a proper fix - adding a missing initialization.
Previously that initialization was hidden in a completely
unexpected place, from where I had to remove it, but
forgot to re-add elsewhere.

> Thanks for your feedback.
Thanks for your testing, I'll submit a patch in a few days.
