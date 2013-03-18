From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH nf-next] netfilter: nfnetlink_queue: zero copy support
Date: Sun, 17 Mar 2013 20:15:55 -0700
Message-ID: <1363576555.29475.122.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:51173 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab3CRDP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 23:15:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

nfqnl_build_packet_message() actually copy the packet
inside the netlink message, while it can instead use
zero copy.

Make sure the skb 'copy' is the last component of the
cooked netlink message, as we cant add anything after it.

Patch cooked in Copenhagen at Netfilter Workshop ;)

Still to be addressed in separate patches :

-GRO/GSO packets are segmented in nf_queue()
and checksummed in nfqnl_build_packet_message().

Proper support for GSO/GRO packets (no segmentation,
and no checksumming) needs application cooperation, if we
want no regressions.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/nfnetlink_queue_core.c |   94 +++++++++++++++++++------
 1 file changed, 72 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 858fd52..388fb8ba3 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -217,14 +217,59 @@ nfqnl_flush(struct nfqnl_instance *queue, nfqnl_cmpfn cmpfn, unsigned long data)
 	spin_unlock_bh(&queue->lock);
 }
 
+static void
+nfqnl_zcopy(struct sk_buff *to, const struct sk_buff *from, int len, int hlen)
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
+
 static struct sk_buff *
 nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			   struct nf_queue_entry *entry,
 			   __be32 **packet_id_ptr)
 {
-	sk_buff_data_t old_tail;
 	size_t size;
 	size_t data_len = 0, cap_len = 0;
+	int hlen = 0;
 	struct sk_buff *skb;
 	struct nlattr *nla;
 	struct nfqnl_msg_packet_hdr *pmsg;
@@ -246,8 +291,10 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 #endif
 		+ nla_total_size(sizeof(u_int32_t))	/* mark */
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hw))
-		+ nla_total_size(sizeof(struct nfqnl_msg_packet_timestamp)
-		+ nla_total_size(sizeof(u_int32_t)));	/* cap_len */
+		+ nla_total_size(sizeof(u_int32_t));	/* cap_len */
+
+	if (entskb->tstamp.tv64)
+		size += nla_total_size(sizeof(struct nfqnl_msg_packet_timestamp));
 
 	outdev = entry->outdev;
 
@@ -265,7 +312,16 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		if (data_len == 0 || data_len > entskb->len)
 			data_len = entskb->len;
 
-		size += nla_total_size(data_len);
+
+		if (!entskb->head_frag ||
+		    skb_headlen(entskb) < L1_CACHE_BYTES ||
+		    skb_shinfo(entskb)->nr_frags >= MAX_SKB_FRAGS)
+			hlen = skb_headlen(entskb);
+
+		if (skb_has_frag_list(entskb))
+			hlen = entskb->len;
+		hlen = min_t(int, data_len, hlen);
+		size += sizeof(struct nlattr) + hlen;
 		cap_len = entskb->len;
 		break;
 	}
@@ -277,7 +333,6 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (!skb)
 		return NULL;
 
-	old_tail = skb->tail;
 	nlh = nlmsg_put(skb, 0, 0,
 			NFNL_SUBSYS_QUEUE << 8 | NFQNL_MSG_PACKET,
 			sizeof(struct nfgenmsg), 0);
@@ -382,31 +437,26 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			goto nla_put_failure;
 	}
 
+	if (ct && nfqnl_ct_put(skb, ct, ctinfo) < 0)
+		goto nla_put_failure;
+
+	if (cap_len > 0 && nla_put_be32(skb, NFQA_CAP_LEN, htonl(cap_len)))
+		goto nla_put_failure;
+
 	if (data_len) {
 		struct nlattr *nla;
-		int sz = nla_attr_size(data_len);
 
-		if (skb_tailroom(skb) < nla_total_size(data_len)) {
-			printk(KERN_WARNING "nf_queue: no tailroom!\n");
-			kfree_skb(skb);
-			return NULL;
-		}
+		if (skb_tailroom(skb) < sizeof(*nla) + hlen)
+			goto nla_put_failure;
 
-		nla = (struct nlattr *)skb_put(skb, nla_total_size(data_len));
+		nla = (struct nlattr *)skb_put(skb, sizeof(*nla));
 		nla->nla_type = NFQA_PAYLOAD;
-		nla->nla_len = sz;
+		nla->nla_len = nla_attr_size(data_len);
 
-		if (skb_copy_bits(entskb, 0, nla_data(nla), data_len))
-			BUG();
+		nfqnl_zcopy(skb, entskb, data_len, hlen);
 	}
 
-	if (ct && nfqnl_ct_put(skb, ct, ctinfo) < 0)
-		goto nla_put_failure;
-
-	if (cap_len > 0 && nla_put_be32(skb, NFQA_CAP_LEN, htonl(cap_len)))
-		goto nla_put_failure;
-
-	nlh->nlmsg_len = skb->tail - old_tail;
+	nlh->nlmsg_len = skb->len;
 	return skb;
 
 nla_put_failure:
