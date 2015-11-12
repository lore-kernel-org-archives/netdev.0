From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 07/14] net: tcp_memcontrol: simplify the per-memcg limit access
Date: Thu, 12 Nov 2015 18:41:26 -0500
Message-ID: <1447371693-25143-8-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>,
	Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tcp_memcontrol replicates the global sysctl_mem limit array per
cgroup, but it only ever sets these entries to the value of the
memory_allocated page_counter limit. Use the latter directly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 1 -
 include/net/sock.h         | 8 +++++---
 net/ipv4/tcp_memcontrol.c  | 8 --------
 3 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 185df8c..96ca3d3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -98,7 +98,6 @@ enum cg_proto_flags {
 struct cg_proto {
 	struct page_counter	memory_allocated;	/* Current allocated memory. */
 	int			memory_pressure;
-	long			sysctl_mem[3];
 	unsigned long		flags;
 	/*
 	 * memcg field is used to find which memcg we belong directly
diff --git a/include/net/sock.h b/include/net/sock.h
index ed141b3..2eefc99 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1159,10 +1159,12 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
 
 static inline long sk_prot_mem_limits(const struct sock *sk, int index)
 {
-	long *prot = sk->sk_prot->sysctl_mem;
+	long limit = sk->sk_prot->sysctl_mem[index];
+
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		prot = sk->sk_cgrp->sysctl_mem;
-	return prot[index];
+		limit = min_t(long, limit, sk->sk_cgrp->memory_allocated.limit);
+
+	return limit;
 }
 
 static inline void memcg_memory_allocated_add(struct cg_proto *prot,
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 8965638..c383e68 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -21,9 +21,6 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	if (!cg_proto)
 		return 0;
 
-	cg_proto->sysctl_mem[0] = sysctl_tcp_mem[0];
-	cg_proto->sysctl_mem[1] = sysctl_tcp_mem[1];
-	cg_proto->sysctl_mem[2] = sysctl_tcp_mem[2];
 	cg_proto->memory_pressure = 0;
 	cg_proto->memcg = memcg;
 
@@ -54,7 +51,6 @@ EXPORT_SYMBOL(tcp_destroy_cgroup);
 static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 {
 	struct cg_proto *cg_proto;
-	int i;
 	int ret;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
@@ -65,10 +61,6 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 	if (ret)
 		return ret;
 
-	for (i = 0; i < 3; i++)
-		cg_proto->sysctl_mem[i] = min_t(long, nr_pages,
-						sysctl_tcp_mem[i]);
-
 	if (nr_pages == PAGE_COUNTER_MAX)
 		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
 	else {
-- 
2.6.2
