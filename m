From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC net-next 3/4] net/mlx5: Separate between eswitch and
 MPFS l2 table logic
Date: Thu, 8 Jun 2017 12:13:18 +0300
Message-ID: <CAJ3xEMi9+iaa3CCA-gdBC7Okz3KgpWbea-vvfYEJFpTQkboxUA@mail.gmail.com>
References: <20170607234214.24723-1-saeedm@mellanox.com> <20170607234214.24723-4-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jes Sorensen <jsorensen@fb.com>,
        Kernel Team <kernel-team@fb.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:33078 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751450AbdFHJNT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:13:19 -0400
Received: by mail-ot0-f194.google.com with SMTP id k4so3070256otd.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 02:13:19 -0700 (PDT)
In-Reply-To: <20170607234214.24723-4-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 2:42 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
[...]
>  9 files changed, 376 insertions(+), 223 deletions(-)

a bit of heavy duty for this sort of sensitive change, should
investigate if it can be broken a bit

> +int mlx5_mpfs_init(struct mlx5_core_dev *dev)
> +{
> +       int l2table_size = 1 << MLX5_CAP_GEN(dev, log_max_l2_table);
> +       struct mlx5_mpfs *mpfs;
> +
> +       if (!MLX5_VPORT_MANAGER(dev))
> +               return 0;

In commit 955bc48081805c053 we added

+ static bool mlx5e_is_eswitch_vport_mngr(struct mlx5_core_dev *mdev)
+{
+       return (MLX5_CAP_GEN(mdev, vport_group_manager) &&
+               MLX5_CAP_GEN(mdev, port_type) == MLX5_CAP_PORT_TYPE_ETH);
+}
+

and now you add

+#define MLX5_VPORT_MANAGER(mdev) \
+       (MLX5_CAP_GEN(mdev, vport_group_manager) && mlx5_core_is_pf(mdev))
+

would be good to align things across the place with a pre-patch and
then use the whatever check
we need to apply

BTW  mlx5e_is_eswitch_vport_mngr() should return false in the down
stream patch when eswitch is compiled out, right?

> +void mlx5_mpfs_cleanup(struct mlx5_core_dev *dev)
> +{
> +       struct mlx5_mpfs *mpfs = dev->priv.mpfs;
> +
> +       if (!MLX5_VPORT_MANAGER(dev))
> +               return;
> +
> +       WARN_ON(!hlist_empty(mpfs->hash));

I don't see any line with WARN_ON that was deleted by this patch, why add that?

> +       kfree(mpfs->bitmap);
> +       kfree(mpfs);
> +}
> +
> +int mlx5_mpfs_add_mac(struct mlx5_core_dev *dev, u8 *mac)
> +{

> +       if (!MLX5_VPORT_MANAGER(dev))
> +               return 0;
> +
> +       if (is_multicast_ether_addr(mac))
> +               return 0;

It would have been much better reviewed and maintained if we can code
things in a manner under which we don't get here if not appropriate and
not simulate successful return.

> +int mlx5_mpfs_del_mac(struct mlx5_core_dev *dev, u8 *mac)
> +{

> +       if (!MLX5_VPORT_MANAGER(dev))
> +               return 0;
> +
> +       if (is_multicast_ether_addr(mac))
> +               return 0;

same comment as for the add_mac call
