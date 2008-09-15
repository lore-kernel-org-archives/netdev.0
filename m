From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH 1/1] net: fix scheduling of dst_gc_task by __dst_free
Date: Mon, 15 Sep 2008 15:26:01 +0200
Message-ID: <48CE6269.4050006@bull.net>
References: <20080912123113.770453085@theryb.frec.bull.fr>	<20080912123118.993434427@theryb.frec.bull.fr>	<48CA80DC.9040408@cosmosbay.com> <20080912.161452.04603170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40555 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730AbYION13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 09:27:29 -0400
In-Reply-To: <20080912.161452.04603170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 12 Sep 2008 16:46:52 +0200
>=20
>> Benjamin Thery a =E9crit :
>>> The dst garbage collector dst_gc_task() may not be scheduled as we
>>> expect it to be in __dst_free().
>>> Indeed, when the dst_gc_timer was replaced by the delayed_work
>>> dst_gc_work, the mod_timer() call used to schedule the garbage
>>> collector at an earlier date was replaced by a schedule_delayed_wor=
k()
>>> (see commit 86bba269d08f0c545ae76c90b56727f65d62d57f).
>>> But, the behaviour of mod_timer() and schedule_delayed_work() is
>>> different in the way they handle the delay. mod_timer() stops the t=
imer and re-arm it with the new given delay,
>>> whereas schedule_delayed_work() only check if the work is already
>>> queued in the workqueue (and queue it (with delay) if it is not)
>>> BUT it does NOT take into account the new delay (even if the new de=
lay
>>> is earlier in time).
>>> schedule_delayed_work() returns 0 if it didn't queue the work,
>>> but we don't check the return code in __dst_free().
>>> If I understand the code in __dst_free() correctly, we want dst_gc_=
task
>>> to be queued after DST_GC_INC jiffies if we pass the test (and not =
in
>>> some undetermined time in the future), so I think we should add a c=
all
>>> to cancel_delayed_work() before schedule_delayed_work(). Patch belo=
w.
>>>
>> Well, you are right that time is undetermined (but < ~120 seconds), =
so your patch
>> makes sense.
>>
>> Acked-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> I'll add this to net-next-2.6 for now.  Benjamin, do you know of any
> real cases where users are being tripped up by our not using the
> shorter scheduling of the workqueue?

I found this issue while tracking an issue that sometimes occurs at=20
network namespace exit.

When a network namespace exits, the routes need to be freed as fast as=20
possible to complete the unregistration of the net devices present in=20
the namespace (ie. the loopback).

Sometimes, the routes garbage collection gets delayed (because of the=20
issue described here) and the refcount on the device isn't decremented=20
as expected when we reach netdev_wait_allrefs() and we get the infamous=
=20
"unregister_netdevice: waiting for lo to become free."

This fix in __dst_free() fixes part of the problem.

Benjamin

>=20
>> Then we should ask why we reset the timer back to its minimum value
>> every time we call __dst_free(). On machines with many dormant tcp
>> sessions, dst_garbage.list can contain huge number of non freeable
>> entries :(
>>
>> Maybe we should count the entries and change the timer only if reall=
y needed.
>=20
> Yet another area of black magic in our routing cache :)
>=20
>>> (Sorry, I think I've been a bit verbose to expose this simple issue=
 :)
>=20
> No, do not apologize, I wish every commit message were this verbose.
>=20
>=20


--=20
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
