From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Fri, 17 Feb 2017 18:46:09 -0800
Message-ID: <1487385969.1311.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9bFC1nVC1Sp3WiAf_OkO_6O9XYqJGRn21yg32NYey6Vw@mail.gmail.com>
         <1487259028.1311.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36316 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752446AbdBRCqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 21:46:42 -0500
Received: by mail-pg0-f66.google.com with SMTP id a123so3530149pgc.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 18:46:11 -0800 (PST)
In-Reply-To: <1487259028.1311.40.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-16 at 07:30 -0800, Eric Dumazet wrote:
> On Thu, 2017-02-16 at 14:38 +0200, Saeed Mahameed wrote:
> 
> > Acked-by: Saeed Mahameed <saeedm@mellanox.com>
> 
> Thanks for reviewing this Saeed !

Note that mlx4_add_cq_to_tasklet() is called from hard irq context, so
we could replace the spin_lock_irqsave() by spin_lock()

Not that I care, but you might be interested ;)

Thanks.

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index fa6d2354a0e910ee160863e3cbe21a512d77bf03..9dcac3a367425f2804e933842698c66685baf626 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -79,13 +79,13 @@ void mlx4_cq_tasklet_cb(unsigned long data)
 		tasklet_schedule(&ctx->task);
 }
 
+/* Called from hard irq handler */
 static void mlx4_add_cq_to_tasklet(struct mlx4_cq *cq)
 {
 	struct mlx4_eq_tasklet *tasklet_ctx = cq->tasklet_ctx.priv;
-	unsigned long flags;
 	bool kick;
 
-	spin_lock_irqsave(&tasklet_ctx->lock, flags);
+	spin_lock(&tasklet_ctx->lock);
 	/* When migrating CQs between EQs will be implemented, please note
 	 * that you need to sync this point. It is possible that
 	 * while migrating a CQ, completions on the old EQs could
@@ -98,7 +98,7 @@ static void mlx4_add_cq_to_tasklet(struct mlx4_cq *cq)
 		if (kick)
 			tasklet_schedule(&tasklet_ctx->task);
 	}
-	spin_unlock_irqrestore(&tasklet_ctx->lock, flags);
+	spin_unlock(&tasklet_ctx->lock);
 }
 
 void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn)
