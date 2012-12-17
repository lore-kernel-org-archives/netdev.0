From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 14/15] openvswitch: use new hashtable implementation
Date: Mon, 17 Dec 2012 10:01:34 -0500
Message-ID: <1355756497-15834-14-git-send-email-sasha.levin@oracle.com>
References: <1355756497-15834-1-git-send-email-sasha.levin@oracle.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
To: Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, dev@openvswitch.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355756497-15834-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch openvswitch to use the new hashtable implementation. This reduces the
amount of generic unrelated code in openvswitch.

This patch depends on d9b482c ("hashtable: introduce a small and naive
hashtable") which was merged in v3.6.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/openvswitch/vport.c | 35 ++++++++++++-----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 70af0be..a946529 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -28,6 +28,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/compat.h>
 #include <net/net_namespace.h>
+#include <linux/hashtable.h>
 
 #include "datapath.h"
 #include "vport.h"
@@ -41,8 +42,8 @@ static const struct vport_ops *vport_ops_list[] = {
 };
 
 /* Protected by RCU read lock for reading, RTNL lock for writing. */
-static struct hlist_head *dev_table;
-#define VPORT_HASH_BUCKETS 1024
+#define VPORT_HASH_BITS 10
+static DEFINE_HASHTABLE(dev_table, VPORT_HASH_BITS);
 
 /**
  *	ovs_vport_init - initialize vport subsystem
@@ -51,11 +52,6 @@ static struct hlist_head *dev_table;
  */
 int ovs_vport_init(void)
 {
-	dev_table = kzalloc(VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
-			    GFP_KERNEL);
-	if (!dev_table)
-		return -ENOMEM;
-
 	return 0;
 }
 
@@ -66,13 +62,6 @@ int ovs_vport_init(void)
  */
 void ovs_vport_exit(void)
 {
-	kfree(dev_table);
-}
-
-static struct hlist_head *hash_bucket(struct net *net, const char *name)
-{
-	unsigned int hash = jhash(name, strlen(name), (unsigned long) net);
-	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
 }
 
 /**
@@ -84,13 +73,12 @@ static struct hlist_head *hash_bucket(struct net *net, const char *name)
  */
 struct vport *ovs_vport_locate(struct net *net, const char *name)
 {
-	struct hlist_head *bucket = hash_bucket(net, name);
 	struct vport *vport;
 	struct hlist_node *node;
+	int key = full_name_hash(name, strlen(name));
 
-	hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
-		if (!strcmp(name, vport->ops->get_name(vport)) &&
-		    net_eq(ovs_dp_get_net(vport->dp), net))
+	hash_for_each_possible_rcu(dev_table, vport, node, hash_node, key)
+		if (!strcmp(name, vport->ops->get_name(vport)))
 			return vport;
 
 	return NULL;
@@ -174,7 +162,8 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
 
 	for (i = 0; i < ARRAY_SIZE(vport_ops_list); i++) {
 		if (vport_ops_list[i]->type == parms->type) {
-			struct hlist_head *bucket;
+			int key;
+			const char *name;
 
 			vport = vport_ops_list[i]->create(parms);
 			if (IS_ERR(vport)) {
@@ -182,9 +171,9 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
 				goto out;
 			}
 
-			bucket = hash_bucket(ovs_dp_get_net(vport->dp),
-					     vport->ops->get_name(vport));
-			hlist_add_head_rcu(&vport->hash_node, bucket);
+			name = vport->ops->get_name(vport);
+			key = full_name_hash(name, strlen(name));
+			hash_add_rcu(dev_table, &vport->hash_node, key);
 			return vport;
 		}
 	}
@@ -225,7 +214,7 @@ void ovs_vport_del(struct vport *vport)
 {
 	ASSERT_RTNL();
 
-	hlist_del_rcu(&vport->hash_node);
+	hash_del_rcu(&vport->hash_node);
 
 	vport->ops->destroy(vport);
 }
-- 
1.8.0
