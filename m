From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 11/17] tcp/dccp: shrink struct listen_sock
Date: Fri,  2 Oct 2015 11:43:33 -0700
Message-ID: <1443811419-4798-12-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35608 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590AbbJBSoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:16 -0400
Received: by pacfv12 with SMTP id fv12so115652690pac.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:15 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We no longer use hash_rnd, nr_table_entries and syn_table[]

For a listener with a backlog of 10 millions sockets, this
saves 80 MBytes of vmalloced memory.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h |  3 ---
 net/core/request_sock.c    | 14 +++-----------
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index e1850923c4f5..353cb61bb399 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -125,9 +125,6 @@ extern int sysctl_max_syn_backlog;
  */
 struct listen_sock {
 	u32			max_qlen_log;
-	u32			hash_rnd;
-	u32			nr_table_entries;
-	struct request_sock	*syn_table[0];
 };
 
 /*
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index a4b305d8ca2b..124f61c5bfef 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -46,18 +46,11 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
 	nr_table_entries = max_t(u32, nr_table_entries, 8);
 	nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
-	lopt_size += nr_table_entries * sizeof(struct request_sock *);
 
-	if (lopt_size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
-		lopt = kzalloc(lopt_size, GFP_KERNEL |
-					  __GFP_NOWARN |
-					  __GFP_NORETRY);
-	if (!lopt)
-		lopt = vzalloc(lopt_size);
+	lopt = kzalloc(lopt_size, GFP_KERNEL);
 	if (!lopt)
 		return -ENOMEM;
 
-	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
 	spin_lock_init(&queue->rskq_lock);
 	spin_lock_init(&queue->syn_wait_lock);
 
@@ -68,7 +61,6 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	queue->fastopenq.max_qlen = 0;
 
 	queue->rskq_accept_head = NULL;
-	lopt->nr_table_entries = nr_table_entries;
 	lopt->max_qlen_log = ilog2(nr_table_entries);
 
 	spin_lock_bh(&queue->syn_wait_lock);
@@ -81,7 +73,7 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 void __reqsk_queue_destroy(struct request_sock_queue *queue)
 {
 	/* This is an error recovery path only, no locking needed */
-	kvfree(queue->listen_opt);
+	kfree(queue->listen_opt);
 }
 
 static inline struct listen_sock *reqsk_queue_yank_listen_sk(
@@ -102,7 +94,7 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
 
 	/* cleaning is done by req timers */
-	kvfree(lopt);
+	kfree(lopt);
 }
 
 /*
-- 
2.6.0.rc2.230.g3dd15c0
