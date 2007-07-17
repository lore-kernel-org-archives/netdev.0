From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 1/3] netlink: allocate group bitmaps dynamically
Date: Tue, 17 Jul 2007 17:45:53 +0200
Message-ID: <469CE431.9070705@trash.net>
References: <20070717122706.899784000@sipsolutions.net> <20070717123642.918587000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47408 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935026AbXGQPqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 11:46:00 -0400
In-Reply-To: <20070717123642.918587000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Allow changing the number of groups for a netlink family
> after it has been created, use RCU to protect the listeners
> bitmap keeping netlink_has_listeners() lock-free.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> ---
>  include/linux/netlink.h  |    1 
>  net/netlink/af_netlink.c |   86 +++++++++++++++++++++++++++++++++++------------
>  2 files changed, 66 insertions(+), 21 deletions(-)
> 
> --- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-17 14:05:30.210964463 +0200
> +++ wireless-dev/net/netlink/af_netlink.c	2007-07-17 14:05:30.720964463 +0200
> -static int netlink_alloc_groups(struct sock *sk)
> +static int netlink_realloc_groups(struct sock *sk)
>  {
>  	struct netlink_sock *nlk = nlk_sk(sk);
>  	unsigned int groups;
> +	unsigned long *new_groups;
>  	int err = 0;
>  
>  	netlink_lock_table();


This is actually a bug in the current code I think, netlink_lock_table
is a reader lock.

>  	groups = nl_table[sk->sk_protocol].groups;
>  	if (!nl_table[sk->sk_protocol].registered)
>  		err = -ENOENT;
> -	netlink_unlock_table();
>  
>  	if (err)
> -		return err;
> +		goto out_unlock;
>  
> -	nlk->groups = kzalloc(NLGRPSZ(groups), GFP_KERNEL);
> -	if (nlk->groups == NULL)
> -		return -ENOMEM;
> +	if (nlk->ngroups >= groups)
> +		goto out_unlock;
> +
> +	new_groups = krealloc(nlk->groups, NLGRPSZ(groups), GFP_KERNEL);
> +	if (new_groups == NULL) {
> +		err = -ENOMEM;
> +		goto out_unlock;
> +	}
> +	memset((char*)new_groups + NLGRPSZ(nlk->ngroups), 0,
> +	       NLGRPSZ(groups) - NLGRPSZ(nlk->ngroups));
> +
> +	nlk->groups = new_groups;
>  	nlk->ngroups = groups;
> -	return 0;
> + out_unlock:
> +	netlink_unlock_table();
> +	return err;
>  }


> +int netlink_change_ngroups(int unit, unsigned int groups)


I think it would be more consistent to pass the kernel socket
instead of the unit.

> +{
> +	unsigned long *listeners, old = NULL;
> +	int err = 0;
> +
> +	netlink_table_grab();
> +	if (NLGRPSZ(nl_table[unit].groups) < NLGRPSZ(groups)) {
> +		listeners = kzalloc(NLGRPSZ(groups), GFP_ATOMIC);
> +		if (!listeners) {
> +			err = -ENOMEM;
> +			goto out_ungrab;
> +		}
> +		old = nl_table[unit].listeners;
> +		memcpy(listeners, old, NLGRPSZ(nl_table[unit].groups));
> +		rcu_assign_pointer(nl_table[unit].listeners, listeners);
> +	}
> +	nl_table[unit].groups = groups;


This might set the group to a value < 32. I don't expect it matters,
but when I changed to old code to support > 32 groups I enforced
a minimum of 32 so anything outside the kernel multicasting on them
would still work (even though its a really stupid idea). So for
consistency this should probably also use a minimum of 32.

