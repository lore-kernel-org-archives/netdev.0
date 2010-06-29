From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC] [PATCH] ethtool: Change ethtool_op_set_flags to validate
 flags
Date: Tue, 29 Jun 2010 17:01:01 +0100
Message-ID: <1277827261.2112.48.camel@achroite.uk.solarflarecom.com>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
	 <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
	 <20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
	 <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D4E@MNEXMB2.qlogic.org>
	 <20100628161412.7d9d0e4f@dhcp-lab-109.englab.brq.redhat.com>
	 <1277734724.2089.10.camel@achroite.uk.solarflarecom.com>
	 <1277822484.2112.19.camel@achroite.uk.solarflarecom.com>
	 <20100629170025.7a130e28@dhcp-lab-109.englab.brq.redhat.com>
	 <1277823923.2112.26.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55203 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089Ab0F2QBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 12:01:06 -0400
In-Reply-To: <1277823923.2112.26.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the sort of change I'd like to see.

Ben.

---
ethtool_op_set_flags() does not check for unsupported flags, and has
no way of doing so.  This means it is not suitable for use as a
default implementation of ethtool_ops::set_flags.

Add a 'supported' parameter specifying the flags that the driver and
hardware support, validate the requested flags against this, and
change all current callers to pass this parameter.

Change some other trivial implementations of ethtool_ops::set_flags to
call ethtool_op_set_flags().
---
 drivers/net/cxgb4/cxgb4_main.c    |    9 +--------
 drivers/net/enic/enic_main.c      |    1 -
 drivers/net/ixgbe/ixgbe_ethtool.c |    5 ++++-
 drivers/net/mv643xx_eth.c         |    7 ++++++-
 drivers/net/myri10ge/myri10ge.c   |   10 +++++++---
 drivers/net/niu.c                 |    9 +--------
 drivers/net/sfc/ethtool.c         |    5 +----
 drivers/net/sky2.c                |   16 ++++++----------
 include/linux/ethtool.h           |    2 +-
 net/core/ethtool.c                |   28 +++++-----------------------
 10 files changed, 32 insertions(+), 60 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 6528167..55a720e 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1799,14 +1799,7 @@ static int set_tso(struct net_device *dev, u32 value)
 
 static int set_flags(struct net_device *dev, u32 flags)
 {
-	if (flags & ~ETH_FLAG_RXHASH)
-		return -EOPNOTSUPP;
-
-	if (flags & ETH_FLAG_RXHASH)
-		dev->features |= NETIF_F_RXHASH;
-	else
-		dev->features &= ~NETIF_F_RXHASH;
-	return 0;
+	return ethtool_op_set_flags(dev, flags, ETH_FLAG_RXHASH);
 }
 
 static struct ethtool_ops cxgb_ethtool_ops = {
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 6c6795b..77a7f87 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -365,7 +365,6 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_coalesce = enic_get_coalesce,
 	.set_coalesce = enic_set_coalesce,
 	.get_flags = ethtool_op_get_flags,
-	.set_flags = ethtool_op_set_flags,
 };
 
 static void enic_free_wq_buf(struct vnic_wq *wq, struct vnic_wq_buf *buf)
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 873b45e..7d2e5ea 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2205,8 +2205,11 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	bool need_reset = false;
+	int rc;
 
-	ethtool_op_set_flags(netdev, data);
+	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO | ETH_FLAG_NTUPLE);
+	if (rc)
+		return rc;
 
 	/* if state changes we need to update adapter->flags and reset */
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) {
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index e345ec8..82b720f 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1636,6 +1636,11 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
 	}
 }
 
+static int mv643xx_eth_set_flags(struct net_device *dev, u32 data)
+{
+	return ethtool_op_set_flags(dev, data, ETH_FLAG_LRO);
+}
+
 static int mv643xx_eth_get_sset_count(struct net_device *dev, int sset)
 {
 	if (sset == ETH_SS_STATS)
@@ -1661,7 +1666,7 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
 	.get_flags		= ethtool_op_get_flags,
-	.set_flags		= ethtool_op_set_flags,
+	.set_flags		= mv643xx_eth_set_flags,
 	.get_sset_count		= mv643xx_eth_get_sset_count,
 };
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index e0b47cc..d771d16 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1730,8 +1730,7 @@ static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_enabled)
 	if (csum_enabled)
 		mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	else {
-		u32 flags = ethtool_op_get_flags(netdev);
-		err = ethtool_op_set_flags(netdev, (flags & ~ETH_FLAG_LRO));
+		netdev->features &= ~NETIF_F_LRO;
 		mgp->csum_flag = 0;
 
 	}
