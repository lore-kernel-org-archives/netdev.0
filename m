From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: do not leak net_generic data on failed init
Date: Tue, 17 Apr 2012 21:01:28 -0700
Message-ID: <m1wr5d3cyv.fsf@fess.ebiederm.org>
References: <1334587395-6033-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46806 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab2DRD5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 23:57:32 -0400
In-Reply-To: <1334587395-6033-1-git-send-email-ja@ssi.bg> (Julian Anastasov's
	message of "Mon, 16 Apr 2012 17:43:15 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> writes:

> 	ops_init should free the net_generic data on
> init failure and __register_pernet_operations should not
> call ops_free when NET_NS is not enabled.

The subject is good.

There is most definitely a leak with us not freeing the net_generic data
on ops_init failure.  Having ops_init just take care of it seems like
the logical place as it makes for simple analysis.

The bit about __register_pernet_operations should not call ops_free when
NET_NS is not enabled is a bad comment.  We just need to move the
ops_free into ops_init on failure, which is what your patch does.

Without your patch the only caller of ops_init that doesn't leak today
is __register_pernet_operations in !CONFIG_NET_NS, precisely because
it does that ops_free.

Now all of that said I have just read through everything and
patch cleanly fixes a rare but real memory leak, and leaves
the code in better state then it is today.

David please apply this patch.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/core/net_namespace.c |   33 ++++++++++++++++++---------------
>  1 files changed, 18 insertions(+), 15 deletions(-)
>
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 0e950fd..31a5ae5 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -83,21 +83,29 @@ assign:
>  
>  static int ops_init(const struct pernet_operations *ops, struct net *net)
>  {
> -	int err;
> +	int err = -ENOMEM;
> +	void *data = NULL;
> +
>  	if (ops->id && ops->size) {
> -		void *data = kzalloc(ops->size, GFP_KERNEL);
> +		data = kzalloc(ops->size, GFP_KERNEL);
>  		if (!data)
> -			return -ENOMEM;
> +			goto out;
>  
>  		err = net_assign_generic(net, *ops->id, data);
> -		if (err) {
> -			kfree(data);
> -			return err;
> -		}
> +		if (err)
> +			goto cleanup;
>  	}
> +	err = 0;
>  	if (ops->init)
> -		return ops->init(net);
> -	return 0;
> +		err = ops->init(net);
> +	if (!err)
> +		return 0;
> +
> +cleanup:
> +	kfree(data);
> +
> +out:
> +	return err;
>  }
>  
>  static void ops_free(const struct pernet_operations *ops, struct net *net)
> @@ -448,12 +456,7 @@ static void __unregister_pernet_operations(struct pernet_operations *ops)
>  static int __register_pernet_operations(struct list_head *list,
>  					struct pernet_operations *ops)
>  {
> -	int err = 0;
> -	err = ops_init(ops, &init_net);
> -	if (err)
> -		ops_free(ops, &init_net);
> -	return err;
> -	
> +	return ops_init(ops, &init_net);
>  }
>  
>  static void __unregister_pernet_operations(struct pernet_operations *ops)
