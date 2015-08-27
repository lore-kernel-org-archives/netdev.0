From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/5 v2] net: Refactor inetpeer address struct
Date: Thu, 27 Aug 2015 16:07:02 -0700
Message-ID: <1440716823-19568-5-git-send-email-dsa@cumulusnetworks.com>
References: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35433 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043AbbH0XHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:07:14 -0400
Received: by pacdd16 with SMTP id dd16so40244049pac.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 16:07:14 -0700 (PDT)
In-Reply-To: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the inetpeer_addr_base union to inetpeer_addr and drop
inetpeer_addr_base.

Both the a6 and in6_addr overlays are not needed; drop the __be32 version
and rename in6 to a6 for consistency with ipv4. Add a new u32 array to
the union which removes the need for the typecast in the compare function
and the use of a consistent arg for both ipv4 and ipv6 addresses which
makes the compare function more readable.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2:
- fix number of words to be compared; dropped the '/ sizeof(u32)' in v1

 include/net/inetpeer.h | 35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 9d9b3446731d..e34f98aa93b1 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -15,16 +15,14 @@
 #include <net/ipv6.h>
 #include <linux/atomic.h>
 
-struct inetpeer_addr_base {
+#define INETPEER_MAXKEYSZ   (sizeof(struct in6_addr) / sizeof(u32))
+
+struct inetpeer_addr {
 	union {
 		__be32			a4;
-		__be32			a6[4];
-		struct in6_addr		in6;
+		struct in6_addr		a6;
+		u32			key[INETPEER_MAXKEYSZ];
 	};
-};
-
-struct inetpeer_addr {
-	struct inetpeer_addr_base	addr;
 	__u16				family;
 };
 
@@ -73,25 +71,25 @@ void inet_initpeers(void) __init;
 
 static inline void inetpeer_set_addr_v4(struct inetpeer_addr *iaddr, __be32 ip)
 {
-	iaddr->addr.a4 = ip;
+	iaddr->a4 = ip;
 	iaddr->family = AF_INET;
 }
 
 static inline __be32 inetpeer_get_addr_v4(struct inetpeer_addr *iaddr)
 {
-	return iaddr->addr.a4;
+	return iaddr->a4;
 }
 
 static inline void inetpeer_set_addr_v6(struct inetpeer_addr *iaddr,
 					struct in6_addr *in6)
 {
-	iaddr->addr.in6 = *in6;
+	iaddr->a6 = *in6;
 	iaddr->family = AF_INET6;
 }
 
 static inline struct in6_addr *inetpeer_get_addr_v6(struct inetpeer_addr *iaddr)
 {
-	return &iaddr->addr.in6;
+	return &iaddr->a6;
 }
 
 /* can be called with or without local BH being disabled */
@@ -105,7 +103,7 @@ static inline struct inet_peer *inet_getpeer_v4(struct inet_peer_base *base,
 {
 	struct inetpeer_addr daddr;
 
-	daddr.addr.a4 = v4daddr;
+	daddr.a4 = v4daddr;
 	daddr.family = AF_INET;
 	return inet_getpeer(base, &daddr, create);
 }
@@ -116,7 +114,7 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
 {
 	struct inetpeer_addr daddr;
 
-	daddr.addr.in6 = *v6daddr;
+	daddr.a6 = *v6daddr;
 	daddr.family = AF_INET6;
 	return inet_getpeer(base, &daddr, create);
 }
@@ -124,12 +122,17 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
 static inline int inetpeer_addr_cmp(const struct inetpeer_addr *a,
 				    const struct inetpeer_addr *b)
 {
-	int i, n = (a->family == AF_INET ? 1 : 4);
+	int i, n;
+
+	if (a->family == AF_INET)
+		n = sizeof(a->a4) / sizeof(u32);
+	else
+		n = sizeof(a->a6) / sizeof(u32);
 
 	for (i = 0; i < n; i++) {
-		if (a->addr.a6[i] == b->addr.a6[i])
+		if (a->key[i] == b->key[i])
 			continue;
-		if ((__force u32)a->addr.a6[i] < (__force u32)b->addr.a6[i])
+		if (a->key[i] < b->key[i])
 			return -1;
 		return 1;
 	}
-- 
1.9.1
