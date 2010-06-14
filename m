From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip_frag: Remove some atomic ops
Date: Mon, 14 Jun 2010 11:02:24 +0200
Message-ID: <1276506144.2478.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:51470 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517Ab0FNJC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 05:02:28 -0400
Received: by wwb18 with SMTP id 18so3557555wwb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 02:02:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of doing one atomic operation per frag, we can factorize them.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_fragment.c |    3 +--
 net/ipv6/reassembly.c  |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 75347ea..963c368 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -556,7 +556,6 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 
 	skb_shinfo(head)->frag_list = head->next;
 	skb_push(head, head->data - skb_network_header(head));
-	atomic_sub(head->truesize, &qp->q.net->mem);
 
 	for (fp=head->next; fp; fp = fp->next) {
 		head->data_len += fp->len;
@@ -566,8 +565,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
-		atomic_sub(fp->truesize, &qp->q.net->mem);
 	}
+	atomic_sub(head->truesize, &qp->q.net->mem);
 
 	head->next = NULL;
 	head->dev = dev;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 6d4292f..a630506 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -524,7 +524,6 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	skb_shinfo(head)->frag_list = head->next;
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
-	atomic_sub(head->truesize, &fq->q.net->mem);
 
 	for (fp=head->next; fp; fp = fp->next) {
 		head->data_len += fp->len;
@@ -534,8 +533,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
-		atomic_sub(fp->truesize, &fq->q.net->mem);
 	}
+	atomic_sub(head->truesize, &fq->q.net->mem);
 
 	head->next = NULL;
 	head->dev = dev;


