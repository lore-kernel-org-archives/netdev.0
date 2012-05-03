From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 1/2] net: Stop decapitating clones that have a head_frag
Date: Wed, 02 May 2012 20:38:56 -0700
Message-ID: <20120503033856.5482.70122.stgit@gitlad.jf.intel.com>
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
	id S1753137Ab2ECDim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 23:38:42 -0400
In-Reply-To: <20120503033018.5482.89902.stgit@gitlad.jf.intel.com>
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

 net/core/skbuff.c    |    2 +-
 net/ipv4/tcp_input.c |    9 ++-------
 2 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 52ba2b5..8703754 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1699,7 +1699,7 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 			      struct splice_pipe_desc *spd, struct sock *sk)
 {
 	int seg;
-	bool head_is_linear = !skb->head_frag;
+	bool head_is_linear = !skb->head_frag || skb_cloned(skb);
 
 	/* map the linear part :
 	 * If skb->head_frag is set, this 'linear' part is backed
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
