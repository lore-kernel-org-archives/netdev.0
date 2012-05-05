From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 2/3] skb: Drop "fastpath" variable for skb_cloned check in
	pskb_expand_head
Date: Fri, 04 May 2012 17:26:51 -0700
Message-ID: <20120505002651.21292.19680.stgit@gitlad.jf.intel.com>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24583 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758571Ab2EEA0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 20:26:36 -0400
In-Reply-To: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since there is now only one spot that actually uses "fastpath" there isn't
much point in carrying it.  Instead we can just use a check for skb_cloned
to verify if we can perform the fast-path free for the head or not.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/core/skbuff.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4d085d4..17e4b1e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -932,7 +932,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	u8 *data;
 	int size = nhead + (skb_end_pointer(skb) - skb->head) + ntail;
 	long off;
-	bool fastpath;
 
 	BUG_ON(nhead < 0);
 
@@ -941,16 +940,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 
 	size = SKB_DATA_ALIGN(size);
 
-	/* Check if we can avoid taking references on fragments if we own
-	 * the last reference on skb->head. (see skb_release_data())
-	 */
-	if (!skb->cloned)
-		fastpath = true;
-	else {
-		int delta = skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1;
-		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
-	}
-
 	data = kmalloc(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
 		       gfp_mask);
 	if (!data)
@@ -966,9 +955,12 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	       skb_shinfo(skb),
 	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_frags]));
 
-	if (fastpath) {
-		skb_free_head(skb);
-	} else {
+	/*
+	 * if shinfo is shared we must drop the old head gracefully, but if it
+	 * is not we can just drop the old head and let the existing refcount
+	 * be since all we did is relocate the values
+	 */
+	if (skb_cloned(skb)) {
 		/* copy this zero copy skb frags */
 		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 			if (skb_copy_ubufs(skb, gfp_mask))
@@ -981,6 +973,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 			skb_clone_fraglist(skb);
 
 		skb_release_data(skb);
+	} else {
+		skb_free_head(skb);
 	}
 	off = (data + nhead) - skb->head;
 
