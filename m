From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: add NAPI support
Date: Wed, 19 Jun 2013 02:09:25 +0400
Message-ID: <201306190209.26217.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver hasn't used NAPI so far; implement its support at last...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave Miller's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |   85 +++++++++++++++++++++++++++++-----
 drivers/net/ethernet/renesas/sh_eth.h |    1 
 2 files changed, 74 insertions(+), 12 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1244,7 +1244,7 @@ static int sh_eth_txfree(struct net_devi
 }
 
 /* Packet receive function */
-static int sh_eth_rx(struct net_device *ndev, u32 intr_status)
+static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_rxdesc *rxdesc;
@@ -1252,6 +1252,7 @@ static int sh_eth_rx(struct net_device *
 	int entry = mdp->cur_rx % mdp->num_rx_ring;
 	int boguscnt = (mdp->dirty_rx + mdp->num_rx_ring) - mdp->cur_rx;
 	struct sk_buff *skb;
+	int exceeded = 0;
 	u16 pkt_len = 0;
 	u32 desc_status;
 
@@ -1267,6 +1268,12 @@ static int sh_eth_rx(struct net_device *
 		if (--boguscnt < 0)
 			break;
 
+		if (*quota <= 0) {
+			exceeded = 1;
+			break;
+		}
+		(*quota)--;
+
 		if (!(desc_status & RDFEND))
 			ndev->stats.rx_length_errors++;
 
@@ -1343,7 +1350,7 @@ static int sh_eth_rx(struct net_device *
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
 	}
 
-	return 0;
+	return exceeded;
 }
 
 static void sh_eth_rcv_snd_disable(struct net_device *ndev)
@@ -1484,7 +1491,7 @@ static irqreturn_t sh_eth_interrupt(int 
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_cpu_data *cd = mdp->cd;
 	irqreturn_t ret = IRQ_NONE;
-	unsigned long intr_status;
+	unsigned long intr_status, intr_enable;
 
 	spin_lock(&mdp->lock);
 
@@ -1495,25 +1502,41 @@ static irqreturn_t sh_eth_interrupt(int 
 	 * and we need to fully handle it in sh_eth_error() in order to quench
 	 * it as it doesn't get cleared by just writing 1 to the ECI bit...
 	 */
-	intr_status &= sh_eth_read(ndev, EESIPR) | DMAC_M_ECI;
-	/* Clear interrupt */
-	if (intr_status & (EESR_RX_CHECK | cd->tx_check | cd->eesr_err_check)) {
-		sh_eth_write(ndev, intr_status, EESR);
+	intr_enable = sh_eth_read(ndev, EESIPR);
+	intr_status &= intr_enable | DMAC_M_ECI;
+	if (intr_status & (EESR_RX_CHECK | cd->tx_check | cd->eesr_err_check))
 		ret = IRQ_HANDLED;
-	} else
+	else
 		goto other_irq;
 
-	if (intr_status & EESR_RX_CHECK)
-		sh_eth_rx(ndev, intr_status);
+	if (intr_status & EESR_RX_CHECK) {
+		if (napi_schedule_prep(&mdp->napi)) {
+			/* Mask Rx interrupts */
+			sh_eth_write(ndev, intr_enable & ~EESR_RX_CHECK,
+				     EESIPR);
+			__napi_schedule(&mdp->napi);
+		} else {
+			dev_warn(&ndev->dev,
+				 "ignoring interrupt, status 0x%08lx, mask 0x%08lx.\n",
+				 intr_status, intr_enable);
+		}
+	}
 
 	/* Tx Check */
 	if (intr_status & cd->tx_check) {
+		/* Clear Tx interrupts */
+		sh_eth_write(ndev, intr_status & cd->tx_check, EESR);
+
 		sh_eth_txfree(ndev);
 		netif_wake_queue(ndev);
 	}
 
-	if (intr_status & cd->eesr_err_check)
+	if (intr_status & cd->eesr_err_check) {
+		/* Clear error interrupts */
+		sh_eth_write(ndev, intr_status & cd->eesr_err_check, EESR);
+
 		sh_eth_error(ndev, intr_status);
+	}
 
 other_irq:
 	spin_unlock(&mdp->lock);
@@ -1521,6 +1544,33 @@ other_irq:
 	return ret;
 }
 
+static int sh_eth_poll(struct napi_struct *napi, int budget)
+{
+	struct sh_eth_private *mdp = container_of(napi, struct sh_eth_private,
+						  napi);
+	struct net_device *ndev = napi->dev;
+	int quota = budget;
+	unsigned long intr_status;
+
+	for (;;) {
+		intr_status = sh_eth_read(ndev, EESR);
+		if (!(intr_status & EESR_RX_CHECK))
+			break;
+		/* Clear Rx interrupts */
+		sh_eth_write(ndev, intr_status & EESR_RX_CHECK, EESR);
+
+		if (sh_eth_rx(ndev, intr_status, &quota))
+			goto out;
+	}
+
+	napi_complete(napi);
+
+	/* Reenable Rx interrupts */
+	sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
+out:
+	return budget - quota;
+}
+
 /* PHY state control function */
 static void sh_eth_adjust_link(struct net_device *ndev)
 {
@@ -1832,6 +1882,8 @@ static int sh_eth_open(struct net_device
 	if (ret)
 		goto out_free_irq;
 
+	napi_enable(&mdp->napi);
+
 	return ret;
 
 out_free_irq:
@@ -1927,6 +1979,8 @@ static int sh_eth_close(struct net_devic
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
+	napi_disable(&mdp->napi);
+
 	netif_stop_queue(ndev);
 
 	/* Disable interrupts by clearing the interrupt mask. */
@@ -2616,10 +2670,12 @@ static int sh_eth_drv_probe(struct platf
 		}
 	}
 
+	netif_napi_add(ndev, &mdp->napi, sh_eth_poll, 64);
+
 	/* network device register */
 	ret = register_netdev(ndev);
 	if (ret)
-		goto out_release;
+		goto out_napi_del;
 
 	/* mdio bus init */
 	ret = sh_mdio_init(ndev, pdev->id, pd);
@@ -2637,6 +2693,9 @@ static int sh_eth_drv_probe(struct platf
 out_unregister:
 	unregister_netdev(ndev);
 
+out_napi_del:
+	netif_napi_del(&mdp->napi);
+
 out_release:
 	/* net_dev free */
 	if (ndev)
@@ -2649,9 +2708,11 @@ out:
 static int sh_eth_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct sh_eth_private *mdp = netdev_priv(ndev);
 
 	sh_mdio_release(ndev);
 	unregister_netdev(ndev);
+	netif_napi_del(&mdp->napi);
 	pm_runtime_disable(&pdev->dev);
 	free_netdev(ndev);
 
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -505,6 +505,7 @@ struct sh_eth_private {
 	u32 cur_tx, dirty_tx;
 	u32 rx_buf_sz;		/* Based on MTU+slack. */
 	int edmac_endian;
+	struct napi_struct napi;
 	/* MII transceiver section. */
 	u32 phy_id;					/* PHY ID */
 	struct mii_bus *mii_bus;	/* MDIO bus control */
