From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] ixgbe: Reduce memory consumption with larger page sizes
Date: Fri,  1 Nov 2013 06:56:48 -0700
Message-ID: <1383314210-24289-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anton Blanchard <anton@samba.org>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12204 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371Ab3KAN4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 09:56:55 -0400
In-Reply-To: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

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
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index f51fd1f..0914914 100644
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
 
-- 
1.8.3.1
