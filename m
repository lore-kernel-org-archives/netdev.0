From: =?UTF-8?Q?Jussi_M=C3=A4ki?= <joamaki@gmail.com>
Subject: [PATCH] xfrm: xfrm hash to use Jenkins' hash
Date: Wed, 5 Aug 2009 10:41:42 +0300
Message-ID: <ce10d01f0908050041p43c308fav72ac640f665e161f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:6545 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932890AbZHEHlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 03:41:42 -0400
Received: by qw-out-2122.google.com with SMTP id 8so2297295qwh.37
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2009 00:41:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The current xfrm hash functions perform very poorly when a number of
policies have the same
last byte in source and destination addresses.

For example with __xfrm_dst_hash, hmask of 0xfff:

192.168.0.1-172.16.0.1 hashes to 3258
192.168.0.2-172.16.0.2 hashes to 3258
... and so on.

This patch addresses the issue by rewriting the xfrm
hash functions to use the Jenkins' hash function.

Signed-off-by: Jussi Maki <joamaki@gmail.com>
---
 net/xfrm/xfrm_hash.h |   90 ++++++++++++++++++++++++++-----------------------
 1 files changed, 48 insertions(+), 42 deletions(-)

diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index d401dc8..59d4cb6 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -3,6 +3,7 @@

 #include <linux/xfrm.h>
 #include <linux/socket.h>
+#include <linux/jhash.h>

 static inline unsigned int __xfrm4_addr_hash(xfrm_address_t *addr)
 {
@@ -14,31 +15,27 @@ static inline unsigned int
__xfrm6_addr_hash(xfrm_address_t *addr)
 	return ntohl(addr->a6[2] ^ addr->a6[3]);
 }

-static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t
*daddr, xfrm_address_t *saddr)
-{
-	return ntohl(daddr->a4 ^ saddr->a4);
-}
-
-static inline unsigned int __xfrm6_daddr_saddr_hash(xfrm_address_t
*daddr, xfrm_address_t *saddr)
-{
-	return ntohl(daddr->a6[2] ^ daddr->a6[3] ^
-		     saddr->a6[2] ^ saddr->a6[3]);
-}
-
-static inline unsigned int __xfrm_dst_hash(xfrm_address_t *daddr,
xfrm_address_t *saddr,
-					   u32 reqid, unsigned short family,
+static inline unsigned int __xfrm_dst_hash(xfrm_address_t *daddr,
+					   xfrm_address_t *saddr,
+					   u32 reqid,
+					   unsigned short family,
 					   unsigned int hmask)
 {
-	unsigned int h = family ^ reqid;
+	unsigned int shash = 0;
+	unsigned int dhash = 0;
+
 	switch (family) {
 	case AF_INET:
-		h ^= __xfrm4_daddr_saddr_hash(daddr, saddr);
+		shash = __xfrm4_addr_hash(saddr);
+		dhash = __xfrm4_addr_hash(daddr);
 		break;
 	case AF_INET6:
-		h ^= __xfrm6_daddr_saddr_hash(daddr, saddr);
-		break;
+		shash = __xfrm6_addr_hash(saddr);
+		dhash = __xfrm6_addr_hash(daddr);
 	}
-	return (h ^ (h >> 16)) & hmask;
+
+	return jhash_3words(shash, dhash,
+			    reqid, family) & hmask;
 }

 static inline unsigned __xfrm_src_hash(xfrm_address_t *daddr,
@@ -46,32 +43,37 @@ static inline unsigned
__xfrm_src_hash(xfrm_address_t *daddr,
 				       unsigned short family,
 				       unsigned int hmask)
 {
-	unsigned int h = family;
+	unsigned int shash = 0;
+	unsigned int dhash = 0;
 	switch (family) {
 	case AF_INET:
-		h ^= __xfrm4_daddr_saddr_hash(daddr, saddr);
+		shash = __xfrm4_addr_hash(saddr);
+		dhash = __xfrm4_addr_hash(daddr);
 		break;
 	case AF_INET6:
-		h ^= __xfrm6_daddr_saddr_hash(daddr, saddr);
-		break;
-	};
-	return (h ^ (h >> 16)) & hmask;
+		shash = __xfrm6_addr_hash(saddr);
+		dhash = __xfrm6_addr_hash(daddr);
+	}
+	return jhash_2words(shash, dhash, family) & hmask;
 }

 static inline unsigned int
-__xfrm_spi_hash(xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned
short family,
+__xfrm_spi_hash(xfrm_address_t *daddr, __be32 spi, u8 proto,
+		unsigned short family,
 		unsigned int hmask)
 {
-	unsigned int h = (__force u32)spi ^ proto;
+	unsigned int h = 0;
+
 	switch (family) {
 	case AF_INET:
-		h ^= __xfrm4_addr_hash(daddr);
+		h = __xfrm4_addr_hash(daddr);
 		break;
 	case AF_INET6:
-		h ^= __xfrm6_addr_hash(daddr);
+		h = __xfrm6_addr_hash(daddr);
 		break;
 	}
-	return (h ^ (h >> 10) ^ (h >> 20)) & hmask;
+
+	return jhash_3words(h, spi, proto, family) & hmask;
 }

 static inline unsigned int __idx_hash(u32 index, unsigned int hmask)
@@ -83,7 +85,8 @@ static inline unsigned int __sel_hash(struct
xfrm_selector *sel, unsigned short
 {
 	xfrm_address_t *daddr = &sel->daddr;
 	xfrm_address_t *saddr = &sel->saddr;
-	unsigned int h = 0;
+	unsigned int shash = 0;
+	unsigned int dhash = 0;

 	switch (family) {
 	case AF_INET:
@@ -91,7 +94,8 @@ static inline unsigned int __sel_hash(struct
xfrm_selector *sel, unsigned short
 		    sel->prefixlen_s != 32)
 			return hmask + 1;

-		h = __xfrm4_daddr_saddr_hash(daddr, saddr);
+		shash = __xfrm4_addr_hash(saddr);
+		dhash = __xfrm4_addr_hash(daddr);
 		break;

 	case AF_INET6:
@@ -99,28 +103,30 @@ static inline unsigned int __sel_hash(struct
xfrm_selector *sel, unsigned short
 		    sel->prefixlen_s != 128)
 			return hmask + 1;

-		h = __xfrm6_daddr_saddr_hash(daddr, saddr);
+		shash = __xfrm6_addr_hash(saddr);
+		dhash = __xfrm6_addr_hash(daddr);
 		break;
 	};
-	h ^= (h >> 16);
-	return h & hmask;
+
+	return jhash_2words(shash, dhash, family) & hmask;
 }

 static inline unsigned int __addr_hash(xfrm_address_t *daddr,
xfrm_address_t *saddr, unsigned short family, unsigned int hmask)
 {
-	unsigned int h = 0;
+	unsigned int shash = 0;
+	unsigned int dhash = 0;

 	switch (family) {
 	case AF_INET:
-		h = __xfrm4_daddr_saddr_hash(daddr, saddr);
+		shash = __xfrm4_addr_hash(saddr);
+		dhash = __xfrm4_addr_hash(daddr);
 		break;
-
 	case AF_INET6:
-		h = __xfrm6_daddr_saddr_hash(daddr, saddr);
-		break;
-	};
-	h ^= (h >> 16);
-	return h & hmask;
+		shash = __xfrm6_addr_hash(saddr);
+		dhash = __xfrm6_addr_hash(daddr);
+	}
+
+	return jhash_2words(shash, dhash, family) & hmask;
 }

 extern struct hlist_head *xfrm_hash_alloc(unsigned int sz);
--
