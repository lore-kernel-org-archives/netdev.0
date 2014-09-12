From: <Frank.Li@freescale.com>
Subject: [Patch v4 net-next 04/12] net: fec: parser max queue number from dt file
Date: Sat, 13 Sep 2014 05:00:49 +0800
Message-ID: <1410555657-10744-5-git-send-email-Frank.Li@freescale.com>
References: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux@arm.linux.org.uk>,
	Fugang Duan <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0130.outbound.protection.outlook.com ([157.56.110.130]:22514
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752258AbaILWFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 18:05:23 -0400
In-Reply-To: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

By default, the tx/rx queue number is 1, user can config the queue number
at DTS file like this:
	fsl,num-tx-queues=<3>;
	fsl,num-rx-queues=<3>

Since i.MX6SX enet-AVB IP support multi queues, so use multi queues
interface to allocate and set up an Ethernet device.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |  2 ++
 drivers/net/ethernet/freescale/fec_main.c | 46 ++++++++++++++++++++++++++++++-
 2 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index b2b91f8..72fb90f 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -356,6 +356,8 @@ struct fec_enet_private {
 
 	bool ptp_clk_on;
 	struct mutex ptp_clk_mutex;
+	unsigned int num_tx_queues;
+	unsigned int num_rx_queues;
 
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
 	struct fec_enet_priv_tx_q *tx_queue[FEC_ENET_MAX_TX_QS];
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4c0d2ee..2240df0 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2709,6 +2709,42 @@ static void fec_reset_phy(struct platform_device *pdev)
 }
 #endif /* CONFIG_OF */
 
+static void
+fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx, int *num_rx)
+{
+	struct device_node *np = pdev->dev.of_node;
+	int err;
+
+	*num_tx = *num_rx = 1;
+
+	if (!np || !of_device_is_available(np))
+		return;
+
+	/* parse the num of tx and rx queues */
+	err = of_property_read_u32(np, "fsl,num-tx-queues", num_tx);
+	err |= of_property_read_u32(np, "fsl,num-rx-queues", num_rx);
+	if (err) {
+		*num_tx = 1;
+		*num_rx = 1;
+		return;
+	}
+
+	if (*num_tx < 1 || *num_tx > FEC_ENET_MAX_TX_QS) {
+		dev_err(&pdev->dev, "Invalidate num_tx(=%d), fail back to 1\n",
+			*num_tx);
+		*num_tx = 1;
+		return;
+	}
+
+	if (*num_rx < 1 || *num_rx > FEC_ENET_MAX_RX_QS) {
+		dev_err(&pdev->dev, "Invalidate num_rx(=%d), fail back to 1\n",
+			*num_rx);
+		*num_rx = 1;
+		return;
+	}
+
+}
+
 static int
 fec_probe(struct platform_device *pdev)
 {
@@ -2720,13 +2756,18 @@ fec_probe(struct platform_device *pdev)
 	const struct of_device_id *of_id;
 	static int dev_id;
 	struct device_node *np = pdev->dev.of_node, *phy_node;
+	int num_tx_qs = 1;
+	int num_rx_qs = 1;
 
 	of_id = of_match_device(fec_dt_ids, &pdev->dev);
 	if (of_id)
 		pdev->id_entry = of_id->data;
 
+	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
+
 	/* Init network device */
-	ndev = alloc_etherdev(sizeof(struct fec_enet_private));
+	ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private),
+				  num_tx_qs, num_rx_qs);
 	if (!ndev)
 		return -ENOMEM;
 
@@ -2735,6 +2776,9 @@ fec_probe(struct platform_device *pdev)
 	/* setup board info structure */
 	fep = netdev_priv(ndev);
 
+	fep->num_rx_queues = num_rx_qs;
+	fep->num_tx_queues = num_tx_qs;
+
 #if !defined(CONFIG_M5272)
 	/* default enable pause frame auto negotiation */
 	if (pdev->id_entry &&
-- 
1.9.1
