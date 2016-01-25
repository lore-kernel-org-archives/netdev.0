From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Bypass at packet-page level (Was: Optimizing instruction-cache,
 more packets at each stage)
Date: Mon, 25 Jan 2016 09:50:16 -0800
Message-ID: <56A66058.1090308@gmail.com>
References: <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>	<20160121122730.6330a84b@redhat.com>	<20160121.105401.1793719917762270884.davem@davemloft.net>	<20160124152814.2ea5e99b@redhat.com>	<20160124163846-mutt-send-email-mst@redhat.com>	<56A509C4.3030706@gmail.com>	<20160125141516.795f3eb7@redhat.com> <CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
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
To: Tom Herbert <tom@herbertland.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36710 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934038AbcAYRuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 12:50:40 -0500
Received: by mail-pa0-f54.google.com with SMTP id yy13so83867634pab.3
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 09:50:39 -0800 (PST)
In-Reply-To: <CALx6S37EmUh7SXmVSjTN9DLMTicr6-VwL-i25VV1fM=V2E6giQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-25 09:09 AM, Tom Herbert wrote:
> On Mon, Jan 25, 2016 at 5:15 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
>>
>> After reading John's reply about perfect filters, I want to re-state
>> my idea, for this very early RX stage.  And describe a packet-page
>> level bypass use-case, that John indirectly mentions.
>>
>>
>> There are two ideas, getting mixed up here.  (1) bundling from the
>> RX-ring, (2) allowing to pick up the "packet-page" directly.
>>
>> Bundling (1) is something that seems natural, and which help us
>> amortize the cost between layers (and utilizes icache better). Lets
>> keep that in another thread.
>>
>> This (2) direct forward of "packet-pages" is a fairly extreme idea,
>> BUT it have the potential of being an new integration point for
>> "selective" bypass-solutions and bringing RAW/af_packet (RX) up-to
>> speed with bypass-solutions.
>>
>>
>> Today, the bypass-solutions grab and control the entire NIC HW.  In
>> many cases this is not very practical, if you also want to use the NIC
>> for something else.
>>
>> Solutions for bypassing only part of the traffic is starting to show
>> up.  Both a netmap[1] and a DPDK[2] based approach.
>>
>> [1] https://blog.cloudflare.com/partial-kernel-bypass-merged-netmap/
>> [2] http://rhelblog.redhat.com/2015/10/02/getting-the-best-of-both-worlds-with-queue-splitting-bifurcated-driver/
>>
>> Both approaches install a HW filter in the NIC, and redirect packets
>> to a separate RX HW queue (via ethtool ntuple + flow-type).  DPDK
>> needs pci SRIOV setup and then run it own poll-mode driver on top.
>> Netmap patch the orig ixgbe driver, and since CloudFlare/Gilberto's
>> changes[3] support a single RX queue mode.
>>

FWIW I wrote a version of the patch talked about in the queue splitting
article that didn't require SR-IOV and we also talked about it at last
netconf in ottowa. The problem is without SR-IOV if you map a queue
directly into userspace so you can run the poll mode drivers there is
nothing protecting the DMA engine. So userspace can put arbitrary
addresses in there. There is something called Process Address Space ID
(PASID) also part of the PCI-SIG spec that could help you here but I
don't know of any hardware that supports it. The other option is to
use system calls and validate the descriptors in the kernel but this
incurs some overhead we had it at 15% or so when I did the numbers
last year. However I'm told there is some interesting work going on
around syscall overhead that may help.

One thing to note is SRIOV does somewhat limit the number of these
types of interfaces you can support to the max VFs where as the
queue mechanism although slower with a function call would be limited
to max number of queues. Also busy polling will help here if you
are worried about pps.

Jesper, at least for you (2) case what are we missing with the
bifurcated/queue splitting work? Are you really after systems
without SR-IOV support or are you trying to get this on the order
of queues instead of VFs.

> Jepser, thanks for providing more specifics.
> 
> One comment: If you intend to change core code paths or APIs for this,
> then I think that we should require up front that the associated HW
> support is protocol agnostic (i.e. HW filters must be programmable and
> generic ). We don't want a promising feature like this to be
> undermined by protocol ossification.

At the moment we use ethtool ntuple filters which is basically adding
a new set of enums and structures every time we need a new protocol
so its painful and you need your vendor to support you and you need a
new kernel.

The flow api was shot down (which would get you to the point where
the user could specify the protocols for the driver to implement e.g.
put_parse_graph) and the only new proposals I've seen are bpf
translations in drivers and 'tc'. I plan to take another shot at this in
net-next.

> 
> Thanks,
> Tom
> 
>> [3] https://github.com/luigirizzo/netmap/pull/87
>>
