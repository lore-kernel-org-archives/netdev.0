From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] netlink: do not enter direct reclaim from
 netlink_dump()
Date: Thu, 06 Oct 2016 08:30:11 +0900
Message-ID: <1475710211.28155.232.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1475694798.28155.215.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161005222438.GA86006@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Greg Thelen <gthelen@google.com>, Chris Mason <clm@fb.com>,
        kernel-team@fb.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35637 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933430AbcJEXaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 19:30:18 -0400
Received: by mail-yw0-f193.google.com with SMTP id t193so154119ywc.2
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 16:30:18 -0700 (PDT)
In-Reply-To: <20161005222438.GA86006@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-05 at 15:24 -0700, Alexei Starovoitov wrote:
> On Thu, Oct 06, 2016 at 04:13:18AM +0900, Eric Dumazet wrote:
> > 
> > While we are at it, since we do an order-3 allocation, allow to use
> > all the allocated bytes instead of 16384 to reduce syscalls during
> > large dumps.
> > 
> > iproute2 already uses 32KB recvmsg() buffer sizes.
> ....
> > diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> > index 627f898c05b96552318a881ce995ccc3342e1576..62bea4591054820eb516ef016214ee23fe89b6e9 100644
> > --- a/net/netlink/af_netlink.c
> > +++ b/net/netlink/af_netlink.c
> > @@ -1832,7 +1832,7 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
> >  	/* Record the max length of recvmsg() calls for future allocations */
> >  	nlk->max_recvmsg_len = max(nlk->max_recvmsg_len, len);
> >  	nlk->max_recvmsg_len = min_t(size_t, nlk->max_recvmsg_len,
> > -				     16384);
> > +				     SKB_WITH_OVERHEAD(32768));
> 
> sure, it won't stress it more than what it is today, but why increase it?
> iproute2 increased the buffer form 16k to 32k due to 'msg_trunc' which
> I think was due to this issue. If we go with SKB_WITH_OVERHEAD(16384)
> we can go back to 16k in iproute2 as well.
> 
> Do we have any data to justify that buffer of 32k - skb_shared_info vs 16k
> will meaninfully reduce the number of syscalls?
> We're seeing direct reclaim get hammered due to order-3.
> Not sure whether & ~__GFP_DIRECT_RECLAIM is going to be enough.

It is. Really.

> Currently we're testing with SKB_WITH_OVERHEAD(16384) and ~__GFP_DIRECT_RECLAIM.
> It will take another week to make sure SKB_WITH_OVERHEAD(32768) is ok.
> imo this optimization is done too soon.
> I'd much more comfortable with SKB_WITH_OVERHEAD(16384) value here.

Well, we _are_ allocating order-3 pages already.

No need to switch to order-2 pages, when we have the proper fix.

Note that tcp_sendmsg() does this all the time, and nobody complained
after Shaohua Li fix (commit fb05e7a89f500cf "net: don't wait for
order-3 page allocation")

Why thousands of sockets could use order-3 pages, but constrain _one_
(rtnl serializations) iproute2 dump to use tiny blocs exactly ?

The rationale for order-3 is pretty clear : 

#define PAGE_ALLOC_COSTLY_ORDER 3

Really there is no point being cautious here.
