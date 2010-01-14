From: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: [PATCH net-next-2.6 v2] can: Proper ctrlmode handling for CAN devices
Date: Thu, 14 Jan 2010 18:08:34 +0100
Message-ID: <1263488914-21655-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

This patch adds error checking of ctrlmode values for CAN devices. As
an example all availabe bits are implemented in the mcp251x driver.

Signed-off-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
---
 drivers/net/can/at91_can.c        |    1 +
 drivers/net/can/bfin_can.c        |    1 +
 drivers/net/can/dev.c             |    2 ++
 drivers/net/can/mcp251x.c         |   11 ++++++++++-
 drivers/net/can/mscan/mscan.c     |    1 +
 drivers/net/can/sja1000/sja1000.c |    1 +
 drivers/net/can/ti_hecc.c         |    1 +
 drivers/net/can/usb/ems_usb.c     |    1 +
 include/linux/can/dev.h           |    1 +
 9 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index f728749..a2f29a3 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1073,6 +1073,7 @@ static int __init at91_can_probe(struct platform_device *pdev)
 	priv->can.bittiming_const = &at91_bittiming_const;
 	priv->can.do_set_bittiming = at91_set_bittiming;
 	priv->can.do_set_mode = at91_set_mode;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 	priv->reg_base = addr;
 	priv->dev = dev;
 	priv->clk = clk;
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 7e1926e..bf7f9ba 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -603,6 +603,7 @@ struct net_device *alloc_bfin_candev(void)
 	priv->can.bittiming_const = &bfin_can_bittiming_const;
 	priv->can.do_set_bittiming = bfin_can_set_bittiming;
 	priv->can.do_set_mode = bfin_can_set_mode;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 
 	return dev;
 }
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index c1bb29f..f08f120 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -592,6 +592,8 @@ static int can_changelink(struct net_device *dev,
 		if (dev->flags & IFF_UP)
 			return -EBUSY;
 		cm = nla_data(data[IFLA_CAN_CTRLMODE]);
+		if (cm->flags & ~priv->ctrlmode_supported)
+			return -EOPNOTSUPP;
 		priv->ctrlmode &= ~cm->mask;
 		priv->ctrlmode |= cm->flags;
 	}
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index afa2fa4..bbe186b 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -539,9 +539,14 @@ static void mcp251x_set_normal_mode(struct spi_device *spi)
 	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
 		/* Put device into loopback mode */
 		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_LOOPBACK);
+	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
+		/* Put device into listen-only mode */
+		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_LISTEN_ONLY);
 	} else {
 		/* Put device into normal mode */
-		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_NORMAL);
+		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_NORMAL |
+				  (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT ?
+				   CANCTRL_OSM : 0));
 
 		/* Wait for the device to enter normal mode */
 		timeout = jiffies + HZ;
@@ -948,6 +953,10 @@ static int __devinit mcp251x_can_probe(struct spi_device *spi)
 	priv->can.bittiming_const = &mcp251x_bittiming_const;
 	priv->can.do_set_mode = mcp251x_do_set_mode;
 	priv->can.clock.freq = pdata->oscillator_frequency / 2;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
+		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
+	if (pdata->model == CAN_MCP251X_MCP2515)
+		priv->can.ctrlmode_supported |= CAN_CTRLMODE_ONE_SHOT;
 	priv->net = net;
 	dev_set_drvdata(&spi->dev, priv);
 
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 40827c1..6b7dd57 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -686,6 +686,7 @@ struct net_device *alloc_mscandev(void)
 	priv->can.bittiming_const = &mscan_bittiming_const;
 	priv->can.do_set_bittiming = mscan_do_set_bittiming;
 	priv->can.do_set_mode = mscan_do_set_mode;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 
 	for (i = 0; i < TX_QUEUE_SIZE; i++) {
 		priv->tx_queue[i].id = i;
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 345304d..ace103a 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -567,6 +567,7 @@ struct net_device *alloc_sja1000dev(int sizeof_priv)
 	priv->can.bittiming_const = &sja1000_bittiming_const;
 	priv->can.do_set_bittiming = sja1000_set_bittiming;
 	priv->can.do_set_mode = sja1000_set_mode;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 
 	if (sizeof_priv)
 		priv->priv = (void *)priv + sizeof(struct sja1000_priv);
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 7d370e3..8332e24 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -909,6 +909,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
 	priv->can.bittiming_const = &ti_hecc_bittiming_const;
 	priv->can.do_set_mode = ti_hecc_do_set_mode;
 	priv->can.do_get_state = ti_hecc_get_state;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 
 	ndev->irq = irq->start;
 	ndev->flags |= IFF_ECHO;
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index ddb17e2..bfab283 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -1022,6 +1022,7 @@ static int ems_usb_probe(struct usb_interface *intf,
 	dev->can.bittiming_const = &ems_usb_bittiming_const;
 	dev->can.do_set_bittiming = ems_usb_set_bittiming;
 	dev->can.do_set_mode = ems_usb_set_mode;
+	dev->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
 
 	netdev->flags |= IFF_ECHO; /* we support local echo */
 
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 7e7c98a..c8c660a 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -38,6 +38,7 @@ struct can_priv {
 
 	enum can_state state;
 	u32 ctrlmode;
+	u32 ctrlmode_supported;
 
 	int restart_ms;
 	struct timer_list restart_timer;
-- 
1.5.6.5
