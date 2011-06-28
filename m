From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 22:22:00 +0200
Message-ID: <20110628202200.GB2121496@jupiter.n2.diac24.net>
References: <BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
 <20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
 <BANLkTin4XOCmpFaETsjkYb2kk+psZUBKcA@mail.gmail.com>
 <BANLkTimD+fvhrhpc+kPXt1qMnQvVi2dw=Q@mail.gmail.com>
 <20110628150257.GB126252@jupiter.n2.diac24.net>
 <20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
 <20110628160018.GC126252@jupiter.n2.diac24.net>
 <BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
 <20110628185811.GA2121496@jupiter.n2.diac24.net>
 <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:42515 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670Ab1F1UWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 16:22:10 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2011 at 09:00:16PM +0100, Nick Carter wrote:
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* If STP =
is turned off, then forward */
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (p->br->stp_=
enabled =3D=3D BR_NO_STP && dest[5] =3D=3D 0)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (p->br->stp_=
enabled =3D=3D BR_NO_STP &&
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 (dest[5] =3D=3D 0 || skb->protocol =3D=3D htons(ETH_P_PAE)))
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 goto forward;
> >> Nick
> >
> > That code actually looks quite wrong to me, we should be forwarding=
 all of
> > the 01:80:C2:00:00:0x groups in non-STP mode, especially :0E and :0=
D.
> > (LLDP and GVRP/MVRP)
> >
> > Pause frames are the one exception that makes the rule, but as the
> > comment a few lines above states, "Pause frames shouldn't be passed=
 up by
> > driver anyway".
> >
> > Btw, what might make sense is a general knob for forwarding those
> > link-local groups, split off from the STP switch so the STP switch
> > controls only the :00 (STP) group. That way you can decide separate=
ly
> > whether you want to be LLDP/GVRP/802.1X/... transparent and whether=
 you
> > want to run STP.
>=20
> Sounds good to me.  So we go for :03, :0D, and :0E.  We cant touch :0=
2 see:
>  commit f01cb5fbea1c1613621f9f32f385e12c1a29dde0
>  Revert "bridge: Forward reserved group addresses if !STP"
>=20
> > Not sure if it's needed, it can always be done with ebtables...
> What would be the ebtables rules to achieve the forwarding of :03 ?  =
I
> asked this question on the netfilter list and the only response I got
> said ebtables was a filter and could not do this. :03 is hitting
> NF_BR_LOCAL_IN.  How would you 'reinject' it so it is forwarded ?

'reinject' isn't possible when it hits that code path - which is pretty
much why I'm saying we should be forwarding everything in the non-STP
case.

I have to read up on the bonding interactions, but to my understanding
the only reasonable usage case is to have the bond below the bridge lik=
e
 eth0 \
      |- bond0 - br0
 eth1 /
then the bonding should receive (and consume) the packets before they
reach the bridge.

(Some quick googling reveals that hardware switch chips special-drop
01:80:c2:00:00:01 [802.3x/pause] and :02 [802.3ad/lacp] and nothing
else - for the dumb ones anyway. It also seems like the match for pause
frames usually works on the address, not on the protocol field like we
do it...)


-David

