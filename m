From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 04/16] c_can: fix receive buffer configuration
Date: Mon,  9 Sep 2013 09:25:01 +0200
Message-ID: <1378711513-2548-5-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37926 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab3IIHZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:33 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The former implementation lacks some initialization of receive buffer.
First the maximal buffer length was 0. The Buffer direction was not set
and the mask register a reserverd flag was cleared.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index bdb7bcd..886163f 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -116,6 +116,11 @@
 				IF_COMM_CONTROL | IF_COMM_TXRQST | \
 				IF_COMM_DATAA | IF_COMM_DATAB)
 
+/* IFx mask */
+#define IF_MASK_MXTD		BIT(31)
+#define IF_MASK_MDIR		BIT(30)
+#define IF_MASK_RES		BIT(29)
+
 /* IFx arbitration */
 #define IF_ARB_MSGVAL		BIT(31)
 #define IF_ARB_MSGXTD		BIT(30)
@@ -653,11 +658,15 @@ static void c_can_configure_msg_objects(struct net_device *dev)
 
 	/* setup receive message objects */
 	for (i = C_CAN_MSG_OBJ_RX_FIRST; i < C_CAN_MSG_OBJ_RX_LAST; i++)
-		c_can_setup_receive_object(dev, 0, i, 0, 0,
-			(IF_MCONT_RXIE | IF_MCONT_UMASK) & ~IF_MCONT_EOB);
-
-	c_can_setup_receive_object(dev, 0, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
-			IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
+		c_can_setup_receive_object(dev, 0, i,
+					   IF_MASK_MDIR | IF_MASK_RES, 0,
+					   IF_MCONT_UMASK | IF_MCONT_RXIE |
+					   IF_MCONT_DLC_MAX);
+
+	c_can_setup_receive_object(dev, 0, C_CAN_MSG_OBJ_RX_LAST,
+				   IF_MASK_MDIR | IF_MASK_RES, 0,
+				   IF_MCONT_UMASK | IF_MCONT_EOB |
+				   IF_MCONT_RXIE | IF_MCONT_DLC_MAX);
 }
 
 /*
-- 
1.8.4.rc3
