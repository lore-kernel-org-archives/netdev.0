From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH v3 2/6] net: move destructor_arg to the front of sk_buff.
Date: Wed, 25 Jan 2012 12:27:10 +0000
Message-ID: <1327494434-21566-2-git-send-email-ian.campbell@citrix.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:44228 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843Ab2AYM1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 07:27:20 -0500
In-Reply-To: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of the previous patch we align the end (rather than the start) of the struct
to a cache line and so, with 32 and 64 byte cache lines and the shinfo size
increase from the next patch, the first 8 bytes of the struct end up on a
different cache line to the rest of it so make sure it is something relatively
unimportant to avoid hitting an extra cache line on hot operations such as
kfree_skb.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |   15 ++++++++++-----
 net/core/skbuff.c      |    5 ++++-
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f04333b..7b82ed1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -242,6 +242,15 @@ struct ubuf_info {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
+	/* Intermediate layers must ensure that destructor_arg
+	 * remains valid until skb destructor */
+	void		*destructor_arg;
+
+	/*
+	 * Warning: all fields from here until dataref are cleared in
+	 * __alloc_skb()
+	 *
+	 */
 	unsigned char	nr_frags;
 	__u8		tx_flags;
 	unsigned short	gso_size;
@@ -253,14 +262,10 @@ struct skb_shared_info {
 	__be32          ip6_frag_id;
 
 	/*
-	 * Warning : all fields before dataref are cleared in __alloc_skb()
+	 * Warning: all fields before dataref are cleared in __alloc_skb()
 	 */
 	atomic_t	dataref;
 
-	/* Intermediate layers must ensure that destructor_arg
-	 * remains valid until skb destructor */
-	void *		destructor_arg;
-
 	/* must be last field, see pskb_expand_head() */
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b6de604..934a9b4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -219,7 +219,10 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+
+	memset(&shinfo->nr_frags, 0,
+	       offsetof(struct skb_shared_info, dataref)
+	       - offsetof(struct skb_shared_info, nr_frags));
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 
-- 
1.7.2.5
