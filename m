From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 3/3] ipv6: use skb coalescing in reassembly
Date: Sat, 19 May 2012 15:02:35 +0200
Message-ID: <1337432555.7029.196.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49776 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758646Ab2ESNCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 09:02:38 -0400
Received: by weyu7 with SMTP id u7so2320908wey.19
        for <netdev@vger.kernel.org>; Sat, 19 May 2012 06:02:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip6_frag_reasm() can use skb_try_coalesce() to build optimized skb,
reducing memory used by them (truesize), and reducing number of cache
line misses and overhead for the consumer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv6/reassembly.c |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 5d32dfa..4ff9af6 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -415,6 +415,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	struct sk_buff *fp, *head = fq->q.fragments;
 	int    payload_len;
 	unsigned int nhoff;
+	int sum_truesize;
 
 	fq_kill(fq);
 
@@ -484,20 +485,33 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	head->mac_header += sizeof(struct frag_hdr);
 	head->network_header += sizeof(struct frag_hdr);
 
-	skb_shinfo(head)->frag_list = head->next;
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
 
-	for (fp=head->next; fp; fp = fp->next) {
-		head->data_len += fp->len;
-		head->len += fp->len;
+	sum_truesize = head->truesize;
+	for (fp = head->next; fp;) {
+		bool headstolen;
+		int delta;
+		struct sk_buff *next = fp->next;
+
+		sum_truesize += fp->truesize;
 		if (head->ip_summed != fp->ip_summed)
 			head->ip_summed = CHECKSUM_NONE;
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
-		head->truesize += fp->truesize;
+
+		if (skb_try_coalesce(head, fp, &headstolen, &delta)) {
+			kfree_skb_partial(fp, headstolen);
+		} else {
+			if (!skb_shinfo(head)->frag_list)
+				skb_shinfo(head)->frag_list = fp;
+			head->data_len += fp->len;
+			head->len += fp->len;
+			head->truesize += fp->truesize;
+		}
+		fp = next;
 	}
-	atomic_sub(head->truesize, &fq->q.net->mem);
+	atomic_sub(sum_truesize, &fq->q.net->mem);
 
 	head->next = NULL;
 	head->dev = dev;
