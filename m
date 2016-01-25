From: Tom Herbert <tom@herbertland.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Mon, 25 Jan 2016 09:09:45 -0800
Message-ID: <CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	<20160121122730.6330a84b@redhat.com>
	<20160121.105401.1793719917762270884.davem@davemloft.net>
	<20160124152814.2ea5e99b@redhat.com>
	<20160124163846-mutt-send-email-mst@redhat.com>
	<56A509C4.3030706@gmail.com>
	<20160125141516.795f3eb7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vladislav Yasevich <vyasevich@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33943 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757504AbcAYRJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 12:09:46 -0500
Received: by mail-ig0-f177.google.com with SMTP id ik10so38797821igb.1
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 09:09:46 -0800 (PST)
In-Reply-To: <20160125141516.795f3eb7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 25, 2016 at 5:15 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> After reading John's reply about perfect filters, I want to re-state
> my idea, for this very early RX stage.  And describe a packet-page
> level bypass use-case, that John indirectly mentions.
>
>
> There are two ideas, getting mixed up here.  (1) bundling from the
> RX-ring, (2) allowing to pick up the "packet-page" directly.
>
> Bundling (1) is something that seems natural, and which help us
> amortize the cost between layers (and utilizes icache better). Lets
> keep that in another thread.
>
> This (2) direct forward of "packet-pages" is a fairly extreme idea,
> BUT it have the potential of being an new integration point for
> "selective" bypass-solutions and bringing RAW/af_packet (RX) up-to
> speed with bypass-solutions.
>
>
> Today, the bypass-solutions grab and control the entire NIC HW.  In
> many cases this is not very practical, if you also want to use the NIC
> for something else.
>
> Solutions for bypassing only part of the traffic is starting to show
> up.  Both a netmap[1] and a DPDK[2] based approach.
>
> [1] https://blog.cloudflare.com/partial-kernel-bypass-merged-netmap/
> [2] http://rhelblog.redhat.com/2015/10/02/getting-the-best-of-both-worlds-with-queue-splitting-bifurcated-driver/
>
> Both approaches install a HW filter in the NIC, and redirect packets
> to a separate RX HW queue (via ethtool ntuple + flow-type).  DPDK
> needs pci SRIOV setup and then run it own poll-mode driver on top.
> Netmap patch the orig ixgbe driver, and since CloudFlare/Gilberto's
> changes[3] support a single RX queue mode.
>
Jepser, thanks for providing more specifics.

One comment: If you intend to change core code paths or APIs for this,
then I think that we should require up front that the associated HW
support is protocol agnostic (i.e. HW filters must be programmable and
generic ). We don't want a promising feature like this to be
undermined by protocol ossification.

Thanks,
Tom

> [3] https://github.com/luigirizzo/netmap/pull/87
>
>
> I'm thinking, why run all this extra driver software on top.  Why
> don't we just pickup the (packet)-page from the RX ring, and
> hand-it-over to a registered bypass handler?  (as mentioned before,
> the HW descriptor need to somehow "mark" these packets for us).
>
> I imagine some kind of page ring structure, and I also imagine
> RAW/af_packet being a "bypass" consumer.  I guess the af_packet part
> was also something John and Daniel have been looking at.
>
>
> (top post, but left John's replay below, because it got me thinking)
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
>
>
>
>
> On Sun, 24 Jan 2016 09:28:36 -0800
> John Fastabend <john.fastabend@gmail.com> wrote:
>
>> On 16-01-24 06:44 AM, Michael S. Tsirkin wrote:
>> > On Sun, Jan 24, 2016 at 03:28:14PM +0100, Jesper Dangaard Brouer wrote:
>> >> On Thu, 21 Jan 2016 10:54:01 -0800 (PST)
>> >> David Miller <davem@davemloft.net> wrote:
>> >>
>> >>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>> >>> Date: Thu, 21 Jan 2016 12:27:30 +0100
>> >>>
> [...]
>
>> >>
>> >> BUT then I realized, what if we take this even further.  What if we
>> >> actually use this information, for something useful, at this very
>> >> early RX stage.
>> >>
>> >> The information I'm interested in, from the HW descriptor, is if this
>> >> packet is NOT for local delivery.  If so, we can send the packet on a
>> >> "fast-forward" code path.
>> >>
>> >> Think about bridging packets to a guest OS.  Because we know very
>> >> early at RX (from packet HW descriptor) we might even avoid allocating
>> >> a SKB.  We could just "forward" the packet-page to the guest OS.
>> >
>> > OK, so you would build a new kind of rx handler, and then
>> > e.g. macvtap could maybe get packets this way?
>> > Sure - e.g. vhost expects an skb at the moment
>> > but it won't be too hard to teach it that there's
>> > some other option.
>>
>> + Daniel, Vlad
>>
>> If you use the macvtap device with the offload features you can "know"
>> via mac address that all packets on a specific hardware queue set belong
>> to a specific guest. (the queues are bound to a new netdev) This works
>> well with the passthru mode of macvlan. So you can do hardware bridging
>> this way. Supporting similar L3 modes probably not via macvlan has been
>> on my todo list for awhile but I haven't got there yet. ixgbe and fm10k
>> intel drivers support this now maybe others but those are the two I've
>> worked with recently.
>>
>> The idea here is you remove any overhead from running bridge code, etc.
>> but still allowing users to stick netfilter, qos, etc hooks in the
>> datapath.
>>
>> Also Daniel and I started working on a zero-copy RX mode which would
>> further help this by letting vhost-net pass down a set of dma buffers
>> we should probably get this working and submit it. iirc Vlad also
>> had the same sort of idea. The initial data for this looked good but
>> not as good as the solution below. However it had a similar issue as
>> below in that you just jumped over netfilter, qos, etc. Our initial
>> implementation used af_packet.
>>
>> >
>> > Or maybe some kind of stub skb that just has
>> > the correct length but no data is easier,
>> > I'm not sure.
>> >
>>
>> Another option is to use perfect filters to push traffic to a VF and
>> then map the VF into user space and use the vhost dpdk bits. This
>> works fairly well and gets pkts into the guest with little hypervisor
>> overhead and no(?) kernel network stack overhead. But the trade-off is
>> you cut out netfilter, qos, etc. This is really slick if you "trust"
>> your guest or have enough ACLs/etc in your hardware to "trust' the
>> guest.
>>
>> A compromise is to use a VF and do not unbind it from the OS then
>> you can use macvtap again and map the netdev 1:1 to a guest. With
>> this mode you can still use your netfilter, qos, etc. but do l2,l3,l4
>> hardware forwarding with perfect filters.
>>
>> As an aside if you don't like ethtool perfect filters I have a set of
>> patches to control this via 'tc' that I'll submit when net-next opens
>> up again which would let you support filtering on more field options
>> using offset:mask:value notation.
>>
>> >> Taking Eric's idea, of remote CPUs, we could even send these
>> >> packet-pages to a remote CPU (e.g. where the guest OS is running),
>> >> without having touched a single cache-line in the packet-data.  I
>> >> would still bundle them up first, to amortize the (100-133ns) cost of
>> >> transferring something to another CPU.
>> >
>> > This bundling would have to happen in a guest
>> > specific way then, so in vhost.
>> > I'd be curious to see what you come up with.
>
