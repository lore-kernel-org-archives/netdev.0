From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: bcmgenet: Add netconsole support
Date: Thu, 30 Jul 2015 12:35:36 -0700
Message-ID: <1438284939-2750-2-git-send-email-f.fainelli@gmail.com>
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
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33513 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbbG3TjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 15:39:13 -0400
Received: by padck2 with SMTP id ck2so28138981pad.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 12:39:13 -0700 (PDT)
In-Reply-To: <1438284939-2750-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a poll controller for netconsole which invokes the RX
interrupt handler to poll for incoming packets, and cleans up all TX
queues.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index c6f2d396edf0..544160f39c1b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2388,6 +2388,16 @@ static irqreturn_t bcmgenet_wol_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void bcmgenet_poll_controller(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	bcmgenet_isr0(priv->irq0, priv);
+	bcmgenet_tx_reclaim_all(dev);
+}
+#endif
+
 static void bcmgenet_umac_reset(struct bcmgenet_priv *priv)
 {
 	u32 reg;
@@ -2939,6 +2949,9 @@ static const struct net_device_ops bcmgenet_netdev_ops = {
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
