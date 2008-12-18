From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/6] ucc_geth: Fix TX watchdog timeout handling
Date: Thu, 18 Dec 2008 21:23:26 +0300
Message-ID: <20081218182326.GB30682@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Cc: David Miller <davem@davemloft.net>, Li Yang <leoli@freescale.com>,
	Timur Tabi <timur@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:26581 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752219AbYLRSX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 13:23:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timeout handling code is currently broken in several ways:

- It calls stop() (which frees all the memory and IRQ), and then
  calls startup() (which won't re-request IRQ, neither it will
  re-init the Fast UCC structure).
- It calls these routines from the softirq context, which is wrong,
  since stop() calls free_irq() (which might sleep) and startup()
  allocates things with GFP_KERNEL.
- It won't soft-reset the PHY. We need the PHY reset for at least
  MPC8360E-MDS boards with Marvell 88E1111 PHY, the PHY won't recover
  from timeouts w/o the reset.

So the patch fixes these problems by implementing the workqueue for the
timeout handling, and there we fully re-open the device via close() and
open() calls. The close/open paths do the right things, and I can see
that the driver actually survive the timeouts.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   37 +++++++++++++++++++++++++++++--------
 drivers/net/ucc_geth.h |    1 +
 2 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 79e6d3d..98a7bd4 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3355,13 +3355,17 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	return 0;
 }
 
-/* ucc_geth_timeout gets called when a packet has not been
- * transmitted after a set amount of time.
- * For now, assume that clearing out all the structures, and
- * starting over will fix the problem. */
-static void ucc_geth_timeout(struct net_device *dev)
+static int ucc_geth_close(struct net_device *dev);
+static int ucc_geth_open(struct net_device *dev);
+
+/* Reopen device. This will reset the MAC and PHY. */
+static void ucc_geth_timeout_work(struct work_struct *work)
 {
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	struct ucc_geth_private *ugeth;
+	struct net_device *dev;
+
+	ugeth = container_of(work, struct ucc_geth_private, timeout_work);
+	dev = ugeth->dev;
 
 	ugeth_vdbg("%s: IN", __func__);
 
@@ -3370,13 +3374,29 @@ static void ucc_geth_timeout(struct net_device *dev)
 	ugeth_dump_regs(ugeth);
 
 	if (dev->flags & IFF_UP) {
-		ucc_geth_stop(ugeth);
-		ucc_geth_startup(ugeth);
+		/*
+		 * Must reset MAC *and* PHY. This is done by reopening
+		 * the device.
+		 */
+		ucc_geth_close(dev);
+		ucc_geth_open(dev);
 	}
 
 	netif_tx_schedule_all(dev);
 }
 
+/*
+ * ucc_geth_timeout gets called when a packet has not been
+ * transmitted after a set amount of time.
+ */
+static void ucc_geth_timeout(struct net_device *dev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+
+	netif_carrier_off(dev);
+	schedule_work(&ugeth->timeout_work);
+}
+
 /* This is called by the kernel when a frame is ready for transmission. */
 /* It is pointed to by the dev->hard_start_xmit function pointer */
 static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -4029,6 +4049,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->hard_start_xmit = ucc_geth_start_xmit;
 	dev->tx_timeout = ucc_geth_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+	INIT_WORK(&ugeth->timeout_work, ucc_geth_timeout_work);
 	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = ucc_netpoll;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index abc0e22..d74d2f7 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1186,6 +1186,7 @@ struct ucc_geth_private {
 	struct ucc_fast_private *uccf;
 	struct net_device *dev;
 	struct napi_struct napi;
+	struct work_struct timeout_work;
 	struct ucc_geth __iomem *ug_regs;
 	struct ucc_geth_init_pram *p_init_enet_param_shadow;
 	struct ucc_geth_exf_global_pram __iomem *p_exf_glbl_param;
-- 
1.5.6.5

