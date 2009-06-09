From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/15]: ipv4: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:02:16 -0700 (PDT)
Message-ID: <20090609.050216.108460651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758400AbZFIMCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CEB5BC8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_fragment.c |    4 ++--
 net/ipv4/ip_output.c   |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 1f1b824..575f9bd 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -507,7 +507,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	/* If the first fragment is fragmented itself, we split
 	 * it to two chunks: the first with data and paged part
 	 * and the second, holding only fragments. */
-	if (skb_shinfo(head)->frag_list) {
+	if (skb_has_frags(head)) {
 		struct sk_buff *clone;
 		int i, plen = 0;
 
@@ -516,7 +516,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		clone->next = head->next;
 		head->next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
-		skb_shinfo(head)->frag_list = NULL;
+		skb_frag_list_init(head);
 		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
 			plen += skb_shinfo(head)->frags[i].size;
 		clone->len = clone->data_len = head->data_len - plen;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3d6167f..9248d28 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -474,7 +474,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	 * LATER: this step can be merged to real generation of fragments,
 	 * we can switch to copy when see the first bad fragment.
 	 */
-	if (skb_shinfo(skb)->frag_list) {
+	if (skb_has_frags(skb)) {
 		struct sk_buff *frag;
 		int first_len = skb_pagelen(skb);
 		int truesizes = 0;
@@ -485,7 +485,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		    skb_cloned(skb))
 			goto slow_path;
 
-		for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+		skb_walk_frags(skb, frag) {
 			/* Correct geometry. */
 			if (frag->len > mtu ||
 			    ((frag->len & 7) && frag->next) ||
@@ -510,7 +510,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		err = 0;
 		offset = 0;
 		frag = skb_shinfo(skb)->frag_list;
-		skb_shinfo(skb)->frag_list = NULL;
+		skb_frag_list_init(skb);
 		skb->data_len = first_len - skb_headlen(skb);
 		skb->truesize -= truesizes;
 		skb->len = first_len;
-- 
1.6.3.2

