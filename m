From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/9] drivers/net: remove unnecessary flush_scheduled_work() calls
Date: Sun, 12 Dec 2010 16:52:57 +0100
Message-ID: <1292169185-10579-2-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Wolfgang Grandegger <wg@grandegger.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

janz-ican3, sh_eth, skge and vxge don't use workqueue at all and there
is no reason to flush the system_wq.  Drop flush_scheduled_work()
calls and references to workqueue.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
Cc: Sivakumar Subramani <sivakumar.subramani@exar.com>
Cc: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Cc: Jon Mason <jon.mason@exar.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/can/janz-ican3.c |    9 ---------
 drivers/net/sh_eth.c         |    1 -
 drivers/net/sh_eth.h         |    1 -
 drivers/net/skge.c           |    2 --
 drivers/net/vxge/vxge-main.c |    2 --
 5 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 6e533dc..b9a6d7a 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1114,11 +1114,6 @@ static bool ican3_txok(struct ican3_dev *mod)
 /*
  * Recieve one CAN frame from the hardware
  *
- * This works like the core of a NAPI function, but is intended to be called
- * from workqueue context instead. This driver already needs a workqueue to
- * process control messages, so we use the workqueue instead of using NAPI.
- * This was done to simplify locking.
- *
  * CONTEXT: must be called from user context
  */
 static int ican3_recv_skb(struct ican3_dev *mod)
@@ -1251,7 +1246,6 @@ static irqreturn_t ican3_irq(int irq, void *dev_id)
  * Reset an ICAN module to its power-on state
  *
  * CONTEXT: no network device registered
- * LOCKING: work function disabled
  */
 static int ican3_reset_module(struct ican3_dev *mod)
 {
@@ -1262,9 +1256,6 @@ static int ican3_reset_module(struct ican3_dev *mod)
 	/* disable interrupts so no more work is scheduled */
 	iowrite8(1 << mod->num, &mod->ctrl->int_disable);
 
-	/* flush any pending work */
-	flush_scheduled_work();
-
 	/* the first unallocated page in the DPM is #9 */
 	mod->free_page = DPM_FREE_START;
 
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index b12660d..819c175 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1552,7 +1552,6 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 
 	sh_mdio_release(ndev);
 	unregister_netdev(ndev);
-	flush_scheduled_work();
 	pm_runtime_disable(&pdev->dev);
 	free_netdev(ndev);
 	platform_set_drvdata(pdev, NULL);
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index 8b47763..efa6422 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -26,7 +26,6 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
-#include <linux/workqueue.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 220e039..8c1404b 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -4012,8 +4012,6 @@ static void __devexit skge_remove(struct pci_dev *pdev)
 	if (!hw)
 		return;
 
-	flush_scheduled_work();
-
 	dev1 = hw->dev[1];
 	if (dev1)
 		unregister_netdev(dev1);
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index b771e4b..537ad87 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3439,8 +3439,6 @@ static void vxge_device_unregister(struct __vxge_hw_device *hldev)
 
 	strncpy(buf, dev->name, IFNAMSIZ);
 
-	flush_scheduled_work();
-
 	/* in 2.6 will call stop() if device is up */
 	unregister_netdev(dev);
 
-- 
1.7.1
