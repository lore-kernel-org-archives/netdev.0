From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] tg3: Tx availability fix
Date: Thu, 05 Jul 2007 17:23:17 -0700
Message-ID: <1183681399.24582.68.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Robert Olsson" <Robert.Olsson@data.slu.se>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Gagan Arneja" <gaagaan@gmail.com>, netdev@vger.kernel.org,
	"Rick Jones" <rick.jones2@hp.com>,
	"Sridhar Samudrala" <sri@us.ibm.com>,
	"David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "jamal" <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2236 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759020AbXGFAX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 20:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes how and to what value the xmit_win variable is
assigned.

The patch starts by correcting the initialization of xmit_win to be 1/4
the value of tx_pending rather than the tx ring size.  The tx_pending
value is initialized to be the tx ring size, but it may be changed
through ethtool.

The patch then reverts the code back to the old logic when deciding
whether or not to wake up the transmit queue.  The new tx batching
implementation had changed this code so that the tg3_tx_avail() function
was only called once and the value returned stored in a local variable.
While the new code looks slightly cleaner, there is the possibility that
more descriptors will become available in-between the time of the call
and the time the value gets used.  Reverting back to the old logic will
ensure that the driver always acts on current information.

The last change makes sure that new xmit_win values, as assigned by the
transmit queue wake code, will not be drastically larger than the value
set during initialization.

As a bonus, this patch removes the unused struct tg3_tx_cbdata members.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index cef9cbe..afa617a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -581,7 +581,7 @@ static inline void tg3_netif_stop(struct tg3 *tp)
 static inline void tg3_netif_start(struct tg3 *tp)
 {
 	netif_wake_queue(tp->dev);
-	tp->dev->xmit_win = TG3_TX_RING_SIZE >> 2;
+	tp->dev->xmit_win = tp->tx_pending >> 2;
 	/* NOTE: unconditional netif_wake_queue is only appropriate
 	 * so long as all callers are assured to have free tx slots
 	 * (such as after tg3_init_hw)
@@ -3120,15 +3120,14 @@ static void tg3_tx(struct tg3 *tp)
 	 */
 	smp_mb();
 
-	dcount = tg3_tx_avail(tp);
 	if (unlikely(netif_queue_stopped(tp->dev) &&
-		     (dcount > TG3_TX_WAKEUP_THRESH(tp)))) {
+		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
 		netif_tx_lock(tp->dev);
 		tp->dev->xmit_win = 1;
 		if (netif_queue_stopped(tp->dev) &&
-		    (dcount > TG3_TX_WAKEUP_THRESH(tp))) {
+		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))) {
 			netif_wake_queue(tp->dev);
-			tp->dev->xmit_win = dcount;
+			tp->dev->xmit_win = tg3_tx_avail(tp) >> 2;
 		}
 		netif_tx_unlock(tp->dev);
 	}
@@ -3885,9 +3884,6 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
 
 struct tg3_tx_cbdata {
 	u32 base_flags;
-	int count;
-	unsigned int max_per_txd;
-	unsigned int nr_frags;
 	unsigned int mss;
 };
 #define TG3_SKB_CB(__skb)       ((struct tg3_tx_cbdata *)&((__skb)->cb[0]))
@@ -3974,16 +3970,16 @@ static int tg3_prep_frame(struct sk_buff *skb, struct net_device *dev)
 void tg3_kick_DMA(struct tg3 *tp)
 {
 	u32 entry = tp->tx_prod;
-	u32 count = tg3_tx_avail(tp);
+
 	/* Packets are ready, update Tx producer idx local and on card. */
 	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
 
-	if (unlikely(count <= (MAX_SKB_FRAGS + 1))) {
+	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
 		netif_stop_queue(tp->dev);
 		tp->dev->xmit_win = 1;
-		if (count > TG3_TX_WAKEUP_THRESH(tp)) {
+		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)) {
 			netif_wake_queue(tp->dev);
-			tp->dev->xmit_win = count;
+			tp->dev->xmit_win = tg3_tx_avail(tp) >> 2;
 		}
 	}
 
@@ -11965,7 +11961,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
 	dev->features |= NETIF_F_BTX;
-	dev->xmit_win = TG3_TX_RING_SIZE >> 2;
+	dev->xmit_win = tp->tx_pending >> 2;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = tg3_poll_controller;


