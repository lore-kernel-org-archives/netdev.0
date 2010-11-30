From: =?utf-8?q?Micha=C5=82?= =?utf-8?b?TWlyb3PFgmF3?=
	<mirq-linux@rere.qmqm.pl>
Subject: Re: Broken TX checksumming offloads
Date: Tue, 30 Nov 2010 15:23:52 +0100
Message-ID: <fddashfjkasdhklfjashlkjfs@rechot.qmqm.pl>
References: <AANLkTi=U51Y7rsQXr+_6TreUks_MyRMdRU=TtdxKOG2Z@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vget.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:56634 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752246Ab0K3OwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 09:52:15 -0500
In-Reply-To: <AANLkTi=U51Y7rsQXr+_6TreUks_MyRMdRU=TtdxKOG2Z@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 29, 2010 at 06:35:44PM -0800, Jesse Gross wrote:
> 2010/11/29 Ben Hutchings <bhutchings@solarflare.com>:
> > On Mon, 2010-11-29 at 19:17 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> >> Hi!
> >>
> >> Unless I'm horribly mistaken, generic HW checksumming works as fol=
lows:
> >> =C2=A0- driver sets netdev->features & NETIF_F_HW_CSUM to indicate=
 support
> >> =C2=A0 =C2=A0for generic checksumming; if the flag is not set, net=
working core
> >> =C2=A0 =C2=A0will checksum skb before calling ndo_start_xmit (let'=
s ignore
> >> =C2=A0 =C2=A0other checksumming options for now) and not pass skb =
with
> >> =C2=A0 =C2=A0skb->ip_summed =3D=3D CHECKSUM_PARTIAL
> >> =C2=A0- ndo_start_xmit() should use skb->csum_start and skb->csum_=
offset
> >> =C2=A0 =C2=A0(or skb->csum) to update checksum in software or inst=
ruct HW to do so
> >>
> >> Looking at pch_gbe_xmit_frame() and its callee - pch_gbe_tx_queue(=
) it
> >> looks like the driver should set NETIF_F_IP_CSUM instead of NETIF_=
=46_HW_CSUM
> >> feature.
> >>
> >> Similar thing happens in ixgbe driver: it sets NETIF_F_HW_CSUM and=
 checks
> >> for skb->ip_summed =3D=3D CHECKSUM_PARTIAL, but then just warns on=
 protocols
> >> other that TCP and SCTP (see: ixgbe_psum()).
> >
> > AFAIK only {TCP,UDP}/IPv{4,6} use the simple 16-bit checksum algori=
thm
> > that NETIF_F_HW_CSUM implies, so in practice it is equivalent to
> > NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM even though it doesn't mean the=
 same
> > thing.
>=20
> There are a few cases that I can think of where the extra generality
> of NETIF_F_HW_CSUM is useful:
>=20
> * The checksum in GRE (maybe other protocols as well) uses the same
> algorithm as TCP/UDP.  In theory this means that we could use hardwar=
e
> offloading for GRE on cards that have NETIF_F_HW_CSUM.  The one issue
> is that NETIF_F_IP_CSUM really means TCP/UDP checksumming but we only
> test if the protocol is IP.  This means that other IP based protocols
> (like GRE) can't use checksum offloading since there is no software
> fallback path.
>=20
> * TCP/UDP packets that are deeply encapsulated.  Currently we can
> express that checksum offloading is supported in one level of vlan
> encapsulation through vlan_features.  However, a NIC that exposes
> NETIF_F_HW_CSUM should in theory be able to checksum over a packet
> that has an arbitrary number of vlan tags in front of it, a GRE
> header, or any other type of encapsulation.

So the following patches should fix what's in tree regarding
NETIF_F_HW_CSUM interpretation. The patches have no interdependencies,
so can be applied independently. The last one is a cleanup that tagged
along.

Drivers that didn't care about csum_{start,offset}:

benet
bnx2x
jme
pch_gbe
sc92031
stmmac
vxge

Best Regards,
Micha=C5=82 Miros=C5=82aw
