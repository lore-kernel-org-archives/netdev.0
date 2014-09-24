From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol version
 1.6
Date: Wed, 24 Sep 2014 10:43:31 -0400
Message-ID: <5422D893.6050306@oracle.com>
References: <541AD838.50700@oracle.com>	<20140923.122420.1216927815526255624.davem@davemloft.net>	<5421A497.9060903@oracle.com> <20140923.144432.343377380510348797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Raghuram.Kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16799 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbaIXOnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 10:43:42 -0400
In-Reply-To: <20140923.144432.343377380510348797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/23/2014 02:44 PM, David Miller wrote:
> From: David L Stevens <david.stevens@oracle.com>
> Date: Tue, 23 Sep 2014 12:49:27 -0400
> 
>> Actually, that's exactly what I've been working on for the last few
>> days. I hope to post this soon. Currently, I allow for misaligned
>> packets by reallocating the skbs with the proper alignment, skip and
>> length restrictions, so the code can handle either, but still copies
>> most of the time. Once I have all the kinks worked out there, I was
>> planning to possibly make *all* skb allocations on LDOMs and/or SPARC64 fit
>> those requirements, since they are compatible with the existing alignments
>> and would allow using the HV copy in any case.
> 
> You should be able to avoid the copy on TX almost all of the time.
> 
> If you do a skb_push(skb, VNET_PACKET_SKIP) (and initialize with some
> garbage bytes) it ought to be aligned.

I can't touch the data buffer (head or tail) without getting a COW copy,
which is often also misaligned, but the code I have now is mapping the
existing head and tail as long as they are part of the skb (ie, headroom
and tailroom to fit it) and with that, I can avoid copies almost all the
time in TCP.

ICMP and ARP still copy usually, but aren't generally high-volume. I didn't
try out UDP yet.

Initial testing shows a ~25% reduction in throughput for the default MTU
(from ~1Gbps to ~750Mbps), but with 64K MTU, I get a ~25% increase in throughput--
from ~7.5Gbps with the original patches to 9.6Gbps with the no-copy, but
remapping, allocating, freeing and unmapping on demand.

Of course the reduction in throughput on the low end eliminates static tx
buffers so allows scaling up the number of LDOMs per vswitch without any
penalty in memory, instead of the n^2 growth before.

If the current static buffer allocation is "good enough," despite its poor
scaling, then we might consider a hybrid where we essentially use the old
code for smaller packets, and direct mapping for larger ones. I have some
other ideas to experiment with, too.

							+-DLS
