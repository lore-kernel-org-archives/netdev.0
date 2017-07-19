From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 14/17] mlxsw: spectrum_router: Add support for
 IPv6 routes addition / deletion
Date: Wed, 19 Jul 2017 19:30:52 +0300
Message-ID: <20170719163052.GB10775@splinter>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-15-jiri@resnulli.us>
 <983f0254-9539-213d-f140-63b542d8f23e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0060.outbound.protection.outlook.com ([104.47.0.60]:6519
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932446AbdGSQbC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 12:31:02 -0400
Content-Disposition: inline
In-Reply-To: <983f0254-9539-213d-f140-63b542d8f23e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 10:14:54AM -0600, David Ahern wrote:
> On 7/19/17 1:02 AM, Jiri Pirko wrote:
> > @@ -2094,6 +2106,40 @@ mlxsw_sp_fib_entry_should_offload(const struct mlxsw_sp_fib_entry *fib_entry)
> >  	}
> >  }
> >  
> > +static void
> > +mlxsw_sp_fib6_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
> > +{
> > +	struct mlxsw_sp_fib6_entry *fib6_entry;
> > +	struct mlxsw_sp_rt6 *mlxsw_sp_rt6;
> > +
> > +	fib6_entry = container_of(fib_entry, struct mlxsw_sp_fib6_entry,
> > +				  common);
> > +	list_for_each_entry(mlxsw_sp_rt6, &fib6_entry->rt6_list, list) {
> > +		struct rt6_info *rt = mlxsw_sp_rt6->rt;
> > +
> > +		write_lock_bh(&rt->rt6i_table->tb6_lock);
> > +		rt->rt6i_flags |= RTF_OFFLOAD;
> > +		write_unlock_bh(&rt->rt6i_table->tb6_lock);
> 
> Seems wrong. A device driver should not be taking FIB table locks.

Will remove this in v2.

[...]

> > +static int mlxsw_sp_nexthop6_init(struct mlxsw_sp *mlxsw_sp,
> > +				  struct mlxsw_sp_nexthop_group *nh_grp,
> > +				  struct mlxsw_sp_nexthop *nh,
> > +				  const struct rt6_info *rt)
> > +{
> > +	struct net_device *dev = rt->dst.dev;
> > +	struct mlxsw_sp_rif *rif;
> > +	int err;
> > +
> > +	nh->nh_grp = nh_grp;
> > +	memcpy(&nh->gw_addr, &rt->rt6i_gateway, sizeof(nh->gw_addr));
> > +
> > +	if (!dev)
> > +		return 0;
> > +
> > +	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
> > +	if (!rif)
> > +		return 0;
> 
> rif == 0 means the dst device is not related to a port owned by this
> driver?

Yes.

> 
> 
> A lot to process so I am sure I missed the answer to these:
> 
> 1. How do you handle host routes for local addresses? IPv6 inserts the
> host and anycast routes with the device set to 'lo' (or VRF device)
> instead of the device with the address. I have a patch to change this,
> but needs more testing

In mlxsw_sp_fib6_entry_type_set() we check for RTF_LOCAL and set the
FIB entry type to MLXSW_SP_FIB_ENTRY_TYPE_TRAP. Packets hitting these
routes will be trapped with IP2ME trap ID towards the CPU.

> 2. How are routes with devices unrelated to ports owned by this driver
> handled?

They are handled just like any other route, but they don't have a valid
RIF (for directly connected routes) or an adjacency group (for
gatewayed routes), so the check in mlxsw_sp_fib_entry_should_offload()
will return false and they will be programmed to the device with trap
action, but using a trap ID (RTR_INGRESS0) with a lower traffic class
than IP2ME, so packets that actually need to be locally received by the
CPU have a better QoS.
