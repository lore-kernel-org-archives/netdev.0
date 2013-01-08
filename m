From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] sunrpc: verbs: Avoid 1kb stack
Date: Tue, 8 Jan 2013 09:46:04 -0500
Message-ID: <20130108144604.GB16343@fieldses.org>
References: <1357587696.21481.48.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>, steved-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Tom Talpey <ttalpey-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1357587696.21481.48.camel@joe-AO722>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 07, 2013 at 11:41:36AM -0800, Joe Perches wrote:
> 16 * 64 is a bit much.
> Use kmalloc_array instead.

I thought there was some reason we didn't do this.

Grepping up through the callers....  It looks like the result is
xprt_rdma_send_request returns -EIO, and as far as I can tell that gets
passed up to the application on the client.   That doesn't sound right.

--b.

> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> ---
>  net/sunrpc/xprtrdma/verbs.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 745973b..9cfebb4 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1736,8 +1736,13 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>  				  IB_ACCESS_REMOTE_READ);
>  	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
>  	int len, i, rc = 0;
> +	struct ib_phys_buf *ipb = kmalloc_array(RPCRDMA_MAX_DATA_SEGS,
> +						sizeof(*ipb),
> +						GFP_KERNEL);
> +
> +	if (!ipb)
> +		return -ENOMEM;
>  
>  	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>  		*nsegs = RPCRDMA_MAX_DATA_SEGS;
> @@ -1770,6 +1775,9 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  		seg1->mr_len = len;
>  	}
>  	*nsegs = i;
> +
> +	kfree(ipb);
> +
>  	return rc;
>  }
>  
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
