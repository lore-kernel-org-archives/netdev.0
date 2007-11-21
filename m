From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 1/2][2.6.24] ehea: Improve tx packets counting
Date: Wed, 21 Nov 2007 17:37:58 +0100
Message-ID: <200711211737.58789.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:57474 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbXKUQj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 11:39:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using own tx_packets counter instead of firmware counters.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |    9 +++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index f78e5bf..5935899 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0080"
+#define DRV_VERSION	"EHEA_0082"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index f0319f1..d2f715d 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -136,7 +136,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	struct ehea_port *port = netdev_priv(dev);
 	struct net_device_stats *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
-	u64 hret, rx_packets;
+	u64 hret, rx_packets, tx_packets;
 	int i;
 
 	memset(stats, 0, sizeof(*stats));
@@ -162,7 +162,11 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	for (i = 0; i < port->num_def_qps; i++)
 		rx_packets += port->port_res[i].rx_packets;
 
-	stats->tx_packets = cb2->txucp + cb2->txmcp + cb2->txbcp;
+	tx_packets = 0;
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+		tx_packets += port->port_res[i].tx_packets;
+
+	stats->tx_packets = tx_packets;
 	stats->multicast = cb2->rxmcp;
 	stats->rx_errors = cb2->rxuerr;
 	stats->rx_bytes = cb2->rxo;
@@ -2000,6 +2004,7 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	ehea_post_swqe(pr->qp, swqe);
+	pr->tx_packets++;
 
 	if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
 		spin_lock_irqsave(&pr->netif_queue, flags);
-- 
1.5.2
