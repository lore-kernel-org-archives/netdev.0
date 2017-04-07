From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] virtio-net: clean tx descriptors from rx
 napi
Date: Sat, 8 Apr 2017 00:10:27 +0300
Message-ID: <20170408000823-mutt-send-email-mst@kernel.org>
References: <20170402201012.76473-1-willemdebruijn.kernel@gmail.com>
 <20170402201012.76473-4-willemdebruijn.kernel@gmail.com>
 <20170403024751.GA21883@redhat.com>
 <CAF=yD-+tJxqvwvLU81=H7nwqDtiSWfAv8UdfncjPQiuNteJ6jQ@mail.gmail.com>
 <20170407222616-mutt-send-email-mst@kernel.org>
 <CAF=yD-JmO7XVng74BubyDLyP5Yf7wSCdXJdza+hx-NkrhDoxrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48152 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751059AbdDGVK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 17:10:28 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-JmO7XVng74BubyDLyP5Yf7wSCdXJdza+hx-NkrhDoxrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 04:59:58PM -0400, Willem de Bruijn wrote:
> On Fri, Apr 7, 2017 at 3:28 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Mon, Apr 03, 2017 at 01:02:13AM -0400, Willem de Bruijn wrote:
> >> On Sun, Apr 2, 2017 at 10:47 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >> > On Sun, Apr 02, 2017 at 04:10:12PM -0400, Willem de Bruijn wrote:
> >> >> From: Willem de Bruijn <willemb@google.com>
> >> >>
> >> >> Amortize the cost of virtual interrupts by doing both rx and tx work
> >> >> on reception of a receive interrupt if tx napi is enabled. With
> >> >> VIRTIO_F_EVENT_IDX, this suppresses most explicit tx completion
> >> >> interrupts for bidirectional workloads.
> >> >>
> >> >> Signed-off-by: Willem de Bruijn <willemb@google.com>
> >
> > This is a popular approach, but I think this will only work well if tx
> > and rx interrupts are processed on the same CPU and if tx queue is per
> > cpu.  If they target different CPUs or if tx queue is used from multiple
> > CPUs they will conflict on the shared locks.
> 
> Yes. As a result of this discussion I started running a few vcpu affinity tests.
> 
> The data is not complete. In particular, I don't have the data yet to
> compare having tx and rx irq on the same cpu (0,0) vs on different
> (0,2) for this patchset. Which is the relevant data to your point.
> 
> Initial results for unmodified upstream driver at {1, 10, 100}x
> TCP_STREAM, for irq cpu affinity (rx,tx). Process is always pinned to cpu
> 1. This is a 4 vcpu system pinned by the host to 4 cores on the same
> socket. The previously reported results were obtained with txq, rtx
> and process on different vcpus (0,2). Running all on the same vcpu
> lower cycle count considerably:
> 
> irq 0,0
> 1    throughput_Mbps=29767.14  391,488,924,526      cycles
> 10  throughput_Mbps=40808.64  424,530,251,896      cycles
> 100 throughput_Mbps=33475.13  414,622,071,167      cycles
> 
> irq 0,2
> 1   throughput_Mbps=30176.05  395,673,200,747      cycles
> 10 throughput_Mbps=40729.26  433,948,374,991      cycles
> 100 throughput_Mbps=33758.68 436,291,949,393      cycles
> 
> irq 1,1
> 1    throughput_Mbps=26635.20 269,071,002,844      cycles
> 10  throughput_Mbps=42385.05 299,945,944,516      cycles
> 100 throughput_Mbps=33580.98 283,272,895,507      cycles
> 
> With this patch set applied, cpu (1,1)
> 
> 1     throughput_Mbps=34980.76  276,504,805,414      cycles
> 10   throughput_Mbps=42519.92 298,105,889,785      cycles
> 100 throughput_Mbps=35268.86 296,670,598,712      cycles
> 
> I will need to get data for (0,2) vs (0,0).
> 
> > This can even change dynamically as CPUs/queues are reconfigured.
> > How about adding a flag and skipping the tx poll if there's no match?
> 
> I suspect that even with the cache invalidations this optimization
> will be an improvement over handling all tx interrupts in the tx napi
> handler. I will get the datapoint for that.
> 
> That said, we can make this conditional. What flag exactly do you
> propose? Compare raw_smp_processor_id() in the rx softint with one
> previously stored in the napi tx callback?

I'm not sure. Another idea is to check vi->affinity_hint_set.
If set we know rq and sq are on the same CPU.

-- 
MST
