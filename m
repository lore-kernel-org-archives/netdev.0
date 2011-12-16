From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2] net: fix sleeping while atomic problem in sock mem_cgroup.
Date: Fri, 16 Dec 2011 13:09:42 +0400
Message-ID: <1324026582-5214-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since we can't scan the proto_list to initialize sock cgroups, as it
holds a rwlock, and we also want to keep the code generic enough to
avoid calling the initialization functions of protocols directly,
I propose we keep the interested parties in a separate list. This list
is protected by a mutex so we can sleep and do the necessary allocations.

Also fixes a reference problem found by Randy Dunlap's randconfig.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
CC: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
---
 include/linux/memcontrol.h   |   11 ++++++-
 include/net/sock.h           |    5 +---
 include/net/tcp_memcontrol.h |    2 +
 mm/memcontrol.c              |   58 ++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c              |   42 +++--------------------------
 5 files changed, 75 insertions(+), 43 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9b296ea..e61fabb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -390,11 +390,13 @@ enum {
 	OVER_LIMIT,
 };
 
-#ifdef CONFIG_INET
+struct proto;
 struct sock;
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
 void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
+void register_sock_cgroup(struct proto *prot);
+void unregister_sock_cgroup(struct proto *prot);
 #else
 static inline void sock_update_memcg(struct sock *sk)
 {
@@ -402,7 +404,12 @@ static inline void sock_update_memcg(struct sock *sk)
 static inline void sock_release_memcg(struct sock *sk)
 {
 }
+static inline void register_sock_cgroup(struct proto *prot)
+{
+}
+static inline void unregister_sock_cgroup(struct proto *prot)
+{
+}
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
-#endif /* CONFIG_INET */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 6fe0dae..f8237a3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -64,10 +64,6 @@
 #include <net/dst.h>
 #include <net/checksum.h>
 
-struct cgroup;
-struct cgroup_subsys;
-int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss);
-void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss);
 /*
  * This structure really needs to be cleaned up.
  * Most of it is for TCP, and not used by any of
@@ -858,6 +854,7 @@ struct proto {
 	void			(*destroy_cgroup)(struct cgroup *cgrp,
 						  struct cgroup_subsys *ss);
 	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
+	struct list_head	cgroup_node;
 #endif
 };
 
diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index 3512082..5aa7c4b 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -11,6 +11,8 @@ struct tcp_memcontrol {
 	int tcp_memory_pressure;
 };
 
+struct cgroup;
+struct cgroup_subsys;
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
 int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
 void tcp_destroy_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7266202..1098afe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4742,6 +4742,64 @@ static struct cftype kmem_cgroup_files[] = {
 	},
 };
 
+static DEFINE_MUTEX(cgroup_proto_list_lock);
+static LIST_HEAD(cgroup_proto_list);
+
+static int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+	struct proto *proto;
+	int ret = 0;
+
+	mutex_lock(&cgroup_proto_list_lock);
+	list_for_each_entry(proto, &cgroup_proto_list, cgroup_node) {
+		if (proto->init_cgroup) {
+			ret = proto->init_cgroup(cgrp, ss);
+			if (ret)
+				goto out;
+		}
+	}
+
+	mutex_unlock(&cgroup_proto_list_lock);
+	return ret;
+out:
+	list_for_each_entry_continue_reverse(proto, &cgroup_proto_list, cgroup_node)
+		if (proto->destroy_cgroup)
+			proto->destroy_cgroup(cgrp, ss);
+	mutex_unlock(&cgroup_proto_list_lock);
+	return ret;
+}
+
+static void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+	struct proto *proto;
+
+	mutex_lock(&cgroup_proto_list_lock);
+	list_for_each_entry_reverse(proto, &cgroup_proto_list, cgroup_node)
+		if (proto->destroy_cgroup)
+			proto->destroy_cgroup(cgrp, ss);
+	mutex_unlock(&cgroup_proto_list_lock);
+}
+
+void register_sock_cgroup(struct proto *prot)
+{
+	if (!prot->proto_cgroup)
+		return;
+
+	mutex_lock(&cgroup_proto_list_lock);
+	list_add(&prot->cgroup_node, &cgroup_proto_list);
+	mutex_unlock(&cgroup_proto_list_lock);
+}
+
+void unregister_sock_cgroup(struct proto *prot)
+{
+	if (!prot->proto_cgroup)
+		return;
+
+	mutex_lock(&cgroup_proto_list_lock);
+	list_del(&prot->cgroup_node);
+	mutex_unlock(&cgroup_proto_list_lock);
+}
+
 static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
 {
 	int ret = 0;
diff --git a/net/core/sock.c b/net/core/sock.c
index 5a6a906..5a56a55 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -139,43 +139,6 @@
 static DEFINE_RWLOCK(proto_list_lock);
 static LIST_HEAD(proto_list);
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
-int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss)
-{
-	struct proto *proto;
-	int ret = 0;
-
-	read_lock(&proto_list_lock);
-	list_for_each_entry(proto, &proto_list, node) {
-		if (proto->init_cgroup) {
-			ret = proto->init_cgroup(cgrp, ss);
-			if (ret)
-				goto out;
-		}
-	}
-
-	read_unlock(&proto_list_lock);
-	return ret;
-out:
-	list_for_each_entry_continue_reverse(proto, &proto_list, node)
-		if (proto->destroy_cgroup)
-			proto->destroy_cgroup(cgrp, ss);
-	read_unlock(&proto_list_lock);
-	return ret;
-}
-
-void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss)
-{
-	struct proto *proto;
-
-	read_lock(&proto_list_lock);
-	list_for_each_entry_reverse(proto, &proto_list, node)
-		if (proto->destroy_cgroup)
-			proto->destroy_cgroup(cgrp, ss);
-	read_unlock(&proto_list_lock);
-}
-#endif
-
 /*
  * Each address family might have different locking rules, so we have
  * one slock key per address family:
@@ -2483,6 +2446,9 @@ int proto_register(struct proto *prot, int alloc_slab)
 	list_add(&prot->node, &proto_list);
 	assign_proto_idx(prot);
 	write_unlock(&proto_list_lock);
+
+	register_sock_cgroup(prot);
+
 	return 0;
 
 out_free_timewait_sock_slab_name:
@@ -2510,6 +2476,8 @@ void proto_unregister(struct proto *prot)
 	list_del(&prot->node);
 	write_unlock(&proto_list_lock);
 
+	unregister_sock_cgroup(prot);
+
 	if (prot->slab != NULL) {
 		kmem_cache_destroy(prot->slab);
 		prot->slab = NULL;
-- 
1.7.6.4

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
