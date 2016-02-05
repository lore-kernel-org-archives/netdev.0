From: Alexandre Bounine <alexandre.bounine@idt.com>
Subject: [PATCH 01/30] rapidio/rionet: fix deadlock on SMP
Date: Fri,  5 Feb 2016 18:19:17 -0500
Message-ID: <1454714386-15259-2-git-send-email-alexandre.bounine@idt.com>
References: <1454714386-15259-1-git-send-email-alexandre.bounine@idt.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Andre van Herk <andre.van.herk@prodrive-technologies.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454714386-15259-1-git-send-email-alexandre.bounine@idt.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aurelien Jacquiot <a-jacquiot@ti.com>

Fix deadlocking during concurrent receive and transmit operations on SMP
platforms caused by the use of incorrect lock: on transmit 'tx_lock'
spinlock should be used instead of 'lock' which is used for receive
operation.

This fix is applicable to kernel versions starting from v2.15.

Signed-off-by: Aurelien Jacquiot <a-jacquiot@ti.com>
Signed-off-by: Alexandre Bounine <alexandre.bounine@idt.com>
Cc: Matt Porter <mporter@kernel.crashing.org>
Cc: Andre van Herk <andre.van.herk@prodrive-technologies.com>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/net/rionet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 01f08a7..e7034c5 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -280,7 +280,7 @@ static void rionet_outb_msg_event(struct rio_mport *mport, void *dev_id, int mbo
 	struct net_device *ndev = dev_id;
 	struct rionet_private *rnet = netdev_priv(ndev);
 
-	spin_lock(&rnet->lock);
+	spin_lock(&rnet->tx_lock);
 
 	if (netif_msg_intr(rnet))
 		printk(KERN_INFO
@@ -299,7 +299,7 @@ static void rionet_outb_msg_event(struct rio_mport *mport, void *dev_id, int mbo
 	if (rnet->tx_cnt < RIONET_TX_RING_SIZE)
 		netif_wake_queue(ndev);
 
-	spin_unlock(&rnet->lock);
+	spin_unlock(&rnet->tx_lock);
 }
 
 static int rionet_open(struct net_device *ndev)
-- 
1.7.8.4
