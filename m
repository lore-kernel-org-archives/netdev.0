From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v6 4/8] SUNRPC: setup rpcbind clients if service
 requires it
Date: Thu, 27 Oct 2011 17:27:32 -0400
Message-ID: <20111027212732.GC31669@fieldses.org>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
 <20111025101705.12689.68022.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111025101705.12689.68022.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 02:17:08PM +0300, Stanislav Kinsbursky wrote:
> New function ("svc_uses_rpcbind") will be used to detect, that new service will
> send portmapper register calls. For such services we will create rpcbind
> clients and remove all stale portmap registrations.
> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for such services
> in case of this field wasn't initialized earlier. This will allow to destroy
> rpcbind clients when no other users of them left.
> 
> Note: Currently, any creating service will be detected as portmap user.
> Probably, this is wrong. But now it depends on program versions "vs_hidden"
> flag.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> ---
>  net/sunrpc/svc.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index d2d61bf..918edc3 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -454,8 +454,15 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>  		spin_lock_init(&pool->sp_lock);
>  	}
>  
> -	/* Remove any stale portmap registrations */
> -	svc_unregister(serv);
> +	if (svc_uses_rpcbind(serv)) {
> +	       	if (svc_rpcb_setup(serv) < 0) {
> +			kfree(serv->sv_pools);
> +			kfree(serv);
> +			return NULL;

Nit: could we convert this (and the previous failure to allocate
sv_pools) to the usual pattern of collecting the cleanup at the end and
jumping to it with a goto?

Looks fine otherwise.

--b.

> +		}
> +		if (!serv->sv_shutdown)
> +			serv->sv_shutdown = svc_rpcb_cleanup;
> +	}
>  
>  	return serv;
>  }
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
