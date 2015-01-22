From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 4/4] sh_eth: Fix serialisation of interrupt disable with
 interrupt & NAPI handlers
Date: Thu, 22 Jan 2015 12:44:08 +0000
Message-ID: <1421930648.1222.289.camel@xylophone.i.decadent.org.uk>
References: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:40761 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbbAVMoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:44:10 -0500
In-Reply-To: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to stop the RX path accessing the RX ring while it's being
stopped or resized, we clear the interrupt mask (EESIPR) and then call
free_irq() or synchronise_irq().  This is insufficient because the
interrupt handler or NAPI poller may set EESIPR again after we clear
it.  Also, in sh_eth_set_ringparam() we currently don't disable NAPI
polling at all.

I could easily trigger a crash by running the loop:

   while ethtool -G eth0 rx 128 && ethtool -G eth0 rx 64; do echo -n .; done

and 'ping -f' toward the sh_eth port from another machine.

To fix this:
- Add a software flag (irq_enabled) to signal whether interrupts
  should be enabled
- In the interrupt handler, if the flag is clear then clear EESIPR
  and return
- In the NAPI poller, if the flag is clear then don't set EESIPR
- Set the flag before enabling interrupts in sh_eth_dev_init() and
  sh_eth_set_ringparam()
- Clear the flag and serialise with the interrupt and NAPI
  handlers before clearing EESIPR in sh_eth_close() and
  sh_eth_set_ringparam()

After this, I could run the loop for 100,000 iterations successfully.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |   39 +++++++++++++++++++++++++--------
 drivers/net/ethernet/renesas/sh_eth.h |    1 +
 2 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index be7aa43..d475929 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1316,8 +1316,10 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 		     RFLR);
 
 	sh_eth_write(ndev, sh_eth_read(ndev, EESR), EESR);
-	if (start)
+	if (start) {
+		mdp->irq_enabled = true;
 		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
+	}
 
 	/* PAUSE Prohibition */
 	val = (sh_eth_read(ndev, ECMR) & ECMR_DM) |
@@ -1653,7 +1655,12 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	if (intr_status & (EESR_RX_CHECK | cd->tx_check | cd->eesr_err_check))
 		ret = IRQ_HANDLED;
 	else
-		goto other_irq;
+		goto out;
+
+	if (!likely(mdp->irq_enabled)) {
+		sh_eth_write(ndev, 0, EESIPR);
+		goto out;
+	}
 
 	if (intr_status & EESR_RX_CHECK) {
 		if (napi_schedule_prep(&mdp->napi)) {
@@ -1684,7 +1691,7 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 		sh_eth_error(ndev, intr_status);
 	}
 
-other_irq:
+out:
 	spin_unlock(&mdp->lock);
 
 	return ret;
@@ -1712,7 +1719,8 @@ static int sh_eth_poll(struct napi_struct *napi, int budget)
 	napi_complete(napi);
 
 	/* Reenable Rx interrupts */
-	sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
+	if (mdp->irq_enabled)
+		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
 out:
 	return budget - quota;
 }
@@ -1970,12 +1978,20 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 	if (netif_running(ndev)) {
 		netif_device_detach(ndev);
 		netif_tx_disable(ndev);
-		/* Disable interrupts by clearing the interrupt mask. */
+
+		/* Serialise with the interrupt handler and NAPI, then
+		 * disable interrupts.  We have to clear the
+		 * irq_enabled flag first to ensure that interrupts
+		 * won't be re-enabled.
+		 */
+		mdp->irq_enabled = false;
+		synchronize_irq(ndev->irq);
+		napi_synchronize(&mdp->napi);
 		sh_eth_write(ndev, 0x0000, EESIPR);
+
 		/* Stop the chip's Tx and Rx processes. */
 		sh_eth_write(ndev, 0, EDTRR);
 		sh_eth_write(ndev, 0, EDRRR);
-		synchronize_irq(ndev->irq);
 
 		/* Free all the skbuffs in the Rx queue. */
 		sh_eth_ring_free(ndev);
@@ -2001,6 +2017,7 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 			return ret;
 		}
 
+		mdp->irq_enabled = true;
 		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
 		/* Setting the Rx mode will start the Rx process. */
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
@@ -2184,7 +2201,13 @@ static int sh_eth_close(struct net_device *ndev)
 
 	netif_stop_queue(ndev);
 
-	/* Disable interrupts by clearing the interrupt mask. */
+	/* Serialise with the interrupt handler and NAPI, then disable
+	 * interrupts.  We have to clear the irq_enabled flag first to
+	 * ensure that interrupts won't be re-enabled.
+	 */
+	mdp->irq_enabled = false;
+	synchronize_irq(ndev->irq);
+	napi_disable(&mdp->napi);
 	sh_eth_write(ndev, 0x0000, EESIPR);
 
 	/* Stop the chip's Tx and Rx processes. */
@@ -2201,8 +2224,6 @@ static int sh_eth_close(struct net_device *ndev)
 
 	free_irq(ndev->irq, ndev);
 
-	napi_disable(&mdp->napi);
-
 	/* Free all the skbuffs in the Rx queue. */
 	sh_eth_ring_free(ndev);
 
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 7bfaf1c..259d03f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -513,6 +513,7 @@ struct sh_eth_private {
 	u32 rx_buf_sz;			/* Based on MTU+slack. */
 	int edmac_endian;
 	struct napi_struct napi;
+	bool irq_enabled;
 	/* MII transceiver section. */
 	u32 phy_id;			/* PHY ID */
 	struct mii_bus *mii_bus;	/* MDIO bus control */
-- 
1.7.10.4
