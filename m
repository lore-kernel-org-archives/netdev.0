From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 2/2] Explicitly call tcp creation and init from memcontrol.c
Date: Thu, 15 Dec 2011 13:34:32 +0400
Message-ID: <1323941672-14324-3-git-send-email-glommer@parallels.com>
References: <1323941672-14324-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323941672-14324-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Walking the proto_list holds a read_lock, which prevents us from doing
allocations. Splitting the tcp create function into create + init is
good, but it is not enough since create_files will do allocations as well
(dentry ones, mostly).

Since this does not involve any protocol state, I propose we call the tcp
functions explicitly from memcontrol.c

With this, we lose by now the ability of doing cgroup memcontrol for
protocols that are loaded as modules. But at least the ones I have in mind
won't really need it (tcp_ipv6 being the only one, but it uses the same data
structures as tcp_ipv4). So I believe this to be the simpler solution to this
problem.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
---
 include/net/sock.h           |    2 --
 include/net/tcp_memcontrol.h |   19 ++++++++++++++++++-
 mm/memcontrol.c              |   13 ++++---------
 net/core/sock.c              |   37 -------------------------------------
 net/ipv4/tcp_memcontrol.c    |   11 ++++++-----
 5 files changed, 28 insertions(+), 54 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1df44e2..6cbee80 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -64,8 +64,6 @@
 #include <net/dst.h>
 #include <net/checksum.h>
 
-int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss);
-void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss);
 /*
  * This structure really needs to be cleaned up.
  * Most of it is for TCP, and not used by any of
diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index 3512082..f1ff94a 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -11,9 +11,26 @@ struct tcp_memcontrol {
 	int tcp_memory_pressure;
 };
 
-struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
+struct cgroup;
+struct cgroup_subsys;
+#if defined(CONFIG_INET) && defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
 int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
 void tcp_destroy_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
+void tcp_create_cgroup(struct mem_cgroup *memcg, struct mem_cgroup *parent);
+#else
+static inline int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+	return 0;
+}
+static inline void tcp_destroy_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+}
+static inline void
+tcp_create_cgroup(struct mem_cgroup *memcg, struct mem_cgroup *parent)
+{
+}
+#endif
+struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
 unsigned long long tcp_max_memory(const struct mem_cgroup *memcg);
 void tcp_prot_mem(struct mem_cgroup *memcg, long val, int idx);
 #endif /* _TCP_MEMCG_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7266202..e3d8886 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4749,22 +4749,15 @@ static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
 	ret = cgroup_add_files(cont, ss, kmem_cgroup_files,
 			       ARRAY_SIZE(kmem_cgroup_files));
 
-	/*
-	 * Part of this would be better living in a separate allocation
-	 * function, leaving us with just the cgroup tree population work.
-	 * We, however, depend on state such as network's proto_list that
-	 * is only initialized after cgroup creation. I found the less
-	 * cumbersome way to deal with it to defer it all to populate time
-	 */
 	if (!ret)
-		ret = mem_cgroup_sockets_init(cont, ss);
+		tcp_init_cgroup(cont, ss);
 	return ret;
 };
 
 static void kmem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	mem_cgroup_sockets_destroy(cont, ss);
+	tcp_destroy_cgroup(cont, ss);
 }
 #else
 static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
@@ -5093,6 +5086,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		res_counter_init(&memcg->res, &parent->res);
 		res_counter_init(&memcg->memsw, &parent->memsw);
 		res_counter_init(&memcg->kmem, &parent->kmem);
+		tcp_create_cgroup(memcg, parent);
 		/*
 		 * We increment refcnt of the parent to ensure that we can
 		 * safely access it on res_counter_charge/uncharge.
@@ -5104,6 +5098,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
 		res_counter_init(&memcg->kmem, NULL);
+		tcp_create_cgroup(memcg, NULL);
 	}
 	memcg->last_scanned_child = 0;
 	memcg->last_scanned_node = MAX_NUMNODES;
diff --git a/net/core/sock.c b/net/core/sock.c
index 5de62d3..103f246 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -138,43 +138,6 @@
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
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 171d7b6..1433505 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -49,7 +49,7 @@ static void memcg_tcp_enter_memory_pressure(struct sock *sk)
 }
 EXPORT_SYMBOL(memcg_tcp_enter_memory_pressure);
 
-int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
+void tcp_create_cgroup(struct mem_cgroup *memcg, struct mem_cgroup *parent)
 {
 	/*
 	 * The root cgroup does not use res_counters, but rather,
@@ -59,13 +59,11 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	struct res_counter *res_parent = NULL;
 	struct cg_proto *cg_proto, *parent_cg;
 	struct tcp_memcontrol *tcp;
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
 	struct net *net = current->nsproxy->net_ns;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
-		goto create_files;
+		return;
 
 	tcp = tcp_from_cgproto(cg_proto);
 
@@ -87,8 +85,11 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	cg_proto->memory_allocated = &tcp->tcp_memory_allocated;
 	cg_proto->sockets_allocated = &tcp->tcp_sockets_allocated;
 	cg_proto->memcg = memcg;
+}
+EXPORT_SYMBOL(tcp_create_cgroup);
 
-create_files:
+int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
 	return cgroup_add_files(cgrp, ss, tcp_files,
 				ARRAY_SIZE(tcp_files));
 }
-- 
1.7.6.4

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
