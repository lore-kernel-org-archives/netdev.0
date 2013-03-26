From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 12/86] net: calxedaxgmac: throw away overrun frames
Date: Tue, 26 Mar 2013 13:21:11 -0400
Message-ID: <20130326173601.744328376@goodmis.org>
References: <20130326172059.136127374@goodmis.org>
Cc: Rob Herring <rob.herring@calxeda.com>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0012-net-calxedaxgmac-throw-away-overrun-frames.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.6.11.1 stable review patch.
If anyone has any objections, please let me know.

------------------

From: Rob Herring <rob.herring@calxeda.com>

[ Upstream commit d6fb3be544b46a7611a3373fcaa62b5b0be01888 ]

The xgmac driver assumes 1 frame per descriptor. If a frame larger than
the descriptor's buffer size is received, the frame will spill over into
the next descriptor. So check for received frames that span more than one
descriptor and discard them. This prevents a crash if we receive erroneous
large packets.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/calxeda/xgmac.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 16814b3..e29c1b6 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -546,6 +546,10 @@ static int desc_get_rx_status(struct xgmac_priv *priv, struct xgmac_dma_desc *p)
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
