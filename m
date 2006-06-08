From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] s2io: netpoll support
Date: Thu, 08 Jun 2006 12:01:58 -0400
Message-ID: <448849F6.8050002@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020507030406010608030501"
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:29141 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S964884AbWFHQCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 12:02:03 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020507030406010608030501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This adds netpoll support for things like netconsole/kgdboe to the s2io 
10GbE driver.

This duplicates some code from s2io_poll() as I wanted to be 
least-invasive, someone from Neterion might have other thoughts?

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------020507030406010608030501
Content-Type: text/x-patch;
 name="s2io.netpoll.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="s2io.netpoll.patch"

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 79208f4..c2c5f46 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2575,6 +2575,53 @@ no_rx:
 #endif
 
 /**
+ * s2io_netpoll - Rx interrupt service handler for netpoll support
+ * @dev : pointer to the device structure.
+ * Description:
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void s2io_netpoll(struct net_device *dev)
+{
+	nic_t *nic = dev->priv;
+	mac_info_t *mac_control;
+	struct config_param *config;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
+	u64 val64;
+	int i;
+
+	atomic_inc(&nic->isr_cnt);
+
+	/*  Disable all interrupts */
+	en_dis_able_nic_intrs(nic, ENA_ALL_INTRS, DISABLE_INTRS);
+
+	mac_control = &nic->mac_control;
+	config = &nic->config;
+
+	val64 = readq(&bar0->rx_traffic_int);
+	writeq(val64, &bar0->rx_traffic_int);
+
+	for (i = 0; i < config->rx_ring_num; i++)
+		rx_intr_handler(&mac_control->rings[i]);
+
+	for (i = 0; i < config->rx_ring_num; i++) {
+		if (fill_rx_buffers(nic, i) == -ENOMEM) {
+			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(ERR_DBG, " in Rx Netpoll!!\n");
+			break;
+		}
+	}
+	/* Re-enable all interrupts */
+	en_dis_able_nic_intrs(nic, ENA_ALL_INTRS, ENABLE_INTRS);
+	atomic_dec(&nic->isr_cnt);
+	return;
+}
+#endif
+
+/**
  *  rx_intr_handler - Rx interrupt handler
  *  @nic: device private variable.
  *  Description:
@@ -6210,6 +6257,10 @@ Defaulting to INTA\n");
 	dev->weight = 32;
 #endif
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = s2io_netpoll;
+#endif
+
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 	if (sp->high_dma_flag == TRUE)
 		dev->features |= NETIF_F_HIGHDMA;

--------------020507030406010608030501--
