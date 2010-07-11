From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] bnx2x: add support for receive hashing
Date: Sun, 11 Jul 2010 19:41:33 +0200
Message-ID: <1278870093.2538.175.camel@edumazet-laptop>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FBFB@SJEXCHCCR02.corp.ad.broadcom.com>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FD52@SJEXCHCCR02.corp.ad.broadcom.com>
	 <AANLkTinRUJS6e8dwqvIMhtAUWBcj5oTk-D9MMrhbL9Bk@mail.gmail.com>
	 <20100710.191242.70196353.davem@davemloft.net>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDE64704DC@SJEXCHCCR02.corp.ad.broadcom.com>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDE64704FA@SJEXCHCCR02.corp.ad.broadcom.com>
	 <1278866713.2538.148.camel@edumazet-laptop>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDE6470521@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:61359 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646Ab0GKRlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 13:41:37 -0400
Received: by wwb13 with SMTP id 13so2598545wwb.1
        for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 10:41:35 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE6470521@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 11 juillet 2010 =C3=A0 10:22 -0700, Vladislav Zolotarov a =C3=
=A9crit :
>=20
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel=
=2Eorg] On
> > Behalf Of Eric Dumazet
> > Sent: Sunday, July 11, 2010 7:45 PM
> > To: Vladislav Zolotarov
> > Cc: David Miller; therbert@google.com; netdev@vger.kernel.org
> > Subject: RE: [PATCH] bnx2x: add support for receive hashing
> >=20
> > Le dimanche 11 juillet 2010 =C3=A0 06:16 -0700, Vladislav Zolotarov=
 a =C3=A9crit :
> > > Dave, it's obvious that there a demand for a new HW/FW configurat=
ion
> > > from our side - "rx hash enable" which is currently tightly coupl=
ed
> > > with the RSS capability. As long as RSS flow in our FW includes a=
 few
> > > more things apart from just creating an RSS hash and as long as t=
here
> > > are flows (even hypothetical) that demand the RSS hash regardless=
 the
> > > RSS itself we started to work on separation of these two features=
 from
> > > FW perspective. This of course will demand a new FW version but o=
nce
> > > we have it we'll be able to be more specific in HW configuration =
and
> > > have a cleaner code.
> > >
> > > Technically, our FW may provide the Rx HASH always and in a curre=
nt
> > > driver configuration this is what it does.
> > > I wonder if the driver always provides the HW RX HASH in the
> > > skb->rxhash regardless the value of NETIF_F_RXHASH bit in a
> > > netdev->features will it cause any harm? If not we can get rid of=
 two
> > > extra conditionals in the bnx2x_rx_int().
> >=20
> > Hi
> >=20
> > Please dont top-post on netdev, thanks.
>=20
> This discussion is directly related to Tom's patch that's why I'm pos=
ting on this thread.=20
>=20

Thats not the question. I am saying "dont top-post", not "dont change
the subject"

> >=20
> > NETIF_RX_HASH bit is needed so that we can disable skb->rxhash from=
 a
> > particular NIC if we know the hardware provided rxhash is not fulfi=
lling
> > our needs (We prefer spend some cpu cycles to recompute a software
> > rxhash).
> >=20
> > Software one for example deliver same rxhash values for both ways o=
f a
> > TCP flow, it can help conntracking for example.
>=20
> I understand that, in that case the proper implementation would be to=
 check the netdev->features when u decide to calculate the SW rxhash, i=
sn't it?
>=20

Nope, please check get_rps_cpus()

We only do :

if (skb->rxhash)
	goto got_hash; /* Skip hash computation on packet header */

That means if skb->rxhash is set, we dont force a recompute.

Your suggestion would move a test from device driver into
get_rps_cpus() ?

Given RPS is more targeted to old devices (not able to provide rxhash),
I am not sure it brings anything.

> >=20
> > The conditional in driver rx is cheap, since the condition is the s=
ame
> > for all packets and CPU can predicts the branch.
>=20
> Not exactly. Our FW/HW won't provide the rxhash for none-IP packets
> setting the hash CQE field to zero and clearing the
> ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG in the CQE statsu_flags (for ARPs
> for instance). Branch prediction is nice but considering my previous
> remark why do we need this branch at all?

Please limit your lines to 70 chars

We want drivers to set skb->rxhash only if allowed to.

If you feel this is bad for your firmware/hardware/driver, dont set
skb->rxhash.



