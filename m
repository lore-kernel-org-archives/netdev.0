From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH linux-next v2] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
Date: Mon, 11 Mar 2013 14:14:50 -0400
Message-ID: <20130311181450.GC30618@fieldses.org>
References: <20130310202838.GL31448@fieldses.org>
 <1363023447-22453-1-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shani Michaeli <shanim-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1363023447-22453-1-git-send-email-tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 11, 2013 at 11:37:27AM -0600, Tim Gardner wrote:
> rpcrdma_register_default_external() is several frames into the call stack which
> goes deeper yet. You run the risk of stack corruption by declaring such a large
> automatic variable, so move the array of 'struct ib_phys_buf' objects into the
> requestor structure 'struct rpcrdma_req' (which is dynamically allocated) in
> order to silence the frame-larger-than warning.
> 
> net/sunrpc/xprtrdma/verbs.c: In function 'rpcrdma_register_default_external':
> net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
> gcc version 4.6.3
> 
> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>
> Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Cc: Shani Michaeli <shanim-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
> 
> v1 - Use kmalloc() to dynamically allocate and free the array of 'struct
> ib_phys_buf' objects
> 
> v2 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_req
> and pass this request down through rpcrdma_register_external() and
> rpcrdma_register_default_external(). This is less overhead then using
> kmalloc() and requires no extra error checking as the allocation burden is
> shifted to the transport client.

Oh good--so that works, and the req is the right place to put this?  How
are you testing this?

(Just want to make it clear: I'm *not* an expert on the rdma code, so my
suggestion to put this in the rpcrdma_req was a suggestion for something
to look into, not a claim that it's correct.)

--b.

> 
>  net/sunrpc/xprtrdma/rpc_rdma.c  |    2 +-
>  net/sunrpc/xprtrdma/verbs.c     |   11 ++++++-----
>  net/sunrpc/xprtrdma/xprt_rdma.h |    3 ++-
>  3 files changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index e03725b..c89448b 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -203,7 +203,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
>  
>  	do {
>  		/* bind/register the memory, then build chunk from result. */
> -		int n = rpcrdma_register_external(seg, nsegs,
> +		int n = rpcrdma_register_external(req, seg, nsegs,
>  						cur_wchunk != NULL, r_xprt);
>  		if (n <= 0)
>  			goto out;
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 93726560..5b439ed 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1730,13 +1730,14 @@ rpcrdma_deregister_memwin_external(struct rpcrdma_mr_seg *seg,
>  }
>  
>  static int
> -rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
> -			int *nsegs, int writing, struct rpcrdma_ia *ia)
> +rpcrdma_register_default_external(struct rpcrdma_req *req,
> +			struct rpcrdma_mr_seg *seg, int *nsegs, int writing,
> +			struct rpcrdma_ia *ia)
>  {
>  	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>  				  IB_ACCESS_REMOTE_READ);
>  	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
> +	struct ib_phys_buf *ipb = req->rl_ipb;
>  	int len, i, rc = 0;
>  
>  	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
> @@ -1791,7 +1792,7 @@ rpcrdma_deregister_default_external(struct rpcrdma_mr_seg *seg,
>  }
>  
>  int
> -rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
> +rpcrdma_register_external(struct rpcrdma_req *req, struct rpcrdma_mr_seg *seg,
>  			int nsegs, int writing, struct rpcrdma_xprt *r_xprt)
>  {
>  	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
> @@ -1827,7 +1828,7 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
>  
>  	/* Default registration each time */
>  	default:
> -		rc = rpcrdma_register_default_external(seg, &nsegs, writing, ia);
> +		rc = rpcrdma_register_default_external(req, seg, &nsegs, writing, ia);
>  		break;
>  	}
>  	if (rc)
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index cc1445d..b10ed34 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -192,6 +192,7 @@ struct rpcrdma_req {
>  	struct ib_sge	rl_send_iov[4];	/* for active requests */
>  	struct ib_sge	rl_iov;		/* for posting */
>  	struct ib_mr	*rl_handle;	/* handle for mem in rl_iov */
> +	struct ib_phys_buf rl_ipb[RPCRDMA_MAX_DATA_SEGS]; /* temp work array */
>  	char		rl_base[MAX_RPCRDMAHDR]; /* start of actual buffer */
>  	__u32 		rl_xdr_buf[0];	/* start of returned rpc rq_buffer */
>  };
> @@ -327,7 +328,7 @@ int rpcrdma_register_internal(struct rpcrdma_ia *, void *, int,
>  int rpcrdma_deregister_internal(struct rpcrdma_ia *,
>  				struct ib_mr *, struct ib_sge *);
>  
> -int rpcrdma_register_external(struct rpcrdma_mr_seg *,
> +int rpcrdma_register_external(struct rpcrdma_req *, struct rpcrdma_mr_seg *,
>  				int, int, struct rpcrdma_xprt *);
>  int rpcrdma_deregister_external(struct rpcrdma_mr_seg *,
>  				struct rpcrdma_xprt *, void *);
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
