From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 09:45:28 -0700
Message-ID: <20160920164526.GB99429@ast-mbp.thefacebook.com>
References: <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
 <20160920102943.24732097@brouer.com>
 <20160920133300.144037fd@redhat.com>
 <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
 <20160920154036.GA98644@ast-mbp.thefacebook.com>
 <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
 <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160920180609.148874b5@redhat.com>
 <1474388036.23058.26.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160920182717.2de9541e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32911 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755134AbcITQpf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:45:35 -0400
Received: by mail-pa0-f46.google.com with SMTP id hm5so8760033pac.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:45:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160920182717.2de9541e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 06:27:17PM +0200, Jesper Dangaard Brouer wrote:
> On Tue, 20 Sep 2016 09:13:56 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Tue, 2016-09-20 at 18:06 +0200, Jesper Dangaard Brouer wrote:
> > > On Tue, 20 Sep 2016 08:58:30 -0700
> > > Eric Dumazet <eric.dumazet@gmail.com> wrote:  
> > 
> > > > Same for XDP_TX if/when packet is dropped because output ring is full.  
> > > 
> > > For the XDP_TX case a counter is already incremented[1] but it is a
> > > local ring counter (ring->tx_dropped++).
> > > 
> > > Do you think we should maintain separate counters for XDP? (to have a
> > > more consistent interface across drivers...)  
> > 
> > No, as long as the admin can learn drops are occurring.
> 
> Okay, so recording these drops is important for an admin, agreed.  Now
> that we have the chance to define the API, wouldn't is be nice if the
> admin across drive drivers knew what counter to look for???
> 
> > "perf ... -e skb:kfree_skb ..." or drop monitor wont work,
> > unfortunately.
> 
> That is actually a good idea... why not add a trace point for these
> rare drop cases, which is a hassle to debug for an admin?
> Let's actually take advantage of all the nice infrastructure the kernel
> provides(?)

that's a great idea. Instead of adding aborted, ring_full, blahblah counters
everywhere that cost performance, let's add tracepoints that are nops
when not in use.
And if all drivers call the same tracepoints it will be even better.
Monitoring trace_xdp_aborted tracepoint would be generic way to debug
'divide by zero'.

To your other question:
> Please explain why a eBPF program error (div by zero) must be a silent drop?

because 'div by zero' is an abnormal situation that shouldn't be exploited.
Meaning if xdp program is doing DoS prevention and it has a bug that
attacker can now exploit by sending a crafted packet that causes
'div by zero' and kernel will warn then attack got successful.
Therefore it has to be silent drop.
tracpoint in such case is great, since the user can do debugging with it
and even monitoring 24/7 and if suddenly the control plan sees a lot
of such trace_xdp_abotred events, it can disable that tracepoint to avoid
spam and adjust the program or act on attack some other way.
Hardcoded warnings and counters are not generic enough for all
the use cases people want to throw at XDP.
The tracepoints idea is awesome, in a sense that it's optional.
