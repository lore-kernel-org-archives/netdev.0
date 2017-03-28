From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v3] net: moxa: fix TX overrun memory leak
Date: Tue, 28 Mar 2017 12:12:38 +0200
Message-ID: <1490695958-23222-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

moxart_mac_start_xmit() doesn't care where tx_tail is, tx_head can
catch and pass tx_tail, which is bad because moxart_tx_finished()
isn't guaranteed to catch up on freeing resources from tx_tail.

Add a check in moxart_mac_start_xmit() stopping the queue at the
end of the circular buffer. Also add a check in moxart_tx_finished()
waking the queue if the buffer has TX_WAKE_THRESHOLD or more
free descriptors.

While we're at it, move spin_lock_irq() to happen before our
descriptor pointer is assigned in moxart_mac_start_xmit().

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=99451

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    ChangeLog v2->v3:
    - add wakeup threshold
    ChangeLog v1->v2:
    - stop queue instead of dropping frames
    
    Applies to next-20170310

 drivers/net/ethernet/moxa/moxart_ether.c | 20 ++++++++++++++++++--
 drivers/net/ethernet/moxa/moxart_ether.h |  1 +
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 06c9f41..6ad44be 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -25,6 +25,7 @@
 #include <linux/of_irq.h>
 #include <linux/crc32.h>
 #include <linux/crc32c.h>
+#include <linux/circ_buf.h>
 
 #include "moxart_ether.h"
 
@@ -278,6 +279,13 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 	return rx;
 }
 
+static int moxart_tx_queue_space(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	return CIRC_SPACE(priv->tx_head, priv->tx_tail, TX_DESC_NUM);
+}
+
 static void moxart_tx_finished(struct net_device *ndev)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
@@ -297,6 +305,9 @@ static void moxart_tx_finished(struct net_device *ndev)
 		tx_tail = TX_NEXT(tx_tail);
 	}
 	priv->tx_tail = tx_tail;
+	if (netif_queue_stopped(ndev) &&
+	    moxart_tx_queue_space(ndev) >= TX_WAKE_THRESHOLD)
+		netif_wake_queue(ndev);
 }
 
 static irqreturn_t moxart_mac_interrupt(int irq, void *dev_id)
@@ -324,13 +335,18 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
 	void *desc;
 	unsigned int len;
-	unsigned int tx_head = priv->tx_head;
+	unsigned int tx_head;
 	u32 txdes1;
 	int ret = NETDEV_TX_BUSY;
 
+	spin_lock_irq(&priv->txlock);
+
+	tx_head = priv->tx_head;
 	desc = priv->tx_desc_base + (TX_REG_DESC_SIZE * tx_head);
 
-	spin_lock_irq(&priv->txlock);
+	if (moxart_tx_queue_space(ndev) == 1)
+		netif_stop_queue(ndev);
+
 	if (moxart_desc_read(desc + TX_REG_OFFSET_DESC0) & TX_DESC0_DMA_OWN) {
 		net_dbg_ratelimited("no TX space for packet\n");
 		priv->stats.tx_dropped++;
diff --git a/drivers/net/ethernet/moxa/moxart_ether.h b/drivers/net/ethernet/moxa/moxart_ether.h
index 93a9563..afc32ec 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.h
+++ b/drivers/net/ethernet/moxa/moxart_ether.h
@@ -59,6 +59,7 @@
 #define TX_NEXT(N)		(((N) + 1) & (TX_DESC_NUM_MASK))
 #define TX_BUF_SIZE		1600
 #define TX_BUF_SIZE_MAX		(TX_DESC1_BUF_SIZE_MASK+1)
+#define TX_WAKE_THRESHOLD	16
 
 #define RX_DESC_NUM		64
 #define RX_DESC_NUM_MASK	(RX_DESC_NUM-1)
-- 
1.8.2.1
