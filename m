From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH]mlx4-core: fix possible use after free in cq_completion
Date: Sun, 26 Jul 2015 17:57:48 +0300
Message-ID: <20150726175748.78091e75@jpm-OptiPlex-GX620>
References: <CAMGffEnvM32Ae-XHDLuwGy1V7NKqosO+eAtakbKJCcVpqKQg3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Yun Wang <yun.wang@profitbricks.com>
To: Jinpu Wang <jinpu.wang@profitbricks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38258 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbbGZO5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 10:57:44 -0400
Received: by wibxm9 with SMTP id xm9so86003945wib.1
        for <netdev@vger.kernel.org>; Sun, 26 Jul 2015 07:57:43 -0700 (PDT)
In-Reply-To: <CAMGffEnvM32Ae-XHDLuwGy1V7NKqosO+eAtakbKJCcVpqKQg3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Jul 2015 10:18:48 +0200
Jinpu Wang <jinpu.wang@profitbricks.com> wrote:

> Hi all,
> 
> I hit bug in OFED, I report to link below:
> 
> http://marc.info/?l=linux-rdma&m=143634872328553&w=2
> I checked latest mainline Linux 4.2-rc3, it has similar bug.
> Here is the patch against Linux 4.2-rc3, compile test only.
> 
> I add one copy as attachment in case mail client break the patch
> format.
> 
> From a9fbc1ff0768acdb260e57e3324798fc0082d194 Mon Sep 17 00:00:00 2001
> From: Jack Wang <jinpu.wang@profitbricks.com>
> Date: Thu, 23 Jul 2015 18:58:08 +0200
> Subject: [PATCH] mlx4_core: fix possible use-after-free in
> cq_completion

Hi Jack,

We have seen this problem, and have developed a fix for it.  We will
be submitting the fix within the next few days (after final testing).
The fix utilizes rcu locking in the interrupt handlers (to avoid
deadlocks).

The fix you propose below has the potential to cause a deadlock.
(We originally tried irq spinlocks here, because this lock is also
grabbed in the process context in mlx4_cq_alloc/free).

The problem is that under VPI, the ETH interface uses multiple msix irq's,
which can result in one cq completion event interrupting another,
in-progress cq completion event. A deadlock results when the handler
for the first cq completion grabs the spinlock, and is interrupted by
the second completion before it has a chance to release the spinlock.
The handler for the second completion will deadlock waiting for the
spinlock to be released.

-Jack



> It's possible during mlx4_cq_free, there are new cq_completion come,
> and there is no spin_lock protection for cq_completion, also no
> refcount protection, it will lead to use after free. So add the
> spin_lock and refcount protection in cq_completion.
> 
> Signed-off-by: Jack Wang <jinpu.wang@profitbricks.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cq.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c
> b/drivers/net/ethernet/mellanox/mlx4/cq.c
> index 3348e64..8d7f405 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
> @@ -99,10 +99,15 @@ static void mlx4_add_cq_to_tasklet(struct mlx4_cq
> *cq)
> 
>  void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn)
>  {
> +    struct mlx4_cq_table *cq_table = &mlx4_priv(dev)->cq_table;
>      struct mlx4_cq *cq;
> 
> -    cq = radix_tree_lookup(&mlx4_priv(dev)->cq_table.tree,
> -                   cqn & (dev->caps.num_cqs - 1));
> +    spin_lock(&cq_table->lock);
> +    cq = radix_tree_lookup(&cq_table->tree, cqn & (dev->caps.num_cqs
> - 1));
> +    if (cq)
> +        atomic_inc(&cq->refcount);
> +
> +    spin_unlock(&cq_table->lock);
>      if (!cq) {
>          mlx4_dbg(dev, "Completion event for bogus CQ %08x\n", cqn);
>          return;
> @@ -111,6 +116,8 @@ void mlx4_cq_completion(struct mlx4_dev *dev, u32
> cqn) ++cq->arm_sn;
> 
>      cq->comp(cq);
> +    if (atomic_dec_and_test(&cq->refcount))
> +        complete(&cq->free);
>  }
> 
>  void mlx4_cq_event(struct mlx4_dev *dev, u32 cqn, int event_type)
