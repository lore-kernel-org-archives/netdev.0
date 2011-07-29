From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 12:42:14 -0400
Message-ID: <20110729164214.GI23194@fieldses.org>
References: <1311876249.2346.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311876249.2346.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 28, 2011 at 08:04:09PM +0200, Eric Dumazet wrote:
> Use NUMA aware allocations to reduce latencies and increase throughput.
> 
> sunrpc kthreads can use kthread_create_on_node() if pool_mode is
> "percpu" or "pernode", and svc_prepare_thread()/svc_init_buffer() can
> also take into account NUMA node affinity for memory allocations.
...
> @@ -662,14 +675,16 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
>  		nrservs--;
>  		chosen_pool = choose_pool(serv, pool, &state);
>  
> -		rqstp = svc_prepare_thread(serv, chosen_pool);
> +		node = svc_pool_map_get_node(chosen_pool->sp_id);
> +		rqstp = svc_prepare_thread(serv, chosen_pool, node);

The only correct value for the third argument there is
svc_pool_map_get_node(chosen_pool->sp_id), so let's have
svc_prepare_thread() call that itself.

Seems OK otherwise.

Any suggestions on how we should test this?

--b.

>  		if (IS_ERR(rqstp)) {
>  			error = PTR_ERR(rqstp);
>  			break;
>  		}
>  
>  		__module_get(serv->sv_module);
> -		task = kthread_create(serv->sv_function, rqstp, serv->sv_name);
> +		task = kthread_create_on_node(serv->sv_function, rqstp,
> +					      node, serv->sv_name);
>  		if (IS_ERR(task)) {
>  			error = PTR_ERR(task);
>  			module_put(serv->sv_module);
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
