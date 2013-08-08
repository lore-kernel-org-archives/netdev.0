From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 2/6] vlan: add __vlan_find_dev_next()
Date: Thu,  8 Aug 2013 18:57:55 +0200
Message-ID: <1375981079-2936-3-git-send-email-vfalico@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757864Ab3HHQ5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 12:57:47 -0400
In-Reply-To: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC -> v1: make the function accept/return vlan's net_device, this way we
	   won't have troubles with VLAN 0, and the user code will be
	   cleaner and faster.
v1  -> v2: don't check for the master device - if we'll want in the future
	   to convert a slave device - it will fail, but now we don't
	   actually care.

Add a new exported function __vlan_find_dev_next(dev, vlan_dev), which
returns the a vlan's net_device that is used by the dev and is its id is
greater or equal to vlan_dev's vlan id. If vlan_dev is NULL, return first
vlan, if nothing is found return NULL.

This function must be under rcu_read_lock(), is aware of master devices and
doesn't guarantee that, once it returns, the vlan dev will still be used by
dev as its vlan.

It's basically a helper for "for_each_vlan_in_dev(dev, vlan_dev)" logic,
and is supposed to be used like this:

vlan_dev = NULL;

while ((vlan_dev = __vlan_find_dev_next(dev, vlan_dev))) {
	if (!vlan_dev)
		continue;

	do_work(vlan_dev);
}

In that case we're sure that vlan_dev at least was used as a vlan, and won't
go away while we're holding rcu_read_lock().

However, if we don't hold rtnl_lock(), we can't be sure that that vlan_dev
is still in dev's vlan_list.

CC: Patrick McHardy <kaber@trash.net>
CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/if_vlan.h |    8 ++++++++
 net/8021q/vlan.h        |    6 ++++--
 net/8021q/vlan_core.c   |   28 ++++++++++++++++++++++++++++
 3 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 715c343..1cfc201 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -86,6 +86,8 @@ static inline int is_vlan_dev(struct net_device *dev)
 
 extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 					       __be16 vlan_proto, u16 vlan_id);
+extern struct net_device *__vlan_find_dev_next(struct net_device *dev,
+					       struct net_device *vlan_dev);
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
@@ -109,6 +111,12 @@ __vlan_find_dev_deep(struct net_device *real_dev,
 	return NULL;
 }
 
+static struct net_device *__vlan_find_dev_next(struct net_device *dev,
+					       struct net_device *vlan_dev)
+{
+	return NULL;
+}
+
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	BUG();
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index ba5983f..e13aeac 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -168,10 +168,12 @@ static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
 	return NULL;
 }
 
-#define vlan_group_for_each_dev(grp, i, dev) \
-	for ((i) = 0; i < VLAN_PROTO_NUM * VLAN_N_VID; i++) \
+#define vlan_group_for_each_dev_from(grp, i, dev, from) \
+	for ((i) = from; i < VLAN_PROTO_NUM * VLAN_N_VID; i++) \
 		if (((dev) = __vlan_group_get_device((grp), (i) / VLAN_N_VID, \
 							    (i) % VLAN_N_VID)))
+#define vlan_group_for_each_dev(grp, i, dev) \
+	vlan_group_for_each_dev_from(grp, i, dev, 0)
 
 /* found in vlan_dev.c */
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 361c97b..c0031c3 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -89,6 +89,34 @@ struct net_device *__vlan_find_dev_deep(struct net_device *dev,
 }
 EXPORT_SYMBOL(__vlan_find_dev_deep);
 
+/* Must be called under rcu_read_lock(), returns next vlan_id used by a
+ * vlan device on dev, starting with vlan_id, or 0 if no vlan_id found.
+ */
+struct net_device *__vlan_find_dev_next(struct net_device *dev,
+					struct net_device *vlan_dev)
+{
+	struct net_device *ret;
+	struct vlan_info *vlan_info;
+	struct vlan_group *grp;
+	u16 vlan_id = 0, i;
+
+	if (vlan_dev)
+		vlan_id = vlan_dev_priv(vlan_dev)->vlan_id + 1;
+
+	vlan_info = rcu_dereference(dev->vlan_info);
+
+	if (!vlan_info)
+		return NULL;
+
+	grp = &vlan_info->grp;
+
+	vlan_group_for_each_dev_from(grp, i, ret, vlan_id)
+		return ret;
+
+	return NULL;
+}
+EXPORT_SYMBOL(__vlan_find_dev_next);
+
 struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	return vlan_dev_priv(dev)->real_dev;
-- 
1.7.1
