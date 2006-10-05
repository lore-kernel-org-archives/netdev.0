From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/2] sk98lin: ethtool register dump
Date: Thu, 5 Oct 2006 10:16:23 -0700
Message-ID: <20061005101623.5da0ce3e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22468 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751420AbWJERWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 13:22:14 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for dumping the registers in the deprecated
sk98lin driver. This is allows for easier comparison with
settings in new skge driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.orig/drivers/net/sk98lin/skethtool.c
+++ linux-2.6/drivers/net/sk98lin/skethtool.c
@@ -581,6 +581,30 @@ static int setRxCsum(struct net_device *
 	return 0;
 }
 
+static int getRegsLen(struct net_device *dev)
+{
+	return 0x4000;
+}
+
+/*
+ * Returns copy of whole control register region
+ * Note: skip RAM address register because accessing it will
+ * 	 cause bus hangs!
+ */
+static void getRegs(struct net_device *dev, struct ethtool_regs *regs,
+			  void *p)
+{
+	DEV_NET *pNet = netdev_priv(dev);
+	const void __iomem *io = pNet->pAC->IoBase;
+
+	regs->version = 1;
+	memset(p, 0, regs->len);
+	memcpy_fromio(p, io, B3_RAM_ADDR);
+
+	memcpy_fromio(p + B3_RI_WTO_R1, io + B3_RI_WTO_R1,
+		      regs->len - B3_RI_WTO_R1);
+}
+
 const struct ethtool_ops SkGeEthtoolOps = {
 	.get_settings		= getSettings,
 	.set_settings		= setSettings,
@@ -599,4 +623,6 @@ const struct ethtool_ops SkGeEthtoolOps 
 	.set_tx_csum		= setTxCsum,
 	.get_rx_csum		= getRxCsum,
 	.set_rx_csum		= setRxCsum,
+	.get_regs		= getRegs,
+	.get_regs_len		= getRegsLen,
 };
