From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] skb: Add skb_head_is_locked helper function
Date: Thu, 03 May 2012 04:09:42 -0700
Message-ID: <20120503110942.18281.27820.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:58308 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846Ab2ECLJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 07:09:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for a skb_head_is_locked helper function.  It is
meant to be used any time we are considering transferring the head from
skb->head to a paged frag.  If the head is locked it means we cannot remove
the head from the skb so it must be copied or we must take the skb as a
whole.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/skbuff.h |   14 ++++++++++++++
 net/core/skbuff.c      |    3 +--
 net/ipv4/tcp_input.c   |    2 +-
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 988fc49..37f5391 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2566,5 +2566,19 @@ static inline bool skb_is_recycleable(const struct sk_buff *skb, int skb_size)
 
 	return true;
 }
+
+/**
+ * skb_head_is_locked - Determine if the skb->head is locked down
+ * @skb: skb to check
+ *
+ * The head on skbs build around a head frag can be removed if they are
+ * not cloned.  This function returns true if the skb head is locked down
+ * due to either being allocated via kmalloc, or by being a clone with
+ * multiple references to the head.
+ */
+static inline bool skb_head_is_locked(const struct sk_buff *skb)
+{
+	return !skb->head_frag || skb_cloned(skb);
+}
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9e8caa0..dc514e3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1699,7 +1699,6 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 			      struct splice_pipe_desc *spd, struct sock *sk)
 {
 	int seg;
-	bool head_is_locked = !skb->head_frag || skb_cloned(skb);
 
 	/* map the linear part :
 	 * If skb->head_frag is set, this 'linear' part is backed by a
@@ -1710,7 +1709,7 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
 			     skb_headlen(skb),
 			     offset, len, skb, spd,
-			     head_is_locked,
+			     skb_head_is_locked(skb),
 			     sk, pipe))
 		return true;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 84e69e0..7b2d351 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4568,7 +4568,7 @@ static bool tcp_try_coalesce(struct sock *sk,
 		    skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
 			return false;
 
-		if (!from->head_frag || skb_cloned(from))
+		if (skb_head_is_locked(from))
 			return false;
 
 		delta = from->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
