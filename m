From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 04/11] net: add simple socket-like dst cache helpers
Date: Fri, 22 Sep 2017 23:06:28 +0200
Message-ID: <280e7c35539483d58163adab20d19a954e1b08cb.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752694AbdIVVHE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:07:04 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be used by later patches to reduce code duplication.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/dst.h | 20 ++++++++++++++++++++
 net/core/dst.c    | 12 ++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/net/dst.h b/include/net/dst.h
index 93568bd0a352..4fcca0e368c6 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -485,6 +485,26 @@ static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 	return dst;
 }
 
+/* update the cache with dst, assuming the latter already carries a refcount */
+static inline bool __dst_update(struct dst_entry **cache, struct dst_entry *dst)
+{
+	struct dst_entry *old = xchg(cache, dst);
+
+	dst_release(old);
+	return old != dst;
+}
+bool dst_update(struct dst_entry **cache, struct dst_entry *dst);
+static inline struct dst_entry *dst_access(struct dst_entry **cache,
+					      u32 cookie)
+{
+	struct dst_entry *dst = READ_ONCE(*cache);
+
+	if (!dst)
+		return NULL;
+
+	return dst_check(dst, cookie);
+}
+
 /* Flags for xfrm_lookup flags argument. */
 enum {
 	XFRM_LOOKUP_ICMP = 1 << 0,
diff --git a/net/core/dst.c b/net/core/dst.c
index a6c47da7d0f8..4076f9af45d7 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -205,6 +205,18 @@ void dst_release_immediate(struct dst_entry *dst)
 }
 EXPORT_SYMBOL(dst_release_immediate);
 
+/* update the cache with dst, assuming the latter does not carry a refcount */
+bool dst_update(struct dst_entry **cache, struct dst_entry *dst)
+{
+	if (likely(*cache == dst))
+		return false;
+
+	if (dst_hold_safe(dst))
+		return __dst_update(cache, dst);
+	return false;
+}
+EXPORT_SYMBOL_GPL(dst_update);
+
 u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old)
 {
 	struct dst_metrics *p = kmalloc(sizeof(*p), GFP_ATOMIC);
-- 
2.13.5
