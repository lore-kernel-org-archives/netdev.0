From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 5/6] rtnetlink: add helpers to dump vf and
 netnsid information
Date: Sat, 23 Sep 2017 11:12:08 -0600
Message-ID: <fdc1459e-9d68-7262-bc62-f7b198d45c6f@gmail.com>
References: <20170922061008.14723-1-fw@strlen.de>
 <20170922061008.14723-6-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33372 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdIWRMK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 13:12:10 -0400
Received: by mail-pf0-f193.google.com with SMTP id h4so1805379pfk.0
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 10:12:10 -0700 (PDT)
In-Reply-To: <20170922061008.14723-6-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/17 12:10 AM, Florian Westphal wrote:
> +static noinline_for_stack int rtnl_fill_vf(struct sk_buff *skb,
> +					   struct net_device *dev,
> +					   u32 ext_filter_mask)
> +{
> +	struct nlattr *vfinfo;
> +	int i, num_vfs;
> +
> +	if (!dev->dev.parent || ((ext_filter_mask & RTEXT_FILTER_VF) == 0))
> +		return 0;
> +
> +	num_vfs = dev_num_vf(dev->dev.parent);
> +	if (nla_put_u32(skb, IFLA_NUM_VF, num_vfs))
> +		return -EMSGSIZE;
> +
> +	if (!dev->netdev_ops->ndo_get_vf_config)
> +		return 0;
> +
> +	vfinfo = nla_nest_start(skb, IFLA_VFINFO_LIST);
> +	if (!vfinfo)
> +		return -EMSGSIZE;
> +
> +	for (i = 0; i < num_vfs; i++) {
> +		if (rtnl_fill_vfinfo(skb, dev, i, vfinfo))
> +			return -EMSGSIZE;
> +	}
> +
> +	nla_nest_end(skb, vfinfo);
> +	return 0;
> +}
> +
>  static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct rtnl_link_ifmap map;
> @@ -1355,6 +1385,23 @@ static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
>  	return 0;
>  }
>  
> +static noinline int rtnl_fill_link_netnsid(struct sk_buff *skb,
> +					   const struct net_device *dev)
> +{
> +	if (dev->rtnl_link_ops && dev->rtnl_link_ops->get_link_net) {
> +		struct net *link_net = dev->rtnl_link_ops->get_link_net(dev);
> +
> +		if (!net_eq(dev_net(dev), link_net)) {
> +			int id = peernet2id_alloc(dev_net(dev), link_net);
> +
> +			if (nla_put_s32(skb, IFLA_LINK_NETNSID, id))
> +				return -EMSGSIZE;
> +		}
> +	}
> +
> +	return 0;
> +}
> +

No reason to combine vf and netnsid into 1 patch; completely separate topics


>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			    int type, u32 pid, u32 seq, u32 change,
>  			    unsigned int flags, u32 ext_filter_mask,
> @@ -1428,27 +1475,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  	if (rtnl_fill_stats(skb, dev))
>  		goto nla_put_failure;
>  
> -	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF) &&
> -	    nla_put_u32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent)))
> +	if (rtnl_fill_vf(skb, dev, ext_filter_mask))
>  		goto nla_put_failure;
>  
> -	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent &&
> -	    ext_filter_mask & RTEXT_FILTER_VF) {
> -		int i;
> -		struct nlattr *vfinfo;
> -		int num_vfs = dev_num_vf(dev->dev.parent);
> -
> -		vfinfo = nla_nest_start(skb, IFLA_VFINFO_LIST);
> -		if (!vfinfo)
> -			goto nla_put_failure;
> -		for (i = 0; i < num_vfs; i++) {
> -			if (rtnl_fill_vfinfo(skb, dev, i, vfinfo))
> -				goto nla_put_failure;
> -		}
> -
> -		nla_nest_end(skb, vfinfo);
> -	}
> -
>  	if (rtnl_port_fill(skb, dev, ext_filter_mask))
>  		goto nla_put_failure;
>  
> @@ -1460,17 +1489,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			goto nla_put_failure;
>  	}
>  
> -	if (dev->rtnl_link_ops &&
> -	    dev->rtnl_link_ops->get_link_net) {
> -		struct net *link_net = dev->rtnl_link_ops->get_link_net(dev);
> -
> -		if (!net_eq(dev_net(dev), link_net)) {
> -			int id = peernet2id_alloc(dev_net(dev), link_net);
> -
> -			if (nla_put_s32(skb, IFLA_LINK_NETNSID, id))
> -				goto nla_put_failure;
> -		}
> -	}
> +	if (rtnl_fill_link_netnsid(skb, dev))
> +		goto nla_put_failure;
>  
>  	if (!(af_spec = nla_nest_start(skb, IFLA_AF_SPEC)))
>  		goto nla_put_failure;
> 

Reviewed-by: David Ahern <dsahern@gmail.com>
