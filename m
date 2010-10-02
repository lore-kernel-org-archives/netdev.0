From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next V2] net: dynamic ingress_queue allocation
Date: Sat, 02 Oct 2010 08:10:36 -0400
Message-ID: <1286021436.3812.28.camel@bigi>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local>  <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop> <1285933506.3553.176.camel@bigi>
	 <1285941388.2641.175.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:47895 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754653Ab0JBMKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Oct 2010 08:10:40 -0400
Received: by qyk9 with SMTP id 9so2239024qyk.19
        for <netdev@vger.kernel.org>; Sat, 02 Oct 2010 05:10:39 -0700 (PDT)
In-Reply-To: <1285941388.2641.175.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-01 at 15:56 +0200, Eric Dumazet wrote:=20
> Le vendredi 01 octobre 2010 =C3=A0 07:45 -0400, jamal a =C3=A9crit :

>=20
> I first thought of this, and found it would add a new dependence on
> vmlinux :
>=20
> If someone wants to add NET_SCH_INGRESS module, he would need to
> recompile whole kernel and reboot.
>=20
> This is probably why ing_filter() and handle_ing() are enclosed with
> CONFIG_NET_CLS_ACT, not CONFIG_NET_SCH_INGRESS.
>=20
> Since struct net_dev only holds one pointer (after this patch), I
> believe its better to use same dependence.
>=20

Ok - I just noticed that CONFIG_NET_SCH_INGRESS depends on=20
CONFIG_NET_CLS_ACT - probably my fault too. I have a use case
for having just CONFIG_NET_SCH_INGRESS without need for
CONFIG_NET_CLS_ACT; but you are right to keep in the current
spirit it is fair to keep it as is; i wonder if it needs to be fixed.

> >=20
> > > +static inline struct netdev_queue *dev_ingress_queue(struct net_=
device *dev)
> > > +{
> > > +#ifdef CONFIG_NET_CLS_ACT
> > > +	return dev->ingress_queue;
> > > +#else
> > > +	return NULL;
> > > +#endif
> >=20
> > Above, if you just returned dev->ingress_queue wouldnt it always be=
=20
> > NULL if it was not allocated?
> >=20
>=20
> ingress_queue is not defined in "struct net_device *dev" if=20
> !CONFIG_NET_CLS_ACT
>=20
> Returning NULL here permits dead code elimination by compiler.
>=20
> Then, probably nobody unset CONFIG_NET_CLS_ACT, so we can probably av=
oid
> this preprocessor stuff.
>=20

Ok


> I see, this adds an indirection and a conditional branch, but this
> should be in cpu cache and well predicted.

Ok - good enough for me.

> I thought adding a fake "struct netdev_queue" object, with a qdisc
> pointing to noop_qdisc. But this would slow down a bit non ingress
> users ;)

nod.

> For people not using ingress, my solution removes an access to an ext=
ra
> cache line. So network latency is improved a bit when cpu caches are
> full of user land data.

Who are these lunatics running without ingress anyways?

> > 1) compile support for ingress and add/delete ingress qdisc
>=20
> This worked for me, but I dont know complex setups.
>=20

I think if you covered the basic case, should be equivalent
to any other case. Maybe a replace after you do an add etc.

> > 2) Dont compile support and add/delete ingress qdisc
>=20
> tc gives an error (a bit like !CONFIG_NET_SCH_INGRESS)
>=20
> # tc qdisc add dev eth0 ingress
> RTNETLINK answers: No such file or directory
> # tc -s -d qdisc show dev eth0
> qdisc mq 0: root=20
>  Sent 636 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)=20
>  backlog 0b 0p requeues 0=20
>=20

nice

>=20
> > 3) Compile ingress as a module and add/delete ingress qdisc
> >=20
> Seems to work like 1)
>=20

ok then, nothing else to bitch about.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

> I took a look at ifb as suggested by Stephen but could not see trivia=
l
> changes (LLTX or per-cpu stats), since central lock is needed I am
> afraid.=20

I wasnt thinking ifb - but ifb (and probably other netdevs) could
benefit a tiny bit by rearranging net_stats struct rx and tx parts into
different cache lines since these are typically updated in different
paths. In kernel, rx path for ifb is guaranteed to run in one cpu at a
time but tx could be many cpus (so at least for rx path theres benefit)

> And qdisc are the same, stats updates are mostly free as we
> dirtied cache line for the lock.

ok - qdiscs are easier because a qdisc instance can be accessed by one
cpu at a time. actions could be configured to be shared by many filters=
;
in such a mode they could be accessed across many cpus.

cheers,
jamal

