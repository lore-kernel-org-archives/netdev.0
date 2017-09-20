From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 4/5] net: add simple socket-like dst cache helpers
Date: Wed, 20 Sep 2017 18:54:04 +0200
Message-ID: <36a1ee841087089c1ba364a3fb89282674a9a80b.1505926196.git.pabeni@redhat.com>
References: <cover.1505926196.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52760 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750938AbdITQ6P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 12:58:15 -0400
In-Reply-To: <cover.1505926196.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be used by later patches to reduce code duplication.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/dst.h | 12 ++++++++++++
 net/core/dst.c    | 16 ++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/net/dst.h b/include/net/dst.h
index 93568bd0a352..a6a39357f19a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -485,6 +485,18 @@ static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 	return dst;
 }
 
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
index a6c47da7d0f8..6aff0a3e7ba3 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -205,6 +205,22 @@ void dst_release_immediate(struct dst_entry *dst)
 }
 EXPORT_SYMBOL(dst_release_immediate);
 
+/* 'dst' is not refcounted */
+bool dst_update(struct dst_entry **cache, struct dst_entry *dst)
+{
+	if (likely(*cache == dst))
+		return false;
+
+	if (dst_hold_safe(dst)) {
+		struct dst_entry *old = xchg(cache, dst);
+
+		dst_release(old);
+		return old != dst;
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(dst_update);
+
 u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old)
 {
 	struct dst_metrics *p = kmalloc(sizeof(*p), GFP_ATOMIC);
-- 
2.13.5
