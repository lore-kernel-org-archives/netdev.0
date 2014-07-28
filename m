From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/2] net: Header length compution function
Date: Mon, 28 Jul 2014 13:14:10 +0300
Message-ID: <1406542451-8857-2-git-send-email-amirv@mellanox.com>
References: <1406542451-8857-1-git-send-email-amirv@mellanox.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47500 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751811AbaG1KOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 06:14:35 -0400
In-Reply-To: <1406542451-8857-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

This commit is based on Eric Dumazet suggestion.
Use flow dissector to calculate header length.
Tested the following with a mlx4, and it indeed speeds up GRE traffic,
as GRO packets can now contain 17 MSS instead of 8.
(Pulling payload means GRO had to use 2 'frags' per MSS)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/skbuff.h    |  1 +
 net/core/flow_dissector.c | 24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b613557..1f9af4d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3133,6 +3133,7 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
 
 u32 __skb_get_poff(const struct sk_buff *skb);
+u32 eth_frame_headlen(void *data, unsigned int len);
 
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 5f362c1..c3afd27 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -343,6 +343,30 @@ u32 __skb_get_poff(const struct sk_buff *skb)
 	return poff;
 }
 
+
+/* Helper to find length of headers in an ethernet frame.
+ * This can help drivers to pull exact amount of bytes into
+ * skb->head to get optimal GRO performance.
+ * TODO: Could also return rxhash while we do a complete flow dissection.
+ */
+u32 eth_frame_headlen(void *data, unsigned int len)
+{
+	const struct ethhdr *eth = data;
+	struct sk_buff skb;
+
+	if (unlikely(len < ETH_HLEN))
+		return len;
+
+	skb.protocol = eth->h_proto;
+	skb.head = data + ETH_HLEN;
+	skb.data = skb.head;
+	skb_reset_network_header(&skb);
+	skb.len = len - ETH_HLEN;
+	skb.data_len = 0;
+	return __skb_get_poff(&skb) + ETH_HLEN;
+}
+EXPORT_SYMBOL(eth_frame_headlen);
+
 static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_XPS
-- 
1.8.3.4
