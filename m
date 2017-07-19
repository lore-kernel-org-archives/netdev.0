From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 14/17] mlxsw: spectrum_router: Add support for
 IPv6 routes addition / deletion
Date: Wed, 19 Jul 2017 10:14:54 -0600
Message-ID: <983f0254-9539-213d-f140-63b542d8f23e@gmail.com>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-15-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        kafai@fb.com, hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33096 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753856AbdGSQO6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 12:14:58 -0400
Received: by mail-pg0-f67.google.com with SMTP id z1so421409pgs.0
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 09:14:58 -0700 (PDT)
In-Reply-To: <20170719070232.28457-15-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 1:02 AM, Jiri Pirko wrote:
> @@ -2094,6 +2106,40 @@ mlxsw_sp_fib_entry_should_offload(const struct mlxsw_sp_fib_entry *fib_entry)
>  	}
>  }
>  
> +static void
> +mlxsw_sp_fib6_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
> +{
> +	struct mlxsw_sp_fib6_entry *fib6_entry;
> +	struct mlxsw_sp_rt6 *mlxsw_sp_rt6;
> +
> +	fib6_entry = container_of(fib_entry, struct mlxsw_sp_fib6_entry,
> +				  common);
> +	list_for_each_entry(mlxsw_sp_rt6, &fib6_entry->rt6_list, list) {
> +		struct rt6_info *rt = mlxsw_sp_rt6->rt;
> +
> +		write_lock_bh(&rt->rt6i_table->tb6_lock);
> +		rt->rt6i_flags |= RTF_OFFLOAD;
> +		write_unlock_bh(&rt->rt6i_table->tb6_lock);

Seems wrong. A device driver should not be taking FIB table locks.


> +	}
> +}
> +
> +static void
> +mlxsw_sp_fib6_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
> +{
> +	struct mlxsw_sp_fib6_entry *fib6_entry;
> +	struct mlxsw_sp_rt6 *mlxsw_sp_rt6;
> +
> +	fib6_entry = container_of(fib_entry, struct mlxsw_sp_fib6_entry,
> +				  common);
> +	list_for_each_entry(mlxsw_sp_rt6, &fib6_entry->rt6_list, list) {
> +		struct rt6_info *rt = mlxsw_sp_rt6->rt;
> +
> +		write_lock_bh(&rt->rt6i_table->tb6_lock);
> +		rt->rt6i_flags &= ~RTF_OFFLOAD;
> +		write_unlock_bh(&rt->rt6i_table->tb6_lock);

same here.




> +static int mlxsw_sp_nexthop6_init(struct mlxsw_sp *mlxsw_sp,
> +				  struct mlxsw_sp_nexthop_group *nh_grp,
> +				  struct mlxsw_sp_nexthop *nh,
> +				  const struct rt6_info *rt)
> +{
> +	struct net_device *dev = rt->dst.dev;
> +	struct mlxsw_sp_rif *rif;
> +	int err;
> +
> +	nh->nh_grp = nh_grp;
> +	memcpy(&nh->gw_addr, &rt->rt6i_gateway, sizeof(nh->gw_addr));
> +
> +	if (!dev)
> +		return 0;
> +
> +	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
> +	if (!rif)
> +		return 0;

rif == 0 means the dst device is not related to a port owned by this
driver?


A lot to process so I am sure I missed the answer to these:

1. How do you handle host routes for local addresses? IPv6 inserts the
host and anycast routes with the device set to 'lo' (or VRF device)
instead of the device with the address. I have a patch to change this,
but needs more testing

2. How are routes with devices unrelated to ports owned by this driver
handled?
