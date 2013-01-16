From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH] net: calxedaxgmac: throw away overrun frames
Date: Wed, 16 Jan 2013 17:36:37 -0600
Message-ID: <1358379397-7152-1-git-send-email-robherring2@gmail.com>
Cc: Rob Herring <rob.herring@calxeda.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

The xgmac driver assumes 1 frame per descriptor. If a frame larger than
the descriptor's buffer size is received, the frame will spill over into
the next descriptor. So check for received frames that span more than one
descriptor and discard them. This prevents a crash if we receive erroneous
large packets.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/calxeda/xgmac.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index b407043..f7f0290 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -548,6 +548,10 @@ static int desc_get_rx_status(struct xgmac_priv *priv, struct xgmac_dma_desc *p)
 		return -1;
 	}
 
+	/* All frames should fit into a single buffer */
+	if (!(status & RXDESC_FIRST_SEG) || !(status & RXDESC_LAST_SEG))
+		return -1;
+
 	/* Check if packet has checksum already */
 	if ((status & RXDESC_FRAME_TYPE) && (status & RXDESC_EXT_STATUS) &&
 		!(ext_status & RXDESC_IP_PAYLOAD_MASK))
-- 
1.7.10.4
