From: David Miller <davem@davemloft.net>
Subject: Re: attempted oversize allocations in tcp_recvmsg.
Date: Wed, 28 Dec 2011 14:06:33 -0500 (EST)
Message-ID: <20111228.140633.884619516495494384.davem@davemloft.net>
References: <20111228184416.GB7901@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148Ab1L1TGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 14:06:36 -0500
In-Reply-To: <20111228184416.GB7901@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 28 Dec 2011 13:44:17 -0500

> I got this trace from the page allocator while fuzzing sys_recvfrom
 ...
> The code in tcp_recvmsg that passes down the enormous size has these checks..
> 
>                 if (skb)
>                         available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
>                 if ((available < target) &&
>                     (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
>                     !sysctl_tcp_low_latency &&
>                     dma_find_channel(DMA_MEMCPY)) {
>                         preempt_enable_no_resched();
>                         tp->ucopy.pinned_list =
>                                         dma_pin_iovec_pages(msg->msg_iov, len);
>                 } else {
>                         preempt_enable_no_resched();
>                 }
> 
> I'm guessing there should be a (len < 65535) (or similar constant) in that check ?
> Or should we be doing this even sooner in one of the earlier functions?

I would say that it is dma_pin_iovec_pages()'s job to validate things, since the
fact that it does this kmalloc() whose size is some function of the given length
is it's business.

> Also, when that dma_pin_iovec_pages fails, we still proceed through the rest of
> tcp_recvmsg. Is that expected ? Or should it be doing a goto out; in that case ?

That's fine, we'll just try to process the recvmsg() without using the
DMA memcpy offloading.  It's exactly the same as if we took the else
branch here.

Anyways, please report this to the DMA layer maintainer.

Thanks.
