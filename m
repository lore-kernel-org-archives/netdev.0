From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 26/30] net: fec: clear receive interrupts before
 processing a packet
Date: Fri, 27 Jun 2014 16:21:06 +0100
Message-ID: <E1X0Xxa-0001Ot-54@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45258 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754353AbaF0PVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:21:08 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear any pending receive interrupt before we process a pending packet.
This helps to avoid any spurious interrupts being raised after we have
fully cleaned the receive ring, while still allowing an interrupt to be
raised if we receive another packet.

The position of this is critical: we must do this prior to reading the
next packet status to avoid potentially dropping an interrupt when a
packet is still pending.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 05982fb42000..e15cb9bc2eae 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1184,6 +1184,8 @@ fec_enet_rx(struct net_device *ndev, int budget)
 		if ((status & BD_ENET_RX_LAST) == 0)
 			netdev_err(ndev, "rcv is not +last\n");
 
+		writel(FEC_ENET_RXF, fep->hwp + FEC_IEVENT);
+
 		/* Check for errors. */
 		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
 			   BD_ENET_RX_CR | BD_ENET_RX_OV)) {
-- 
1.8.3.1
