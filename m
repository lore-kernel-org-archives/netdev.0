From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v6] mpls: support for dead routes
Date: Mon, 30 Nov 2015 23:02:27 +0000
Message-ID: <565CD583.8050507@brocade.com>
References: <1448768313-34809-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:49003 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754695AbbK3XCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 18:02:46 -0500
In-Reply-To: <1448768313-34809-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/11/15 03:38, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>   		}
>   	}
>
> -	nh_index = hash % rt->rt_nhn;
> +	return hash;
> +}
> +
> +static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
> +					     struct sk_buff *skb, bool bos)
> +{
> +	u32 hash = 0;
> +	int nh_index = 0;
> +	int n = 0;
> +
> +	/* No need to look further into packet if there's only
> +	 * one path
> +	 */
> +	if (rt->rt_nhn == 1)
> +		goto out;
> +
> +	if (rt->rt_nhn_alive <= 0)
> +		return NULL;
> +
> +	hash = mpls_multipath_hash(rt, skb, bos);
> +	nh_index = hash % rt->rt_nhn_alive;

There's a possibility that the compiler could generate multiple reads to 
rt_nhn_alive and thus see partial updates. If this happens, then we 
could end up accessing a nexthop pointer that is actually beyond the end 
of the nexthop array.

I don't think any form of memory barrier is necessary so I would 
therefore suggest fixing this by changing the line above to:

	nh_index = hash % ACCESS_ONCE(rt->rt_nhn_alive);

If we assume that it's OK to drop packets for a short time around the 
change, then the rt->rt_nhn_alive <= 0 check above is fine as is.

Similarly if we assume that it's OK for packets to go via nexthops they 
wouldn't normally do transiently then the rt->rt_nhn_alive == rt->rt_nhn 
check below is also fine as is.

However, it might look confusing to a casual observer, so perhaps we 
should consider stashing the alive nexthop count in a variable, still 
getting it using the ACCESS_ONCE macro?

> +	if (rt->rt_nhn_alive == rt->rt_nhn)
> +		goto out;
> +	for_nexthops(rt) {
> +		if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
> +			continue;
> +		if (n == nh_index)
> +			return nh;
> +		n++;
> +	} endfor_nexthops(rt);
> +
>   out:
>   	return &rt->rt_nh[nh_index];
>   }
...
>   	return ERR_PTR(err);
>   }
>
> -static void mpls_ifdown(struct net_device *dev)
> +static void mpls_ifdown(struct net_device *dev, int event)
>   {
>   	struct mpls_route __rcu **platform_label;
>   	struct net *net = dev_net(dev);
> -	struct mpls_dev *mdev;
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
> +		change_nexthops(rt) {
>   			if (rtnl_dereference(nh->nh_dev) != dev)
>   				continue;
> -			nh->nh_dev = NULL;
> +			switch (event) {
> +			case NETDEV_DOWN:
> +			case NETDEV_UNREGISTER:
> +				nh->nh_flags |= RTNH_F_DEAD;
> +				/* fall through */
> +			case NETDEV_CHANGE:
> +				nh->nh_flags |= RTNH_F_LINKDOWN;
> +				rt->rt_nhn_alive--;

For the similar reasons as above, to prevent mpls_select_multipath 
seeing partial updates I think this should be:

   ACCESS_ONCE(rt->rt_nhn_alive) = rt->rt_nhn_alive - 1;

Again, I don't think any memory barrier is required here, but I could be 
mistaken.

No special treatment of nh->nh_flags is required if we assume that it's 
OK transiently for packets to be dropped or go via a different nexthop 
than in steady state.

> +				break;
> +			}
> +			if (event == NETDEV_UNREGISTER)
> +				RCU_INIT_POINTER(nh->nh_dev, NULL);
>   		} endfor_nexthops(rt);
>   	}
>
> -	mdev = mpls_dev_get(dev);
> -	if (!mdev)
> -		return;
>
> -	mpls_dev_sysctl_unregister(mdev);
> +	return;
> +}
> +
> +static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
> +{
> +	struct mpls_route __rcu **platform_label;
> +	struct net *net = dev_net(dev);
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
> +		alive = 0;
> +		change_nexthops(rt) {
> +			struct net_device *nh_dev =
> +				rtnl_dereference(nh->nh_dev);
> +
> +			if (!(nh->nh_flags & nh_flags)) {
> +				alive++;
> +				continue;
> +			}
> +			if (nh_dev != dev)
> +				continue;
> +			alive++;
> +			nh->nh_flags &= ~nh_flags;
> +		} endfor_nexthops(rt);
>
> -	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
> +		rt->rt_nhn_alive = alive;

For the similar reasons as above, to prevent mpls_select_multipath 
seeing partial updates I think this should be:

		ACCESS_ONCE(rt->rt_nhn_alive) = alive;

Again, I don't think any memory barrier is required here, but I could be 
mistaken.

> +	}
>
> -	kfree_rcu(mdev, rcu);
> +	return;
>   }
>
>   static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
