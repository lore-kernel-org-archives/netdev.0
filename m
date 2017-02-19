From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Mon, 20 Feb 2017 00:39:13 +0200
Message-ID: <CALzJLG-+4ANDstQ_09NCy2+N66Ko-8yMuE7a1ve52_nEwTgbCQ@mail.gmail.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG9bFC1nVC1Sp3WiAf_OkO_6O9XYqJGRn21yg32NYey6Vw@mail.gmail.com>
 <1487259028.1311.40.camel@edumazet-glaptop3.roam.corp.google.com> <1487385969.1311.91.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Matan Barak <matanb@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36761 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdBSWjf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 17:39:35 -0500
Received: by mail-qt0-f193.google.com with SMTP id h53so12060067qth.3
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 14:39:35 -0800 (PST)
In-Reply-To: <1487385969.1311.91.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 18, 2017 at 4:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-02-16 at 07:30 -0800, Eric Dumazet wrote:
>> On Thu, 2017-02-16 at 14:38 +0200, Saeed Mahameed wrote:
>>
>> > Acked-by: Saeed Mahameed <saeedm@mellanox.com>
>>
>> Thanks for reviewing this Saeed !
>
> Note that mlx4_add_cq_to_tasklet() is called from hard irq context, so
> we could replace the spin_lock_irqsave() by spin_lock()
>
> Not that I care, but you might be interested ;)
>

Sure we are !
we will take it from here :-).

Thank you Eric.

> Thanks.
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
> index fa6d2354a0e910ee160863e3cbe21a512d77bf03..9dcac3a367425f2804e933842698c66685baf626 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
> @@ -79,13 +79,13 @@ void mlx4_cq_tasklet_cb(unsigned long data)
>                 tasklet_schedule(&ctx->task);
>  }
>
> +/* Called from hard irq handler */
>  static void mlx4_add_cq_to_tasklet(struct mlx4_cq *cq)
>  {
>         struct mlx4_eq_tasklet *tasklet_ctx = cq->tasklet_ctx.priv;
> -       unsigned long flags;
>         bool kick;
>
> -       spin_lock_irqsave(&tasklet_ctx->lock, flags);
> +       spin_lock(&tasklet_ctx->lock);
>         /* When migrating CQs between EQs will be implemented, please note
>          * that you need to sync this point. It is possible that
>          * while migrating a CQ, completions on the old EQs could
> @@ -98,7 +98,7 @@ static void mlx4_add_cq_to_tasklet(struct mlx4_cq *cq)
>                 if (kick)
>                         tasklet_schedule(&tasklet_ctx->task);
>         }
> -       spin_unlock_irqrestore(&tasklet_ctx->lock, flags);
> +       spin_unlock(&tasklet_ctx->lock);
>  }
>
>  void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn)
>
>
