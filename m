From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] pxa168: close race between napi and irq activation
Date: Sun, 30 Nov 2014 11:49:36 +0100
Message-ID: <1417344576-4940-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: paul.gortmaker@windriver.com, w-lkml@lebenslange-mailadresse.de,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In pxa168_eth_open() the irqs are enabled before napi. This opens a tiny time
window in which the irq handler is processed, disables irqs but then is not able
to schedule the not yet activated napi, leaving irqs disabled forever (since
irqs are reenabled in napi poll function).
Fix this race by activating napi before irqs are activated.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
Please note that i could not test this since I dont have access to the
concerning hardware.

 drivers/net/ethernet/marvell/pxa168_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index c3b209c..a3e394c 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1153,8 +1153,8 @@ static int pxa168_eth_open(struct net_device *dev)
 	pep->rx_used_desc_q = 0;
 	pep->rx_curr_desc_q = 0;
 	netif_carrier_off(dev);
-	eth_port_start(dev);
 	napi_enable(&pep->napi);
+	eth_port_start(dev);
 	return 0;
 out_free_rx_skb:
 	rxq_deinit(dev);
-- 
1.9.1
