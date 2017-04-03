From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 1/1] skbuff: Extend gso_type to unsigned int.
Date: Mon, 3 Apr 2017 10:15:52 +0200
Message-ID: <1491207352-27585-2-git-send-email-steffen.klassert@secunet.com>
References: <1491207352-27585-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50596 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751168AbdDCI1B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 04:27:01 -0400
In-Reply-To: <1491207352-27585-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All available gso_type flags are currently in use, so
extend gso_type from 'unsigned short' to 'unsigned int'
to be able to add further flags.

We also reorder the struct skb_shared_info to use
two bytes of the four byte hole before dataref.
All fields before _unused are cleared now, i.e.
two bytes more than before the change.

Structure layout on x86-64 before the change:

struct skb_shared_info {
	unsigned char              nr_frags;             /*     0     1 */
	__u8                       tx_flags;             /*     1     1 */
	short unsigned int         gso_size;             /*     2     2 */
	short unsigned int         gso_segs;             /*     4     2 */
	short unsigned int         gso_type;             /*     6     2 */
	struct sk_buff *           frag_list;            /*     8     8 */
	struct skb_shared_hwtstamps hwtstamps;           /*    16     8 */
	u32                        tskey;                /*    24     4 */
	__be32                     ip6_frag_id;          /*    28     4 */
	atomic_t                   dataref;              /*    32     4 */

	/* XXX 4 bytes hole, try to pack */

	void *                     destructor_arg;       /*    40     8 */
	skb_frag_t                 frags[17];            /*    48   272 */
	/* --- cacheline 5 boundary (320 bytes) --- */

	/* size: 320, cachelines: 5, members: 12 */
	/* sum members: 316, holes: 1, sum holes: 4 */
};

Structure layout on x86-64 after the change:

struct skb_shared_info {
	struct sk_buff *           frag_list;            /*     0     8 */
	struct skb_shared_hwtstamps hwtstamps;           /*     8     8 */
	u32                        tskey;                /*    16     4 */
	__be32                     ip6_frag_id;          /*    20     4 */
	unsigned int               gso_type;             /*    24     4 */
	unsigned char              nr_frags;             /*    28     1 */
	__u8                       tx_flags;             /*    29     1 */
	short unsigned int         gso_size;             /*    30     2 */
	short unsigned int         gso_segs;             /*    32     2 */
	short unsigned int         _unused;              /*    34     2 */
	atomic_t                   dataref;              /*    36     4 */
	void *                     destructor_arg;       /*    40     8 */
	skb_frag_t                 frags[17];            /*    48   272 */
	/* --- cacheline 5 boundary (320 bytes) --- */

	/* size: 320, cachelines: 5, members: 13 */
};

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/skbuff.h | 13 +++++++------
 net/core/skbuff.c      |  2 +-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c776abd..cb36159 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -413,20 +413,21 @@ struct ubuf_info {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
+	struct sk_buff	*frag_list;
+	struct skb_shared_hwtstamps hwtstamps;
+	u32		tskey;
+	__be32          ip6_frag_id;
+	unsigned int	gso_type;
 	unsigned char	nr_frags;
 	__u8		tx_flags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
 	unsigned short	gso_segs;
-	unsigned short  gso_type;
-	struct sk_buff	*frag_list;
-	struct skb_shared_hwtstamps hwtstamps;
-	u32		tskey;
-	__be32          ip6_frag_id;
 
 	/*
-	 * Warning : all fields before dataref are cleared in __alloc_skb()
+	 * Warning : all fields before _unused are cleared in __alloc_skb()
 	 */
+	unsigned short	_unused;
 	atomic_t	dataref;
 
 	/* Intermediate layers must ensure that destructor_arg
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9f78109..8796b93 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -257,7 +257,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+	memset(shinfo, 0, offsetof(struct skb_shared_info, _unused));
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 
-- 
2.7.4
