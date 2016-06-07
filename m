From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net: get rid of spin_trylock() in net_tx_action()
Date: Tue, 7 Jun 2016 09:04:02 -0700
Message-ID: <CALx6S36MxNK9VUQA9Y=djD6bEwY_uiAkf674OEB=c_GUo8Pefw@mail.gmail.com>
References: <1465095748.2968.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36757 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932862AbcFGQED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 12:04:03 -0400
Received: by mail-it0-f67.google.com with SMTP id h190so2598327ith.3
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 09:04:03 -0700 (PDT)
In-Reply-To: <1465095748.2968.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 4, 2016 at 8:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Note: Tom Herbert posted almost same patch 3 months back, but for
> different reasons.
>
> The reasons we want to get rid of this spin_trylock() are :
>
> 1) Under high qdisc pressure, the spin_trylock() has almost no
> chance to succeed.
>
> 2) We loop multiple times in softirq handler, eventually reaching
> the max retry count (10), and we schedule ksoftirqd.
>
> Since we want to adhere more strictly to ksoftirqd being waked up in
> the future (https://lwn.net/Articles/687617/), better avoid spurious
> wakeups.
>
> 3) calls to __netif_reschedule() dirty the cache line containing
> q->next_sched, slowing down the owner of qdisc.
>
> 4) RT kernels can not use the spin_trylock() here.
>
> With help of busylock, we get the qdisc spinlock fast enough, and
> the trylock trick brings only performance penalty.
>
> Depending on qdisc setup, I observed a gain of up to 19 % in qdisc
> performance (1016600 pps instead of 853400 pps, using prio+tbf+fq_codel)
>
> ("mpstat -I SCPU 1" is much happier now)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> ---
>  net/core/dev.c |   26 +++++++++-----------------
>  1 file changed, 9 insertions(+), 17 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 904ff431d570e3cfc0e6255480bd25f3c9dec2f3..896b686d19669d61a04bdccf6b0b71c0537cca81 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2253,7 +2253,7 @@ int netif_get_num_default_rss_queues(void)
>  }
>  EXPORT_SYMBOL(netif_get_num_default_rss_queues);
>
> -static inline void __netif_reschedule(struct Qdisc *q)
> +static void __netif_reschedule(struct Qdisc *q)
>  {
>         struct softnet_data *sd;
>         unsigned long flags;
> @@ -3898,22 +3898,14 @@ static void net_tx_action(struct softirq_action *h)
>                         head = head->next_sched;
>
>                         root_lock = qdisc_lock(q);
> -                       if (spin_trylock(root_lock)) {
> -                               smp_mb__before_atomic();
> -                               clear_bit(__QDISC_STATE_SCHED,
> -                                         &q->state);
> -                               qdisc_run(q);
> -                               spin_unlock(root_lock);
> -                       } else {
> -                               if (!test_bit(__QDISC_STATE_DEACTIVATED,
> -                                             &q->state)) {
> -                                       __netif_reschedule(q);
> -                               } else {
> -                                       smp_mb__before_atomic();
> -                                       clear_bit(__QDISC_STATE_SCHED,
> -                                                 &q->state);
> -                               }
> -                       }
> +                       spin_lock(root_lock);
> +                       /* We need to make sure head->next_sched is read
> +                        * before clearing __QDISC_STATE_SCHED
> +                        */
> +                       smp_mb__before_atomic();
> +                       clear_bit(__QDISC_STATE_SCHED, &q->state);
> +                       qdisc_run(q);
> +                       spin_unlock(root_lock);
>                 }
>         }
>  }
>
>
Acked-by: Tom Herbert <tom@herbertland.com>
