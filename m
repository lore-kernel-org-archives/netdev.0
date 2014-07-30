From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH] xen-netfront: Fix handling packets on compound pages with skb_segment
Date: Wed, 30 Jul 2014 14:25:30 +0100
Message-ID: <1406726730-17994-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a long known problem with the netfront/netback interface: if the guest
tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 ring slots,
it gets dropped. The reason is that netback maps these slots to a frag in the
frags array, which is limited by size. Having so many slots can occur since
compound pages were introduced, as the ring protocol slice them up into
individual (non-compound) page aligned slots. The theoretical worst case
scenario looks like this (note, skbs are limited to 64 Kb here):
linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page boundary,
using 2 slots
first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes are at the
end and the beginning of a page, therefore they use 3 * 15 = 45 slots
last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 = 4 slots
Although I don't think this 51 slots skb can really happen, we need a solution
which can deal with every scenario. In real life there is only a few slots
overdue, but usually it causes the TCP stream to be blocked, as the retry will
most likely have the same buffer layout.
This patch solves this problem by slicing up the skb itself with the help of
skb_segment, and calling xennet_start_xmit again on the resulting packets. It
also works with the theoretical worst case, where there is a 3 level recursion.
The good thing is that skb_segment only copies the header part, the frags will
be just referenced again.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <Ian.Campbell@citrix.com>
Cc: Paul Durrant <paul.durrant@citrix.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 055222b..0398240 100644
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 055222b..9ce1b62 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -625,12 +625,37 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 	}
 
+	/* WARNING: this function should be reentrant up until this point, as in
+	 * the below if branch it could be called recursively
+	 */
 	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
-		net_alert_ratelimited(
-			"xennet: skb rides the rocket: %d slots\n", slots);
-		goto drop;
+		struct sk_buff *segs, *nskb;
+		unsigned short gso_size_orig = skb_shinfo(skb)->gso_size;
+		unsigned short gso_type_orig = skb_shinfo(skb)->gso_type;
+
+		net_dbg_ratelimited(
+			"xennet: skb rides the rocket: %d slots, %d bytes\n",
+			slots, skb->len);
+		netdev_features_t features =
+			netif_skb_features(skb) & ~NETIF_F_GSO_MASK;
+		/* Segment this into two pieces, most probably it will fit */
+		skb_shinfo(skb)->gso_size = skb->len / 2 + 1;
+		segs = skb_gso_segment(skb, features);
+		if (unlikely(!segs || IS_ERR(segs)))
+			goto drop;
+		do {
+			nskb = segs;
+			segs = nskb->next;
+			nskb->next = NULL;
+			skb_shinfo(nskb)->gso_size = gso_size_orig;
+			skb_shinfo(nskb)->gso_type = gso_type_orig;
+			xennet_start_xmit(nskb, dev);
+		} while (segs);
+
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&queue->tx_lock, flags);
