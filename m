From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: fix napi_{en|dis}able() calls racing against interrupts
Date: Wed, 4 Sep 2013 02:41:27 +0400
Message-ID: <201309040241.27834.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While implementing NAPI for the driver, I overlooked the race conditions where
interrupt  handler might have called napi_schedule_prep() before napi_enable()
was called or after napi_disable() was called. If RX interrupt happens, this
would cause the endless interrupts and messages like:

sh-eth eth0: ignoring interrupt, status 0x00040000, mask 0x01ff009f.

The interrupt wouldn't even be masked by the kernel eventually since the handler
would return IRQ_HANDLED all the time.

As a fix, move napi_enable() call before request_irq() call and napi_disable()
call after free_irq() call.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave's 'net.git' repo.  It should be applied to 3.11.y too.

 drivers/net/ethernet/renesas/sh_eth.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1857,11 +1857,13 @@ static int sh_eth_open(struct net_device
 
 	pm_runtime_get_sync(&mdp->pdev->dev);
 
+	napi_enable(&mdp->napi);
+
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
 			  mdp->cd->irq_flags, ndev->name, ndev);
 	if (ret) {
 		dev_err(&ndev->dev, "Can not assign IRQ number\n");
-		return ret;
+		goto out_napi_off;
 	}
 
 	/* Descriptor set */
@@ -1879,12 +1881,12 @@ static int sh_eth_open(struct net_device
 	if (ret)
 		goto out_free_irq;
 
-	napi_enable(&mdp->napi);
-
 	return ret;
 
 out_free_irq:
 	free_irq(ndev->irq, ndev);
+out_napi_off:
+	napi_disable(&mdp->napi);
 	pm_runtime_put_sync(&mdp->pdev->dev);
 	return ret;
 }
@@ -1976,8 +1978,6 @@ static int sh_eth_close(struct net_devic
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
-	napi_disable(&mdp->napi);
-
 	netif_stop_queue(ndev);
 
 	/* Disable interrupts by clearing the interrupt mask. */
@@ -1995,6 +1995,8 @@ static int sh_eth_close(struct net_devic
 
 	free_irq(ndev->irq, ndev);
 
+	napi_disable(&mdp->napi);
+
 	/* Free all the skbuffs in the Rx queue. */
 	sh_eth_ring_free(ndev);
 
