From: Maxime Morin <maxime.morin@vitec.com>
Subject: Re: Problem: net: mvneta: auto-negotiation with disconnected network
 cable
Date: Thu, 23 Mar 2017 11:30:04 +0000
Message-ID: <AM4PR0501MB270859E18A4D7F73F297AF64943F0@AM4PR0501MB2708.eurprd05.prod.outlook.com>
References: <DB6PR0501MB2712340C8CDC37F3038766AD943C0@DB6PR0501MB2712.eurprd05.prod.outlook.com>,<c5e143f0-f6b4-ff74-4239-e64ca025821b@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>
To: Stas Sergeev <stsp@list.ru>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10052.outbound.protection.outlook.com ([40.107.1.52]:9282
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753871AbdCWLbD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 07:31:03 -0400
In-Reply-To: <c5e143f0-f6b4-ff74-4239-e64ca025821b@list.ru>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Thank you very much for your help and your reactivity! See my answer bellow=
:

> 22.03.2017 16:23, Maxime Morin =D0=C9=DB=C5=D4:
> > Hi all,
> >
> > I work on an embedded platform based on the Marvell Armada 88F6707, tha=
t is connected to a Marvell Alaska 88E1512 ethernet transceiver. A defect h=
as appeared recently, and it turns out to be a regression on the network pa=
rt. There is a complete lost of the network when following these steps:
> >      1) boot the board with the network cable disconnected
> >      2) run the following commands (or equivalent):
> >          ip link set eth0 up
> >          ip addr add 10.0.0.80/24 dev eth0
> >          ethtool -s eth0 autoneg on #this is the command that really br=
eaks the network
> Why do you call it a regression, if previously
> this command did nothing at all?

I called that a regression because we still pass through the function phy_e=
thtool_sset(), which I though was also doing something about the auto-negot=
iation. But apparently not.

>=20
> >      3) plug the network cable
> >          =3D> there is no network, and no way to have it back except by=
 rebooting
> > If I do not launch the "ethtool" command, when I plug the network cable=
 it works, so it really seems to be related to the auto-negotiation set to =
"on" when the network cable has never been > connected.
> So if you do that with the cable plugged it, there
> is no breakage?
> When you do "ethtool -s eth0 autoneg off" it doesn't
> revive?

Unfortunately no, it does not. I tried many things with ethtool, but it nev=
er gets back.

> > I did a "git bisect" to find when the regression was introduced, becaus=
e it previously worked with kernel 4.4, but not with the recent ones. The c=
ommit that made appear the issue is this one: https://git.kernel.org/pub/sc=
m/linux/kernel/git/torvalds/linux.git/commit/?id=3D0c0744fc1dd5b
> > If I remove on mvneta.c the part that was added on this commit on the f=
unction mvneta_ethtool_set_link_ksettings (mvneta_ethtool_set_settings at t=
hat time), I do not have the issue, but I can't call that a fix...
> > So, could it be a driver issue, or maybe a wrong configuration somewher=
e? If you need additional information to reproduce the problem please ask m=
e, I will be as responsive as possible.
> It seems mvneta_set_autoneg() does some non-symmetric
> things. It clears
> MVNETA_GMAC_FORCE_LINK_PASS |
> MVNETA_GMAC_FORCE_LINK_DOWN |
> MVNETA_GMAC_AN_FLOW_CTRL_EN
> when enabling autoneg, and does not restore these flags
> when disabling it. Try to make it to set or to restore these
> flags and see if that makes "ethtool -s eth0 autoneg off" to
> get the network back alive> .

As you suggested, I just set these three flags when the function is called =
with "enable" set to 0. And it works!
Actually, I did not even have to set autoneg to off. When the module is pro=
bed, the default param are applied (mvneta_defaults_set()), and mvneta_set_=
autoneg() is called with "enable" to 0, and it seems to fix everything. I t=
ested it then, by setting autoneg to off/on, booting with or without the ca=
ble plugged, and I failed to break it. It seems to be fixed. Should I submi=
t a patch? (would be the first time...)

Again, thanks a lot for your help.=
