From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v6 2/3] net: core: add SW stats to if_stats_msg
Date: Tue, 09 Aug 2016 23:08:41 -0700
Message-ID: <57AAC4E9.4010407@cumulusnetworks.com>
References: <1470777912-2227-1-git-send-email-jiri@resnulli.us> <1470777912-2227-3-git-send-email-jiri@resnulli.us>
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
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35133 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935327AbcHJTN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:13:29 -0400
Received: by mail-pf0-f177.google.com with SMTP id x72so18641131pfd.2
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 12:13:18 -0700 (PDT)
In-Reply-To: <1470777912-2227-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/9/16, 2:25 PM, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
>
> Add a nested attribute of SW stats to if_stats_msg
> under IFLA_STATS_LINK_SW_64.
>
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/uapi/linux/if_link.h |  1 +
>  net/core/rtnetlink.c         | 21 +++++++++++++++++++++
>  2 files changed, 22 insertions(+)
>
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index a1b5202..1c9b808 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -825,6 +825,7 @@ enum {
>  	IFLA_STATS_LINK_64,
>  	IFLA_STATS_LINK_XSTATS,
>  	IFLA_STATS_LINK_XSTATS_SLAVE,
> +	IFLA_STATS_LINK_SW_64,

sorry, don't mean to drag this discussion forever...but...

IIRC on the switchdev call, I thought we had agreed to just put these kind of breakdown
stats in one more layer of nesting.. which can be extended for everybody.

IFLA_STATS_LINK_DRIVER_XSTATS   (or some other name) [
                IFLA_STATS_LINK_SW_64  (struct rtnl_link_stats64)    <---- you get the well defined struct here as you wanted.
                IFLA_STATS_LINK_HW_ACL_DROPS  /* u64 */        <----- we can keep extending this for other stats people want.

                /* just keeps it extensible */
]

because in addition to all other reasons I have mentioned before, technically IFLA_STATS_LINK_64 (top-level aggregate stats)
are also software only stats for say most logical devices etc.


and instead of adding one ndo for your software only stats now and then again for other ethtool
like hw stats from all drivers, it could also be like the below:

new ndo_get_hw_stats

IFLA_STATS_LINK_HW_XSTATS   (or some other name) [
                IFLA_STATS_LINK_CPU_64  (struct rtnl_link_stats64)    <---- you get the well defined struct here as you wanted.
                IFLA_STATS_LINK_HW_ACL_DROPS  /* u64 */              <----- we can keep extending this for other stats people want.
                /* just keeps it extensible */
]

It gets you what you want and keeps the api extensible IMO. your call.

>  	__IFLA_STATS_MAX,
>  };
>  
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 189cc78..910f802 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -3583,6 +3583,21 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
>  		dev_get_stats(dev, sp);
>  	}
>  
> +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64, *idxattr)) {
> +		if (dev_have_sw_stats(dev)) {
> +			struct rtnl_link_stats64 *sp;
> +
> +			attr = nla_reserve_64bit(skb, IFLA_STATS_LINK_SW_64,
> +						 sizeof(struct rtnl_link_stats64),
> +						 IFLA_STATS_UNSPEC);
> +			if (!attr)
> +				goto nla_put_failure;
> +
> +			sp = nla_data(attr);
> +			dev_get_sw_stats(dev, sp);
> +		}
> +	}
> +
>  	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, *idxattr)) {
>  		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
>  
> @@ -3644,6 +3659,7 @@ nla_put_failure:
>  
>  static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
>  	[IFLA_STATS_LINK_64]	= { .len = sizeof(struct rtnl_link_stats64) },
> +	[IFLA_STATS_LINK_SW_64] = { .len = sizeof(struct rtnl_link_stats64) },
>  };
>  
>  static size_t if_nlmsg_stats_size(const struct net_device *dev,
> @@ -3685,6 +3701,11 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
>  		}
>  	}
>  
> +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64, 0)) {
> +		if (dev_have_sw_stats(dev))
> +			size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
> +	}
> +
>  	return size;
>  }
>  
