From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [Xen-devel] [RFC 21/23] net/xen-netback: Make it running on 64KB
 page granularity
Date: Mon, 18 May 2015 13:11:26 +0100
Message-ID: <5559D6EE.3030400@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
	<1431622863-28575-22-git-send-email-julien.grall@citrix.com>
	<20150515023534.GE19352@zion.uk.xensource.com>	<5555E81E.8070803@citrix.com>
 <20150515153143.GA8521@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <stefano.stabellini@eu.citrix.com>,
	<netdev@vger.kernel.org>, <tim@xen.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Julien Grall <julien.grall@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:39327 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752460AbbERMMC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 08:12:02 -0400
In-Reply-To: <20150515153143.GA8521@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei,

On 15/05/15 16:31, Wei Liu wrote:
> On Fri, May 15, 2015 at 01:35:42PM +0100, Julien Grall wrote:
>> On 15/05/15 03:35, Wei Liu wrote:
>>> On Thu, May 14, 2015 at 06:01:01PM +0100, Julien Grall wrote:
>>>> The PV network protocol is using 4KB page granularity. The goal of this
>>>> patch is to allow a Linux using 64KB page granularity working as a
>>>> network backend on a non-modified Xen.
>>>>
>>>> It's only necessary to adapt the ring size and break skb data in small
>>>> chunk of 4KB. The rest of the code is relying on the grant table code.
>>>>
>>>> Although only simple workload is working (dhcp request, ping). If I try
>>>> to use wget in the guest, it will stall until a tcpdump is started on
>>>> the vif interface in DOM0. I wasn't able to find why.
>>>>
>>>
>>> I think in wget workload you're more likely to break down 64K pages to
>>> 4K pages. Some of your calculation of mfn, offset might be wrong.
>>
>> If so, why tcpdump on the vif interface would make wget suddenly
>> working? Does it make netback use a different path?
> 
> No, but if might make core network component behave differently, this is
> only my suspicion.
> 
> Do you see malformed packets with tcpdump?

I don't see any malformed packets with tcpdump. The connection is stalling
until tcpdump is started on the vif in dom0.

>>
>>>> I have not modified XEN_NETBK_RX_SLOTS_MAX because I wasn't sure what
>>>> it's used for (I have limited knowledge on the network driver).
>>>>
>>>
>>> This is the maximum slots a guest packet can use. AIUI the protocol
>>> still works on 4K granularity (you break 64K page to a bunch of 4K
>>> pages), you don't need to change this.
>>
>> 1 slot = 1 grant right? If so, XEN_NETBK_RX_SLOTS_MAX is based on the
>> number of Linux page. So we would have to get the number for Xen page.
>>
> 
> Yes, 1 slot = 1 grant. I see what you're up to now. Yes, you need to
> change this constant to match underlying HV page.
> 
>> Although, I gave a try to multiple by XEN_PFN_PER_PAGE (4KB/64KB = 16)
>> but it get stuck in the loop.
>>
> 
> I don't follow. What is the new #define? Which loop does it get stuck?


diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 0eda6e9..c2a5402 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -204,7 +204,7 @@ struct xenvif_queue { /* Per-queue data for xenvif */
 /* Maximum number of Rx slots a to-guest packet may use, including the
  * slot needed for GSO meta-data.
  */
-#define XEN_NETBK_RX_SLOTS_MAX (MAX_SKB_FRAGS + 1)
+#define XEN_NETBK_RX_SLOTS_MAX ((MAX_SKB_FRAGS + 1) * XEN_PFN_PER_PAGE)
 
 enum state_bit_shift {
        /* This bit marks that the vif is connected */

The function xenvif_wait_for_rx_work never returns. I guess it's because there
is not enough slot available.

For 64KB page granularity we ask for 16 times more slots than 4KB page
granularity. Although, it's very unlikely that all the slot will be used.

FWIW I pointed out the same problem on blkfront.


>>>
>>>>  		queue->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
>>>>  		queue->tx_copy_ops[*copy_ops].dest.offset =
>>>> -			offset_in_page(skb->data);
>>>> +			offset_in_page(skb->data) & ~XEN_PAGE_MASK;
>>>>  
>>>>  		queue->tx_copy_ops[*copy_ops].len = data_len;
>>>>  		queue->tx_copy_ops[*copy_ops].flags = GNTCOPY_source_gref;
>>>> @@ -1366,8 +1367,8 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
>>>
>>> This function is to coalesce frag_list to a new SKB. It's completely
>>> fine to use the natural granularity of backend domain. The way you
>>> modified it can lead to waste of memory, i.e. you only use first 4K of a
>>> 64K page.
>>
>> Thanks for explaining. I wasn't sure how the function works so I change
>> it for safety. I will redo the change.
>>
>> FWIW, I'm sure there is other place in netback where we waste memory
>> with 64KB page granularity (such as grant table). I need to track them.
>>
>> Let me know if you have some place in mind where the memory usage can be
>> improved.
>>
> 
> I was about to say the mmap_pages array is an array of pages. But that
> probably belongs to grant table driver.

Yes, there is a lot of rework in the grant table driver in order
to avoid wasting memory.

Regards,

-- 
Julien Grall
