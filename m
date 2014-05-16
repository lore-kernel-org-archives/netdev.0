From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it occupies
 too many slots
Date: Fri, 16 May 2014 17:29:05 +0100
Message-ID: <53763CD1.6060500@citrix.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com> <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com> <20140516131145.GK18551@zion.uk.xensource.com> <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com> <20140516143653.GL18551@zion.uk.xensource.com> <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com> <20140516153452.GM18551@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>
To: Wei Liu <wei.liu2@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30641 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbaEPQ3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 12:29:09 -0400
In-Reply-To: <20140516153452.GM18551@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/05/14 16:34, Wei Liu wrote:
> On Fri, May 16, 2014 at 08:22:19AM -0700, Eric Dumazet wrote:
>> On Fri, 2014-05-16 at 15:36 +0100, Wei Liu wrote:
>>> On Fri, May 16, 2014 at 07:21:08AM -0700, Eric Dumazet wrote:
>>>> On Fri, 2014-05-16 at 14:11 +0100, Wei Liu wrote:
>>>>
>>>>> It's not that common to trigger this, I only saw a few reports. In fact
>>>>> Stefan's report is the first one that comes with a method to reproduce
>>>>> it.
>>>>>
>>>>> I tested with redis-benchmark on a guest with 256MB RAM and only saw a
>>>>> few "failed to linearize", never saw a single one with 1GB guest.
>>>>
>>>> Well, I am just saying. This is asking order-5 allocations, and yes,
>>>> this is going to fail after few days of uptime, no matter what you try.
>>>>
>>>
>>> Hmm... I see what you mean -- memory fragmentation leads to allocation
>>> failure. Thanks.
>>
>> In the mean time, have you tried to lower gso_max_size ?
>>
>> Setting it witk netif_set_gso_max_size() to something like 56000 might
>> avoid the problem.
>>
>> (Not sure if it is applicable in your case)
>>
> 
> It works, at least in this Redis testcase. Could you explain a bit where
> this 56000 magic number comes from? :-)
> 
> Presumably I can derive it from some constant in core network code?

I guess it just makes more unlikely to have packets with problematic layout. But the following packet would still fail:
linear buffer : 80 bytes, on 2 pages
17 frags, 80 bytes each, each spanning over page boundary.

I just had an idea: a modified version of xenvif_handle_frag_list function from netback would be useful for us here. It recreates the frags array on fully utilized 4k pages. Plus we can use pskb_expand_head to reduce the page number on the linear buffer (although it might not work, see my comment in the patch)
The worst case linear buffer then spans N+1 pages, and has N*PAGE_SIZE+1 bytes. Then the frags after this coalescing should have 16*PAGE_SIZE - (N*PAGE_SIZE+2) bytes at most, which is 16-N pages. Altogether that's 16+1 page, which should definitely fit!
This is what I mean:

8<--------------
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 158b5e6..b1133d6 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -544,6 +544,73 @@ static int xennet_count_skb_frag_slots(struct sk_buff *skb)
 	return pages;
 }
 
+int xenvif_reduce_pages(struct sk_buff *skb, int target)
+{
+	unsigned int offset = skb_headlen(skb);
+	skb_frag_t frags[MAX_SKB_FRAGS];
+	int newfrags, oldfrags;
+	unsigned int pages, optimal;
+
+	BUG_ON(!target);
+
+	pages = DIV_ROUND_UP(offset_in_page(skb->data) + skb_headlen(skb), PAGE_SIZE);
+	optimal = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
+	if (pages - optimal) {
+		int err;
+/* FIXME: we should check if pskb_expand_head really allocates on page boundary,
+ *  otherwise we can still have suboptimal page layout */
+		if (unlikely(err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+			return err;
+		target -= pages - optimal;
+		if (!target)
+			return 0;
+	}
+
+	/* Subtract frags size, we will correct it later */
+	skb->truesize -= skb->data_len;
+
+	/* Create a brand new frags array and coalesce there */
+	for (newfrags = 0; offset < skb->len; newfrags++) {
+		struct page *page;
+		unsigned int len;
+
+		BUG_ON(newfrags >= MAX_SKB_FRAGS);
+		page = alloc_page(GFP_ATOMIC);
+		if (!page) {
+			int j;
+			skb->truesize += skb->data_len;
+			for (j = 0; j < newfrags; j++)
+				put_page(frags[j].page.p);
+			return -ENOMEM;
+		}
+
+		if (offset + PAGE_SIZE < skb->len)
+			len = PAGE_SIZE;
+		else
+			len = skb->len - offset;
+		if (skb_copy_bits(skb, offset, page_address(page), len))
+			BUG();
+
+		offset += len;
+		frags[newfrags].page.p = page;
+		frags[newfrags].page_offset = 0;
+		skb_frag_size_set(&frags[newfrags], len);
+	}
+
+	/* Drop the original buffers */
+	for (oldfrags = 0; oldfrags < skb_shinfo(skb)->nr_frags; oldfrags++)
+		skb_frag_unref(skb, oldfrags);
+
+	/* Swap the new frags array with the old one */
+	memcpy(skb_shinfo(skb)->frags,
+	       frags,
+	       newfrags * sizeof(skb_frag_t));
+	skb_shinfo(skb)->nr_frags = newfrags;
+	/* Correct truesize */
+	skb->truesize += newfrags * PAGE_SIZE;
+	return 0;
+}
+
 static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned short id;
@@ -573,11 +640,21 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
-		net_alert_ratelimited(
-			"xennet: skb rides the rocket: %d slots\n", slots);
-		goto drop;
+		if (unlikely(xenvif_reduce_pages(skb, slots - MAX_SKB_FRAGS - 1))) {
+			net_alert_ratelimited(
+				"xennet: couldn't reduce slot number from %d\n", slots);
+			goto drop;
+		}
+		slots = DIV_ROUND_UP(offset_in_page(data) + len, PAGE_SIZE) +
+			xennet_count_skb_frag_slots(skb);
+		if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
+			net_alert_ratelimited(
+				"xennet: slot reduction doesn't work, slots: %d\n", slots);
+			goto drop;
+		}
 	}
 
+
 	spin_lock_irqsave(&np->tx_lock, flags);
 
 	if (unlikely(!netif_carrier_ok(dev) ||
