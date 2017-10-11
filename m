From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 2/2] net: call cgroup_sk_alloc() earlier in sk_clone_lock()
Date: Tue, 10 Oct 2017 19:12:33 -0700
Message-ID: <20171011021233.24158-2-edumazet@google.com>
References: <20171011021233.24158-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Craig Gallek <cgallek@google.com>, Tejun Heo <tj@kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:53090 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756781AbdJKCMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 22:12:41 -0400
Received: by mail-pg0-f50.google.com with SMTP id w9so193988pgo.9
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 19:12:41 -0700 (PDT)
In-Reply-To: <20171011021233.24158-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If for some reason, the newly allocated child need to be freed,
we will call cgroup_put() (via sk_free_unlock_clone()) while the
corresponding cgroup_get() was not yet done, and we will free memory
too soon.

Fixes: d979a39d7242 ("cgroup: duplicate cgroup reference when cloning sockets")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
---
 net/core/sock.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 70c6ccbdf49f2f8a5a0f7c41c7849ea01459be50..415f441c63b9e2ff8feb010f44ca27303c72aaa1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1687,6 +1687,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		atomic_set(&newsk->sk_zckey, 0);
 
 		sock_reset_flag(newsk, SOCK_DONE);
+		cgroup_sk_alloc(&newsk->sk_cgrp_data);
 
 		rcu_read_lock();
 		filter = rcu_dereference(sk->sk_filter);
@@ -1718,8 +1719,6 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_incoming_cpu = raw_smp_processor_id();
 		atomic64_set(&newsk->sk_cookie, 0);
 
-		cgroup_sk_alloc(&newsk->sk_cgrp_data);
-
 		/*
 		 * Before updating sk_refcnt, we must commit prior changes to memory
 		 * (Documentation/RCU/rculist_nulls.txt for details)
-- 
2.15.0.rc0.271.g36b669edcc-goog
