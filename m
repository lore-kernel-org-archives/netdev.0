From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] ixgbe: Reduce memory consumption with larger page sizes
Date: Tue, 22 Oct 2013 10:37:57 +1100
Message-ID: <20131022103757.162f1a79@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48895 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449Ab3JUXh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 19:37:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The ixgbe driver allocates pages for its receive rings. It currently
uses 512 pages, regardless of page size. During receive handling it
adds the unused part of the page back into the rx ring, avoiding the
need for a new allocation.

On a ppc64 box with 64 threads and 64kB pages, we end up with
512 entries * 64 rx queues * 64kB = 2GB memory used. Even more of a
concern is that we use up 2GB of IOMMU space in order to map all this
memory.

The driver makes a number of decisions based on if PAGE_SIZE is less
than 8kB, so use this as the breakpoint and only allocate 128 entries
on 8kB or larger page sizes.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Jeff: The breakpoint and the ring size I chose was pretty arbitrary,
feel free to adjust as you see fit. Our main concern is we get that 2GB
consumption down to something more reasonable :)

Index: b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
===================================================================
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -67,7 +67,11 @@
 #define IXGBE_MAX_TXD			   4096
 #define IXGBE_MIN_TXD			     64
 
+#if (PAGE_SIZE < 8192)
 #define IXGBE_DEFAULT_RXD		    512
+#else
+#define IXGBE_DEFAULT_RXD		    128
+#endif
 #define IXGBE_MAX_RXD			   4096
 #define IXGBE_MIN_RXD			     64
 
