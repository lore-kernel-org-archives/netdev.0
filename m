From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] pkt_sched: gen_estimator: kill est_lock
	rwlock
Date: Mon, 7 Jun 2010 22:53:37 +0800
Message-ID: <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
References: <1275921171.2545.102.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:59986 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab0FGOx7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 10:53:59 -0400
Received: by pwj5 with SMTP id 5so890700pwj.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 07:53:58 -0700 (PDT)
In-Reply-To: <1275921171.2545.102.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 7, 2010 at 10:32 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> We can use RCU in est_timer() and kill est_lock rwlock.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =A0net/core/gen_estimator.c | =A0 45 ++++++++++++++------------------=
-----
> =A01 file changed, 18 insertions(+), 27 deletions(-)
>
> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> index cf8e703..406d880 100644
> --- a/net/core/gen_estimator.c
> +++ b/net/core/gen_estimator.c
> @@ -102,9 +102,6 @@ struct gen_estimator_head
>
> =A0static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
>
> -/* Protects against NULL dereference */
> -static DEFINE_RWLOCK(est_lock);
> -
> =A0/* Protects against soft lockup during large deletion */
> =A0static struct rb_root est_root =3D RB_ROOT;
>
> @@ -115,29 +112,25 @@ static void est_timer(unsigned long arg)
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0list_for_each_entry_rcu(e, &elist[idx].list, list) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 nbytes;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 brate;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 npackets;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 rate;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct gnet_stats_basic_packed *bstats;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(e->stats_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 read_lock(&est_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (e->bstats =3D=3D NULL)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto skip;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nbytes =3D e->bstats->bytes;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 npackets =3D e->bstats->packets;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 brate =3D (nbytes - e->last_bytes)<<(7 =
- idx);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->last_bytes =3D nbytes;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->avbps +=3D (brate >> e->ewma_log) - =
(e->avbps >> e->ewma_log);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->rate_est->bps =3D (e->avbps+0xF)>>5;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rate =3D (npackets - e->last_packets)<<=
(12 - idx);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->last_packets =3D npackets;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->avpps +=3D (rate >> e->ewma_log) - (=
e->avpps >> e->ewma_log);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->rate_est->pps =3D (e->avpps+0x1FF)>>=
10;
> -skip:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 read_unlock(&est_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bstats =3D rcu_dereference(e->bstats);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bstats) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 nbytes =3D ACCESS_O=
NCE(bstats->bytes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 npackets =3D ACCESS=
_ONCE(bstats->packets);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 brate =3D (nbytes -=
 e->last_bytes)<<(7 - idx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 rate;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->last_bytes =3D nbyte=
s;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->avbps +=3D (brate >>=
 e->ewma_log) - (e->avbps >> e->ewma_log);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->rate_est->bps =3D (e=
->avbps+0xF)>>5;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rate =3D (npackets - e-=
>last_packets)<<(12 - idx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->last_packets =3D npa=
ckets;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->avpps +=3D (rate >> =
e->ewma_log) - (e->avpps >> e->ewma_log);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->rate_est->pps =3D (e=
->avpps+0x1FF)>>10;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(e->stats_lock);
> =A0 =A0 =A0 =A0}
>
> @@ -271,9 +264,7 @@ void gen_kill_estimator(struct gnet_stats_basic_p=
acked *bstats,
> =A0 =A0 =A0 =A0while ((e =3D gen_find_node(bstats, rate_est))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rb_erase(&e->node, &est_root);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_lock_bh(&est_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->bstats =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_unlock_bh(&est_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(e->bstats, NULL);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del_rcu(&e->list);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0call_rcu(&e->e_rcu, __gen_kill_estimat=
or);
>

Hmm. I don't think it is correct.

Look at this code:

void xt_rateest_put(struct xt_rateest *est)
{
        mutex_lock(&xt_rateest_mutex);
        if (--est->refcnt =3D=3D 0) {
                hlist_del(&est->list);
                gen_kill_estimator(&est->bstats, &est->rstats);
                kfree(est);
        }
        mutex_unlock(&xt_rateest_mutex);
}

est will be released after gen_kill_estimator() returns. After est is
freed, there may still be some other CPUs running in the branch:
     if (bstats) {
         ....
     }

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
