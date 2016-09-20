From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next 5/7] net/faraday: Clear stale interrupts
Date: Tue, 20 Sep 2016 16:00:05 +0930
Message-ID: <20160920063007.24291-6-joel@jms.id.au>
References: <20160920063007.24291-1-joel@jms.id.au>
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, andrew@lunn.ch,
        andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920063007.24291-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gavin Shan <gwshan@linux.vnet.ibm.com>

There is stale interrupt (PHYSTS_CHG in ISR, bit#6 in 0x0) from
the bootloader (uboot) when enabling the MAC. The stale interrupts
aren't part of kernel and should be cleared.

This clears the stale interrupts in ISR (0x0) when enabling the MAC.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index f2ea6c2f1fbd..7ba0f2d58a8b 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1113,6 +1113,7 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 static int ftgmac100_open(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
+	unsigned int status;
 	int err;
 
 	err = ftgmac100_alloc_buffers(priv);
@@ -1138,6 +1139,11 @@ static int ftgmac100_open(struct net_device *netdev)
 
 	ftgmac100_init_hw(priv);
 	ftgmac100_start_hw(priv, priv->use_ncsi ? 100 : 10);
+
+	/* Clear stale interrupts */
+	status = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
+	iowrite32(status, priv->base + FTGMAC100_OFFSET_ISR);
+
 	if (netdev->phydev)
 		phy_start(netdev->phydev);
 	else if (priv->use_ncsi)
-- 
2.9.3
