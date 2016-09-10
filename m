From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH] net: Remove NO_IRQ from powerpc-only network drivers
Date: Sat, 10 Sep 2016 19:59:05 +1000
Message-ID: <1473501545-10134-1-git-send-email-mpe@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
        arnd@arndb.de
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:53812 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754107AbcIJJ7N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Sep 2016 05:59:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'd like to eventually remove NO_IRQ on powerpc, so remove usages of it
from powerpc-only drivers.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 drivers/net/ethernet/freescale/fman/fman_mac.h   |  2 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c |  2 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c |  2 +-
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c |  2 +-
 drivers/net/ethernet/ibm/emac/core.c             | 10 +++++-----
 drivers/net/ethernet/ibm/emac/mal.c              |  5 ++---
 drivers/net/ethernet/ibm/ibmvnic.c               |  4 ++--
 drivers/net/ethernet/toshiba/ps3_gelic_net.c     |  4 ++--
 8 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman_mac.h b/drivers/net/ethernet/freescale/fman/fman_mac.h
index 8ddeedbcef9c..ddf0260176c9 100644
--- a/drivers/net/ethernet/freescale/fman/fman_mac.h
+++ b/drivers/net/ethernet/freescale/fman/fman_mac.h
@@ -192,7 +192,7 @@ struct fman_mac_params {
 	/* A handle to the FM object this port related to */
 	void *fm;
 	/* MDIO exceptions interrupt source - not valid for all
-	 * MACs; MUST be set to 'NO_IRQ' for MACs that don't have
+	 * MACs; MUST be set to 0 for MACs that don't have
 	 * mdio-irq, or for polling
 	 */
 	void *dev_id; /* device cookie used by the exception cbs */
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
index d71761a34022..7a3277419876 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
@@ -90,7 +90,7 @@ static int do_pd_setup(struct fs_enet_private *fep)
 	int ret = -EINVAL;
 
 	fep->interrupt = irq_of_parse_and_map(ofdev->dev.of_node, 0);
-	if (fep->interrupt == NO_IRQ)
+	if (!fep->interrupt)
 		goto out;
 
 	fep->fcc.fccp = of_iomap(ofdev->dev.of_node, 0);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
index 35a318ed3a62..a09ba70cf09f 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
@@ -99,7 +99,7 @@ static int do_pd_setup(struct fs_enet_private *fep)
 	struct platform_device *ofdev = to_platform_device(fep->dev);
 
 	fep->interrupt = irq_of_parse_and_map(ofdev->dev.of_node, 0);
-	if (fep->interrupt == NO_IRQ)
+	if (!fep->interrupt)
 		return -EINVAL;
 
 	fep->fec.fecp = of_iomap(ofdev->dev.of_node, 0);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
index e8b9c33d35b4..69654fa67ca0 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
@@ -99,7 +99,7 @@ static int do_pd_setup(struct fs_enet_private *fep)
 	struct platform_device *ofdev = to_platform_device(fep->dev);
 
 	fep->interrupt = irq_of_parse_and_map(ofdev->dev.of_node, 0);
-	if (fep->interrupt == NO_IRQ)
+	if (!fep->interrupt)
 		return -EINVAL;
 
 	fep->scc.sccp = of_iomap(ofdev->dev.of_node, 0);
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 4c9771d57d6e..ec4d0f3b7850 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2750,7 +2750,7 @@ static int emac_probe(struct platform_device *ofdev)
 	/* Get interrupts. EMAC irq is mandatory, WOL irq is optional */
 	dev->emac_irq = irq_of_parse_and_map(np, 0);
 	dev->wol_irq = irq_of_parse_and_map(np, 1);
-	if (dev->emac_irq == NO_IRQ) {
+	if (!dev->emac_irq) {
 		printk(KERN_ERR "%s: Can't map main interrupt\n", np->full_name);
 		goto err_free;
 	}
@@ -2913,9 +2913,9 @@ static int emac_probe(struct platform_device *ofdev)
  err_reg_unmap:
 	iounmap(dev->emacp);
  err_irq_unmap:
-	if (dev->wol_irq != NO_IRQ)
+	if (dev->wol_irq)
 		irq_dispose_mapping(dev->wol_irq);
-	if (dev->emac_irq != NO_IRQ)
+	if (dev->emac_irq)
 		irq_dispose_mapping(dev->emac_irq);
  err_free:
 	free_netdev(ndev);
@@ -2957,9 +2957,9 @@ static int emac_remove(struct platform_device *ofdev)
 	emac_dbg_unregister(dev);
 	iounmap(dev->emacp);
 
-	if (dev->wol_irq != NO_IRQ)
+	if (dev->wol_irq)
 		irq_dispose_mapping(dev->wol_irq);
-	if (dev->emac_irq != NO_IRQ)
+	if (dev->emac_irq)
 		irq_dispose_mapping(dev->emac_irq);
 
 	free_netdev(dev->ndev);
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index fdb5cdb3cd15..aaf6fec566b5 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -597,9 +597,8 @@ static int mal_probe(struct platform_device *ofdev)
 		mal->rxde_irq = irq_of_parse_and_map(ofdev->dev.of_node, 4);
 	}
 
-	if (mal->txeob_irq == NO_IRQ || mal->rxeob_irq == NO_IRQ ||
-	    mal->serr_irq == NO_IRQ || mal->txde_irq == NO_IRQ ||
-	    mal->rxde_irq == NO_IRQ) {
+	if (!mal->txeob_irq || !mal->rxeob_irq || !mal->serr_irq ||
+	    !mal->txde_irq  || !mal->rxde_irq) {
 		printk(KERN_ERR
 		       "mal%d: failed to map interrupts !\n", index);
 		err = -ENODEV;
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 88f3c85fb04a..b334fc018215 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1422,7 +1422,7 @@ static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter)
 		scrq = adapter->tx_scrq[i];
 		scrq->irq = irq_create_mapping(NULL, scrq->hw_irq);
 
-		if (scrq->irq == NO_IRQ) {
+		if (!scrq->irq) {
 			rc = -EINVAL;
 			dev_err(dev, "Error mapping irq\n");
 			goto req_tx_irq_failed;
@@ -1442,7 +1442,7 @@ static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter)
 	for (i = 0; i < adapter->req_rx_queues; i++) {
 		scrq = adapter->rx_scrq[i];
 		scrq->irq = irq_create_mapping(NULL, scrq->hw_irq);
-		if (scrq->irq == NO_IRQ) {
+		if (!scrq->irq) {
 			rc = -EINVAL;
 			dev_err(dev, "Error mapping irq\n");
 			goto req_rx_irq_failed;
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 79f0ec4e51ac..bc258d7e41df 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1791,7 +1791,7 @@ fail_alloc_rx:
 	gelic_card_free_chain(card, card->tx_chain.head);
 fail_alloc_tx:
 	free_irq(card->irq, card);
-	netdev->irq = NO_IRQ;
+	netdev->irq = 0;
 fail_request_irq:
 	ps3_sb_event_receive_port_destroy(dev, card->irq);
 fail_alloc_irq:
@@ -1843,7 +1843,7 @@ static int ps3_gelic_driver_remove(struct ps3_system_bus_device *dev)
 	netdev0 = card->netdev[GELIC_PORT_ETHERNET_0];
 	/* disconnect event port */
 	free_irq(card->irq, card);
-	netdev0->irq = NO_IRQ;
+	netdev0->irq = 0;
 	ps3_sb_event_receive_port_destroy(card->dev, card->irq);
 
 	wait_event(card->waitq,
-- 
2.7.4
