From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH RFC] xen-netback: calculate the number of
 slots required for large MTU vifs
Date: Thu, 11 Jul 2013 14:01:01 +0800
Message-ID: <51DE4A1D.8030203@oracle.com>
References: <20130709221406.GA13671@u109add4315675089e695.ant.amazon.com> <1373409659-22383-1-git-send-email-msw@amazon.com> <20130710081333.GI19798@zion.uk.xensource.com> <20130710193703.GB20453@zion.uk.xensource.com> <20130711051441.GA5189@u109add4315675089e695.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, Xi Xiong <xixiong@amazon.com>
To: Matt Wilson <msw@amazon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23563 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904Ab3GKGBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 02:01:16 -0400
In-Reply-To: <20130711051441.GA5189@u109add4315675089e695.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-7-11 13:14, Matt Wilson wrote:
> On Wed, Jul 10, 2013 at 08:37:03PM +0100, Wei Liu wrote:
>> On Wed, Jul 10, 2013 at 09:13:33AM +0100, Wei Liu wrote:
>>> On Tue, Jul 09, 2013 at 10:40:59PM +0000, Matt Wilson wrote:
>>>> From: Xi Xiong <xixiong@amazon.com>
>>>>
>>>> [ note: I've just cherry picked this onto net-next, and only compile
>>>>    tested. This a RFC only. -msw ]
>>>>
>>> Should probably rebase it on net.git because it is a bug fix. Let's
>>> worry about that later...
> *nod*
>
>>>> Currently the number of RX slots required to transmit a SKB to
>>>> xen-netfront can be miscalculated when an interface uses a MTU larger
>>>> than PAGE_SIZE. If the slot calculation is wrong, xen-netback can
>>>> pause the queue indefinitely or reuse slots. The former manifests as a
>>>> loss of connectivity to the guest (which can be restored by lowering
>>>> the MTU set on the interface). The latter manifests with "Bad grant
>>>> reference" messages from Xen such as:
>>>>
>>>> (XEN) grant_table.c:1797:d0 Bad grant reference 264241157
>>>>
>>>> and kernel messages within the guest such as:
>>>>
>>>> [  180.419567] net eth0: Invalid extra type: 112
>>>> [  180.868620] net eth0: rx->offset: 0, size: 4294967295
>>>> [  180.868629] net eth0: rx->offset: 0, size: 4294967295
>>>>
>>>> BUG_ON() assertions can also be hit if RX slots are exhausted while
>>>> handling a SKB.
>>>>
>>>> This patch changes xen_netbk_rx_action() to count the number of RX
>>>> slots actually consumed by netbk_gop_skb() instead of using nr_frags + 1.
>>>> This prevents under-counting the number of RX slots consumed when a
>>>> SKB has a large linear buffer.
>>>>
>>>> Additionally, we now store the estimated number of RX slots required
>>>> to handle a SKB in the cb overlay. This value is used to determine if
>>>> the next SKB in the queue can be processed.
>>>>
>>>> Finally, the logic in start_new_rx_buffer() can cause RX slots to be
>>>> wasted when setting up copy grant table operations for SKBs with large
>>>> linear buffers. For example, a SKB with skb_headlen() equal to 8157
>>>> bytes that starts 64 bytes 64 bytes from the start of the page will
>>> Duplicated "64 bytes". And this change looks like an improvement not a
>>> bug fix. Probably submit a separate patch for this?
> Argh, I knew it was in there somewhere (since you pointed it out in
> Dubin :-).
>
> Maybe it could be a separate patch. I think the description is also a
> bit confusing. I'll work on rewording it.
>
>>>> consume three RX slots instead of two. This patch changes the "head"
>>>> parameter to netbk_gop_frag_copy() to act as a flag. When set,
>>>> start_new_rx_buffer() will always place as much data as possible into
>>>> each RX slot.
>>>>
>>>> Signed-off-by: Xi Xiong <xixiong@amazon.com>
>>>> Reviewed-by: Matt Wilson <msw@amazon.com>
>>>> [ msw: minor code cleanups, rewrote commit message, adjusted code
>>>>    to count RX slots instead of meta structures ]
>>>> Signed-off-by: Matt Wilson <msw@amazon.com>
>>>> Cc: Annie Li <annie.li@oracle.com>
>>>> Cc: Wei Liu <wei.liu2@citrix.com>
>>>> Cc: Ian Campbell <Ian.Campbell@citrix.com>
>>>> Cc: netdev@vger.kernel.org
>>>> Cc: xen-devel@lists.xenproject.org
>>>> ---
>>>>   drivers/net/xen-netback/netback.c |   51 ++++++++++++++++++++++--------------
>>>>   1 files changed, 31 insertions(+), 20 deletions(-)
>>>>
>>>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>>>> index 64828de..82dd207 100644
>>>> --- a/drivers/net/xen-netback/netback.c
>>>> +++ b/drivers/net/xen-netback/netback.c
>>>> @@ -110,6 +110,11 @@ union page_ext {
>>>>   	void *mapping;
>>>>   };
>>>>   
>>>> +struct skb_cb_overlay {
>>>> +	int meta_slots_used;
>>>> +	int peek_slots_count;
>>>> +};
>>>> +
>>>>   struct xen_netbk {
>>>>   	wait_queue_head_t wq;
>>>>   	struct task_struct *task;
>>>> @@ -370,6 +375,7 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
>>>>   {
>>>>   	unsigned int count;
>>>>   	int i, copy_off;
>>>> +	struct skb_cb_overlay *sco;
>>>>   
>>>>   	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
>>>>   
>>>> @@ -411,6 +417,9 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
>>>>   				offset = 0;
>>>>   		}
>>>>   	}
>>>> +
>>>> +	sco = (struct skb_cb_overlay *) skb->cb;
>>>> +	sco->peek_slots_count = count;
>>>>   	return count;
>>>>   }
>>>>   
>>>> @@ -443,13 +452,12 @@ static struct netbk_rx_meta *get_next_rx_buffer(struct xenvif *vif,
>>>>   }
>>>>   
>>>>   /*
>>>> - * Set up the grant operations for this fragment. If it's a flipping
>>>> - * interface, we also set up the unmap request from here.
>>>> + * Set up the grant operations for this fragment.
>>>>    */
>>>>   static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>>>>   				struct netrx_pending_operations *npo,
>>>>   				struct page *page, unsigned long size,
>>>> -				unsigned long offset, int *head)
>>>> +				unsigned long offset, int head, int *first)
>>>>   {
>>>>   	struct gnttab_copy *copy_gop;
>>>>   	struct netbk_rx_meta *meta;
>>>> @@ -479,12 +487,12 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>>>>   		if (bytes > size)
>>>>   			bytes = size;
>>>>   
>>>> -		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
>>>> +		if (start_new_rx_buffer(npo->copy_off, bytes, head)) {

head is always 1 here when processing the header data, so it is 
impossible to start a new buffer for header data with larger header 
size, and get_next_rx_buffer is never called. I assume this would not 
work well for skb with larger header data size. Have you run network 
test with this patch?

>>>>   			/*
>>>>   			 * Netfront requires there to be some data in the head
>>>>   			 * buffer.
>>>>   			 */
>>>> -			BUG_ON(*head);
>>>> +			BUG_ON(*first);
>>>>   
>>>>   			meta = get_next_rx_buffer(vif, npo);
>>>>   		}
snip...
>>>> Comments?
> I think that this patch addresses the problem more completely. Annie?

See my comments above, I am curious whether the header data is processed 
correctly.:-)

Thanks
Annie
