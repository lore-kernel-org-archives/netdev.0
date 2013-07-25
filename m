From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 1/2] net: Export skb_zerocopy() to zerocopy from one skb to another
Date: Thu, 25 Jul 2013 14:43:44 +0200
Message-ID: <87045a6b80374a9be6a5c37241fed4b97af537cd.1374756042.git.tgraf@suug.ch>
References: <cover.1374756042.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, eric.dumazet@gmail.com
To: davem@davemloft.net, jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37142 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755457Ab3GYMnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 08:43:51 -0400
In-Reply-To: <cover.1374756042.git.tgraf@suug.ch>
In-Reply-To: <cover.1374756042.git.tgraf@suug.ch>
References: <cover.1374756042.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the skb zerocopy logic written for nfnetlink queue available for
use by other modules.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/skbuff.h               |  3 ++
 net/core/skbuff.c                    | 85 ++++++++++++++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c | 59 ++-----------------------
 3 files changed, 92 insertions(+), 55 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5afefa0..2f3c64f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2381,6 +2381,9 @@ extern int             skb_splice_bits(struct sk_buff *skb,
 						unsigned int len,
 						unsigned int flags);
 extern void	       skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
+extern unsigned int    skb_zerocopy_headlen(const struct sk_buff *from);
+extern void	       skb_zerocopy(struct sk_buff *to, const struct sk_buff *from,
+				    int len, int hlen);
 extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
 extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 20e02d2..23736ad 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2111,6 +2111,91 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
 EXPORT_SYMBOL(skb_copy_and_csum_dev);
 
 /**
+ *	skb_zerocopy_headlen - Calculate headroom needed for skb_zerocopy()
+ *	@from: source buffer
+ *
+ *	Calculates the amount of linear headroom needed in the 'to' skb passed
+ *	into skb_zerocopy().
+ */
+unsigned int
+skb_zerocopy_headlen(const struct sk_buff *from)
+{
+	unsigned int hlen = 0;
+
+	if (!from->head_frag ||
+	    skb_headlen(from) < L1_CACHE_BYTES ||
+	    skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
+		hlen = skb_headlen(from);
+
+	if (skb_has_frag_list(from))
+		hlen = from->len;
+
+	return hlen;
+}
+EXPORT_SYMBOL_GPL(skb_zerocopy_headlen);
+
+/**
+ *	skb_zerocopy - Zero copy skb to skb
+ *	@to: destination buffer
+ *	@source: source buffer
+ *	@len: number of bytes to copy from source buffer
+ *	@hlen: size of linear headroom in destination buffer
+ *
+ *	Copies up to `len` bytes from `from` to `to` by creating references
+ *	to the frags in the source buffer.
+ *
+ *	The `hlen` as calculated by skb_zerocopy_headlen() specifies the
+ *	headroom in the `to` buffer.
+ */
+void
+skb_zerocopy(struct sk_buff *to, const struct sk_buff *from, int len, int hlen)
+{
+	int i, j = 0;
+	int plen = 0; /* length of skb->head fragment */
+	struct page *page;
+	unsigned int offset;
+
+	BUG_ON(!from->head_frag && !hlen);
+
+	/* dont bother with small payloads */
+	if (len <= skb_tailroom(to)) {
+		skb_copy_bits(from, 0, skb_put(to, len), len);
+		return;
+	}
+
+	if (hlen) {
+		skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
+		len -= hlen;
+	} else {
+		plen = min_t(int, skb_headlen(from), len);
+		if (plen) {
+			page = virt_to_head_page(from->head);
+			offset = from->data - (unsigned char *)page_address(page);
+			__skb_fill_page_desc(to, 0, page, offset, plen);
+			get_page(page);
+			j = 1;
+			len -= plen;
+		}
+	}
+
+	to->truesize += len + plen;
+	to->len += len + plen;
+	to->data_len += len + plen;
+
+	for (i = 0; i < skb_shinfo(from)->nr_frags; i++) {
+		if (!len)
+			break;
+		skb_shinfo(to)->frags[j] = skb_shinfo(from)->frags[i];
+		skb_shinfo(to)->frags[j].size = min_t(int, skb_shinfo(to)->frags[j].size, len);
+		len -= skb_shinfo(to)->frags[j].size;
+		skb_frag_ref(to, j);
+		j++;
+	}
+	skb_shinfo(to)->nr_frags = j;
+}
+EXPORT_SYMBOL_GPL(skb_zerocopy);
+
+/**
  *	skb_dequeue - remove from the head of the queue
  *	@list: list to dequeue from
  *
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 971ea14..ba539a8 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -235,51 +235,6 @@ nfqnl_flush(struct nfqnl_instance *queue, nfqnl_cmpfn cmpfn, unsigned long data)
 	spin_unlock_bh(&queue->lock);
 }
 
-static void
-nfqnl_zcopy(struct sk_buff *to, const struct sk_buff *from, int len, int hlen)
-{
-	int i, j = 0;
-	int plen = 0; /* length of skb->head fragment */
-	struct page *page;
-	unsigned int offset;
-
-	/* dont bother with small payloads */
-	if (len <= skb_tailroom(to)) {
-		skb_copy_bits(from, 0, skb_put(to, len), len);
-		return;
-	}
-
-	if (hlen) {
-		skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
-		len -= hlen;
-	} else {
-		plen = min_t(int, skb_headlen(from), len);
-		if (plen) {
-			page = virt_to_head_page(from->head);
-			offset = from->data - (unsigned char *)page_address(page);
-			__skb_fill_page_desc(to, 0, page, offset, plen);
-			get_page(page);
-			j = 1;
-			len -= plen;
-		}
-	}
-
-	to->truesize += len + plen;
-	to->len += len + plen;
-	to->data_len += len + plen;
-
-	for (i = 0; i < skb_shinfo(from)->nr_frags; i++) {
-		if (!len)
-			break;
-		skb_shinfo(to)->frags[j] = skb_shinfo(from)->frags[i];
-		skb_shinfo(to)->frags[j].size = min_t(int, skb_shinfo(to)->frags[j].size, len);
-		len -= skb_shinfo(to)->frags[j].size;
-		skb_frag_ref(to, j);
-		j++;
-	}
-	skb_shinfo(to)->nr_frags = j;
-}
-
 static int
 nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet,
 		      bool csum_verify)
