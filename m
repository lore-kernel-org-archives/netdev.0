From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH net] netlink: Properly unbind in error conditions.
Date: Wed, 12 Nov 2014 14:44:54 -0500
Message-ID: <20141112194454.GC28076@madcap2.tricolour.ca>
References: <20141113042410.013c5d044aa442a05832d6d9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353AbaKLTpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2014 14:45:00 -0500
Content-Disposition: inline
In-Reply-To: <20141113042410.013c5d044aa442a05832d6d9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/11/13, Hiroaki SHIMODA wrote:
> Even if netlink_kernel_cfg::unbind is implemented the unbind() method is
> not called, because cfg->unbind is omitted in __netlink_kernel_create().
> And fix wrong argument of test_bit() and off by one problem.
> 
> At this point, no unbind() method is implemented, so there is no real
> issue.
> 
> Fixes: 4f520900522f ("netlink: have netlink per-protocol bind function return an error code.")
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Cc: Richard Guy Briggs <rgb@redhat.com>
> ---
>  net/netlink/af_netlink.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index f1de72de273e..0007b8180397 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1440,7 +1440,7 @@ static void netlink_unbind(int group, long unsigned int groups,
>  		return;
>  
>  	for (undo = 0; undo < group; undo++)
> -		if (test_bit(group, &groups))
> +		if (test_bit(undo, &groups))

Nice find!  (Cut-and-waste from line 1480...)

>  			nlk->netlink_unbind(undo);
>  }
>  
> @@ -1492,7 +1492,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
>  			netlink_insert(sk, net, nladdr->nl_pid) :
>  			netlink_autobind(sock);
>  		if (err) {
> -			netlink_unbind(nlk->ngroups - 1, groups, nlk);
> +			netlink_unbind(nlk->ngroups, groups, nlk);

Yup, agreed.

>  			return err;
>  		}
>  	}
> @@ -2509,6 +2509,7 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
>  		nl_table[unit].module = module;
>  		if (cfg) {
>  			nl_table[unit].bind = cfg->bind;
> +			nl_table[unit].unbind = cfg->unbind;

Yup, thanks.

>  			nl_table[unit].flags = cfg->flags;
>  			if (cfg->compare)
>  				nl_table[unit].compare = cfg->compare;

Acked-by: Richard Guy Briggs <rgb@redhat.com>

> -- 
> 2.0.4
> 

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
