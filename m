From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v7 5/7] SUNRPC: cleanup service destruction
Date: Fri, 28 Oct 2011 10:22:50 -0400
Message-ID: <20111028142250.GD5193@fieldses.org>
References: <20111028104530.24628.23631.stgit@localhost6.localdomain6>
 <20111028105326.24628.81582.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111028105326.24628.81582.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2011 at 02:53:43PM +0300, Stanislav Kinsbursky wrote:
> svc_unregister() call have to be removed from svc_destroy() since it will be
> called in sv_shutdown callback.
> This also means, that we have to call svc_rpcb_cleanup() explicitly from
> nfsd_last_thread() since this function is registered as service shutdown
> callback and thus nobody else will done it for us.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Acked-by: J. Bruce Fields <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

> 
> ---
>  fs/nfsd/nfssvc.c           |    2 ++
>  include/linux/sunrpc/svc.h |    1 +
>  net/sunrpc/svc.c           |    4 ++--
>  3 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index dc5a1bf..52cd976 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -256,6 +256,8 @@ static void nfsd_last_thread(struct svc_serv *serv)
>  	nfsd_serv = NULL;
>  	nfsd_shutdown();
>  
> +	svc_rpcb_cleanup(serv);
> +
>  	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
>  			    "cache\n");
>  	nfsd_export_flush();
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 223588a..5e71a30 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -401,6 +401,7 @@ struct svc_procedure {
>  /*
>   * Function prototypes.
>   */
> +void svc_rpcb_cleanup(struct svc_serv *serv);
>  struct svc_serv *svc_create(struct svc_program *, unsigned int,
>  			    void (*shutdown)(struct svc_serv *));
>  struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 87a67b2..96df2ba 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -367,11 +367,12 @@ static int svc_rpcb_setup(struct svc_serv *serv)
>  	return 0;
>  }
>  
> -static void svc_rpcb_cleanup(struct svc_serv *serv)
> +void svc_rpcb_cleanup(struct svc_serv *serv)
>  {
>  	svc_unregister(serv);
>  	rpcb_put_local();
>  }
> +EXPORT_SYMBOL_GPL(svc_rpcb_cleanup);
>  
>  static int svc_uses_rpcbind(struct svc_serv *serv)
>  {
> @@ -531,7 +532,6 @@ svc_destroy(struct svc_serv *serv)
>  	if (svc_serv_is_pooled(serv))
>  		svc_pool_map_put();
>  
> -	svc_unregister(serv);
>  	kfree(serv->sv_pools);
>  	kfree(serv);
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
