From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: splice: fix __splice_segment()
Date: Fri, 11 Jan 2013 16:46:37 -0800
Message-ID: <1357951597.20249.247.camel@edumazet-glaptop>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
	 <1357750898.27446.33.camel@edumazet-glaptop>
	 <1357751372.27446.40.camel@edumazet-glaptop>
	 <1357801149.27446.1142.camel@edumazet-glaptop>
	 <20130110072136.GK9943@1wt.eu>
	 <1357831787.27446.2168.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:34069 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903Ab3ALAqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 19:46:40 -0500
Received: by mail-pb0-f47.google.com with SMTP id un1so1229713pbc.6
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 16:46:40 -0800 (PST)
In-Reply-To: <1357831787.27446.2168.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 9ca1b22d6d2 (net: splice: avoid high order page splitting)
forgot that skb->head could need a copy into several page frags.

This could be the case for loopback traffic mostly.

Also remove now useless skb argument from linear_to_page()
and __splice_segment() prototypes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willy Tarreau <w@1wt.eu>
---
 net/core/skbuff.c |   28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1e1b9ea..2568c44 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1652,7 +1652,7 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
 
 static struct page *linear_to_page(struct page *page, unsigned int *len,
 				   unsigned int *offset,
-				   struct sk_buff *skb, struct sock *sk)
+				   struct sock *sk)
 {
 	struct page_frag *pfrag = sk_page_frag(sk);
 
@@ -1685,14 +1685,14 @@ static bool spd_can_coalesce(const struct splice_pipe_desc *spd,
 static bool spd_fill_page(struct splice_pipe_desc *spd,
 			  struct pipe_inode_info *pipe, struct page *page,
 			  unsigned int *len, unsigned int offset,
-			  struct sk_buff *skb, bool linear,
+			  bool linear,
 			  struct sock *sk)
 {
 	if (unlikely(spd->nr_pages == MAX_SKB_FRAGS))
 		return true;
 
 	if (linear) {
-		page = linear_to_page(page, len, &offset, skb, sk);
+		page = linear_to_page(page, len, &offset, sk);
 		if (!page)
 			return true;
 	}
@@ -1711,13 +1711,11 @@ static bool spd_fill_page(struct splice_pipe_desc *spd,
 
 static bool __splice_segment(struct page *page, unsigned int poff,
 			     unsigned int plen, unsigned int *off,
-			     unsigned int *len, struct sk_buff *skb,
+			     unsigned int *len,
 			     struct splice_pipe_desc *spd, bool linear,
 			     struct sock *sk,
 			     struct pipe_inode_info *pipe)
 {
-	unsigned int flen;
-
 	if (!*len)
 		return true;
 
@@ -1732,12 +1730,16 @@ static bool __splice_segment(struct page *page, unsigned int poff,
 	plen -= *off;
 	*off = 0;
 
-	flen = min(*len, plen);
-
-	if (spd_fill_page(spd, pipe, page, &flen, poff, skb, linear, sk))
-		return true;
+	do {
+		unsigned int flen = min(*len, plen);
 
-	*len -= flen;
+		if (spd_fill_page(spd, pipe, page, &flen, poff,
+				  linear, sk))
+			return true;
+		poff += flen;
+		plen -= flen;
+		*len -= flen;
+	} while (*len && plen);
 
 	return false;
 }
@@ -1760,7 +1762,7 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 	if (__splice_segment(virt_to_page(skb->data),
 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
 			     skb_headlen(skb),
-			     offset, len, skb, spd,
+			     offset, len, spd,
 			     skb_head_is_locked(skb),
 			     sk, pipe))
 		return true;
@@ -1773,7 +1775,7 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 
 		if (__splice_segment(skb_frag_page(f),
 				     f->page_offset, skb_frag_size(f),
-				     offset, len, skb, spd, false, sk, pipe))
+				     offset, len, spd, false, sk, pipe))
 			return true;
 	}
 
