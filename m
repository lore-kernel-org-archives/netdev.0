From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 1/4] ethtool: correctly ensure {GS}CHANNELS doesn't conflict with GS{RXFH}
Date: Mon,  8 Feb 2016 12:06:02 -0800
Message-ID: <1454961965-15116-2-git-send-email-jacob.e.keller@intel.com>
References: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
Cc: mooray3@wp.pl, davem@davemloft.net,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8053 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617AbcBHUIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 15:08:40 -0500
In-Reply-To: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet drivers implementing both {GS}RXFH and {GS}CHANNELS ethtool ops
incorrectly allow SCHANNELS when it would conflict with the settings
from SRXFH. This occurs because it is not possible for drivers to
understand whether their Rx flow indirection table has been configured
or is in the default state. In addition, drivers currently behave in
various ways when increasing the number of Rx channels.

Some drivers will always destroy the Rx flow indirection table when this
occurs, whether it has been set by the user or not. Other drivers will
attempt to preserve the table even if the user has never modified it
from the default driver settings. Neither of these situation is
desirable because it leads to unexpected behavior or loss of user
configuration.

The correct behavior is to simply return -EINVAL when SCHANNELS would
conflict with the current Rx flow table settings. However, it should
only do so if the current settings were modified by the user. If we
required that the new settings never conflict with the current (default)
Rx flow settings, we would force users to first reduce their Rx flow
settings and then reduce the number of Rx channels.

This patch proposes a solution implemented in net/core/ethtool.c which
ensures that all drivers behave correctly. It checks whether the RXFH
table has been configured to non-default settings, and stores this
information in a private netdev flag. When the number of channels is
requested to change, it first ensures that the current Rx flow table is
not going to assign flows to now disabled channels.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 include/linux/netdevice.h |  8 +++++++
 net/core/ethtool.c        | 59 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 289c2314d766..044fa2d88c7f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1291,6 +1291,7 @@ struct net_device_ops {
  * @IFF_OPENVSWITCH: device is a Open vSwitch master
  * @IFF_L3MDEV_SLAVE: device is enslaved to an L3 master device
  * @IFF_TEAM: device is a team device
+ * @IFF_RXFH_CONFIGURED: device has had Rx Flow indirection table configured
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1318,6 +1319,7 @@ enum netdev_priv_flags {
 	IFF_OPENVSWITCH			= 1<<22,
 	IFF_L3MDEV_SLAVE		= 1<<23,
 	IFF_TEAM			= 1<<24,
+	IFF_RXFH_CONFIGURED		= 1<<25,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1345,6 +1347,7 @@ enum netdev_priv_flags {
 #define IFF_OPENVSWITCH			IFF_OPENVSWITCH
 #define IFF_L3MDEV_SLAVE		IFF_L3MDEV_SLAVE
 #define IFF_TEAM			IFF_TEAM
+#define IFF_RXFH_CONFIGURED		IFF_RXFH_CONFIGURED
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -4045,6 +4048,11 @@ static inline bool netif_is_lag_port(const struct net_device *dev)
 	return netif_is_bond_slave(dev) || netif_is_team_port(dev);
 }
 
+static inline bool netif_is_rxfh_configured(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_RXFH_CONFIGURED;
+}
+
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index daf04709dd3c..8a40948c1fc6 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -642,6 +642,39 @@ void netdev_rss_key_fill(void *buffer, size_t len)
 }
 EXPORT_SYMBOL(netdev_rss_key_fill);
 
+static inline int ethool_get_max_rxfh_channel(struct net_device *dev, u32 *max)
+{
+	u32 dev_size, current_max = 0;
+	u32 *indir;
+	int ret, i;
+
+	if (!dev->ethtool_ops->get_rxfh_indir_size ||
+	    !dev->ethtool_ops->get_rxfh)
+		return -EOPNOTSUPP;
+	dev_size = dev->ethtool_ops->get_rxfh_indir_size(dev);
+	if (dev_size == 0)
+		return -EOPNOTSUPP;
+
+	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER);
+	if (!indir)
+		return -ENOMEM;
+
+	ret = dev->ethtool_ops->get_rxfh(dev, indir, NULL, NULL);
+	if (ret)
+		goto out;
+
+	for (i = dev_size; i--;) {
+		if (indir[i] > current_max)
+			current_max = indir[i];
+	}
+
+	*max = current_max;
+
+out:
+	kfree(indir);
+	return ret;
+}
+
 static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *dev,
 						     void __user *useraddr)
 {
@@ -738,6 +771,14 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 	}
 
 	ret = ops->set_rxfh(dev, indir, NULL, ETH_RSS_HASH_NO_CHANGE);
+	if (ret)
+		goto out;
+
+	/* indicate whether rxfh was set to default */
+	if (user_size == 0)
+		dev->priv_flags &= ~IFF_RXFH_CONFIGURED;
+	else
+		dev->priv_flags |= IFF_RXFH_CONFIGURED;
 
 out:
 	kfree(indir);
@@ -897,6 +938,14 @@ static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
 	}
 
 	ret = ops->set_rxfh(dev, indir, hkey, rxfh.hfunc);
+	if (ret)
+		goto out;
+
+	/* indicate whether rxfh was set to default */
+	if (rxfh.indir_size == 0)
+		dev->priv_flags &= ~IFF_RXFH_CONFIGURED;
+	else if (rxfh.indir_size != ETH_RXFH_INDIR_NO_CHANGE)
+		dev->priv_flags |= IFF_RXFH_CONFIGURED;
 
 out:
 	kfree(rss_config);
@@ -1228,6 +1277,8 @@ static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 						   void __user *useraddr)
 {
 	struct ethtool_channels channels;
+	u32 max_rx = 0;
+	int ret;
 
 	if (!dev->ethtool_ops->set_channels)
 		return -EOPNOTSUPP;
@@ -1235,6 +1286,14 @@ static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 	if (copy_from_user(&channels, useraddr, sizeof(channels)))
 		return -EFAULT;
 
+	/* ensure the new Rx count fits within the configured Rx flow
+	 * indirection table settings */
+	if (netif_is_rxfh_configured(dev) &&
+	    ethtool_get_max_rxfh_channel(dev, &max_rx) &&
+	    ((channels.rx_count > max_rx) ||
+	     (channels.combined_count > max_rx))
+	    return -EINVAL;
+
 	return dev->ethtool_ops->set_channels(dev, &channels);
 }
 
-- 
2.7.0.236.gda096a0.dirty
