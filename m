From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] skge: MTU changing fix
Date: Wed, 28 Nov 2007 14:25:05 -0800
Message-ID: <20071128142505.2018aa73@freepuppy.rosehill>
References: <20071126195447.846382144@linux-foundation.org>
	<20071126195557.815206367@linux-foundation.org>
	<20071128142301.116526f4@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45709 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756573AbXK1XbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 18:31:05 -0500
In-Reply-To: <20071128142301.116526f4@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code to change MTU doesn't correctly handle all the chip variations
and requirements for restarting.  On Genesis chips changing MTU would just
cause receiver to hang.
Use a simpler approach of just taking link down/up if needed.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---

Please apply to 2.6.24 (upstream-fixes).

--- a/drivers/net/skge.c	2007-11-28 11:49:15.000000000 -0800
+++ b/drivers/net/skge.c	2007-11-28 11:49:48.000000000 -0800
@@ -2896,11 +2896,7 @@ static void skge_tx_timeout(struct net_d
 
 static int skge_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct skge_port *skge = netdev_priv(dev);
-	struct skge_hw *hw = skge->hw;
-	int port = skge->port;
 	int err;
-	u16 ctl, reg;
 
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
@@ -2910,40 +2906,13 @@ static int skge_change_mtu(struct net_de
 		return 0;
 	}
 
-	skge_write32(hw, B0_IMSK, 0);
-	dev->trans_start = jiffies;	/* prevent tx timeout */
-	netif_stop_queue(dev);
-	napi_disable(&skge->napi);
-
-	ctl = gma_read16(hw, port, GM_GP_CTRL);
-	gma_write16(hw, port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
-
-	skge_rx_clean(skge);
-	skge_rx_stop(hw, port);
+	skge_down(dev);
 
 	dev->mtu = new_mtu;
 
-	reg = GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
-	if (new_mtu > 1500)
-		reg |= GM_SMOD_JUMBO_ENA;
-	gma_write16(hw, port, GM_SERIAL_MODE, reg);
-
-	skge_write8(hw, RB_ADDR(rxqaddr[port], RB_CTRL), RB_ENA_OP_MD);
-
-	err = skge_rx_fill(dev);
-	wmb();
-	if (!err)
-		skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
-	skge_write32(hw, B0_IMSK, hw->intr_mask);
-
+	err = skge_up(dev);
 	if (err)
 		dev_close(dev);
-	else {
-		gma_write16(hw, port, GM_GP_CTRL, ctl);
-
-		napi_enable(&skge->napi);
-		netif_wake_queue(dev);
-	}
 
 	return err;
 }
