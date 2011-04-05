From: Enric Balletbo i Serra <eballetbo@iseebcn.com>
Subject: [PATCH/RFC] can: mcp251x: Allow pass IRQ flags through platform data.
Date: Tue,  5 Apr 2011 19:08:41 +0200
Message-ID: <1302023321-25182-1-git-send-email-eballetbo@iseebcn.com>
Cc: Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61218 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102Ab1DERJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 13:09:14 -0400
Received: by wya21 with SMTP id 21so523595wya.19
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 10:09:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an interrupt occurs, the INT pin is driven low by the
MCP251x controller (falling edge) but in some cases the INT
pin can be connected to the MPU through a transistor or level
translator which inverts this signal. In this case interrupt
should be configured in rising edge.

This patch adds support to pass the IRQ flags via
mcp251x_platform_data.

Signed-off-by: Enric Balletbo i Serra <eballetbo@iseebcn.com>
---
 drivers/net/can/mcp251x.c            |    3 ++-
 include/linux/can/platform/mcp251x.h |    2 ++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 7513c45..330140e 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -931,7 +931,8 @@ static int mcp251x_open(struct net_device *net)
 	priv->tx_len = 0;
 
 	ret = request_threaded_irq(spi->irq, NULL, mcp251x_can_ist,
-			  IRQF_TRIGGER_FALLING, DEVICE_NAME, priv);
+		  pdata->irq_flags ? pdata->irq_flags : IRQF_TRIGGER_FALLING,
+		  DEVICE_NAME, priv);
 	if (ret) {
 		dev_err(&spi->dev, "failed to acquire irq %d\n", spi->irq);
 		if (pdata->transceiver_enable)
diff --git a/include/linux/can/platform/mcp251x.h b/include/linux/can/platform/mcp251x.h
index 8e20540..089fe43 100644
--- a/include/linux/can/platform/mcp251x.h
+++ b/include/linux/can/platform/mcp251x.h
@@ -12,6 +12,7 @@
 /**
  * struct mcp251x_platform_data - MCP251X SPI CAN controller platform data
  * @oscillator_frequency:       - oscillator frequency in Hz
+ * @irq_flags:                  - IRQF configuration flags
  * @board_specific_setup:       - called before probing the chip (power,reset)
  * @transceiver_enable:         - called to power on/off the transceiver
  * @power_enable:               - called to power on/off the mcp *and* the
@@ -24,6 +25,7 @@
 
 struct mcp251x_platform_data {
 	unsigned long oscillator_frequency;
+	unsigned long irq_flags;
 	int (*board_specific_setup)(struct spi_device *spi);
 	int (*transceiver_enable)(int enable);
 	int (*power_enable) (int enable);
-- 
1.7.0.4

