From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 21:54:01 +0100
Message-ID: <BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
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
	<20110628202200.GB2121496@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:65432 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab1F1UyB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 16:54:01 -0400
Received: by pvg12 with SMTP id 12so337377pvg.19
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2011 13:54:01 -0700 (PDT)
In-Reply-To: <20110628202200.GB2121496@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2011 21:22, David Lamparter <equinox@diac24.net> wrote:
> On Tue, Jun 28, 2011 at 09:00:16PM +0100, Nick Carter wrote:
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If STP is turned off, then for=
ward */
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO=
_STP && dest[5] =3D=3D 0)
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO=
_STP &&
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (dest[5] =3D=3D 0 |=
| skb->protocol =3D=3D htons(ETH_P_PAE)))
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto forward;
>> >> Nick
>> >
>> > That code actually looks quite wrong to me, we should be forwardin=
g all of
>> > the 01:80:C2:00:00:0x groups in non-STP mode, especially :0E and :=
0D.
>> > (LLDP and GVRP/MVRP)
>> >
>> > Pause frames are the one exception that makes the rule, but as the
>> > comment a few lines above states, "Pause frames shouldn't be passe=
d up by
>> > driver anyway".
>> >
>> > Btw, what might make sense is a general knob for forwarding those
>> > link-local groups, split off from the STP switch so the STP switch
>> > controls only the :00 (STP) group. That way you can decide separat=
ely
>> > whether you want to be LLDP/GVRP/802.1X/... transparent and whethe=
r you
>> > want to run STP.
>>
>> Sounds good to me. =A0So we go for :03, :0D, and :0E. =A0We cant tou=
ch :02 see:
>> =A0commit f01cb5fbea1c1613621f9f32f385e12c1a29dde0
>> =A0Revert "bridge: Forward reserved group addresses if !STP"
>>
>> > Not sure if it's needed, it can always be done with ebtables...
>> What would be the ebtables rules to achieve the forwarding of :03 ? =
=A0I
>> asked this question on the netfilter list and the only response I go=
t
>> said ebtables was a filter and could not do this. :03 is hitting
>> NF_BR_LOCAL_IN. =A0How would you 'reinject' it so it is forwarded ?
>
> 'reinject' isn't possible when it hits that code path - which is pret=
ty
> much why I'm saying we should be forwarding everything in the non-STP
> case.
I'm not sure I like this turn off STP and suddenly start forwarding
random groups.  There is no connection between wanting STP on / off
and forwarding pae on / off.  There is no dependencies between the
protocols.
Also on reflection I think a knob per mac group would be better.  We
are only interested in 3 and if I enable pae forwarding so I can
connect virtual machine supplicants, i don't then want to turn on LDP
forwarding which will needlessly hit my virtual machines.
So how about sysfs
=2E./bridge/pae_forwarding
=2E./bridge/ldp_forwarding
=2E./bridge/mvrp_forwarding
>
> I have to read up on the bonding interactions, but to my understandin=
g
> the only reasonable usage case is to have the bond below the bridge l=
ike
> =A0eth0 \
> =A0 =A0 =A0|- bond0 - br0
> =A0eth1 /
> then the bonding should receive (and consume) the packets before they
> reach the bridge.
>
> (Some quick googling reveals that hardware switch chips special-drop
> 01:80:c2:00:00:01 [802.3x/pause] and :02 [802.3ad/lacp] and nothing
> else - for the dumb ones anyway. It also seems like the match for pau=
se
> frames usually works on the address, not on the protocol field like w=
e
> do it...)
'Enterprise' switches drop :03 [802.1x]
Nick
>
>
> -David
>
>
