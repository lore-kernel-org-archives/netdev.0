From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] s2io: netpoll support
Date: Thu, 15 Jun 2006 14:36:36 -0400
Message-ID: <4491A8B4.1050105@hp.com>
References: <005401c68f41$bc4bfaa0$3e10100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090704080601010406090803"
Cc: ravinandan.arakali@neterion.com, jgarzik@pobox.com,
	"Ananda. Raju (E-mail)" <ananda.raju@neterion.com>,
	"Leonid. Grossman (E-mail)" <leonid.grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelbas04.cce.hp.com ([161.114.21.107]:6828 "EHLO
	ccerelbas04.cce.hp.com") by vger.kernel.org with ESMTP
	id S1031050AbWFOSgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 14:36:40 -0400
To: netdev@vger.kernel.org
In-Reply-To: <005401c68f41$bc4bfaa0$3e10100a@pc.s2io.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090704080601010406090803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This adds netpoll support for things like netconsole/kgdboe to the s2io
10GbE driver.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------090704080601010406090803
Content-Type: text/x-patch;
 name="s2io.netpoll.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="s2io.netpoll.patch"

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 79208f4..f2b8dba 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2575,6 +2575,50 @@ no_rx:
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
+	disable_irq(dev->irq);
+
+	atomic_inc(&nic->isr_cnt);
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
+	atomic_dec(&nic->isr_cnt);
+	enable_irq(dev->irq);
+	return;
+}
+#endif
+
+/**
  *  rx_intr_handler - Rx interrupt handler
  *  @nic: device private variable.
  *  Description:
@@ -6210,6 +6254,10 @@ Defaulting to INTA\n");
 	dev->weight = 32;
 #endif
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = s2io_netpoll;
+#endif
+
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 	if (sp->high_dma_flag == TRUE)
 		dev->features |= NETIF_F_HIGHDMA;

--------------090704080601010406090803--
