From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [5/6] pasemi_mac: don't enable rx before there are buffers
	on the ring
Date: Wed, 26 Sep 2007 16:24:42 -0500
Message-ID: <20070926212442.GF24168@lixom.net>
References: <20070926212200.GA24168@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49477 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762156AbXIZVVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 17:21:33 -0400
Content-Disposition: inline
In-Reply-To: <20070926212200.GA24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: don't enable rx before there are buffers on the ring

Reorder initialization of the DMA channels and the interface. Before there
was a time window when the interface was enabled before DMA was enabled.
Also, now there will always be RX buffers available at the time the
MAC interface is enabled, to avoid temporary out-of-buffer errors for the
very first packets (on busy networks).


Signed-off-by: Olof Johansson <olof@lixom.net>


Index: 2.6.23/drivers/net/pasemi_mac.c
===================================================================
--- 2.6.23.orig/drivers/net/pasemi_mac.c
+++ 2.6.23/drivers/net/pasemi_mac.c
@@ -791,14 +791,6 @@ static int pasemi_mac_open(struct net_de
 
 	write_mac_reg(mac, PAS_MAC_CFG_TXP, flags);
 
-	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
-		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
-
-	if (mac->type == MAC_TYPE_GMAC)
-		flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
-	else
-		flags |= PAS_MAC_CFG_PCFG_TSR_10G | PAS_MAC_CFG_PCFG_SPD_10G;
-
 	write_iob_reg(mac, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
 			   PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
 
@@ -813,8 +805,6 @@ static int pasemi_mac_open(struct net_de
 	write_iob_reg(mac, PAS_IOB_DMA_COM_TIMEOUTCFG,
 			   PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
 
-	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
-
 	ret = pasemi_mac_setup_rx_resources(dev);
 	if (ret)
 		goto out_rx_resources;
@@ -842,6 +832,17 @@ static int pasemi_mac_open(struct net_de
 
 	pasemi_mac_replenish_rx_ring(dev);
 
+	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
+		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
+
+	if (mac->type == MAC_TYPE_GMAC)
+		flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
+	else
+		flags |= PAS_MAC_CFG_PCFG_TSR_10G | PAS_MAC_CFG_PCFG_SPD_10G;
+
+	/* Enable interface in MAC */
+	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
+
 	ret = pasemi_mac_phy_init(dev);
 	/* Some configs don't have PHYs (XAUI etc), so don't complain about
 	 * failed init due to -ENODEV.
