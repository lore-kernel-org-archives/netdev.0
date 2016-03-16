From: Maor Gottlieb <maor.linux@gmail.com>
Subject: Re: linux-next: manual merge of the rdma tree with the net-next tree
Date: Wed, 16 Mar 2016 16:27:28 +0200
Message-ID: <CA+WJiLyyAVX41JgVUtPXsupmzBnqMWugZ_BCeO5s+z3Aa1MQYg@mail.gmail.com>
References: <20160316115809.61b4478e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amir Vadai <amir@vadai.me>, Maor Gottlieb <maorg@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160316115809.61b4478e@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-03-16 2:58 GMT+02:00 Stephen Rothwell <sfr@canb.auug.org.au>:
> Hi all,
>
> Today's linux-next merge of the rdma tree got a conflict in:
>
>   drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
>
> between commit:
>
>   60ab4584f5bf ("net/mlx5_core: Set flow steering dest only for forward rules")
>
> from the net-next tree and commit:
>
>   b3638e1a7664 ("net/mlx5_core: Introduce forward to next priority action")
>
> from the rdma tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>
> --
> Cheers,
> Stephen Rothwell
>
> diff --cc drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
> index e848d708d2b7,bf3446794bd5..000000000000
> --- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
> @@@ -73,10 -73,13 +73,13 @@@
>   #define BY_PASS_MIN_LEVEL (KENREL_MIN_LEVEL + MLX5_BY_PASS_NUM_PRIOS +\
>                            LEFTOVERS_MAX_FT)
>
>  -#define KERNEL_MAX_FT 2
>  -#define KERNEL_NUM_PRIOS 1
>  +#define KERNEL_MAX_FT 3
>  +#define KERNEL_NUM_PRIOS 2
>   #define KENREL_MIN_LEVEL 2
>
> + #define ANCHOR_MAX_FT 1
> + #define ANCHOR_NUM_PRIOS 1
> + #define ANCHOR_MIN_LEVEL (BY_PASS_MIN_LEVEL + 1)
>   struct node_caps {
>         size_t  arr_sz;
>         long    *caps;
> @@@ -360,8 -367,13 +367,13 @@@ static void del_rule(struct fs_node *no
>         memcpy(match_value, fte->val, sizeof(fte->val));
>         fs_get_obj(ft, fg->node.parent);
>         list_del(&rule->node.list);
> +       if (rule->sw_action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
> +               mutex_lock(&rule->dest_attr.ft->lock);
> +               list_del(&rule->next_ft);
> +               mutex_unlock(&rule->dest_attr.ft->lock);
> +       }
>  -      fte->dests_size--;
>  -      if (fte->dests_size) {
>  +      if ((fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) &&
>  +          --fte->dests_size) {
>                 err = mlx5_cmd_update_fte(dev, ft,
>                                           fg->id, fte);
>                 if (err)
> @@@ -762,9 -835,9 +835,10 @@@ static struct mlx5_flow_rule *alloc_rul
>         if (!rule)
>                 return NULL;
>
> +       INIT_LIST_HEAD(&rule->next_ft);
>         rule->node.type = FS_TYPE_FLOW_DEST;
>  -      memcpy(&rule->dest_attr, dest, sizeof(*dest));
>  +      if (dest)
>  +              memcpy(&rule->dest_attr, dest, sizeof(*dest));
>
>         return rule;
>   }
> @@@ -783,12 -856,16 +857,17 @@@ static struct mlx5_flow_rule *add_rule_
>                 return ERR_PTR(-ENOMEM);
>
>         fs_get_obj(ft, fg->node.parent);
> -       /* Add dest to dests list- added as first element after the head */
> +       /* Add dest to dests list- we need flow tables to be in the
> +        * end of the list for forward to next prio rules.
> +        */
>         tree_init_node(&rule->node, 1, del_rule);
> -       list_add_tail(&rule->node.list, &fte->node.children);
> +       if (dest && dest->type != MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE)
> +               list_add(&rule->node.list, &fte->node.children);
> +       else
> +               list_add_tail(&rule->node.list, &fte->node.children);
>  -      fte->dests_size++;
>  -      if (fte->dests_size == 1)
>  +      if (dest)
>  +              fte->dests_size++;
>  +      if (fte->dests_size == 1 || !dest)
>                 err = mlx5_cmd_create_fte(get_dev(&ft->node),
>                                           ft, fg->id, fte);
>         else

Hi Stephen,

I reveiwed your merge and it's fine.

Thanks,
Maor
