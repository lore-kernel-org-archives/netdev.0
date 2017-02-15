From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Wed, 15 Feb 2017 13:10:20 +0200
Message-ID: <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35466 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751412AbdBOLKl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 06:10:41 -0500
Received: by mail-qt0-f196.google.com with SMTP id s58so20730194qtc.2
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 03:10:41 -0800 (PST)
In-Reply-To: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 2:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> All rx and rx netdev interrupts are handled by respectively
> by mlx4_en_rx_irq() and mlx4_en_tx_irq() which simply schedule a NAPI.
>
> But mlx4_eq_int() also fires a tasklet to service all items that were
> queued via mlx4_add_cq_to_tasklet(), but this handler was not called
> unless user cqe was handled.
>
> This is very confusing, as "mpstat -I SCPU ..." show huge number of
> tasklet invocations.
>
> This patch saves this overhead, by carefully firing the tasklet directly
> from mlx4_add_cq_to_tasklet(), removing four atomic operations per IRQ.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cq.c |    6 +++++-
>  drivers/net/ethernet/mellanox/mlx4/eq.c |    9 +--------
>  2 files changed, 6 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
> index 6b8635378f1fcb2aae4e8ac390bcd09d552c2256..fa6d2354a0e910ee160863e3cbe21a512d77bf03 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
> @@ -81,8 +81,9 @@ void mlx4_cq_tasklet_cb(unsigned long data)
>
>  static void mlx4_add_cq_to_tasklet(struct mlx4_cq *cq)
>  {
> -       unsigned long flags;
>         struct mlx4_eq_tasklet *tasklet_ctx = cq->tasklet_ctx.priv;
> +       unsigned long flags;
> +       bool kick;
>
>         spin_lock_irqsave(&tasklet_ctx->lock, flags);
>         /* When migrating CQs between EQs will be implemented, please note
> @@ -92,7 +93,10 @@ static void mlx4_add_cq_to_tasklet(struct mlx4_cq *cq)
>          */
>         if (list_empty_careful(&cq->tasklet_ctx.list)) {
>                 atomic_inc(&cq->refcount);
> +               kick = list_empty(&tasklet_ctx->list);

So first one in would fire the tasklet, but wouldn't this cause CQE
processing loss
in the same mlx4_eq_int loop if the tasklet was fast enough to
schedule and while other CQEs are going to add themselves to the
tasklet_ctx->list ?

Anyway i tried to find race scenarios that could cause such thing but
synchronization looks good.

>                 list_add_tail(&cq->tasklet_ctx.list, &tasklet_ctx->list);
> +               if (kick)
> +                       tasklet_schedule(&tasklet_ctx->task);
>         }
>         spin_unlock_irqrestore(&tasklet_ctx->lock, flags);
>  }
> diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
> index 0509996957d9664b612358dd805359f4bc67b8dc..39232b6a974f4b4b961d3b0b8634f04e6b9d0caa 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/eq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
> @@ -494,7 +494,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
>  {
>         struct mlx4_priv *priv = mlx4_priv(dev);
>         struct mlx4_eqe *eqe;
> -       int cqn = -1;
> +       int cqn;
>         int eqes_found = 0;
>         int set_ci = 0;
>         int port;
> @@ -840,13 +840,6 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
>
>         eq_set_ci(eq, 1);
>
> -       /* cqn is 24bit wide but is initialized such that its higher bits
> -        * are ones too. Thus, if we got any event, cqn's high bits should be off
> -        * and we need to schedule the tasklet.
> -        */
> -       if (!(cqn & ~0xffffff))

what if we simply change this condition to:
if (!list_empty_careful(eq->tasklet_ctx.list))

Wouldn't this be sort of equivalent to what you did ? and this way we
would simply fire the tasklet only when needed and not on every
handled CQE.

> -               tasklet_schedule(&eq->tasklet_ctx.task);
> -
>         return eqes_found;
>  }
>
>
>
