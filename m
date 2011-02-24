From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/17] tipc: Improve accuracy of link transmit queue maximum size statistic
Date: Wed, 23 Feb 2011 20:26:38 -0500
Message-ID: <1298510805-20630-11-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34515 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111Ab1BXB1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:12 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Enhances TIPC's unicast and broadcast link code to update the transmit
queue maximum size counter in a single place, namely the routine that
adds messages to the queue. This ensures that the maximum size statistic
reported for unicast links is completely accurate, rather than being
partially based on statistical sampling.

The changes to link.h are just documenting the roles of the variables.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    2 --
 net/tipc/link.c  |    9 +++------
 net/tipc/link.h  |   18 ++++++------------
 3 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a5eb7db..63df42b 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -418,8 +418,6 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 	else
 		bclink_set_last_sent();
 
-	if (bcl->out_queue_size > bcl->stats.max_queue_sz)
-		bcl->stats.max_queue_sz = bcl->out_queue_size;
 	bcl->stats.queue_sz_counts++;
 	bcl->stats.accu_queue_sz += bcl->out_queue_size;
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 0cb773b..d1818fb 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -246,9 +246,6 @@ static void link_timeout(struct link *l_ptr)
 	l_ptr->stats.accu_queue_sz += l_ptr->out_queue_size;
 	l_ptr->stats.queue_sz_counts++;
 
-	if (l_ptr->out_queue_size > l_ptr->stats.max_queue_sz)
-		l_ptr->stats.max_queue_sz = l_ptr->out_queue_size;
-
 	if (l_ptr->first_out) {
 		struct tipc_msg *msg = buf_msg(l_ptr->first_out);
 		u32 length = msg_size(msg);
@@ -824,7 +821,10 @@ static void link_add_to_outqueue(struct link *l_ptr,
 		l_ptr->last_out = buf;
 	} else
 		l_ptr->first_out = l_ptr->last_out = buf;
+
 	l_ptr->out_queue_size++;
+	if (l_ptr->out_queue_size > l_ptr->stats.max_queue_sz)
+		l_ptr->stats.max_queue_sz = l_ptr->out_queue_size;
 }
 
 /*
@@ -867,9 +867,6 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 
 	/* Packet can be queued or sent: */
 
-	if (queue_size > l_ptr->stats.max_queue_sz)
-		l_ptr->stats.max_queue_sz = queue_size;
-
 	if (likely(!tipc_bearer_congested(l_ptr->b_ptr, l_ptr) &&
 		   !link_congested(l_ptr))) {
 		link_add_to_outqueue(l_ptr, buf, msg);
diff --git a/net/tipc/link.h b/net/tipc/link.h
index bdb0fa2..a7794e7 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -196,18 +196,12 @@ struct link {
 		u32 bearer_congs;
 		u32 deferred_recv;
 		u32 duplicates;
-
-		/* for statistical profiling of send queue size */
-
-		u32 max_queue_sz;
-		u32 accu_queue_sz;
-		u32 queue_sz_counts;
-
-		/* for statistical profiling of message lengths */
-
-		u32 msg_length_counts;
-		u32 msg_lengths_total;
-		u32 msg_length_profile[7];
+		u32 max_queue_sz;	/* send queue size high water mark */
+		u32 accu_queue_sz;	/* used for send queue size profiling */
+		u32 queue_sz_counts;	/* used for send queue size profiling */
+		u32 msg_length_counts;	/* used for message length profiling */
+		u32 msg_lengths_total;	/* used for message length profiling */
+		u32 msg_length_profile[7]; /* used for msg. length profiling */
 	} stats;
 };
 
-- 
1.7.3.3

