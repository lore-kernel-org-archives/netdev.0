From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv4 net-next 03/13] net: mvpp2: handle too large value handling in mvpp2_rx_pkts_coal_set()
Date: Tue, 21 Feb 2017 11:28:03 +0100
Message-ID: <1487672893-5746-4-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([62.4.15.54]:49541 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751837AbdBUK2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 05:28:43 -0500
In-Reply-To: <1487672893-5746-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, mvpp2_rx_pkts_coal_set() does the following to avoid setting
a too large value for the RX coalescing by packet number:

  val = (pkts & MVPP2_OCCUPIED_THRESH_MASK);

This means that if you set a value that is slightly higher the the
maximum number of packets, you in fact get a very low value. It makes a
lot more sense to simply check if the value is too high, and if it's too
high, limit it to the maximum possible value.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Acked-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvpp2.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 92ab9a0..559d7d0 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4381,11 +4381,12 @@ static void mvpp2_txp_max_tx_size_set(struct mvpp2_port *port)
 static void mvpp2_rx_pkts_coal_set(struct mvpp2_port *port,
 				   struct mvpp2_rx_queue *rxq)
 {
-	u32 val;
+	if (rxq->pkts_coal > MVPP2_OCCUPIED_THRESH_MASK)
+		rxq->pkts_coal = MVPP2_OCCUPIED_THRESH_MASK;
 
-	val = (rxq->pkts_coal & MVPP2_OCCUPIED_THRESH_MASK);
 	mvpp2_write(port->priv, MVPP2_RXQ_NUM_REG, rxq->id);
-	mvpp2_write(port->priv, MVPP2_RXQ_THRESH_REG, val);
+	mvpp2_write(port->priv, MVPP2_RXQ_THRESH_REG,
+		    rxq->pkts_coal);
 }
 
 /* Set the time delay in usec before Rx interrupt */
-- 
2.7.4
