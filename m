From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 04/21] net: introduce DST_NOGC in dst_release() to destroy dst based on refcnt
Date: Sat, 17 Jun 2017 10:42:27 -0700
Message-ID: <20170617174244.132862-5-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34937 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752755AbdFQRnq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id s66so11093245pfs.2
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:41 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

The current mechanism of freeing dst is a bit complicated. dst has its
ref count and when user grabs the reference to the dst, the ref count is
properly taken in most cases except in IPv4/IPv6/decnet/xfrm routing
code due to some historic reasons.

If the reference to dst is always taken properly, we should be able to
simplify the logic in dst_release() to destroy dst when dst->__refcnt
drops from 1 to 0. And this should be the only condition to determine
if we can call dst_destroy().
And as dst is always ref counted, there is no need for a dst garbage
list to hold the dst entries that already get removed by the routing
code but are still held by other users. And the task to periodically
check the list to free dst if ref count become 0 is also not needed
anymore.

This patch introduces a temporary flag DST_NOGC(no garbage collector).
If it is set in the dst, dst_release() will call dst_destroy() when
dst->__refcnt drops to 0. dst_hold_safe() will also check for this flag
and do atomic_inc_not_zero() similar as DST_NOCACHE to avoid double free
issue.
This temporary flag is mainly used so that we can make the transition
component by component without breaking other parts.
This flag will be removed after all components are properly transitioned.

This patch also introduces a new function dst_release_immediate() which
destroys dst without waiting on the rcu when refcnt drops to 0. It will
be used in later patches.

Follow-up patches will correct all the places to properly take ref count
on dst and mark DST_NOGC. dst_release() or dst_release_immediate() will
be used to release the dst instead of dst_free() and its related
functions.
And final clean-up patch will remove the DST_NOGC flag.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/dst.h |  5 ++++-
 net/core/dst.c    | 20 ++++++++++++++++++--
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 1969008783d8..2735d5a1e774 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -58,6 +58,7 @@ struct dst_entry {
 #define DST_XFRM_TUNNEL		0x0080
 #define DST_XFRM_QUEUE		0x0100
 #define DST_METADATA		0x0200
+#define DST_NOGC		0x0400
 
 	short			error;
 
@@ -278,6 +279,8 @@ static inline struct dst_entry *dst_clone(struct dst_entry *dst)
 
 void dst_release(struct dst_entry *dst);
 
+void dst_release_immediate(struct dst_entry *dst);
+
 static inline void refdst_drop(unsigned long refdst)
 {
 	if (!(refdst & SKB_DST_NOREF))
@@ -334,7 +337,7 @@ static inline void skb_dst_force(struct sk_buff *skb)
  */
 static inline bool dst_hold_safe(struct dst_entry *dst)
 {
-	if (dst->flags & DST_NOCACHE)
+	if (dst->flags & (DST_NOCACHE | DST_NOGC))
 		return atomic_inc_not_zero(&dst->__refcnt);
 	dst_hold(dst);
 	return true;
diff --git a/net/core/dst.c b/net/core/dst.c
index 13ba4a090c41..551834c3363f 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -300,18 +300,34 @@ void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
 		int newrefcnt;
-		unsigned short nocache = dst->flags & DST_NOCACHE;
+		unsigned short destroy_after_rcu = dst->flags &
+						   (DST_NOCACHE | DST_NOGC);
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
 		if (unlikely(newrefcnt < 0))
 			net_warn_ratelimited("%s: dst:%p refcnt:%d\n",
 					     __func__, dst, newrefcnt);
-		if (!newrefcnt && unlikely(nocache))
+		if (!newrefcnt && unlikely(destroy_after_rcu))
 			call_rcu(&dst->rcu_head, dst_destroy_rcu);
 	}
 }
 EXPORT_SYMBOL(dst_release);
 
+void dst_release_immediate(struct dst_entry *dst)
+{
+	if (dst) {
+		int newrefcnt;
+
+		newrefcnt = atomic_dec_return(&dst->__refcnt);
+		if (unlikely(newrefcnt < 0))
+			net_warn_ratelimited("%s: dst:%p refcnt:%d\n",
+					     __func__, dst, newrefcnt);
+		if (!newrefcnt)
+			dst_destroy(dst);
+	}
+}
+EXPORT_SYMBOL(dst_release_immediate);
+
 u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old)
 {
 	struct dst_metrics *p = kmalloc(sizeof(*p), GFP_ATOMIC);
-- 
2.13.1.518.g3df882009-goog
