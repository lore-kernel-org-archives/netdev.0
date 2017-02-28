From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Tue, 28 Feb 2017 09:20:03 -0800
Message-ID: <CAKgT0UeSpxzgePoidJumQFvM5a2mOC5+rL8gCHqvX-HBvrn74A@mail.gmail.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com> <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33034 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751511AbdB1SUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 13:20:31 -0500
Received: by mail-it0-f67.google.com with SMTP id 68so2361794itg.0
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 10:20:30 -0800 (PST)
In-Reply-To: <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 6:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While playing with mlx4 hardware timestamping of RX packets, I found
> that some packets were received by TCP stack with a ~200 ms delay...
>
> Since the timestamp was provided by the NIC, and my probe was added
> in tcp_v4_rcv() while in BH handler, I was confident it was not
> a sender issue, or a drop in the network.
>
> This would happen with a very low probability, but hurting RPC
> workloads.
>
> A NAPI driver normally arms the IRQ after the napi_complete_done(),
> after NAPI_STATE_SCHED is cleared, so that the hard irq handler can grab
> it.
>
> Problem is that if another point in the stack grabs NAPI_STATE_SCHED bit
> while IRQ are not disabled, we might have later an IRQ firing and
> finding this bit set, right before napi_complete_done() clears it.
>
> This can happen with busy polling users, or if gro_flush_timeout is
> used. But some other uses of napi_schedule() in drivers can cause this
> as well.
>
> This patch adds a new NAPI_STATE_MISSED bit, that napi_schedule_prep()
> can set if it could not grab NAPI_STATE_SCHED
>
> Then napi_complete_done() properly reschedules the napi to make sure
> we do not miss something.
>
> Since we manipulate multiple bits at once, use cmpxchg() like in
> sk_busy_loop() to provide proper transactions.
>
> In v2, I changed napi_watchdog() to use a relaxed variant of
> napi_schedule_prep() : No need to set NAPI_STATE_MISSED from this point.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/netdevice.h |   29 ++++++-------------
>  net/core/dev.c            |   53 +++++++++++++++++++++++++++++++++---
>  2 files changed, 58 insertions(+), 24 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f40f0ab3847a8caaf46bd4d5f224c65014f501cc..97456b2539e46d6232dda804f6a434db6fd7134f 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -330,6 +330,7 @@ struct napi_struct {
>
>  enum {
>         NAPI_STATE_SCHED,       /* Poll is scheduled */
> +       NAPI_STATE_MISSED,      /* reschedule a napi */
>         NAPI_STATE_DISABLE,     /* Disable pending */
>         NAPI_STATE_NPSVC,       /* Netpoll - don't dequeue from poll_list */
>         NAPI_STATE_HASHED,      /* In NAPI hash (busy polling possible) */
> @@ -338,12 +339,13 @@ enum {
>  };
>
>  enum {
> -       NAPIF_STATE_SCHED        = (1UL << NAPI_STATE_SCHED),
> -       NAPIF_STATE_DISABLE      = (1UL << NAPI_STATE_DISABLE),
> -       NAPIF_STATE_NPSVC        = (1UL << NAPI_STATE_NPSVC),
> -       NAPIF_STATE_HASHED       = (1UL << NAPI_STATE_HASHED),
> -       NAPIF_STATE_NO_BUSY_POLL = (1UL << NAPI_STATE_NO_BUSY_POLL),
> -       NAPIF_STATE_IN_BUSY_POLL = (1UL << NAPI_STATE_IN_BUSY_POLL),
> +       NAPIF_STATE_SCHED        = BIT(NAPI_STATE_SCHED),
> +       NAPIF_STATE_MISSED       = BIT(NAPI_STATE_MISSED),
> +       NAPIF_STATE_DISABLE      = BIT(NAPI_STATE_DISABLE),
> +       NAPIF_STATE_NPSVC        = BIT(NAPI_STATE_NPSVC),
> +       NAPIF_STATE_HASHED       = BIT(NAPI_STATE_HASHED),
> +       NAPIF_STATE_NO_BUSY_POLL = BIT(NAPI_STATE_NO_BUSY_POLL),
> +       NAPIF_STATE_IN_BUSY_POLL = BIT(NAPI_STATE_IN_BUSY_POLL),
>  };
>
>  enum gro_result {
> @@ -414,20 +416,7 @@ static inline bool napi_disable_pending(struct napi_struct *n)
>         return test_bit(NAPI_STATE_DISABLE, &n->state);
>  }
>
> -/**
> - *     napi_schedule_prep - check if NAPI can be scheduled
> - *     @n: NAPI context
> - *
> - * Test if NAPI routine is already running, and if not mark
> - * it as running.  This is used as a condition variable to
> - * insure only one NAPI poll instance runs.  We also make
> - * sure there is no pending NAPI disable.
> - */
> -static inline bool napi_schedule_prep(struct napi_struct *n)
> -{
> -       return !napi_disable_pending(n) &&
> -               !test_and_set_bit(NAPI_STATE_SCHED, &n->state);
> -}
> +bool napi_schedule_prep(struct napi_struct *n);
>
>  /**
>   *     napi_schedule - schedule NAPI poll
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 304f2deae5f9897e60a79ed8b69d6ef208295ded..edeb916487015f279036ecf7ff5d9096dff365d3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4884,6 +4884,32 @@ void __napi_schedule(struct napi_struct *n)
>  EXPORT_SYMBOL(__napi_schedule);
>
>  /**
> + *     napi_schedule_prep - check if napi can be scheduled
> + *     @n: napi context
> + *
> + * Test if NAPI routine is already running, and if not mark
> + * it as running.  This is used as a condition variable
> + * insure only one NAPI poll instance runs.  We also make
> + * sure there is no pending NAPI disable.
> + */
> +bool napi_schedule_prep(struct napi_struct *n)
> +{
> +       unsigned long val, new;
> +
> +       do {
> +               val = READ_ONCE(n->state);
> +               if (unlikely(val & NAPIF_STATE_DISABLE))
> +                       return false;
> +               new = val | NAPIF_STATE_SCHED;
> +               if (unlikely(val & NAPIF_STATE_SCHED))
> +                       new |= NAPIF_STATE_MISSED;

You might want to consider just using a combination AND, divide,
multiply, and OR to avoid having to have any conditional branches
being added due to this code path.  Basically the logic would look
like:
    new = val | NAPIF_STATE_SCHED;
    new |= (val & NAPIF_STATE_SCHED) / NAPIF_STATE_SCHED * NAPIF_STATE_MISSED;

In assembler that all ends up getting translated out to AND, SHL, OR.
You avoid the branching, or MOV/OR/TEST/CMOV type code you would end
up with otherwise.

> +       } while (cmpxchg(&n->state, val, new) != val);
> +
> +       return !(val & NAPIF_STATE_SCHED);
> +}
> +EXPORT_SYMBOL(napi_schedule_prep);
> +
> +/**
>   * __napi_schedule_irqoff - schedule for receive
>   * @n: entry to schedule
>   *
> @@ -4897,7 +4923,7 @@ EXPORT_SYMBOL(__napi_schedule_irqoff);
>
>  bool napi_complete_done(struct napi_struct *n, int work_done)
>  {
> -       unsigned long flags;
> +       unsigned long flags, val, new;
>
>         /*
>          * 1) Don't let napi dequeue from the cpu poll list
> @@ -4927,7 +4953,21 @@ bool napi_complete_done(struct napi_struct *n, int work_done)
>                 list_del_init(&n->poll_list);
>                 local_irq_restore(flags);
>         }
> -       WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &n->state));
> +
> +       do {
> +               val = READ_ONCE(n->state);
> +
> +               WARN_ON_ONCE(!(val & NAPIF_STATE_SCHED));
> +
> +               new = val & ~(NAPIF_STATE_MISSED | NAPIF_STATE_SCHED);
> +
> +               if (unlikely(val & NAPIF_STATE_MISSED))
> +                       new |= NAPIF_STATE_SCHED;

Same kind of thing here.  You could probably just get away with something like:
    new = val & ~NAPIF_STATE_MISSED;
    new &= (val & NAPIF_STATE_MISSED) / NAPIF_STATE_MISSED * NETIF_STATE_SCHED;

> +       } while (cmpxchg(&n->state, val, new) != val);
> +
> +       if (unlikely(val & NAPIF_STATE_MISSED))
> +               __napi_schedule(n);
> +
>         return true;
>  }

If you rescheduled napi should you really be returning true?  Seems
like you should be returning "!(val & NAPIF_STATE_MISSED)" to try to
avoid letting this occur again.

>  EXPORT_SYMBOL(napi_complete_done);
> @@ -5088,8 +5128,13 @@ static enum hrtimer_restart napi_watchdog(struct hrtimer *timer)
>         struct napi_struct *napi;
>
>         napi = container_of(timer, struct napi_struct, timer);
> -       if (napi->gro_list)
> -               napi_schedule_irqoff(napi);
> +
> +       /* Note : we use a relaxed variant of napi_schedule_prep() not setting
> +        * NAPI_STATE_MISSED, since we do not react to a device IRQ.
> +        */
> +       if (napi->gro_list && !napi_disable_pending(napi) &&
> +           !test_and_set_bit(NAPI_STATE_SCHED, &napi->state))
> +               __napi_schedule_irqoff(napi);
>
>         return HRTIMER_NORESTART;
>  }
>
>
