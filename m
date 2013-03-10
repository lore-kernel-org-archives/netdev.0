From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH linux-next] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
Date: Sun, 10 Mar 2013 16:28:38 -0400
Message-ID: <20130310202838.GL31448@fieldses.org>
References: <1362929953-63785-1-git-send-email-tim.gardner@canonical.com>
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
In-Reply-To: <1362929953-63785-1-git-send-email-tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 10, 2013 at 09:39:13AM -0600, Tim Gardner wrote:
> rpcrdma_register_default_external() is several frames into
> the call stack which goes deeper yet. You run the risk of stack
> corruption by declaring such a large automatic variable,
> so dynamically allocate the array of 'struct ib_phys_buf' objects in
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
> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  net/sunrpc/xprtrdma/verbs.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 93726560..0916467 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1736,9 +1736,13 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>  				  IB_ACCESS_REMOTE_READ);
>  	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
> +	struct ib_phys_buf *ipb;
>  	int len, i, rc = 0;
>  
> +	ipb = kmalloc(sizeof(*ipb) * RPCRDMA_MAX_DATA_SEGS, GFP_KERNEL);

Have you checked that this occurs in a context where allocations are OK?
Checking very quickly through the callers I can't see any spinlocks or
anything, but I also don't see any other allocations.

Assuming this is just in rpciod context....  Trond's the authority, but
I think we generally try to avoid allocations here, or make them
GFP_NOFS if we must.

Would it be possible to allocate this array as part of the rpcrdma_req?

--b.

> +	if (!ipb)
> +		return -ENOMEM;
> +
>  	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>  		*nsegs = RPCRDMA_MAX_DATA_SEGS;
>  	for (len = 0, i = 0; i < *nsegs;) {
> @@ -1770,6 +1774,7 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  		seg1->mr_len = len;
>  	}
>  	*nsegs = i;
> +	kfree(ipb);
>  	return rc;
>  }
>  
> -- 
> 1.7.9.5
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
