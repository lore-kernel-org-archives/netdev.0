From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/4] net: systemport: Add netconsole support
Date: Fri, 31 Jul 2015 11:42:55 -0700
Message-ID: <1438368177-23942-3-git-send-email-f.fainelli@gmail.com>
References: <1438368177-23942-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35382 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbbGaSpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 14:45:18 -0400
Received: by pabkd10 with SMTP id kd10so44931724pab.2
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 11:45:17 -0700 (PDT)
In-Reply-To: <1438368177-23942-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a poll controller for netconsole which invokes the RX
interrupt handler to poll for incoming packets, and cleans up all TX
queues by invoking the TX interrupt handler.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- properly pair the interrupt handler calls with disable/enable_irq
- remove the call to bcm_sysport_tx_reclaim, handler does this

 drivers/net/ethernet/broadcom/bcmsysport.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 4566cdf0bc39..b9a5a97ed4dd 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -933,6 +933,21 @@ static irqreturn_t bcm_sysport_wol_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void bcm_sysport_poll_controller(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+
+	disable_irq(priv->irq0);
+	bcm_sysport_rx_isr(priv->irq0, priv);
+	enable_irq(priv->irq0);
+
+	disable_irq(priv->irq1);
+	bcm_sysport_tx_isr(priv->irq1, priv);
+	enable_irq(priv->irq1);
+}
+#endif
+
 static struct sk_buff *bcm_sysport_insert_tsb(struct sk_buff *skb,
 					      struct net_device *dev)
 {
@@ -1723,6 +1738,9 @@ static const struct net_device_ops bcm_sysport_netdev_ops = {
 	.ndo_set_features	= bcm_sysport_set_features,
 	.ndo_set_rx_mode	= bcm_sysport_set_rx_mode,
 	.ndo_set_mac_address	= bcm_sysport_change_mac,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= bcm_sysport_poll_controller,
+#endif
 };
 
 #define REV_FMT	"v%2x.%02x"
-- 
2.1.0
