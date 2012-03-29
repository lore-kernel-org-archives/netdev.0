From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 2/3] memcg/tcp: remove static_branch_slow_dec() at
 changing limit
Date: Thu, 29 Mar 2012 16:07:45 +0900
Message-ID: <4F740A41.6040002@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer@parallels.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:60171 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583Ab2C2HJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 03:09:26 -0400
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B4F7D3EE0C0
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:09:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9142B45DE59
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:09:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B1BF45DE54
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:09:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C5AA1DB803C
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:09:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 090531DB802C
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 16:09:25 +0900 (JST)
In-Reply-To: <4F7408B7.9090706@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp memcontrol uses static_branch to optimize limit=RESOURCE_MAX case.
If all cgroup's limit=RESOUCE_MAX, resource usage is not accounted.
But it's buggy now.

For example, do following
 # while sleep 1;do
   echo 9223372036854775807 > /cgroup/memory/A/memory.kmem.tcp.limit_in_bytes;
   echo 300M > /cgroup/memory/A/memory.kmem.tcp.limit_in_bytes;
   done

and run network application under A. tcp's usage is sometimes accounted
and sometimes not accounted because of frequent changes of static_branch.
Then, finally, you can see broken tcp.usage_in_bytes.
WARN_ON() is printed because res_counter->usage goes below 0.
==
kernel: ------------[ cut here ]----------
kernel: WARNING: at kernel/res_counter.c:96 res_counter_uncharge_locked+0x37/0x40()
 <snip>
kernel: Pid: 17753, comm: bash Tainted: G  W    3.3.0+ #99
kernel: Call Trace:
kernel: <IRQ>  [<ffffffff8104cc9f>] warn_slowpath_common+0x7f/0xc0
kernel: [<ffffffff810d7e88>] ? rb_reserve__next_event+0x68/0x470
kernel: [<ffffffff8104ccfa>] warn_slowpath_null+0x1a/0x20
kernel: [<ffffffff810b4e37>] res_counter_uncharge_locked+0x37/0x40
...
==

This patch removes static_branch_slow_dec() at changing res_counter's
limit to RESOUCE_MAX. By this, once accounting started, the accountting
will continue until the tcp cgroup is destroyed.

I think this will not be problem in real use.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/net/tcp_memcontrol.h |    1 +
 net/ipv4/tcp_memcontrol.c    |   24 ++++++++++++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index 48410ff..f47e3c7 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -9,6 +9,7 @@ struct tcp_memcontrol {
 	/* those two are read-mostly, leave them at the end */
 	long tcp_prot_mem[3];
 	int tcp_memory_pressure;
+	bool accounting;
 };
 
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 32764a6..cd0b47d 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -49,6 +49,20 @@ static void memcg_tcp_enter_memory_pressure(struct sock *sk)
 }
 EXPORT_SYMBOL(memcg_tcp_enter_memory_pressure);
 
+static void tcp_start_accounting(struct tcp_memcontrol *tcp)
+{
+	if (tcp->accounting)
+		return;
+	tcp->accounting = true;
+	static_key_slow_inc(&memcg_socket_limit_enabled);
+}
+
+static void tcp_end_accounting(struct tcp_memcontrol *tcp)
+{
+	if (tcp->accounting)
+		static_key_slow_dec(&memcg_socket_limit_enabled);
+}
+
 int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 {
 	/*
@@ -73,6 +87,7 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	tcp->tcp_prot_mem[1] = net->ipv4.sysctl_tcp_mem[1];
 	tcp->tcp_prot_mem[2] = net->ipv4.sysctl_tcp_mem[2];
 	tcp->tcp_memory_pressure = 0;
+	tcp->accounting = false;
 
 	parent_cg = tcp_prot.proto_cgroup(parent);
 	if (parent_cg && mem_cgroup_use_hierarchy(parent))
@@ -110,8 +125,7 @@ void tcp_destroy_cgroup(struct cgroup *cgrp)
 
 	val = res_counter_read_u64(&tcp->tcp_memory_allocated, RES_LIMIT);
 
-	if (val != RESOURCE_MAX)
-		static_key_slow_dec(&memcg_socket_limit_enabled);
+	tcp_end_accounting(tcp);
 }
 EXPORT_SYMBOL(tcp_destroy_cgroup);
 
@@ -142,10 +156,8 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 		tcp->tcp_prot_mem[i] = min_t(long, val >> PAGE_SHIFT,
 					     net->ipv4.sysctl_tcp_mem[i]);
 
-	if (val == RESOURCE_MAX && old_lim != RESOURCE_MAX)
-		static_key_slow_dec(&memcg_socket_limit_enabled);
-	else if (old_lim == RESOURCE_MAX && val != RESOURCE_MAX)
-		static_key_slow_inc(&memcg_socket_limit_enabled);
+	if (old_lim == RESOURCE_MAX && val != RESOURCE_MAX)
+		tcp_start_accounting(tcp);
 
 	return 0;
 }
-- 
1.7.4.1
