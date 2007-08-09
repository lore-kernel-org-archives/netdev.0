From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 9 Aug 2007 09:24:42 -0400
Message-ID: <20070809132442.GA13042@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:36931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936159AbXHINZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 09:25:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Purify volatile use for atomic[64]_t on alpha.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-alpha/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-alpha/atomic.h	2007-08-09 09:19:00.000000000 -0400
@@ -14,18 +14,22 @@
 
 
 /*
- * Counter is volatile to make sure gcc doesn't try to be clever
- * and move things around on us. We need to use _exactly_ the address
- * the user gave us, not some alias that contains the same information.
+ * Make sure gcc doesn't try to be clever and move things around
+ * on us. We need to use _exactly_ the address the user gave us,
+ * not some alias that contains the same information.
  */
-typedef struct { volatile int counter; } atomic_t;
-typedef struct { volatile long counter; } atomic64_t;
+typedef struct { int counter; } atomic_t;
+typedef struct { long counter; } atomic64_t;
 
 #define ATOMIC_INIT(i)		( (atomic_t) { (i) } )
 #define ATOMIC64_INIT(i)	( (atomic64_t) { (i) } )
 
-#define atomic_read(v)		((v)->counter + 0)
-#define atomic64_read(v)	((v)->counter + 0)
+/*
+ * Casting to volatile here minimizes the need for barriers,
+ * without having to declare the type itself as volatile.
+ */
+#define atomic_read(v)		(*(volatile int *)&(v)->counter + 0)
+#define atomic64_read(v)	(*(volatile long *)&(v)->counter + 0)
 
 #define atomic_set(v,i)		((v)->counter = (i))
 #define atomic64_set(v,i)	((v)->counter = (i))
