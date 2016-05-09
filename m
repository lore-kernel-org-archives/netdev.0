From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH v3 1/2] net: nps_enet: Tx handler synchronization
Date: Mon, 9 May 2016 20:13:19 +0300
Message-ID: <1462814000-16331-2-git-send-email-eladkan@mellanox.com>
References: <1462814000-16331-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <noamca@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <eladkan@mellanox.com>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462814000-16331-1-git-send-email-eladkan@mellanox.com>
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
	tx_skb = skb
	tx_packet_sent = true
	order HW to start tx
	.
	.
	HW complete tx
			    ------> 	get tx complete interrupt
					.
					.
					if(tx_packet_sent == true)
						handle tx_skb

	end memory transaction
	(tx_packet_sent actually
	 written)

Furthermore there is a dependency between tx_skb and tx_packet_sent.
There is no assurance that tx_skb contains a valid pointer at CPU B
when it sees tx_packet_sent == true.

Solution:

Initialize tx_skb to NULL and use it to indicate that packet was sent,
in this way tx_packet_sent can be removed.
Add a write memory barrier after setting tx_skb in order to make sure
that it is valid before HW is informed and IRQ is fired.

Fixed sequence will be:

       CPU-A                           CPU-B
       -----                           -----

	tx_skb = skb
	wmb()
	.
	.
	order HW to start tx
	.
	.
	HW complete tx
			------>		get tx complete interrupt
					.
					.
					if(tx_skb != NULL)
						handle tx_skb

					tx_skb = NULL

Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
Acked-by: Noam Camus <noamca@mellanox.com>
Acked-by: Gilad Ben-Yossef <giladby@mellanox.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |   15 +++++++++------
 drivers/net/ethernet/ezchip/nps_enet.h |    2 --
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 1f23845..25ac2de 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -145,7 +145,7 @@ static void nps_enet_tx_handler(struct net_device *ndev)
 	u32 tx_ctrl_nt = (tx_ctrl_value & TX_CTL_NT_MASK) >> TX_CTL_NT_SHIFT;
 
 	/* Check if we got TX */
-	if (!priv->tx_packet_sent || tx_ctrl_ct)
+	if (!priv->tx_skb || tx_ctrl_ct)
 		return;
 
 	/* Ack Tx ctrl register */
@@ -160,7 +160,7 @@ static void nps_enet_tx_handler(struct net_device *ndev)
 	}
 
 	dev_kfree_skb(priv->tx_skb);
-	priv->tx_packet_sent = false;
+	priv->tx_skb = NULL;
 
 	if (netif_queue_stopped(ndev))
 		netif_wake_queue(ndev);
@@ -217,7 +217,7 @@ static irqreturn_t nps_enet_irq_handler(s32 irq, void *dev_instance)
 	u32 tx_ctrl_ct = (tx_ctrl_value & TX_CTL_CT_MASK) >> TX_CTL_CT_SHIFT;
 	u32 rx_ctrl_cr = (rx_ctrl_value & RX_CTL_CR_MASK) >> RX_CTL_CR_SHIFT;
 
-	if ((!tx_ctrl_ct && priv->tx_packet_sent) || rx_ctrl_cr)
+	if ((!tx_ctrl_ct && priv->tx_skb) || rx_ctrl_cr)
 		if (likely(napi_schedule_prep(&priv->napi))) {
 			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
 			__napi_schedule(&priv->napi);
@@ -387,8 +387,6 @@ static void nps_enet_send_frame(struct net_device *ndev,
 	/* Write the length of the Frame */
 	tx_ctrl_value |= length << TX_CTL_NT_SHIFT;
 
-	/* Indicate SW is done */
-	priv->tx_packet_sent = true;
 	tx_ctrl_value |= NPS_ENET_ENABLE << TX_CTL_CT_SHIFT;
 	/* Send Frame */
 	nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, tx_ctrl_value);
@@ -465,7 +463,7 @@ static s32 nps_enet_open(struct net_device *ndev)
 	s32 err;
 
 	/* Reset private variables */
-	priv->tx_packet_sent = false;
+	priv->tx_skb = NULL;
 	priv->ge_mac_cfg_2_value = 0;
 	priv->ge_mac_cfg_3_value = 0;
 
@@ -534,6 +532,11 @@ static netdev_tx_t nps_enet_start_xmit(struct sk_buff *skb,
 
 	priv->tx_skb = skb;
 
+	/* make sure tx_skb is actually written to the memory
+	 * before the HW is informed and the IRQ is fired.
+	 */
+	wmb();
+
 	nps_enet_send_frame(ndev, skb);
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/ethernet/ezchip/nps_enet.h b/drivers/net/ethernet/ezchip/nps_enet.h
index d0cab60..3939ca2 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.h
+++ b/drivers/net/ethernet/ezchip/nps_enet.h
@@ -165,14 +165,12 @@
  * struct nps_enet_priv - Storage of ENET's private information.
  * @regs_base:      Base address of ENET memory-mapped control registers.
  * @irq:            For RX/TX IRQ number.
- * @tx_packet_sent: SW indication if frame is being sent.
  * @tx_skb:         socket buffer of sent frame.
  * @napi:           Structure for NAPI.
  */
 struct nps_enet_priv {
 	void __iomem *regs_base;
 	s32 irq;
-	bool tx_packet_sent;
 	struct sk_buff *tx_skb;
 	struct napi_struct napi;
 	u32 ge_mac_cfg_2_value;
-- 
1.7.1
