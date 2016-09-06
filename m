From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v7 2/3] net: core: Add offload stats to if_stats_msg
Date: Tue, 06 Sep 2016 08:20:12 -0700
Message-ID: <57CEDEAC.1040806@cumulusnetworks.com>
References: <1473095937-27100-1-git-send-email-jiri@resnulli.us> <1473095937-27100-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35271 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932180AbcIFPUO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 11:20:14 -0400
Received: by mail-pf0-f169.google.com with SMTP id w87so17460927pfk.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 08:20:13 -0700 (PDT)
In-Reply-To: <1473095937-27100-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/16, 10:18 AM, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
>
> Add a nested attribute of offload stats to if_stats_msg
> named IFLA_STATS_LINK_OFFLOAD_XSTATS.
> Under it, add SW stats, meaning stats only per packets that went via
> slowpath to the cpu, named IFLA_OFFLOAD_XSTATS_CPU_HIT.
>
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/uapi/linux/if_link.h | 10 +++++
>  net/core/rtnetlink.c         | 88 ++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 94 insertions(+), 4 deletions(-)
>
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 9bf3aec..4aaa2a1 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -826,6 +826,7 @@ enum {
>  	IFLA_STATS_LINK_64,
>  	IFLA_STATS_LINK_XSTATS,
>  	IFLA_STATS_LINK_XSTATS_SLAVE,
> +	IFLA_STATS_LINK_OFFLOAD_XSTATS,
>  	__IFLA_STATS_MAX,
>  };
>  
> @@ -845,6 +846,15 @@ enum {
>  };
>  #define LINK_XSTATS_TYPE_MAX (__LINK_XSTATS_TYPE_MAX - 1)
>  
> +/* These are stats embedded into IFLA_STATS_LINK_OFFLOAD_XSTATS */
> +enum {
> +	IFLA_OFFLOAD_XSTATS_UNSPEC,
> +	IFLA_OFFLOAD_XSTATS_CPU_HIT, /* struct rtnl_link_stats64 */
> +	__IFLA_OFFLOAD_XSTATS_MAX
> +};
> +#define IFLA_OFFLOAD_XSTATS_MAX (__IFLA_OFFLOAD_XSTATS_MAX - 1)
> +#define IFLA_OFFLOAD_XSTATS_FIRST (IFLA_OFFLOAD_XSTATS_UNSPEC + 1)

not sure why we need a first in the uapi.
> +
>  /* XDP section */
>  
>  enum {
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 1dfca1c..95eb131 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -3577,6 +3577,74 @@ static bool stats_attr_valid(unsigned int mask, int attrid, int idxattr)
>  	       (!idxattr || idxattr == attrid);
>  }
>  
> +static int rtnl_get_offload_stats_attr_size(int attr_id)
> +{
> +	switch (attr_id) {
> +	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
> +		return sizeof(struct rtnl_link_stats64);
> +	}
> +
> +	return 0;
> +}
> +
> +static int rtnl_get_offload_stats(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct nlattr *attr;
> +	int attr_id, size;
> +	void *attr_data;
> +	int err;
> +
> +	if (!(dev->netdev_ops && dev->netdev_ops->ndo_has_offload_stats &&
> +	      dev->netdev_ops->ndo_get_offload_stats))
> +		return 0;
> +
> +	for (attr_id = IFLA_OFFLOAD_XSTATS_FIRST;
> +	     attr_id <= IFLA_OFFLOAD_XSTATS_MAX; attr_id++) {
> +		size = rtnl_get_offload_stats_attr_size(attr_id);
> +		if (!size)
> +			continue;
> +
> +		if (!dev->netdev_ops->ndo_has_offload_stats(attr_id))
> +			continue;
> +
> +		attr = nla_reserve_64bit(skb, attr_id, size,
> +					 IFLA_OFFLOAD_XSTATS_UNSPEC);
> +		if (!attr)
> +			return -EMSGSIZE;

you need this 64bit alignment padding only for the specific nested attribute
your driver is adding ?. The code seems to add it unconditionally for every attribute.
But, I am guessing future attribute authors will need to adjust this somehow.

> +
> +		attr_data = nla_data(attr);
> +		memset(attr_data, 0, size);
> +		err = dev->netdev_ops->ndo_get_offload_stats(attr_id, dev,
> +							     attr_data);
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}
> +
> +static int rtnl_get_offload_stats_size(const struct net_device *dev)
> +{
> +	int size = 0;
> +	int attr_id;
> +
> +	if (!(dev->netdev_ops && dev->netdev_ops->ndo_has_offload_stats &&
> +	      dev->netdev_ops->ndo_get_offload_stats))
> +		return nla_total_size(0);
> +
> +	for (attr_id = IFLA_OFFLOAD_XSTATS_FIRST;
> +	     attr_id <= IFLA_OFFLOAD_XSTATS_MAX; attr_id++) {
> +		if (!dev->netdev_ops->ndo_has_offload_stats(attr_id))
> +			continue;
> +
> +		size += rtnl_get_offload_stats_attr_size(attr_id);
> +	}
> +
> +	size += nla_total_size(0);
> +
> +	return size;
> +}
> +
>  static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
>  			       int type, u32 pid, u32 seq, u32 change,
>  			       unsigned int flags, unsigned int filter_mask,
> @@ -3586,6 +3654,7 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
>  	struct nlmsghdr *nlh;
>  	struct nlattr *attr;
>  	int s_prividx = *prividx;
> +	int err;
>  
>  	ASSERT_RTNL();
>  
> @@ -3614,8 +3683,6 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
>  		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
>  
>  		if (ops && ops->fill_linkxstats) {
> -			int err;
> -
>  			*idxattr = IFLA_STATS_LINK_XSTATS;
>  			attr = nla_nest_start(skb,
>  					      IFLA_STATS_LINK_XSTATS);
> @@ -3639,8 +3706,6 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
>  		if (master)
>  			ops = master->rtnl_link_ops;
>  		if (ops && ops->fill_linkxstats) {
> -			int err;
> -
>  			*idxattr = IFLA_STATS_LINK_XSTATS_SLAVE;
>  			attr = nla_nest_start(skb,
>  					      IFLA_STATS_LINK_XSTATS_SLAVE);
> @@ -3655,6 +3720,18 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
>  		}
>  	}
>  
> +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS,
> +			     *idxattr)) {
> +		attr = nla_nest_start(skb, IFLA_STATS_LINK_OFFLOAD_XSTATS);
> +		if (!attr)
> +			goto nla_put_failure;
> +
> +		err = rtnl_get_offload_stats(skb, dev);
> +		nla_nest_end(skb, attr);

seems like this can result in an empty nested attribute. better thing would be to
cancel the nest if size from rtnl_get_offload_stats is zero ?

> +		if (err)
> +			goto nla_put_failure;
> +	}
> +
>  	nlmsg_end(skb, nlh);
>  
>  	return 0;
> @@ -3712,6 +3789,9 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
>  		}
>  	}
>  
> +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS, 0))
> +		size += rtnl_get_offload_stats_size(dev);
> +
>  	return size;
>  }
>  
