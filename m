From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V6 PATCH 0/5] New bpf cpumap type for XDP_REDIRECT
Date: Wed, 11 Oct 2017 10:06:08 +0200
Message-ID: <20171011100608.48bc1c86@redhat.com>
References: <150763962554.14394.15623435724195136364.stgit@firesoul>
        <a430c181-aa56-61a7-fc59-9b135bbb262b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59230 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757219AbdJKIGU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Oct 2017 04:06:20 -0400
In-Reply-To: <a430c181-aa56-61a7-fc59-9b135bbb262b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Oct 2017 23:10:39 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 10/10/2017 05:47 AM, Jesper Dangaard Brouer wrote:
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
> >    enough to allow software to see and filter all packets wirespeed.
> >    Thus, no packets getting silently dropped by hardware.
> > 
> > 2. Given NIC HW unevenly distributes packets across RX queue, this
> >    mechanism can be used for redistribution load across CPUs.  This
> >    usually happens when HW is unaware of a new protocol.  This
> >    resembles RPS (Receive Packet Steering), just faster, but with more
> >    responsibility placed on the BPF program for correct steering.  
> 
> Hi Jesper,
> 
> Another (somewhat meta) comment about the performance benchmarks. In
> one of the original threads you showed that the XDP cpu map outperformed
> RPS in TCP_CRR netperf tests. It was significant iirc in the mpps range.

Let me correct this.  This is (significantly) faster than RPS, and
it have the same performance as netperf TCP_CRR and TCP_RR.  As this is
just invoking the network stack (on a remote CPU). Thus, I'm very happy
to see the same comparative performance.  The netperf TCP_RR test is
actually the worst case scenario, where the "hidden" bulking doesn't
work.  And RPS is the best case scenario. I've even left several
optimization opportunities for later.


> But, with this series we will skip GRO. Do you have any idea how this
> looks with other tests such as TCP_STREAM? I'm trying to understand
> if this is something that can be used in the general case or is more
> for the special case and will have to be enabled/disabled by the
> orchestration layer depending on workload/network conditions.

On my testlab server, the TCP_STREAM tests show the same results (full
10G with MTU size packets).  This is because my server is fast-enough,
and don't need the GRO aggregation to keep up (it "only" need to handle
812Kpps).
 
> My intuition is the general case will be slower due to lack of GRO. If
> this is the case any ideas how we could add GRO? Not needed in the
> initial patchset but trying to see if the two are mutually exclusive.
> I don't off-hand see an easy way to pull GRO into this feature.

Adding GRO _later_ is a big part of my plan.  I haven't figured out the
exact code paths.  The general idea is to perform partial sorting of
flows, based on the RSS-hash or something provided by the BPF prog.

NetFlix's extension to FreeBSD illustrate the GRO sorting problem
nicely[1], see section "RSS Assisted LRO".  For the record, my idea is
not based on their idea.  I had this idea long before reading their
article. I want to partial sorting on many levels. E.g. cpumap enqueue
can have 8 times 8 percpu packet queues (64 packets max NAPI budget)
sorted on some part of the RSS-hash.  BPF prog choosing a CPU
destination is also a sorting step.  The cpumap dequeue kthread step,
that need to invoke a GRO netstack function, can also perform a partial
sorting step, plus implement a GRO flush point when the queue is empty.

[1] https://medium.com/netflix-techblog/serving-100-gbps-from-an-open-connect-appliance-cdb51dda3b99

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
