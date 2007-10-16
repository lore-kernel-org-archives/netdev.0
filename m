From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/7] skge: changing MTU while running causes problems
Date: Tue, 16 Oct 2007 12:15:50 -0700
Message-ID: <20071016191733.940421506@linux-foundation.org>
References: <20071016191548.447710749@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37064 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761049AbXJPTTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:19:08 -0400
Content-Disposition: inline; filename=skge-mtu.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than bring network down/up when changing MTU,
only need to impact receiver.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/skge.c	2007-10-16 11:17:02.000000000 -0700
+++ b/drivers/net/skge.c	2007-10-16 11:22:41.000000000 -0700
@@ -2544,6 +2544,15 @@ static int skge_up(struct net_device *de
 	return err;
 }
 
+/* stop receiver */
+static void skge_rx_stop(struct skge_hw *hw, int port)
+{
+	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_STOP);
+	skge_write32(hw, RB_ADDR(port ? Q_R2 : Q_R1, RB_CTRL),
+		     RB_RST_SET|RB_DIS_OP_MD);
+	skge_write32(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_SET_RESET);
+}
+
 static int skge_down(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
@@ -2595,11 +2604,8 @@ static int skge_down(struct net_device *
 
 	/* Reset the RAM Buffer async Tx queue */
 	skge_write8(hw, RB_ADDR(port == 0 ? Q_XA1 : Q_XA2, RB_CTRL), RB_RST_SET);
-	/* stop receiver */
-	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_STOP);
-	skge_write32(hw, RB_ADDR(port ? Q_R2 : Q_R1, RB_CTRL),
-		     RB_RST_SET|RB_DIS_OP_MD);
-	skge_write32(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_SET_RESET);
+
+	skge_rx_stop(hw, port);
 
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		skge_write8(hw, SK_REG(port, TX_MFF_CTRL2), MFF_RST_SET);
@@ -2782,7 +2788,11 @@ static void skge_tx_timeout(struct net_d
 
 static int skge_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct skge_port *skge = netdev_priv(dev);
+	struct skge_hw *hw = skge->hw;
+	int port = skge->port;
 	int err;
+	u16 ctl, reg;
 
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
@@ -2792,13 +2802,40 @@ static int skge_change_mtu(struct net_de
 		return 0;
 	}
 
-	skge_down(dev);
+	skge_write32(hw, B0_IMSK, 0);
+	dev->trans_start = jiffies;	/* prevent tx timeout */
+	netif_stop_queue(dev);
+	napi_disable(&skge->napi);
+
+	ctl = gma_read16(hw, port, GM_GP_CTRL);
+	gma_write16(hw, port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
+
+	skge_rx_clean(skge);
+	skge_rx_stop(hw, port);
 
 	dev->mtu = new_mtu;
 
-	err = skge_up(dev);
+	reg = GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
+	if (new_mtu > 1500)
+		reg |= GM_SMOD_JUMBO_ENA;
+	gma_write16(hw, port, GM_SERIAL_MODE, reg);
+
+	skge_write8(hw, RB_ADDR(rxqaddr[port], RB_CTRL), RB_ENA_OP_MD);
+
+	err = skge_rx_fill(dev);
+	wmb();
+	if (!err)
+		skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
+	skge_write32(hw, B0_IMSK, hw->intr_mask);
+
 	if (err)
 		dev_close(dev);
+	else {
+		gma_write16(hw, port, GM_GP_CTRL, ctl);
+
+		napi_enable(&skge->napi);
+		netif_wake_queue(dev);
+	}
 
 	return err;
 }

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

