From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next V6 PATCH 0/5] New bpf cpumap type for XDP_REDIRECT
Date: Tue, 10 Oct 2017 23:10:39 -0700
Message-ID: <a430c181-aa56-61a7-fc59-9b135bbb262b@gmail.com>
References: <150763962554.14394.15623435724195136364.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35151 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdJKGKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 02:10:43 -0400
Received: by mail-wm0-f65.google.com with SMTP id b189so1115635wmd.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 23:10:43 -0700 (PDT)
In-Reply-To: <150763962554.14394.15623435724195136364.stgit@firesoul>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2017 05:47 AM, Jesper Dangaard Brouer wrote:
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
>    enough to allow software to see and filter all packets wirespeed.
>    Thus, no packets getting silently dropped by hardware.
> 
> 2. Given NIC HW unevenly distributes packets across RX queue, this
>    mechanism can be used for redistribution load across CPUs.  This
>    usually happens when HW is unaware of a new protocol.  This
>    resembles RPS (Receive Packet Steering), just faster, but with more
>    responsibility placed on the BPF program for correct steering.

Hi Jesper,

Another (somewhat meta) comment about the performance benchmarks. In
one of the original threads you showed that the XDP cpu map outperformed
RPS in TCP_CRR netperf tests. It was significant iirc in the mpps range.

But, with this series we will skip GRO. Do you have any idea how this
looks with other tests such as TCP_STREAM? I'm trying to understand
if this is something that can be used in the general case or is more
for the special case and will have to be enabled/disabled by the
orchestration layer depending on workload/network conditions.

My intuition is the general case will be slower due to lack of GRO. If
this is the case any ideas how we could add GRO? Not needed in the
initial patchset but trying to see if the two are mutually exclusive. I
don't off-hand see an easy way to pull GRO into this feature.

Thanks,
John
