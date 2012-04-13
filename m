From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
Date: Fri, 13 Apr 2012 14:33:49 -0300
Message-ID: <4F88637D.5020204@parallels.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com> <4F750FE8.2030800@jp.fujitsu.com> <4F7F1091.9040204@parallels.com> <4F839CF1.5050104@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------080903080709020500010102"
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:52303 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751677Ab2DMRfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2012 13:35:30 -0400
In-Reply-To: <4F839CF1.5050104@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------080903080709020500010102
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit

On 04/09/2012 11:37 PM, KAMEZAWA Hiroyuki wrote:
> (2012/04/07 0:49), Glauber Costa wrote:
> 
>> On 03/30/2012 05:44 AM, KAMEZAWA Hiroyuki wrote:
>>> Maybe what we can do before lsf/mm summit will be this (avoid warning.)
>>> This patch is onto linus's git tree. Patch description is updated.
>>>
>>> Thanks.
>>> -Kame
>>> ==
>>>   From 4ab80f84bbcb02a790342426c1de84aeb17fcbe9 Mon Sep 17 00:00:00 2001
>>> From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>> Date: Thu, 29 Mar 2012 14:59:04 +0900
>>> Subject: [PATCH] memcg/tcp: fix warning caused b res->usage go to negative.
>>>
>>> tcp memcontrol starts accouting after res->limit is set. So, if a sockets
>>> starts before setting res->limit, there are already used resource.
>>> At setting res->limit, accounting starts. The resource will be uncharged
>>> and make res_counter below 0 because they are not charged.
>>> This causes warning.
>>>
>>
>> Kame,
>>
>> Please test the following patch and see if it fixes your problems (I
>> tested locally, and it triggers me no warnings running the test script
>> you provided + an inbound scp -r copy of an iso directory from a remote
>> machine)
>>
>> When you are reviewing, keep in mind that we're likely to have the same
>> problems with slab jump labels - since the slab pages will outlive the
>> cgroup as well, and it might be worthy to keep this in mind, and provide
>> a central point for the jump labels to be set of on cgroup destruction.
>>
> 
> 
> Hm. What happens in following sequence ?
> 
>    1. a memcg is created
>    2. put a task into the memcg, start tcp steam
>    3. set tcp memory limit
> 
> The resource used between 2 and 3 will cause the problem finally.
> 
> Then, Dave's request
> ==
> You must either:
> 
> 1) Integrate the socket's existing usage when the limit is set.
> 
> 2) Avoid accounting completely for a socket that started before
>     the limit was set.
> ==
> are not satisfied. So, we need to have a state per sockets, it's accounted
> or not. I'll look into this problem again, today.
> 

Kame,

Let me know what you think of the attached fix.
I still need to compile test it in other configs to be sure it doesn't
break, etc. But let's agree on it first.

--------------080903080709020500010102
Content-Type: text/x-patch;
	name="0001-decrement-static-keys-on-real-destroy-time.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-decrement-static-keys-on-real-destroy-time.patch"

>From cdebff23dceeb9d35fd27e5988748a506bb47985 Mon Sep 17 00:00:00 2001
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

We just need to be careful with the static branch activation:
since there is no particular preferred order of their activation,
we need to make sure that we only start using it after all
call sites are active. This is achieved by having a per-memcg
flag that is only updated after static_key_slow_inc() returns.
At this time, we are sure all sites are active.

This is made per-memcg, not global, for a reason:
it also has the effect of making socket accounting more
consistent. The first memcg to be limited will trigger static_key()
activation, therefore, accounting. But all the others will then be
accounted no matter what. After this patch, only limited memcgs
will have its sockets accounted.

