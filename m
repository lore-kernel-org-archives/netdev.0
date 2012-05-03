From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [v2 PATCH 3/4] tcp: move stats merge to the end of tcp_try_coalesce
Date: Thu, 03 May 2012 00:19:09 -0700
Message-ID: <20120503071909.13636.43086.stgit@gitlad.jf.intel.com>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39586 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758Ab2ECHTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 03:19:16 -0400
In-Reply-To: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change cleans up the last bits of tcp_try_coalesce so that we only
need one goto which jumps to the end of the function.  The idea is to make
the code more readable by putting things in a linear order so that we start
execution at the top of the function, and end it at the bottom.

I also made a slight tweak to the code for handling frags when we are a
clone.  Instead of making it an if (clone) loop else nr_frags = 0 I changed
the logic so that if (!clone) we just set the number of frags to 0 which
disables the for loop anyway.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/ipv4/tcp_input.c |   55 ++++++++++++++++++++++++++------------------------
 1 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 41fa5df..84e69e0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4548,15 +4548,13 @@ static bool tcp_try_coalesce(struct sock *sk,
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
@@ -4581,7 +4579,6 @@ merge:
 		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
 				   page, offset, skb_headlen(from));
 		*fragstolen = true;
-		goto copyfrags;
 	} else {
 		if (skb_shinfo(to)->nr_frags +
 		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
@@ -4589,27 +4586,33 @@ merge:
 
 		delta = from->truesize -
 			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
-copyfrags:
-		WARN_ON_ONCE(delta < len);
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
 	}
-	return false;
+
+	WARN_ON_ONCE(delta < len);
+
+	memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
+	       skb_shinfo(from)->frags,
+	       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
+	skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
+
+	if (!skb_cloned(from))
+		skb_shinfo(from)->nr_frags = 0;
+
+	/* if the skb is cloned this does nothing since we set nr_frags to 0 */
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
