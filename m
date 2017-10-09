From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] net: defer call to cgroup_sk_alloc()
Date: Sun,  8 Oct 2017 21:44:52 -0700
Message-ID: <20171009044452.20564-3-edumazet@google.com>
References: <20171009044452.20564-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Tejun Heo <tj@kernel.org>, John Sperbeck <jsperbeck@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:50679 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751715AbdJIEpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:45:01 -0400
Received: by mail-pf0-f174.google.com with SMTP id m63so12609647pfk.7
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:45:01 -0700 (PDT)
In-Reply-To: <20171009044452.20564-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_clone_lock() might run while TCP/DCCP listener already vanished.

In order to prevent use after free, it is better to defer cgroup_sk_alloc()
to the point we know both parent and child exist, and from process context.

Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
---
 kernel/cgroup/cgroup.c          | 11 -----------
 net/core/sock.c                 |  3 +--
 net/ipv4/inet_connection_sock.c |  5 +++++
 3 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 44857278eb8aa6a2bbf27b7eb12137ef42628170..3380a3e49af501e457991b2823020494cf32af80 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -5709,17 +5709,6 @@ void cgroup_sk_alloc(struct sock_cgroup_data *skcd)
 	if (cgroup_sk_alloc_disabled)
 		return;
 
-	/* Socket clone path */
-	if (skcd->val) {
-		/*
-		 * We might be cloning a socket which is left in an empty
-		 * cgroup and the cgroup might have already been rmdir'd.
-		 * Don't use cgroup_get_live().
-		 */
-		cgroup_get(sock_cgroup_ptr(skcd));
-		return;
-	}
-
 	rcu_read_lock();
 
 	while (true) {
diff --git a/net/core/sock.c b/net/core/sock.c
index 70c6ccbdf49f2f8a5a0f7c41c7849ea01459be50..4499e31538132ed59a16d92e6f6b923e776df84e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1680,6 +1680,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 
 		/* sk->sk_memcg will be populated at accept() time */
 		newsk->sk_memcg = NULL;
+		memset(&newsk->sk_cgrp_data, 0, sizeof(newsk->sk_cgrp_data));
 
 		atomic_set(&newsk->sk_drops, 0);
 		newsk->sk_send_head	= NULL;
@@ -1718,8 +1719,6 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_incoming_cpu = raw_smp_processor_id();
 		atomic64_set(&newsk->sk_cookie, 0);
 
-		cgroup_sk_alloc(&newsk->sk_cgrp_data);
-
 		/*
 		 * Before updating sk_refcnt, we must commit prior changes to memory
 		 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 67aec7a106860b26c929fea1624d652c87972f04..d32c74507314cc4b91d040de8e877e4bd8204106 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -26,6 +26,8 @@
 #include <net/tcp.h>
 #include <net/sock_reuseport.h>
 #include <net/addrconf.h>
+#include <net/cls_cgroup.h>
+#include <net/netprio_cgroup.h>
 
 #ifdef INET_CSK_DEBUG
 const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
@@ -476,6 +478,9 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err, bool kern)
 		spin_unlock_bh(&queue->fastopenq.lock);
 	}
 	mem_cgroup_sk_alloc(newsk);
+	cgroup_sk_alloc(&newsk->sk_cgrp_data);
+	sock_update_classid(&newsk->sk_cgrp_data);
+	sock_update_netprioidx(&newsk->sk_cgrp_data);
 out:
 	release_sock(sk);
 	if (req)
-- 
2.14.2.920.gcf0c67979c-goog
