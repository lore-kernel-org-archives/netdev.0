From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Generic rx-recycling and emergency skb pool
Date: Sat, 03 Jul 2010 08:23:25 +0200
Message-ID: <1278138205.2474.27.camel@edumazet-laptop>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:61975 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab0GCGX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 02:23:29 -0400
Received: by wwb39 with SMTP id 39so65582wwb.1
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 23:23:28 -0700 (PDT)
In-Reply-To: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 juillet 2010 =C3=A0 21:20 +0200, Sebastian Andrzej Siewi=
or a
=C3=A9crit :
> This is version two of generic rx-recycling followed by version one o=
f
> emergency skb pools which are built on top of rx-recycling.
> The change from v1 of generic rx-recycling is that the list access is
> unlocked instead of locked.
> Patch six which introduces the emergency pools adds the locking back.
> This is required since we now have two not serialized users. In order
> not to punish everyone patch eight removes this locking again. That
> patch converts only two drivers so you have an idea what I think is
> required to get the locking removed.
>=20
> The idea behind emergency pools is to have pre-allocated skbs for TX =
and
> RX. Using the memory allocator for it leads to latencies during memor=
y
> pressure. The pre-allocated skb are "tagged" and should get back to t=
he
> pool once they are through the stack so the pool should never get
> exhausted.
>=20
> While it was easy to convert the drivers which share the same concept=
 of
> rx-recycling to use the emergency pools it was difficult to hook up t=
he
> more complex drivers like e1000e. The e1000e can use split skbs / a f=
rag
> list which is different from the allocation currently used. So instea=
d of
> forcing all drivers to use the same way of doing things I've been thi=
nking
> about providing a dedicated callback for skb allocation and checking =
if
> this skb is "good enough". This is not yet implemented.
>=20
> I would be glad to receive some feedback on this patch series before =
I go
> any further. Unfortunately I'm on vacation for the next two weeks so =
I
> can't respond earlier. tglx is on Cc and should be able respond earli=
er :)
>=20
> Sebastian

Sebastian

I read all patches, and my initial feeling is all this is very complex
and have many shortcomings.

Most modern NICS are multiqueue, so that each cpu can use a queue on it=
s
own without slowing down other cpus.

Yet rx recycling has one queue per device, defeating part of the
multiqueue goal.

Patch 6/8 even touches dev->refcnt on each emerg packet
Patch 6/8 adds 8 bytes (emerg_dev) to skb. Oh well...

Adding cache layers, especially dumb ones like this one, is probably th=
e
sign something more fundamental is broken somewhere.


I do believe for example that netdev_alloc_skb() should not try to use
the node affinity of the device, but use current cpu node for sk_buff a=
t
least, and possibly for data part too.

One other problem of skb are the two memory blocs involved, and fact
that first one (skb) is already very big and fat, and filled/dirtied
many cycles before its use in RX path.

Maybe its time to provide new API, so that a driver can build an skb at
the time RX interrupt is handled, not at the time the rx ring buffer is
renewed. RX ring should only provide the data part to NIC, and skb
should be built when NIC delivers the frame, so that we provide to IP
stack a real hot skb.



