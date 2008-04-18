From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] net: add destructor for skb data (rewritten)
Date: Fri, 18 Apr 2008 14:21:25 +1000
Message-ID: <200804181421.25828.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41505 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbYDREYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 00:24:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we want to notify something when an skb is truly finished (such as
for tun vringfd support), we need a destructor on the data.

This turns out to be slightly non-trivial as fragments from one skb
get copied to another skb: if the first skb has a destructor (or its
parent does) we need to keep a reference to it and destroy it only
when (all the) children are destroyed.  We add an 'orig' pointer to
the skb_shared_info to do this.

But there's currently no way to get from the shinfo to the head (to
kfree it), so we add a 'len' field.  A better alternative to this
might be to move the skb_shared_info to before the head of the skb data.

Note that the destructor is responsible for calling kfree: for the tun
device, this is critical since the destructor can be called from any
context and it has to do a copy_to_user, so it queues the skb.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 include/linux/skbuff.h |    9 +++++++
 net/core/skbuff.c      |   62 ++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 60 insertions(+), 11 deletions(-)

diff -r 78decd088c5d include/linux/skbuff.h
--- a/include/linux/skbuff.h	Thu Apr 17 07:20:31 2008 +1000
+++ b/include/linux/skbuff.h	Fri Apr 18 10:33:19 2008 +1000
@@ -146,8 +146,12 @@ struct skb_shared_info {
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
 	__be32          ip6_frag_id;
+	unsigned int	len; /* Subtract from this shinfo to find skb->head */
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
+	struct skb_shared_info *orig;
+	/* This is responsible for kfree() of header. */
+	void		(*destructor)(struct skb_shared_info *);
 };
 
 /* We divide dataref into two halves.  The higher 16 bits hold references
@@ -852,6 +856,11 @@ static inline void skb_fill_page_desc(st
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->frag_list)
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
 
+static inline unsigned char *skb_shinfo_to_head(struct skb_shared_info *shinfo)
+{
+	return (unsigned char *)shinfo - shinfo->len;
+}
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_tail_pointer(const struct sk_buff *skb)
 {
diff -r 78decd088c5d net/core/skbuff.c
--- a/net/core/skbuff.c	Thu Apr 17 07:20:31 2008 +1000
+++ b/net/core/skbuff.c	Fri Apr 18 10:33:19 2008 +1000
@@ -218,6 +218,9 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
+	shinfo->destructor = NULL;
+	shinfo->orig = NULL;
+	shinfo->len = skb_end_pointer(skb) - skb->head;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -289,21 +292,50 @@ static void skb_clone_fraglist(struct sk
 		skb_get(list);
 }
 
+static void shinfo_put(struct skb_shared_info *shinfo, bool nohdr)
+{
+	struct skb_shared_info *orig;
+
+	do {
+		if (atomic_sub_return(nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
+				      &shinfo->dataref))
+			return;
+
+		if (shinfo->nr_frags) {
+			int i;
+			for (i = 0; i < shinfo->nr_frags; i++)
+				put_page(shinfo->frags[i].page);
+		}
+
+		if (shinfo->frag_list)
+			skb_drop_list(&shinfo->frag_list);
+
+		orig = shinfo->orig;
+		if (shinfo->destructor)
+			shinfo->destructor(shinfo);
+		else
+			kfree(skb_shinfo_to_head(shinfo));
+
+		/* We hold a payload reference to our parent. */
+		nohdr = true;
+	} while ((shinfo = orig) != NULL);
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
-	if (!skb->cloned ||
-	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
-			       &skb_shinfo(skb)->dataref)) {
-		if (skb_shinfo(skb)->nr_frags) {
-			int i;
-			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
-		}
+	if (!skb->cloned)
+		shinfo_put(skb_shinfo(skb), skb->nohdr);
+}
 
-		if (skb_shinfo(skb)->frag_list)
-			skb_drop_fraglist(skb);
+/* Now hold reference to older data, if has a destructor (recursively). */
+static void skb_ref_data_parent(struct sk_buff *parent,
+				struct skb_shared_info *shinfo)
+{
+	struct skb_shared_info *pshinfo = skb_shinfo(parent);
 
-		kfree(skb->head);
+	if (pshinfo->destructor || pshinfo->orig) {
+		shinfo->orig = pshinfo;
+		atomic_add((1 << SKB_DATAREF_SHIFT) + 1, &pshinfo->dataref);
 	}
 }
 
@@ -634,6 +666,7 @@ struct sk_buff *pskb_copy(struct sk_buff
 			get_page(skb_shinfo(n)->frags[i].page);
 		}
 		skb_shinfo(n)->nr_frags = i;
+		skb_ref_data_parent(skb, skb_shinfo(n));
 	}
 
 	if (skb_shinfo(skb)->frag_list) {
@@ -699,6 +732,8 @@ int pskb_expand_head(struct sk_buff *skb
 	if (skb_shinfo(skb)->frag_list)
 		skb_clone_fraglist(skb);
 
+	skb_ref_data_parent(skb, (void *)(data + size));
+
 	skb_release_data(skb);
 
 	off = (data + nhead) - skb->head;
@@ -721,6 +756,7 @@ int pskb_expand_head(struct sk_buff *skb
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
+	skb_shinfo(skb)->len = skb_end_pointer(skb) - skb->head;
 	return 0;
 
 nodata:
@@ -1868,6 +1904,8 @@ void skb_split(struct sk_buff *skb, stru
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
 		skb_split_no_header(skb, skb1, len, pos);
+
+	skb_ref_data_parent(skb, skb_shinfo(skb1));
 }
 
 /**
@@ -2240,6 +2278,8 @@ struct sk_buff *skb_segment(struct sk_bu
 		nskb->data_len = len - hsize;
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
+
+		skb_ref_data_parent(skb, skb_shinfo(nskb));
 	} while ((offset += len) < skb->len);
 
 	return segs;
