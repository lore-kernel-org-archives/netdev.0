From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 3/5] net: w5100: enable to support sleepable register access interface
Date: Fri, 15 Apr 2016 00:11:31 +0900
Message-ID: <1460646693-25179-4-git-send-email-akinobu.mita@gmail.com>
References: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35284 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbcDNPL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 11:11:58 -0400
Received: by mail-pf0-f176.google.com with SMTP id n1so46905759pfn.2
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 08:11:58 -0700 (PDT)
In-Reply-To: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SPI transfer routines are callable only from contexts that can sleep.

This adds ability to tell the core driver that the interface mode
cannot access w5100 register on atomic contexts.  In this case,
workqueue and threaded irq are required.

This also corrects timeout period waiting for command register to be
automatically cleared because the latency of the register access with
SPI transfer can be interfered by other contexts.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
* No changes from v2

 drivers/net/ethernet/wiznet/w5100.c | 190 ++++++++++++++++++++++++++++--------
 drivers/net/ethernet/wiznet/w5100.h |   1 +
 2 files changed, 153 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 89cba67..42a9de4 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -96,6 +96,13 @@ struct w5100_priv {
 	struct net_device *ndev;
 	bool promisc;
 	u32 msg_enable;
+
+	struct workqueue_struct *xfer_wq;
+	struct work_struct rx_work;
+	struct sk_buff *tx_skb;
+	struct work_struct tx_work;
+	struct work_struct setrx_work;
+	struct work_struct restart_work;
 };
 
 /************************************************************************
@@ -502,10 +509,12 @@ static int w5100_reset(struct w5100_priv *priv)
 
 static int w5100_command(struct w5100_priv *priv, u16 cmd)
 {
-	unsigned long timeout = jiffies + msecs_to_jiffies(100);
+	unsigned long timeout;
 
 	w5100_write(priv, W5100_S0_CR, cmd);
 
+	timeout = jiffies + msecs_to_jiffies(100);
+
 	while (w5100_read(priv, W5100_S0_CR) != 0) {
 		if (time_after(jiffies, timeout))
 			return -EIO;
@@ -605,7 +614,7 @@ static void w5100_get_regs(struct net_device *ndev,
 	w5100_readbulk(priv, W5100_S0_REGS, buf, W5100_S0_REGS_LEN);
 }
 
-static void w5100_tx_timeout(struct net_device *ndev)
+static void w5100_restart(struct net_device *ndev)
 {
 	struct w5100_priv *priv = netdev_priv(ndev);
 
@@ -617,12 +626,28 @@ static void w5100_tx_timeout(struct net_device *ndev)
 	netif_wake_queue(ndev);
 }
 
-static int w5100_start_tx(struct sk_buff *skb, struct net_device *ndev)
+static void w5100_restart_work(struct work_struct *work)
+{
+	struct w5100_priv *priv = container_of(work, struct w5100_priv,
+					       restart_work);
+
+	w5100_restart(priv->ndev);
+}
+
+static void w5100_tx_timeout(struct net_device *ndev)
 {
 	struct w5100_priv *priv = netdev_priv(ndev);
-	u16 offset;
 
-	netif_stop_queue(ndev);
+	if (priv->ops->may_sleep)
+		schedule_work(&priv->restart_work);
+	else
+		w5100_restart(ndev);
+}
+
+static void w5100_tx_skb(struct net_device *ndev, struct sk_buff *skb)
+{
+	struct w5100_priv *priv = netdev_priv(ndev);
+	u16 offset;
 
 	offset = w5100_read16(priv, W5100_S0_TX_WR);
 	w5100_writebuf(priv, offset, skb->data, skb->len);
@@ -632,47 +657,98 @@ static int w5100_start_tx(struct sk_buff *skb, struct net_device *ndev)
 	dev_kfree_skb(skb);
 
 	w5100_command(priv, S0_CR_SEND);
+}
+
+static void w5100_tx_work(struct work_struct *work)
+{
+	struct w5100_priv *priv = container_of(work, struct w5100_priv,
+					       tx_work);
+	struct sk_buff *skb = priv->tx_skb;
+
+	priv->tx_skb = NULL;
+
+	if (WARN_ON(!skb))
+		return;
+	w5100_tx_skb(priv->ndev, skb);
+}
+
+static int w5100_start_tx(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct w5100_priv *priv = netdev_priv(ndev);
+
+	netif_stop_queue(ndev);
+
+	if (priv->ops->may_sleep) {
+		WARN_ON(priv->tx_skb);
+		priv->tx_skb = skb;
+		queue_work(priv->xfer_wq, &priv->tx_work);
+	} else {
+		w5100_tx_skb(ndev, skb);
+	}
 
 	return NETDEV_TX_OK;
 }
 
-static int w5100_napi_poll(struct napi_struct *napi, int budget)
+static struct sk_buff *w5100_rx_skb(struct net_device *ndev)
 {
-	struct w5100_priv *priv = container_of(napi, struct w5100_priv, napi);
-	struct net_device *ndev = priv->ndev;
+	struct w5100_priv *priv = netdev_priv(ndev);
 	struct sk_buff *skb;
-	int rx_count;
 	u16 rx_len;
 	u16 offset;
 	u8 header[2];
+	u16 rx_buf_len = w5100_read16(priv, W5100_S0_RX_RSR);
 
-	for (rx_count = 0; rx_count < budget; rx_count++) {
-		u16 rx_buf_len = w5100_read16(priv, W5100_S0_RX_RSR);
-		if (rx_buf_len == 0)
-			break;
+	if (rx_buf_len == 0)
+		return NULL;
 
-		offset = w5100_read16(priv, W5100_S0_RX_RD);
-		w5100_readbuf(priv, offset, header, 2);
-		rx_len = get_unaligned_be16(header) - 2;
-
-		skb = netdev_alloc_skb_ip_align(ndev, rx_len);
-		if (unlikely(!skb)) {
-			w5100_write16(priv, W5100_S0_RX_RD,
-					    offset + rx_buf_len);
-			w5100_command(priv, S0_CR_RECV);
-			ndev->stats.rx_dropped++;
-			return -ENOMEM;
-		}
+	offset = w5100_read16(priv, W5100_S0_RX_RD);
+	w5100_readbuf(priv, offset, header, 2);
+	rx_len = get_unaligned_be16(header) - 2;
 
-		skb_put(skb, rx_len);
-		w5100_readbuf(priv, offset + 2, skb->data, rx_len);
-		w5100_write16(priv, W5100_S0_RX_RD, offset + 2 + rx_len);
+	skb = netdev_alloc_skb_ip_align(ndev, rx_len);
+	if (unlikely(!skb)) {
+		w5100_write16(priv, W5100_S0_RX_RD, offset + rx_buf_len);
 		w5100_command(priv, S0_CR_RECV);
-		skb->protocol = eth_type_trans(skb, ndev);
+		ndev->stats.rx_dropped++;
+		return NULL;
+	}
+
+	skb_put(skb, rx_len);
+	w5100_readbuf(priv, offset + 2, skb->data, rx_len);
+	w5100_write16(priv, W5100_S0_RX_RD, offset + 2 + rx_len);
+	w5100_command(priv, S0_CR_RECV);
+	skb->protocol = eth_type_trans(skb, ndev);
+
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += rx_len;
+
+	return skb;
+}
+
+static void w5100_rx_work(struct work_struct *work)
+{
+	struct w5100_priv *priv = container_of(work, struct w5100_priv,
+					       rx_work);
+	struct sk_buff *skb;
+
+	while ((skb = w5100_rx_skb(priv->ndev)))
+		netif_rx_ni(skb);
+
+	w5100_write(priv, W5100_IMR, IR_S0);
+}
+
+static int w5100_napi_poll(struct napi_struct *napi, int budget)
+{
+	struct w5100_priv *priv = container_of(napi, struct w5100_priv, napi);
+	int rx_count;
+
+	for (rx_count = 0; rx_count < budget; rx_count++) {
+		struct sk_buff *skb = w5100_rx_skb(priv->ndev);
 
-		netif_receive_skb(skb);
-		ndev->stats.rx_packets++;
-		ndev->stats.rx_bytes += rx_len;
+		if (skb)
+			netif_receive_skb(skb);
+		else
+			break;
 	}
 
 	if (rx_count < budget) {
@@ -699,10 +775,12 @@ static irqreturn_t w5100_interrupt(int irq, void *ndev_instance)
 	}
 
 	if (ir & S0_IR_RECV) {
-		if (napi_schedule_prep(&priv->napi)) {
-			w5100_write(priv, W5100_IMR, 0);
+		w5100_write(priv, W5100_IMR, 0);
+
+		if (priv->ops->may_sleep)
+			queue_work(priv->xfer_wq, &priv->rx_work);
+		else if (napi_schedule_prep(&priv->napi))
 			__napi_schedule(&priv->napi);
-		}
 	}
 
 	return IRQ_HANDLED;
@@ -726,6 +804,14 @@ static irqreturn_t w5100_detect_link(int irq, void *ndev_instance)
 	return IRQ_HANDLED;
 }
 
+static void w5100_setrx_work(struct work_struct *work)
+{
+	struct w5100_priv *priv = container_of(work, struct w5100_priv,
+					       setrx_work);
+
+	w5100_hw_start(priv);
+}
+
 static void w5100_set_rx_mode(struct net_device *ndev)
 {
 	struct w5100_priv *priv = netdev_priv(ndev);
@@ -733,7 +819,11 @@ static void w5100_set_rx_mode(struct net_device *ndev)
 
 	if (priv->promisc != set_promisc) {
 		priv->promisc = set_promisc;
-		w5100_hw_start(priv);
+
+		if (priv->ops->may_sleep)
+			schedule_work(&priv->setrx_work);
+		else
+			w5100_hw_start(priv);
 	}
 }
 
@@ -872,6 +962,17 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 	if (err < 0)
 		goto err_register;
 
+	priv->xfer_wq = create_workqueue(netdev_name(ndev));
+	if (!priv->xfer_wq) {
+		err = -ENOMEM;
+		goto err_wq;
+	}
+
+	INIT_WORK(&priv->rx_work, w5100_rx_work);
+	INIT_WORK(&priv->tx_work, w5100_tx_work);
+	INIT_WORK(&priv->setrx_work, w5100_setrx_work);
+	INIT_WORK(&priv->restart_work, w5100_restart_work);
+
 	if (mac_addr)
 		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
 	else
@@ -889,8 +990,14 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 		goto err_hw;
 	}
 
-	err = request_irq(priv->irq, w5100_interrupt, IRQF_TRIGGER_LOW,
-			  netdev_name(ndev), ndev);
+	if (ops->may_sleep) {
+		err = request_threaded_irq(priv->irq, NULL, w5100_interrupt,
+					   IRQF_TRIGGER_LOW | IRQF_ONESHOT,
+					   netdev_name(ndev), ndev);
+	} else {
+		err = request_irq(priv->irq, w5100_interrupt,
+				  IRQF_TRIGGER_LOW, netdev_name(ndev), ndev);
+	}
 	if (err)
 		goto err_hw;
 
@@ -915,6 +1022,8 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 err_gpio:
 	free_irq(priv->irq, ndev);
 err_hw:
+	destroy_workqueue(priv->xfer_wq);
+err_wq:
 	unregister_netdev(ndev);
 err_register:
 	free_netdev(ndev);
@@ -932,6 +1041,11 @@ int w5100_remove(struct device *dev)
 	if (gpio_is_valid(priv->link_gpio))
 		free_irq(priv->link_irq, ndev);
 
+	flush_work(&priv->setrx_work);
+	flush_work(&priv->restart_work);
+	flush_workqueue(priv->xfer_wq);
+	destroy_workqueue(priv->xfer_wq);
+
 	unregister_netdev(ndev);
 	free_netdev(ndev);
 	return 0;
diff --git a/drivers/net/ethernet/wiznet/w5100.h b/drivers/net/ethernet/wiznet/w5100.h
index 39d452d8..69045f0 100644
--- a/drivers/net/ethernet/wiznet/w5100.h
+++ b/drivers/net/ethernet/wiznet/w5100.h
@@ -8,6 +8,7 @@
  */
 
 struct w5100_ops {
+	bool may_sleep;
 	int (*read)(struct net_device *ndev, u16 addr);
 	int (*write)(struct net_device *ndev, u16 addr, u8 data);
 	int (*read16)(struct net_device *ndev, u16 addr);
-- 
2.5.0
