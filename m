From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Mon, 18 Mar 2013 12:06:22 +0200
Message-ID: <1363601182.4752.13.camel@lb-tlvb-eilong.il.broadcom.com>
References: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
 <1363384577-21287-1-git-send-email-zenczykowski@gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F20BE6A2B@SJEXCHMB06.corp.ad.broadcom.com>
 <20130317.142425.1713640249735424829.davem@davemloft.net>
 <1363549074.4752.3.camel@lb-tlvb-eilong.il.broadcom.com>
 <1363551952.29475.93.camel@edumazet-glaptop>
 <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
 <CANP3RGdZHMTPT6FTbYzSOHkrNq4seF1WcXjysQ6=HEp0A_CxWg@mail.gmail.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Linux NetDev" <netdev@vger.kernel.org>,
	"Mintz Yuval" <yuvalmin@broadcom.com>
To: "Maciej =?UTF-8?Q?=C5=BBenczykowski?=" <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3588 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355Ab3CRKKV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 06:10:21 -0400
In-Reply-To: <CANP3RGdZHMTPT6FTbYzSOHkrNq4seF1WcXjysQ6=HEp0A_CxWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-17 at 23:18 -0700, Maciej =C5=BBenczykowski wrote:
> This has nothing to do with atomicity or races or anything.
>=20
> Look at the ADD_64 macro (which implements a +=3D b) and compare it t=
o
> this one (which implents a =3D b + c).
>=20
> It simply doesn't know how to correctly add in any situation in which
> "qstats_old->t..._lo !=3D 0".
> By this point all the stats are already in software and both firmware
> and hardware is not relevant.
>=20
> Normally qstats_old starts off at 0 and the bug isn't visible (since
> with a value of 0, there can't be overflow and carry propagation is
> not needed).
>=20
> The reason qstats_old was introduced was to allow for a partial nic
> reset [or whatever the proper term is] which resets fw/hw provided
> stats to not reset sw exported stats.
> During the reset old stats are copied into qstats_old, and in the
> future stats are returned as "qstats_old + current stats from fw/hw"
> except this addition is buggy and only works if qstats_old happens to
> have lower 32-bits zero (ie. basically only before first partial nic
> reset).
>=20
> Imagine:
> (a) driver initializes, nic gets brought up, qstats_old =3D 0, stats
> from device =3D 0
> (b) 2GB of xfer happens
> (c) qstats_old still =3D 0, stats from device =3D 2GB
> (d) addition happens qstats =3D qstats_old + stats_from_dev =3D 0 + 2=
GB =3D
> 2GB   --- we report 2GB xfer
> (e) something partially resets nic (say mtu change), qstats_old =3D 2=
GB,
> stats from device =3D 0
> (f) 2GB-1 of xfer happens
> (g) qstats_old =3D 2GB, stats from device =3D 2GB-1
> (h) addition happens qstats =3D qstats_old + stats_from_dev =3D 2GB +
> 2GB-1 =3D 4GB-1   --- we report 4GB-1 xfer
> (i) 1 byte of xfer happens
> (j) qstats_old =3D 2GB, stats from device =3D 2GB
> (k) addition happens qstats =3D qstats_old + stats_from_dev =3D 2GB +=
 2GB
> =3D 0   --- we report 0 xfer
> (l) 2GB of xfer happens
> (m) qstats_old =3D 2GB, stats from device =3D 4GB
> (n) addition happens qstats =3D qstats_old + stats_from_dev =3D 2GB +=
 4GB
> =3D 6GB   --- we report 6GB xfer
>=20
> And yes the macro in question when asked to do 2GB+2GB will return 0.
>=20
> (btw. at least on the driver I tested there's still some weirdness
> with mtu change not-resetting per-queue stats but resetting
> coalesced-from-all-queues stats)
>=20
> Now, to be fair, I don't yet have confirmation that my patch fixes th=
e
> problem our SREs saw in deployment, but I expect to have that soon.
> (and even if it doesn't fix the problem, this code is still buggy and
> should be fixed)
>=20
> Maciej

Maciej - thanks for the detailed information. You are right - it has
nothing to do with the HW/FW and it is simply a bug that needs to be
fixed. I withdraw my objections and add my ACK.

Acked-by: Eilon Greenstein <eilong@broadcom.com>
