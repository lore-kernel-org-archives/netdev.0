From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.6.1-bk1-netdev4 - latent bug
Date: Wed, 14 Jan 2004 23:33:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114233350.A4646@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

(disclaimer: I have not been especially brilliant these last days, so
handle with care)

  the following patch against -netdev4 should fix an error which appears in
every r8169 driver (-vanilla, -mm, -netdev, -my). The patch will not apply
against plain 2.6.x due to endianness conflict. I will regenerate a serie
for 2.6.1-bk1 in a few minutes.

It has not been tested so far but it could be a decent candidate for
lock-up under stress.

Please review rtl8169_tx_interrupt/rtl8169_start_xmit and/or test if you can.



- possible tx descriptor index overflow (assume tp->dirty_tx = NUM_TX_DESC/2,
  tp->cur_tx = NUM_TX_DESC - 1 for example);
- the status of an inadequate descriptor is checked.

When tx_dirty == 1, one should not necessarily notice a difference.


 drivers/net/r8169.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff -puN drivers/net/r8169.c~r8169-tx-index-overflow drivers/net/r8169.c
--- linux-2.6.1-bk1-netdev4/drivers/net/r8169.c~r8169-tx-index-overflow	2004-01-14 23:16:58.000000000 +0100
+++ linux-2.6.1-bk1-netdev4-fr/drivers/net/r8169.c	2004-01-14 23:16:58.000000000 +0100
@@ -1341,8 +1341,7 @@ static void
 rtl8169_tx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void *ioaddr)
 {
-	unsigned long dirty_tx, tx_left = 0;
-	int entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned long dirty_tx, tx_left;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -1352,8 +1351,9 @@ rtl8169_tx_interrupt(struct net_device *
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
-		if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
-			int cur = dirty_tx % NUM_TX_DESC;
+		int cur = dirty_tx % NUM_TX_DESC;
+
+		if (!(le32_to_cpu(tp->TxDescArray[cur].status) & OWNbit)) {
 			struct sk_buff *skb = tp->Tx_skbuff[cur];
 
 			/* FIXME: is it really accurate for TxErr ? */
@@ -1365,7 +1365,6 @@ rtl8169_tx_interrupt(struct net_device *
 			dev_kfree_skb_irq(skb);
 			dirty_tx++;
 			tx_left--;
-			entry++;
 		}
 	}
 

_