@@ -1900,6 +1899,11 @@ static u32 myri10ge_get_msglevel(struct net_device *netdev)
 	return mgp->msg_enable;
 }
 
+static int myri10ge_set_flags(struct net_device *netdev, u32 value)
+{
+	return ethtool_op_set_flags(netdev, value, ETH_FLAG_LRO);
+}
+
 static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.get_settings = myri10ge_get_settings,
 	.get_drvinfo = myri10ge_get_drvinfo,
@@ -1920,7 +1924,7 @@ static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.set_msglevel = myri10ge_set_msglevel,
 	.get_msglevel = myri10ge_get_msglevel,
 	.get_flags = ethtool_op_get_flags,
-	.set_flags = ethtool_op_set_flags
+	.set_flags = myri10ge_set_flags
 };
 
 static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 63e8e38..3d523cb 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7920,14 +7920,7 @@ static int niu_phys_id(struct net_device *dev, u32 data)
 
 static int niu_set_flags(struct net_device *dev, u32 data)
 {
-	if (data & (ETH_FLAG_LRO | ETH_FLAG_NTUPLE))
-		return -EOPNOTSUPP;
-
-	if (data & ETH_FLAG_RXHASH)
-		dev->features |= NETIF_F_RXHASH;
-	else
-		dev->features &= ~NETIF_F_RXHASH;
-	return 0;
+	return ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH);
 }
 
 static const struct ethtool_ops niu_ethtool_ops = {
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 7693cfb..23372bf 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -551,10 +551,7 @@ static int efx_ethtool_set_flags(struct net_device *net_dev, u32 data)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	u32 supported = efx->type->offload_features & ETH_FLAG_RXHASH;
 
-	if (data & ~supported)
-		return -EOPNOTSUPP;
-
-	return ethtool_op_set_flags(net_dev, data);
+	return ethtool_op_set_flags(net_dev, data, supported);
 }
 
 static void efx_ethtool_self_test(struct net_device *net_dev,
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7985165..c762c6a 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4188,17 +4188,13 @@ static int sky2_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom
 static int sky2_set_flags(struct net_device *dev, u32 data)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
+	u32 supported =
+		(sky2->hw->flags & SKY2_HW_RSS_BROKEN) ? 0 : ETH_FLAG_RXHASH;
+	int rc;
 
-	if (data & ~ETH_FLAG_RXHASH)
-		return -EOPNOTSUPP;
-
-	if (data & ETH_FLAG_RXHASH) {
-		if (sky2->hw->flags & SKY2_HW_RSS_BROKEN)
-			return -EINVAL;
-
-		dev->features |= NETIF_F_RXHASH;
-	} else
-		dev->features &= ~NETIF_F_RXHASH;
+	rc = ethtool_op_set_flags(dev, data, supported);
+	if (rc)
+		return rc;
 
 	rx_set_rss(dev);
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 2c8af09..084ddb3 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -457,7 +457,7 @@ int ethtool_op_set_tso(struct net_device *dev, u32 data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
 u32 ethtool_op_get_flags(struct net_device *dev);
-int ethtool_op_set_flags(struct net_device *dev, u32 data);
+int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);
 void ethtool_ntuple_flush(struct net_device *dev);
 
 /**
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a0f4964..5d42fae 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -144,31 +144,13 @@ u32 ethtool_op_get_flags(struct net_device *dev)
 }
 EXPORT_SYMBOL(ethtool_op_get_flags);
 
-int ethtool_op_set_flags(struct net_device *dev, u32 data)
+int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
 {
-	const struct ethtool_ops *ops = dev->ethtool_ops;
-	unsigned long features = dev->features;
-
-	if (data & ETH_FLAG_LRO)
-		features |= NETIF_F_LRO;
-	else
-		features &= ~NETIF_F_LRO;
-
-	if (data & ETH_FLAG_NTUPLE) {
-		if (!ops->set_rx_ntuple)
-			return -EOPNOTSUPP;
-		features |= NETIF_F_NTUPLE;
-	} else {
-		/* safe to clear regardless */
-		features &= ~NETIF_F_NTUPLE;
-	}
-
-	if (data & ETH_FLAG_RXHASH)
-		features |= NETIF_F_RXHASH;
-	else
-		features &= ~NETIF_F_RXHASH;
+	if (data & ~supported)
+		return -EINVAL;
 
-	dev->features = features;
+	dev->features = ((dev->features & ~flags_dup_features) |
+			 (data & flags_dup_features));
 	return 0;
 }
 EXPORT_SYMBOL(ethtool_op_set_flags);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

