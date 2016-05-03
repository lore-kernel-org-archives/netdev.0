From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 3/9] netfilter: conntrack: don't attempt to
 iterate over empty table
Date: Tue, 3 May 2016 19:03:57 +0200
Message-ID: <20160503170357.GA21641@salvia>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <1461863628-23350-4-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461863628-23350-4-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 07:13:42PM +0200, Florian Westphal wrote:
> Once we place all conntracks into same table iteration becomes more
> costly because the table contains conntracks that we are not interested
> in (belonging to other netns).
> 
> So don't bother scanning if the current namespace has no entries.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/netfilter/nf_conntrack_core.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 29fa08b..f2e75a5 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1428,6 +1428,9 @@ void nf_ct_iterate_cleanup(struct net *net,
>  
>  	might_sleep();
>  
> +	if (atomic_read(&net->ct.count) == 0)
> +		return;

This optimization gets defeated with just one single conntrack (ie.
net->ct.count == 1), so I wonder if this is practical thing.

At the cost of consuming more memory per conntrack, we may consider
adding a per-net list so this iteration doesn't become a problem.

>  	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
>  		/* Time to push up daises... */
>  		if (del_timer(&ct->timeout))
> -- 
> 2.7.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
