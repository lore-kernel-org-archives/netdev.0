From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 1/2] net: fix sleeping while atomic problem in sock mem_cgroup.
Date: Fri, 16 Dec 2011 14:51:59 +0400
Message-ID: <1324032720-13752-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We can't scan the proto_list to initialize sock cgroups, as it
holds a rwlock, and we also want to keep the code generic enough to
avoid calling the initialization functions of protocols directly,

Convert proto_list_lock into a mutex, so we can sleep and do the
necessary allocations. This lock is seldom taken, so there shouldn't
be any performance penalties associated with that

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
CC: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
---
 net/core/sock.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 5a6a906..0c67fac 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -136,7 +136,7 @@
 #include <net/tcp.h>
 #endif
 
-static DEFINE_RWLOCK(proto_list_lock);
+static DEFINE_MUTEX(proto_list_mutex);
 static LIST_HEAD(proto_list);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
@@ -145,7 +145,7 @@ int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	struct proto *proto;
 	int ret = 0;
 
-	read_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	list_for_each_entry(proto, &proto_list, node) {
 		if (proto->init_cgroup) {
 			ret = proto->init_cgroup(cgrp, ss);
@@ -154,13 +154,13 @@ int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss)
 		}
 	}
 
-	read_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 	return ret;
 out:
 	list_for_each_entry_continue_reverse(proto, &proto_list, node)
 		if (proto->destroy_cgroup)
 			proto->destroy_cgroup(cgrp, ss);
-	read_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 	return ret;
 }
 
@@ -168,11 +168,11 @@ void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss)
 {
 	struct proto *proto;
 
-	read_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	list_for_each_entry_reverse(proto, &proto_list, node)
 		if (proto->destroy_cgroup)
 			proto->destroy_cgroup(cgrp, ss);
-	read_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 }
 #endif
 
@@ -2479,10 +2479,10 @@ int proto_register(struct proto *prot, int alloc_slab)
 		}
 	}
 
-	write_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	list_add(&prot->node, &proto_list);
 	assign_proto_idx(prot);
-	write_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 	return 0;
 
 out_free_timewait_sock_slab_name:
@@ -2505,10 +2505,10 @@ EXPORT_SYMBOL(proto_register);
 
 void proto_unregister(struct proto *prot)
 {
-	write_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	release_proto_idx(prot);
 	list_del(&prot->node);
-	write_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 
 	if (prot->slab != NULL) {
 		kmem_cache_destroy(prot->slab);
@@ -2531,9 +2531,9 @@ EXPORT_SYMBOL(proto_unregister);
 
 #ifdef CONFIG_PROC_FS
 static void *proto_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(proto_list_lock)
+	__acquires(proto_list_mutex)
 {
-	read_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	return seq_list_start_head(&proto_list, *pos);
 }
 
@@ -2543,9 +2543,9 @@ static void *proto_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void proto_seq_stop(struct seq_file *seq, void *v)
-	__releases(proto_list_lock)
+	__releases(proto_list_mutex)
 {
-	read_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 }
 
 static char proto_method_implemented(const void *method)
-- 
1.7.6.4

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
