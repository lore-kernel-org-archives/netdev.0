From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/5] net: Add helper function to compare inetpeer addresses
Date: Thu, 27 Aug 2015 14:16:31 -0700
Message-ID: <1440710193-4824-4-git-send-email-dsa@cumulusnetworks.com>
References: <1440710193-4824-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34938 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbbH0VR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:17:59 -0400
Received: by pacdd16 with SMTP id dd16so37742708pac.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 14:17:59 -0700 (PDT)
In-Reply-To: <1440710193-4824-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_metrics and inetpeer both have functions to compare inetpeer
addresses. Consolidate into 1 version.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/inetpeer.h | 16 ++++++++++++++++
 net/ipv4/inetpeer.c    | 20 ++------------------
 net/ipv4/tcp_metrics.c |  6 +-----
 3 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index f75b9e7036a2..9d9b3446731d 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -121,6 +121,22 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
 	return inet_getpeer(base, &daddr, create);
 }
 
+static inline int inetpeer_addr_cmp(const struct inetpeer_addr *a,
+				    const struct inetpeer_addr *b)
+{
+	int i, n = (a->family == AF_INET ? 1 : 4);
+
+	for (i = 0; i < n; i++) {
+		if (a->addr.a6[i] == b->addr.a6[i])
+			continue;
+		if ((__force u32)a->addr.a6[i] < (__force u32)b->addr.a6[i])
+			return -1;
+		return 1;
+	}
+
+	return 0;
+}
+
 /* can be called from BH context or outside */
 void inet_putpeer(struct inet_peer *p);
 bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 241afd743d2c..86fa45809540 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -157,22 +157,6 @@ void __init inet_initpeers(void)
 	INIT_DEFERRABLE_WORK(&gc_work, inetpeer_gc_worker);
 }
 
-static int addr_compare(const struct inetpeer_addr *a,
-			const struct inetpeer_addr *b)
-{
-	int i, n = (a->family == AF_INET ? 1 : 4);
-
-	for (i = 0; i < n; i++) {
-		if (a->addr.a6[i] == b->addr.a6[i])
-			continue;
-		if ((__force u32)a->addr.a6[i] < (__force u32)b->addr.a6[i])
-			return -1;
-		return 1;
-	}
-
-	return 0;
-}
-
 #define rcu_deref_locked(X, BASE)				\
 	rcu_dereference_protected(X, lockdep_is_held(&(BASE)->lock.lock))
 
@@ -188,7 +172,7 @@ static int addr_compare(const struct inetpeer_addr *a,
 	*stackptr++ = &_base->root;				\
 	for (u = rcu_deref_locked(_base->root, _base);		\
 	     u != peer_avl_empty;) {				\
-		int cmp = addr_compare(_daddr, &u->daddr);	\
+		int cmp = inetpeer_addr_cmp(_daddr, &u->daddr);	\
 		if (cmp == 0)					\
 			break;					\
 		if (cmp == -1)					\
@@ -215,7 +199,7 @@ static struct inet_peer *lookup_rcu(const struct inetpeer_addr *daddr,
 	int count = 0;
 
 	while (u != peer_avl_empty) {
-		int cmp = addr_compare(daddr, &u->daddr);
+		int cmp = inetpeer_addr_cmp(daddr, &u->daddr);
 		if (cmp == 0) {
 			/* Before taking a reference, check if this entry was
 			 * deleted (refcnt=-1)
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 4ef4dd4bf38c..c8cbc2b4b792 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -81,11 +81,7 @@ static void tcp_metric_set(struct tcp_metrics_block *tm,
 static bool addr_same(const struct inetpeer_addr *a,
 		      const struct inetpeer_addr *b)
 {
-	if (a->family != b->family)
-		return false;
-	if (a->family == AF_INET)
-		return a->addr.a4 == b->addr.a4;
-	return ipv6_addr_equal(&a->addr.in6, &b->addr.in6);
+	return inetpeer_addr_cmp(a, b) == 0;
 }
 
 struct tcpm_hash_bucket {
-- 
1.9.1
