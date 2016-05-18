From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] net: suppress warnings on dev_alloc_skb
Date: Wed, 18 May 2016 11:25:24 -0400
Message-ID: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52757 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465AbcERPZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 11:25:47 -0400
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

So, I added __GFP_NOWARN to the gfp_flags, to be added unless DEBUG was enabled,
in which case getting the splat makes a bit more sense

applies to the net tree

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 include/linux/skbuff.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 15d0df9..8e61fe7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2452,6 +2452,10 @@ static inline struct page *__dev_alloc_pages(gfp_t gfp_mask,
 	 */
 	gfp_mask |= __GFP_COLD | __GFP_COMP | __GFP_MEMALLOC;
 
+#ifndef DEBUG
+	gfp_mask |= __GFP_NOWARN;
+#endif
+
 	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
 }
 
-- 
2.5.5
