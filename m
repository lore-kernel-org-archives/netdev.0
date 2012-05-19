From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/3] ipv4: use skb coalescing in defragmentation
Date: Sat, 19 May 2012 15:02:20 +0200
Message-ID: <1337432540.7029.195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64041 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758591Ab2ESNCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 09:02:23 -0400
Received: by wibhn6 with SMTP id hn6so982235wib.1
        for <netdev@vger.kernel.org>; Sat, 19 May 2012 06:02:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip_frag_reasm() can use skb_try_coalesce() to build optimized skb,
reducing memory used by them (truesize), and reducing number of cache
line misses and overhead for the consumer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/ip_fragment.c |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 695b27f..9dbd3dd 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -545,6 +545,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	int len;
 	int ihlen;
 	int err;
+	int sum_truesize;
 	u8 ecn;
 
 	ipq_kill(qp);
@@ -611,19 +612,32 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		atomic_add(clone->truesize, &qp->q.net->mem);
 	}
 
-	skb_shinfo(head)->frag_list = head->next;
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
-	atomic_sub(head->truesize, &qp->q.net->mem);
+	atomic_sub(sum_truesize, &qp->q.net->mem);
 
 	head->next = NULL;
 	head->dev = dev;