@@ -304,7 +259,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 {
 	size_t size;
 	size_t data_len = 0, cap_len = 0;
-	int hlen = 0;
+	unsigned int hlen = 0;
 	struct sk_buff *skb;
 	struct nlattr *nla;
 	struct nfqnl_msg_packet_hdr *pmsg;
@@ -356,14 +311,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		if (data_len > entskb->len)
 			data_len = entskb->len;
 
-		if (!entskb->head_frag ||
-		    skb_headlen(entskb) < L1_CACHE_BYTES ||
-		    skb_shinfo(entskb)->nr_frags >= MAX_SKB_FRAGS)
-			hlen = skb_headlen(entskb);
-
-		if (skb_has_frag_list(entskb))
-			hlen = entskb->len;
-		hlen = min_t(int, data_len, hlen);
+		hlen = skb_zerocopy_headlen(entskb);
+		hlen = min_t(unsigned int, hlen, data_len);
 		size += sizeof(struct nlattr) + hlen;
 		cap_len = entskb->len;
 		break;
@@ -501,7 +450,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		nla->nla_type = NFQA_PAYLOAD;
 		nla->nla_len = nla_attr_size(data_len);
 
-		nfqnl_zcopy(skb, entskb, data_len, hlen);
+		skb_zerocopy(skb, entskb, data_len, hlen);
 	}
 
 	nlh->nlmsg_len = skb->len;
-- 
1.8.3.1
