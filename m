From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 2.6.3 - drivers/net/sis190.c - Tx desc overflow
Date: Thu, 19 Feb 2004 01:05:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219010521.A23025@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Tx descriptor overflow - take II.

Assume tp->dirty_tx = NUM_TX_DESC/2, tp->cur_tx = NUM_TX_DESC - 1,
watch "entry" go beyond NUM_TX_DESC. Actually this is where the same
bug in r8169 driver comes from.


 drivers/net/sis190.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/net/sis190.c~sis190-tx-desc-overflow drivers/net/sis190.c
--- linux-2.6.3/drivers/net/sis190.c~sis190-tx-desc-overflow	2004-02-19 00:49:25.000000000 +0100
+++ linux-2.6.3-fr/drivers/net/sis190.c	2004-02-19 00:52:32.000000000 +0100
@@ -955,8 +955,7 @@ static void
 SiS190_tx_interrupt(struct net_device *dev, struct sis190_private *tp,
 		    void *ioaddr)
 {
-	unsigned long dirty_tx, tx_left = 0;
-	int entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned long dirty_tx, tx_left;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -966,6 +965,8 @@ SiS190_tx_interrupt(struct net_device *d
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
+		int entry = dirty_tx % NUM_TX_DESC;
+
 		if ((le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit) == 0) {
 			struct sk_buff *skb;
 
@@ -981,7 +982,6 @@ SiS190_tx_interrupt(struct net_device *d
 			tp->stats.tx_packets++;
 			dirty_tx++;
 			tx_left--;
-			entry++;
 		}
 	}
 

_
