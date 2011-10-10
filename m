From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: e100 + VLANs?
Date: Mon, 10 Oct 2011 17:05:52 +0200
Message-ID: <1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E90212D.8030009@msgid.tls.msk.ru>
	 <1318091046.5276.22.camel@edumazet-laptop> <4E9097C0.2030307@gmail.com>
	 <20111010101954.GB2840382@jupiter.n2.diac24.net>
	 <4E9307CB.4050704@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48022 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977Ab1JJPFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 11:05:39 -0400
Received: by bkbzt4 with SMTP id zt4so8571844bkb.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 08:05:38 -0700 (PDT)
In-Reply-To: <4E9307CB.4050704@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 octobre 2011 =C3=A0 18:57 +0400, Michael Tokarev a =C3=A9cr=
it :
> 10.10.2011 14:19, David Lamparter wrote:
> > On Sat, Oct 08, 2011 at 11:34:40AM -0700, Jeff Kirsher wrote:
> >> On 10/08/2011 09:24 AM, Eric Dumazet wrote:
> >>> Le samedi 08 octobre 2011 =C3=A0 14:08 +0400, Michael Tokarev a =C3=
=A9crit :
> >>>>> Yesterday I tried to use 802.1Q VLAN tagging with an (oldish)
> >>>>> e100-driven network card, identified by lspci like this:
> >>>>>
> >>>>>  00:12.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 E=
thernet Pro 100 (rev 02)
> >>>>>
> >>>>> Just to discover that it does not quite work: packets of
> >>>>> size 1497+ bytes gets lost.
> > [...]
> >>> e100 driver seems VLAN enabled at a first glance.
> >> Eric is correct, that e100 does support VLANs.
> >>
> >> In addition to Eric's suggestion, can you also provide all the out=
put of
> >> lspci -vvv for the network card?
> >=20
> > I'm opening the lore box here, but early e100 cards AFAIK have a=20
> > hardware limit at 1500 (+18 src/dst/proto) bytes. At least, Juniper=
's
> > JUNOS does not support full-sized .1Q on their e100 control plane
> > interfaces...
>=20
> Thank you all for the suggestions and feedback.
>=20
> The card may indeed be quite old, I don't know where it come from and
> when.  Here's lspci -vvv for it:
>=20
> 00:12.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet=
 Pro 100 (rev 02)
> 	Subsystem: Intel Corporation EtherExpress PRO/100B (TX)
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- =
Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <=
TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 66 (2000ns min, 14000ns max)
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: Memory at fe200000 (32-bit, prefetchable) [size=3D4K]
> 	Region 1: I/O ports at 2400 [size=3D32]
> 	Region 2: Memory at fc000000 (32-bit, non-prefetchable) [size=3D1M]
> 	[virtual] Expansion ROM at 30100000 [disabled] [size=3D1M]
> 	Kernel driver in use: e100
>=20
>=20
> I tried to set it up to talk to another machine in order to find
> out where the packets gets lost.  But had another complication
> on the way: it does not "want" to work with 802.1Q VLANs anymore
> at all... ;)
>=20
> When pinging this NIC from another machine over VLAN5, I see
> ARP packets coming to it, gets recognized and replies going
> back, all on vlan 5.  But on the other side, replies comes
> WITHOUT a VLAN tag!
>=20
> From this NIC's point of view, capturing on whole ethX:
>=20
> 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), len=
gth 60: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Req=
uest who-has 10.48.11.2 tell 10.48.11.1, length 42
> 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.1Q (0x8100), len=
gth 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Rep=
ly 10.48.11.2 is-at 00:90:27:30:6d:1c, length 28
>=20
> From the partner point of view, also on whole ethX:
>=20
> 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), len=
gth 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Req=
uest who-has 10.48.11.2 tell 10.48.11.1, length 28
> 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype ARP (0x0806), length=
 60: Ethernet (len 6), IPv4 (len 4), Reply 10.48.11.2 is-at 00:90:27:30=
:6d:1c, length 46
>=20
> So, the tag gets eaten somewhere along the way... ;)
>=20
> And I can't really recreate the situation which I had - I know
> some packets were flowing, so at least ARP worked.  Now it
> does not work anymore.

What the 'partner' setup looks like ?

ip link
ip addr
ip ro
