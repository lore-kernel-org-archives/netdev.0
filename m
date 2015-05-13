From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] net: Reserve skb headroom and set skb->dev even if
 using __alloc_skb
Date: Wed, 13 May 2015 13:34:13 -0700
Message-ID: <20150513203413.8252.98057.stgit@ahduyck-vm-fedora22>
References: <20150513182738.GA28201@saruman.tx.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org, balbi@ti.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150513182738.GA28201@saruman.tx.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When I had inlined __alloc_rx_skb into __netdev_alloc_skb and
__napi_alloc_skb I had overlooked the fact that there was a return in the
__alloc_rx_skb.  As a result we weren't reserving headroom or setting the
skb->dev in certain cases.  This change corrects that by adding a couple of
jump labels to jump to depending on __alloc_skb either succeeding or failing.

Fixes: 9451980a6646 ("net: Use cached copy of pfmemalloc to avoid accessing page")
Reported-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/core/skbuff.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d67e612bf0ef..f3fe9bd9e672 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -414,8 +414,12 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
 	len += NET_SKB_PAD;
 
 	if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
-	    (gfp_mask & (__GFP_WAIT | GFP_DMA)))
-		return __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
+	    (gfp_mask & (__GFP_WAIT | GFP_DMA))) {
+		skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
+		if (!skb)
+			goto skb_fail;
+		goto skb_success;
+	}
 
 	len += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	len = SKB_DATA_ALIGN(len);
@@ -445,9 +449,11 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
 		skb->pfmemalloc = 1;
 	skb->head_frag = 1;
 
+skb_success:
 	skb_reserve(skb, NET_SKB_PAD);
 	skb->dev = dev;
 
+skb_fail:
 	return skb;
 }
 EXPORT_SYMBOL(__netdev_alloc_skb);
@@ -475,8 +481,12 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 	len += NET_SKB_PAD + NET_IP_ALIGN;
 
 	if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
-	    (gfp_mask & (__GFP_WAIT | GFP_DMA)))
-		return __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
+	    (gfp_mask & (__GFP_WAIT | GFP_DMA))) {
+		skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
+		if (!skb)
+			goto skb_fail;
+		goto skb_success;
+	}
 
 	len += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	len = SKB_DATA_ALIGN(len);
@@ -499,9 +509,11 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 		skb->pfmemalloc = 1;
 	skb->head_frag = 1;
 
+skb_success:
 	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
 	skb->dev = napi->dev;
 
+skb_fail:
 	return skb;
 }
 EXPORT_SYMBOL(__napi_alloc_skb);
