From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Sun, 24 Jan 2016 16:08:48 -0800
Message-ID: <56A56790.4080808@gmail.com>
References: <20160115142223.1e92be75@redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC6613@AcuExch.aculab.com>
 <20160115150025.13a5db04@redhat.com> <56990473.9090300@openwrt.org>
 <20160118125420.0375ffda@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:34671 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbcAYAIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 19:08:53 -0500
Received: by mail-ob0-f194.google.com with SMTP id x5so8346265obg.1
        for <netdev@vger.kernel.org>; Sun, 24 Jan 2016 16:08:53 -0800 (PST)
In-Reply-To: <20160118125420.0375ffda@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper

On 18/01/2016 03:54, Jesper Dangaard Brouer wrote:
> 
> On Fri, 15 Jan 2016 15:38:43 +0100 Felix Fietkau <nbd@openwrt.org> wrote:
>> On 2016-01-15 15:00, Jesper Dangaard Brouer wrote:
> [...]
>>>
>>> The icache is still quite small 32Kb on modern server processors.  I
>>> don't know if smaller embedded processors also have icache and how
>>> large they are.  I speculate this approach would also be a benefit for
>>> them (if they have icache).
>>
>> All of the router devices that I work with have icache. Typical sizes
>> are 32 or 64 KiB. FWIW, I'm really looking forward to having such
>> optimizations in the network stack ;)
> 
> That is very interesting. These kind of icache optimization will then
> likely benefit lower-end devices more than high end Intel CPUs :-)

Typical embedded routers have small I and D cache, but they also have
fairly small cache line sizes (16, 32 or 64 bytes), and not necessarily
a L2 cache to help them, the memory bandwidth is also very limited
(DDR/DDR2 speeds are not uncommon) so the less I/D cache lines you
trash, the better obviously.

One thing that some HW vendors have done, before they started
introducing a HW capable of offloading routing/NAT workloads to
specialized hardware is to hack the heck of the Linux network stack to
allow a lightweight SKB structure to be used for forwarding and allocate
these "meta" bookeekping SKBs from a dedicated kmem cache pool to get
relatively predictable latencies.

There is also a notion of a dirty pointer within the skbuff itself, such
that instead of e.g: having your Ethernet NIC driver do a DMA-API call
which can potentially invalidate the D-cache for an entire 1500-ish
bytes Ethernet frame, the packet contents are "valid" up until the dirty
pointer, which is a nice trick if you are just forwarding, but requires
both SKB accessors/manipulation functions to check that, and your
Ethernet driver to be cooperative as well, so may not scale well.

Broadcom's implementation of such a thing can be found here among these
files, code is not kernel style compliant, but there might be some
re-usable ideas for you:

NBUFF/FKBUFF/SKBUFF are the actual packet book keeping data structures
that replace and/or extend the use of SKBs:

https://code.google.com/p/gfiber-gflt100/source/browse/kernel/linux/include/linux/nbuff.h
https://code.google.com/p/gfiber-gflt100/source/browse/kernel/linux/net/core/nbuff.c

# Check for CONFIG_MIPS_BRCM changes here:
https://code.google.com/p/gfiber-gflt100/source/browse/kernel/linux/net/core/skbuff.c
https://code.google.com/p/gfiber-gflt100/source/browse/kernel/linux/include/linux/skbuff.h
