From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] eHEA: net_poll support
Date: Mon, 23 Jul 2007 16:05:03 +0200
Message-ID: <200707231605.03459.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:9021 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbXGWOdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 10:33:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_poll support for eHEA added

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---


 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   22 +++++++++++++++++++++-
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 489c8b2..8ee2c2c 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0071"
+#define DRV_VERSION	"EHEA_0072"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 4c70a93..58702f5 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -589,6 +589,23 @@ static int ehea_poll(struct net_device *dev, int *budget)
 	return 1;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void ehea_netpoll(struct net_device *dev)
+{
+	struct ehea_port *port = netdev_priv(dev);
+
+	netif_rx_schedule(port->port_res[0].d_netdev);
+}
+#endif
+
+static int ehea_poll_firstqueue(struct net_device *dev, int *budget)
+{
+	struct ehea_port *port = netdev_priv(dev);
+	struct net_device *d_dev = port->port_res[0].d_netdev;
+
+	return ehea_poll(d_dev, budget);
+}
+
 static irqreturn_t ehea_recv_irq_handler(int irq, void *param)
 {
 	struct ehea_port_res *pr = param;
@@ -2626,7 +2643,10 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	memcpy(dev->dev_addr, &port->mac_addr, ETH_ALEN);
 
 	dev->open = ehea_open;
-	dev->poll = ehea_poll;
+	dev->poll = ehea_poll_firstqueue;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = ehea_netpoll;
+#endif
 	dev->weight = 64;
 	dev->stop = ehea_stop;
 	dev->hard_start_xmit = ehea_start_xmit;
-- 
1.5.2

