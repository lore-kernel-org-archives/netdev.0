From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 20:07:19 +0100
Message-ID: <49C14667.2040806@cosmosbay.com>
References: <49C12E64.1000301@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: Vernon Mauery <vernux@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54162 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbZCRTH3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 15:07:29 -0400
In-Reply-To: <49C12E64.1000301@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vernon Mauery a =E9crit :
> I have been beating on network throughput in the -rt kernel for some =
time
> now.  After digging down through the send path of UDP packets, I foun=
d
> that the sk_buff_head.lock is under some very high contention.  This =
lock
> is acquired each time a packet is enqueued on a qdisc and then acquir=
ed
> again to dequeue the packet.  Under high networking loads, the enqueu=
eing
> processes are not only contending among each other for the lock, but =
also
> with the net-tx soft irq.  This makes for some very high contention o=
n this
> one lock.  My testcase is running varying numbers of concurrent netpe=
rf
> instances pushing UDP traffic to another machine.  As the count goes =
from
> 1 to 2, the network performance increases.  But from 2 to 4 and from =
4
> to 8,
> we see a big decline, with 8 instances pushing about half of what a s=
ingle
> thread can do.
>=20
> Running 2.6.29-rc6-rt3 on an 8-way machine with a 10GbE card (I have =
tried
> both NetXen and Broadcom, with very similar results), I can only push=
 about
> 1200 Mb/s.  Whereas with the mainline 2.6.29-rc8 kernel, I can push n=
early
> 6000 Mb/s. But still not as much as I think is possible.  I was curio=
us and
> decided to see if the mainline kernel was hitting the same lock, and =
using
> /proc/lock_stat, it is hitting the sk_buff_head.lock as well (it was =
the
> number one contended lock).
>=20
> So while this issue really hits -rt kernels hard, it has a real effec=
t on
> mainline kernels as well.  The contention of the spinlocks is amplifi=
ed
> when they get turned into rt-mutexes, which causes a double context s=
witch.
>=20
> Below is the top of the lock_stat for 2.6.29-rc8.  This was captured =
from
> a 1 minute network stress test.  The next high contender had 2 orders=
 of
> magnitude fewer contentions.  Think of the throughput increase if we =
could
> ease this contention a bit.  We might even be able to saturate a 10Gb=
E
> link.
>=20
> lock_stat version 0.3
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
---------------------------
>=20
>       class name    con-bounces    contentions   waittime-min =20
> waittime-max   waittime-total    acq-bounces   acquisitions =20
> holdtime-min  holdtime-max holdtime-total
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
---------------------------
>=20
>=20
>    &list->lock#3:      24517307       24643791           0.71      =20
> 1286.62      56516392.42       34834296       44904018         =20
> 0.60        164.79    31314786.02
>     -------------
>    &list->lock#3       15596927    [<ffffffff812474da>]
> dev_queue_xmit+0x2ea/0x468
>    &list->lock#3        9046864    [<ffffffff812546e9>]
> __qdisc_run+0x11b/0x1ef
>     -------------
>    &list->lock#3        6525300    [<ffffffff812546e9>]
> __qdisc_run+0x11b/0x1ef
>    &list->lock#3       18118491    [<ffffffff812474da>]
> dev_queue_xmit+0x2ea/0x468
>=20
>=20
> The story is the same for -rt kernels, only the waittime and holdtime
> are both
> orders of magnitude greater.
>=20
> I am not exactly clear on the solution, but if I understand correctly=
,
> in the
> past there has been some discussion of batched enqueueing and
> dequeueing.  Is
> anyone else working on this problem right now who has just not yet po=
sted
> anything for review?  Questions, comments, flames?
>=20

Yes we have a known contention point here, but before adding more compl=
ex code,
could you try following patch please ?

[PATCH] net: Reorder fields of struct Qdisc

dev_queue_xmit() needs to dirty fields "state" and "q"

On x86_64 arch, they currently span two cache lines, involving more
cache line ping pongs than necessary.

Before patch :

offsetof(struct Qdisc, state)=3D0x38
offsetof(struct Qdisc, q)=3D0x48
offsetof(struct Qdisc, dev_queue)=3D0x60

After patch :

offsetof(struct Qdisc, dev_queue)=3D0x38
offsetof(struct Qdisc, state)=3D0x48
offsetof(struct Qdisc, q)=3D0x50


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f8c4742..e24feeb 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -51,10 +51,11 @@ struct Qdisc
 	u32			handle;
 	u32			parent;
 	atomic_t		refcnt;
-	unsigned long		state;
+	struct netdev_queue	*dev_queue;
+
 	struct sk_buff		*gso_skb;
+	unsigned long		state;
 	struct sk_buff_head	q;
-	struct netdev_queue	*dev_queue;
 	struct Qdisc		*next_sched;
 	struct list_head	list;
=20


