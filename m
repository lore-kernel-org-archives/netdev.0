From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [Xen-devel] [RFC 21/23] net/xen-netback: Make it running on 64KB
 page granularity
Date: Tue, 19 May 2015 23:56:39 +0100
Message-ID: <555BBFA7.8030502@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
	<1431622863-28575-22-git-send-email-julien.grall@citrix.com>
	<20150515023534.GE19352@zion.uk.xensource.com>	<5555E81E.8070803@citrix.com>
	<20150515153143.GA8521@zion.uk.xensource.com>	<5559D6EE.3030400@citrix.com>
 <20150518125406.GA9503@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julien Grall <julien.grall@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <netdev@vger.kernel.org>,
	<tim@xen.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:7959 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942AbbESW4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 18:56:42 -0400
In-Reply-To: <20150518125406.GA9503@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 18/05/2015 13:54, Wei Liu wrote:
> On Mon, May 18, 2015 at 01:11:26PM +0100, Julien Grall wrote:
>> On 15/05/15 16:31, Wei Liu wrote:
>>> On Fri, May 15, 2015 at 01:35:42PM +0100, Julien Grall wrote:
>>>> On 15/05/15 03:35, Wei Liu wrote:
>>>>> On Thu, May 14, 2015 at 06:01:01PM +0100, Julien Grall wrote:
>>>>>> The PV network protocol is using 4KB page granularity. The goal of this
>>>>>> patch is to allow a Linux using 64KB page granularity working as a
>>>>>> network backend on a non-modified Xen.
>>>>>>
>>>>>> It's only necessary to adapt the ring size and break skb data in small
>>>>>> chunk of 4KB. The rest of the code is relying on the grant table code.
>>>>>>
>>>>>> Although only simple workload is working (dhcp request, ping). If I try
>>>>>> to use wget in the guest, it will stall until a tcpdump is started on
>>>>>> the vif interface in DOM0. I wasn't able to find why.
>>>>>>
>>>>>
>>>>> I think in wget workload you're more likely to break down 64K pages to
>>>>> 4K pages. Some of your calculation of mfn, offset might be wrong.
>>>>
>>>> If so, why tcpdump on the vif interface would make wget suddenly
>>>> working? Does it make netback use a different path?
>>>
>>> No, but if might make core network component behave differently, this is
>>> only my suspicion.
>>>
>>> Do you see malformed packets with tcpdump?
>>
>> I don't see any malformed packets with tcpdump. The connection is stalling
>> until tcpdump is started on the vif in dom0.
>>
>
> Hmm... Don't have immediate idea about this.
>
> Ian said skb_orphan is called with tcpdump. If I remember correct that
> would trigger the callback to release the slots in netback. It could be
> that other part of Linux is holding onto the skbs for too long.
>
> If you're wgetting from another host, I would suggest wgetting from Dom0
> to limit the problem between Dom0 and DomU.

Thanks to Wei, I was able to narrow the problem. It looks like the 
problem is not coming from netback but somewhere else down in the 
network stack: wget/ssh between Dom0 64KB and DomU is working fine.

Although, wget/ssh between a guest and an external host doesn't work 
when Dom0 is using 64KB page granularity unless if I start a tcpdump on 
the vif in DOM0. Anyone an idea?

I have no issue to wget/ssh in DOM0 to an external host and the same 
kernel with 4KB page granularity (i.e same source code but rebuilt with 
4KB) doesn't show any issue with wget/ssh in the guest.

This has been tested on AMD Seattle, the guest kernel is the same on 
every test (4KB page granularity).

I'm planning to give a try tomorrow on X-gene (ARM64 board and I think 
64KB page granularity is supported) to see if I can reproduce the bug.

>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>> index 0eda6e9..c2a5402 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -204,7 +204,7 @@ struct xenvif_queue { /* Per-queue data for xenvif */
>>   /* Maximum number of Rx slots a to-guest packet may use, including the
>>    * slot needed for GSO meta-data.
>>    */
>> -#define XEN_NETBK_RX_SLOTS_MAX (MAX_SKB_FRAGS + 1)
>> +#define XEN_NETBK_RX_SLOTS_MAX ((MAX_SKB_FRAGS + 1) * XEN_PFN_PER_PAGE)
>>
>>   enum state_bit_shift {
>>          /* This bit marks that the vif is connected */
>>
>> The function xenvif_wait_for_rx_work never returns. I guess it's because there
>> is not enough slot available.
>>
>> For 64KB page granularity we ask for 16 times more slots than 4KB page
>> granularity. Although, it's very unlikely that all the slot will be used.
>>
>> FWIW I pointed out the same problem on blkfront.
>>
>
> This is not going to work. The ring in netfront / netback has only 256
> slots. Now you ask for netback to reserve more than 256 slots -- (17 +
> 1) * (64 / 4) = 288, which can never be fulfilled. See the call to
> xenvif_rx_ring_slots_available.
>
> I think XEN_NETBK_RX_SLOTS_MAX derived from the fact the each packet to
> the guest cannot be larger than 64K. So you might be able to
>
> #define XEN_NETBK_RX_SLOTS_MAX ((65536 / XEN_PAGE_SIZE) + 1)

I didn't know that packet cannot be larger than 64KB. That's simply a 
lot the problem.

>
> Blk driver may have a different story. But the default ring size (1
> page) yields even less slots than net (given that sizeof(union(req/rsp))
> is larger IIRC).

I will see with Roger for Blkback.


-- 
Julien Grall
