From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v3 5/9] bgmac: add check for oversized packets
Date: Sun, 12 Apr 2015 23:38:27 +0200
Message-ID: <1428874711-23950-5-git-send-email-nbd@openwrt.org>
References: <1428874711-23950-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:48619
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752553AbbDLVig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 17:38:36 -0400
In-Reply-To: <1428874711-23950-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In very rare cases, the MAC can catch an internal buffer that is bigger
than it's supposed to be. Instead of crashing the kernel, simply pass
the buffer back to the hardware

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index e004588..3ac8d9a 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -422,6 +422,14 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 				break;
 			}
 
+			if (len > BGMAC_RX_ALLOC_SIZE) {
+				bgmac_err(bgmac, "Found oversized packet at slot %d, DMA issue!\n",
+					  ring->start);
+				rx->len = cpu_to_le16(0xdead);
+				rx->flags = cpu_to_le16(0xbeef);
+				break;
+			}
+
 			/* Omit CRC. */
 			len -= ETH_FCS_LEN;
 
-- 
2.2.2
