From: David Lamparter <equinox@diac24.net>
Subject: [PATCH] net: vlan, qlcnic: make vlan_find_dev private
Date: Sun, 17 Jul 2011 20:53:12 +0200
Message-ID: <1310928792-3436326-1-git-send-email-equinox@diac24.net>
Cc: David Lamparter <equinox@diac24.net>,
	Patrick McHardy <kaber@trash.net>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:35393 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754714Ab1GQSx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 14:53:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

there is only one user of vlan_find_dev outside of the actual vlan code:
qlcnic uses it to iterate over some VLANs it knows.

let's just make vlan_find_dev private to the VLAN code and have the
iteration in qlcnic be a bit more direct. (a few rcu dereferences less
too)

Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: linux-driver@qlogic.com
---
 drivers/net/qlcnic/qlcnic_main.c |    7 ++++++-
 include/linux/if_vlan.h          |   11 -----------
 net/8021q/vlan.h                 |   12 ++++++++++++
 3 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 006a693..3579229 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -4198,13 +4198,18 @@ static void
 qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct vlan_group *grp;
 	struct net_device *dev;
 	u16 vid;
 
 	qlcnic_config_indev_addr(adapter, netdev, event);
 
+	grp = rcu_dereference_rtnl(netdev->vlgrp);
+	if (!grp)
+		return;
+
 	for_each_set_bit(vid, adapter->vlans, VLAN_N_VID) {
-		dev = vlan_find_dev(netdev, vid);
+		dev = vlan_group_get_device(grp, vid);
 		if (!dev)
 			continue;
 		qlcnic_config_indev_addr(adapter, dev, event);
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index affa273..bc03e40 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -119,17 +119,6 @@ static inline int is_vlan_dev(struct net_device *dev)
 #define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-/* Must be invoked with rcu_read_lock or with RTNL. */
-static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
-					       u16 vlan_id)
-{
-	struct vlan_group *grp = rcu_dereference_rtnl(real_dev->vlgrp);
-
-	if (grp)
-		return vlan_group_get_device(grp, vlan_id);
-
-	return NULL;
-}
 
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 9da07e3..b132f54 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -74,6 +74,18 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
 	return netdev_priv(dev);
 }
 
+/* Must be invoked with rcu_read_lock or with RTNL. */
+static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
+					       u16 vlan_id)
+{
+	struct vlan_group *grp = rcu_dereference_rtnl(real_dev->vlgrp);
+
+	if (grp)
+		return vlan_group_get_device(grp, vlan_id);
+
+	return NULL;
+}
+
 /* found in vlan_dev.c */
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, u16 vlan_prio);
-- 
1.7.5.3

