From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next] net: core: Traverse the adjacency list from
 first entry
Date: Wed, 26 Oct 2016 18:52:01 +0300
Message-ID: <20161026155201.ooeuhfs4bxcbgkjp@splinter>
References: <1477463962-2802-1-git-send-email-idosch@idosch.org>
 <0ddd89b6-a9ec-29b5-2e0a-18d11fac5e4e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, mlxsw@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36945 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755631AbcJZPwE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 11:52:04 -0400
Content-Disposition: inline
In-Reply-To: <0ddd89b6-a9ec-29b5-2e0a-18d11fac5e4e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 09:05:35AM -0600, David Ahern wrote:
> On 10/26/16 12:39 AM, idosch@idosch.org wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > netdev_next_lower_dev() returns NULL when we finished traversing the
> > adjacency list ('iter' points to the list's head). Therefore, we must
> > start traversing the list from the first entry and not its head.
> > 
> > Fixes: 1a3f060c1a47 ("net: Introduce new api for walking upper and lower devices")
> > Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> > ---
> >  net/core/dev.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index f55fb45..d9c937f 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -5419,7 +5419,7 @@ int netdev_walk_all_lower_dev(struct net_device *dev,
> >  	struct list_head *iter;
> >  	int ret;
> >  
> > -	for (iter = &dev->adj_list.lower,
> > +	for (iter = dev->adj_list.lower.next,
> >  	     ldev = netdev_next_lower_dev(dev, &iter);
> >  	     ldev;
> >  	     ldev = netdev_next_lower_dev(dev, &iter)) {
> > 
> 
> How about this instead? It keeps the 3 walk functions in sync modulo the rcu reference:

I don't see any problem, so I guess it will work as well. I simply
preferred to use the same convention employed prior to your patchset.

Please submit yours formally, if you prefer.

> 
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f55fb4536016..6aa43cd8cbb5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5400,12 +5400,12 @@ static struct net_device *netdev_next_lower_dev(struct net_device *dev,
>  {
> 	struct netdev_adjacent *lower;
> 
> -	lower = list_entry(*iter, struct netdev_adjacent, list);
> +	lower = list_entry((*iter)->next, struct netdev_adjacent, list);
> 
>  	if (&lower->list == &dev->adj_list.lower)
>  		return NULL;
> 
> -	*iter = lower->list.next;
> +	*iter = &lower->list;
> 
>  	return lower->dev;
>  }
