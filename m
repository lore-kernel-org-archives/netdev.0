From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v6 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Tue, 25 Oct 2011 13:16:09 +0200
Message-ID: <1319541369.2716.1.camel@lade.trondhjem.org>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
	 <20111025101608.12689.68689.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111025101608.12689.68689.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-10-25 at 14:16 +0300, Stanislav Kinsbursky wrote: 
> v6:
> 1) added write memory barrier to rpcb_set_local to make sure, that rpcbind
> clients become valid before rpcb_users assignment
> 2) explicitly set rpcb_users to 1 instead of incrementing it (looks clearer from
> my pow).
> 
> v5: fixed races with rpcb_users in rpcb_get_local()
> 
> This helpers will be used for dynamical creation and destruction of rpcbind
> clients.
> Variable rpcb_users is actually a counter of lauched RPC services. If rpcbind
> clients has been created already, then we just increase rpcb_users.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> ---
>  net/sunrpc/rpcb_clnt.c |   54 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 54 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index e45d2fb..9fcdb42 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>  static struct rpc_clnt *	rpcb_local_clnt;
>  static struct rpc_clnt *	rpcb_local_clnt4;
>  
> +DEFINE_SPINLOCK(rpcb_clnt_lock);
> +unsigned int			rpcb_users;
> +
>  struct rpcbind_args {
>  	struct rpc_xprt *	r_xprt;
>  
> @@ -161,6 +164,57 @@ static void rpcb_map_release(void *data)
>  	kfree(map);
>  }
>  
> +static int rpcb_get_local(void)
> +{
> +	int cnt;
> +
> +	spin_lock(&rpcb_clnt_lock);
> +	if (rpcb_users)
> +		rpcb_users++;
> +	cnt = rpcb_users;
> +	spin_unlock(&rpcb_clnt_lock);
> +
> +	return cnt;
> +}
> +
> +void rpcb_put_local(void)
> +{
> +	struct rpc_clnt *clnt = rpcb_local_clnt;
> +	struct rpc_clnt *clnt4 = rpcb_local_clnt4;
> +	int shutdown;
> +
> +	spin_lock(&rpcb_clnt_lock);
> +	if (--rpcb_users == 0) {
> +		rpcb_local_clnt = NULL;
> +		rpcb_local_clnt4 = NULL;
> +	}
> +	shutdown = !rpcb_users;
> +	spin_unlock(&rpcb_clnt_lock);
> +
> +	if (shutdown) {
> +		/*
> +		 * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
> +		 */
> +		if (clnt4)
> +			rpc_shutdown_client(clnt4);
> +		if (clnt)
> +			rpc_shutdown_client(clnt);
> +	}
> +	return;

I'm removing this before applying...

> +}
> +

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
