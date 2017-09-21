From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 5/7] rtnetlink: add helper to dump vf information
Date: Thu, 21 Sep 2017 11:17:47 -0600
Message-ID: <bdc39ebf-e934-16ce-0834-e0795774a656@gmail.com>
References: <20170921165902.10746-1-fw@strlen.de>
 <20170921165902.10746-6-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35458 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751782AbdIURRq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:17:46 -0400
Received: by mail-pg0-f67.google.com with SMTP id j16so3758281pga.2
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 10:17:46 -0700 (PDT)
In-Reply-To: <20170921165902.10746-6-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/17 10:59 AM, Florian Westphal wrote:
> similar to earlier patches, split out more parts of this function to
> better see what is happening and where we assume rtnl is locked.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/core/rtnetlink.c | 80 ++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 50 insertions(+), 30 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 1af3ef7f329d..7503021fe308 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1211,6 +1211,36 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
>  	return -EMSGSIZE;
>  }
>  
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
> @@ -1355,6 +1385,23 @@ static int noinline nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
>  	return 0;
>  }
>  
> +static int noinline rtnl_fill_link_netnsid(struct sk_buff *skb,
> +				  const struct net_device *dev)
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
>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,

Similarly for this patch -- subject references vf helper yet the code
changes flips netnsid as well.
