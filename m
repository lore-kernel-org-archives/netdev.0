From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Mon, 3 Mar 2008 10:35:29 +0100
Message-ID: <20080303093529.GB15091@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Christoph Lameter <clameter@engr.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:46013 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbYCCJfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 04:35:31 -0500
Content-Disposition: inline
In-Reply-To: <20080303093449.GA15091@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Introduce SLAB_SMP_ALIGN, for allocations where false sharing must be
minimised on SMP systems.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -22,7 +22,8 @@
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
-#define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
+#define SLAB_SMP_ALIGN		0x00004000UL	/* Align on cachelines for SMP*/
+#define SLAB_CACHE_DMA		0x00008000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -174,13 +174,13 @@
 /* Legal flag mask for kmem_cache_create(). */
 #if DEBUG
 # define CREATE_MASK	(SLAB_RED_ZONE | \
-			 SLAB_POISON | SLAB_HWCACHE_ALIGN | \
+			 SLAB_POISON | SLAB_HWCACHE_ALIGN | SLAB_SMP_ALIGN | \
 			 SLAB_CACHE_DMA | \
 			 SLAB_STORE_USER | \
 			 SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | \
 			 SLAB_DESTROY_BY_RCU | SLAB_MEM_SPREAD)
 #else
-# define CREATE_MASK	(SLAB_HWCACHE_ALIGN | \
+# define CREATE_MASK	(SLAB_HWCACHE_ALIGN | SLAB_SMP_ALIGN | \
 			 SLAB_CACHE_DMA | \
 			 SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | \
 			 SLAB_DESTROY_BY_RCU | SLAB_MEM_SPREAD)
@@ -2245,6 +2245,9 @@ kmem_cache_create (const char *name, siz
 		ralign = BYTES_PER_WORD;
 	}
 
+	if ((flags & SLAB_SMP_ALIGN) && num_possible_cpus() > 1)
+		ralign = max_t(unsigned long, ralign, cache_line_size());
+
 	/*
 	 * Redzoning and user store require word alignment or possibly larger.
 	 * Note this will be overridden by architecture or caller mandated
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -1903,6 +1903,9 @@ static unsigned long calculate_alignment
 		align = max(align, ralign);
 	}
 
+	if ((flags & SLAB_SMP_ALIGN) && num_possible_cpus() > 1)
+		align = max_t(unsigned long, align, cache_line_size());
+
 	if (align < ARCH_SLAB_MINALIGN)
 		align = ARCH_SLAB_MINALIGN;
 
