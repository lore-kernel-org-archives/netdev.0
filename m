From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v2 8/8] macvlan: add FDB bridge ops and macvlan flags
Date: Wed, 11 Apr 2012 23:57:54 -0700
Message-ID: <20120412065754.3112.31357.stgit@jf-dev1-dcblab>
References: <20120412064858.3112.65818.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: shemminger@vyatta.com, mst@redhat.com, davem@davemloft.net,
	bhutchings@solarflare.com, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19344 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757468Ab2DLHK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 03:10:58 -0400
In-Reply-To: <20120412064858.3112.65818.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds FDB bridge ops to the macvlan device passthru mode.
Additionally a flags field was added and a NOPROMISC bit to
allow users to use passthru mode without the driver calling
dev_set_promiscuity(). The flags field is a u16 placed in a
4 byte hole (consuming 2 bytes) of the macvlan_dev struct.

We want to do this so that the macvlan driver or stack
above the macvlan driver does not have to process every
packet. For the use case where we know all the MAC addresses
of the endstations above us this works well.

This patch is a result of Roopa Prabhu's work. Follow up
patches are needed for VEPA and VEB macvlan modes.

v2: Change from distinct nopromisc mode to a flags field to
    configure this. This avoids the tendency to add a new
    mode every time we need some slightly different behavior.

CC: Roopa Prabhu <roprabhu@cisco.com>
CC: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/macvlan.c      |   61 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_link.h    |    3 ++
 include/linux/if_macvlan.h |    1 +
 3 files changed, 59 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b17fc90..df782c0 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -312,7 +312,8 @@ static int macvlan_open(struct net_device *dev)
 	int err;
 
 	if (vlan->port->passthru) {
-		dev_set_promiscuity(lowerdev, 1);
+		if (!(vlan->flags & MACVLAN_FLAG_NOPROMISC))
+			dev_set_promiscuity(lowerdev, 1);
 		goto hash_add;
 	}
 
@@ -344,12 +345,15 @@ static int macvlan_stop(struct net_device *dev)
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
+	dev_uc_unsync(lowerdev, dev);
+	dev_mc_unsync(lowerdev, dev);
+
 	if (vlan->port->passthru) {
-		dev_set_promiscuity(lowerdev, -1);
+		if (!(vlan->flags & MACVLAN_FLAG_NOPROMISC))
+			dev_set_promiscuity(lowerdev, 1);
 		goto hash_del;
 	}
 
-	dev_mc_unsync(lowerdev, dev);
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, -1);
 
@@ -399,10 +403,11 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
 		dev_set_allmulti(lowerdev, dev->flags & IFF_ALLMULTI ? 1 : -1);
 }
 
-static void macvlan_set_multicast_list(struct net_device *dev)
+static void macvlan_set_mac_lists(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	dev_uc_sync(vlan->lowerdev, dev);
 	dev_mc_sync(vlan->lowerdev, dev);
 }
 
@@ -542,6 +547,43 @@ static int macvlan_vlan_rx_kill_vid(struct net_device *dev,
 	return 0;
 }
 
+static int macvlan_fdb_add(struct ndmsg *ndm,
+			   struct net_device *dev,
+			   unsigned char *addr,
+			   u16 flags)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err = -EINVAL;
+
+	if (!vlan->port->passthru)
+		return -EOPNOTSUPP;
+
+	if (is_unicast_ether_addr(addr))
+		err = dev_uc_add_excl(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_add_excl(dev, addr);
+
+	return err;
+}
+
+static int macvlan_fdb_del(struct ndmsg *ndm,
+			   struct net_device *dev,
+			   unsigned char *addr)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err = -EINVAL;
+
+	if (!vlan->port->passthru)
+		return -EOPNOTSUPP;
+
+	if (is_unicast_ether_addr(addr))
+		err = dev_uc_del(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_del(dev, addr);
+
+	return err;
+}
+
 static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *drvinfo)
 {
@@ -572,11 +614,14 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_change_mtu		= macvlan_change_mtu,
 	.ndo_change_rx_flags	= macvlan_change_rx_flags,
 	.ndo_set_mac_address	= macvlan_set_mac_address,
-	.ndo_set_rx_mode	= macvlan_set_multicast_list,
+	.ndo_set_rx_mode	= macvlan_set_mac_lists,
 	.ndo_get_stats64	= macvlan_dev_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_vlan_rx_add_vid	= macvlan_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= macvlan_vlan_rx_kill_vid,
+	.ndo_fdb_add		= macvlan_fdb_add,
+	.ndo_fdb_del		= macvlan_fdb_del,
+	.ndo_fdb_dump		= ndo_dflt_fdb_dump,
 };
 
 void macvlan_common_setup(struct net_device *dev)
@@ -711,6 +756,9 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (data && data[IFLA_MACVLAN_MODE])
 		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
 
+	if (data && data[IFLA_MACVLAN_FLAGS])
+		vlan->flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
+
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
 		if (port->count)
 			return -EINVAL;
@@ -782,7 +830,8 @@ nla_put_failure:
 }
 
 static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
-	[IFLA_MACVLAN_MODE] = { .type = NLA_U32 },
+	[IFLA_MACVLAN_MODE]  = { .type = NLA_U32 },
+	[IFLA_MACVLAN_FLAGS] = { .type = NLA_U16 },
 };
 
 int macvlan_link_register(struct rtnl_link_ops *ops)
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 2f4fa93..f715750 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -255,6 +255,7 @@ struct ifla_vlan_qos_mapping {
 enum {
 	IFLA_MACVLAN_UNSPEC,
 	IFLA_MACVLAN_MODE,
+	IFLA_MACVLAN_FLAGS,
 	__IFLA_MACVLAN_MAX,
 };
 
@@ -267,6 +268,8 @@ enum macvlan_mode {
 	MACVLAN_MODE_PASSTHRU = 8,/* take over the underlying device */
 };
 
+#define MACVLAN_FLAG_NOPROMISC	1
+
 /* SR-IOV virtual function management section */
 
 enum {
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index d103dca..f65e8d2 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -60,6 +60,7 @@ struct macvlan_dev {
 	struct net_device	*lowerdev;
 	struct macvlan_pcpu_stats __percpu *pcpu_stats;
 	enum macvlan_mode	mode;
+	u16			flags;
 	int (*receive)(struct sk_buff *skb);
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
 	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
