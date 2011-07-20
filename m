From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 03/47] vlan: introduce __vlan_find_dev_deep()
Date: Wed, 20 Jul 2011 16:54:05 +0200
Message-ID: <1311173689-17419-4-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545Ab1GTOzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:01 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since vlan_group_get_device and vlan_group is not going to be accessible
from device drivers, introduce function which substitutes it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |    8 ++++++++
 net/8021q/vlan_core.c   |   21 +++++++++++++++++++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index cfb0cf2..69391cc 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -120,6 +120,8 @@ static inline int is_vlan_dev(struct net_device *dev)
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 
+extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
+					       u16 vlan_id);
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
@@ -135,6 +137,12 @@ vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	       unsigned int vlan_tci);
 
 #else
+static inline struct net_device *
+__vlan_find_dev_deep(struct net_device *real_dev, u16 vlan_id)
+{
+	return NULL;
+}
+
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	BUG();
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index fcc6846..5940366 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -63,6 +63,27 @@ bool vlan_do_receive(struct sk_buff **skbp)
 	return true;
 }
 
+/* Must be invoked with rcu_read_lock or with RTNL. */
+struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
+					u16 vlan_id)
+{
+	struct vlan_group *grp = rcu_dereference_rtnl(real_dev->vlgrp);
+
+	if (grp) {
+		return vlan_group_get_device(grp, vlan_id);
+	} else {
+		/*
+		 * Bonding slaves do not have grp assigned to themselves.
+		 * Grp is assigned to bonding master instead.
+		 */
+		if (netif_is_bond_slave(real_dev))
+			return __vlan_find_dev_deep(real_dev->master, vlan_id);
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(__vlan_find_dev_deep);
+
 struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	return vlan_dev_info(dev)->real_dev;
-- 
1.7.6

