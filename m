From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 6/6] rtnetlink: rtnl_have_link_slave_info
 doesn't need rtnl
Date: Sat, 23 Sep 2017 11:17:37 -0600
Message-ID: <80ca6187-4a08-d65d-fe16-27dcf7c55e4c@gmail.com>
References: <20170922061008.14723-1-fw@strlen.de>
 <20170922061008.14723-7-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36671 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdIWRRj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 13:17:39 -0400
Received: by mail-pf0-f196.google.com with SMTP id f84so1798648pfj.3
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 10:17:38 -0700 (PDT)
In-Reply-To: <20170922061008.14723-7-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/17 12:10 AM, Florian Westphal wrote:
> Switch it to rcu.
> 
> rtnl_link_slave_info_fill on to other hand does need rtnl mutex for now so
> add an annotation to its caller as a reminder.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Change since v1:
>   - don't add ASSERT_RTNL to rtnl_link_slave_info_fill and
>   rtnl_link_info_fill they are only called via rtnl_link_fill.
> 
>  net/core/rtnetlink.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 590823f70cc3..e6f9e36d9d5a 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -522,11 +522,15 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev,
>  static bool rtnl_have_link_slave_info(const struct net_device *dev)
>  {
>  	struct net_device *master_dev;
> +	bool ret = false;
>  
> -	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
> +	rcu_read_lock();
> +
> +	master_dev = netdev_master_upper_dev_get_rcu((struct net_device *)dev);
>  	if (master_dev && master_dev->rtnl_link_ops)
> -		return true;
> -	return false;
> +		ret = true;
> +	rcu_read_unlock();
> +	return ret;
>  }
>  
>  static int rtnl_link_slave_info_fill(struct sk_buff *skb,
> @@ -598,6 +602,8 @@ static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
>  	struct nlattr *linkinfo;
>  	int err = -EMSGSIZE;
>  
> +	ASSERT_RTNL();

Rather than sprinkling the ASSERT_RTNL why not just add a comment above
the function which is done in many places. Since this is really meant as
your notes as you remove rtnl usage a comment serves the same purpose.

> +
>  	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
>  	if (linkinfo == NULL)
>  		goto out;
> 


Reviewed-by: David Ahern <dsahern@gmail.com>
