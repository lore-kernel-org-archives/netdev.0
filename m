From: y@pengutronix.de
Subject: [PATCH] fec: replace flush_dcache_range with dma_sync_single
Date: Tue, 27 Jan 2009 11:24:06 +0100
Message-ID: <21332.5988887393$1233052021@news.gmane.org>
References: <1233051848-5994-1-git-send-email-y>
 <1233051848-5994-2-git-send-email-y>
 <1233051848-5994-3-git-send-email-y>
 <1233051848-5994-4-git-send-email-y>
 <1233051848-5994-5-git-send-email-y>
 <1233051848-5994-6-git-send-email-y>
 <1233051848-5994-7-git-send-email-y>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42899 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbZA0KZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:25:25 -0500
In-Reply-To: <1233051848-5994-7-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>

flush_dcache_range is not portable across architectures. Use
dma_sync_single instead. Also, the memory must be synchronised in the
receive path aswell.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index f36ee43..6a54d1f 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -356,8 +356,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
 	 */
-	flush_dcache_range((unsigned long)skb->data,
-			   (unsigned long)skb->data + skb->len);
+	dma_sync_single(NULL, bdp->cbd_bufaddr,
+			bdp->cbd_datlen, DMA_TO_DEVICE);
 
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
@@ -630,6 +630,9 @@ while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 	dev->stats.rx_bytes += pkt_len;
 	data = (__u8*)__va(bdp->cbd_bufaddr);
 
+	dma_sync_single(NULL, (unsigned long)__pa(data),
+			pkt_len - 4, DMA_FROM_DEVICE);
+
 	/* This does 16 byte alignment, exactly what we need.
 	 * The packet length includes FCS, but we don't want to
 	 * include that when passing upstream as it messes up
-- 
1.5.6.5

