From: Veaceslav Falico <vfalico@redhat.com>
Subject: [RFC PATCH net-next 2/6] vlan: add __vlan_find_dev_next_id()
Date: Tue,  6 Aug 2013 19:59:00 +0200
Message-ID: <1375811944-31942-3-git-send-email-vfalico@redhat.com>
References: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756195Ab3HFR6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 13:58:41 -0400
In-Reply-To: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new exported function __vlan_find_dev_next_id(dev, vlan_id), which
returns the a vlan id that is used by the dev and is greater or equal to
vlan_id.

This function must be under rcu_read_lock(), is aware of master devices and
doesn't guarantee that, once it returns, the vlan id will still be used.

It's basically a helper for "for_each_vlan_in_dev(dev, vlan_dev)" logic,
and is supposed to be used like this:

vlan_id = 0;

while ((vlan_id = __vlan_find_dev_next_id(dev, vlan_id+1))) {
	vlan_dev = __vlan_find_dev_deep(dev, htons(ETH_P_8021Q), vlan_id);
	if (!vlan_dev)
		continue;

	do_work(vlan_dev);
}

In that case we're sure that vlan_dev at least was used as a vlan, after
__vlan_find_dev_deep() returns, and won't go away while we're holding
rcu_read_lock().

However, if we don't hold rtnl_lock(), we can't be sure that that vlan_dev
is still in dev's vlan_list.

CC: Patrick McHardy <kaber@trash.net>
CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/if_vlan.h |    6 ++++++
 net/8021q/vlan_core.c   |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 1fcea36..a69219b 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -86,6 +86,7 @@ static inline int is_vlan_dev(struct net_device *dev)
 
 extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 					       __be16 vlan_proto, u16 vlan_id);
+extern u16 __vlan_find_dev_next_id(struct net_device *dev, u16 vlan_id);
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
@@ -110,6 +111,11 @@ __vlan_find_dev_deep(struct net_device *real_dev,
 	return NULL;
 }
 
+static inline u16 __vlan_find_dev_next_id(struct net_device *dev, u16 vlan_id)
+{
+	return 0;
+}
+
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	BUG();
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 52e3fb3..4e9ff3f 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -89,6 +89,42 @@ struct net_device *__vlan_find_dev_deep(struct net_device *dev,
 }
 EXPORT_SYMBOL(__vlan_find_dev_deep);
 
+#define vlan_group_for_each_from(grp, i, from) \
+	for ((i) = from; i < VLAN_PROTO_NUM * VLAN_N_VID; i++) \
+		if (__vlan_group_get_device((grp), (i) / VLAN_N_VID, \
+						   (i) % VLAN_N_VID))
+
+/* Must be called under rcu_read_lock(), returns next vlan_id used by a
+ * vlan device on dev, starting with vlan_id, or 0 if no vlan_id found.
+ */
+u16 __vlan_find_dev_next_id(struct net_device *dev, u16 vlan_id)
+{
+	struct net_device *real_dev = dev, *master_dev;
+	struct vlan_info *vlan_info;
+	struct vlan_group *grp;
+	u16 i;
+
+	BUG_ON(vlan_id >= VLAN_PROTO_NUM * VLAN_N_VID);
+
+	master_dev = netdev_master_upper_dev_get_rcu(real_dev);
+
+	if (master_dev)
+		real_dev = master_dev;
+
+	vlan_info = rcu_dereference(real_dev->vlan_info);
+
+	if (!vlan_info)
+		return 0;
+
+	grp = &vlan_info->grp;
+
+	vlan_group_for_each_from(grp, i, vlan_id)
+		return i;
+
+	return 0;
+}
+EXPORT_SYMBOL(__vlan_find_dev_next_id);
+
 struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	return vlan_dev_priv(dev)->real_dev;
-- 
1.7.1
