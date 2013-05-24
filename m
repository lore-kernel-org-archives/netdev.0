From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 1/2] net: Export skb_zerocopy() to zerocopy from one skb to another
Date: Fri, 24 May 2013 16:52:22 +0200
Message-ID: <d209be514b6eff718e0b6562da289faadd014806.1369406826.git.tgraf@suug.ch>
References: <cover.1369406826.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:35558 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab3EXOwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 10:52:30 -0400
In-Reply-To: <cover.1369406826.git.tgraf@suug.ch>
In-Reply-To: <cover.1369406826.git.tgraf@suug.ch>
References: <cover.1369406826.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the skb zerocopy logic written for nfnetlink queue available for
use by other modules.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/skbuff.h               |  2 ++
 net/core/skbuff.c                    | 46 +++++++++++++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c | 47 +-----------------------------------
 3 files changed, 49 insertions(+), 46 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2e0ced1..ff2cbe8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2478,6 +2478,8 @@ extern int             skb_splice_bits(struct sk_buff *skb,
 						unsigned int len,
 						unsigned int flags);
 extern void	       skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
+extern void	       skb_zerocopy(struct sk_buff *to, const struct sk_buff *from,
+				    int len, int hlen);
 extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
 extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d629891..cb60bf6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2118,6 +2118,52 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
 }
 EXPORT_SYMBOL(skb_copy_and_csum_dev);
 
+void
+skb_zerocopy(struct sk_buff *to, const struct sk_buff *from, int len, int hlen)
+{
+	int i, j = 0;
+	int plen = 0; /* length of skb->head fragment */
+	struct page *page;
+	unsigned int offset;
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
 /**
  *	skb_dequeue - remove from the head of the queue
  *	@list: list to dequeue from
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 2e0e835..7ac9dba 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -227,51 +227,6 @@ nfqnl_flush(struct nfqnl_instance *queue, nfqnl_cmpfn cmpfn, unsigned long data)
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
 static int nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet)
 {
 	__u32 flags = 0;
@@ -481,7 +436,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		nla->nla_type = NFQA_PAYLOAD;
 		nla->nla_len = nla_attr_size(data_len);
 
-		nfqnl_zcopy(skb, entskb, data_len, hlen);
+		skb_zerocopy(skb, entskb, data_len, hlen);
 	}
 
 	nlh->nlmsg_len = skb->len;
-- 
1.7.11.7
