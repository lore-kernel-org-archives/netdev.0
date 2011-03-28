From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] net: Always allocate at least 16 skb frags regardless of
 page size
Date: Mon, 28 Mar 2011 11:57:26 +1100
Message-ID: <20110328115726.4cca214d@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54818 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab1C1A5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Mar 2011 20:57:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When analysing performance of the cxgb3 on a ppc64 box I noticed that
we weren't doing much GRO merging. It turns out we are limited by the
number of SKB frags:

#define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)

With a 4kB page size we have 18 frags, but with a 64kB page size we
only have 3 frags.

I ran a single stream TCP bandwidth test to compare the performance of
different values of MAX_SKB_FRAGS on the receiver:

MAX_SKB_FRAGS   Mbps
3               7080	
8               7931    (+12%)
16              8335	(+17%)
32              8349	(+17%)

Performance continues to increase up to 16 frags then levels off so
the patch below puts a lower bound of 16 on MAX_SKB_FRAGS.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: powerpc.git/include/linux/skbuff.h
===================================================================
--- powerpc.git.orig/include/linux/skbuff.h	2011-03-28 09:41:25.392124844 +1100
+++ powerpc.git/include/linux/skbuff.h	2011-03-28 10:18:58.253050000 +1100
@@ -122,8 +122,14 @@ struct sk_buff_head {
 
 struct sk_buff;
 
-/* To allow 64K frame to be packed as single skb without frag_list */
+/* To allow 64K frame to be packed as single skb without frag_list. Since
+ * GRO uses frags we allocate at least 16 regardless of page size.
+ */
+#if (65536/PAGE_SIZE + 2) < 16
+#define MAX_SKB_FRAGS 16
+#else
 #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
+#endif
 
 typedef struct skb_frag_struct skb_frag_t;
 
