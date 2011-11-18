From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: root_lock vs. device's TX lock
Date: Fri, 18 Nov 2011 06:02:20 +0100
Message-ID: <1321592540.2444.31.camel@edumazet-laptop>
References: <CA+mtBx8sHDprEct3zgGXXKEESK6i0FYnFS-_z35FOyVQjS9R4Q@mail.gmail.com>
	 <1321547698.2751.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321550786.2751.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw6VfGKAk_gBZOjyCCcR0tCSc8PMjOoPv6Qi8m+P1idp4Q@mail.gmail.com>
	 <CAKWjMd7xvepSb2sMf4X4U4cjRYizq=tP2TTHhYaozuyBeSW4AQ@mail.gmail.com>
	 <CA+mtBx8KfVQYcZFCJrQF__LJh7e0cRSPqSk1nn537Z_ATMjD9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Fleming <afleming@gmail.com>, Dave Taht <dave.taht@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61360 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab1KRFC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 00:02:27 -0500
Received: by wwe5 with SMTP id 5so4460636wwe.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 21:02:26 -0800 (PST)
In-Reply-To: <CA+mtBx8KfVQYcZFCJrQF__LJh7e0cRSPqSk1nn537Z_ATMjD9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 16:35 -0800, Tom Herbert a =C3=A9crit =
:
> > Actually, I'm interested in circumventing *both* locks. Our SoC has
> > some quite-versatile queueing infrastructure, such that (for many
> > queueing setups) we can do all of the queueing in hardware, using
> > per-cpu access portals. By hacking around the qdisc lock, and using=
 a
> > tx queue per core, we were able to achieve a significant speedup.

If packet reordering is not a concern (or taken into account in the
hardware)... A task sending tcp flow can migrate from cpu1 to cpu2...

> This was actually one of the motivations for my question.  If we have
> a one TX queue per core, and and use a trivial mq aware qdisc for
> instance, the locking becomes mostly overhead.  I don't mind taking a
> lock once per TX, but right now were taking three! (root lock twice,
> and device lock once).
>=20


> Even without one queue per TX, I think the overhead savings may still
> be present.  Eric, I realize that a point of dropping the root lock i=
n
> sch_direct_xmit is to possibly allow queuing to to qdisc and device
> xmit in parallel, but if you're using a trivial qdisc then the time i=
n
> qdisc may be << time in device xmit, so the overhead of locking could
> mitigate the gains in parallelism.  At the very least, this benefit i=
s
> hugely variable depending on the qdisc used.

Andy speaks more of a way to bypass qdisc (direct to device), while I
thought Tom wanted to optimize htb/cbq/..complex qdisc handling...

Note we have LLTX thing to avoid taking dev->lock for some devices.

We could have a qdisc->fast_enqueue() method for some (qdiscs/device)
combinations, able to short cut __dev_xmit_skb() and do their own stuff
(using rcu locking or other synch method, percpu bytes/counter stats...=
)

But if device is really that smart, why even use a qdisc in the first
place ?

If qdisc not needed : We take only one lock (dev lock) to transmit a
packet. If device is LLTX, no lock taken at all.

If qdisc is needed : We need to take qdisc lock to enqueue packet.
   Then, _if_ we own the __QDISC___STATE_RUNNING flag, we enter the loo=
p
to dequeue and xmit packets (__qdisc_run() / sch_direct_xmit() doing th=
e
insane lock flips)

Its a tough choice : Do we want to avoid false sharing in the device
itself or qdisc...

Current handling was designed so that one cpu was feeding the device an=
d
other cpus feeding the qdisc.
