From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] RPS: support 802.1q and pppoe session
Date: Thu, 25 Mar 2010 13:47:48 +0800
Message-ID: <412e6f7f1003242247h79dd3ce0u449a1e71bf4ec742@mail.gmail.com>
References: <4BAAE6E9.6030103@gmail.com> <1269493402.15280.29.camel@edumazet-laptop>
	<412e6f7f1003242212t242a30e0k635bdfb861c324e4@mail.gmail.com>
	<1269494668.15280.72.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:45126 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433Ab0CYFsI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 01:48:08 -0400
Received: by iwn6 with SMTP id 6so3369345iwn.4
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 22:48:08 -0700 (PDT)
In-Reply-To: <1269494668.15280.72.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 25, 2010 at 1:24 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 25 mars 2010 =C3=A0 13:12 +0800, Changli Gao a =C3=A9crit :
>>
>> It is useful when Linux is run as a bridge.
>>
>
> I am not saying its not useful. BTW, for routers/bridges, RPS is not =
a
> good idea, unless you must add netfilter complex rules.
>

Yea, we do DPI in netfilter. And for a stateful fireware, connection
tracking isn't cheap. As bandwidth increases, we find one CPU can't
handle all the traffic from a single NIC. We currently use dynamic
weighted packets distributing algorithm with patched Linux-2.6.18, and
it works very well.

>> >
>> > I agree we might need a flag or something to reset rxhash to 0 som=
ewhere
>> > (probably in non accelerated vlan rx handling) to force second
>> > get_rps_cpu() invocation to recompute it. This small correction ha=
s no
>> > cost if put outside of get_rps_cpus().
>> >
>> > If get_rps_cpus() is too complex, it might become too slow for typ=
ical
>> > use. We should find smart ways to solve your performance problem i=
f they
>> > ever exist.
>> >
>>
>> It means that more than one IPI will be sent for just a single
>> packets, I don't think the cost is acceptable.
>>
>
> I believe you dont _fully_ understand how RPS currently works.
>
> I am very surprised you send RPS patches if you dont master it.
>
> Please read again get_rps_cpus(), line 2238
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0default:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto done; =C2=
=A0 <<<< HERE skb->rxhash unchanged >>>>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ports =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (ip_proto) {
>
>
> This means that unknown protocols are directly handled by THIS cpu, a=
nd
> not given to another cpu. No IPI involved.
>
> In case of tunnels or vlan, we then reenter lowlevel stack and at thi=
s
> point, we can fully use RPS, because we are able to find IPV4/IPV6
> headers.
>
> Your patch is not necessary, since next time we call get_rps_cpus(),
> rxhash being still null, we compute the correct non null hash and at
> this point can choose an appropriate target cpu.
>
> (All you need is to set /sys/class/net/vlan.825/queues/rx-0/rps_cpus =
to
> needed mask)
>

I knew the current code is OK, and no additional IPI is needed. I said
that because you said:

>> > I agree we might need a flag or something to reset rxhash to 0 som=
ewhere
>> > (probably in non accelerated vlan rx handling) to force second
>> > get_rps_cpu() invocation to recompute it. This small correction ha=
s no
>> > cost if put outside of get_rps_cpus().

Oh, maybe I misunderstood you words. I thought the rxhash you want to
clear is computed by get_rps_cpu()? I remembered some NIC itself can
get 5-tuple from vlan and pppoe packets to compute hash. In that case,
we should not clear rxhash.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
