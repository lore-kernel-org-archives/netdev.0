From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] netlink: do not enter direct reclaim from
 netlink_dump()
Date: Wed, 5 Oct 2016 16:59:57 -0700
Message-ID: <20161005235956.GB87410@ast-mbp.thefacebook.com>
References: <1475694798.28155.215.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161005222438.GA86006@ast-mbp.thefacebook.com>
 <1475710211.28155.232.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Greg Thelen <gthelen@google.com>, Chris Mason <clm@fb.com>,
        kernel-team@fb.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32776 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755289AbcJFAAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 20:00:03 -0400
Received: by mail-pf0-f194.google.com with SMTP id i85so162240pfa.0
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 17:00:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1475710211.28155.232.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 06, 2016 at 08:30:11AM +0900, Eric Dumazet wrote:
> On Wed, 2016-10-05 at 15:24 -0700, Alexei Starovoitov wrote:
> > On Thu, Oct 06, 2016 at 04:13:18AM +0900, Eric Dumazet wrote:
> > > 
> > > While we are at it, since we do an order-3 allocation, allow to use
> > > all the allocated bytes instead of 16384 to reduce syscalls during
> > > large dumps.
> > > 
> > > iproute2 already uses 32KB recvmsg() buffer sizes.
> > ....
> > > diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> > > index 627f898c05b96552318a881ce995ccc3342e1576..62bea4591054820eb516ef016214ee23fe89b6e9 100644
> > > --- a/net/netlink/af_netlink.c
> > > +++ b/net/netlink/af_netlink.c
> > > @@ -1832,7 +1832,7 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
> > >  	/* Record the max length of recvmsg() calls for future allocations */
> > >  	nlk->max_recvmsg_len = max(nlk->max_recvmsg_len, len);
> > >  	nlk->max_recvmsg_len = min_t(size_t, nlk->max_recvmsg_len,
> > > -				     16384);
> > > +				     SKB_WITH_OVERHEAD(32768));
> > 
> > sure, it won't stress it more than what it is today, but why increase it?
> > iproute2 increased the buffer form 16k to 32k due to 'msg_trunc' which
> > I think was due to this issue. If we go with SKB_WITH_OVERHEAD(16384)
> > we can go back to 16k in iproute2 as well.
> > 
> > Do we have any data to justify that buffer of 32k - skb_shared_info vs 16k
> > will meaninfully reduce the number of syscalls?
> > We're seeing direct reclaim get hammered due to order-3.
> > Not sure whether & ~__GFP_DIRECT_RECLAIM is going to be enough.
> 
> It is. Really.
> 
> > Currently we're testing with SKB_WITH_OVERHEAD(16384) and ~__GFP_DIRECT_RECLAIM.
> > It will take another week to make sure SKB_WITH_OVERHEAD(32768) is ok.
> > imo this optimization is done too soon.
> > I'd much more comfortable with SKB_WITH_OVERHEAD(16384) value here.
> 
> Well, we _are_ allocating order-3 pages already.
> 
> No need to switch to order-2 pages, when we have the proper fix.
> 
> Note that tcp_sendmsg() does this all the time, and nobody complained
> after Shaohua Li fix (commit fb05e7a89f500cf "net: don't wait for
> order-3 page allocation")
> 
> Why thousands of sockets could use order-3 pages, but constrain _one_
> (rtnl serializations) iproute2 dump to use tiny blocs exactly ?

Good point. Large tcp_sendmsg() should be stressing mm
with order-3 more than netlink polling once a second
that some application do with 'ss' or 'tc -s show'

> Really there is no point being cautious here.

I guess I'm being too paranoid. If we discover issues
with SKB_WITH_OVERHEAD(32768), we can adjust it later, so
Acked-by: Alexei Starovoitov <ast@kernel.org>
