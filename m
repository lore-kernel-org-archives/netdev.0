From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 10/11] net/can/mscan: add error path to mscan_open()
Date: Mon, 16 Nov 2009 23:57:53 +0100
Message-ID: <1258412274-14686-11-git-send-email-w.sang@pengutronix.de>
References: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1258412274-14686-1-git-send-email-w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/mscan/mscan.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 263d1a9..bb06dfb 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -542,10 +542,8 @@ static int mscan_open(struct net_device *dev)
 
 	ret = request_irq(dev->irq, mscan_isr, 0, dev->name, dev);
 	if (ret < 0) {
-		napi_disable(&priv->napi);
-		printk(KERN_ERR "%s - failed to attach interrupt\n",
-		       dev->name);
-		return ret;
+		dev_err(dev->dev.parent, "failed to attach interrupt\n");
+		goto exit_napi_disable;
 	}
 
 	priv->open_time = jiffies;
@@ -554,11 +552,19 @@ static int mscan_open(struct net_device *dev)
 
 	ret = mscan_start(dev);
 	if (ret)
-		return ret;
+		goto exit_free_irq;
 
 	netif_start_queue(dev);
 
 	return 0;
+
+exit_free_irq:
+	priv->open_time = 0;
+	free_irq(dev->irq, dev);
+exit_napi_disable:
+	napi_disable(&priv->napi);
+	close_candev(dev);
+	return ret;
 }
 
 static int mscan_close(struct net_device *dev)
-- 
1.6.3.3
