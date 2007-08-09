From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 15/24] make atomic_read() behave consistently on powerpc
Date: Thu, 9 Aug 2007 10:04:12 -0400
Message-ID: <20070809140412.GA17660@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932387AbXHIOEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:04:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Purify volatile use for atomic[64]_t on powerpc.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-powerpc/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-powerpc/atomic.h	2007-08-09 07:15:21.000000000 -0400
@@ -5,7 +5,7 @@
  * PowerPC atomic operations
  */
 
-typedef struct { volatile int counter; } atomic_t;
+typedef struct { int counter; } atomic_t;
 
 #ifdef __KERNEL__
 #include <linux/compiler.h>
@@ -15,7 +15,11 @@ typedef struct { volatile int counter; }
 
 #define ATOMIC_INIT(i)		{ (i) }
 
-#define atomic_read(v)		((v)->counter)
+/*
+ * Casting to volatile here minimizes the need for barriers,
+ * without having to declare the type itself as volatile.
+ */
+#define atomic_read(v)		(*(volatile int *)&(v)->counter)
 #define atomic_set(v,i)		(((v)->counter) = (i))
 
 static __inline__ void atomic_add(int a, atomic_t *v)
@@ -240,11 +244,11 @@ static __inline__ int atomic_dec_if_posi
 
 #ifdef __powerpc64__
 
-typedef struct { volatile long counter; } atomic64_t;
+typedef struct { long counter; } atomic64_t;
 
 #define ATOMIC64_INIT(i)	{ (i) }
 
-#define atomic64_read(v)	((v)->counter)
+#define atomic64_read(v)	(*(volatile long *)&(v)->counter)
 #define atomic64_set(v,i)	(((v)->counter) = (i))
 
 static __inline__ void atomic64_add(long a, atomic64_t *v)
