From: Bernd Edlinger <bernd.edlinger@hotmail.de>
Subject: [PATCH] stmmac: Don't access tx_q->dirty_tx before netif_tx_lock
Date: Sat, 21 Oct 2017 06:51:30 +0000
Message-ID: <AM5PR0701MB2657DAF1EEA20231A0FFF50EE4400@AM5PR0701MB2657.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: de-DE
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the possible reason for different hard to reproduce
problems on my ARMv7-SMP test system.

The symptoms are in recent kernels imprecise external aborts,
and in older kernels various kinds of network stalls and
unexpected page allocation failures.

My testing indicates that the trouble started between v4.5 and v4.6
and prevails up to v4.14.

Using the dirty_tx before acquiring the spin lock is clearly
wrong and was first introduced with v4.6.

Fixes: e3ad57c96715 ("stmmac: review RX/TX ring management")

Signed-off-by: Bernd Edlinger <bernd.edlinger@hotmail.de>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1763e48..c8e280fa 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1800,12 +1800,13 @@ static void stmmac_tx_clean(struct stmmac_priv *priv, u32 queue)
 {
 	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
 	unsigned int bytes_compl = 0, pkts_compl = 0;
-	unsigned int entry = tx_q->dirty_tx;
+	unsigned int entry;
 
 	netif_tx_lock(priv->dev);
 
 	priv->xstats.tx_clean++;
 
+	entry = tx_q->dirty_tx;
 	while (entry != tx_q->cur_tx) {
 		struct sk_buff *skb = tx_q->tx_skbuff[entry];
 		struct dma_desc *p;
-- 
1.9.1
