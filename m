From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 07/12] mlxsw: spectrum: Add the multicast
 routing offloading logic
Date: Mon, 25 Sep 2017 13:40:37 +0300
Message-ID: <5ded28ba-0a0c-927c-5a5e-c0fc761ca49e@cumulusnetworks.com>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-8-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:49785 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934575AbdIYKkl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 06:40:41 -0400
Received: by mail-wm0-f47.google.com with SMTP id r74so18105310wme.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 03:40:40 -0700 (PDT)
In-Reply-To: <20170924172212.10096-8-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/17 20:22, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Add the multicast router offloading logic, which is in charge of handling
> the VIF and MFC notifications and translating it to the hardware logic API.
> 
> The offloading logic has to overcome several obstacles in order to safely
> comply with the kernel multicast router user API:
>  - It must keep track of the mapping between VIFs to netdevices. The user
>    can add an MFC cache entry pointing to a VIF, delete the VIF and add
>    re-add it with a different netdevice. The offloading logic has to handle
>    this in order to be compatible with the kernel logic.
>  - It must keep track of the mapping between netdevices to spectrum RIFs,
>    as the current hardware implementation assume having a RIF for every
>    port in a multicast router.
>  - It must handle routes pointing to pimreg device to be trapped to the
>    kernel, as the packet should be delivered to userspace.
>  - It must handle routes pointing tunnel VIFs. The current implementation
>    does not support multicast forwarding to tunnels, thus routes that point
>    to a tunnel should be trapped to the kernel.
>  - It must be aware of proxy multicast routes, which include both (*,*)
>    routes and duplicate routes. Currently proxy routes are not offloaded
>    and trigger the abort mechanism: removal of all routes from hardware and
>    triggering the traffic to go through the kernel.
> 
> The multicast routing offloading logic also updates the counters of the
> offloaded MFC routes in a periodic work.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
>  - Update the lastuse MFC entry field too, in addition to packets an bytes.
> ---
>  drivers/net/ethernet/mellanox/mlxsw/Makefile      |    3 +-
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h    |    1 +
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c | 1014 +++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h |  133 +++
>  4 files changed, 1150 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h
> 
[snip]
> +static void mlxsw_sp_mr_route_erase(struct mlxsw_sp_mr_table *mr_table,
> +				    struct mlxsw_sp_mr_route *mr_route)
> +{
> +	struct mlxsw_sp *mlxsw_sp = mr_table->mlxsw_sp;
> +	struct mlxsw_sp_mr *mr = mlxsw_sp->mr;
> +
> +	mr->mr_ops->route_destroy(mlxsw_sp, mr->priv, mr_route->route_priv);
> +	kfree(mr_route->route_priv);
> +}
> +
> +static struct mlxsw_sp_mr_route *
> +mlxsw_sp_mr_route4_create(struct mlxsw_sp_mr_table *mr_table,
> +			  struct mfc_cache *mfc)
> +{
> +	struct mlxsw_sp_mr_route_vif_entry *rve, *tmp;
> +	struct mlxsw_sp_mr_route *mr_route;
> +	int err;
> +	int i;
> +
> +	/* Allocate and init a new route and fill it with parameters */
> +	mr_route = kzalloc(sizeof(*mr_table), GFP_KERNEL);

sizeof(*mr_table) ? Shouldn't you allocate sizeof struct mlsw_sp_mr_route (*mr_route) here ?

> +	if (!mr_route)
> +		return ERR_PTR(-ENOMEM);
> +	INIT_LIST_HEAD(&mr_route->evif_list);
> +	mlxsw_sp_mr_route4_key(mr_table, &mr_route->key, mfc);
> +
> +	/* Find min_mtu and link iVIF and eVIFs */
> +	mr_route->min_mtu = ETH_MAX_MTU;
> +	ipmr_cache_hold(mfc);
> +	mr_route->mfc4 = mfc;
> +	mr_route->mr_table = mr_table;
> +	for (i = 0; i < MAXVIFS; i++) {
> +		if (mfc->mfc_un.res.ttls[i] != 255) {
> +			err = mlxsw_sp_mr_route_evif_link(mr_route,
> +							  &mr_table->vifs[i]);
> +			if (err)
> +				goto err;
> +			if (mr_table->vifs[i].dev &&
> +			    mr_table->vifs[i].dev->mtu < mr_route->min_mtu)
> +				mr_route->min_mtu = mr_table->vifs[i].dev->mtu;
> +		}
> +	}
> +	mlxsw_sp_mr_route_ivif_link(mr_route, &mr_table->vifs[mfc->mfc_parent]);
> +	if (err)
> +		goto err;
> +
> +	mr_route->route_action = mlxsw_sp_mr_route_action(mr_route);
> +	return mr_route;
> +err:
> +	ipmr_cache_put(mfc);
> +	list_for_each_entry_safe(rve, tmp, &mr_route->evif_list, route_node)
> +		mlxsw_sp_mr_route_evif_unlink(rve);
> +	kfree(mr_route);
> +	return ERR_PTR(err);
> +}
> +
> +static void mlxsw_sp_mr_route4_destroy(struct mlxsw_sp_mr_table *mr_table,
> +				       struct mlxsw_sp_mr_route *mr_route)
> +{
> +	struct mlxsw_sp_mr_route_vif_entry *rve, *tmp;
> +
> +	mlxsw_sp_mr_route_ivif_unlink(mr_route);
> +	ipmr_cache_put(mr_route->mfc4);
> +	list_for_each_entry_safe(rve, tmp, &mr_route->evif_list, route_node)
> +		mlxsw_sp_mr_route_evif_unlink(rve);
> +	kfree(mr_route);
> +}
[snip]
