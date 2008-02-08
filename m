From: "Alexandre Bounine" <Alexandre.Bounine@tundra.com>
Subject: [PATCH 5/5] Tsi108_eth: Add ethtool support
Date: Fri, 8 Feb 2008 14:17:48 -0500
Message-ID: <1B5F013528140F45B5C671039279CA5702A960A5@NANUK.pc.tundra.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@ozlabs.org>,
	"Josh Boyer" <jwboyer@linux.vnet.ibm.com>,
	"Zang Roy-r61911" <tie-fei.zang@freescale.com>
To: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tundra.com ([142.46.200.162]:48725 "EHLO mx2.tundra.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763238AbYBHT3s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 14:29:48 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool support to tsi108_eth network driver.
   
Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
---

diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
linux-2.6.24-fix/drivers/net/tsi108_eth.c
--- linux-2.6.24/drivers/net/tsi108_eth.c	2008-02-06
17:10:53.000000000 -0500
+++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
18:09:43.000000000 -0500
@@ -36,6 +36,7 @@
 #include <linux/net.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -1519,12 +1520,46 @@ static void tsi108_init_mac(struct net_d
 	TSI_WRITE(TSI108_EC_INTMASK, ~0);
 }
 
+static int tsi108_get_settings(struct net_device *dev, struct
ethtool_cmd *cmd)
+{
+	struct tsi108_prv_data *data = netdev_priv(dev);
+	unsigned long flags;
+	int rc;
+	
+	spin_lock_irqsave(&data->txlock, flags);
+	rc = mii_ethtool_gset(&data->mii_if, cmd);
+	spin_unlock_irqrestore(&data->txlock, flags);
+
+	return rc;
+}
+
+static int tsi108_set_settings(struct net_device *dev, struct
ethtool_cmd *cmd)
+{
+	struct tsi108_prv_data *data = netdev_priv(dev);
+	unsigned long flags;
+	int rc;
+
+	spin_lock_irqsave(&data->txlock, flags);
+	rc = mii_ethtool_sset(&data->mii_if, cmd);
+	spin_unlock_irqrestore(&data->txlock, flags);
+	
+	return rc;
+}
+
 static int tsi108_do_ioctl(struct net_device *dev, struct ifreq *rq,
int cmd)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
+	if (!netif_running(dev))
+		return -EINVAL;
 	return generic_mii_ioctl(&data->mii_if, if_mii(rq), cmd, NULL);
 }
 
+static const struct ethtool_ops tsi108_ethtool_ops = {
+	.get_link 	= ethtool_op_get_link,
+	.get_settings	= tsi108_get_settings,
+	.set_settings	= tsi108_set_settings,
+};
+
 static int
 tsi108_init_one(struct platform_device *pdev)
 {
@@ -1589,6 +1624,7 @@ tsi108_init_one(struct platform_device *
 	dev->get_stats = tsi108_get_stats;
 	netif_napi_add(dev, &data->napi, tsi108_poll, 64);
 	dev->do_ioctl = tsi108_do_ioctl;
+	dev->ethtool_ops = &tsi108_ethtool_ops;
 
 	/* Apparently, the Linux networking code won't use
scatter-gather
 	 * if the hardware doesn't do checksums.  However, it's faster



---



Important Notice: This message is intended for the use of the individual to whom it is addressed and may contain information which is privileged, confidential and/or exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, or is not the employee or agent responsible for delivering the message to the intended recipient, you are hereby notified that any dissemination, distribution, or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender immediately by telephone or return e-mail and delete the original message from your systems. Thank you. 


