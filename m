From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 6/8] net/mlx5e: Introduce tc offload support
Date: Tue, 1 Mar 2016 17:59:59 +0200
Message-ID: <CALzJLG8oPTwoowafcPODKwZ4=Uxeqs2jqr6L7UUME_ZVmx66wg@mail.gmail.com>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
	<1456842290-7844-7-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f194.google.com ([209.85.160.194]:36486 "EHLO
	mail-yk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbcCAQAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 11:00:00 -0500
Received: by mail-yk0-f194.google.com with SMTP id z13so5048743ykd.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 07:59:59 -0800 (PST)
In-Reply-To: <1456842290-7844-7-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 4:24 PM, Amir Vadai <amir@vadai.me> wrote:
> +#define FT_CAP(f) MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_receive.f)
> +       if (FT_CAP(flow_modify_en) &&
> +           FT_CAP(modify_root) &&
> +           FT_CAP(identified_miss_table_mode) &&
> +           FT_CAP(flow_table_modify))
> +               priv->netdev->hw_features      |= NETIF_F_HW_TC;
> +
>         netdev->features         |= NETIF_F_HIGHDMA;
>
>         netdev->priv_flags       |= IFF_UNICAST_FLT;
>
> +       mlx5e_tc_init(priv);

This is not the place for this, We usually do internal data structure
initialization  after we create all HW resources in
mlx5e_create_netdev
Please see mlx5e_vxlan_init as example, and you already call
mlx5e_tc_cleanup inside mlx5e_destroy_netdev, please move the
mlx5e_tc_init
to mlx5e_create_netdev after HW resources creation,


> @@ -2558,6 +2588,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
>         mlx5_core_dealloc_transport_domain(priv->mdev, priv->tdn);
>         mlx5_core_dealloc_pd(priv->mdev, priv->pdn);
>         mlx5_unmap_free_uar(priv->mdev, &priv->cq_uar);
> +       mlx5e_tc_cleanup(priv);

I would suggest to move  mlx5e_tc_init to be right after
mlx5e_vxlan_init and mlx5e_tc_cleanup before mlx5e_vxlan_cleanup.

> +struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
> +                                        u32 *match_c, u32 *match_v,
> +                                        u32 action, u32 flow_tag)
> +{
> +       struct mlx5_flow_destination dest = {
> +               .type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE,
> +               {.ft = priv->fts.vlan.t},
> +       };
> +       struct mlx5_flow_rule *rule;
> +       bool table_created = false;
> +
> +       if (IS_ERR_OR_NULL(priv->fts.tc.t)) {
> +               priv->fts.tc.t =
> +                       mlx5_create_auto_grouped_flow_table(priv->fts.ns, 0,
> +                                                           MLX5E_TC_FLOW_TABLE_NUM_ENTRIES,
> +                                                           MLX5E_TC_FLOW_TABLE_NUM_GROUPS);
> +               if (IS_ERR(priv->fts.tc.t)) {
> +                       netdev_err(priv->netdev,
> +                                  "Failed to create tc offload table\n");
> +                       return ERR_CAST(priv->fts.tc.t);

Here priv->fts.tc.t will be invalid pointer and in your code you treat
it as NULL in case of failure.

> +               }
> +
> +               table_created = true;
> +       }
> +
> +       rule = mlx5_add_flow_rule(priv->fts.tc.t, MLX5_MATCH_OUTER_HEADERS,
> +                                 match_c, match_v,
> +                                 action, flow_tag,
> +                                 action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST ? &dest : NULL);
> +
> +       if (IS_ERR(rule) && table_created) {
> +               mlx5_destroy_flow_table(priv->fts.tc.t);
> +               priv->fts.tc.t = NULL;
> +       }
> +
> +       return rule;
> +}
> +

> +void mlx5e_tc_cleanup(struct mlx5e_priv *priv)
> +{
> +       struct mlx5e_tc_flow_table *tc = &priv->fts.tc;
> +
> +       rhashtable_free_and_destroy(&tc->ht, _mlx5e_tc_del_flow, priv);
> +
> +       if (priv->fts.tc.t) {

priv->fts.tc.t will be invalid pointer and this test will pass in case
 mlx5_create_auto_grouped_flow_table had failed

> +               mlx5_destroy_flow_table(priv->fts.tc.t);
> +               priv->fts.tc.t = NULL;
> +       }
> +}
