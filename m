From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH] net: fix sock_clone reference mismatch with tcp memcontrol
Date: Fri,  6 Jan 2012 10:16:39 +0400
Message-ID: <1325830599-11857-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Laurent Chavey <chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sockets can also be created through sock_clone. Because it copies
all data in the sock structure, it also copies the memcg-related pointer,
and all should be fine. However, since we now use reference counts in
socket creation, we are left with some sockets that have no reference
counts. It matters when we destroy them, since it leads to a mismatch.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
CC: Laurent Chavey <chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 include/net/sock.h |    6 ++++++
 mm/memcontrol.c    |   19 ++++++++++++++-----
 net/core/sock.c    |    2 ++
 3 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index bb972d2..0ed65e3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1103,6 +1103,12 @@ sk_sockets_allocated_read_positive(struct sock *sk)
 	return percpu_counter_sum_positive(prot->sockets_allocated);
 }
 
+static inline void sk_update_clone(const struct sock *sk, struct sock *newsk)
+{
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		sock_update_memcg(newsk);
+}
+
 static inline int
 proto_sockets_allocated_sum_positive(struct proto *prot)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 94da8ee..9c72d5d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -381,16 +381,25 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
 static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 void sock_update_memcg(struct sock *sk)
 {
-	/* A socket spends its whole life in the same cgroup */
-	if (sk->sk_cgrp) {
-		WARN_ON(1);
-		return;
-	}
 	if (static_branch(&memcg_socket_limit_enabled)) {
 		struct mem_cgroup *memcg;
 
 		BUG_ON(!sk->sk_prot->proto_cgroup);
 
+		/* Socket cloning can throw us here with sk_cgrp already
+		 * filled. It won't however, necessarily happen from
+		 * process context. So the test for root memcg given
+		 * the current task's memcg won't help us in this case.
+		 *
+		 * Respecting the original socket's memcg is a better
+		 * decision in this case.
+		 */
+		if (sk->sk_cgrp) {
+			BUG_ON(mem_cgroup_is_root(sk->sk_cgrp->memcg));
+			mem_cgroup_get(sk->sk_cgrp->memcg);
+			return;
+		}
+
 		rcu_read_lock();
 		memcg = mem_cgroup_from_task(current);
 		if (!mem_cgroup_is_root(memcg)) {
diff --git a/net/core/sock.c b/net/core/sock.c
index 002939c..e80b64f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1362,6 +1362,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		sk_set_socket(newsk, NULL);
 		newsk->sk_wq = NULL;
 
+		sk_update_clone(sk, newsk);
+
 		if (newsk->sk_prot->sockets_allocated)
 			sk_sockets_allocated_inc(newsk);
 
-- 
1.7.7.4
