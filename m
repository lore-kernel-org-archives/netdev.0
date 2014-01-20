From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v5 0/9] xen-netback: TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy
Date: Mon, 20 Jan 2014 21:24:20 +0000
Message-ID: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:20229 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaATVYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 16:24:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A long known problem of the upstream netback implementation that on the TX
path (from guest to Dom0) it copies the whole packet from guest memory into
Dom0. That simply became a bottleneck with 10Gb NICs, and generally it's a
huge perfomance penalty. The classic kernel version of netback used grant
mapping, and to get notified when the page can be unmapped, it used page
destructors. Unfortunately that destructor is not an upstreamable solution.
Ian Campbell's skb fragment destructor patch series [1] tried to solve this
problem, however it seems to be very invasive on the network stack's code,
and therefore haven't progressed very well.
This patch series use SKBTX_DEV_ZEROCOPY flags to tell the stack it needs to
know when the skb is freed up. That is the way KVM solved the same problem,
and based on my initial tests it can do the same for us. Avoiding the extra
copy boosted up TX throughput from 6.8 Gbps to 7.9 (I used a slower
Interlagos box, both Dom0 and guest on upstream kernel, on the same NUMA node,
running iperf 2.0.5, and the remote end was a bare metal box on the same 10Gb
switch)
Based on my investigations the packet get only copied if it is delivered to
Dom0 stack, which is due to this [2] patch. That's a bit unfortunate, but
luckily it doesn't cause a major regression for this usecase. In the future
we should try to eliminate that copy somehow.
There are a few spinoff tasks which will be addressed in separate patches:
- grant copy the header directly instead of map and memcpy. This should help
  us avoiding TLB flushing
- use something else than ballooned pages
- fix grant map to use page->index properly
I will run some more extensive tests, but some basic XenRT tests were already
passed with good results.
I've tried to broke it down to smaller patches, with mixed results, so I
welcome suggestions on that part as well:
1: Introduce TX grant map definitions
2: Change TX path from grant copy to mapping
3: Remove old TX grant copy definitons and fix indentations
4: Change RX path for mapped SKB fragments
5: Add stat counters for zerocopy
6: Handle guests with too many frags
7: Add stat counters for frag_list skbs
8: Timeout packets in RX path
9: Aggregate TX unmap operations

v2: I've fixed some smaller things, see the individual patches. I've added a
few new stat counters, and handling the important use case when an older guest
sends lots of slots. Instead of delayed copy now we timeout packets on the RX
path, based on the assumption that otherwise packets should get stucked
anywhere else. Finally some unmap batching to avoid too much TLB flush

v3: Apart from fixing a few things mentioned in responses the important change
is the use the hypercall directly for grant [un]mapping, therefore we can
avoid m2p override.

v4: Now we are using a new grant mapping API to avoid m2p_override. The RX queue
timeout logic changed also.

v5: Only minor fixes based on Wei's comments

[1] http://lwn.net/Articles/491522/
[2] https://lkml.org/lkml/2012/7/20/363

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
