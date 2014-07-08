From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH C 3/7] net: fec: clear receive interrupts before processing a
 packet
Date: Tue, 08 Jul 2014 13:01:49 +0100
Message-ID: <E1X4U5l-0005u5-4g@rmk-PC.arm.linux.org.uk>
References: <20140708120117.GJ21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58737 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754499AbaGHMBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 08:01:51 -0400
In-Reply-To: <20140708120117.GJ21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear any pending receive interrupt before we process a pending packet.
This helps to avoid any spurious interrupts being raised after we have
fully cleaned the receive ring, while still allowing an interrupt to be
raised if we receive another packet.

The position of this is critical: we must do this prior to reading the
next packet status to avoid potentially dropping an interrupt when a
packet is still pending.

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b2ae7e706d5e..79d578d6db8a 100644
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
