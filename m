From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 2/2] drivers/net: Fix synchronize_irq() bugs, redundancies
Date: Mon, 21 Apr 2008 19:35:37 -0400
Message-ID: <20080421233537.GA5223@havoc.gtf.org>
References: <20080421233419.GA4923@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759586AbYDUXfy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080421233419.GA4923@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

free_irq() calls synchronize_irq() for you, so there is no need for
drivers to manually do the same thing (again).  Thus, calls where
sync-irq immediately precedes free-irq can be simplified.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 drivers/net/8139cp.c       |    1 -
 drivers/net/8139too.c      |    1 -
 drivers/net/dl2k.c         |    2 +-
 drivers/net/pci-skeleton.c |    1 -
 drivers/net/tsi108_eth.c   |    1 -
 drivers/net/typhoon.c      |    3 ---
 6 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a453eda..b92cc15 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1214,7 +1214,6 @@ static int cp_close (struct net_device *dev)
 
 	spin_unlock_irqrestore(&cp->lock, flags);
 
-	synchronize_irq(dev->irq);
 	free_irq(dev->irq, dev);
 
 	cp_free_rings(cp);
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 53bd903..fbdf831 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2232,7 +2232,6 @@ static int rtl8139_close (struct net_device *dev)
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 
-	synchronize_irq (dev->irq);	/* racy, but that's ok here */
 	free_irq (dev->irq, dev);
 
 	rtl8139_tx_clear (tp);
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index e233d04..05f606d 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1753,7 +1753,7 @@ rio_close (struct net_device *dev)
 
 	/* Stop Tx and Rx logics */
 	writel (TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl);
-	synchronize_irq (dev->irq);
+
 	free_irq (dev->irq, dev);
 	del_timer_sync (&np->timer);
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index fffc49b..53451c3 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1739,7 +1739,6 @@ static int netdrv_close (struct net_device *dev)
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 
-	synchronize_irq (dev->irq);
 	free_irq (dev->irq, dev);
 
 	netdrv_tx_clear (dev);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 6f33f84..e75dd88 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1434,7 +1434,6 @@ static int tsi108_close(struct net_device *dev)
 		dev_kfree_skb(skb);
 	}
 
-	synchronize_irq(data->irq_num);
 	free_irq(data->irq_num, dev);
 
 	/* Discard the RX ring. */
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 333961b..7d2a4c6 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -334,8 +334,6 @@ enum state_values {
 #define TYPHOON_RESET_TIMEOUT_NOSLEEP	((6 * 1000000) / TYPHOON_UDELAY)
 #define TYPHOON_WAIT_TIMEOUT		((1000000 / 2) / TYPHOON_UDELAY)
 
-#define typhoon_synchronize_irq(x) synchronize_irq(x)
-
 #if defined(NETIF_F_TSO)
 #define skb_tso_size(x)		(skb_shinfo(x)->gso_size)
 #define TSO_NUM_DESCRIPTORS	2
@@ -2143,7 +2141,6 @@ typhoon_close(struct net_device *dev)
 		printk(KERN_ERR "%s: unable to stop runtime\n", dev->name);
 
 	/* Make sure there is no irq handler running on a different CPU. */
-	typhoon_synchronize_irq(dev->irq);
 	free_irq(dev->irq, dev);
 
 	typhoon_free_rx_rings(tp);
