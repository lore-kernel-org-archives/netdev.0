From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Mon, 3 Mar 2008 10:34:49 +0100
Message-ID: <20080303093449.GA15091@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Christoph Lameter <clameter@engr.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:49965 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477AbYCCJew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 04:34:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


SLUB should pack even small objects nicely into cachelines if that is what
has been asked for. Use the same algorithm as SLAB for this.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -1896,12 +1896,15 @@ static unsigned long calculate_alignment
 	 * specified alignment though. If that is greater
 	 * then use it.
 	 */
-	if ((flags & SLAB_HWCACHE_ALIGN) &&
-			size > cache_line_size() / 2)
-		return max_t(unsigned long, align, cache_line_size());
+	if (flags & SLAB_HWCACHE_ALIGN) {
+		unsigned long ralign = cache_line_size();
+		while (size <= ralign / 2)
+			ralign /= 2;
+		align = max(align, ralign);
+	}
 
 	if (align < ARCH_SLAB_MINALIGN)
-		return ARCH_SLAB_MINALIGN;
+		align = ARCH_SLAB_MINALIGN;
 
 	return ALIGN(align, sizeof(void *));
 }
