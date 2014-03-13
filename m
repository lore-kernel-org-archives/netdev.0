From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v7 0/9] xen-netback: TX grant mapping with
 SKBTX_DEV_ZEROCOPY instead of copy
Date: Thu, 13 Mar 2014 10:08:33 +0000
Message-ID: <1394705313.25873.13.camel@kazak.uk.xensource.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-06 at 21:48 +0000, Zoltan Kiss wrote:
> A long known problem of the upstream netback implementation that on the TX
> path (from guest to Dom0) it copies the whole packet from guest memory into
> Dom0. That simply became a bottleneck with 10Gb NICs, and generally it's a
> huge perfomance penalty. The classic kernel version of netback used grant
> mapping, and to get notified when the page can be unmapped, it used page
> destructors. Unfortunately that destructor is not an upstreamable solution.
> Ian Campbell's skb fragment destructor patch series [1] tried to solve this
> problem, however it seems to be very invasive on the network stack's code,
> and therefore haven't progressed very well.
> This patch series use SKBTX_DEV_ZEROCOPY flags to tell the stack it needs to
> know when the skb is freed up. That is the way KVM solved the same problem,
> and based on my initial tests it can do the same for us. Avoiding the extra
> copy boosted up TX throughput from 6.8 Gbps to 7.9 (I used a slower AMD
> Interlagos box, both Dom0 and guest on upstream kernel, on the same NUMA node,
> running iperf 2.0.5, and the remote end was a bare metal box on the same 10Gb
> switch)

Do you have any other numbers? e.g. for a modern Intel or AMD system? A
slower box is likely to make the difference between copy and map larger,
whereas modern Intel for example is supposed to be very good at copying.

> Based on my investigations the packet get only copied if it is delivered to
> Dom0 IP stack through deliver_skb, which is due to this [2] patch. This affects
> DomU->Dom0 IP traffic and when Dom0 does routing/NAT for the guest. That's a bit
> unfortunate, but luckily it doesn't cause a major regression for this usecase.

Numbers?

> In the future we should try to eliminate that copy somehow.
> There are a few spinoff tasks which will be addressed in separate patches:
> - grant copy the header directly instead of map and memcpy. This should help
>   us avoiding TLB flushing
> - use something else than ballooned pages
> - fix grant map to use page->index properly
> I've tried to broke it down to smaller patches, with mixed results, so I
> welcome suggestions on that part as well:
> 1: Use skb->cb to store pending_idx
> 2: Some refactoring
> 3: Change RX path for mapped SKB fragments (moved here to keep bisectability,
> review it after #4)
> 4: Introduce TX grant mapping
> 5: Remove old TX grant copy definitons and fix indentations
> 6: Add stat counters for zerocopy
> 7: Handle guests with too many frags
> 8: Timeout packets in RX path
> 9: Aggregate TX unmap operations
> 
> v2: I've fixed some smaller things, see the individual patches. I've added a
> few new stat counters, and handling the important use case when an older guest
> sends lots of slots. Instead of delayed copy now we timeout packets on the RX
> path, based on the assumption that otherwise packets should get stucked
> anywhere else. Finally some unmap batching to avoid too much TLB flush
> 
> v3: Apart from fixing a few things mentioned in responses the important change
> is the use the hypercall directly for grant [un]mapping, therefore we can
> avoid m2p override.
> 
> v4: Now we are using a new grant mapping API to avoid m2p_override. The RX queue
> timeout logic changed also.
> 
> v5: Only minor fixes based on Wei's comments
> 
> v6: Important bugfixes for xenvif_poll exit path and zerocopy callback, see
> first 2 patches. Also rework of handling packets with too many slots, and
> reorder the series a bit.
> 
> v7: Small fixes in comments/log messages/error paths, and merging the frag
> overflow stats patch into its parent.
> 
> [1] http://lwn.net/Articles/491522/
> [2] https://lkml.org/lkml/2012/7/20/363
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> 
