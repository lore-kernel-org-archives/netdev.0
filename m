From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Wed, 02 May 2012 20:39:01 -0700
Message-ID: <20120503033901.5482.27183.stgit@gitlad.jf.intel.com>
References: <20120503033018.5482.89902.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58896 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753871Ab2ECDir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 23:38:47 -0400
In-Reply-To: <20120503033018.5482.89902.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is mostly meant to help improve the readability of
tcp_try_coalesce.  I had a few issues since there were several points when
the code would test for a conditional, fail, then succeed on another
conditional take some action, and then follow a goto back into the previous
conditional.  I just tore all of that apart and made the whole thing one
linear flow with a single goto.

Also there were multiple ways of computing the delta, the one for head_frag
made the least amount of sense to me since we were only dropping the
sk_buff so I have updated the logic for the stolen head case so that delta
is only truesize - sizeof(skb_buff), and for the case where we are dropping
the head as well it is truesize - SKB_TRUESIZE(skb_end_pointer - head).
This way we can also account for the head_frag with headlen == 0.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/ipv4/tcp_input.c |   80 +++++++++++++++++++++++++++-----------------------
 1 files changed, 43 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c6f78e2..23bc3ff 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4548,62 +4548,68 @@ static bool tcp_try_coalesce(struct sock *sk,
 	int i, delta, len = from->len;
 
 	*fragstolen = false;
+
 	if (tcp_hdr(from)->fin || skb_cloned(to))
 		return false;
+
 	if (len <= skb_tailroom(to)) {
 		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
-merge:
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
-		TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
-		TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
-		return true;
+		goto merge;
 	}
 
 	if (skb_has_frag_list(to) || skb_has_frag_list(from))
 		return false;
 
-	if (skb_headlen(from) == 0 &&
-	    (skb_shinfo(to)->nr_frags +
-	     skb_shinfo(from)->nr_frags <= MAX_SKB_FRAGS)) {
-		WARN_ON_ONCE(from->head_frag);
-		delta = from->truesize - ksize(from->head) -
-			SKB_DATA_ALIGN(sizeof(struct sk_buff));
-
-		WARN_ON_ONCE(delta < len);
-copyfrags:
-		memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
-		       skb_shinfo(from)->frags,
-		       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
-		skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
-
-		if (skb_cloned(from))
-			for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
-				skb_frag_ref(from, i);
-		else
-			skb_shinfo(from)->nr_frags = 0;
-
-		to->truesize += delta;
-		atomic_add(delta, &sk->sk_rmem_alloc);
-		sk_mem_charge(sk, delta);
-		to->len += len;
-		to->data_len += len;
-		goto merge;
-	}
-	if (from->head_frag && !skb_cloned(from)) {
+	if (skb_headlen(from) != 0) {
 		struct page *page;
 		unsigned int offset;
 
-		if (skb_shinfo(to)->nr_frags + skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
+		if (skb_shinfo(to)->nr_frags +
+		    skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
+			return false;
+
+		if (!from->head_frag || skb_cloned(from))
 			return false;
+
+		delta = from->truesize - sizeof(struct sk_buff);
+
 		page = virt_to_head_page(from->head);
 		offset = from->data - (unsigned char *)page_address(page);
+
 		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
 				   page, offset, skb_headlen(from));
 		*fragstolen = true;
-		delta = len; /* we dont know real truesize... */
-		goto copyfrags;
+	} else {
+		if (skb_shinfo(to)->nr_frags +
+		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
+			return false;
+
+		delta = from->truesize -
+			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
 	}
-	return false;
+
+	memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
+	       skb_shinfo(from)->frags,
+	       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
+	skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
+
+	if (!skb_cloned(from))
+		skb_shinfo(from)->nr_frags = 0;
+
+	for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
+		skb_frag_ref(from, i);
+
+	to->truesize += delta;
+	atomic_add(delta, &sk->sk_rmem_alloc);
+	sk_mem_charge(sk, delta);
+	to->len += len;
+	to->data_len += len;
+
+merge:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
+	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
+	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
+	return true;
 }
 
 static void kfree_skb_partial(struct sk_buff *skb, bool head_stolen)
