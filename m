From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/5] ucc_geth: Factor out MAC initialization steps into a
 call
Date: Thu, 27 Aug 2009 21:35:54 +0400
Message-ID: <20090827173554.GC1580@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Timur Tabi <timur@freescale.com>,
	Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:17554 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751704AbZH0Rfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 13:35:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch factors out MAC initialization into ucc_geth_init_mac()
function that we'll use for suspend/resume.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   87 ++++++++++++++++++++++++++++-------------------
 1 files changed, 52 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 3b957e6..488b591 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3413,46 +3413,25 @@ static int ucc_geth_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
-/* Called when something needs to use the ethernet device */
-/* Returns 0 for success. */
-static int ucc_geth_open(struct net_device *dev)
+static int ucc_geth_init_mac(struct ucc_geth_private *ugeth)
 {
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	struct net_device *dev = ugeth->ndev;
 	int err;
 
-	ugeth_vdbg("%s: IN", __func__);
-
-	/* Test station address */
-	if (dev->dev_addr[0] & ENET_GROUP_ADDR) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Multicast address used for station address"
-				  " - is this what you wanted?", __func__);
-		return -EINVAL;
-	}
-
-	err = init_phy(dev);
-	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot initialize PHY, aborting.",
-				  dev->name);
-		return err;
-	}
-
 	err = ucc_struct_init(ugeth);
 	if (err) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot configure internal struct, aborting.", dev->name);
-		goto out_err_stop;
+			ugeth_err("%s: Cannot configure internal struct, "
+				  "aborting.", dev->name);
+		goto err;
 	}
 
-	napi_enable(&ugeth->napi);
-
 	err = ucc_geth_startup(ugeth);
 	if (err) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Cannot configure net device, aborting.",
 				  dev->name);
-		goto out_err;
+		goto err;
 	}
 
 	err = adjust_enet_interface(ugeth);
@@ -3460,7 +3439,7 @@ static int ucc_geth_open(struct net_device *dev)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Cannot configure net device, aborting.",
 				  dev->name);
-		goto out_err;
+		goto err;
 	}
 
 	/*       Set MACSTNADDR1, MACSTNADDR2                */
@@ -3474,13 +3453,51 @@ static int ucc_geth_open(struct net_device *dev)
 				   &ugeth->ug_regs->macstnaddr1,
 				   &ugeth->ug_regs->macstnaddr2);
 
-	phy_start(ugeth->phydev);
-
 	err = ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
 	if (err) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Cannot enable net device, aborting.", dev->name);
-		goto out_err;
+		goto err;
+	}
+
+	return 0;
+err:
+	ucc_geth_stop(ugeth);
+	return err;
+}
+
+/* Called when something needs to use the ethernet device */
+/* Returns 0 for success. */
+static int ucc_geth_open(struct net_device *dev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	int err;
+
+	ugeth_vdbg("%s: IN", __func__);
+
+	/* Test station address */
+	if (dev->dev_addr[0] & ENET_GROUP_ADDR) {
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Multicast address used for station "
+				  "address - is this what you wanted?",
+				  __func__);
+		return -EINVAL;
+	}
+
+	err = init_phy(dev);
+	if (err) {
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot initialize PHY, aborting.",
+				  dev->name);
+		return err;
+	}
+
+	err = ucc_geth_init_mac(ugeth);
+	if (err) {
+		if (netif_msg_ifup(ugeth))
+			ugeth_err("%s: Cannot initialize MAC, aborting.",
+				  dev->name);
+		goto err;
 	}
 
 	err = request_irq(ugeth->ug_info->uf_info.irq, ucc_geth_irq_handler,
@@ -3489,16 +3506,16 @@ static int ucc_geth_open(struct net_device *dev)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Cannot get IRQ for net device, aborting.",
 				  dev->name);
-		goto out_err;
+		goto err;
 	}
 
+	phy_start(ugeth->phydev);
+	napi_enable(&ugeth->napi);
 	netif_start_queue(dev);
 
 	return err;
 
-out_err:
-	napi_disable(&ugeth->napi);
-out_err_stop:
+err:
 	ucc_geth_stop(ugeth);
 	return err;
 }
-- 
1.6.3.3

