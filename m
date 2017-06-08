From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC net-next 3/4] net/mlx5: Separate between eswitch and
 MPFS l2 table logic
Date: Thu, 8 Jun 2017 12:26:31 +0300
Message-ID: <CAJ3xEMgdXGZfC5nbtA2D5m=78zPJYQfpV+xhhXz340bEJd6-6Q@mail.gmail.com>
References: <20170607234214.24723-1-saeedm@mellanox.com> <20170607234214.24723-4-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jes Sorensen <jsorensen@fb.com>,
        Kernel Team <kernel-team@fb.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35341 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbdFHJ0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:26:32 -0400
Received: by mail-oi0-f65.google.com with SMTP id v74so2409400oie.2
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 02:26:31 -0700 (PDT)
In-Reply-To: <20170607234214.24723-4-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 2:42 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:

> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c

> @@ -363,17 +364,28 @@ static void mlx5e_del_vlan_rules(struct mlx5e_priv *priv)
>  static void mlx5e_execute_l2_action(struct mlx5e_priv *priv,
>                                     struct mlx5e_l2_hash_node *hn)
>  {
> -       switch (hn->action) {
> +       u8 action = hn->action;
> +       int l2_err = 0;
> +
> +       switch (action) {
>         case MLX5E_ACTION_ADD:
>                 mlx5e_add_l2_flow_rule(priv, &hn->ai, MLX5E_FULLMATCH);
> +               /* mlx5_mpfs_add_mac will skip mc addresses */
> +               l2_err = mlx5_mpfs_add_mac(priv->mdev, hn->ai.addr);
>                 hn->action = MLX5E_ACTION_NONE;
>                 break;
>
>         case MLX5E_ACTION_DEL:
> +               /* mlx5_mpfs_del_mac will skip mc addresses */
> +               l2_err = mlx5_mpfs_del_mac(priv->mdev, hn->ai.addr);
>                 mlx5e_del_l2_flow_rule(priv, &hn->ai);
>                 mlx5e_del_l2_from_hash(hn);
>                 break;
>         }

> --- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c

>  static int esw_add_uc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
>  {
> -       struct hlist_head *hash = esw->l2_table.l2_hash;
> -       struct esw_uc_addr *esw_uc;
>         u8 *mac = vaddr->node.addr;
>         u32 vport = vaddr->vport;
>         int err;
>
> -       esw_uc = l2addr_hash_find(hash, mac, struct esw_uc_addr);
> -       if (esw_uc) {
> +       /* Skip l2_table_add for PFs,
> +        * it is already done by the PF netdev in mlx5e_execute_l2_action
> +        */
> +       if (!vport)
> +               goto fdb_add;
> +

why !vport means we should go there?

> +       err = mlx5_mpfs_add_mac(esw->dev, mac);
> +       if (err) {
>                 esw_warn(esw->dev,
> -                        "Failed to set L2 mac(%pM) for vport(%d), mac is already in use by vport(%d)\n",
> -                        mac, vport, esw_uc->vport);
> -               return -EEXIST;
> +                        "Failed to add L2 table mac(%pM) for vport(%d), err(%d)\n",
> +                        mac, vport, err);
> +               return err;
>         }
>
> -       esw_uc = l2addr_hash_add(hash, mac, struct esw_uc_addr, GFP_KERNEL);
> -       if (!esw_uc)
> -               return -ENOMEM;
> -       esw_uc->vport = vport;
> -
> -       err = set_l2_table_entry(esw->dev, mac, 0, 0, &esw_uc->table_index);
> -       if (err)
> -               goto abort;
> -
> +fdb_add:
>         /* SRIOV is enabled: Forward UC MAC to vport */
>         if (esw->fdb_table.fdb && esw->mode == SRIOV_LEGACY)
>                 vaddr->flow_rule = esw_fdb_set_vport_rule(esw, mac, vport);
>
> -       esw_debug(esw->dev, "\tADDED UC MAC: vport[%d] %pM index:%d fr(%p)\n",
> -                 vport, mac, esw_uc->table_index, vaddr->flow_rule);
> -       return err;
> -abort:
> -       l2addr_hash_del(esw_uc);
> +       esw_debug(esw->dev, "\tADDED UC MAC: vport[%d] %pM fr(%p)\n",
> +                 vport, mac, vaddr->flow_rule);
> +
>         return err;
>  }


>  static int esw_del_uc_addr(struct mlx5_eswitch *esw, struct vport_addr *vaddr)
>  {
> -       struct hlist_head *hash = esw->l2_table.l2_hash;
> -       struct esw_uc_addr *esw_uc;
>         u8 *mac = vaddr->node.addr;
>         u32 vport = vaddr->vport;
> +       int err = 0;
>
> -       esw_uc = l2addr_hash_find(hash, mac, struct esw_uc_addr);
> -       if (!esw_uc || esw_uc->vport != vport) {
> -               esw_debug(esw->dev,
> -                         "MAC(%pM) doesn't belong to vport (%d)\n",
> -                         mac, vport);
> -               return -EINVAL;
> -       }
> -       esw_debug(esw->dev, "\tDELETE UC MAC: vport[%d] %pM index:%d fr(%p)\n",
> -                 vport, mac, esw_uc->table_index, vaddr->flow_rule);
> +       /* Skip l2_table_del for PFs,
> +        * it is already done by the PF netdev in mlx5e_execute_l2_action
> +        */
> +       if (!vport)
> +               goto fdb_del;
>
> -       del_l2_table_entry(esw->dev, esw_uc->table_index);
> +       err = mlx5_mpfs_del_mac(esw->dev, mac);
> +       if (err)
> +               esw_warn(esw->dev,
> +                        "Failed to del L2 table mac(%pM) for vport(%d), err(%d)\n",
> +                        mac, vport, err);
>
> +fdb_del:
>         if (vaddr->flow_rule)
>                 mlx5_del_flow_rules(vaddr->flow_rule);
>         vaddr->flow_rule = NULL;
>
> -       l2addr_hash_del(esw_uc);
>         return 0;
>  }
>

can we somehow put these areas into a pre-patch?
