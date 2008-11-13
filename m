From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH]  bnx2: bnx2_alloc_rx_mem() should use kmalloc() for small
 allocations
Date: Thu, 13 Nov 2008 06:49:14 +0100
Message-ID: <491BBFDA.9000303@cosmosbay.com>
References: <1226531404-26118-1-git-send-email-mchan@broadcom.com> <1226531404-26118-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080903090609000906070803"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>,
	Benjamin Li <benli@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:52249 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbYKMFtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 00:49:22 -0500
In-Reply-To: <1226531404-26118-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080903090609000906070803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi all

# grep bnx2 /proc/vmallocinfo
0xf8218000-0xf821a000    8192 bnx2_alloc_rx_mem+0x33/0x310 pages=1 vmalloc
0xf821b000-0xf821d000    8192 bnx2_alloc_rx_mem+0x33/0x310 pages=1 vmalloc
0xf8220000-0xf8234000   81920 bnx2_init_board+0x104/0xae0 phys=f6000000 ioremap
0xf8240000-0xf8254000   81920 bnx2_init_board+0x104/0xae0 phys=fa000000 ioremap


Any chance bnx2_alloc_rx_mem doesnt use vmalloc() to allocate less than a page of memory ?

Thank you

[PATCH] bnx2: bnx2_alloc_rx_mem() should use kmalloc() for small allocations

Add two helper functions to allocate and free memory, using kzalloc() or vmalloc()
depending of the size of the allocation

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 drivers/net/bnx2.c |   36 +++++++++++++++++++++++++-----------
 1 files changed, 25 insertions(+), 11 deletions(-)

--------------080903090609000906070803
Content-Type: text/plain;
 name="bnx2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bnx2.patch"

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0853b3c..93c8256 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -523,6 +523,24 @@ bnx2_free_tx_mem(struct bnx2 *bp)
 	}
 }
 
+static void *
+bnx2_alloc_kmem(size_t sz)
+{
+	if (sz <= PAGE_SIZE)
+		return kzalloc(sz, GFP_KERNEL);
+	else
+		return 	__vmalloc(sz, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
+}
+
+static void
+bnx2_free_kmem(void *ptr, size_t sz)
+{
+	if (sz <= PAGE_SIZE)
+		kfree(ptr);
+	else
+		vfree(ptr);
+}
+
 static void
 bnx2_free_rx_mem(struct bnx2 *bp)
 {
@@ -541,7 +559,8 @@ bnx2_free_rx_mem(struct bnx2 *bp)
 			rxr->rx_desc_ring[j] = NULL;
 		}
 		if (rxr->rx_buf_ring)
-			vfree(rxr->rx_buf_ring);
+			bnx2_free_kmem(rxr->rx_buf_ring,
+				       SW_RXBD_RING_SIZE * bp->rx_max_ring);
 		rxr->rx_buf_ring = NULL;
 
 		for (j = 0; j < bp->rx_max_pg_ring; j++) {
@@ -552,7 +571,8 @@ bnx2_free_rx_mem(struct bnx2 *bp)
 			rxr->rx_pg_desc_ring[i] = NULL;
 		}
 		if (rxr->rx_pg_ring)
-			vfree(rxr->rx_pg_ring);
+			bnx2_free_kmem(rxr->rx_pg_ring,
+				       SW_RXPG_RING_SIZE * bp->rx_max_pg_ring);
 		rxr->rx_pg_ring = NULL;
 	}
 }
@@ -590,13 +610,10 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
 		int j;
 
 		rxr->rx_buf_ring =
-			vmalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
+			bnx2_alloc_kmem(SW_RXBD_RING_SIZE * bp->rx_max_ring);
 		if (rxr->rx_buf_ring == NULL)
 			return -ENOMEM;
 
-		memset(rxr->rx_buf_ring, 0,
-		       SW_RXBD_RING_SIZE * bp->rx_max_ring);
-
 		for (j = 0; j < bp->rx_max_ring; j++) {
 			rxr->rx_desc_ring[j] =
 				pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
@@ -607,13 +624,10 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
 		}
 
 		if (bp->rx_pg_ring_size) {
-			rxr->rx_pg_ring = vmalloc(SW_RXPG_RING_SIZE *
-						  bp->rx_max_pg_ring);
+			rxr->rx_pg_ring = bnx2_alloc_kmem(SW_RXPG_RING_SIZE *
+							  bp->rx_max_pg_ring);
 			if (rxr->rx_pg_ring == NULL)
 				return -ENOMEM;
-
-			memset(rxr->rx_pg_ring, 0, SW_RXPG_RING_SIZE *
-			       bp->rx_max_pg_ring);
 		}
 
 		for (j = 0; j < bp->rx_max_pg_ring; j++) {

--------------080903090609000906070803--
