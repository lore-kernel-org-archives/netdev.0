From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v7 0/9] xen-netback: TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy
Date: Sat, 8 Mar 2014 14:37:50 +0000
Message-ID: <531B2B3E.5050800@citrix.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com> <20140307.160552.282750558679341658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	<andrew.bennieston@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140307.160552.282750558679341658.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/03/14 21:05, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Thu, 6 Mar 2014 21:48:22 +0000
>
>> A long known problem of the upstream netback implementation that on the TX
>> path (from guest to Dom0) it copies the whole packet from guest memory into
>> Dom0. That simply became a bottleneck with 10Gb NICs, and generally it's a
>> huge perfomance penalty. The classic kernel version of netback used grant
>> mapping, and to get notified when the page can be unmapped, it used page
>> destructors. Unfortunately that destructor is not an upstreamable solution.
>> Ian Campbell's skb fragment destructor patch series [1] tried to solve this
>> problem, however it seems to be very invasive on the network stack's code,
>> and therefore haven't progressed very well.
>> This patch series use SKBTX_DEV_ZEROCOPY flags to tell the stack it needs to
>> know when the skb is freed up. That is the way KVM solved the same problem,
>> and based on my initial tests it can do the same for us. Avoiding the extra
>> copy boosted up TX throughput from 6.8 Gbps to 7.9 (I used a slower AMD
>> Interlagos box, both Dom0 and guest on upstream kernel, on the same NUMA node,
>> running iperf 2.0.5, and the remote end was a bare metal box on the same 10Gb
>> switch)
>> Based on my investigations the packet get only copied if it is delivered to
>> Dom0 IP stack through deliver_skb, which is due to this [2] patch. This affects
>> DomU->Dom0 IP traffic and when Dom0 does routing/NAT for the guest. That's a bit
>> unfortunate, but luckily it doesn't cause a major regression for this usecase.
>> In the future we should try to eliminate that copy somehow.
>> There are a few spinoff tasks which will be addressed in separate patches:
>> - grant copy the header directly instead of map and memcpy. This should help
>>    us avoiding TLB flushing
>> - use something else than ballooned pages
>> - fix grant map to use page->index properly
>> I've tried to broke it down to smaller patches, with mixed results, so I
>> welcome suggestions on that part as well:
>> 1: Use skb->cb to store pending_idx
>> 2: Some refactoring
>> 3: Change RX path for mapped SKB fragments (moved here to keep bisectability,
>> review it after #4)
>> 4: Introduce TX grant mapping
>> 5: Remove old TX grant copy definitons and fix indentations
>> 6: Add stat counters for zerocopy
>> 7: Handle guests with too many frags
>> 8: Timeout packets in RX path
>> 9: Aggregate TX unmap operations
> Series applied, thanks.
Well, thanks, I'm happy that things moving fast :), but I'm not sure 
it's good to apply a series before the maintainers ack it. As far as 
I've seen neither Wei nor Ian said the final word, and I guess Ian 
didn't had time to finish his review yet. There is an another series 
from Andrew Bennieston which was half-acked by Wei:

"This series looks good enough for me. IIRC Ian said it's still in his 
queue so I will wait for his final review."

Maybe you mixed up mine with that? But that's also not eligible to be 
applied yet.

Zoli
