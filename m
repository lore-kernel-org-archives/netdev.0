From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] Revert "ipv4: use skb coalescing in defragmentation"
Date: Sat, 11 Jul 2015 01:37:36 +0200
Message-ID: <1436571456-27905-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42952 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754386AbbGJXho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 19:37:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 3cc4949269e01f39443d0fcfffb5bc6b47878d45.

There is nothing wrong with coalescing during defragmentation, it
reduces truesize overhead and simplifies things for the receiving
socket (no fraglist walk needed).

However, it also destroys geometry of the original fragments.
While that doesn't cause any breakage (we make sure to not exceed largest
original size) ip_do_fragment contains a 'fastpath' that takes advantage
of a present frag list and results in fragments that (in most cases)
match what was received.

In case its needed the coalescing could be done later, when we're sure
the skb is not forwarded.  But discussion during NFWS resulted in
'lets just remove this for now'.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a50dc6d..4d3fffa 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -522,7 +522,6 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	int len;
 	int ihlen;
 	int err;
-	int sum_truesize;
 	u8 ecn;
 
 	ipq_kill(qp);
@@ -590,32 +589,19 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		add_frag_mem_limit(&qp->q, clone->truesize);
 	}
 
+	skb_shinfo(head)->frag_list = head->next;
 	skb_push(head, head->data - skb_network_header(head));
 
-	sum_truesize = head->truesize;
-	for (fp = head->next; fp;) {
-		bool headstolen;
-		int delta;
-		struct sk_buff *next = fp->next;
-
-		sum_truesize += fp->truesize;
+	for (fp=head->next; fp; fp = fp->next) {
+		head->data_len += fp->len;
+		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
 			head->ip_summed = CHECKSUM_NONE;
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
-
-		if (skb_try_coalesce(head, fp, &headstolen, &delta)) {
-			kfree_skb_partial(fp, headstolen);
-		} else {
-			if (!skb_shinfo(head)->frag_list)
-				skb_shinfo(head)->frag_list = fp;
-			head->data_len += fp->len;
-			head->len += fp->len;
-			head->truesize += fp->truesize;
-		}
-		fp = next;
+		head->truesize += fp->truesize;
 	}
-	sub_frag_mem_limit(&qp->q, sum_truesize);
+	sub_frag_mem_limit(&qp->q, head->truesize);
 
 	head->next = NULL;
 	head->dev = dev;
-- 
2.0.5
