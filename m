From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] 3c59x: mask LAST_FRAG bit from length field in ring
Date: Thu, 25 Feb 2016 13:02:50 -0500
Message-ID: <1456423370-22797-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37486 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381AbcBYSDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 13:03:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently, I fixed a bug in 3c59x:

commit 6e144419e4da11a9a4977c8d899d7247d94ca338
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Wed Jan 13 12:43:54 2016 -0500

    3c59x: fix another page map/single unmap imbalance

Which correctly rebalanced dma mapping and unmapping types.  Unfortunately it
introduced a new bug which causes oopses on older systems.

When mapping dma regions, the last entry for a packet in the 3c59x tx ring
encodes a LAST_FRAG bit, which is encoded as the high order bit of the buffers
length field.  When it is unmapped the LAST_FRAG bit is cleared prior to being
passed to the unmap function.  Unfortunately the commit above fails to do that
masking.  It was missed in testing because the system on which I tested it had
an intel iommu, the driver for which ignores the size field, using only the DMA
address as the token to identify the mapping to be released.  However, on older
systems that rely on swiotlb (or other dma drivers that key off that length
field), not masking off that LAST_FRAG high order bit results in parsing a huge
size to be release, leading to all sorts of odd corruptions and the like.

Fix is easy, just mask the length with 0xFFF.  It should really be
&(LAST_FRAG-1), but 0xFFF is the style of the file, and I'd like to make this
fix minimal and correct before making it prettier.

Appies to the net tree cleanly.  All testing on both iommu and swiommu based
systems produce good results

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/3com/3c59x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 79e1a02..17b2126 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2461,7 +2461,7 @@ boomerang_interrupt(int irq, void *dev_id)
 					int i;
 					pci_unmap_single(VORTEX_PCI(vp),
 							le32_to_cpu(vp->tx_ring[entry].frag[0].addr),
-							le32_to_cpu(vp->tx_ring[entry].frag[0].length),
+							le32_to_cpu(vp->tx_ring[entry].frag[0].length)&0xFFF,
 							PCI_DMA_TODEVICE);
 
 					for (i=1; i<=skb_shinfo(skb)->nr_frags; i++)
-- 
2.5.0
