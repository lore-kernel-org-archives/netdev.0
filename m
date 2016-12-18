From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC net-next 7/7] net: pending_confirm is not used anymore
Date: Sun, 18 Dec 2016 22:56:36 +0200
Message-ID: <1482094596-26046-8-git-send-email-ja@ssi.bg>
References: <1482094596-26046-1-git-send-email-ja@ssi.bg>
Cc: linux-sctp@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46915 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753874AbcLRU5q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Dec 2016 15:57:46 -0500
In-Reply-To: <1482094596-26046-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When same struct dst_entry can be used for many different
neighbours we can not use it for pending confirmations.
As last step, we can remove the pending_confirm flag.

Reported-by: YueHaibing <yuehaibing@huawei.com>
Fixes: 5110effee8fd ("net: Do delayed neigh confirmation.")
Fixes: f2bb4bedf35d ("ipv4: Cache output routes in fib_info nexthops.")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/dst.h | 14 ++------------
 net/core/dst.c    |  1 -
 2 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 3a3b34b..84a1043 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -59,8 +59,6 @@ struct dst_entry {
 #define DST_XFRM_QUEUE		0x0100
 #define DST_METADATA		0x0200
 
-	unsigned short		pending_confirm;
-
 	short			error;
 
 	/* A non-zero value of dst->obsolete forces by-hand validation
@@ -78,6 +76,8 @@ struct dst_entry {
 #define DST_OBSOLETE_KILL	-2
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
+	unsigned short		__pad3;
+
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	__u32			tclassid;
 #else
@@ -440,7 +440,6 @@ static inline void dst_rcu_free(struct rcu_head *head)
 
 static inline void dst_confirm(struct dst_entry *dst)
 {
-	dst->pending_confirm = 1;
 }
 
 static inline int dst_neigh_output(struct dst_entry *dst, struct neighbour *n,
@@ -448,15 +447,6 @@ static inline int dst_neigh_output(struct dst_entry *dst, struct neighbour *n,
 {
 	const struct hh_cache *hh;
 
-	if (dst->pending_confirm) {
-		unsigned long now = jiffies;
-
-		dst->pending_confirm = 0;
-		/* avoid dirtying neighbour */
-		if (n->confirmed != now)
-			n->confirmed = now;
-	}
-
 	hh = &n->hh;
 	if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
 		return neigh_hh_output(hh, skb);
diff --git a/net/core/dst.c b/net/core/dst.c
index b5cbbe0..960e503 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -190,7 +190,6 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	dst->__use = 0;
 	dst->lastuse = jiffies;
 	dst->flags = flags;
-	dst->pending_confirm = 0;
 	dst->next = NULL;
 	if (!(flags & DST_NOCOUNT))
 		dst_entries_add(ops, 1);
-- 
1.9.3
