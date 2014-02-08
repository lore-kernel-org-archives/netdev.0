From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] SUNRPC: Allow one callback request to be received
 from two sk_buff
Date: Sat, 08 Feb 2014 23:14:51 +0400
Message-ID: <52F6822B.1000804@cogentembedded.com>
References: <no> <1391826543-3102-1-git-send-email-shaobingqing@bwstor.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: shaobingqing <shaobingqing-Gb3srWounXyPt1CcHtbs0g@public.gmane.org>,
	trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1391826543-3102-1-git-send-email-shaobingqing-Gb3srWounXyPt1CcHtbs0g@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 08-02-2014 6:29, shaobingqing wrote:

> In current code, there only one struct rpc_rqst is prealloced. If one
> callback request is received from two sk_buff, the xprt_alloc_bc_request
> would be execute two times with the same transport->xid. The first time
> xprt_alloc_bc_request will alloc one struct rpc_rqst and the TCP_RCV_COPY_DATA
> bit of transport->tcp_flags will not be cleared. The second time
> xprt_alloc_bc_request could not alloc struct rpc_rqst any more and NULL
> pointer will be returned, then xprt_force_disconnect occur. I think one
> callback request can be allowed to be received from two sk_buff.

> Signed-off-by: shaobingqing <shaobingqing-Gb3srWounXyPt1CcHtbs0g@public.gmane.org>
[...]

> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index cec7b9b..82bfe01 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -211,6 +211,7 @@ struct rpc_xprt {
>   						 * items */
>   	struct list_head	bc_pa_list;	/* List of preallocated
>   						 * backchannel rpc_rqst's */
> +	struct rpc_rqst	*req_first;

    Please align the variable name with the ones above and below.

>   #endif /* CONFIG_SUNRPC_BACKCHANNEL */
>   	struct list_head	recv;
>
[...]
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index ee03d35..c43dca4 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1272,7 +1272,16 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
>   				container_of(xprt, struct sock_xprt, xprt);
>   	struct rpc_rqst *req;
>
> -	req = xprt_alloc_bc_request(xprt);
> +	if (xprt->req_first != NULL &&
> +			xprt->req_first->rq_xid == transport->tcp_xid) {

    The continuation line should be aligned right under 'xprt' on the broken 
up line, according to the networking coding style.

> +		req = xprt->req_first;
> +	} else if (xprt->req_first != NULL &&
> +			xprt->req_first->rq_xid != transport->tcp_xid) {

    Same here.

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
