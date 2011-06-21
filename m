From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 4/7] benet: use irq naming standard
Date: Tue, 21 Jun 2011 10:05:45 -0700
Message-ID: <20110621170658.694188607@vyatta.com>
References: <20110621170541.309890798@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49490 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756977Ab1FURHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:07:23 -0400
Content-Disposition: inline; filename=benet-use-irqname.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the standard for network device IRQ nameing for multiqueue devices.
It appears, this device has one transmit interrup, but multiple receive
interrupts. They will now be named:
  ethX-tx-0 ethX-rx-0 ethX-rx-1 ...

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/benet/be_main.c	2011-06-21 09:34:01.407952135 -0700
+++ b/drivers/net/benet/be_main.c	2011-06-21 09:41:03.643951899 -0700
@@ -2196,13 +2196,16 @@ static inline int be_msix_vec_get(struct
 }
 
 static int be_request_irq(struct be_adapter *adapter,
-		struct be_eq_obj *eq_obj,
-		void *handler, char *desc, void *context)
+			  struct be_eq_obj *eq_obj,
+			  unsigned int usage, unsigned int queue,
+			  irq_handler_t handler, void *context)
 {
 	struct net_device *netdev = adapter->netdev;
 	int vec;
 
-	sprintf(eq_obj->desc, "%s-%s", netdev->name, desc);
+	netdev_irqname(eq_obj->desc, sizeof(eq_obj->desc),
+		       netdev, usage, queue);
+
 	vec = be_msix_vec_get(adapter, eq_obj);
 	return request_irq(vec, handler, 0, eq_obj->desc, context);
 }
@@ -2218,17 +2221,17 @@ static int be_msix_register(struct be_ad
 {
 	struct be_rx_obj *rxo;
 	int status, i;
-	char qname[10];
 
-	status = be_request_irq(adapter, &adapter->tx_eq, be_msix_tx_mcc, "tx",
-				adapter);
+	status = be_request_irq(adapter, &adapter->tx_eq,
+				NETIF_IRQ_TX, 0,
+				be_msix_tx_mcc, adapter);
 	if (status)
 		goto err;
 
 	for_all_rx_queues(adapter, rxo, i) {
-		sprintf(qname, "rxq%d", i);
-		status = be_request_irq(adapter, &rxo->rx_eq, be_msix_rx,
-				qname, rxo);
+		status = be_request_irq(adapter, &rxo->rx_eq,
+					NETIF_IRQ_RX, i,
+					be_msix_rx, rxo);
 		if (status)
 			goto err_msix;
 	}