[v2: changed a tcp limited flag for a generic proto limited flag ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 include/net/sock.h        |    1 +
 mm/memcontrol.c           |   20 ++++++++++++++++++--
 net/ipv4/tcp_memcontrol.c |   12 ++++++------
 3 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b3ebe6b..f35ff7d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -913,6 +913,7 @@ struct cg_proto {
 	struct percpu_counter	*sockets_allocated;	/* Current number of sockets. */
 	int			*memory_pressure;
 	long			*sysctl_mem;
+	bool			limited;
 	/*
 	 * memcg field is used to find which memcg we belong directly
 	 * Each memcg struct can hold more than one cg_proto, so container_of
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 02b01d2..61f2d31 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -404,6 +404,7 @@ void sock_update_memcg(struct sock *sk)
 {
 	if (mem_cgroup_sockets_enabled) {
 		struct mem_cgroup *memcg;
+		struct cg_proto *cg_proto;
 
 		BUG_ON(!sk->sk_prot->proto_cgroup);
 
@@ -423,9 +424,10 @@ void sock_update_memcg(struct sock *sk)
 
 		rcu_read_lock();
 		memcg = mem_cgroup_from_task(current);
-		if (!mem_cgroup_is_root(memcg)) {
+		cg_proto = sk->sk_prot->proto_cgroup(memcg);
+		if (!mem_cgroup_is_root(memcg) && cg_proto->limited) {
 			mem_cgroup_get(memcg);
-			sk->sk_cgrp = sk->sk_prot->proto_cgroup(memcg);
+			sk->sk_cgrp = cg_proto;
 		}
 		rcu_read_unlock();
 	}
@@ -442,6 +444,14 @@ void sock_release_memcg(struct sock *sk)
 	}
 }
 
+static void disarm_static_keys(struct mem_cgroup *memcg)
+{
+#ifdef CONFIG_INET
+	if (memcg->tcp_mem.cg_proto.limited)
+		static_key_slow_dec(&memcg_socket_limit_enabled);
+#endif
+}
+
 #ifdef CONFIG_INET
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
 {
@@ -452,6 +462,11 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
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
@@ -4883,6 +4898,7 @@ static void __mem_cgroup_put(struct mem_cgroup *memcg, int count)
 {
 	if (atomic_sub_and_test(count, &memcg->refcnt)) {
 		struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+		disarm_static_keys(memcg);
 		__mem_cgroup_free(memcg);
 		if (parent)
 			mem_cgroup_put(parent);
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 1517037..8005667 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -54,6 +54,7 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	cg_proto->sysctl_mem = tcp->tcp_prot_mem;
 	cg_proto->memory_allocated = &tcp->tcp_memory_allocated;
 	cg_proto->sockets_allocated = &tcp->tcp_sockets_allocated;
+	cg_proto->limited = false;
 	cg_proto->memcg = memcg;
 
 	return 0;
@@ -74,9 +75,6 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 	percpu_counter_destroy(&tcp->tcp_sockets_allocated);
 
 	val = res_counter_read_u64(&tcp->tcp_memory_allocated, RES_LIMIT);
-
-	if (val != RESOURCE_MAX)
-		static_key_slow_dec(&memcg_socket_limit_enabled);
 }
 EXPORT_SYMBOL(tcp_destroy_cgroup);
 
@@ -107,10 +105,12 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 		tcp->tcp_prot_mem[i] = min_t(long, val >> PAGE_SHIFT,
 					     net->ipv4.sysctl_tcp_mem[i]);
 
-	if (val == RESOURCE_MAX && old_lim != RESOURCE_MAX)
-		static_key_slow_dec(&memcg_socket_limit_enabled);
-	else if (old_lim == RESOURCE_MAX && val != RESOURCE_MAX)
+	if (val == RESOURCE_MAX)
+		cg_proto->limited = false;
+	else if (val != RESOURCE_MAX && !cg_proto->limited) {
 		static_key_slow_inc(&memcg_socket_limit_enabled);
+		cg_proto->limited = true;
+	}
 
 	return 0;
 }
-- 
1.7.7.6


--------------080903080709020500010102--
