From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave	instead
 of master
Date: Wed, 09 Mar 2011 15:49:49 +0100
Message-ID: <4D77938D.3080408@gmail.com>
References: <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com> <20110307224338.GU11864@gospo.rdu.redhat.com> <20110308071350.GA2826@psychotron.redhat.com> <20110308134247.GW11864@gospo.rdu.redhat.com> <4D76A345.9040200@gmail.com> <20110309074547.GA2808@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33095 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756988Ab1CIOty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 09:49:54 -0500
Received: by wya21 with SMTP id 21so490201wya.19
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2011 06:49:53 -0800 (PST)
In-Reply-To: <20110309074547.GA2808@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/03/2011 08:45, Jiri Pirko a =E9crit :
> Tue, Mar 08, 2011 at 10:44:37PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 08/03/2011 14:42, Andy Gospodarek a =E9crit :
>>> I'm pretty sure this patch will have the same catastrophic problem =
your
>>> last one did.  By cloning and setting skb2->dev =3D orig_dev you ju=
st
>>> inserted a frame identical to the one we received right back into t=
he
>>> stack.  It only took a few minutes for my box to melt as one frame =
on
>>> the wire will cause an infinite number of frames to be received by =
the
>>> stack.
>>
>> I agree with Andy. We still keep one reinject (netif_rx), which is
>> probably better that two (__netif_receive_skb), but not enough.
>>
>> I really think we need a general framework for late delivery of fina=
l
>> packets to packet handler registered somewhere in the rx_handler
>> path.
>>
>> Jiri, is this patch the one you announced as "I have some kind nice
>> solution in mind and I'm going to submit that as a patch later (too
>> many patches are in the wind atm)" ?
>
>
> I did not had time to verify my thought yet but I think that the only
> think needed against my original patch (bonding: move processing of r=
ecv
> handlers into handle_frame()) is ro remove vlan_on_bond_hook, period.
>
> Because all incoming arps are seen by bond_handle_frame =3D>
> bond->recv_probe , even vlan ones - that would make eth0-bond0-bond0.=
5
> work and eth0-bond0-br0-bond0.5 as well. But again, need to verify th=
is.

All incoming ARPs are seen by bond_handle_frame, even vlan ones, defini=
tely true.

But as some of them *are* vlan ones, you will have to untag those "by h=
and" inside bond_handle_frame.

It might work, but I wouldn't support the idea, for two reasons :

- It would duplicate code, or at least, duplicate places where untaggin=
g happens.
- It would cause some vlan hacks to sit inside bond, which is not nice =
from a layering point of=20
view. You recently advocated against breaking layering and you are righ=
t. We should avoid putting X=20
related stuff into Y part of the network stack, as much as possible.

Again, I think we should try and find a generic way to have the final f=
rame delivered to whoever=20
needs it. And this way should not be limited to "vlan untagging" nor to=
 bonding.

	Nicolas.
