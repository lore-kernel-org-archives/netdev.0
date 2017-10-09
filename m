From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] net: memcontrol: defer call to mem_cgroup_sk_alloc()
Date: Sun,  8 Oct 2017 21:44:51 -0700
Message-ID: <20171009044452.20564-2-edumazet@google.com>
References: <20171009044452.20564-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Tejun Heo <tj@kernel.org>, John Sperbeck <jsperbeck@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:45820 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdJIEo6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:44:58 -0400
Received: by mail-pf0-f176.google.com with SMTP id z84so12614432pfi.2
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:44:58 -0700 (PDT)
In-Reply-To: <20171009044452.20564-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of calling mem_cgroup_sk_alloc() from BH context,
it is better to call it from inet_csk_accept() in process context.

Not only this removes code in mem_cgroup_sk_alloc(), but it also
fixes a bug since listener might have been dismantled and css_get()
might cause a use-after-free.

Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c                 | 15 ---------------
 net/core/sock.c                 |  5 ++++-
 net/ipv4/inet_connection_sock.c |  1 +
 3 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d5f3a62887cf958f6b657c0f542f0cf2c3e86e8d..661f046ad3181f65eccfd9bf3832e395e27aa226 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5828,21 +5828,6 @@ void mem_cgroup_sk_alloc(struct sock *sk)
 	if (!mem_cgroup_sockets_enabled)
 		return;
 
-	/*
-	 * Socket cloning can throw us here with sk_memcg already
-	 * filled. It won't however, necessarily happen from
-	 * process context. So the test for root memcg given
-	 * the current task's memcg won't help us in this case.
-	 *
-	 * Respecting the original socket's memcg is a better
-	 * decision in this case.
-	 */
-	if (sk->sk_memcg) {
-		BUG_ON(mem_cgroup_is_root(sk->sk_memcg));
-		css_get(&sk->sk_memcg->css);
-		return;
-	}
-
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(current);
 	if (memcg == root_mem_cgroup)
diff --git a/net/core/sock.c b/net/core/sock.c
index 23953b741a41fbcf4a6ffb0dd5bf05bd5266b99d..70c6ccbdf49f2f8a5a0f7c41c7849ea01459be50 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1677,6 +1677,10 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_dst_pending_confirm = 0;
 		newsk->sk_wmem_queued	= 0;
 		newsk->sk_forward_alloc = 0;
+
+		/* sk->sk_memcg will be populated at accept() time */
+		newsk->sk_memcg = NULL;
+
 		atomic_set(&newsk->sk_drops, 0);
 		newsk->sk_send_head	= NULL;
 		newsk->sk_userlocks	= sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
@@ -1714,7 +1718,6 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_incoming_cpu = raw_smp_processor_id();
 		atomic64_set(&newsk->sk_cookie, 0);
 
-		mem_cgroup_sk_alloc(newsk);
 		cgroup_sk_alloc(&newsk->sk_cgrp_data);
 
 		/*
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c039c937ba90c7aec39ba2687bceb8253ead70aa..67aec7a106860b26c929fea1624d652c87972f04 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -475,6 +475,7 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err, bool kern)
 		}
 		spin_unlock_bh(&queue->fastopenq.lock);
 	}
+	mem_cgroup_sk_alloc(newsk);
 out:
 	release_sock(sk);
 	if (req)
-- 
2.14.2.920.gcf0c67979c-goog
