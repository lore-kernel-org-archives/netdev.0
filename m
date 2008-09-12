From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/1] net: fix scheduling of dst_gc_task by __dst_free
Date: Fri, 12 Sep 2008 16:46:52 +0200
Message-ID: <48CA80DC.9040408@cosmosbay.com>
References: <20080912123113.770453085@theryb.frec.bull.fr> <20080912123118.993434427@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.150]:56115 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbYILPqF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 11:46:05 -0400
Received: from smtp2f.orange.fr (mwinf2f01 [10.232.18.23])
	by mwinf2f05.orange.fr (SMTP Server) with ESMTP id C2D951C4B8A3
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 16:47:43 +0200 (CEST)
In-Reply-To: <20080912123118.993434427@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery a =E9crit :
> The dst garbage collector dst_gc_task() may not be scheduled as we
> expect it to be in __dst_free().
>=20
> Indeed, when the dst_gc_timer was replaced by the delayed_work
> dst_gc_work, the mod_timer() call used to schedule the garbage
> collector at an earlier date was replaced by a schedule_delayed_work(=
)
> (see commit 86bba269d08f0c545ae76c90b56727f65d62d57f).
>=20
> But, the behaviour of mod_timer() and schedule_delayed_work() is
> different in the way they handle the delay.=20
>=20
> mod_timer() stops the timer and re-arm it with the new given delay,
> whereas schedule_delayed_work() only check if the work is already
> queued in the workqueue (and queue it (with delay) if it is not)
> BUT it does NOT take into account the new delay (even if the new dela=
y
> is earlier in time).
> schedule_delayed_work() returns 0 if it didn't queue the work,
> but we don't check the return code in __dst_free().
>=20
> If I understand the code in __dst_free() correctly, we want dst_gc_ta=
sk
> to be queued after DST_GC_INC jiffies if we pass the test (and not in
> some undetermined time in the future), so I think we should add a cal=
l
> to cancel_delayed_work() before schedule_delayed_work(). Patch below.
>=20

Well, you are right that time is undetermined (but < ~120 seconds), so =
your patch
makes sense.

Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Then we should ask why we reset the timer back to its minimum value
every time we call __dst_free(). On machines with many dormant tcp sess=
ions,=20
dst_garbage.list can contain huge number of non freeable entries :(

Maybe we should count the entries and change the timer only if really n=
eeded.


> Or we should at least test the return code of schedule_delayed_work()=
,
> and reset the values of dst_garbage.timer_inc and dst_garbage.timer_e=
xpires
> back to their former values if schedule_delayed_work() failed.
> Otherwise the subsequent calls to __dst_free will test the wrong valu=
es
> and assume wrong thing about when the garbage collector is supposed t=
o
> be scheduled.
>=20
> dst_gc_task() also calls schedule_delayed_work() without checking
> its return code (or calling cancel_scheduled_work() first), but it
> should fine there: dst_gc_task is the routine of the delayed_work, so
> no dst_gc_work should be pending in the queue when it's running.
> =20
> This patch applies on top of net-2.6.
>=20
> (Sorry, I think I've been a bit verbose to expose this simple issue :=
)
>=20
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> ---
>  net/core/dst.c |    1 +
>  1 file changed, 1 insertion(+)
>=20
> Index: net-2.6/net/core/dst.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-2.6.orig/net/core/dst.c
> +++ net-2.6/net/core/dst.c
> @@ -203,6 +203,7 @@ void __dst_free(struct dst_entry * dst)
>  	if (dst_garbage.timer_inc > DST_GC_INC) {
>  		dst_garbage.timer_inc =3D DST_GC_INC;
>  		dst_garbage.timer_expires =3D DST_GC_MIN;
> +		cancel_delayed_work(&dst_gc_work);
>  		schedule_delayed_work(&dst_gc_work, dst_garbage.timer_expires);
>  	}
>  	spin_unlock_bh(&dst_garbage.lock);
>=20




