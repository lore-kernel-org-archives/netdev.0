From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] fib_semantics: prevent long hash chains in access server config
Date: Sat, 12 Jan 2008 13:58:19 -0500
Message-ID: <20080112185819.GA12775@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:44415 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756740AbYALS6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 13:58:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a patch from a while ago that I'm resending.  Basically, in access 
server configurations, a lot of routes have the same local ip address but on 
different devices.  This fixes the long chains that result from not including 
the device index in the hash.

		-ben

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1351a26..5375824 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -196,11 +196,21 @@ static __inline__ int nh_comp(const struct fib_info *fi, const struct fib_info *
 	return 0;
 }
 
+static inline unsigned int fib_devindex_hashfn(unsigned int val)
+{
+	unsigned int mask = DEVINDEX_HASHSIZE - 1;
+
+	return (val ^
+		(val >> DEVINDEX_HASHBITS) ^
+		(val >> (DEVINDEX_HASHBITS * 2))) & mask;
+}
+
 static inline unsigned int fib_info_hashfn(const struct fib_info *fi)
 {
 	unsigned int mask = (fib_hash_size - 1);
 	unsigned int val = fi->fib_nhs;
 
+	val ^= fib_devindex_hashfn(fi->fib_dev->ifindex);
 	val ^= fi->fib_protocol;
 	val ^= (__force u32)fi->fib_prefsrc;
 	val ^= fi->fib_priority;
@@ -234,15 +244,6 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 	return NULL;
 }
 
-static inline unsigned int fib_devindex_hashfn(unsigned int val)
-{
-	unsigned int mask = DEVINDEX_HASHSIZE - 1;
-
-	return (val ^
-		(val >> DEVINDEX_HASHBITS) ^
-		(val >> (DEVINDEX_HASHBITS * 2))) & mask;
-}
-
 /* Check, that the gateway is already configured.
    Used only by redirect accept routine.
  */
