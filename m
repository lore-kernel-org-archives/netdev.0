From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v2 1/7] via-velocity: Correct 64-byte alignment for rx
 buffers
Date: Mon, 23 Nov 2009 15:30:55 +0100
Message-ID: <20091123153055.32fe0d1a@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:47167 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751022AbZKWOa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 09:30:58 -0500
In-Reply-To: <20091123152724.2871cf4d@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(From the VIA driver). The current code does not guarantee 64-byte
alignment since it simply does

        int add = skb->data & 63;

        skb->data += add;

(via skb_reserve). So for example, if the skb->data address would be
0x10, this would result in 32-byte alignment (0x10 + 0x10).

Correct by adding

        64 - (skb->data & 63)

instead.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index e04e5be..b6cf3b5 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1483,7 +1483,8 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	 *	Do the gymnastics to get the buffer head for data at
 	 *	64byte alignment.
 	 */
-	skb_reserve(rd_info->skb, (unsigned long) rd_info->skb->data & 63);
+	skb_reserve(rd_info->skb,
+			64 - ((unsigned long) rd_info->skb->data & 63));
 	rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data,
 					vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
 
-- 
1.6.0.4

