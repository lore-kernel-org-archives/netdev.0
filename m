From: atomlin@redhat.com
Subject: [Patch v1] skbuff: Hide GFP_ATOMIC page allocation failures for dropped packets
Date: Sun, 26 May 2013 14:17:21 +0100
Message-ID: <1369574241-21397-1-git-send-email-atomlin@redhat.com>
Cc: davem@davemloft.net, edumazet@google.com, pshelar@nicira.com,
	mst@redhat.com, alexander.h.duyck@intel.com,
	linux-kernel@vger.kernel.org, Aaron Tomlin <atomlin@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aaron Tomlin <atomlin@redhat.com>

Failed GFP_ATOMIC allocations by the network stack result in dropped
packets, which will be received on a subsequent retransmit, and an
unnecessary, noisy warning with a kernel backtrace.

These warnings are harmless, but they still cause users to panic and
file bug reports over dropped packets. It would be better to hide the
failed allocation warnings and backtraces, and let retransmits handle
dropped packets quietly.

Signed-off-by: Aaron Tomlin <atomlin@redhat.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index af9185d..02139d6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -236,7 +236,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		? skbuff_fclone_cache : skbuff_head_cache;
 
 	if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
-		gfp_mask |= __GFP_MEMALLOC;
+		gfp_mask |= (__GFP_MEMALLOC|__GFP_NOWARN);
 
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
-- 
1.8.1.4
