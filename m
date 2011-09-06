From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/3 RFC] macvlan: Add function to set addr
	filters for device in passthru mode
Date: Tue, 06 Sep 2011 15:35:50 -0700
Message-ID: <20110906223550.6552.69365.stgit@savbu-pc100.cisco.com>
References: <20110906223536.6552.2062.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dragos.tatulea@gmail.com, arnd@arndb.de, mst@redhat.com,
	dwang2@cisco.com, benve@cisco.com, kaber@trash.net, sri@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:55428 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510Ab1IFWpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 18:45:17 -0400
In-Reply-To: <20110906223536.6552.2062.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch introduces a function that accepts address list and filter flags
and sets them on the macvlan netdev. Currently it only supports PASSTHRU mode.
It also removes the code that puts the device in promiscous mode for PASSTHRU

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvlan.c      |  130 ++++++++++++++++++++++++++++++++++++++------
 include/linux/if_macvlan.h |    3 +
 2 files changed, 114 insertions(+), 19 deletions(-)


diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 528924f..ba8b5a6 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -299,18 +299,16 @@ static int macvlan_open(struct net_device *dev)
 	struct net_device *lowerdev = vlan->lowerdev;
 	int err;
 
-	if (vlan->port->passthru) {
-		dev_set_promiscuity(lowerdev, 1);
-		goto hash_add;
-	}
+	if (!vlan->port->passthru) {
+		err = -EBUSY;
+		if (macvlan_addr_busy(vlan->port, dev->dev_addr))
+			goto out;
 
-	err = -EBUSY;
-	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
-		goto out;
+		err = dev_uc_add(lowerdev, dev->dev_addr);
+		if (err < 0)
+			goto out;
+	}
 
-	err = dev_uc_add(lowerdev, dev->dev_addr);
-	if (err < 0)
-		goto out;
 	if (dev->flags & IFF_ALLMULTI) {
 		err = dev_set_allmulti(lowerdev, 1);
 		if (err < 0)
@@ -322,7 +320,6 @@ static int macvlan_open(struct net_device *dev)
 			goto unset_allmulti;
 	}
 
-hash_add:
 	macvlan_hash_add(vlan);
 	return 0;
 
@@ -330,7 +327,8 @@ unset_allmulti:
 	dev_set_allmulti(lowerdev, -1);
 
 del_unicast:
-	dev_uc_del(lowerdev, dev->dev_addr);
+	if (!vlan->port->passthru)
+		dev_uc_del(lowerdev, dev->dev_addr);
 out:
 	return err;
 }
@@ -340,11 +338,6 @@ static int macvlan_stop(struct net_device *dev)
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	if (vlan->port->passthru) {
-		dev_set_promiscuity(lowerdev, -1);
-		goto hash_del;
-	}
-
 	dev_uc_unsync(lowerdev, dev);
 	dev_mc_unsync(lowerdev, dev);
 	if (dev->flags & IFF_ALLMULTI)
@@ -352,9 +345,9 @@ static int macvlan_stop(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(lowerdev, -1);
 
-	dev_uc_del(lowerdev, dev->dev_addr);
+	if (!vlan->port->passthru)
+		dev_uc_del(lowerdev, dev->dev_addr);
 
-hash_del:
 	macvlan_hash_del(vlan, !dev->dismantle);
 	return 0;
 }
@@ -854,6 +847,105 @@ static int macvlan_device_event(struct notifier_block *unused,
 	return NOTIFY_DONE;
 }
 
+static int macvlan_set_filter_passthru(struct net_device *dev,
+					unsigned int flags, int count,
+					u8 *addrlist)
+{
+	struct netdev_hw_addr *ha;
+	u8 *addr;
+	int i, found;
+	unsigned int flags_changed;
+
+	rtnl_lock();
+
+	/*
+	 *	Only look for changes in IFF_PROMISC and IFF_ALLMULTI for now.
+	 *	Ideally this list for flags to look must come from the caller
+	 */
+	flags_changed = (dev->flags ^ flags) & (IFF_PROMISC | IFF_ALLMULTI);
+	if (flags_changed)
+		dev_change_flags(dev, dev->flags ^ flags_changed);
+
+	if (!count) {
+		rtnl_unlock();
+		return 0;
+	}
+
+	/* Delete all multicast addresses not in use */
+	netdev_for_each_mc_addr(ha, dev) {
+		for (i = 0, addr = addrlist; i < count; i++) {
+			if (is_multicast_ether_addr(addr)
+				&& !compare_ether_addr(addr,
+				ha->addr))
+				break;
+			addr += ETH_ALEN;
+		}
+		if (i == count)
+			dev_mc_del(dev, ha->addr);
+	}
+
+	/* Delete all unicast addresses not in use */
+	netdev_for_each_uc_addr(ha, dev) {
+		for (i = 0, addr = addrlist; i < count; i++) {
+			if (!is_multicast_ether_addr(addr)
+				&& !compare_ether_addr(addr,
+				ha->addr))
+				break;
+			addr += ETH_ALEN;
+		}
+		if (i == count)
+			dev_uc_del(dev, ha->addr);
+	}
+
+	/* Add new addresses */
+	for (i = 0, addr = addrlist; i < count; i++) {
+		found = 0;
+		if (is_multicast_ether_addr(addr)) {
+			netdev_for_each_mc_addr(ha, dev) {
+				if (compare_ether_addr(addr,
+					ha->addr) == 0) {
+					found = 1;
+					break;
+				}
+			}
+			if (!found)
+				dev_mc_add(dev, addr);
+		} else {
+			netdev_for_each_uc_addr(ha, dev) {
+				if (compare_ether_addr(addr,
+					ha->addr) == 0) {
+					found = 1;
+					break;
+				}
+			}
+			if (!found)
+				dev_uc_add(dev, addr);
+		}
+		addr += ETH_ALEN;
+	}
+	rtnl_unlock();
+
+	return count;
+}
+
+int macvlan_set_filter(struct net_device *dev, unsigned int flags,
+			int count, u8 *addrlist)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	if (!vlan)
+		return -EINVAL;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		return macvlan_set_filter_passthru(dev, flags, count,
+							addrlist);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+EXPORT_SYMBOL_GPL(macvlan_set_filter);
+
 static struct notifier_block macvlan_notifier_block __read_mostly = {
 	.notifier_call	= macvlan_device_event,
 };
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index e28b2e4..d55d4e6 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -104,4 +104,7 @@ extern int macvlan_link_register(struct rtnl_link_ops *ops);
 extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
 
+extern int macvlan_set_filter(struct net_device *dev, unsigned int flags,
+			      int count, u8 *addrlist);
+
 #endif /* _LINUX_IF_MACVLAN_H */
