From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/2] inet: generalize ipv4-only RFC3168 5.3 ecn fragmentation handling for future use by ipv6
Date: Fri, 22 Mar 2013 19:24:37 +0100
Message-ID: <20130322182437.GC19365@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, jbrouer@redhat.com, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52600 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422649Ab3CVSYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 14:24:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just moves some code arround to make the ip4_frag_ecn_table
and IPFRAG_ECN_* constants accessible from the other reassembly engines. I
also renamed ip4_frag_ecn_table to ip_frag_ecn_table.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_frag.h  | 12 ++++++++++++
 net/ipv4/inet_fragment.c | 22 ++++++++++++++++++++++
 net/ipv4/ip_fragment.c   | 31 +------------------------------
 3 files changed, 35 insertions(+), 30 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 0a1dcc2..64b4e7d 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -153,4 +153,16 @@ static inline void inet_frag_lru_add(struct netns_frags *nf,
 	list_add_tail(&q->lru_list, &nf->lru_list);
 	spin_unlock(&nf->lru_lock);
 }
+
+/* RFC 3168 support :
+ * We want to check ECN values of all fragments, do detect invalid combinations.
+ * In ipq->ecn, we store the OR value of each ip4_frag_ecn() fragment value.
+ */
+#define	IPFRAG_ECN_NOT_ECT	0x01 /* one frag had ECN_NOT_ECT */
+#define	IPFRAG_ECN_ECT_1	0x02 /* one frag had ECN_ECT_1 */
+#define	IPFRAG_ECN_ECT_0	0x04 /* one frag had ECN_ECT_0 */
+#define	IPFRAG_ECN_CE		0x08 /* one frag had ECN_CE */
+
+extern const u8 ip_frag_ecn_table[16];
+
 #endif
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index f4fd23d..2bff045 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -23,6 +23,28 @@
 
 #include <net/sock.h>
 #include <net/inet_frag.h>
+#include <net/inet_ecn.h>
+
+/* Given the OR values of all fragments, apply RFC 3168 5.3 requirements
+ * Value : 0xff if frame should be dropped.
+ *         0 or INET_ECN_CE value, to be ORed in to final iph->tos field
+ */
+const u8 ip_frag_ecn_table[16] = {
+	/* at least one fragment had CE, and others ECT_0 or ECT_1 */
+	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0]			= INET_ECN_CE,
+	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1]			= INET_ECN_CE,
+	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1]	= INET_ECN_CE,
+
+	/* invalid combinations : drop frame */
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_0] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_1] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1] = 0xff,
+};
+EXPORT_SYMBOL(ip_frag_ecn_table);
 
 static void inet_frag_secret_rebuild(unsigned long dummy)
 {
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a6445b8..9385206 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -79,40 +79,11 @@ struct ipq {
 	struct inet_peer *peer;
 };
 
-/* RFC 3168 support :
- * We want to check ECN values of all fragments, do detect invalid combinations.
- * In ipq->ecn, we store the OR value of each ip4_frag_ecn() fragment value.
- */
-#define	IPFRAG_ECN_NOT_ECT	0x01 /* one frag had ECN_NOT_ECT */
-#define	IPFRAG_ECN_ECT_1	0x02 /* one frag had ECN_ECT_1 */
-#define	IPFRAG_ECN_ECT_0	0x04 /* one frag had ECN_ECT_0 */
-#define	IPFRAG_ECN_CE		0x08 /* one frag had ECN_CE */
-
 static inline u8 ip4_frag_ecn(u8 tos)
 {
 	return 1 << (tos & INET_ECN_MASK);
 }
 
-/* Given the OR values of all fragments, apply RFC 3168 5.3 requirements
- * Value : 0xff if frame should be dropped.
- *         0 or INET_ECN_CE value, to be ORed in to final iph->tos field
- */
-static const u8 ip4_frag_ecn_table[16] = {
-	/* at least one fragment had CE, and others ECT_0 or ECT_1 */
-	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0]			= INET_ECN_CE,
-	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1]			= INET_ECN_CE,
-	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1]	= INET_ECN_CE,
-
-	/* invalid combinations : drop frame */
-	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE] = 0xff,
-	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_0] = 0xff,
-	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_1] = 0xff,
-	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1] = 0xff,
-	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0] = 0xff,
-	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1] = 0xff,
-	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1] = 0xff,
-};
-
 static struct inet_frags ip4_frags;
 
 int ip_frag_nqueues(struct net *net)
@@ -551,7 +522,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 
 	ipq_kill(qp);
 
-	ecn = ip4_frag_ecn_table[qp->ecn];
+	ecn = ip_frag_ecn_table[qp->ecn];
 	if (unlikely(ecn == 0xff)) {
 		err = -EINVAL;
 		goto out_fail;
-- 
1.8.1.4
