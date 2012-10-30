From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v8 15/16] openvswitch: use new hashtable
	implementation
Date: Tue, 30 Oct 2012 14:46:11 -0400
Message-ID: <1351622772-16400-15-git-send-email-levinsasha928@gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1351622772-16400-1-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Switch openvswitch to use the new hashtable implementation. This reduces the
amount of generic unrelated code in openvswitch.

Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/vport.c | 35 ++++++++++++-----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 03779e8..20fdbd4 100644
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
1.7.12.4
