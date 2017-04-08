From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 0/1 v2] skbuff: Extend gso_type to unsigned int.
Date: Sat, 8 Apr 2017 20:36:24 +0200
Message-ID: <1491676584-22421-2-git-send-email-steffen.klassert@secunet.com>
References: <1491676584-22421-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46652 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753098AbdDHSgu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 14:36:50 -0400
In-Reply-To: <1491676584-22421-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All available gso_type flags are currently in use, so
extend gso_type from 'unsigned short' to 'unsigned int'
to be able to add further flags.

We reorder the struct skb_shared_info to use
two bytes of the four byte hole before dataref.
All fields before dataref are cleared, i.e.
four bytes more than before the change.

The remaining two byte hole is moved to the
beginning of the structure, this protects us
from immediate overwites on out of bound writes
to the sk_buff head.

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
	short unsigned int         _unused;              /*     0     2 */
	unsigned char              nr_frags;             /*     2     1 */
	__u8                       tx_flags;             /*     3     1 */
	short unsigned int         gso_size;             /*     4     2 */
	short unsigned int         gso_segs;             /*     6     2 */
	struct sk_buff *           frag_list;            /*     8     8 */
	struct skb_shared_hwtstamps hwtstamps;           /*    16     8 */
	unsigned int               gso_type;             /*    24     4 */
	u32                        tskey;                /*    28     4 */
	__be32                     ip6_frag_id;          /*    32     4 */
	atomic_t                   dataref;              /*    36     4 */
	void *                     destructor_arg;       /*    40     8 */
	skb_frag_t                 frags[17];            /*    48   272 */
	/* --- cacheline 5 boundary (320 bytes) --- */

	/* size: 320, cachelines: 5, members: 13 */
};

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/skbuff.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c776abd..741d75c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -413,14 +413,15 @@ struct ubuf_info {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
+	unsigned short	_unused;
 	unsigned char	nr_frags;
 	__u8		tx_flags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
 	unsigned short	gso_segs;
-	unsigned short  gso_type;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
+	unsigned int	gso_type;
 	u32		tskey;
 	__be32          ip6_frag_id;
 
-- 
2.7.4
