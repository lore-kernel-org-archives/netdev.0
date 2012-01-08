From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH net-next 1/7] via-rhine: factor out tx_thresh handling
Date: Sun, 8 Jan 2012 06:13:14 +0100
Message-ID: <CACPM=kUAaM9qX566gJg50m3cE9kmop-wVRNdF-AMzEwSVTRESw@mail.gmail.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
	<20120107224941.GA25021@electric-eye.fr.zoreil.com>
	<CACPM=kVKm1xYnBGJ_-ABaBkLcSApnixagQhqmgi89OfCTn5ktQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rl@hellgate.ch,
	David Miller <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:35481 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab2AHFNP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2012 00:13:15 -0500
Received: by iaeh11 with SMTP id h11so4950666iae.19
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2012 21:13:14 -0800 (PST)
In-Reply-To: <CACPM=kVKm1xYnBGJ_-ABaBkLcSApnixagQhqmgi89OfCTn5ktQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/8 Bjarke Istrup Pedersen <gurligebis@gentoo.org>:
> 2012/1/7 Francois Romieu <romieu@fr.zoreil.com>:
>> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>> ---
>> =A0drivers/net/ethernet/via/via-rhine.c | =A0 17 ++++++++++++-----
>> =A01 files changed, 12 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethe=
rnet/via/via-rhine.c
>> index 5c4983b..93987e8 100644
>> --- a/drivers/net/ethernet/via/via-rhine.c
>> +++ b/drivers/net/ethernet/via/via-rhine.c
>> @@ -657,6 +657,16 @@ static void rhine_poll(struct net_device *dev)
>> =A0}
>> =A0#endif
>>
>> +static void rhine_kick_tx_threshold(struct rhine_private *rp)
>> +{
>> + =A0 =A0 =A0 if (rp->tx_thresh < 0xe0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rp->tx_thresh +=3D 0x20;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BYTE_REG_BITS_SET(rp->tx_thresh, 0x80,=
 ioaddr + TxConfig);
>> + =A0 =A0 =A0 }
>> +}
>> +
>> =A0static int rhine_napipoll(struct napi_struct *napi, int budget)
>> =A0{
>> =A0 =A0 =A0 =A0struct rhine_private *rp =3D container_of(napi, struc=
t rhine_private, napi);
>> @@ -1910,8 +1920,7 @@ static void rhine_error(struct net_device *dev=
, int intr_status)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0intr_status);
>> =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0if (intr_status & IntrTxUnderrun) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rp->tx_thresh < 0xE0)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BYTE_REG_BITS_SET((rp-=
>tx_thresh +=3D 0x20), 0x80, ioaddr + TxConfig);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_kick_tx_threshold(rp);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (debug > 1)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_info(dev, "Tra=
nsmitter underrun, Tx threshold now %02x\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0rp->tx_thresh);
>> @@ -1923,9 +1932,7 @@ static void rhine_error(struct net_device *dev=
, int intr_status)
>> =A0 =A0 =A0 =A0if ((intr_status & IntrTxError) &&
>> =A0 =A0 =A0 =A0 =A0 =A0(intr_status & (IntrTxAborted |
>> =A0 =A0 =A0 =A0 =A0 =A0 IntrTxUnderrun | IntrTxDescRace)) =3D=3D 0) =
{
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rp->tx_thresh < 0xE0) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BYTE_REG_BITS_SET((rp-=
>tx_thresh +=3D 0x20), 0x80, ioaddr + TxConfig);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_kick_tx_threshold(rp);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (debug > 1)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_info(dev, "Uns=
pecified error. Tx threshold now %02x\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0rp->tx_thresh);
>> --
>> 1.7.6.4
>>
>
> Still net-next, or should they be applied on top of mainline 3.2? :)
>
> /Bjarke

Hey again,

Nevermind, my mail client seems to have ate the first mail of the set
that mentions it :)
I'll test it later today :)

/Bjarke
