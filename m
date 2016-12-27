From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 02/11] net: mvpp2: handle too large value in mvpp2_rx_time_coal_set()
Date: Tue, 27 Dec 2016 17:54:11 +0100
Message-ID: <1482857660-16092-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36652 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932987AbcL0Qyc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:32 -0500
In-Reply-To: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring the MVPP2_ISR_RX_THRESHOLD_REG with the RX coalescing
time threshold, we do not check for the maximum allowed value supported
by the driver, which means we might overflow and use a bogus value. This
commit adds a check for this situation, and if a value higher than what
is supported by the hardware is provided, then we use the maximum value
supported by the hardware.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 02d91e4..a1ba89f 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -154,6 +154,7 @@
 
 /* Interrupt Cause and Mask registers */
 #define MVPP2_ISR_RX_THRESHOLD_REG(rxq)		(0x5200 + 4 * (rxq))
+#define     MVPP2_MAX_ISR_RX_THRESHOLD		0xfffff0
 #define MVPP2_ISR_RXQ_GROUP_REG(rxq)		(0x5400 + 4 * (rxq))
 #define MVPP2_ISR_ENABLE_REG(port)		(0x5420 + 4 * (port))
 #define     MVPP2_ISR_ENABLE_INTERRUPT(mask)	((mask) & 0xffff)
@@ -4397,6 +4398,12 @@ static void mvpp2_rx_time_coal_set(struct mvpp2_port *port,
 	u32 val;
 
 	val = (port->priv->tclk / USEC_PER_SEC) * usec;
+
+	if (val > MVPP2_MAX_ISR_RX_THRESHOLD) {
+		val = MVPP2_MAX_ISR_RX_THRESHOLD;
+		usec = (val * USEC_PER_SEC) / port->priv->tclk;
+	}
+
 	mvpp2_write(port->priv, MVPP2_ISR_RX_THRESHOLD_REG(rxq->id), val);
 
 	rxq->time_coal = usec;
-- 
2.7.4
