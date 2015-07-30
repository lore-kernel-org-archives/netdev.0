From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: systemport: Add netconsole support
Date: Thu, 30 Jul 2015 12:35:37 -0700
Message-ID: <1438284939-2750-3-git-send-email-f.fainelli@gmail.com>
References: <1438284939-2750-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34562 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbG3TjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 15:39:13 -0400
Received: by pdbbh15 with SMTP id bh15so29124610pdb.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 12:39:13 -0700 (PDT)
In-Reply-To: <1438284939-2750-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a poll controller for netconsole which invokes the RX
interrupt handler to poll for incoming packets, and cleans up all TX
queues.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 4566cdf0bc39..3685924708f6 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -933,6 +933,16 @@ static irqreturn_t bcm_sysport_wol_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void bcm_sysport_poll_controller(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+
+	bcm_sysport_rx_isr(priv->irq0, priv);
+	bcm_sysport_tx_reclaim_all(priv);
+}
+#endif
+
 static struct sk_buff *bcm_sysport_insert_tsb(struct sk_buff *skb,
 					      struct net_device *dev)
 {
@@ -1723,6 +1733,9 @@ static const struct net_device_ops bcm_sysport_netdev_ops = {
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
