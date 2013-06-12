From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] neigh: only allow init_net to change the default
 neigh_parms
Date: Wed, 12 Jun 2013 12:38:34 +0800
Message-ID: <51B7FB4A.1030704@cn.fujitsu.com>
References: <1371011651-30894-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ebiederm@xmission.com, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:24867 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750968Ab3FLEgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 00:36:55 -0400
In-Reply-To: <1371011651-30894-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 12:34 PM, Gao feng wrote:
> From: Gao feng <gaofeng@Donkey.lan>

Sorry, please ignore these two patches, I need to resend them.

> 
> Though we don't export the /proc/sys/net/ipv[4,6]/neigh/default/
> directory to the un-init_net, but we can still use cmd such as
> "ip ntable change name arp_cache locktime 129" to change the locktime
> of default neigh_parms.
> 
> This patch disallows the un-init_net to find out the neigh_table.parms.
> So the un-init_net will failed to influence the init_net.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/core/neighbour.c | 25 ++++++++++++++-----------
>  1 file changed, 14 insertions(+), 11 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 5c56b21..e4027ff 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1418,26 +1418,29 @@ static inline struct neigh_parms *lookup_neigh_parms(struct neigh_table *tbl,
>  	struct neigh_parms *p;
>  
>  	for (p = &tbl->parms; p; p = p->next) {
> -		if ((p->dev && p->dev->ifindex == ifindex && net_eq(neigh_parms_net(p), net)) ||
> -		    (!p->dev && !ifindex))
> +		if (p->dev && p->dev->ifindex == ifindex &&
> +		    net_eq(neigh_parms_net(p), net))
>  			return p;
> +
> +		if (!p->dev && !ifindex) {
> +			if (net_eq(net, &init_net))
> +				return p;
> +			else
> +				return ERR_PTR(-EPERM);
> +		}
>  	}
>  
> -	return NULL;
> +	return ERR_PTR(-ENOENT);
>  }
>  
>  struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
>  				      struct neigh_table *tbl)
>  {
> -	struct neigh_parms *p, *ref;
> +	struct neigh_parms *p;
>  	struct net *net = dev_net(dev);
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  
> -	ref = lookup_neigh_parms(tbl, net, 0);
> -	if (!ref)
> -		return NULL;
> -
> -	p = kmemdup(ref, sizeof(*p), GFP_KERNEL);
> +	p = kmemdup(&tbl->parms, sizeof(*p), GFP_KERNEL);
>  	if (p) {
>  		p->tbl		  = tbl;
>  		atomic_set(&p->refcnt, 1);
> @@ -1999,8 +2002,8 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
>  			ifindex = nla_get_u32(tbp[NDTPA_IFINDEX]);
>  
>  		p = lookup_neigh_parms(tbl, net, ifindex);
> -		if (p == NULL) {
> -			err = -ENOENT;
> +		if (IS_ERR(p)) {
> +			err = PTR_ERR(p);
>  			goto errout_tbl_lock;
>  		}
>  
> 
