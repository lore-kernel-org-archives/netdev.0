From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net namespace: wrap for_each_net with rtnl_lock
Date: Thu, 04 Jul 2013 00:04:27 -0700
Message-ID: <87txkaolfo.fsf@xmission.com>
References: <1372918855-3815-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <serge.hallyn@canonical.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39660 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148Ab3GDHFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 03:05:09 -0400
In-Reply-To: <1372918855-3815-1-git-send-email-fan.du@windriver.com> (Fan Du's
	message of "Thu, 4 Jul 2013 14:20:55 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fan Du <fan.du@windriver.com> writes:

> The read access to net_namespace_list with for_each_net should always
> be protected with rtnl_lock agiast any adding/removing operation from
> the list.

That is not correct.  The rtnl_lock does not protect the
net_namespace_list.  The net_mutex provides that protection.

Modifications to the net_namespace_list are under both the rtnl_lock
and the net_mutex which removes the need of grabbing the net_mutex when
you just need to traverse the list of network namespaces.  This avoids a
lock ordering problem as most places it is desirable to traverse the
net namespace list the rtnl_lock is already held.

In general the init methods will deadlock if you call them with the 
rtnl_lock held, as they grab the rtnl_lock when creating network devices
etc.

The methods you change are protected by the net_mutex so I don't see any
problems here.

Was this patch inspired by code review or was there an actual problem
that inspired it?

> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/core/net_namespace.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index f976520..f3808ff 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -445,12 +445,14 @@ static int __register_pernet_operations(struct list_head *list,
>  
>  	list_add_tail(&ops->list, list);
>  	if (ops->init || (ops->id && ops->size)) {
> +		rtnl_lock();
>  		for_each_net(net) {
>  			error = ops_init(ops, net);
>  			if (error)
>  				goto out_undo;
>  			list_add_tail(&net->exit_list, &net_exit_list);
>  		}
> +		rtnl_unlock();
>  	}
>  	return 0;
>  
> @@ -468,8 +470,10 @@ static void __unregister_pernet_operations(struct pernet_operations *ops)
>  	LIST_HEAD(net_exit_list);
>  
>  	list_del(&ops->list);
> +	rtnl_lock();
>  	for_each_net(net)
>  		list_add_tail(&net->exit_list, &net_exit_list);
> +	rtnl_unlock();
>  	ops_exit_list(ops, &net_exit_list);
>  	ops_free_list(ops, &net_exit_list);
>  }
