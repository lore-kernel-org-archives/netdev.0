From: "Michael Chan" <mchan@broadcom.com>
Subject: [NET]: Add ethtool support for NETIF_F_IPV6_CSUM devices.
Date: Fri, 13 Jul 2007 19:03:22 -0700
Message-ID: <1184378602.6079.1.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2672 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760662AbXGNBLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 21:11:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Add ethtool support for NETIF_F_IPV6_CSUM devices.

Add ethtool utility function to set or clear IPV6_CSUM feature flag.
Modify tg3.c and bnx2.c to use this function when doing ethtool -K
to change tx checksum.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4e5e1cb..d23861c 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6218,7 +6218,7 @@ bnx2_set_tx_csum(struct net_device *dev, u32 data)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		return (ethtool_op_set_tx_hw_csum(dev, data));
+		return (ethtool_op_set_tx_ipv6_csum(dev, data));
 	else
 		return (ethtool_op_set_tx_csum(dev, data));
 }
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 32e4037..5ee1476 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8318,7 +8318,7 @@ static int tg3_set_tx_csum(struct net_device *dev, u32 data)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
-		ethtool_op_set_tx_hw_csum(dev, data);
+		ethtool_op_set_tx_ipv6_csum(dev, data);
 	else
 		ethtool_op_set_tx_csum(dev, data);
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index f2d248f..3a63224 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -265,6 +265,7 @@ u32 ethtool_op_get_link(struct net_device *dev);
 u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
+int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data);
 u32 ethtool_op_get_sg(struct net_device *dev);
 int ethtool_op_set_sg(struct net_device *dev, u32 data);
 u32 ethtool_op_get_tso(struct net_device *dev);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 8d5e5a0..0b531e9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -52,6 +52,17 @@ int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
 
 	return 0;
 }
+
+int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	else
+		dev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+
+	return 0;
+}
+
 u32 ethtool_op_get_sg(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_SG) != 0;
@@ -980,5 +991,6 @@ EXPORT_SYMBOL(ethtool_op_set_sg);
 EXPORT_SYMBOL(ethtool_op_set_tso);
 EXPORT_SYMBOL(ethtool_op_set_tx_csum);
 EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
+EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
 EXPORT_SYMBOL(ethtool_op_set_ufo);
 EXPORT_SYMBOL(ethtool_op_get_ufo);


