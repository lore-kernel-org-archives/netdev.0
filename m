From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RESEND 1/2] neigh: only allow init_net to change the default neigh_parms
Date: Wed, 12 Jun 2013 00:33:54 -0700
Message-ID: <87ehc7rdel.fsf@xmission.com>
References: <1371012275-31735-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39885 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab3FLHeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 03:34:24 -0400
In-Reply-To: <1371012275-31735-1-git-send-email-gaofeng@cn.fujitsu.com> (Gao
	feng's message of "Wed, 12 Jun 2013 12:44:34 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gao feng <gaofeng@cn.fujitsu.com> writes:

> Though we don't export the /proc/sys/net/ipv[4,6]/neigh/default/
> directory to the un-init_net, but we can still use cmd such as
> "ip ntable change name arp_cache locktime 129" to change the locktime
> of default neigh_parms.
>
> This patch disallows the un-init_net to find out the neigh_table.parms.
> So the un-init_net will failed to influence the init_net.

Interesting...  

The problem these two patches seek to address seems legit.

However I disagree with the way you are handling this.

Outside of the initial network namespace we should return -ENOENT
instead of -EPERM.  Which would match how we handle sysctls, and I think
missing neigh table values.  Just not making these global values visible
seems wise.

The alternative is to use the proper permission test which is
capable(CAP_SYS_ADMIN) (instead of testing network namespaces) and
return -EPERM if that fails.  Which would allow processes in other
network namespaces to change the value if they could otherwise change
the value.

Namespaces are about visibility and there is no need to make an
exception here.

Eric

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
