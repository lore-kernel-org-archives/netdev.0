From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/2] forcedeth: mac address corrected
Date: Mon, 31 Jul 2006 12:05:01 -0400
Message-ID: <44CE2A2D.9000103@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000409000302020605040700"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:551 "EHLO
	HQEMGATE02.nvidia.com") by vger.kernel.org with ESMTP
	id S1030299AbWGaSMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 14:12:49 -0400
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000409000302020605040700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch will correct the mac address and set a flag to indicate that 
it is already corrected in case nv_probe is called again. For example, 
when you use kexec to restart the kernel.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------000409000302020605040700
Content-Type: text/plain;
 name="patch-forcedeth-057-macaddress-corrected"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-057-macaddress-corrected"

--- orig-2.6/drivers/net/forcedeth.c	2006-07-06 15:06:27.000000000 -0400
+++ new-2.6/drivers/net/forcedeth.c	2006-07-06 15:06:58.000000000 -0400
@@ -109,6 +109,7 @@
  *	0.54: 21 Mar 2006: Fix spin locks for multi irqs and cleanup.
  *	0.55: 22 Mar 2006: Add flow control (pause frame).
  *	0.56: 22 Mar 2006: Additional ethtool config and moduleparam support.
+ *	0.57: 14 May 2006: Mac address set in probe/remove and order corrections.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -120,7 +121,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.56"
+#define FORCEDETH_VERSION		"0.57"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -262,7 +263,8 @@
 	NvRegRingSizes = 0x108,
 #define NVREG_RINGSZ_TXSHIFT 0
 #define NVREG_RINGSZ_RXSHIFT 16
-	NvRegUnknownTransmitterReg = 0x10c,
+	NvRegTransmitPoll = 0x10c,
+#define NVREG_TRANSMITPOLL_MAC_ADDR_REV	0x00008000
 	NvRegLinkSpeed = 0x110,
 #define NVREG_LINKSPEED_FORCE 0x10000
 #define NVREG_LINKSPEED_10	1000
@@ -1178,7 +1180,7 @@
 			KERN_INFO "nv_stop_tx: TransmitterStatus remained busy");
 
 	udelay(NV_TXSTOP_DELAY2);
-	writel(0, base + NvRegUnknownTransmitterReg);
+	writel(readl(base + NvRegTransmitPoll) & NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPoll);
 }
 
 static void nv_txrx_reset(struct net_device *dev)
@@ -3917,7 +3919,7 @@
 	oom = nv_init_ring(dev);
 
 	writel(0, base + NvRegLinkSpeed);
-	writel(0, base + NvRegUnknownTransmitterReg);
+	writel(readl(base + NvRegTransmitPoll) & NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPoll);
 	nv_txrx_reset(dev);
 	writel(0, base + NvRegUnknownSetupReg6);
 
@@ -4082,7 +4084,7 @@
 	unsigned long addr;
 	u8 __iomem *base;
 	int err, i;
-	u32 powerstate;
+	u32 powerstate, txreg;
 
 	dev = alloc_etherdev(sizeof(struct fe_priv));
 	err = -ENOMEM;
@@ -4269,12 +4271,30 @@
 	np->orig_mac[0] = readl(base + NvRegMacAddrA);
 	np->orig_mac[1] = readl(base + NvRegMacAddrB);
 
-	dev->dev_addr[0] = (np->orig_mac[1] >>  8) & 0xff;
-	dev->dev_addr[1] = (np->orig_mac[1] >>  0) & 0xff;
-	dev->dev_addr[2] = (np->orig_mac[0] >> 24) & 0xff;
-	dev->dev_addr[3] = (np->orig_mac[0] >> 16) & 0xff;
-	dev->dev_addr[4] = (np->orig_mac[0] >>  8) & 0xff;
-	dev->dev_addr[5] = (np->orig_mac[0] >>  0) & 0xff;
+	/* check the workaround bit for correct mac address order */
+	txreg = readl(base + NvRegTransmitPoll);
+	if (txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) {
+		/* mac address is already in correct order */
+		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
+		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
+		dev->dev_addr[2] = (np->orig_mac[0] >> 16) & 0xff;
+		dev->dev_addr[3] = (np->orig_mac[0] >> 24) & 0xff;
+		dev->dev_addr[4] = (np->orig_mac[1] >>  0) & 0xff;
+		dev->dev_addr[5] = (np->orig_mac[1] >>  8) & 0xff;
+	} else {
+		/* need to reverse mac address to correct order */
+		dev->dev_addr[0] = (np->orig_mac[1] >>  8) & 0xff;
+		dev->dev_addr[1] = (np->orig_mac[1] >>  0) & 0xff;
+		dev->dev_addr[2] = (np->orig_mac[0] >> 24) & 0xff;
+		dev->dev_addr[3] = (np->orig_mac[0] >> 16) & 0xff;
+		dev->dev_addr[4] = (np->orig_mac[0] >>  8) & 0xff;
+		dev->dev_addr[5] = (np->orig_mac[0] >>  0) & 0xff;
+		/* set permanent address to be correct aswell */
+		np->orig_mac[0] = (dev->dev_addr[0] << 0) + (dev->dev_addr[1] << 8) +
+			(dev->dev_addr[2] << 16) + (dev->dev_addr[3] << 24);
+		np->orig_mac[1] = (dev->dev_addr[4] << 0) + (dev->dev_addr[5] << 8);
+		writel(txreg|NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPoll);
+	}
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	if (!is_valid_ether_addr(dev->perm_addr)) {

--------------000409000302020605040700--
