From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_semantics: prevent long hash chains in access
 server config
Date: Sun, 13 Jan 2008 18:11:18 -0800 (PST)
Message-ID: <20080113.181118.08046749.davem@davemloft.net>
References: <20080112185819.GA12775@kvack.org>
	<20080112.213857.68003780.davem@davemloft.net>
	<20080113175849.GC12775@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47351
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753947AbYANCLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 21:11:19 -0500
In-Reply-To: <20080113175849.GC12775@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Sun, 13 Jan 2008 12:58:49 -0500

> Ah, you're right indeed.  It's probably easier for me to change how the 
> daemon adds the local ip address for these point to point interfaces.

I guess you didn't understand, I checked in the following
patch which implements things correctly.

commit d5414fdd4098742a5a9d255c4b9af587318c525f
Author: David S. Miller <davem@davemloft.net>
Date:   Sat Jan 12 21:49:01 2008 -0800

    [IPV4] FIB: Include nexthop device indexes in fib_info hashfn.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3ed920b..0e08df4 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -194,6 +194,15 @@ static __inline__ int nh_comp(const struct fib_info *fi, const struct fib_info *
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
@@ -202,6 +211,9 @@ static inline unsigned int fib_info_hashfn(const struct fib_info *fi)
 	val ^= fi->fib_protocol;
 	val ^= (__force u32)fi->fib_prefsrc;
 	val ^= fi->fib_priority;
+	for_nexthops(fi) {
+		val ^= fib_devindex_hashfn(nh->nh_oif);
+	} endfor_nexthops(fi)
 
 	return (val ^ (val >> 7) ^ (val >> 12)) & mask;
 }
@@ -232,15 +244,6 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
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
