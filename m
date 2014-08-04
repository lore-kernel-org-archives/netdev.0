From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH] xen-netfront: Fix handling packets on compound pages
 with skb_segment
Date: Mon, 4 Aug 2014 18:29:34 +0100
Message-ID: <53DFC2FE.8070105@citrix.com>
References: <1406726730-17994-1-git-send-email-zoltan.kiss@citrix.com> <20140731.132520.1889577477638334755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <konrad.wilk@oracle.com>, <boris.ostrovsky@oracle.com>,
	<david.vrabel@citrix.com>, <wei.liu2@citrix.com>,
	<Ian.Campbell@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42667 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaHDR3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 13:29:38 -0400
In-Reply-To: <20140731.132520.1889577477638334755.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/07/14 21:25, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Wed, 30 Jul 2014 14:25:30 +0100
>
>> There is a long known problem with the netfront/netback interface: if the guest
>> tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 ring slots,
>> it gets dropped. The reason is that netback maps these slots to a frag in the
>> frags array, which is limited by size. Having so many slots can occur since
>> compound pages were introduced, as the ring protocol slice them up into
>> individual (non-compound) page aligned slots. The theoretical worst case
>> scenario looks like this (note, skbs are limited to 64 Kb here):
>> linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page boundary,
>> using 2 slots
>> first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes are at the
>> end and the beginning of a page, therefore they use 3 * 15 = 45 slots
>> last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 = 4 slots
>> Although I don't think this 51 slots skb can really happen, we need a solution
>> which can deal with every scenario. In real life there is only a few slots
>> overdue, but usually it causes the TCP stream to be blocked, as the retry will
>> most likely have the same buffer layout.
>> This patch solves this problem by slicing up the skb itself with the help of
>> skb_segment, and calling xennet_start_xmit again on the resulting packets. It
>> also works with the theoretical worst case, where there is a 3 level recursion.
>> The good thing is that skb_segment only copies the header part, the frags will
>> be just referenced again.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>
> This is a really scary change :-)
I admit that :)
>
> I definitely see some potential problem here.
>
> First of all, even in cases where it might "work", such as TCP, you
> are modifying the data stream.  The sizes are changing, the packet
> counts are different, and all of this will have side effects such as
> potentially harming TCP performance.
>
> Secondly, for something like UDP you can't just split the packet up
> like this, or for any other datagram protocol for that matter.
The netback/netfront interface currently only supports TSO and TSO6. 
That's why I did the pktgen TCP patch
>
> I know you're in a difficult situation, but I just can't see this
> being an acceptable approach to solving the problem right now.
>
> Where does the MAX_SKB_FRAGS + 1 limit really come from, the size of
> the TX queue?
>
> If you were to have a 64-slot TX queue, you ought to be able to handle
> this theoretical 51 slot SKB.
Let me step a bit back to explain the situation:
There is a shared ring buffer between netfront and netback. The frontend 
posts requests with grant references plus offset-size pairs. A grant 
reference points to a page, which is limited by PAGE_SIZE. The frontend 
slice up the skb's linear buffer and frags array into "slots", each of 
them is a triplet mentioned above.
If the linear buffer or a frag is on a compound page and overlaps page 
boundary, it is posted as separate buffers. E.g if it starts at offset 
4000 with a size of 400 bytes, it will consume 2 slots. Unfortunately 
the grant mapping interface can't map compound pages into an another 
domain. The main problem is that those pages are only adjacent in the 
frontend's memory space, but not in the backend or DMA space, so even if 
you map them to adjacent backend pages (which would need a lot of 
change), you either need SWIOTLB (expensive, and backend pays the cost) 
or IOMMU (still don't work).
Currently netback limits each skb sent through to 18 slots, because it 
has to map every grant ref to a frag. There was an idea to handle this 
problem by removing this limit and let the backend coalesce the 
scattered buffers into a brand new piece, but then the backend would pay 
the price, and it would be huge as most of the packet should be copied.
We haven't seen this problem very often, and it's also a bit hard to 
reproduce (hence my frag offset-size pktgen patches), but we can't 
afford the assumption that it won't happen very often. Also, it is 
required that the guest should pay the price if it sends packets in such 
buffers, not the backend.

The main concept in this solution is that if it turns out the packet 
needs too many slots in start_xmit, pretend that netfront is not GSO 
capable, and fall back to the software segmentation, which will result 
in packets which can fit. It mimics as if we would go back to 
dev_hard_start_xmit, to the place where it calls dev_gso_segment(), but 
the gso_size is set temporarily to (skb->len / 2 + 1) to avoid creating 
too many packets. It can also happen recursively, if the resulting 
packets are still too big slotwise.
As far as I know it's not really possible to push back an skb to QDisc 
from start_xmit. If it is, that would be a more elegant solution for 
this problem.

>
> And I don't think it's so theoretical, a carefully crafted sequence of
> sendfile() calls during a TCP_CORK sequence should be able to do it.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
