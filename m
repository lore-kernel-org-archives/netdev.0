From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 14/24] make atomic_read() behave consistently on parisc
Date: Thu, 9 Aug 2007 10:01:54 -0400
Message-ID: <20070809140154.GA17489@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:50451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933695AbXHIOCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:02:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Purify volatile use for atomic[64]_t on parisc.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-parisc/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-parisc/atomic.h	2007-08-09 07:11:38.000000000 -0400
@@ -128,7 +128,7 @@ __cmpxchg(volatile void *ptr, unsigned l
  * Cache-line alignment would conflict with, for example, linux/module.h
  */
 
-typedef struct { volatile int counter; } atomic_t;
+typedef struct { int counter; } atomic_t;
 
 /* It's possible to reduce all atomic operations to either
  * __atomic_add_return, atomic_set and atomic_read (the latter
@@ -157,9 +157,13 @@ static __inline__ void atomic_set(atomic
 	_atomic_spin_unlock_irqrestore(v, flags);
 }
 
+/*
+ * Casting to volatile here minimizes the need for barriers,
+ * without having to declare the type itself as volatile.
+ */
 static __inline__ int atomic_read(const atomic_t *v)
 {
-	return v->counter;
+	return (*(volatile int *)&(v)->counter);
 }
 
 /* exported interface */
@@ -227,7 +231,7 @@ static __inline__ int atomic_add_unless(
 
 #ifdef CONFIG_64BIT
 
-typedef struct { volatile s64 counter; } atomic64_t;
+typedef struct { s64 counter; } atomic64_t;
 
 #define ATOMIC64_INIT(i) ((atomic64_t) { (i) })
 
@@ -258,7 +262,7 @@ atomic64_set(atomic64_t *v, s64 i)
 static __inline__ s64
 atomic64_read(const atomic64_t *v)
 {
-	return v->counter;
+	return (*(volatile s64 *)&(v)->counter);
 }
 
 #define atomic64_add(i,v)	((void)(__atomic64_add_return( ((s64)i),(v))))
