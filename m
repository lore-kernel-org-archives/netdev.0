From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v3 2/4] rtnetlink: add HW/SW stats distinction
 in rtnl_fill_stats
Date: Fri, 13 May 2016 10:20:18 -0700
Message-ID: <1463160018.23934.203.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463151257-3972-1-git-send-email-jiri@resnulli.us>
	 <1463151257-3972-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
	gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
	eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
	hannes@stressinduktion.org, f.fainelli@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:32820 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbcEMRUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:20:21 -0400
Received: by mail-pa0-f67.google.com with SMTP id gh9so8951487pac.0
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 10:20:20 -0700 (PDT)
In-Reply-To: <1463151257-3972-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-13 at 16:54 +0200, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
> 
> Since hardware stats are now returned by default, add a way to
> query only software stats.
> They are saved in IFLA_SW_STATS64.
> (This option is valid only if the driver return HW stats in the
> default ndo stats)
> 
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v2->v3:
> - avoided memcpy as requerted by DaveM
> v1->v2:
> - no change
> ---
>  include/uapi/linux/if_link.h |  1 +
>  net/core/rtnetlink.c         | 13 +++++++++++++
>  2 files changed, 14 insertions(+)
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index bb36bd5..98175e7 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -156,6 +156,7 @@ enum {
>  	IFLA_GSO_MAX_SEGS,
>  	IFLA_GSO_MAX_SIZE,
>  	IFLA_PAD,
> +	IFLA_SW_STATS64,
>  	__IFLA_MAX
>  };
>  
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index d69c464..b0ebac6 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1054,12 +1054,25 @@ static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
>  
>  	attr = nla_reserve_64bit(skb, IFLA_STATS64,
>  				 sizeof(struct rtnl_link_stats64), IFLA_PAD);
> +
>  	if (!attr)
>  		return -EMSGSIZE;
>  
>  	sp = nla_data(attr);
>  	dev_get_stats(dev, sp);
>  
> +	if (dev_have_sw_stats(dev)) {
> +		attr = nla_reserve_64bit(skb, IFLA_SW_STATS64,
> +					 sizeof(struct rtnl_link_stats64),
> +					 IFLA_PAD);
> +
> +		if (!attr)
> +			return -EMSGSIZE;
> +
> +		sp = nla_data(attr);
> +		dev_get_sw_stats(dev, sp);
> +	}
> +
>  	attr = nla_reserve(skb, IFLA_STATS,
>  			   sizeof(struct rtnl_link_stats));
>  	if (!attr)


You forgot to change if_nlmsg_size() ?

nla_total_size_64bit(sizeof(struct rtnl_link_stats64)) is quite big.
