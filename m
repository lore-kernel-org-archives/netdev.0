From: Jinpu Wang <jinpu.wang@profitbricks.com>
Subject: Re: [PATCH]mlx4-core: fix possible use after free in cq_completion
Date: Fri, 24 Jul 2015 11:48:35 +0200
Message-ID: <CAMGffEmStnjfN12Z6gL6pw=S_TS6+9MGuhmu=pCn9uSZpjQYXA@mail.gmail.com>
References: <CAMGffEnvM32Ae-XHDLuwGy1V7NKqosO+eAtakbKJCcVpqKQg3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Yun Wang <yun.wang@profitbricks.com>
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35798 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbbGXJsz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 05:48:55 -0400
Received: by wibxm9 with SMTP id xm9so21050516wib.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 02:48:54 -0700 (PDT)
In-Reply-To: <CAMGffEnvM32Ae-XHDLuwGy1V7NKqosO+eAtakbKJCcVpqKQg3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2015 at 10:18 AM, Jinpu Wang
<jinpu.wang@profitbricks.com> wrote:
> Hi all,
>
> I hit bug in OFED, I report to link below:
>
> http://marc.info/?l=3Dlinux-rdma&m=3D143634872328553&w=3D2
> I checked latest mainline Linux 4.2-rc3, it has similar bug.
> Here is the patch against Linux 4.2-rc3, compile test only.
>
> I add one copy as attachment in case mail client break the patch form=
at.
>
> From a9fbc1ff0768acdb260e57e3324798fc0082d194 Mon Sep 17 00:00:00 200=
1
> From: Jack Wang <jinpu.wang@profitbricks.com>
> Date: Thu, 23 Jul 2015 18:58:08 +0200
> Subject: [PATCH] mlx4_core: fix possible use-after-free in cq_complet=
ion
>
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
> @@ -99,10 +99,15 @@ static void mlx4_add_cq_to_tasklet(struct mlx4_cq=
 *cq)
>
>  void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn)
>  {
> +    struct mlx4_cq_table *cq_table =3D &mlx4_priv(dev)->cq_table;
>      struct mlx4_cq *cq;
>
> -    cq =3D radix_tree_lookup(&mlx4_priv(dev)->cq_table.tree,
> -                   cqn & (dev->caps.num_cqs - 1));
> +    spin_lock(&cq_table->lock);
> +    cq =3D radix_tree_lookup(&cq_table->tree, cqn & (dev->caps.num_c=
qs - 1));
> +    if (cq)
> +        atomic_inc(&cq->refcount);
> +
> +    spin_unlock(&cq_table->lock);
>      if (!cq) {
>          mlx4_dbg(dev, "Completion event for bogus CQ %08x\n", cqn);
>          return;
> @@ -111,6 +116,8 @@ void mlx4_cq_completion(struct mlx4_dev *dev, u32=
 cqn)
>      ++cq->arm_sn;
>
>      cq->comp(cq);
> +    if (atomic_dec_and_test(&cq->refcount))
> +        complete(&cq->free);
>  }
>
>  void mlx4_cq_event(struct mlx4_dev *dev, u32 cqn, int event_type)
> --
> 1.9.1
>

=46ound almost same patch as what I did, but 3 years ago :)

http://linux-rdma.vger.kernel.narkive.com/NSyWFRkW/patch-rfc-for-next-n=
et-mlx4-core-fix-racy-flow-in-the-driver-cq-completion-handler

Could you consider to apply the patch, it fix real PANIC?

Thanks

Jack

--
Mit freundlichen Gr=C3=BC=C3=9Fen,
Best Regards,

Jack Wang

Linux Kernel Developer Storage
ProfitBricks GmbH  The IaaS-Company.

ProfitBricks GmbH
Greifswalder Str. 207
D - 10405 Berlin
Tel: +49 30 5770083-42
=46ax: +49 30 5770085-98
Email: jinpu.wang@profitbricks.com
URL: http://www.profitbricks.de

Sitz der Gesellschaft: Berlin.
Registergericht: Amtsgericht Charlottenburg, HRB 125506 B.
Gesch=C3=A4ftsf=C3=BChrer: Andreas Gauger, Achim Weiss.
