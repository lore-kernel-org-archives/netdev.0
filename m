From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 21:00:16 +0100
Message-ID: <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
	<20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
	<BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
	<20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
	<BANLkTin4XOCmpFaETsjkYb2kk+psZUBKcA@mail.gmail.com>
	<BANLkTimD+fvhrhpc+kPXt1qMnQvVi2dw=Q@mail.gmail.com>
	<20110628150257.GB126252@jupiter.n2.diac24.net>
	<20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
	<20110628160018.GC126252@jupiter.n2.diac24.net>
	<BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
	<20110628185811.GA2121496@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51961 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977Ab1F1UAQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 16:00:16 -0400
Received: by pvg12 with SMTP id 12so307416pvg.19
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2011 13:00:16 -0700 (PDT)
In-Reply-To: <20110628185811.GA2121496@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2011 19:58, David Lamparter <equinox@diac24.net> wrote:
> On Tue, Jun 28, 2011 at 07:34:57PM +0100, Nick Carter wrote:
>> > Yes, the default is a dumb hub (IMHO correctly so). And a dumb hub=
 will
>> > forward 802.1X packets (IMHO also correctly so).
>> >
>> > Why should we specifically add a knob for EAPOL? Next we're adding=
 one
>> > for STP itself, then one for LLDP, then one for Cisco's deprecated
>> > crap (CDP, DTP, ...) etc.
>> >
>> > If you want a dumb hub that drops EAPOL, use ebtables.
>> >
>> > -David
>> >
>> >
>> If we are not going to have an EAPOL knob, but we are going to act a=
s
>> a repeater when STP is off then we still need these diffs to forward
>> the PAE group address.
>> (In fact we cant just act as a repeater because of the recent ethern=
et
>> bonding regression)
>>
>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>> index 90e985b..267f581 100644
>> --- a/net/bridge/br_input.c
>> +++ b/net/bridge/br_input.c
>> @@ -163,7 +163,8 @@ struct sk_buff *br_handle_frame(struct sk_buff *=
skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If STP is turned off, then forwar=
d */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO_ST=
P && dest[5] =3D=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO_ST=
P &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (dest[5] =3D=3D 0 || s=
kb->protocol =3D=3D htons(ETH_P_PAE)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto forward;
>> Nick
>
> That code actually looks quite wrong to me, we should be forwarding a=
ll of
> the 01:80:C2:00:00:0x groups in non-STP mode, especially :0E and :0D.
> (LLDP and GVRP/MVRP)
>
> Pause frames are the one exception that makes the rule, but as the
> comment a few lines above states, "Pause frames shouldn't be passed u=
p by
> driver anyway".
>
> Btw, what might make sense is a general knob for forwarding those
> link-local groups, split off from the STP switch so the STP switch
> controls only the :00 (STP) group. That way you can decide separately
> whether you want to be LLDP/GVRP/802.1X/... transparent and whether y=
ou
> want to run STP.

Sounds good to me.  So we go for :03, :0D, and :0E.  We cant touch :02 =
see:
 commit f01cb5fbea1c1613621f9f32f385e12c1a29dde0
 Revert "bridge: Forward reserved group addresses if !STP"

> Not sure if it's needed, it can always be done with ebtables...
What would be the ebtables rules to achieve the forwarding of :03 ?  I
asked this question on the netfilter list and the only response I got
said ebtables was a filter and could not do this. :03 is hitting
NF_BR_LOCAL_IN.  How would you 'reinject' it so it is forwarded ?

Thanks
Nick

>
>
> -David
>
>
