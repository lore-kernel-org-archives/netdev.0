From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: root_lock vs. device's TX lock
Date: Thu, 17 Nov 2011 18:26:26 +0100
Message-ID: <1321550786.2751.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+mtBx8sHDprEct3zgGXXKEESK6i0FYnFS-_z35FOyVQjS9R4Q@mail.gmail.com>
	 <1321547698.2751.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33911 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837Ab1KQR0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 12:26:30 -0500
Received: by wyh11 with SMTP id 11so2289273wyh.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 09:26:29 -0800 (PST)
In-Reply-To: <1321547698.2751.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 17:34 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le jeudi 17 novembre 2011 =C3=A0 08:10 -0800, Tom Herbert a =C3=A9cri=
t :
> > From sch_direct_xmit:
> >=20
> >         /* And release qdisc */
> >         spin_unlock(root_lock);
> >=20
> >         HARD_TX_LOCK(dev, txq, smp_processor_id());
> >         if (!netif_tx_queue_frozen_or_stopped(txq))
> >                 ret =3D dev_hard_start_xmit(skb, dev, txq);
> >=20
> >         HARD_TX_UNLOCK(dev, txq);
> >=20
> >         spin_lock(root_lock);
> >=20
> > This is a lot of lock manipulation to basically switch from one loc=
k
> > to another and possibly thrashing just to send a packet.  I am
> > thinking that if the there is a 1-1 correspondence between qdisc an=
d
> > device queue then we could actually use the device's lock as the ro=
ot
> > lock for the qdisc.  So in that case, we would need to touch any lo=
cks
> > from sch_direct_xmit (just hold root lock which is already device l=
ock
> > for the duration).
> >=20
> > Is there any reason why this couldn't work?
>=20
> But we have to dirty part of Qdisc anyway ?
> (state, bstats, q, ...)
>=20

Also we want to permit other cpus to enqueue packets to Qdisc while our
cpu is busy in network driver ndo_start_xmit()

=46or complex Qdisc / tc setups (potentially touching a lot of cache
lines), we could eventually add a small ring buffer so that the cpu
doing the ndo_start_xmit() also queues the packets into Qdisc.

This ringbuffer could use a lockless algo. (we currently use the
secondary 'busylock' to serialize other cpus, but each cpu calls qdisc
enqueue itself.)
