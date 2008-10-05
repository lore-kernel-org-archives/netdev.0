From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Sun, 5 Oct 2008 08:55:10 +0200
Message-ID: <20081005065509.GA2538@ami.dom.local>
References: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>, davem@davemloft.net,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:45317 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbYJEGyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 02:54:52 -0400
Received: by nf-out-0910.google.com with SMTP id d3so855412nfc.21
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2008 23:54:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote, On 10/05/2008 06:26 AM:
...
> The problem is really quite silly.  We were trying to create
> parallelism where none was required.  As netdev_run_todo always
> follows a RTNL section, and that todo tasks can only be added
> with the RTNL held, by definition you should only need to wait
> for the very ones that you've added and be done with it.
> 
> There is no need for a second mutex or spinlock.

Is it for sure? (Read below.)

> 
> This is exactly what the following patch does.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e8eb2b4..021f531 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3808,14 +3808,11 @@ static int dev_new_index(struct net *net)
>  }
>  
>  /* Delayed registration/unregisteration */
> -static DEFINE_SPINLOCK(net_todo_list_lock);
>  static LIST_HEAD(net_todo_list);
>  
>  static void net_set_todo(struct net_device *dev)
>  {
> -	spin_lock(&net_todo_list_lock);
>  	list_add_tail(&dev->todo_list, &net_todo_list);
> -	spin_unlock(&net_todo_list_lock);
>  }
>  
>  static void rollback_registered(struct net_device *dev)
> @@ -4142,33 +4139,24 @@ static void netdev_wait_allrefs(struct net_device *dev)
>   *	free_netdev(y1);
>   *	free_netdev(y2);
>   *
> - * We are invoked by rtnl_unlock() after it drops the semaphore.
> + * We are invoked by rtnl_unlock().
>   * This allows us to deal with problems:
>   * 1) We can delete sysfs objects which invoke hotplug
>   *    without deadlocking with linkwatch via keventd.
>   * 2) Since we run with the RTNL semaphore not held, we can sleep
>   *    safely in order to wait for the netdev refcnt to drop to zero.
> + *
> + * We must not return until all unregister events added during
> + * the interval the lock was held have been completed.
>   */
> -static DEFINE_MUTEX(net_todo_run_mutex);
>  void netdev_run_todo(void)
>  {
>  	struct list_head list;
>  
> -	/* Need to guard against multiple cpu's getting out of order. */
> -	mutex_lock(&net_todo_run_mutex);
> -
> -	/* Not safe to do outside the semaphore.  We must not return
> -	 * until all unregister events invoked by the local processor
> -	 * have been completed (either by this todo run, or one on
> -	 * another cpu).
> -	 */

I think, it's about not to let others run this for devices unregistered
within later rtnl_locks before completing previous tasks. So, it would
be nice to have some comment why it's not necessary anymore.

Cheers,
Jarek P.

> -	if (list_empty(&net_todo_list))
> -		goto out;
> -
>  	/* Snapshot list, allow later requests */
> -	spin_lock(&net_todo_list_lock);
>  	list_replace_init(&net_todo_list, &list);
> -	spin_unlock(&net_todo_list_lock);
> +
> +	__rtnl_unlock();
>  
>  	while (!list_empty(&list)) {
>  		struct net_device *dev
> @@ -4200,9 +4188,6 @@ void netdev_run_todo(void)
>  		/* Free network device */
>  		kobject_put(&dev->dev.kobj);
>  	}
> -
> -out:
> -	mutex_unlock(&net_todo_run_mutex);
>  }
>  
>  static struct net_device_stats *internal_stats(struct net_device *dev)
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 71edb8b..d6381c2 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -73,7 +73,7 @@ void __rtnl_unlock(void)
>  
>  void rtnl_unlock(void)
>  {
> -	mutex_unlock(&rtnl_mutex);
> +	/* This fellow will unlock it for us. */
>  	netdev_run_todo();
>  }
>  
> Cheers,





