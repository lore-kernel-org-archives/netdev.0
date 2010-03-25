From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RPS: support 802.1q and pppoe session
Date: Thu, 25 Mar 2010 06:24:28 +0100
Message-ID: <1269494668.15280.72.camel@edumazet-laptop>
References: <4BAAE6E9.6030103@gmail.com>
	 <1269493402.15280.29.camel@edumazet-laptop>
	 <412e6f7f1003242212t242a30e0k635bdfb861c324e4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:57822 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab0CYFYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 01:24:35 -0400
Received: by bwz1 with SMTP id 1so547492bwz.21
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 22:24:33 -0700 (PDT)
In-Reply-To: <412e6f7f1003242212t242a30e0k635bdfb861c324e4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 mars 2010 =C3=A0 13:12 +0800, Changli Gao a =C3=A9crit :
> On Thu, Mar 25, 2010 at 1:03 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > While this might sounds a good idea, you really should split this i=
n two
> > parts.
> >
> > By the way, why not handling IPIP too ?
>=20
> I'm not sure if it is a good idea to support VLAN and PPPOE, and
> actually David don't like it. :(
>=20
> >
> > Because I believe 802.1q part has no added value for instance, sinc=
e
> > packet handled by CPUX will be decoded and passed to VLAN device, h=
aving
> > a chance to be fully taken by RPS, since we go back to netif_rx().
> >
> > Probably same thing for IPIP / PPPOE can be discussed.
>=20
> It is useful when Linux is run as a bridge.
>=20

I am not saying its not useful. BTW, for routers/bridges, RPS is not a
good idea, unless you must add netfilter complex rules.

> >
> > I agree we might need a flag or something to reset rxhash to 0 some=
where
> > (probably in non accelerated vlan rx handling) to force second
> > get_rps_cpu() invocation to recompute it. This small correction has=
 no
> > cost if put outside of get_rps_cpus().
> >
> > If get_rps_cpus() is too complex, it might become too slow for typi=
cal
> > use. We should find smart ways to solve your performance problem if=
 they
> > ever exist.
> >
>=20
> It means that more than one IPI will be sent for just a single
> packets, I don't think the cost is acceptable.
>=20

I believe you dont _fully_ understand how RPS currently works.

I am very surprised you send RPS patches if you dont master it.

Please read again get_rps_cpus(), line 2238

        default:
                goto done;   <<<< HERE skb->rxhash unchanged >>>>
        }
        ports =3D 0;
        switch (ip_proto) {


This means that unknown protocols are directly handled by THIS cpu, and
not given to another cpu. No IPI involved.

In case of tunnels or vlan, we then reenter lowlevel stack and at this
point, we can fully use RPS, because we are able to find IPV4/IPV6
headers.

Your patch is not necessary, since next time we call get_rps_cpus(),
rxhash being still null, we compute the correct non null hash and at
this point can choose an appropriate target cpu.

(All you need is to set /sys/class/net/vlan.825/queues/rx-0/rps_cpus to
needed mask)




