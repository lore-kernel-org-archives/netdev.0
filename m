From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 4/6] tcp_memcontrol: Kill struct tcp_memcontrol
Date: Sat, 19 Oct 2013 16:26:19 -0700
Message-ID: <871u3ghmg4.fsf@xmission.com>
References: <87r4bghml4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r4bghml4.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Sat, 19 Oct 2013 16:23:19 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


Replace the pointers in struct cg_proto with actual data fields and kill
struct tcp_memcontrol as it is not fully redundant.

This removes a confusing, unnecessary layer of abstraction.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/sock.h           |   28 +++++++++---------
 include/net/tcp_memcontrol.h |   10 -------
 mm/memcontrol.c              |    6 ++--
 net/ipv4/tcp_memcontrol.c    |   61 ++++++++++++-----------------------------
 4 files changed, 35 insertions(+), 70 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7e50df5c71d4..86bb0668c581 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1036,10 +1036,10 @@ enum cg_proto_flags {
 
 struct cg_proto {
 	void			(*enter_memory_pressure)(struct sock *sk);
-	struct res_counter	*memory_allocated;	/* Current allocated memory. */
-	struct percpu_counter	*sockets_allocated;	/* Current number of sockets. */
-	int			*memory_pressure;
-	long			*sysctl_mem;
+	struct res_counter	memory_allocated;	/* Current allocated memory. */
+	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
+	int			memory_pressure;
+	long			sysctl_mem[3];
 	unsigned long		flags;
 	/*
 	 * memcg field is used to find which memcg we belong directly
@@ -1135,9 +1135,9 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
 		return false;
 
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return !!*sk->sk_cgrp->memory_pressure;
+		return !!sk->sk_cgrp->memory_pressure;
 
-	return !!*sk->sk_prot->memory_pressure;
+	return !!sk->sk_prot->memory_pressure;
 }
 
 static inline void sk_leave_memory_pressure(struct sock *sk)
@@ -1155,8 +1155,8 @@ static inline void sk_leave_memory_pressure(struct sock *sk)
 		struct proto *prot = sk->sk_prot;
 
 		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			if (*cg_proto->memory_pressure)
-				*cg_proto->memory_pressure = 0;
+			if (cg_proto->memory_pressure)
+				cg_proto->memory_pressure = 0;
 	}
 
 }
@@ -1192,7 +1192,7 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 	struct res_counter *fail;
 	int ret;
 
-	ret = res_counter_charge_nofail(prot->memory_allocated,
+	ret = res_counter_charge_nofail(&prot->memory_allocated,
 					amt << PAGE_SHIFT, &fail);
 	if (ret < 0)
 		*parent_status = OVER_LIMIT;
@@ -1201,13 +1201,13 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
 					      unsigned long amt)
 {
-	res_counter_uncharge(prot->memory_allocated, amt << PAGE_SHIFT);
+	res_counter_uncharge(&prot->memory_allocated, amt << PAGE_SHIFT);
 }
 
 static inline u64 memcg_memory_allocated_read(struct cg_proto *prot)
 {
 	u64 ret;
-	ret = res_counter_read_u64(prot->memory_allocated, RES_USAGE);
+	ret = res_counter_read_u64(&prot->memory_allocated, RES_USAGE);
 	return ret >> PAGE_SHIFT;
 }
 
@@ -1255,7 +1255,7 @@ static inline void sk_sockets_allocated_dec(struct sock *sk)
 		struct cg_proto *cg_proto = sk->sk_cgrp;
 
 		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			percpu_counter_dec(cg_proto->sockets_allocated);
+			percpu_counter_dec(&cg_proto->sockets_allocated);
 	}
 
 	percpu_counter_dec(prot->sockets_allocated);
@@ -1269,7 +1269,7 @@ static inline void sk_sockets_allocated_inc(struct sock *sk)
 		struct cg_proto *cg_proto = sk->sk_cgrp;
 
 		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			percpu_counter_inc(cg_proto->sockets_allocated);
+			percpu_counter_inc(&cg_proto->sockets_allocated);
 	}
 
 	percpu_counter_inc(prot->sockets_allocated);
@@ -1281,7 +1281,7 @@ sk_sockets_allocated_read_positive(struct sock *sk)
 	struct proto *prot = sk->sk_prot;
 
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return percpu_counter_read_positive(sk->sk_cgrp->sockets_allocated);
+		return percpu_counter_read_positive(&sk->sk_cgrp->sockets_allocated);
 
 	return percpu_counter_read_positive(prot->sockets_allocated);
 }
diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index af0c0680a873..05b94d9453de 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -1,16 +1,6 @@
 #ifndef _TCP_MEMCG_H
 #define _TCP_MEMCG_H
 
-struct tcp_memcontrol {
-	struct cg_proto cg_proto;
-	/* per-cgroup tcp memory pressure knobs */
-	struct res_counter tcp_memory_allocated;
-	struct percpu_counter tcp_sockets_allocated;
-	/* those two are read-mostly, leave them at the end */
-	long tcp_prot_mem[3];
-	int tcp_memory_pressure;
-};
-
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
 void tcp_destroy_cgroup(struct mem_cgroup *memcg);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1c52ddbc839b..28243f7d9c23 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -311,7 +311,7 @@ struct mem_cgroup {
 
 	atomic_t	dead_count;
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
-	struct tcp_memcontrol tcp_mem;
+	struct cg_proto tcp_mem;
 #endif
 #if defined(CONFIG_MEMCG_KMEM)
 	/* analogous to slab_common's slab_caches list. per-memcg */
@@ -550,13 +550,13 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
 	if (!memcg || mem_cgroup_is_root(memcg))
 		return NULL;
 
-	return &memcg->tcp_mem.cg_proto;
+	return &memcg->tcp_mem;
 }
 EXPORT_SYMBOL(tcp_proto_cgroup);
 
 static void disarm_sock_keys(struct mem_cgroup *memcg)
 {
-	if (!memcg_proto_activated(&memcg->tcp_mem.cg_proto))
+	if (!memcg_proto_activated(&memcg->tcp_mem))
 		return;
 	static_key_slow_dec(&memcg_socket_limit_enabled);
 }
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 86feaa0d6d70..03e9154f7e68 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -6,15 +6,10 @@
 #include <linux/memcontrol.h>
 #include <linux/module.h>
 
-static inline struct tcp_memcontrol *tcp_from_cgproto(struct cg_proto *cg_proto)
-{
-	return container_of(cg_proto, struct tcp_memcontrol, cg_proto);
-}
-
 static void memcg_tcp_enter_memory_pressure(struct sock *sk)
 {
 	if (sk->sk_cgrp->memory_pressure)
-		*sk->sk_cgrp->memory_pressure = 1;
+		sk->sk_cgrp->memory_pressure = 1;
 }
 EXPORT_SYMBOL(memcg_tcp_enter_memory_pressure);
 
@@ -27,33 +22,24 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	 */
 	struct res_counter *res_parent = NULL;
 	struct cg_proto *cg_proto, *parent_cg;
-	struct tcp_memcontrol *tcp;
 	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
 		return 0;
 
-	tcp = tcp_from_cgproto(cg_proto);
-
-	tcp->tcp_prot_mem[0] = sysctl_tcp_mem[0];
-	tcp->tcp_prot_mem[1] = sysctl_tcp_mem[1];
-	tcp->tcp_prot_mem[2] = sysctl_tcp_mem[2];
-	tcp->tcp_memory_pressure = 0;
+	cg_proto->sysctl_mem[0] = sysctl_tcp_mem[0];
+	cg_proto->sysctl_mem[1] = sysctl_tcp_mem[1];
+	cg_proto->sysctl_mem[2] = sysctl_tcp_mem[2];
+	cg_proto->memory_pressure = 0;
+	cg_proto->memcg = memcg;
 
 	parent_cg = tcp_prot.proto_cgroup(parent);
 	if (parent_cg)
-		res_parent = parent_cg->memory_allocated;
-
-	res_counter_init(&tcp->tcp_memory_allocated, res_parent);
-	percpu_counter_init(&tcp->tcp_sockets_allocated, 0);
+		res_parent = &parent_cg->memory_allocated;
 
-	cg_proto->enter_memory_pressure = memcg_tcp_enter_memory_pressure;
-	cg_proto->memory_pressure = &tcp->tcp_memory_pressure;
-	cg_proto->sysctl_mem = tcp->tcp_prot_mem;
-	cg_proto->memory_allocated = &tcp->tcp_memory_allocated;
-	cg_proto->sockets_allocated = &tcp->tcp_sockets_allocated;
-	cg_proto->memcg = memcg;
+	res_counter_init(&cg_proto->memory_allocated, res_parent);
+	percpu_counter_init(&cg_proto->sockets_allocated, 0);
 
 	return 0;
 }
