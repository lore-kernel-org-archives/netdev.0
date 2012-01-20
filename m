From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/3] net: fix socket memcg build with !CONFIG_NET
Date: Fri, 20 Jan 2012 18:57:14 +0400
Message-ID: <1327071436-20763-2-git-send-email-glommer@parallels.com>
References: <1327071436-20763-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327071436-20763-1-git-send-email-glommer@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is still a build bug with the sock memcg code, that triggers
with !CONFIG_NET, that survived my series of randconfig builds.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reported-by: Randy Dunlap <rdunlap@xenotime.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/net/sock.h |    2 +-
 mm/memcontrol.c    |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index bb972d2..3cae112 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -921,7 +921,7 @@ inline void sk_refcnt_debug_release(const struct sock *sk)
 #define sk_refcnt_debug_release(sk) do { } while (0)
 #endif /* SOCK_REFCNT_DEBUG */
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+#if defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM) && defined(CONFIG_NET)
 extern struct jump_label_key memcg_socket_limit_enabled;
 static inline struct cg_proto *parent_cg_proto(struct proto *proto,
 					       struct cg_proto *cg_proto)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3dbff4d..c3688df 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -379,7 +379,7 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
 static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 void sock_update_memcg(struct sock *sk)
 {
-	if (static_branch(&memcg_socket_limit_enabled)) {
+	if (mem_cgroup_sockets_enabled) {
 		struct mem_cgroup *memcg;
 
 		BUG_ON(!sk->sk_prot->proto_cgroup);
@@ -411,7 +411,7 @@ EXPORT_SYMBOL(sock_update_memcg);
 
 void sock_release_memcg(struct sock *sk)
 {
-	if (static_branch(&memcg_socket_limit_enabled) && sk->sk_cgrp) {
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
 		struct mem_cgroup *memcg;
 		WARN_ON(!sk->sk_cgrp->memcg);
 		memcg = sk->sk_cgrp->memcg;
-- 
1.7.7.4
