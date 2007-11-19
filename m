From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [PATCH][net-2.6.25][NETNS] make netns cleanup to run in a
 separate workqueue
Date: Mon, 19 Nov 2007 14:05:23 +0300
Message-ID: <47416DF3.700@sw.ru>
References: <47416909.4000602@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47416909.4000602-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

imho panic() is too much.
create_singlethread_workqueue() can fail e.g. due to out of memory...

Thanks,
Kirill


Daniel Lezcano wrote:
> Subject: make netns cleanup to run in a separate queue
> From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
> 
> This patch adds a separate workqueue for cleaning up a network 
> namespace. If we use the keventd workqueue to execute cleanup_net(), 
> there is a problem to unregister devices in IPv6. Indeed the code 
> that cleans up also schedule work in keventd: as long as cleanup_net() 
> hasn't return, dst_gc_task() cannot run and as long as dst_gc_task() has
> not run, there are still some references pending on the net devices and
> cleanup_net() can not unregister and exit the keventd workqueue.
> 
> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
> Acked-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  net/core/net_namespace.c |    9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> Index: net-2.6.25/net/core/net_namespace.c
> ===================================================================
> --- net-2.6.25.orig/net/core/net_namespace.c
> +++ net-2.6.25/net/core/net_namespace.c
> @@ -58,6 +58,7 @@ out_undo:
>  
>  #ifdef CONFIG_NET_NS
>  static struct kmem_cache *net_cachep;
> +static struct workqueue_struct *netns_wq;
>  
>  static struct net *net_alloc(void)
>  {
> @@ -149,7 +150,7 @@ void __put_net(struct net *net)
>  {
>  	/* Cleanup the network namespace in process context */
>  	INIT_WORK(&net->work, cleanup_net);
> -	schedule_work(&net->work);
> +	queue_work(netns_wq, &net->work);
>  }
>  EXPORT_SYMBOL_GPL(__put_net);
>  
> @@ -171,7 +172,13 @@ static int __init net_ns_init(void)
>  	net_cachep = kmem_cache_create("net_namespace", sizeof(struct net),
>  					SMP_CACHE_BYTES,
>  					SLAB_PANIC, NULL);
> +
> +	/* Create workqueue for cleanup */
> +	netns_wq = create_singlethread_workqueue("netns");
> +	if (!netns_wq)
> +		panic("Could not create netns workq");

>  #endif
> +
>  	mutex_lock(&net_mutex);
>  	err = setup_net(&init_net);
>  
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
