From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next v2 4/6] net/faraday: Clear stale interrupts
Date: Thu, 22 Sep 2016 08:35:01 +0930
Message-ID: <20160921230503.23309-5-joel@jms.id.au>
References: <20160921230503.23309-1-joel@jms.id.au>
Cc: clg@kaod.org, Gavin Shan <gwshan@linux.vnet.ibm.com>,
        andrew@lunn.ch, andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921230503.23309-1-joel@jms.id.au>
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
index 47f512224b57..189373743ddf 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1112,6 +1112,7 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 static int ftgmac100_open(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
+	unsigned int status;
 	int err;
 
 	err = ftgmac100_alloc_buffers(priv);
@@ -1137,6 +1138,11 @@ static int ftgmac100_open(struct net_device *netdev)
 
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
