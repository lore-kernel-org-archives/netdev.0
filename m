From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 6/7] Staging: Octeon Ethernet: Enable scatter-gather.
Date: Thu,  7 Jan 2010 11:05:05 -0800
Message-ID: <1262891106-32146-6-git-send-email-ddaney@caviumnetworks.com>
References: <4B463005.8060505@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:17174 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383Ab0AGTGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:06:02 -0500
In-Reply-To: <4B463005.8060505@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octeon ethernet hardware can handle NETIF_F_SG, so we enable it.

A gather list of up to six fragments will fit in the SKB's CB
structure, so no extra memory is required.  If a SKB has more than six
fragments, we must linearize it.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/ethernet-tx.c |   57 +++++++++++++++++++++++++++++----
 drivers/staging/octeon/ethernet.c    |    7 +++-
 2 files changed, 55 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 05b58f8..bc67e41 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -53,6 +53,8 @@
 
 #include "cvmx-gmxx-defs.h"
 
+#define CVM_OCT_SKB_CB(skb)	((u64 *)((skb)->cb))
+
 /*
  * You can define GET_SKBUFF_QOS() to override how the skbuff output
  * function determines which output queue is used. The default
@@ -121,6 +123,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	uint64_t old_scratch;
 	uint64_t old_scratch2;
 	int qos;
+	int i;
 	enum {QUEUE_CORE, QUEUE_HW, QUEUE_DROP} queue_type;
 	struct octeon_ethernet *priv = netdev_priv(dev);
 	struct sk_buff *to_free_list;
@@ -171,6 +174,28 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/*
+	 * We have space for 6 segment pointers, If there will be more
+	 * than that, we must linearize.
+	 */
+	if (unlikely(skb_shinfo(skb)->nr_frags > 5)) {
+		if (unlikely(__skb_linearize(skb))) {
+			queue_type = QUEUE_DROP;
+			if (USE_ASYNC_IOBDMA) {
+				/* Get the number of skbuffs in use by the hardware */
+				CVMX_SYNCIOBDMA;
+				skb_to_free = cvmx_scratch_read64(CVMX_SCR_SCRATCH);
+			} else {
+				/* Get the number of skbuffs in use by the hardware */
+				skb_to_free = cvmx_fau_fetch_and_add32(priv->fau + qos * 4,
+								       MAX_SKB_TO_FREE);
+			}
+			skb_to_free = cvm_oct_adjust_skb_to_free(skb_to_free, priv->fau + qos * 4);
+			spin_lock_irqsave(&priv->tx_free_list[qos].lock, flags);
+			goto skip_xmit;
+		}
+	}
+
+	/*
 	 * The CN3XXX series of parts has an errata (GMX-401) which
 	 * causes the GMX block to hang if a collision occurs towards
 	 * the end of a <68 byte packet. As a workaround for this, we
@@ -198,13 +223,6 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	/* Build the PKO buffer pointer */
-	hw_buffer.u64 = 0;
-	hw_buffer.s.addr = cvmx_ptr_to_phys(skb->data);
-	hw_buffer.s.pool = 0;
-	hw_buffer.s.size =
-	    (unsigned long)skb_end_pointer(skb) - (unsigned long)skb->head;
-
 	/* Build the PKO command */
 	pko_command.u64 = 0;
 	pko_command.s.n2 = 1;	/* Don't pollute L2 with the outgoing packet */
@@ -215,6 +233,31 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	pko_command.s.dontfree = 1;
 	pko_command.s.reg0 = priv->fau + qos * 4;
+
+	/* Build the PKO buffer pointer */
+	hw_buffer.u64 = 0;
+	if (skb_shinfo(skb)->nr_frags == 0) {
+		hw_buffer.s.addr = XKPHYS_TO_PHYS((u64)skb->data);
+		hw_buffer.s.pool = 0;
+		hw_buffer.s.size = skb->len;
+	} else {
+		hw_buffer.s.addr = XKPHYS_TO_PHYS((u64)skb->data);
+		hw_buffer.s.pool = 0;
+		hw_buffer.s.size = skb_headlen(skb);
+		CVM_OCT_SKB_CB(skb)[0] = hw_buffer.u64;
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			struct skb_frag_struct *fs = skb_shinfo(skb)->frags + i;
+			hw_buffer.s.addr = XKPHYS_TO_PHYS((u64)(page_address(fs->page) + fs->page_offset));
+			hw_buffer.s.size = fs->size;
+			CVM_OCT_SKB_CB(skb)[i + 1] = hw_buffer.u64;
+		}
+		hw_buffer.s.addr = XKPHYS_TO_PHYS((u64)CVM_OCT_SKB_CB(skb));
+		hw_buffer.s.size = skb_shinfo(skb)->nr_frags + 1;
+		pko_command.s.segs = skb_shinfo(skb)->nr_frags + 1;
+		pko_command.s.gather = 1;
+		goto dont_put_skbuff_in_hw;
+	}
+
 	/*
 	 * See if we can put this skb in the FPA pool. Any strange
 	 * behavior from the Linux networking stack will most likely
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 9f5b741..9d63202 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -484,8 +484,11 @@ int cvm_oct_common_init(struct net_device *dev)
 	    && (always_use_pow || strstr(pow_send_list, dev->name)))
 		priv->queue = -1;
 
-	if (priv->queue != -1 && USE_HW_TCPUDP_CHECKSUM)
-		dev->features |= NETIF_F_IP_CSUM;
+	if (priv->queue != -1) {
+		dev->features |= NETIF_F_SG;
+		if (USE_HW_TCPUDP_CHECKSUM)
+			dev->features |= NETIF_F_IP_CSUM;
+	}
 
 	/* We do our own locking, Linux doesn't need to */
 	dev->features |= NETIF_F_LLTX;
-- 
1.6.0.6

