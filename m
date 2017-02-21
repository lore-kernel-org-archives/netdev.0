From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv4 net-next 04/13] net: mvpp2: handle too large value in mvpp2_rx_time_coal_set()
Date: Tue, 21 Feb 2017 11:28:04 +0100
Message-ID: <1487672893-5746-5-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1487672893-5746-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@arm.linux.org.uk>,
        Stefan Chulski <stefanc@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:49535 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdBUK2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 05:28:43 -0500
In-Reply-To: <1487672893-5746-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring the MVPP2_ISR_RX_THRESHOLD_REG with the RX coalescing
time threshold, we do not check for the maximum allowed value supported
by the driver, which means we might overflow and use a bogus value. This
commit adds a check for this situation, and if a value higher than what
is supported by the hardware is provided, then we use the maximum value
supported by the hardware.

In order to achieve this in a way that avoids overflow and rounding
errors, we introduce two utility functions mvpp2_usec_to_cycles() and
cycles_to_usec(). Many thanks to Russell King for suggesting this
implementation.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Acked-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvpp2.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 559d7d0..6fe1520 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -154,6 +154,7 @@
 
 /* Interrupt Cause and Mask registers */
 #define MVPP2_ISR_RX_THRESHOLD_REG(rxq)		(0x5200 + 4 * (rxq))
+#define     MVPP2_MAX_ISR_RX_THRESHOLD		0xfffff0
 #define MVPP2_ISR_RXQ_GROUP_REG(rxq)		(0x5400 + 4 * (rxq))
 #define MVPP2_ISR_ENABLE_REG(port)		(0x5420 + 4 * (port))
 #define     MVPP2_ISR_ENABLE_INTERRUPT(mask)	((mask) & 0xffff)
@@ -4389,13 +4390,39 @@ static void mvpp2_rx_pkts_coal_set(struct mvpp2_port *port,
 		    rxq->pkts_coal);
 }
 
+static u32 mvpp2_usec_to_cycles(u32 usec, unsigned long clk_hz)
+{
+	u64 tmp = (u64)clk_hz * usec;
+
+	do_div(tmp, USEC_PER_SEC);
+
+	return tmp > U32_MAX ? U32_MAX : tmp;
+}
+
+static u32 mvpp2_cycles_to_usec(u32 cycles, unsigned long clk_hz)
+{
+	u64 tmp = (u64)cycles * USEC_PER_SEC;
+
+	do_div(tmp, clk_hz);
+
+	return tmp > U32_MAX ? U32_MAX : tmp;
+}
+
 /* Set the time delay in usec before Rx interrupt */
 static void mvpp2_rx_time_coal_set(struct mvpp2_port *port,
 				   struct mvpp2_rx_queue *rxq)
 {
-	u32 val;
+	unsigned long freq = port->priv->tclk;
+	u32 val = mvpp2_usec_to_cycles(rxq->time_coal, freq);
+
+	if (val > MVPP2_MAX_ISR_RX_THRESHOLD) {
+		rxq->time_coal =
+			mvpp2_cycles_to_usec(MVPP2_MAX_ISR_RX_THRESHOLD, freq);
+
+		/* re-evaluate to get actual register value */
+		val = mvpp2_usec_to_cycles(rxq->time_coal, freq);
+	}
 
-	val = (port->priv->tclk / USEC_PER_SEC) * rxq->time_coal;
 	mvpp2_write(port->priv, MVPP2_ISR_RX_THRESHOLD_REG(rxq->id), val);
 }
 
-- 
2.7.4
