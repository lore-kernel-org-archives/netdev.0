From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
Date: Fri, 6 Apr 2012 19:49:37 +0400
Message-ID: <4F7F1091.9040204@parallels.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com> <4F750FE8.2030800@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------080303030304060903030908"
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:33346 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168Ab2DFPvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 11:51:12 -0400
In-Reply-To: <4F750FE8.2030800@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------080303030304060903030908
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit

On 03/30/2012 05:44 AM, KAMEZAWA Hiroyuki wrote:
> Maybe what we can do before lsf/mm summit will be this (avoid warning.)
> This patch is onto linus's git tree. Patch description is updated.
> 
> Thanks.
> -Kame
> ==
>  From 4ab80f84bbcb02a790342426c1de84aeb17fcbe9 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 29 Mar 2012 14:59:04 +0900
> Subject: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
> 
> tcp memcontrol starts accouting after res->limit is set. So, if a sockets
> starts before setting res->limit, there are already used resource.
> At setting res->limit, accounting starts. The resource will be uncharged
> and make res_counter below 0 because they are not charged.
> This causes warning.
> 

Kame,

Please test the following patch and see if it fixes your problems (I
tested locally, and it triggers me no warnings running the test script
you provided + an inbound scp -r copy of an iso directory from a remote
machine)

When you are reviewing, keep in mind that we're likely to have the same
problems with slab jump labels - since the slab pages will outlive the
cgroup as well, and it might be worthy to keep this in mind, and provide
a central point for the jump labels to be set of on cgroup destruction.


--------------080303030304060903030908
Content-Type: text/x-patch;
	name="0001-decrement-static-keys-on-real-destroy-time.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-decrement-static-keys-on-real-destroy-time.patch"

>From c40bbd69cbb655b6389c2398ce89abb06e64910d Mon Sep 17 00:00:00 2001
From: Glauber Costa <glommer@parallels.com>
Date: Wed, 4 Apr 2012 21:08:38 +0400
Subject: [PATCH] decrement static keys on real destroy time

We call the destroy function when a cgroup starts to be removed,
such as by a rmdir event.

However, because of our reference counters, some objects are still
inflight. Right now, we are decrementing the static_keys at destroy()
time, meaning that if we get rid of the last static_key reference,
some objects will still have charges, but the code to properly
uncharge them won't be run.

This becomes a problem specially if it is ever enabled again, because
now new charges will be added to the staled charges making keeping
it pretty much impossible.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 include/net/tcp_memcontrol.h |    2 ++
 mm/memcontrol.c              |   15 +++++++++++++++
 net/ipv4/tcp_memcontrol.c    |   10 ++++------
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index 7df18bc..5a2b915 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -9,6 +9,8 @@ struct tcp_memcontrol {
 	/* those two are read-mostly, leave them at the end */
 	long tcp_prot_mem[3];
 	int tcp_memory_pressure;
+	/* if this cgroup was ever limited, having static_keys activated */
+	bool limited;
 };
 
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 64a1bcd..74b757b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -442,6 +442,15 @@ void sock_release_memcg(struct sock *sk)
 	}
 }
 
+static void disarm_static_keys(struct mem_cgroup *memcg)
+{
+#ifdef CONFIG_INET
+	if (memcg->tcp_mem.limited)	
+		static_key_slow_dec(&memcg_socket_limit_enabled);
+#endif
+}
+
+
 #ifdef CONFIG_INET
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
 {
@@ -452,6 +461,11 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(tcp_proto_cgroup);
 #endif /* CONFIG_INET */
+#else
+static inline void disarm_static_keys(struct mem_cgroup *memcg)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
 
 static void drain_all_stock_async(struct mem_cgroup *memcg);
@@ -4883,6 +4897,7 @@ static void __mem_cgroup_put(struct mem_cgroup *memcg, int count)
 {
 	if (atomic_sub_and_test(count, &memcg->refcnt)) {
 		struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+		disarm_static_keys(memcg);
 		__mem_cgroup_free(memcg);
 		if (parent)
 			mem_cgroup_put(parent);
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 1517037..93555ab 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -41,6 +41,7 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	tcp->tcp_prot_mem[1] = net->ipv4.sysctl_tcp_mem[1];
 	tcp->tcp_prot_mem[2] = net->ipv4.sysctl_tcp_mem[2];
 	tcp->tcp_memory_pressure = 0;
+	tcp->limited = false;
 
 	parent_cg = tcp_prot.proto_cgroup(parent);
 	if (parent_cg)
@@ -74,9 +75,6 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 	percpu_counter_destroy(&tcp->tcp_sockets_allocated);
 
 	val = res_counter_read_u64(&tcp->tcp_memory_allocated, RES_LIMIT);
-
-	if (val != RESOURCE_MAX)
-		static_key_slow_dec(&memcg_socket_limit_enabled);
 }
 EXPORT_SYMBOL(tcp_destroy_cgroup);
 
@@ -107,10 +105,10 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 		tcp->tcp_prot_mem[i] = min_t(long, val >> PAGE_SHIFT,
 					     net->ipv4.sysctl_tcp_mem[i]);
 
-	if (val == RESOURCE_MAX && old_lim != RESOURCE_MAX)
-		static_key_slow_dec(&memcg_socket_limit_enabled);
-	else if (old_lim == RESOURCE_MAX && val != RESOURCE_MAX)
+	if (old_lim == RESOURCE_MAX && !tcp->limited) {
 		static_key_slow_inc(&memcg_socket_limit_enabled);
+		tcp->limited = true;
+	}
 
 	return 0;
 }
-- 
1.7.7.6


--------------080303030304060903030908--
