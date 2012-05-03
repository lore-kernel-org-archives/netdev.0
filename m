From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [v2 PATCH 2/4] tcp: Move code related to head frag in tcp_try_coalesce
Date: Thu, 03 May 2012 00:19:04 -0700
Message-ID: <20120503071904.13636.61130.stgit@gitlad.jf.intel.com>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13473 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138Ab2ECHS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 03:18:58 -0400
In-Reply-To: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change reorders the code related to the use of an skb->head_frag so it
is placed before we check the rest of the frags.  This allows the code to
read more linearly instead of like some sort of loop.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/ipv4/tcp_input.c |   42 +++++++++++++++++++++++++-----------------
 1 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3cb273a..41fa5df 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4562,9 +4562,31 @@ merge:
 	if (skb_has_frag_list(to) || skb_has_frag_list(from))
 		return false;
 
-	if (skb_headlen(from) == 0 &&
-	    (skb_shinfo(to)->nr_frags +
-	     skb_shinfo(from)->nr_frags <= MAX_SKB_FRAGS)) {
+	if (skb_headlen(from) != 0) {
+		struct page *page;
+		unsigned int offset;
+
+		if (skb_shinfo(to)->nr_frags +
+		    skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
+			return false;
+
+		if (!from->head_frag || skb_cloned(from))
+			return false;
+
+		delta = from->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
+
+		page = virt_to_head_page(from->head);
+		offset = from->data - (unsigned char *)page_address(page);
+
+		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
+				   page, offset, skb_headlen(from));
+		*fragstolen = true;
+		goto copyfrags;
+	} else {
+		if (skb_shinfo(to)->nr_frags +
+		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
+			return false;
+
 		delta = from->truesize -
 			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
 copyfrags:
@@ -4587,20 +4609,6 @@ copyfrags:
 		to->data_len += len;
 		goto merge;
 	}
-	if (from->head_frag && !skb_cloned(from)) {
-		struct page *page;
-		unsigned int offset;
-
-		if (skb_shinfo(to)->nr_frags + skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
-			return false;
-		page = virt_to_head_page(from->head);
-		offset = from->data - (unsigned char *)page_address(page);
-		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
-				   page, offset, skb_headlen(from));
-		*fragstolen = true;
-		delta = from->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
-		goto copyfrags;
-	}
 	return false;
 }
 
