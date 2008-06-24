From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/2] net: Fix consumers of skb->queue_mapping to use lower 8
	bits
Date: Tue, 24 Jun 2008 16:28:12 -0700
Message-ID: <20080624232719.11654.97193.stgit@localhost.localdomain>
References: <20080624232545.11654.65805.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22858 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbYFXX2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 19:28:13 -0400
In-Reply-To: <20080624232545.11654.65805.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch will cause the consumers of skb->queue_mapping to only use the
lower 8 bits, so drivers can use the upper 8 bits for CPU index.

Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 include/linux/skbuff.h         |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0d37c90..7b39394 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3244,7 +3244,7 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	len -= skb->data_len;
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-	r_idx = (adapter->num_tx_queues - 1) & skb->queue_mapping;
+	r_idx = (adapter->num_tx_queues - 1) & (skb->queue_mapping & 0xff);
 #endif
 	tx_ring = &adapter->tx_ring[r_idx];
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 299ec4b..0246827 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1672,14 +1672,14 @@ static inline void skb_init_secmark(struct sk_buff *skb)
 static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queue_mapping)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-	skb->queue_mapping = queue_mapping;
+	skb->queue_mapping = (queue_mapping & 0xff);
 #endif
 }
 
 static inline u16 skb_get_queue_mapping(struct sk_buff *skb)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-	return skb->queue_mapping;
+	return (skb->queue_mapping & 0xff);
 #else
 	return 0;
 #endif
@@ -1688,7 +1688,7 @@ static inline u16 skb_get_queue_mapping(struct sk_buff *skb)
 static inline void skb_copy_queue_mapping(struct sk_buff *to, const struct sk_buff *from)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-	to->queue_mapping = from->queue_mapping;
+	to->queue_mapping = (from->queue_mapping & 0xff);
 #endif
 }
 

