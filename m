From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 2/2] 3c59x: fix another page map/single unmap imbalance
Date: Wed, 13 Jan 2016 12:43:54 -0500
Message-ID: <1452707034-16379-3-git-send-email-nhorman@tuxdriver.com>
References: <1452707034-16379-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33296 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932341AbcAMRoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 12:44:37 -0500
In-Reply-To: <1452707034-16379-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

libdma debug found another page map/unmap imbalance in 3c59x.  Multi fragment
frames are mapped such that the lead fragment was mapped as a single entry,
while all other fragments were mapped as pages.  However, on unmapping they were
all unmapped as pages.  Fix is pretty easy, just unmap the lead frag as a single
entry, and bump the for loop initalization up by one so that all subsequent
frags get unmapped as pages

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
---
 drivers/net/ethernet/3com/3c59x.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index eec4a3a..b18ad8e 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2459,7 +2459,12 @@ boomerang_interrupt(int irq, void *dev_id)
 					struct sk_buff *skb = vp->tx_skbuff[entry];
 #if DO_ZEROCOPY
 					int i;
-					for (i=0; i<=skb_shinfo(skb)->nr_frags; i++)
+					pci_unmap_single(VORTEX_PCI(vp),
+							le32_to_cpu(vp->tx_ring[entry].frag[0].addr), 
+							le32_to_cpu(vp->tx_ring[entry].frag[0].length),
+							PCI_DMA_TODEVICE);
+
+					for (i=1; i<=skb_shinfo(skb)->nr_frags; i++)
 							pci_unmap_page(VORTEX_PCI(vp),
 											 le32_to_cpu(vp->tx_ring[entry].frag[i].addr),
 											 le32_to_cpu(vp->tx_ring[entry].frag[i].length)&0xFFF,
-- 
2.5.0
