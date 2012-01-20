From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 3/3] net: introduce res_counter_charge_nofail() for socket allocations
Date: Fri, 20 Jan 2012 18:57:16 +0400
Message-ID: <1327071436-20763-4-git-send-email-glommer@parallels.com>
References: <1327071436-20763-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Laurent Chavey <chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1327071436-20763-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is a case in __sk_mem_schedule(), where an allocation
is beyond the maximum, but yet we are allowed to proceed.
It happens under the following condition:

	sk->sk_wmem_queued + size >= sk->sk_sndbuf

The network code won't revert the allocation in this case,
meaning that at some point later it'll try to do it. Since
this is never communicated to the underlying res_counter
code, there is an inbalance in res_counter uncharge operation.

I see two ways of fixing this:

1) storing the information about those allocations somewhere
   in memcg, and then deducting from that first, before
   we start draining the res_counter,
2) providing a slightly different allocation function for
   the res_counter, that matches the original behavior of
   the network code more closely.

I decided to go for #2 here, believing it to be more elegant,
since #1 would require us to do basically that, but in a more
obscure way.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
CC: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
CC: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
CC: Laurent Chavey <chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 include/linux/res_counter.h |    6 ++++++
 include/net/sock.h          |   10 ++++------
 kernel/res_counter.c        |   25 +++++++++++++++++++++++++
 net/core/sock.c             |    4 ++--
 4 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index d06d014..da81af0 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -109,12 +109,18 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent);
  *
  * returns 0 on success and <0 if the counter->usage will exceed the
  * counter->limit _locked call expects the counter->lock to be taken
+ *
+ * charge_nofail works the same, except that it charges the resource
+ * counter unconditionally, and returns < 0 if the after the current
+ * charge we are over limit.
  */
 
 int __must_check res_counter_charge_locked(struct res_counter *counter,
 		unsigned long val);
 int __must_check res_counter_charge(struct res_counter *counter,
 		unsigned long val, struct res_counter **limit_fail_at);
+int __must_check res_counter_charge_nofail(struct res_counter *counter,
+		unsigned long val, struct res_counter **limit_fail_at);
 
 /*
  * uncharge - tell that some portion of the resource is released
diff --git a/include/net/sock.h b/include/net/sock.h
index 3cae112..e3f1ea4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1007,9 +1007,8 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 	struct res_counter *fail;
 	int ret;
 
-	ret = res_counter_charge(prot->memory_allocated,
-				 amt << PAGE_SHIFT, &fail);
-
+	ret = res_counter_charge_nofail(prot->memory_allocated,
+					amt << PAGE_SHIFT, &fail);
 	if (ret < 0)
 		*parent_status = OVER_LIMIT;
 }
@@ -1053,12 +1052,11 @@ sk_memory_allocated_add(struct sock *sk, int amt, int *parent_status)
 }
 
 static inline void
-sk_memory_allocated_sub(struct sock *sk, int amt, int parent_status)
+sk_memory_allocated_sub(struct sock *sk, int amt)
 {
 	struct proto *prot = sk->sk_prot;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
-	    parent_status != OVER_LIMIT) /* Otherwise was uncharged already */
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
 		memcg_memory_allocated_sub(sk->sk_cgrp, amt);
 
 	atomic_long_sub(amt, prot->memory_allocated);
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 6d269cc..d508363 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -66,6 +66,31 @@ done:
 	return ret;
 }
 
+int res_counter_charge_nofail(struct res_counter *counter, unsigned long val,
+			      struct res_counter **limit_fail_at)
+{
+	int ret, r;
+	unsigned long flags;
+	struct res_counter *c;
+
+	r = ret = 0;
+	*limit_fail_at = NULL;
+	local_irq_save(flags);
+	for (c = counter; c != NULL; c = c->parent) {
+		spin_lock(&c->lock);
+		r = res_counter_charge_locked(c, val);
+		if (r)
+			c->usage += val;
+		spin_unlock(&c->lock);
+		if (r < 0 && ret == 0) {
+			*limit_fail_at = c;
+			ret = r;
+		}
+	}
+	local_irq_restore(flags);
+
+	return ret;
+}
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
 {
 	if (WARN_ON(counter->usage < val))
diff --git a/net/core/sock.c b/net/core/sock.c
index 5c5af998..3e81fd2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1827,7 +1827,7 @@ suppress_allocation:
 	/* Alas. Undo changes. */
 	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
 
-	sk_memory_allocated_sub(sk, amt, parent_status);
+	sk_memory_allocated_sub(sk, amt);
 
 	return 0;
 }
@@ -1840,7 +1840,7 @@ EXPORT_SYMBOL(__sk_mem_schedule);
 void __sk_mem_reclaim(struct sock *sk)
 {
 	sk_memory_allocated_sub(sk,
-				sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT, 0);
+				sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT);
 	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
 
 	if (sk_under_memory_pressure(sk) &&
-- 
1.7.7.4
