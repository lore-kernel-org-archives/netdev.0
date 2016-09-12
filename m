From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Mon, 12 Sep 2016 12:56:28 -0700
Message-ID: <20160912195626.GA18146@ast-mbp.thefacebook.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
 <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
 <20160908101147.1b351432@redhat.com>
 <20160909032202.GA62966@ast-mbp.thefacebook.com>
 <20160909073652.351d76d7@redhat.com>
 <20160909063048.GA67375@ast-mbp.thefacebook.com>
 <20160912133025.5b35c25b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35541 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbcILT4e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 15:56:34 -0400
Received: by mail-pa0-f48.google.com with SMTP id b2so53828357pat.2
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 12:56:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160912133025.5b35c25b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 01:30:25PM +0200, Jesper Dangaard Brouer wrote:
> On Thu, 8 Sep 2016 23:30:50 -0700
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> > On Fri, Sep 09, 2016 at 07:36:52AM +0200, Jesper Dangaard Brouer wrote:
> [...]
> > > Imagine you have packets intermixed towards the stack and XDP_TX. 
> > > Every time you call the stack code, then you flush your icache.  When
> > > returning to the driver code, you will have to reload all the icache
> > > associated with the XDP_TX, this is a costly operation.  
> > 
> [...]
> > To make further progress in this discussion can we talk about
> > the use case you have in mind instead? Then solution will
> > be much clear, I hope.
> 
> The DDoS use-case _is_ affected by this "hidden" bulking design.
> 
> Lets say, I want to implement a DDoS facility. Instead of just
> dropping the malicious packets, I want to see the bad packets.  I
> implement this by rewriting the destination-MAC to be my monitor
> machine and then XDP_TX the packet.

not following the use case. you want to implement a DDoS generator?
Or just forward all bad packets from affected host to another host
in the same rack? so two servers will be spammed with traffic and
even more load on the tor? I really don't see how this is useful
for anything but stress testing.

> In the DDoS use-case, you have loaded your XDP/eBPF program, and 100%
> of the traffic is delivered to the stack. (See note 1)

hmm. DoS prevention use case is when 99% of the traffic is dropped.

> Once the DDoS attack starts, then the traffic pattern changes, and XDP
> should (hopefully only) catch the malicious traffic (monitor machine can
> help diagnose false positive).  Now, due to interleaving the DDoS
> traffic with the clean traffic, then efficiency of XDP_TX is reduced due to
> more icache misses...
> 
> 
> 
> Note(1): Notice I have already demonstrated that loading a XDP/eBPF
> program with 100% delivery to the stack, actually slows down the
> normal stack.  This is due to hitting a bottleneck in the page
> allocator.  I'm working removing that bottleneck with page_pool, and
> that solution is orthogonal to this problem.

sure. no one arguing against improving page allocator.

>  It is actually an excellent argument, for why you would want to run a
> DDoS XDP filter only on a restricted number of RX queues.

no. it's the opposite. If the host is under DoS there is no way
the host can tell in advance which rx queue will be seeing bad packets.
