From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] 8139cp: fix coherent mapping leak in error path.
Date: Sun, 2 Dec 2012 00:08:50 +0100
Message-ID: <20121201230850.GA10935@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	jasowang@redhat.com, netdev@vger.kernel.org,
	John Greene <jogreene@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36570 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408Ab2LAXd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 18:33:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cp_open
[...]
        rc = cp_alloc_rings(cp);
        if (rc)
                return rc;

cp_alloc_rings
[...]
        mem = dma_alloc_coherent(&cp->pdev->dev, CP_RING_BYTES,
                                 &cp->ring_dma, GFP_KERNEL);

- cp_alloc_rings never frees the coherent mapping it allocates
- neither do cp_open when cp_alloc_rings fails

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/8139cp.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index b01f83a..609125a 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1060,17 +1060,22 @@ static int cp_init_rings (struct cp_private *cp)
 
 static int cp_alloc_rings (struct cp_private *cp)
 {
+	struct device *d = &cp->pdev->dev;
 	void *mem;
+	int rc;
 
-	mem = dma_alloc_coherent(&cp->pdev->dev, CP_RING_BYTES,
-				 &cp->ring_dma, GFP_KERNEL);
+	mem = dma_alloc_coherent(d, CP_RING_BYTES, &cp->ring_dma, GFP_KERNEL);
 	if (!mem)
 		return -ENOMEM;
 
 	cp->rx_ring = mem;
 	cp->tx_ring = &cp->rx_ring[CP_RX_RING_SIZE];
 
-	return cp_init_rings(cp);
+	rc = cp_init_rings(cp);
+	if (rc < 0)
+		dma_free_coherent(d, CP_RING_BYTES, cp->rx_ring, cp->ring_dma);
+
+	return rc;
 }
 
 static void cp_clean_rings (struct cp_private *cp)
-- 
1.7.11.7
