From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [7/12] pasemi_mac: Improve RX interrupt mitigation
Date: Wed, 28 Nov 2007 20:57:09 -0600
Message-ID: <20071129025709.GH17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:36893 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755978AbXK2Cx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:53:58 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: Improve RX interrupt mitigation

Currently the receive side interrupts will go off on the reception of
a packet, NAPI will poll the ring and keep polling as long as there's
a decent amount of packets to receive.

This is less than optimal, especially for LRO where it's better if we
have a more substantial amount of packets to process at once, to get
the real LRO benefits.

So, set the count threshold to a higher value and use the timeout feature
that will give us an interrupt even if not enough packets have come in
to set off the count threshold.

FIXME: It'd be real nice to have ethtool support for users to tune this
at runtime.


Signed-off-by: Olof Johansson <olof@lixom.net>


---
 drivers/net/pasemi_mac.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -504,15 +504,19 @@ static void pasemi_mac_replenish_rx_ring
 
 static void pasemi_mac_restart_rx_intr(const struct pasemi_mac *mac)
 {
+	struct pasemi_mac_rxring *rx = rx_ring(mac);
 	unsigned int reg, pcnt;
 	/* Re-enable packet count interrupts: finally
 	 * ack the packet count interrupt we got in rx_intr.
 	 */
 
-	pcnt = *rx_ring(mac)->chan.status & PAS_STATUS_PCNT_M;
+	pcnt = *rx->chan.status & PAS_STATUS_PCNT_M;
 
 	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_RXCH_RESET_PINTC;
 
+	if (*rx->chan.status & PAS_STATUS_TIMER)
+		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
+
 	write_iob_reg(PAS_IOB_DMA_RXCH_RESET(mac->rx->chan.chno), reg);
 }
 
@@ -795,8 +799,6 @@ static irqreturn_t pasemi_mac_rx_intr(in
 		reg |= PAS_IOB_DMA_RXCH_RESET_SINTC;
 	if (*chan->status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_RXCH_RESET_DINTC;
-	if (*chan->status & PAS_STATUS_TIMER)
-		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
 
 	netif_rx_schedule(dev, &mac->napi);
 
@@ -972,10 +974,6 @@ static int pasemi_mac_open(struct net_de
 
 	write_mac_reg(mac, PAS_MAC_CFG_TXP, flags);
 
-	/* 0xffffff is max value, about 16ms */
-	write_iob_reg(PAS_IOB_DMA_COM_TIMEOUTCFG,
-		      PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
-
 	ret = pasemi_mac_setup_rx_resources(dev);
 	if (ret)
 		goto out_rx_resources;
@@ -985,8 +983,12 @@ static int pasemi_mac_open(struct net_de
 	if (!mac->tx)
 		goto out_tx_ring;
 
+	/* 0x3ff with 33MHz clock is about 31us */
+	write_iob_reg(PAS_IOB_DMA_COM_TIMEOUTCFG,
+		      PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0x3ff));
+
 	write_iob_reg(PAS_IOB_DMA_RXCH_CFG(mac->rx->chan.chno),
-		      PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
+		      PAS_IOB_DMA_RXCH_CFG_CNTTH(128));
 
 	write_iob_reg(PAS_IOB_DMA_TXCH_CFG(mac->tx->chan.chno),
 		      PAS_IOB_DMA_TXCH_CFG_CNTTH(32));
