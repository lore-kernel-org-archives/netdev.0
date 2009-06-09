From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/15]: ipv6: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:02:21 -0700 (PDT)
Message-ID: <20090609.050221.200908123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760001AbZFIMCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:19 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 03917C8C1B5
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_output.c |    6 +++---
 net/ipv6/reassembly.c |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c8dc8e5..db6c722 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -658,7 +658,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	}
 	mtu -= hlen + sizeof(struct frag_hdr);
 
-	if (skb_shinfo(skb)->frag_list) {
+	if (skb_has_frags(skb)) {
 		int first_len = skb_pagelen(skb);
 		int truesizes = 0;
 
@@ -667,7 +667,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		    skb_cloned(skb))
 			goto slow_path;
 
-		for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+		skb_walk_frags(skb, frag) {
 			/* Correct geometry. */
 			if (frag->len > mtu ||
 			    ((frag->len & 7) && frag->next) ||
@@ -690,7 +690,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		err = 0;
 		offset = 0;
 		frag = skb_shinfo(skb)->frag_list;
-		skb_shinfo(skb)->frag_list = NULL;
+		skb_frag_list_init(skb);
 		/* BUILD HEADER */
 
 		*prevhdr = NEXTHDR_FRAGMENT;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 54a387d..2642a41 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -494,7 +494,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	/* If the first fragment is fragmented itself, we split
 	 * it to two chunks: the first with data and paged part
 	 * and the second, holding only fragments. */
-	if (skb_shinfo(head)->frag_list) {
+	if (skb_has_frags(head)) {
 		struct sk_buff *clone;
 		int i, plen = 0;
 
@@ -503,7 +503,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		clone->next = head->next;
 		head->next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
-		skb_shinfo(head)->frag_list = NULL;
+		skb_frag_list_init(head);
 		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
 			plen += skb_shinfo(head)->frags[i].size;
 		clone->len = clone->data_len = head->data_len - plen;
-- 
1.6.3.2

