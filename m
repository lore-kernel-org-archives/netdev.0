From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 04/14] net: tcp_memcontrol: remove bogus hierarchy pressure propagation
Date: Thu, 12 Nov 2015 18:41:23 -0500
Message-ID: <1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>,
	Tejun Heo <tj@kernel.org>,
	Michal Hocko <mhocko@suse.cz>,
	netdev@vger.kernel.org,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

When a cgroup currently breaches its socket memory limit, it enters
memory pressure mode for itself and its *ancestors*. This throttles
transmission in unrelated sibling and cousin subtrees that have
nothing to do with the breached limit.

On the contrary, breaching a limit should make that group and its
*children* enter memory pressure mode. But this happens already,
albeit lazily: if an ancestor limit is breached, siblings will enter
memory pressure on their own once the next packet arrives for them.

So no additional hierarchy code is needed. Remove the bogus stuff.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/net/sock.h | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c4b33c9..6fc9147 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1152,14 +1152,8 @@ static inline void sk_leave_memory_pressure(struct sock *sk)
 	if (*memory_pressure)
 		*memory_pressure = 0;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct cg_proto *cg_proto = sk->sk_cgrp;
-		struct proto *prot = sk->sk_prot;
-
-		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			cg_proto->memory_pressure = 0;
-	}
-
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		sk->sk_cgrp->memory_pressure = 0;
 }
 
 static inline void sk_enter_memory_pressure(struct sock *sk)
@@ -1167,13 +1161,8 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
 	if (!sk->sk_prot->enter_memory_pressure)
 		return;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct cg_proto *cg_proto = sk->sk_cgrp;
-		struct proto *prot = sk->sk_prot;
-
-		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			cg_proto->memory_pressure = 1;
-	}
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		sk->sk_cgrp->memory_pressure = 1;
 
 	sk->sk_prot->enter_memory_pressure(sk);
 }
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
