From: dhananjay@netxen.com
Subject: [PATCH 2/2] netxen: Fix interrupt handling for multiport adapters
Date: Sat, 21 Jul 2007 00:37:51 +0530
Message-ID: <20070720191307.605520215@netxen.com>
References: <20070720190749.535704712@netxen.com>
Cc: rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:1870 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S936440AbXGTTSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 15:18:40 -0400
Content-Disposition: inline; filename=intr.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes masking of interrupts on multiport adapters. Also disables
interrupts upon ifdown interface. The wrong mask could result in interrupt
flood after interface is down.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -930,6 +930,8 @@ static int netxen_nic_close(struct net_d
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
+	netxen_nic_disable_int(adapter);
+
 	cmd_buff = adapter->cmd_buf_arr;
 	for (i = 0; i < adapter->max_tx_desc_count; i++) {
 		buffrag = cmd_buff->frag_array;
@@ -1243,28 +1245,12 @@ static int
 netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	u32 ret = 0;
-	u32 our_int = 0;
 
 	DPRINTK(INFO, "Entered handle ISR\n");
 	adapter->stats.ints++;
 
-	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		/* not our interrupt */
-		if ((our_int & (0x80 << adapter->portnum)) == 0)
-			return ret;
-	}
-
 	netxen_nic_disable_int(adapter);
 
-	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
-		/* claim interrupt */
-		if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-			writel(our_int & ~((u32)(0x80 << adapter->portnum)),
-			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		}
-	}
-
 	if (netxen_nic_rx_has_work(adapter) || netxen_nic_tx_has_work(adapter)) {
 		if (netif_rx_schedule_prep(netdev)) {
 			/*
@@ -1298,6 +1284,7 @@ irqreturn_t netxen_intr(int irq, void *d
 {
 	struct netxen_adapter *adapter;
 	struct net_device *netdev;
+	u32 our_int = 0;
 
 	if (unlikely(!irq)) {
 		return IRQ_NONE;	/* Not our interrupt */
@@ -1305,7 +1292,22 @@ irqreturn_t netxen_intr(int irq, void *d
 
 	adapter = (struct netxen_adapter *)data;
 	netdev  = adapter->netdev;
-	/* process our status queue (for all 4 ports) */
+
+	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		/* not our interrupt */
+		if ((our_int & (0x80 << adapter->portnum)) == 0)
+			return IRQ_NONE;
+	}
+
+	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
+		/* claim interrupt */
+		if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+			writel(our_int & ~((u32)(0x80 << adapter->portnum)),
+			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		}
+	}
+
 	if (netif_running(netdev))
 		netxen_handle_int(adapter, netdev);
 

-- 
