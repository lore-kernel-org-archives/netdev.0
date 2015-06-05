From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH] net: moxa: fix TX overrun memory leak
Date: Fri,  5 Jun 2015 15:46:18 +0200
Message-ID: <1433511978-17666-1-git-send-email-jonas.jensen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

moxart_mac_start_xmit() doesn't care where tx_tail is, tx_head can
catch and pass tx_tail, which is bad because moxart_tx_finished()
isn't guaranteed to catch up on freeing resources from tx_tail.

Add a check in moxart_mac_start_xmit(), exit to make sure tx_head
never passes tx_tail.

Move tx_head and place tx_tail within spinlock, avoiding read-write
race that could happen when interrupts hit at the wrong moment.

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=99451

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20150604

 drivers/net/ethernet/moxa/moxart_ether.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index becbb5f..e0af86c 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -25,6 +25,7 @@
 #include <linux/of_irq.h>
 #include <linux/crc32.h>
 #include <linux/crc32c.h>
+#include <linux/circ_buf.h>
 
 #include "moxart_ether.h"
 
@@ -312,13 +313,22 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
 	void __iomem *desc;
 	unsigned int len;
-	unsigned int tx_head = priv->tx_head;
+	unsigned int tx_head, tx_tail;
 	u32 txdes1;
 	int ret = NETDEV_TX_BUSY;
 
+	spin_lock_irq(&priv->txlock);
+
+	tx_head = priv->tx_head;
+	tx_tail = priv->tx_tail;
+
 	desc = priv->tx_desc_base + (TX_REG_DESC_SIZE * tx_head);
 
-	spin_lock_irq(&priv->txlock);
+	if (CIRC_SPACE(tx_head, tx_tail, TX_DESC_NUM) == 0) {
+		priv->stats.tx_dropped++;
+		goto out_unlock;
+	}
+
 	if (readl(desc + TX_REG_OFFSET_DESC0) & TX_DESC0_DMA_OWN) {
 		net_dbg_ratelimited("no TX space for packet\n");
 		priv->stats.tx_dropped++;
-- 
1.8.2.1
