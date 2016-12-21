From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 02/27] net: mvpp2: handle too large value handling in mvpp2_rx_pkts_coal_set()
Date: Wed, 21 Dec 2016 12:16:09 +0100
Message-ID: <1482318994-23488-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([62.4.15.54]:56076 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbcLULQk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:16:40 -0500
In-Reply-To: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
---
 drivers/net/ethernet/marvell/mvpp2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 930c816..4c9e3ea 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4381,11 +4381,11 @@ static void mvpp2_txp_max_tx_size_set(struct mvpp2_port *port)
 static void mvpp2_rx_pkts_coal_set(struct mvpp2_port *port,
 				   struct mvpp2_rx_queue *rxq, u32 pkts)
 {
-	u32 val;
+	if (pkts > MVPP2_OCCUPIED_THRESH_MASK)
+		pkts = MVPP2_OCCUPIED_THRESH_MASK;
 
-	val = (pkts & MVPP2_OCCUPIED_THRESH_MASK);
 	mvpp2_write(port->priv, MVPP2_RXQ_NUM_REG, rxq->id);
-	mvpp2_write(port->priv, MVPP2_RXQ_THRESH_REG, val);
+	mvpp2_write(port->priv, MVPP2_RXQ_THRESH_REG, pkts);
 
 	rxq->pkts_coal = pkts;
 }
-- 
2.7.4
