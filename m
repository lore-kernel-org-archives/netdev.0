From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: suppress warnings on dev_alloc_skb
Date: Wed, 18 May 2016 09:01:38 -0700
Message-ID: <1463587298.18194.129.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33442 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187AbcERQBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:01:40 -0400
Received: by mail-pa0-f66.google.com with SMTP id gh9so5268106pac.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:01:40 -0700 (PDT)
In-Reply-To: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 11:25 -0400, Neil Horman wrote:
> Noticed an allocation failure in a network driver the other day on a 32 bit
> system:
> 
> DMA-API: debugging out of memory - disabling
> bnx2fc: adapter_lookup: hba NULL
> lldpad: page allocation failure. order:0, mode:0x4120
> Pid: 4556, comm: lldpad Not tainted 2.6.32-639.el6.i686.debug #1
> Call Trace:
>  [<c08a4086>] ? printk+0x19/0x23
>  [<c05166a4>] ? __alloc_pages_nodemask+0x664/0x830
>  [<c0649d02>] ? free_object+0x82/0xa0
>  [<fb4e2c9b>] ? ixgbe_alloc_rx_buffers+0x10b/0x1d0 [ixgbe]
>  [<fb4e2fff>] ? ixgbe_configure_rx_ring+0x29f/0x420 [ixgbe]
>  [<fb4e228c>] ? ixgbe_configure_tx_ring+0x15c/0x220 [ixgbe]
>  [<fb4e3709>] ? ixgbe_configure+0x589/0xc00 [ixgbe]
>  [<fb4e7be7>] ? ixgbe_open+0xa7/0x5c0 [ixgbe]
>  [<fb503ce6>] ? ixgbe_init_interrupt_scheme+0x5b6/0x970 [ixgbe]
>  [<fb4e8e54>] ? ixgbe_setup_tc+0x1a4/0x260 [ixgbe]
>  [<fb505a9f>] ? ixgbe_dcbnl_set_state+0x7f/0x90 [ixgbe]
>  [<c088d80d>] ? dcb_doit+0x10ed/0x16d0
> ...


Well, maybe this call site (via ixgbe_configure_rx_ring()) should be
using GFP_KERNEL instead of GFP_ATOMIC.

Otherwise, if you are unlucky, not a single page would be allocated and
RX ring buffer would be empty.

So the 'fix' could be limited to GFP_ATOMIC callers ?

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c413c588a24f854be9e4df78d8a6872b6b1ff9f3..61b923f1520845145a5470d752b278d283cbb348 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2467,7 +2467,7 @@ static inline struct page *__dev_alloc_pages(gfp_t gfp_mask,
 
 static inline struct page *dev_alloc_pages(unsigned int order)
 {
-	return __dev_alloc_pages(GFP_ATOMIC, order);
+	return __dev_alloc_pages(GFP_ATOMIC | __GFP_NOWARN, order);
 }
 
 /**
@@ -2485,7 +2485,7 @@ static inline struct page *__dev_alloc_page(gfp_t gfp_mask)
 
 static inline struct page *dev_alloc_page(void)
 {
-	return __dev_alloc_page(GFP_ATOMIC);
+	return dev_alloc_pages(0);
 }
 
 /**
