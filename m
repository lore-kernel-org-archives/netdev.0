From: Jan Altenberg <jan@linutronix.de>
Subject: [PATCH] can: c_can: Do basic c_can configuration _before_ enabling
 the interrupts
Date: Mon, 21 Mar 2011 14:47:38 +0100
Message-ID: <1300715258.2010.30.camel@moestavern>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, b.spranger@linutronix.de, jan@linutronix.de,
	netdev@vger.kernel.org
To: bhupesh.sharma@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:41796 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab1CUNrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 09:47:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I ran into some trouble while testing the SocketCAN driver for the BOSCH
C_CAN controller. The interface is not correctly initialized, if I put
some CAN traffic on the line, _while_ the interface is being started
(which means: the interface doesn't come up correcty, if there's some RX
traffic while doing 'ifconfig can0 up').

The current implementation enables the controller interrupts _before_
doing the basic c_can configuration. I think, this should be done the
other way round.

The patch below fixes things for me.

Signed-off-by: Jan Altenberg <jan@linutronix.de>
---
diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 1405078..110eda0 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -633,9 +633,6 @@ static void c_can_start(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 
-	/* enable status change, error and module interrupts */
-	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
-
 	/* basic c_can configuration */
 	c_can_chip_config(dev);
 
@@ -643,6 +640,9 @@ static void c_can_start(struct net_device *dev)
 
 	/* reset tx helper pointers */
 	priv->tx_next = priv->tx_echo = 0;
+
+	/* enable status change, error and module interrupts */
+	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
 }
 
 static void c_can_stop(struct net_device *dev)



