From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] Fix a race between sky2_down and sky2_poll.
Date: Tue, 2 Jun 2009 10:40:12 +0900
Message-ID: <392fb48f0906011840n4914ef32x8aa316358b2ceacc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:45929 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758846AbZFBBrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 21:47:55 -0400
Received: by bwz22 with SMTP id 22so7837102bwz.37
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2009 18:47:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If sky2_down was called between an interrupt and the corresponding sky2_poll,
rx_ring will have been free'd and we'll crash.

Deal with rx_ring being NULL in sky2_status_intr rather than trying to force
napi polls to complete before freeing rx_ring.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a2ff9cb..1f2a5ab 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1822,8 +1822,8 @@ static int sky2_down(struct net_device *dev)
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);

-	/* Make sure no packets are pending */
-	napi_synchronize(&hw->napi);
+	/* disable soft interrupts */
+	napi_disable(&hw->napi);

 	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);

@@ -1878,6 +1878,9 @@ static int sky2_down(struct net_device *dev)
 	sky2->rx_ring = NULL;
 	sky2->tx_ring = NULL;

+	/* re-enable soft interrupts */
+	napi_enable(&hw->napi);
+
 	return 0;
 }

@@ -2372,6 +2375,16 @@ static int sky2_status_intr(struct sky2_hw *hw,
int to_do, u16 idx)
 		length = le16_to_cpu(le->length);
 		status = le32_to_cpu(le->status);

+		/*
+		 * rx_ring may have been free'd in sky2_down
+		 * if we are responding to an interrupt queued to
+		 * napi before interrupts were disabled
+		 */
+		if (!sky2->rx_ring) {
+			work_done = to_do;
+			break;
+		}
+
 		le->opcode = 0;
 		switch (opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
-- 
1.5.6.5
