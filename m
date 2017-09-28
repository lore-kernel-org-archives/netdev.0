From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] vhost_net: do not stall on zerocopy depletion
Date: Wed, 27 Sep 2017 20:33:38 -0400
Message-ID: <CAF=yD-LYhzuJZv89HvktOphPMnBP=tK7H=2UdUTFacc-CRA2bQ@mail.gmail.com>
References: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:51401 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752402AbdI1AeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 20:34:19 -0400
Received: by mail-oi0-f51.google.com with SMTP id n82so14245785oib.8
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 17:34:18 -0700 (PDT)
In-Reply-To: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 8:25 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Vhost-net has a hard limit on the number of zerocopy skbs in flight.
> When reached, transmission stalls. Stalls cause latency, as well as
> head-of-line blocking of other flows that do not use zerocopy.
>
> Instead of stalling, revert to copy-based transmission.
>
> Tested by sending two udp flows from guest to host, one with payload
> of VHOST_GOODCOPY_LEN, the other too small for zerocopy (1B). The
> large flow is redirected to a netem instance with 1MBps rate limit
> and deep 1000 entry queue.
>
>   modprobe ifb
>   ip link set dev ifb0 up
>   tc qdisc add dev ifb0 root netem limit 1000 rate 1MBit
>
>   tc qdisc add dev tap0 ingress
>   tc filter add dev tap0 parent ffff: protocol ip \
>       u32 match ip dport 8000 0xffff \
>       action mirred egress redirect dev ifb0
>
> Before the delay, both flows process around 80K pps. With the delay,
> before this patch, both process around 400. After this patch, the
> large flow is still rate limited, while the small reverts to its
> original rate. See also discussion in the first link, below.
>
> The limit in vhost_exceeds_maxpend must be carefully chosen. When
> vq->num >> 1, the flows remain correlated. This value happens to
> correspond to VHOST_MAX_PENDING for vq->num == 256. Allow smaller
> fractions and ensure correctness also for much smaller values of
> vq->num, by testing the min() of both explicitly. See also the
> discussion in the second link below.
>
> Link:http://lkml.kernel.org/r/CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com

>From the same discussion thread: it would be good to expose stats
on the number of zerocopy skb sent and number completed without
copy.

To test this patch, I also added ethtool stats to tun and extended them
with two zerocopy counters. Then had tun override the uarg->callback
with its own and update the counters before calling the original callback.

The one useful datapoint I did not get out of that is why skbs would
revert to non-zerocopy: because of size, vhost_exceeds_maxpend
or vhost_net_tx_select_zcopy. The simplistic implementation with an
extra indirect function call and without percpu counters is also not
suitable for submission as is.
