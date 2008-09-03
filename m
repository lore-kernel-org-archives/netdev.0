From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/2] [NET] add skb_recycle_check() to enable netdriver skb recycling
Date: Wed,  3 Sep 2008 15:55:00 +0200
Message-ID: <1220450101-21317-2-git-send-email-buytenh@wantstofly.org>
References: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:58000 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752742AbYICNzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 09:55:05 -0400
In-Reply-To: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds skb_recycle_check(), which can be used by a network
driver after transmitting an skb to check whether this skb can be
recycled as a receive buffer.

skb_recycle_check() checks that the skb is not shared or cloned, and
that it is linear and its head portion large enough (as determined by
the driver) to be recycled as a receive buffer.  If these conditions
are met, it does any necessary reference count dropping and cleans
up the skbuff as if it just came from __alloc_skb().

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 include/linux/skbuff.h |    2 ++
 net/core/skbuff.c      |   41 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9099237..b8a5ac7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -369,6 +369,8 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, 1, -1);
 }
 
+extern int skb_recycle_check(struct sk_buff *skb, int skb_size);
+
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
 				 gfp_t priority);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ca1ccdf..2c218a0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -363,8 +363,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 	}
 }
 
-/* Free everything but the sk_buff shell. */
-static void skb_release_all(struct sk_buff *skb)
+static void skb_release_head_state(struct sk_buff *skb)
 {
 	dst_release(skb->dst);
 #ifdef CONFIG_XFRM
@@ -388,6 +387,12 @@ static void skb_release_all(struct sk_buff *skb)
 	skb->tc_verd = 0;
 #endif
 #endif
+}
+
+/* Free everything but the sk_buff shell. */
+static void skb_release_all(struct sk_buff *skb)
+{
+	skb_release_head_state(skb);
 	skb_release_data(skb);
 }
 
@@ -424,6 +429,38 @@ void kfree_skb(struct sk_buff *skb)
 	__kfree_skb(skb);
 }
 
+int skb_recycle_check(struct sk_buff *skb, int skb_size)
+{
+	struct skb_shared_info *shinfo;
+
+	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
+		return 0;
+
+	skb_size = SKB_DATA_ALIGN(skb_size + NET_SKB_PAD);
+	if (skb_end_pointer(skb) - skb->head < skb_size)
+		return 0;
+
+	if (skb_shared(skb) || skb_cloned(skb))
+		return 0;
+
+	skb_release_head_state(skb);
+	shinfo = skb_shinfo(skb);
+	atomic_set(&shinfo->dataref, 1);
+	shinfo->nr_frags = 0;
+	shinfo->gso_size = 0;
+	shinfo->gso_segs = 0;
+	shinfo->gso_type = 0;
+	shinfo->ip6_frag_id = 0;
+	shinfo->frag_list = NULL;
+
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb_reset_tail_pointer(skb);
+	skb->data = skb->head + NET_SKB_PAD;
+
+	return 1;
+}
+EXPORT_SYMBOL(skb_recycle_check);
+
 static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
 	new->tstamp		= old->tstamp;
-- 
1.5.6.4

