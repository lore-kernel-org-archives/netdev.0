From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCHv2] net: suppress warnings on dev_alloc_skb
Date: Thu, 19 May 2016 11:30:54 -0400
Message-ID: <1463671854-26829-1-git-send-email-nhorman@tuxdriver.com>
References: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38897 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140AbcESPbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 11:31:14 -0400
In-Reply-To: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed an allocation failure in a network driver the other day on a 32 bit
system:

DMA-API: debugging out of memory - disabling
bnx2fc: adapter_lookup: hba NULL
lldpad: page allocation failure. order:0, mode:0x4120
Pid: 4556, comm: lldpad Not tainted 2.6.32-639.el6.i686.debug #1
Call Trace:
 [<c08a4086>] ? printk+0x19/0x23
 [<c05166a4>] ? __alloc_pages_nodemask+0x664/0x830
 [<c0649d02>] ? free_object+0x82/0xa0
 [<fb4e2c9b>] ? ixgbe_alloc_rx_buffers+0x10b/0x1d0 [ixgbe]
 [<fb4e2fff>] ? ixgbe_configure_rx_ring+0x29f/0x420 [ixgbe]
 [<fb4e228c>] ? ixgbe_configure_tx_ring+0x15c/0x220 [ixgbe]
 [<fb4e3709>] ? ixgbe_configure+0x589/0xc00 [ixgbe]
 [<fb4e7be7>] ? ixgbe_open+0xa7/0x5c0 [ixgbe]
 [<fb503ce6>] ? ixgbe_init_interrupt_scheme+0x5b6/0x970 [ixgbe]
 [<fb4e8e54>] ? ixgbe_setup_tc+0x1a4/0x260 [ixgbe]
 [<fb505a9f>] ? ixgbe_dcbnl_set_state+0x7f/0x90 [ixgbe]
 [<c088d80d>] ? dcb_doit+0x10ed/0x16d0
...

Thought that perhaps the big splat in the logs wasn't really necessecary, as
all call sites for dev_alloc_skb:

a) check the return code for the function

and

b) either print their own error message or have a recovery path that makes the
warning moot.

Fix it by modifying dev_alloc_pages to pass __GFP_NOWARN as a gfp flag to
suppress the warning

applies to the net tree

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Alexander Duyck <alexander.duyck@gmail.com>

---
Change notes
v2) Modified patch to only apply to dev_alloc_pages, so that callers have the
option to get the warning by using the non-wrapped __dev_alloc_pages as per
suggestion from Eric D.
---
 include/linux/skbuff.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 15d0df9..c93d809 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2457,7 +2457,7 @@ static inline struct page *__dev_alloc_pages(gfp_t gfp_mask,
 
 static inline struct page *dev_alloc_pages(unsigned int order)
 {
-	return __dev_alloc_pages(GFP_ATOMIC, order);
+	return __dev_alloc_pages(GFP_ATOMIC | __GFP_NOWARN, order);
 }
 
 /**
@@ -2475,7 +2475,7 @@ static inline struct page *__dev_alloc_page(gfp_t gfp_mask)
 
 static inline struct page *dev_alloc_page(void)
 {
-	return __dev_alloc_page(GFP_ATOMIC);
+	return dev_alloc_pages(0);
 }
 
 /**
-- 
2.5.5
