From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH 1/2] ks8842: Add flags in the platform data
Date: Sat, 24 Jul 2010 22:25:23 +0200
Message-ID: <1280003123.28285.280.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:54602 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756335Ab0GXUZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 16:25:26 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id E2428E9F29
	for <netdev@vger.kernel.org>; Sat, 24 Jul 2010 22:25:24 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously the driver did a write to a timberdale specific register.
Timberdale is a FPGA used in some hardware setup which communicates
to the ks8842 via VLB.

A flag field is introduced where it is possible to pass a flag if
the ks8842 is connected via timberdale. Otherwise the driver won't
try to access timberdale registers.

If the timberdale flag is passed the driver also acks interrupts
in the FPGA, this is a bit more polite to the FPGA state machine.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 0be9261..48e4582 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -33,7 +33,13 @@
 #define DRV_NAME "ks8842"
=20
 /* Timberdale specific Registers */
-#define REG_TIMB_RST	0x1c
+#define REG_TIMB_RST		0x1c
+#define REG_TIMB_FIFO		0x20
+#define REG_TIMB_ISR		0x24
+#define REG_TIMB_IER		0x28
+#define REG_TIMB_IAR		0x2C
+#define REQ_TIMB_DMA_RESUME	0x30
+
=20
 /* KS8842 registers */
=20
@@ -121,6 +127,7 @@ struct ks8842_adapter {
 	spinlock_t	lock; /* spinlock to be interrupt safe */
 	struct work_struct timeout_work;
 	struct net_device *netdev;
+	u8 flags;
 };
=20
 static inline void ks8842_select_bank(struct ks8842_adapter *adapter, =
u16 bank)
@@ -195,12 +202,15 @@ static void ks8842_reset(struct ks8842_adapter *a=
dapter)
 	/* The KS8842 goes haywire when doing softare reset
 	 * a work around in the timberdale IP is implemented to
 	 * do a hardware reset instead
-	ks8842_write16(adapter, 3, 1, REG_GRR);
-	msleep(10);
-	iowrite16(0, adapter->hw_addr + REG_GRR);
-	*/
-	iowrite32(0x1, adapter->hw_addr + REG_TIMB_RST);
-	msleep(20);
+	 */
+	if (adapter->flags & KS8842_FLAGS_TIMB) {
+		iowrite32(0x1, adapter->hw_addr + REG_TIMB_RST);
+		msleep(20);
+	} else {
+		ks8842_write16(adapter, 3, 1, REG_GRR);
+		msleep(10);
+		iowrite16(0, adapter->hw_addr + REG_GRR);
+	}
 }
=20
 static void ks8842_update_link_status(struct net_device *netdev,
@@ -463,6 +473,10 @@ void ks8842_tasklet(unsigned long arg)
 	/* Ack */
 	ks8842_write16(adapter, 18, isr, REG_ISR);
=20
+	/* Ack in the timberdale IP as well */
+	if (adapter->flags & KS8842_FLAGS_TIMB)
+		iowrite32(0x1, adapter->hw_addr + REG_TIMB_IAR);
+
 	if (!netif_running(netdev))
 		return;
=20
@@ -687,6 +701,8 @@ static int __devinit ks8842_probe(struct platform_d=
evice *pdev)
 	/* Check if a mac address was given */
 	i =3D netdev->addr_len;
 	if (pdata) {
+		adapter->flags =3D pdata->flags;
+
 		for (i =3D 0; i < netdev->addr_len; i++)
 			if (pdata->macaddr[i] !=3D 0)
 				break;
diff --git a/include/linux/ks8842.h b/include/linux/ks8842.h
index da0341b..12b4bda 100644
--- a/include/linux/ks8842.h
+++ b/include/linux/ks8842.h
@@ -21,14 +21,18 @@
=20
 #include <linux/if_ether.h>
=20
+#define KS8842_FLAGS_TIMB 0x01
+
 /**
  * struct ks8842_platform_data - Platform data of the KS8842 network d=
river
  * @macaddr:	The MAC address of the device, set to all 0:s to use the =
on in
  *		the chip.
+ * @flags:	Flags to the drivers which configures the hardware setup
  *
  */
 struct ks8842_platform_data {
 	u8 macaddr[ETH_ALEN];
+	u8 flags;
 };
=20
 #endif

