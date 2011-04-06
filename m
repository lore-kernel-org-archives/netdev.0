From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC net-next] qlge: use ethtool set_phys_id
Date: Wed, 6 Apr 2011 16:47:50 -0700
Message-ID: <20110406164750.11cfeef3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32961 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756760Ab1DFXrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 19:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a stab at replacing old ethtool phys_id with set_phys_id
on the Qlogic 10Gb driver. Compile tested only.

Not sure if set_led_cfg will flash continuously, or needs
to be replaced by ETHTOOL_ID_ON/ETHTOOL_ID_OFF

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/qlge/qlge_ethtool.c	2011-04-06 16:28:33.897200810 -0700
+++ b/drivers/net/qlge/qlge_ethtool.c	2011-04-06 16:39:55.140139828 -0700
@@ -412,31 +412,31 @@ static int ql_set_wol(struct net_device
 	return 0;
 }
 
-static int ql_phys_id(struct net_device *ndev, u32 data)
+static int ql_set_phys_id(struct net_device *ndev,
+			  enum ethtool_phys_id_state state)
+
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	u32 led_reg, i;
-	int status;
-
-	/* Save the current LED settings */
-	status = ql_mb_get_led_cfg(qdev);
-	if (status)
-		return status;
-	led_reg = qdev->led_config;
 
-	/* Start blinking the led */
-	if (!data || data > 300)
-		data = 300;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		/* Save the current LED settings */
+		if (ql_mb_get_led_cfg(qdev))
+			return -EIO;
 
-	for (i = 0; i < (data * 10); i++)
+		/* Start blinking */
 		ql_mb_set_led_cfg(qdev, QL_LED_BLINK);
+		return 0;
 
-	/* Restore LED settings */
-	status = ql_mb_set_led_cfg(qdev, led_reg);
-	if (status)
-		return status;
+	case ETHTOOL_ID_INACTIVE:
+		/* Restore LED settings */
+		if (ql_mb_set_led_cfg(qdev, qdev->led_config))
+			return -EIO;
+		return 0;
 
-	return 0;
+	default:
+		return -EINVAL;
+	}
 }
 
 static int ql_start_loopback(struct ql_adapter *qdev)
@@ -703,7 +703,7 @@ const struct ethtool_ops qlge_ethtool_op
 	.get_msglevel = ql_get_msglevel,
 	.set_msglevel = ql_set_msglevel,
 	.get_link = ethtool_op_get_link,
-	.phys_id		 = ql_phys_id,
+	.set_phys_id		 = ql_set_phys_id,
 	.self_test		 = ql_self_test,
 	.get_pauseparam		 = ql_get_pauseparam,
 	.set_pauseparam		 = ql_set_pauseparam,

