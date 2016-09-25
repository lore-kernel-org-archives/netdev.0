From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next v2 3/6] mlxsw: spectrum_router: Use FIB
 notifications instead of switchdev calls
Date: Sun, 25 Sep 2016 13:22:08 +0300
Message-ID: <20160925102208.GA20792@splinter>
References: <1474622535-4002-1-git-send-email-jiri@resnulli.us>
 <1474622535-4002-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com, kaber@trash.net,
        john@phrozen.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50704 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751582AbcIYKWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 06:22:13 -0400
Content-Disposition: inline
In-Reply-To: <1474622535-4002-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 11:22:12AM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Until now, in order to offload a FIB entry to HW we use switchdev op.
> However that has limits. Mainly in case we need to make the HW aware of
> all route prefixes configured in kernel. HW needs to know those in order
> to properly trap appropriate packets and pass the to kernel to do
> the forwarding. Abort mechanism is now handled within the mlxsw driver.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

[...]

>  static int
>  mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
> -				const struct switchdev_obj_ipv4_fib *fib4,
> +				const struct fib_entry_notifier_info *fen_info,
>  				struct mlxsw_sp_fib_entry *fib_entry)
>  {
> -	struct fib_info *fi = fib4->fi;
> +	struct fib_info *fi = fen_info->fi;
> +	struct mlxsw_sp_rif *r;
> +	int nhsel;
>  
> -	if (fib4->type == RTN_LOCAL || fib4->type == RTN_BROADCAST) {
> +	if (fen_info->type == RTN_LOCAL || fen_info->type == RTN_BROADCAST) {
>  		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
>  		return 0;
>  	}
> -	if (fib4->type != RTN_UNICAST)
> +	if (fen_info->type != RTN_UNICAST)
>  		return -EINVAL;
>  
> -	if (fi->fib_scope != RT_SCOPE_UNIVERSE) {
> -		struct mlxsw_sp_rif *r;
> +	for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
> +		const struct fib_nh *nh = &fi->fib_nh[nhsel];
> +
> +		if (!nh->nh_dev)
> +			continue;
> +		r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, nh->nh_dev);
> +		if (!r) {
> +			/* In case router interface is not found for
> +			 * at least one of the nexthops, that means
> +			 * the nexthop points to some device unrelated
> +			 * to us. Set trap and pass the packets for
> +			 * this prefix to kernel.
> +			 */
> +			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
> +			return 0;
> +		}
> +	}
>  
> +	if (fi->fib_scope != RT_SCOPE_UNIVERSE) {
>  		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
> -		r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, fi->fib_dev);
> -		if (!r)
> -			return -EINVAL;
>  		fib_entry->rif = r->rif;
>  		return 0;
>  	}
> +
>  	fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
>  	return mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fi);
>  }

[...]

> +static int mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
> +				    struct fib_entry_notifier_info *fen_info)
>  {
> -	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
> -	struct mlxsw_sp_router_fib4_add_info *info;
>  	struct mlxsw_sp_fib_entry *fib_entry;
>  	struct mlxsw_sp_vr *vr;
>  	int err;
>  
> -	info = switchdev_trans_item_dequeue(trans);
> -	fib_entry = info->fib_entry;
> -	kfree(info);
> +	if (mlxsw_sp->router.aborted)
> +		return 0;
> +
> +	fib_entry = mlxsw_sp_fib_entry_get(mlxsw_sp, fen_info);
> +	if (IS_ERR(fib_entry)) {
> +		dev_warn(mlxsw_sp->bus_info->dev, "Failed to get FIB4 entry being added.\n");
> +		return PTR_ERR(fib_entry);
> +	}
>  
>  	if (fib_entry->ref_count != 1)
> -		return 0;
> +		goto skip_add;
>  
>  	vr = fib_entry->vr;
>  	err = mlxsw_sp_fib_entry_insert(vr->fib, fib_entry);
> -	if (err)
> +	if (err) {
> +		dev_warn(mlxsw_sp->bus_info->dev, "Failed to insert FIB4 entry being added.\n");
>  		goto err_fib_entry_insert;
> -	err = mlxsw_sp_fib_entry_update(mlxsw_sp_port->mlxsw_sp, fib_entry);
> +	}
> +	err = mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
>  	if (err)
>  		goto err_fib_entry_add;
> +
> +skip_add:
> +	fib_info_offload_inc(fen_info->fi);

This is called for every FIB that is added on the system. Even those
going via management ports, so all the routes are marked as offloaded.
Tested to make sure I'm not talking nonsense ^^

$ ip r s
default via 10.209.0.1 dev eno1
10.209.0.0/23 dev eno1  proto kernel  scope link  src 10.209.1.6
169.254.0.0/16 dev eno1  scope link  metric 1002

$ sudo ip r a 1.1.1.0/24 dev eno1
$ ip r s
default via 10.209.0.1 dev eno1
1.1.1.0/24 dev eno1  scope link offload
10.209.0.0/23 dev eno1  proto kernel  scope link  src 10.209.1.6
169.254.0.0/16 dev eno1  scope link  metric 1002

I think we should only call fib_info_offload_inc() in
mlxsw_sp_router_fib4_entry_init() if fib_entry->type !=
MLXSW_SP_FIB_ENTRY_TRAP. It'll also solve another problem (see below).

>  	return 0;
>  
>  err_fib_entry_add:
> @@ -1899,29 +1814,22 @@ err_fib_entry_insert:
>  	return err;
>  }

[...]

> +static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
> +{
> +	struct mlxsw_resources *resources;
> +	struct mlxsw_sp_fib_entry *fib_entry;
> +	struct mlxsw_sp_fib_entry *tmp;
> +	struct mlxsw_sp_vr *vr;
> +	int i;
> +	int err;
> +
> +	resources = mlxsw_core_resources_get(mlxsw_sp->core);
> +	for (i = 0; i < resources->max_virtual_routers; i++) {
> +		vr = &mlxsw_sp->router.vrs[i];
> +		if (!vr->used)
> +			continue;
> +
> +		list_for_each_entry_safe(fib_entry, tmp,
> +					 &vr->fib->entry_list, list) {
> +			bool do_break = &tmp->list == &vr->fib->entry_list;
> +
> +			fib_info_offload_dec(fib_entry->fi);

We call fib_info_offload_inc() multiple times for an already existing
FIB entry, but in abort we only call fib_info_offload_dec() once per
entry.

If we inc / dec in fib4_entry_init/fini, then this counter is called
once per entry (upon creation / destruction).

> +			mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
> +			mlxsw_sp_fib_entry_remove(fib_entry->vr->fib,
> +						  fib_entry);
> +			mlxsw_sp_fib_entry_put_all(mlxsw_sp, fib_entry);
> +			if (do_break)
> +				break;
> +		}
> +	}
> +	mlxsw_sp->router.aborted = true;
> +	err = mlxsw_sp_router_set_abort_trap(mlxsw_sp);
> +	if (err)
> +		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set abort trap.\n");
> +}

Besides that the patch looks really good to me.

Thanks!
