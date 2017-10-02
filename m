From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] vhost_net: do not stall on zerocopy depletion
Date: Mon, 2 Oct 2017 07:08:01 +0300
Message-ID: <20171002070731-mutt-send-email-mst@kernel.org>
References: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com>
 <20170929223710-mutt-send-email-mst@kernel.org>
 <CAF=yD-KotdpHs96GomMKR-BqG3Gyrvo+to0sk2=a6E5BKjgpkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jason Wang <jasowang@redhat.com>,
        Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42842 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750740AbdJBEIE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 00:08:04 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-KotdpHs96GomMKR-BqG3Gyrvo+to0sk2=a6E5BKjgpkg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 09:25:27PM -0400, Willem de Bruijn wrote:
> On Fri, Sep 29, 2017 at 3:38 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Wed, Sep 27, 2017 at 08:25:56PM -0400, Willem de Bruijn wrote:
> >> From: Willem de Bruijn <willemb@google.com>
> >>
> >> Vhost-net has a hard limit on the number of zerocopy skbs in flight.
> >> When reached, transmission stalls. Stalls cause latency, as well as
> >> head-of-line blocking of other flows that do not use zerocopy.
> >>
> >> Instead of stalling, revert to copy-based transmission.
> >>
> >> Tested by sending two udp flows from guest to host, one with payload
> >> of VHOST_GOODCOPY_LEN, the other too small for zerocopy (1B). The
> >> large flow is redirected to a netem instance with 1MBps rate limit
> >> and deep 1000 entry queue.
> >>
> >>   modprobe ifb
> >>   ip link set dev ifb0 up
> >>   tc qdisc add dev ifb0 root netem limit 1000 rate 1MBit
> >>
> >>   tc qdisc add dev tap0 ingress
> >>   tc filter add dev tap0 parent ffff: protocol ip \
> >>       u32 match ip dport 8000 0xffff \
> >>       action mirred egress redirect dev ifb0
> >>
> >> Before the delay, both flows process around 80K pps. With the delay,
> >> before this patch, both process around 400. After this patch, the
> >> large flow is still rate limited, while the small reverts to its
> >> original rate. See also discussion in the first link, below.
> >>
> >> The limit in vhost_exceeds_maxpend must be carefully chosen. When
> >> vq->num >> 1, the flows remain correlated. This value happens to
> >> correspond to VHOST_MAX_PENDING for vq->num == 256. Allow smaller
> >> fractions and ensure correctness also for much smaller values of
> >> vq->num, by testing the min() of both explicitly. See also the
> >> discussion in the second link below.
> >>
> >> Link:http://lkml.kernel.org/r/CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com
> >> Link:http://lkml.kernel.org/r/20170819064129.27272-1-den@klaipeden.com
> >> Signed-off-by: Willem de Bruijn <willemb@google.com>
> >
> > I'd like to see the effect on the non rate limited case though.
> > If guest is quick won't we have lots of copies then?
> 
> Yes, but not significantly more than without this patch.
> 
> I ran 1, 10 and 100 flow tcp_stream throughput tests from a sender
> in the guest to a receiver in the host.
> 
> To answer the other benchmark question first, I did not see anything
> noteworthy when increasing vq->num from 256 to 1024.
> 
> With 1 and 10 flows without this patch all packets use zerocopy.
> With the patch, less than 1% eschews zerocopy.
> 
> With 100 flows, even without this patch, 90+% of packets are copied.
> Some zerocopy packets from vhost_net fail this test in tun.c
> 
>     if (iov_iter_npages(&i, INT_MAX) <= MAX_SKB_FRAGS)
> 
> Generating packets with up to 21 frags. I'm not sure yet why or
> what the fraction of these packets is. But this in turn can
> disable zcopy_used in vhost_net_tx_select_zcopy for a
> larger share of packets:
> 
>         return !net->tx_flush &&
>                 net->tx_packets / 64 >= net->tx_zcopy_err;
> 
> Because the number of copied and zerocopy packets are the
> same before and after the patch, so are the overall throughput
> numbers.

OK, thanks!
Are you looking into new warnings that kbuild system reported
with this patch?

Thanks,

-- 
MST
