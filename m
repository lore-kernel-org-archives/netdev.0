From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/28] tipc: Remove non-executable code to handle broadcast bearer congestion
Date: Sat, 17 Sep 2011 23:32:04 -0400
Message-ID: <1316316744-29514-9-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49972 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab1IRDcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:47 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates code associated with the sending of unsent broadcast link
traffic when the broadcast pseudo-bearer becomes unblocked following a
temporary congestion situation. This code is non-executable because the
broadcast pseudo-bearer never becomes blocked [see tipc_bcbearer_send()].

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c  |   21 ---------------------
 net/tipc/bcast.h  |    1 -
 net/tipc/bearer.c |    6 +-----
 3 files changed, 1 insertions(+), 27 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 7abdca0..5200457 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -667,27 +667,6 @@ void tipc_bcbearer_sort(void)
 	spin_unlock_bh(&bc_lock);
 }
 
-/**
- * tipc_bcbearer_push - resolve bearer congestion
- *
- * Forces bclink to push out any unsent packets, until all packets are gone
- * or congestion reoccurs.
- * No locks set when function called
- */
-
-void tipc_bcbearer_push(void)
-{
-	struct tipc_bearer *b_ptr;
-
-	spin_lock_bh(&bc_lock);
-	b_ptr = &bcbearer->bearer;
-	if (b_ptr->blocked) {
-		b_ptr->blocked = 0;
-		tipc_bearer_lock_push(b_ptr);
-	}
-	spin_unlock_bh(&bc_lock);
-}
-
 
 int tipc_bclink_stats(char *buf, const u32 buf_size)
 {
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 500c97f..06740da 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -101,6 +101,5 @@ int  tipc_bclink_stats(char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
 void tipc_bcbearer_sort(void);
-void tipc_bcbearer_push(void);
 
 #endif
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 85eba9c..e465a92 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -385,13 +385,9 @@ static int bearer_push(struct tipc_bearer *b_ptr)
 
 void tipc_bearer_lock_push(struct tipc_bearer *b_ptr)
 {
-	int res;
-
 	spin_lock_bh(&b_ptr->lock);
-	res = bearer_push(b_ptr);
+	bearer_push(b_ptr);
 	spin_unlock_bh(&b_ptr->lock);
-	if (res)
-		tipc_bcbearer_push();
 }
 
 
-- 
1.7.4.4
