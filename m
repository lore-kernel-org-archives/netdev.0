From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC] net: fix ethtool->set_flags not intended -EINVAL return value
Date: Mon, 21 Mar 2011 16:10:16 +0100
Message-ID: <20110321151015.GA2209@redhat.com>
References: <1300446743.11985.317.camel@firesoul.comx.local>
 <4D8385CE.1060205@intel.com>
 <1300699294.10934.63.camel@firesoul.comx.local>
 <1300700708.2884.10.camel@edumazet-laptop>
 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8429@MNEXMB2.qlogic.org>
 <20110321123406.GA2376@redhat.com>
 <20110321134647.GA3126@redhat.com>
 <1300715543.26693.349.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6317 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837Ab1CUPKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 11:10:51 -0400
Content-Disposition: inline
In-Reply-To: <1300715543.26693.349.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit d5dbda23804156ae6f35025ade5307a49d1db6d7 "ethtool: Add
support for vlan accleration.", drivers that have NETIF_F_HW_VLAN_TX,
and/or NETIF_F_HW_VLAN_RX feature, but do not allow enable/disable vlan
acceleration via ethtool set_flags, always return -EINVAL from that
function. Fix by returning -EINVAL only if requested features do
not match current settings and can not be changed by driver.

RFC for now, compile tested only.

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 653d308..3bdcc80 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -871,7 +871,7 @@ static int netxen_nic_set_flags(struct net_device *netdev, u32 data)
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int hw_lro;
 
-	if (data & ~ETH_FLAG_LRO)
+	if (ethtool_invalid_flags(netdev, data, ETH_FLAG_LRO))
 		return -EINVAL;
 
 	if (!(adapter->capabilities & NX_FW_CAPABILITY_HW_LRO))
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 4c14510..45b2755 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -1003,7 +1003,7 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int hw_lro;
 
-	if (data & ~ETH_FLAG_LRO)
+	if (ethtool_invalid_flags(netdev, data, ETH_FLAG_LRO))
 		return -EINVAL;
 
 	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO))
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2ad6364..356e74d 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6726,7 +6726,7 @@ static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
 	int rc = 0;
 	int changed = 0;
 
-	if (data & ~ETH_FLAG_LRO)
+	if (ethtool_invalid_flags(dev, data, ETH_FLAG_LRO))
 		return -EINVAL;
 
 	if (data & ETH_FLAG_LRO) {
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 81254be..51f2ef1 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -304,8 +304,8 @@ vmxnet3_set_flags(struct net_device *netdev, u32 data)
 	u8 lro_present = (netdev->features & NETIF_F_LRO) == 0 ? 0 : 1;
 	unsigned long flags;
 
-	if (data & ~ETH_FLAG_LRO)
-		return -EOPNOTSUPP;
+	if (ethtool_invalid_flags(netdev, data, ETH_FLAG_LRO))
+		return -EINVAL;
 
 	if (lro_requested ^ lro_present) {
 		/* toggle the LRO feature*/
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
index 1dd3a21..c5eb034 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1117,8 +1117,8 @@ static int vxge_set_flags(struct net_device *dev, u32 data)
 	struct vxgedev *vdev = netdev_priv(dev);
 	enum vxge_hw_status status;
 
-	if (data & ~ETH_FLAG_RXHASH)
-		return -EOPNOTSUPP;
+	if (ethtool_invalid_flags(dev, data, ETH_FLAG_RXHASH))
+		return -EINVAL;
 
 	if (!!(data & ETH_FLAG_RXHASH) == vdev->devh->config.rth_en)
 		return 0;
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index aac3e2e..e22b046 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -643,6 +643,7 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data);
 u32 ethtool_op_get_flags(struct net_device *dev);
 int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);
 void ethtool_ntuple_flush(struct net_device *dev);
+bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
 
 /**
  * &ethtool_ops - Alter and report network device settings
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..514127d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -141,9 +141,17 @@ u32 ethtool_op_get_flags(struct net_device *dev)
 }
 EXPORT_SYMBOL(ethtool_op_get_flags);
 
+bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported)
+{
+	u32 features = dev->features & flags_dup_features;
+
+	return ((features & ~supported) != (data & ~supported));
+}
+EXPORT_SYMBOL(ethtool_invalid_flags);
+
 int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
 {
-	if (data & ~supported)
+	if (ethtool_invalid_flags(dev, data, supported))
 		return -EINVAL;
 
 	dev->features = ((dev->features & ~flags_dup_features) |
