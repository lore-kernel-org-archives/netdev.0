From: Tom Quetchenbach <virtualphtn@gmail.com>
Subject: [PATCH 2/2] David Miller's rbtree patches for 2.6.22.6
Date: Wed, 19 Sep 2007 18:44:03 -0700
Message-ID: <46F1D063.6030005@gmail.com>
References: <46F1CF35.3030606@gmail.com> <46F1D00B.6030108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing-mail.its.caltech.edu ([131.215.239.19]:24633 "EHLO
	outgoing-mail.its.caltech.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751482AbXITBoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 21:44:06 -0400
Received: from fire-dog.its.caltech.edu (fire-dog [192.168.1.4])
	by wood-ox-postvirus (Postfix) with ESMTP id 5F0FF13F87
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 18:44:05 -0700 (PDT)
Received: from [10.1.234.14] (mystic.caltech.edu [131.215.220.112])
	(Authenticated sender: quetchen)
	by water-ox.its.caltech.edu (Postfix) with ESMTP id E8A021BBEF
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 18:44:03 -0700 (PDT)
In-Reply-To: <46F1D00B.6030108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch 2: fixes to fack_counts and enhancement of SACK fast path

-Tom

---
diff -ur linux-2.6.22.6-rbtree-davem-fixed/include/net/tcp.h linux-2.6.22.6-rbtree-tomq/include/net/tcp.h
--- linux-2.6.22.6-rbtree-davem-fixed/include/net/tcp.h	2007-09-19 17:36:07.000000000 -0700
+++ linux-2.6.22.6-rbtree-tomq/include/net/tcp.h	2007-09-19 12:22:06.000000000 -0700
@@ -1213,6 +1213,11 @@
 	sk->sk_send_head = tcp_write_queue_next(sk, skb);
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head = NULL;
+	else
+		/* update fack_count of send_head. Since we've sent skb already,
+ 		 * its packet count must be set by now. */
+		TCP_SKB_CB(sk->sk_send_head)->fack_count =
+			TCP_SKB_CB(skb)->fack_count + tcp_skb_pcount(skb);
 	/* Don't override Nagle indefinately with F-RTO */
 	if (tp->frto_counter == 2)
 		tp->frto_counter = 3;
@@ -1310,19 +1315,22 @@
 /* An insert into the middle of the write queue causes the fack
  * counts in subsequent packets to become invalid, fix them up.
  */
-static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *first)
+static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *skb)
 {
-	struct sk_buff *prev = first->prev;
+	struct sk_buff *prev = skb->prev;
 	unsigned int fc = 0;
 
 	if (prev != (struct sk_buff *) &sk->sk_write_queue)
 		fc = TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
 
-	while (first != (struct sk_buff *)&sk->sk_write_queue) {
-		TCP_SKB_CB(first)->fack_count = fc;
+	while (skb != (struct sk_buff *)&sk->sk_write_queue) {
+		if (TCP_SKB_CB(skb)->fack_count == fc || !tcp_skb_pcount(skb))
+			break;
 
-		fc += tcp_skb_pcount(first);
-		first = first->next;
+		TCP_SKB_CB(skb)->fack_count = fc;
+
+		fc += tcp_skb_pcount(skb);
+		skb = skb->next;
 	}
 }
 
diff -ur linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_input.c linux-2.6.22.6-rbtree-tomq/net/ipv4/tcp_input.c
--- linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_input.c	2007-09-13 18:23:16.000000000 -0700
+++ linux-2.6.22.6-rbtree-tomq/net/ipv4/tcp_input.c	2007-09-19 12:27:42.000000000 -0700
@@ -956,6 +956,7 @@
 	int fack_count_base;
 	int i;
 	int first_sack_index;
+	u32 prev_end_seq = 0;
 
 	if (!tp->sacked_out)
 		tp->fackets_out = 0;
@@ -1000,6 +1001,7 @@
 		if (i == 0) {
 			if (tp->recv_sack_cache[i].start_seq != start_seq)
 				flag = 0;
+			prev_end_seq = ntohl(tp->recv_sack_cache[i].end_seq);
 		} else {
 			if ((tp->recv_sack_cache[i].start_seq != start_seq) ||
 			    (tp->recv_sack_cache[i].end_seq != end_seq))
@@ -1016,9 +1018,16 @@
 
 	first_sack_index = 0;
 	if (flag)
+		/* all that has changed is end of first SACK block. So all we
+ 		 * need to do is tag those skbs that were'nt tagged last time. */
 		num_sacks = 1;
 	else {
 		int j;
+		
+		/* more than just end of first SACK block has changed; invalidate
+		 * prev_end_seq */
+
+		prev_end_seq = 0;
 
 		/* order SACK blocks to allow in order walk of the retrans queue */
 		for (i = num_sacks-1; i > 0; i--) {
@@ -1051,6 +1060,8 @@
 		int fack_count;
 		int dup_sack = (found_dup_sack && (i == first_sack_index));
 
+		if (prev_end_seq) start_seq = prev_end_seq;
+
 		skb = tcp_write_queue_find(sk, start_seq);
 		if (!skb)
 			continue;