@@ -62,20 +48,17 @@ EXPORT_SYMBOL(tcp_init_cgroup);
 void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 {
 	struct cg_proto *cg_proto;
-	struct tcp_memcontrol *tcp;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
 		return;
 
-	tcp = tcp_from_cgproto(cg_proto);
-	percpu_counter_destroy(&tcp->tcp_sockets_allocated);
+	percpu_counter_destroy(&cg_proto->sockets_allocated);
 }
 EXPORT_SYMBOL(tcp_destroy_cgroup);
 
 static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 {
-	struct tcp_memcontrol *tcp;
 	struct cg_proto *cg_proto;
 	u64 old_lim;
 	int i;
@@ -88,16 +71,14 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 	if (val > RES_COUNTER_MAX)
 		val = RES_COUNTER_MAX;
 
-	tcp = tcp_from_cgproto(cg_proto);
-
-	old_lim = res_counter_read_u64(&tcp->tcp_memory_allocated, RES_LIMIT);
-	ret = res_counter_set_limit(&tcp->tcp_memory_allocated, val);
+	old_lim = res_counter_read_u64(&cg_proto->memory_allocated, RES_LIMIT);
+	ret = res_counter_set_limit(&cg_proto->memory_allocated, val);
 	if (ret)
 		return ret;
 
 	for (i = 0; i < 3; i++)
-		tcp->tcp_prot_mem[i] = min_t(long, val >> PAGE_SHIFT,
-					     sysctl_tcp_mem[i]);
+		cg_proto->sysctl_mem[i] = min_t(long, val >> PAGE_SHIFT,
+						sysctl_tcp_mem[i]);
 
 	if (val == RES_COUNTER_MAX)
 		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
@@ -154,28 +135,24 @@ static int tcp_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
 
 static u64 tcp_read_stat(struct mem_cgroup *memcg, int type, u64 default_val)
 {
-	struct tcp_memcontrol *tcp;
 	struct cg_proto *cg_proto;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
 		return default_val;
 
-	tcp = tcp_from_cgproto(cg_proto);
-	return res_counter_read_u64(&tcp->tcp_memory_allocated, type);
+	return res_counter_read_u64(&cg_proto->memory_allocated, type);
 }
 
 static u64 tcp_read_usage(struct mem_cgroup *memcg)
 {
-	struct tcp_memcontrol *tcp;
 	struct cg_proto *cg_proto;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
 		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
 
-	tcp = tcp_from_cgproto(cg_proto);
-	return res_counter_read_u64(&tcp->tcp_memory_allocated, RES_USAGE);
+	return res_counter_read_u64(&cg_proto->memory_allocated, RES_USAGE);
 }
 
 static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
@@ -203,21 +180,19 @@ static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
 static int tcp_cgroup_reset(struct cgroup_subsys_state *css, unsigned int event)
 {
 	struct mem_cgroup *memcg;
-	struct tcp_memcontrol *tcp;
 	struct cg_proto *cg_proto;
 
 	memcg = mem_cgroup_from_css(css);
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
 		return 0;
-	tcp = tcp_from_cgproto(cg_proto);
 
 	switch (event) {
 	case RES_MAX_USAGE:
-		res_counter_reset_max(&tcp->tcp_memory_allocated);
+		res_counter_reset_max(&cg_proto->memory_allocated);
 		break;
 	case RES_FAILCNT:
-		res_counter_reset_failcnt(&tcp->tcp_memory_allocated);
+		res_counter_reset_failcnt(&cg_proto->memory_allocated);
 		break;
 	}
 
-- 
1.7.5.4
