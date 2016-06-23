From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] net: bgmac: Fix SOF bit checking
Date: Thu, 23 Jun 2016 14:23:12 -0700
Message-ID: <1466716994-28037-2-git-send-email-f.fainelli@gmail.com>
References: <1466716994-28037-1-git-send-email-f.fainelli@gmail.com>
Cc: nbd@nbd.name, zajec5@gmail.com, davem@davemloft.net,
	hauke@hauke-m.de, jon.mason@broadcom.com,
	bcm-kernel-feedback-list@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35283 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbcFWVXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 17:23:25 -0400
Received: by mail-pa0-f68.google.com with SMTP id hf6so7313541pac.2
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 14:23:25 -0700 (PDT)
In-Reply-To: <1466716994-28037-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are checking for the Start of Frame bit in the ctl1 word, while this
bit is set in the ctl0 word instead. Read the ctl0 word and update the
check to verify that.

Fixes: 9cde94506eac ("bgmac: implement scatter/gather support")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index ee5f431ab32a..70926c611f25 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -267,15 +267,16 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 	while (ring->start != ring->end) {
 		int slot_idx = ring->start % BGMAC_TX_RING_SLOTS;
 		struct bgmac_slot_info *slot = &ring->slots[slot_idx];
-		u32 ctl1;
+		u32 ctl0, ctl1;
 		int len;
 
 		if (slot_idx == empty_slot)
 			break;
 
+		ctl0 = le32_to_cpu(ring->cpu_base[slot_idx].ctl0);
 		ctl1 = le32_to_cpu(ring->cpu_base[slot_idx].ctl1);
 		len = ctl1 & BGMAC_DESC_CTL1_LEN;
-		if (ctl1 & BGMAC_DESC_CTL0_SOF)
+		if (ctl0 & BGMAC_DESC_CTL0_SOF)
 			/* Unmap no longer used buffer */
 			dma_unmap_single(dma_dev, slot->dma_addr, len,
 					 DMA_TO_DEVICE);
-- 
2.7.4
