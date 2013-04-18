From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/14]: netlink: memory mapped I/O
Date: Thu, 18 Apr 2013 13:11:02 +0200
Message-ID: <20130418111102.GB26734@macbook.localnet>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
 <20130417194046.GF1408@breakpoint.cc>
 <20130418102738.GA25166@macbook.localnet>
 <20130418110105.GH1408@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130418110105.GH1408@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 01:01:05PM +0200, Florian Westphal wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> > So I think while the nfnetlink_queue zero copy patches are a great idea,
> > there are still enough unhandled use cases for memory mapped netlink.
> >
> > > Another issue with mmap is the need to preallocate the ring frame size.
> > > After the gso avoidance change [ no skb_gso_segment calls anymore ],
> > > we will need to be able to queue GSO/GRO skbs, which makes it necessary to
> > > cope with 64k payload in the mmap case...
> > 
> > Hmm that might actually also be a problem in the zcopy case for userspace since
> > the netlink recv buffer sizes are in many cases not that large.
> 
> I am not sure I am following here.  Can you elaborate?
> Maybe I was a bit too vague, so let me try to clarify.
> 
> The GSO segmentation avoidance patch requires userspace support, including large
> recv buffer size (i.e., 64k + a few byte netlink overhead).
> 
> It will be off by default, userspace needs to enable it when it binds
> the nfqueue.

I see, that makes sense.

> What I was pointing out is that for mmap'd netlink you usually need
> to allocate enough slots so the ring can handle e.g. 1024 packets.
> 
> For the 64k packet case, that would be >64 MB mmap-ring.
> 
> I'm not saying its a problem, just wanted to point it out.
> 
> [ 64k is probably rare enough to have mmap-users fallback to recv,
>   and your patches already support this ].

Yes, thats true. An alternative would be to have the ring frames dynamically
sized. The downside is that it increases overhead on the kernel side for
socket congestion control, currently its very easy to check whether the ring
is half empty, with dynamically sized frames we'd need to iterate through
the ring.

A further alternative would be to seperate the control and data areas, so
we'd have four rings, RX-control, RX-data, TX-control and TX-data. That would
avoid that problem, but it would only be partially dynamic since the number
of control frames would be constant.
