From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/4] net: bcmgenet: Add netconsole support
Date: Fri, 31 Jul 2015 11:42:54 -0700
Message-ID: <1438368177-23942-2-git-send-email-f.fainelli@gmail.com>
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
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35159 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbGaSpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 14:45:16 -0400
Received: by pdrg1 with SMTP id g1so46844798pdr.2
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 11:45:15 -0700 (PDT)
In-Reply-To: <1438368177-23942-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a poll controller for netconsole which invokes both of our
interrupt handlers for the different RX/TX queues.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- properly pair the interrupt handler with disable/enable_irq pairs
- remove the call to bcmgenet_tx_reclaim, this is done by the handler

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index c6f2d396edf0..eb080ef8ee97 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2388,6 +2388,23 @@ static irqreturn_t bcmgenet_wol_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void bcmgenet_poll_controller(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	/* Invoke the main RX/TX interrupt handler */
+	disable_irq(priv->irq0);
+	bcmgenet_isr0(priv->irq0, priv);
+	enable_irq(priv->irq0);
+
+	/* And the interrupt handler for RX/TX priority queues */
+	disable_irq(priv->irq1);
+	bcmgenet_isr1(priv->irq1, priv);
+	enable_irq(priv->irq1);
+}
+#endif
+
 static void bcmgenet_umac_reset(struct bcmgenet_priv *priv)
 {
 	u32 reg;
@@ -2939,6 +2956,9 @@ static const struct net_device_ops bcmgenet_netdev_ops = {
 	.ndo_set_mac_address	= bcmgenet_set_mac_addr,
 	.ndo_do_ioctl		= bcmgenet_ioctl,
 	.ndo_set_features	= bcmgenet_set_features,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= bcmgenet_poll_controller,
+#endif
 };
 
 /* Array of GENET hardware parameters/characteristics */
-- 
2.1.0
