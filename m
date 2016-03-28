From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Subject: [PATCH] ethernet: mvneta: Support netpoll
Date: Mon, 28 Mar 2016 17:41:18 -0300
Message-ID: <1459197678-12022-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Cc: <netdev@vger.kernel.org>,
	Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36779 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbcC1Ulu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 16:41:50 -0400
Received: by mail-qk0-f177.google.com with SMTP id i4so90080641qkc.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 13:41:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds the support for netpoll, which is used
to implement netconsole.

Signed-off-by: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
---
Tested on Armada 370 Mirabox and Armada XP Openblocks AX3-4
with netconsole.

 drivers/net/ethernet/marvell/mvneta.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 577f7ca7deba..dd114303c98f 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3813,6 +3813,24 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void mvneta_percpu_poll_controller(void *arg)
+{
+	struct mvneta_port *pp = arg;
+	struct mvneta_pcpu_port *pcpu_port =
+		this_cpu_ptr(pp->ports);
+	mvneta_isr(pp->dev->irq, pcpu_port);
+}
+
+/* Polled functionality used by netconsole and others in non interrupt mode */
+static void mvneta_poll_controller(struct net_device *dev)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	on_each_cpu(mvneta_percpu_poll_controller, pp, false);
+}
+#endif
+
 static const struct net_device_ops mvneta_netdev_ops = {
 	.ndo_open            = mvneta_open,
 	.ndo_stop            = mvneta_stop,
@@ -3823,6 +3841,9 @@ static const struct net_device_ops mvneta_netdev_ops = {
 	.ndo_fix_features    = mvneta_fix_features,
 	.ndo_get_stats64     = mvneta_get_stats64,
 	.ndo_do_ioctl        = mvneta_ioctl,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = mvneta_poll_controller,
+#endif
 };
 
 const struct ethtool_ops mvneta_eth_tool_ops = {
-- 
2.7.0
