From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fix scheduling of dst_gc_task by __dst_free
Date: Fri, 12 Sep 2008 16:14:52 -0700 (PDT)
Message-ID: <20080912.161452.04603170.davem@davemloft.net>
References: <20080912123113.770453085@theryb.frec.bull.fr>
	<20080912123118.993434427@theryb.frec.bull.fr>
	<48CA80DC.9040408@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37997
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755650AbYILXO6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 19:14:58 -0400
In-Reply-To: <48CA80DC.9040408@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 12 Sep 2008 16:46:52 +0200

> Benjamin Thery a =E9crit :
> > The dst garbage collector dst_gc_task() may not be scheduled as we
> > expect it to be in __dst_free().
> > Indeed, when the dst_gc_timer was replaced by the delayed_work
> > dst_gc_work, the mod_timer() call used to schedule the garbage
> > collector at an earlier date was replaced by a schedule_delayed_wor=
k()
> > (see commit 86bba269d08f0c545ae76c90b56727f65d62d57f).
> > But, the behaviour of mod_timer() and schedule_delayed_work() is
> > different in the way they handle the delay. mod_timer() stops the t=
imer and re-arm it with the new given delay,
> > whereas schedule_delayed_work() only check if the work is already
> > queued in the workqueue (and queue it (with delay) if it is not)
> > BUT it does NOT take into account the new delay (even if the new de=
lay
> > is earlier in time).
> > schedule_delayed_work() returns 0 if it didn't queue the work,
> > but we don't check the return code in __dst_free().
> > If I understand the code in __dst_free() correctly, we want dst_gc_=
task
> > to be queued after DST_GC_INC jiffies if we pass the test (and not =
in
> > some undetermined time in the future), so I think we should add a c=
all
> > to cancel_delayed_work() before schedule_delayed_work(). Patch belo=
w.
> >=20
>=20
> Well, you are right that time is undetermined (but < ~120 seconds), s=
o your patch
> makes sense.
>=20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

I'll add this to net-next-2.6 for now.  Benjamin, do you know of any
real cases where users are being tripped up by our not using the
shorter scheduling of the workqueue?

> Then we should ask why we reset the timer back to its minimum value
> every time we call __dst_free(). On machines with many dormant tcp
> sessions, dst_garbage.list can contain huge number of non freeable
> entries :(
>
> Maybe we should count the entries and change the timer only if really=
 needed.

Yet another area of black magic in our routing cache :)

> > (Sorry, I think I've been a bit verbose to expose this simple issue=
 :)

No, do not apologize, I wish every commit message were this verbose.
