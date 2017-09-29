From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 0/5] New bpf cpumap type for XDP_REDIRECT
Date: Fri, 29 Sep 2017 08:53:13 +0200
Message-ID: <20170929085313.4ff4815b@redhat.com>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
        <59CD7B94.8010103@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, edumazet@google.com,
        brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58100 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751219AbdI2GxY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 02:53:24 -0400
In-Reply-To: <59CD7B94.8010103@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Sep 2017 00:45:40 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 09/28/2017 02:57 PM, Jesper Dangaard Brouer wrote:
> > Introducing a new way to redirect XDP frames.  Notice how no driver
> > changes are necessary given the design of XDP_REDIRECT.
> >
> > This redirect map type is called 'cpumap', as it allows redirection
> > XDP frames to remote CPUs.  The remote CPU will do the SKB allocation
> > and start the network stack invocation on that CPU.
> >
> > This is a scalability and isolation mechanism, that allow separating
> > the early driver network XDP layer, from the rest of the netstack, and
> > assigning dedicated CPUs for this stage.  The sysadm control/configure
> > the RX-CPU to NIC-RX queue (as usual) via procfs smp_affinity and how
> > many queues are configured via ethtool --set-channels.  Benchmarks
> > show that a single CPU can handle approx 11Mpps.  Thus, only assigning
> > two NIC RX-queues (and two CPUs) is sufficient for handling 10Gbit/s
> > wirespeed smallest packet 14.88Mpps.  Reducing the number of queues
> > have the advantage that more packets being "bulk" available per hard
> > interrupt[1].
> >
> > [1] https://www.netdevconf.org/2.1/papers/BusyPollingNextGen.pdf
> >
> > Use-cases:
> >
> > 1. End-host based pre-filtering for DDoS mitigation.  This is fast
> >     enough to allow software to see and filter all packets wirespeed.
> >     Thus, no packets getting silently dropped by hardware.
> >
> > 2. Given NIC HW unevenly distributes packets across RX queue, this
> >     mechanism can be used for redistribution load across CPUs.  This
> >     usually happens when HW is unaware of a new protocol.  This
> >     resembles RPS (Receive Packet Steering), just faster, but with more
> >     responsibility placed on the BPF program for correct steering.
> >
> > 3. Auto-scaling or power saving via only activating the appropriate
> >     number of remote CPUs for handling the current load.  The cpumap
> >     tracepoints can function as a feedback loop for this purpose.  
> 
> Interesting work, thanks! Still digesting the code a bit. I think
> it pretty much goes into the direction that Eric describes in his
> netdev paper quoted above; not on a generic level though but specific
> to XDP at least; theoretically XDP could just run transparently on
> the CPU doing the filtering, and raw buffers are handed to remote
> CPU with similar batching, but it would need some different config
> interface at minimum.

Good that you noticed this is (implicit) implementing RX bulking, which
is where much of the performance gain originates from.

It is true, I am inspired by Eric's paper (I love it). Do notice that
this is not blocking or interfering with Erics/others continued work in
this area.  This implementation just show that the section "break the
pipe!" idea works very well for XDP. 

More on config knobs below.
 
> Shouldn't we take the CPU(s) running XDP on the RX queues out from
> the normal process scheduler, so that we have a guarantee that user
> space or unrelated kernel tasks cannot interfere with them anymore,
> and we could then turn them into busy polling eventually (e.g. as
> long as XDP is running there and once off could put them back into
> normal scheduling domain transparently)?

We should be careful not to invent networking config knobs that belongs
to other parts of the kernel, like the scheduler.  We already have
ability to control where IRQ's land via procfs smp_affinity.  And if
you want to avoid CPU isolation, we can use the boot cmdline
"isolcpus" (hint like DPDK recommend/use for zero-loss configs).  It is
the userspace tool (or sysadm) loading the XDP program, who is
responsible for having configures the CPU smp_affinity alignment.

Making NAPI busy-poll is out of scope for this patchset. Someone
should work on this separately.  It would just help/improve this kind
of scheme.

I actually think it would be more relevant to add/put the "remote" CPUs
in the 'cpumap' into a separate scheduler group.  To implement stuff
like auto-scaling and power-saving.


> What about RPS/RFS in the sense that once you punt them to remote
> CPU, could we reuse application locality information so they'd end
> up on the right CPU in the first place (w/o backlog detour), or is
> the intent to rather disable it and have some own orchestration
> with relation to the CPU map?

An advanced bpf orchestration could basically implement what you
describe, combined with a userspace side tool that taskset/pin
applications.  To know when a task can move between CPUs, you use the
tracepoints to see when the CPU queue is empty (hint, time_limit=true
and processed=0).

For now, I'm not targeting such advanced use-cases.  My main target is
a customer that have double tagged VLANS, and ixgbe cannot RSS
distribute these, thus they all end-up on queue 0.  And as I
demonstrated (in another email) RPS is too slow to fix this.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
