From: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: [PATCH net-next-2.6] can: fix setting mcp251x bit timing on open
Date: Tue, 17 Nov 2009 17:20:44 +0100
Message-ID: <1258474844-10239-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org,
	pthomas8589-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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


Signed-off-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
---
 drivers/net/can/mcp251x.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 8f48f4b..78b1b69 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -594,13 +594,7 @@ static int mcp251x_do_set_bittiming(struct net_device *net)
 static int mcp251x_setup(struct net_device *net, struct mcp251x_priv *priv,
 			 struct spi_device *spi)
 {
-	int ret;
-
-	ret = open_candev(net);
-	if (ret) {
-		dev_err(&spi->dev, "unable to set initial baudrate!\n");
-		return ret;
-	}
+	mcp251x_do_set_bittiming(net);
 
 	/* Enable RX0->RX1 buffer roll over and disable filters */
 	mcp251x_write_bits(spi, RXBCTRL(0),
@@ -671,6 +665,12 @@ static int mcp251x_open(struct net_device *net)
 	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 	int ret;
 
+	ret = open_candev(net);
+	if (ret) {
+		dev_err(&spi->dev, "unable to set initial baudrate!\n");
+		return ret;
+	}
+
 	if (pdata->transceiver_enable)
 		pdata->transceiver_enable(1);
 
@@ -684,6 +684,7 @@ static int mcp251x_open(struct net_device *net)
 		dev_err(&spi->dev, "failed to acquire irq %d\n", spi->irq);
 		if (pdata->transceiver_enable)
 			pdata->transceiver_enable(0);
+		close_candev(net);
 		return ret;
 	}
 
@@ -692,8 +693,10 @@ static int mcp251x_open(struct net_device *net)
 	ret = mcp251x_setup(net, priv, spi);
 	if (ret) {
 		free_irq(spi->irq, net);
+		mcp251x_hw_sleep(spi);
 		if (pdata->transceiver_enable)
 			pdata->transceiver_enable(0);
+		close_candev(net);
 		return ret;
 	}
 	mcp251x_set_normal_mode(spi);
@@ -956,7 +959,6 @@ static int __devinit mcp251x_can_probe(struct spi_device *spi)
 	priv->can.bittiming_const = &mcp251x_bittiming_const;
 	priv->can.do_set_mode = mcp251x_do_set_mode;
 	priv->can.clock.freq = pdata->oscillator_frequency / 2;
-	priv->can.do_set_bittiming = mcp251x_do_set_bittiming;
 	priv->net = net;
 	dev_set_drvdata(&spi->dev, priv);
 
-- 
1.5.6.5
