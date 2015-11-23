From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v4] mpls: support for dead routes
Date: Mon, 23 Nov 2015 14:15:50 +0000
Message-ID: <56531F96.2030704@brocade.com>
References: <1448082968-63882-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:8237 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754118AbbKWOQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 09:16:06 -0500
In-Reply-To: <1448082968-63882-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/11/15 05:16, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
> routes due to link events. Also adds code to ignore dead
> routes during route selection.
>
> Unlike ip routes, mpls routes are not deleted when the route goes
> dead. This is current mpls behaviour and this patch does not change
> that. With this patch however, routes will be marked dead.
> dead routes are not notified to userspace (this is consistent with ipv4
> routes).
>
...
> v3 - v4:
>          - removed per route rt_flags and derive it from the nh_flags during dumps
>          - use kmemdup to make a copy of the route during route updates
>            due to link events

Looks much better. Thanks for making those changes Roopa.

I've just a couple of minor comments on this new version.

> +static inline int mpls_route_alloc_size(int num_nh, u8 max_alen_aligned)

I think the standard practice is to not put inline on functions declared 
in .c files, but instead to just let the compiler use its best judgement 
as to whether it's worth inlining or not.

> +{
> +	struct mpls_route *rt;
> +
> +	return (ALIGN(sizeof(*rt) + num_nh * sizeof(*rt->rt_nh),
> +		      VIA_ALEN_ALIGN) + num_nh * max_alen_aligned);
> +}
> +

> -static void mpls_ifdown(struct net_device *dev)
> +static inline bool mpls_route_dev_exists(struct mpls_route *rt,

Ditto.

> +					 struct net_device *dev)
> +{
> +	for_nexthops(rt) {
> +		if (rtnl_dereference(nh->nh_dev) != dev)
> +			continue;
> +		return true;
> +	} endfor_nexthops(rt);
> +
> +	return false;
> +}
> +
> +static void mpls_ifdown(struct net_device *dev, int event)
>   {
>   	struct mpls_route __rcu **platform_label;
>   	struct net *net = dev_net(dev);
> -	struct mpls_dev *mdev;
> +	struct mpls_route *rt_new;
>   	unsigned index;
>
>   	platform_label = rtnl_dereference(net->mpls.platform_label);
>   	for (index = 0; index < net->mpls.platform_labels; index++) {
>   		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
> +
>   		if (!rt)
>   			continue;
> -		for_nexthops(rt) {
> +
> +		if (!mpls_route_dev_exists(rt, dev))
> +			continue;
> +
> +		rt_new = kmemdup(rt, mpls_route_alloc_size(rt->rt_nhn,
> +							   rt->rt_max_alen),
> +							   GFP_KERNEL);

Shouldn't the above line be indented level with the opening bracket of 
kmemdup?

> +		if (!rt_new) {
> +			pr_warn("mpls_ifdown: kmemdup failed\n");

It isn't safe to leave the current route untouched if the net device is 
being deleted, since a nexthop will be left holding a stale pointer to 
it. Perhaps delete the route entirely in that case?

> +			return;
> +		}
> +
> +		for_nexthops(rt_new) {

Since the nexthop is being changed, this should be change_nexthops. I 
know this was a problem in the existing code you are changing in this 
patch, if it isn't too much trouble it would be good to fix this whilst 
reindenting it.

>   			if (rtnl_dereference(nh->nh_dev) != dev)
>   				continue;
> -			nh->nh_dev = NULL;
> -		} endfor_nexthops(rt);
> +			switch (event) {
> +			case NETDEV_DOWN:
> +			case NETDEV_UNREGISTER:
> +				nh->nh_flags |= RTNH_F_DEAD;
> +				/* fall through */
> +			case NETDEV_CHANGE:
> +				nh->nh_flags |= RTNH_F_LINKDOWN;
> +				rt_new->rt_nhn_alive--;
> +				break;
> +			}
> +			if (event == NETDEV_UNREGISTER)
> +				RCU_INIT_POINTER(nh->nh_dev, NULL);
> +		} endfor_nexthops(rt_new);
> +
> +		mpls_route_update(net, index, rt_new, NULL, false);
>   	}
>
> -	mdev = mpls_dev_get(dev);
> -	if (!mdev)
> -		return;
> +	return;
> +}
> +
> +static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
> +{
> +	struct mpls_route __rcu **platform_label;
> +	struct net *net = dev_net(dev);
> +	struct mpls_route *rt_new;
> +	unsigned index;
> +	int alive;
> +
> +	platform_label = rtnl_dereference(net->mpls.platform_label);
> +	for (index = 0; index < net->mpls.platform_labels; index++) {
> +		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
> +
> +		if (!rt)
> +			continue;
> +
> +		if (!mpls_route_dev_exists(rt, dev))
> +			continue;
>
> -	mpls_dev_sysctl_unregister(mdev);
> +		rt_new = kmemdup(rt, mpls_route_alloc_size(rt->rt_nhn,
> +							   rt->rt_max_alen),
> +							   GFP_KERNEL);
> +		if (!rt_new) {
> +			pr_warn("mpls_ifdown: kmemdup failed\n");
> +			return;
> +		}
>
> -	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
> +		alive = 0;
> +		for_nexthops(rt_new) {

Ditto, this should also be change_nexthops.

> +			struct net_device *nh_dev =
> +				rtnl_dereference(nh->nh_dev);
>
> -	kfree_rcu(mdev, rcu);
> +			if (!(nh->nh_flags & nh_flags)) {
> +				alive++;
> +				continue;
> +			}
> +			if (nh_dev != dev)
> +				continue;
> +			alive++;
> +			nh->nh_flags &= ~nh_flags;
> +		} endfor_nexthops(rt_new);
> +
> +		rt_new->rt_nhn_alive = alive;
> +		mpls_route_update(net, index, rt_new, NULL, false);
> +	}
> +
> +	return;
>   }
