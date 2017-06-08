From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC net-next 2/4] net/mlx5e: NIC netdev init flow cleanup
Date: Thu, 8 Jun 2017 11:30:24 +0300
Message-ID: <CAJ3xEMhDqHWp4mr=iNiQanFG2Pp6fiR=pALhrduo0onfzGiqYw@mail.gmail.com>
References: <20170607234214.24723-1-saeedm@mellanox.com> <20170607234214.24723-3-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jes Sorensen <jsorensen@fb.com>,
        Kernel Team <kernel-team@fb.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33731 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751450AbdFHIaZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 04:30:25 -0400
Received: by mail-oi0-f66.google.com with SMTP id k145so1085432oih.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 01:30:25 -0700 (PDT)
In-Reply-To: <20170607234214.24723-3-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 2:42 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Remove redundant mlx5_eswitch_unregister_vport_rep in mlx5e_add error flow.

Maybe have point patch that makes it clear we fix commit 26e59d807 ?


> Hide mlx5e_rep_priv and eswitch internal structures from en_main.c in
> preparation for downstream patches which allows compiling the driver
> without en_rep and eswitch.

otherwise than the about comment and another one re how to do that,
patch seems fine

>  static void *mlx5e_add(struct mlx5_core_dev *mdev)
>  {
> -       struct mlx5_eswitch *esw = mdev->priv.eswitch;
> -       int total_vfs = MLX5_TOTAL_VPORTS(mdev);
> -       struct mlx5e_rep_priv *rpriv = NULL;
> +       struct net_device *netdev;
> +       void *rpriv = NULL;
>         void *priv;
> -       int vport;
>         int err;
> -       struct net_device *netdev;
>
>         err = mlx5e_check_required_hca_cap(mdev);
>         if (err)
>                 return NULL;
>
>         if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
> -               rpriv = kzalloc(sizeof(*rpriv), GFP_KERNEL);
> +               rpriv = mlx5e_alloc_nic_rep_priv(mdev);
>                 if (!rpriv) {
> -                       mlx5_core_warn(mdev,
> -                                      "Not creating net device, Failed to alloc rep priv data\n");
> +                       mlx5_core_warn(mdev, "Failed to alloc NIC rep priv data\n");
>                         return NULL;
>                 }
> -               rpriv->rep = &esw->offloads.vport_reps[0];
>         }
>
>         netdev = mlx5e_create_netdev(mdev, &mlx5e_nic_profile, rpriv);
>         if (!netdev) {
>                 mlx5_core_err(mdev, "mlx5e_create_netdev failed\n");
> -               goto err_unregister_reps;
> +               kfree(rpriv);
> +               return NULL;

nit - would be better to just do goto err_something and avoid
repeating the kfree/return we already have there

>         }
>
>         priv = netdev_priv(netdev);
> @@ -4407,10 +4403,6 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
>  err_destroy_netdev:
>         mlx5e_destroy_netdev(priv);
>
> -err_unregister_reps:
> -       for (vport = 1; vport < total_vfs; vport++)
> -               mlx5_eswitch_unregister_vport_rep(esw, vport);
> -
+err_something:
>         kfree(rpriv);
>         return NULL;
>  }
