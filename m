From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [v2 PATCH] net: Stop decapitating clones that have a head_frag
Date: Wed, 02 May 2012 21:18:42 -0700
Message-ID: <20120503041842.8315.16138.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54619 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746Ab2ECES3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 00:18:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant ot prevent stealing the skb->head to use as a page in
the event that the skb->head was cloned.  This allows the other clones to
track each other via shinfo->dataref.

Without this we break down to two methods for tracking the reference count,
one being dataref, the other being the page count.  As a result it becomes
difficult to track how many references there are to skb->head.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/skbuff.c    |    9 +++++----
 net/ipv4/tcp_input.c |    9 ++-------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 52ba2b5..9e8caa0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1699,17 +1699,18 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 			      struct splice_pipe_desc *spd, struct sock *sk)
 {
 	int seg;
-	bool head_is_linear = !skb->head_frag;
+	bool head_is_locked = !skb->head_frag || skb_cloned(skb);
 
 	/* map the linear part :
-	 * If skb->head_frag is set, this 'linear' part is backed
-	 * by a fragment, and we can avoid a copy.
+	 * If skb->head_frag is set, this 'linear' part is backed by a
+	 * fragment, and if the head is not shared with any clones then
+	 * we can avoid a copy since we own the head portion of this page.
 	 */
 	if (__splice_segment(virt_to_page(skb->data),
 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
 			     skb_headlen(skb),
 			     offset, len, skb, spd,
-			     head_is_linear,
+			     head_is_locked,
 			     sk, pipe))
 		return true;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2f696ef..c6f78e2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4589,7 +4589,7 @@ copyfrags:
 		to->data_len += len;
 		goto merge;
 	}
-	if (from->head_frag) {
+	if (from->head_frag && !skb_cloned(from)) {
 		struct page *page;
 		unsigned int offset;
 
@@ -4599,12 +4599,7 @@ copyfrags:
 		offset = from->data - (unsigned char *)page_address(page);
 		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
 				   page, offset, skb_headlen(from));
-
-		if (skb_cloned(from))
-			get_page(page);
-		else
-			*fragstolen = true;
-
+		*fragstolen = true;
 		delta = len; /* we dont know real truesize... */
 		goto copyfrags;
 	}
