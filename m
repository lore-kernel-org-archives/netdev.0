From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 1/3] mlx5: Move pci device handling from mlx5_ib
 to mlx5_core
Date: Mon, 28 Jul 2014 23:57:37 +0300
Message-ID: <CAJZOPZLyhh6pGSwFHOe8oCc4a3xVTdCHric6sH78Kz5Dr7NvLw@mail.gmail.com>
References: <1406579424-16213-1-git-send-email-eli@mellanox.com>
	<1406579424-16213-2-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roland Dreier <roland@kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eli Cohen <eli@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:53977 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbaG1U5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 16:57:38 -0400
Received: by mail-qa0-f45.google.com with SMTP id cm18so8465574qab.4
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 13:57:37 -0700 (PDT)
In-Reply-To: <1406579424-16213-2-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 28, 2014 at 11:30 PM, Eli Cohen <eli@dev.mellanox.co.il> wrote:
[...]
> --- a/drivers/infiniband/hw/mlx5/main.c
> +++ b/drivers/infiniband/hw/mlx5/main.c
> @@ -54,96 +54,17 @@ MODULE_DESCRIPTION("Mellanox Connect-IB HCA >
[...]
-static int prof_sel = 2;
> -module_param_named(prof_sel, prof_sel, int, 0444);
> -MODULE_PARM_DESC(prof_sel, "profile selector. Valid range 0 - 2");
> +static int deprecated_prof_sel = 2;
> +module_param_named(prof_sel, deprecated_prof_sel, int, 0444);
> +MODULE_PARM_DESC(prof_sel, "profile selector. Deprecated here. Moved to module mlx5_core");

[...]

> @@ -1340,28 +1260,19 @@ static int init_one(struct pci_dev *pdev,
>
>         dev = (struct mlx5_ib_dev *)ib_alloc_device(sizeof(*dev));
>         if (!dev)
> -               return -ENOMEM;
> +               return NULL;
>
> -       mdev = &dev->mdev;
> -       mdev->event = mlx5_ib_event;
> -       if (prof_sel >= ARRAY_SIZE(profile)) {
> -               pr_warn("selected pofile out of range, selceting default\n");
> -               prof_sel = 0;
> -       }

You need to issue a warning here if someone attempts to change the
previously default value of the now deprecated module param. E.g warn
this is deprecated and point them to mlx5_core


> -       mdev->profile = &profile[prof_sel];
> -       err = mlx5_dev_init(mdev, pdev);
> -       if (err)
> -               goto err_free;
> +       dev->mdev = mdev;
>
>         err = get_port_caps(dev);
>         if (err)
> -               goto err_cleanup;
> +               goto err_dealloc;
>
>         get_ext_port_caps(dev);
>
>         err = alloc_comp_eqs(dev);
>         if (err)
> -               goto err_cleanup;
> +               goto err_dealloc;
>
>         MLX5_INIT_DOORBELL_LOCK(&dev->uar_lock);
>
> @@ -1480,7 +1391,7 @@ static int init_one(struct pci_dev *pdev,
>
>         dev->ib_active = true;
>
> -       return 0;
> +       return dev;
>
>  err_umrc:
>         destroy_umrc_res(dev);
