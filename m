From: David Miller <davem@davemloft.net>
Subject: Re: link error : 2.6.21-rc6-mm1 for s390
Date: Tue, 10 Apr 2007 18:36:29 -0700 (PDT)
Message-ID: <20070410.183629.57444787.davem@davemloft.net>
References: <20070411005616.GG15262@Krystal>
	<20070410182937.8169c672.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@polymtl.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@linux-foundation.org,
	heiko.carstens@de.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54436
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965851AbXDKBg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 21:36:28 -0400
In-Reply-To: <20070410182937.8169c672.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 10 Apr 2007 18:29:37 -0700

> git-net.patch implements generic lib/div64.c, but s390 also has a
> private one.  Presumably the appropriate fix is to remove s390's
> private implementation within davem's tree.

The s390 version seems to be optimized in assembler for that
processor, therefore we should probably instead elide the
generic version on s390.

How about something like this?

diff --git a/include/asm-s390/div64.h b/include/asm-s390/div64.h
index 6cd978c..21aea15 100644
--- a/include/asm-s390/div64.h
+++ b/include/asm-s390/div64.h
@@ -1 +1,2 @@
 #include <asm-generic/div64.h>
+#define HAVE_ARCH_DIV64_32
diff --git a/lib/div64.c b/lib/div64.c
index 74f0c8c..5b480fa 100644
--- a/lib/div64.c
+++ b/lib/div64.c
@@ -23,6 +23,8 @@
 /* Not needed on 64bit architectures */
 #if BITS_PER_LONG == 32
 
+#ifndef HAVE_ARCH_DIV64_32
+
 uint32_t __div64_32(uint64_t *n, uint32_t base)
 {
 	uint64_t rem = *n;
@@ -58,6 +60,8 @@ uint32_t __div64_32(uint64_t *n, uint32_t base)
 
 EXPORT_SYMBOL(__div64_32);
 
+#endif /* !(HAVE_ARCH_DIV64_32) */
+
 /* 64bit divisor, dividend and result. dynamic precision */
 uint64_t div64_64(uint64_t dividend, uint64_t divisor)
 {
