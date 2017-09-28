From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/5] New bpf cpumap type for XDP_REDIRECT
Date: Fri, 29 Sep 2017 00:45:40 +0200
Message-ID: <59CD7B94.8010103@iogearbox.net>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, edumazet@google.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52750 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdI1Wpr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 18:45:47 -0400
In-Reply-To: <150660339205.2808.7084136789768233829.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2017 02:57 PM, Jesper Dangaard Brouer wrote:
> Introducing a new way to redirect XDP frames.  Notice how no driver
> changes are necessary given the design of XDP_REDIRECT.
>
> This redirect map type is called 'cpumap', as it allows redirection
> XDP frames to remote CPUs.  The remote CPU will do the SKB allocation
> and start the network stack invocation on that CPU.
>
> This is a scalability and isolation mechanism, that allow separating
> the early driver network XDP layer, from the rest of the netstack, and
> assigning dedicated CPUs for this stage.  The sysadm control/configure
> the RX-CPU to NIC-RX queue (as usual) via procfs smp_affinity and how
> many queues are configured via ethtool --set-channels.  Benchmarks
> show that a single CPU can handle approx 11Mpps.  Thus, only assigning
> two NIC RX-queues (and two CPUs) is sufficient for handling 10Gbit/s
> wirespeed smallest packet 14.88Mpps.  Reducing the number of queues
> have the advantage that more packets being "bulk" available per hard
> interrupt[1].
>
> [1] https://www.netdevconf.org/2.1/papers/BusyPollingNextGen.pdf
>
> Use-cases:
>
> 1. End-host based pre-filtering for DDoS mitigation.  This is fast
>     enough to allow software to see and filter all packets wirespeed.
>     Thus, no packets getting silently dropped by hardware.
>
> 2. Given NIC HW unevenly distributes packets across RX queue, this
>     mechanism can be used for redistribution load across CPUs.  This
>     usually happens when HW is unaware of a new protocol.  This
>     resembles RPS (Receive Packet Steering), just faster, but with more
>     responsibility placed on the BPF program for correct steering.
>
> 3. Auto-scaling or power saving via only activating the appropriate
>     number of remote CPUs for handling the current load.  The cpumap
>     tracepoints can function as a feedback loop for this purpose.

Interesting work, thanks! Still digesting the code a bit. I think
it pretty much goes into the direction that Eric describes in his
netdev paper quoted above; not on a generic level though but specific
to XDP at least; theoretically XDP could just run transparently on
the CPU doing the filtering, and raw buffers are handed to remote
CPU with similar batching, but it would need some different config
interface at minimum.

Shouldn't we take the CPU(s) running XDP on the RX queues out from
the normal process scheduler, so that we have a guarantee that user
space or unrelated kernel tasks cannot interfere with them anymore,
and we could then turn them into busy polling eventually (e.g. as
long as XDP is running there and once off could put them back into
normal scheduling domain transparently)?

What about RPS/RFS in the sense that once you punt them to remote
CPU, could we reuse application locality information so they'd end
up on the right CPU in the first place (w/o backlog detour), or is
the intent to rather disable it and have some own orchestration
with relation to the CPU map?

Cheers,
Daniel
