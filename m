From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: Allow one callback request to be received from
 two sk_buff
Date: Wed, 22 Jan 2014 18:52:33 -0500
Message-ID: <20140122235233.GA17155@fieldses.org>
References: <1390201154-20815-1-git-send-email-shaobingqing@bwstor.com.cn>
 <1390259843.2501.2.camel@leira.trondhjem.org>
 <CALrKORrZ3Kcuqc1RajQKkZcot0yiswh4VR_WuXHqfRTjn9oGQQ@mail.gmail.com>
 <1BFACA51-087E-4945-851A-FBF0F108604C@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shaobingqing <shaobingqing-Gb3srWounXyPt1CcHtbs0g@public.gmane.org>,
	Dr Fields James Bruce <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Miller David S." <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linuxnfs <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1BFACA51-087E-4945-851A-FBF0F108604C-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 21, 2014 at 08:35:36AM -0700, Trond Myklebust wrote:
> 
> On Jan 21, 2014, at 3:08, shaobingqing <shaobingqing-Gb3srWounXyPt1CcHtbs0g@public.gmane.org> wrote:
> 
> > 2014/1/21 Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>:
> >> On Mon, 2014-01-20 at 14:59 +0800, shaobingqing wrote:
> >>> In current code, there only one struct rpc_rqst is prealloced. If one
> >>> callback request is received from two sk_buff, the xprt_alloc_bc_request
> >>> would be execute two times with the same transport->xid. The first time
> >>> xprt_alloc_bc_request will alloc one struct rpc_rqst and the TCP_RCV_COPY_DATA
> >>> bit of transport->tcp_flags will not be cleared. The second time
> >>> xprt_alloc_bc_request could not alloc struct rpc_rqst any more and NULL
> >>> pointer will be returned, then xprt_force_disconnect occur. I think one
> >>> callback request can be allowed to be received from two sk_buff.
> >>> 
> >>> Signed-off-by: shaobingqing <shaobingqing-Gb3srWounXyPt1CcHtbs0g@public.gmane.org>
> >>> ---
> >>> net/sunrpc/xprtsock.c |   11 +++++++++--
> >>> 1 files changed, 9 insertions(+), 2 deletions(-)
> >>> 
> >>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> >>> index ee03d35..606950d 100644
> >>> --- a/net/sunrpc/xprtsock.c
> >>> +++ b/net/sunrpc/xprtsock.c
> >>> @@ -1271,8 +1271,13 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
> >>>      struct sock_xprt *transport =
> >>>                              container_of(xprt, struct sock_xprt, xprt);
> >>>      struct rpc_rqst *req;
> >>> +     static struct rpc_rqst *req_partial;
> >>> +
> >>> +     if (req_partial == NULL)
> >>> +             req = xprt_alloc_bc_request(xprt);
> >>> +     else if (req_partial->rq_xid == transport->tcp_xid)
> >>> +             req = req_partial;
> >> 
> >> What happens here if req_partial->rq_xid != transport->tcp_xid? AFAICS,
> >> req will be undefined. Either way, you cannot use a static variable for
> >> storage here: that isn't re-entrant.
> > 
> > Because metadata sever only have one slot for backchannel request,
> > req_partial->rq_xid == transport->tcp_xid always happens, if the callback
> > request just being splited in two sk_buffs. But req_partial->rq_xid !=
> > transport->tcp_xid may also happens in some special cases, such as
> > retransmission occurs?
> 
> If the server retransmits, then it is broken. The NFSv4.1 protocol does not allow it to retransmit unless the connection breaks.

shaobingqing, are you actually seeing retransmission?  (If so, are we
setting up the callback client wrong?)

--b.

> 
> > If one callback request is splited in two sk_buffs, xs_tcp_read_callback
> > will be execute two times. The req_partial should be a static variable,
> > because  the second execution of xs_tcp_read_callback should use
> > the rpc_rqst allocated for the first execution, which saves information
> > copies from the first sk_buff.
> 
> No! This is a multi-threaded/process environment which can support multiple connection. It is a bug to use a static variable.
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
