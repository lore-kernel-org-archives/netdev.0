From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH v2 1/2] net: nps_enet: Sync access to packet sent flag
Date: Wed, 27 Apr 2016 16:18:29 +0300
Message-ID: <1461763110-15263-2-git-send-email-eladkan@mellanox.com>
References: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <noamca@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <eladkan@mellanox.com>,
	<talz@mellanox.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elad Kanfi <eladkan@mellanox.com>

Below is a description of a possible problematic
sequence. CPU-A is sending a frame and CPU-B handles
the interrupt that indicates the frame was sent. CPU-B
reads an invalid value of tx_packet_sent.

	CPU-A				CPU-B
	-----				-----
	nps_enet_send_frame
	.
	.
	tx_packet_sent = true
	order HW to start tx
	.
	.
	HW complete tx
			    ------> 	get tx complete interrupt
					.
					.
					if(tx_packet_sent == true)

	end memory transaction
	(tx_packet_sent actually
	 written)

Problem solution:

Add a memory barrier after setting tx_packet_sent,
in order to make sure that it is written before
the packet is sent.

Signed-off-by: Elad Kanfi <eladkan@mellanox.com>

Acked-by: Noam Camus <noamca@mellanox.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 1f23845..1373236 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -389,6 +389,13 @@ static void nps_enet_send_frame(struct net_device *ndev,
 
 	/* Indicate SW is done */
 	priv->tx_packet_sent = true;
+
+	/* before the frame is sent we have to make
+	 * sure that priv->tx_packet_sent will be valid
+	 * for the CPU'S that handles the ISR and NAPI poll
+	 */
+	smp_wmb();
+
 	tx_ctrl_value |= NPS_ENET_ENABLE << TX_CTL_CT_SHIFT;
 	/* Send Frame */
 	nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, tx_ctrl_value);
-- 
1.7.1
