From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH 1/1] net: nps_enet: Disable interrupts before napi reschedule
Date: Thu, 26 May 2016 15:00:06 +0300
Message-ID: <1464264006-26627-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <noamca@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <eladkan@mellanox.com>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elad Kanfi <eladkan@mellanox.com>

Since NAPI works by shutting down event interrupts when theres
work and turning them on when theres none, the net driver must
make sure that interrupts are disabled when it reschedules polling.
By calling napi_reschedule, the driver switches to polling mode,
therefor there should be no interrupt interference.
Any received packets will be handled in nps_enet_poll by polling the HW
indication of received packet until all packets are handled.

Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
Acked-by: Noam Camus <noamca@mellanox.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 085f912..06f0317 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -205,8 +205,10 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 		 * re-adding ourselves to the poll list.
 		 */
 
-		if (priv->tx_skb && !tx_ctrl_ct)
+		if (priv->tx_skb && !tx_ctrl_ct) {
+			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
 			napi_reschedule(napi);
+		}
 	}
 
 	return work_done;
-- 
1.7.1
