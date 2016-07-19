From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 10/10] net/faraday: Mask PHY interrupt with NCSI mode
Date: Tue, 19 Jul 2016 11:54:25 +1000
Message-ID: <1468893265-10635-11-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48624 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752496AbcGSBy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 21:54:58 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6J1sHaA129380
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:57 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2496h5pf98-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:57 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 19 Jul 2016 11:54:53 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 6B3662BB005D
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:33 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6J1sXu126214540
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:33 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6J1sWGY001604
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:33 +1000
In-Reply-To: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bogus PHY interrupts are observed. This masks the PHY interrupt
when the interface works in NCSI mode as there is no attached
PHY under the circumstance.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index d8afa2d..2d4c7ea 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -74,6 +74,7 @@ struct ftgmac100 {
 
 	struct mii_bus *mii_bus;
 	int old_speed;
+	int int_mask_all;
 	bool use_ncsi;
 	bool enabled;
 };
@@ -84,14 +85,6 @@ static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
 /******************************************************************************
  * internal functions (hardware register access)
  *****************************************************************************/
-#define INT_MASK_ALL_ENABLED	(FTGMAC100_INT_RPKT_LOST	| \
-				 FTGMAC100_INT_XPKT_ETH		| \
-				 FTGMAC100_INT_XPKT_LOST	| \
-				 FTGMAC100_INT_AHB_ERR		| \
-				 FTGMAC100_INT_PHYSTS_CHG	| \
-				 FTGMAC100_INT_RPKT_BUF		| \
-				 FTGMAC100_INT_NO_RXBUF)
-
 static void ftgmac100_set_rx_ring_base(struct ftgmac100 *priv, dma_addr_t addr)
 {
 	iowrite32(addr, priv->base + FTGMAC100_OFFSET_RXR_BADR);
@@ -1070,8 +1063,9 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 		ftgmac100_tx_complete(priv);
 	}
 
-	if (status & (FTGMAC100_INT_NO_RXBUF | FTGMAC100_INT_RPKT_LOST |
-		      FTGMAC100_INT_AHB_ERR | FTGMAC100_INT_PHYSTS_CHG)) {
+	if (status & priv->int_mask_all & (FTGMAC100_INT_NO_RXBUF |
+			FTGMAC100_INT_RPKT_LOST | FTGMAC100_INT_AHB_ERR |
+			FTGMAC100_INT_PHYSTS_CHG)) {
 		if (net_ratelimit())
 			netdev_info(netdev, "[ISR] = 0x%x: %s%s%s%s\n", status,
 				    status & FTGMAC100_INT_NO_RXBUF ? "NO_RXBUF " : "",
@@ -1094,7 +1088,8 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 
 		/* enable all interrupts */
-		iowrite32(INT_MASK_ALL_ENABLED, priv->base + FTGMAC100_OFFSET_IER);
+		iowrite32(priv->int_mask_all,
+			  priv->base + FTGMAC100_OFFSET_IER);
 	}
 
 	return rx;
@@ -1140,7 +1135,7 @@ static int ftgmac100_open(struct net_device *netdev)
 	netif_start_queue(netdev);
 
 	/* enable all interrupts */
-	iowrite32(INT_MASK_ALL_ENABLED, priv->base + FTGMAC100_OFFSET_IER);
+	iowrite32(priv->int_mask_all, priv->base + FTGMAC100_OFFSET_IER);
 
 	/* Start the NCSI device */
 	if (priv->use_ncsi) {
@@ -1365,6 +1360,13 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	/* MAC address from chip or random one */
 	ftgmac100_setup_mac(priv);
 
+	priv->int_mask_all = (FTGMAC100_INT_RPKT_LOST |
+			      FTGMAC100_INT_XPKT_ETH |
+			      FTGMAC100_INT_XPKT_LOST |
+			      FTGMAC100_INT_AHB_ERR |
+			      FTGMAC100_INT_PHYSTS_CHG |
+			      FTGMAC100_INT_RPKT_BUF |
+			      FTGMAC100_INT_NO_RXBUF);
 	if (pdev->dev.of_node &&
 	    of_get_property(pdev->dev.of_node, "use-ncsi", NULL)) {
 		if (!IS_ENABLED(CONFIG_NET_NCSI)) {
@@ -1374,6 +1376,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 		dev_info(&pdev->dev, "Using NCSI interface\n");
 		priv->use_ncsi = true;
+		priv->int_mask_all &= ~FTGMAC100_INT_PHYSTS_CHG;
 		priv->ndev = ncsi_register_dev(netdev, ftgmac100_ncsi_handler);
 		if (!priv->ndev)
 			goto err_ncsi_dev;
-- 
2.1.0
