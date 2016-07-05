From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] net: tracepoint napi:napi_poll add work and budget
Date: Tue, 05 Jul 2016 19:35:27 +0200
Message-ID: <20160705173444.3113.23769.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596AbcGERqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 13:46:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An important information for the napi_poll tracepoint is knowing
the work done (packets processed) by the napi_poll() call. Add
both the work done and budget, as they are related.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
Can this patch go thought the net-next tree?

 include/trace/events/napi.h |   13 +++++++++----
 net/core/dev.c              |    4 ++--
 net/core/netpoll.c          |    2 +-
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/napi.h b/include/trace/events/napi.h
index 8fe1e93f531d..118ed7767639 100644
--- a/include/trace/events/napi.h
+++ b/include/trace/events/napi.h
@@ -12,22 +12,27 @@
 
 TRACE_EVENT(napi_poll,
 
-	TP_PROTO(struct napi_struct *napi),
+	TP_PROTO(struct napi_struct *napi, int work, int budget),
 
-	TP_ARGS(napi),
+	TP_ARGS(napi, work, budget),
 
 	TP_STRUCT__entry(
 		__field(	struct napi_struct *,	napi)
+		__field(	int,			work)
+		__field(	int,			budget)
 		__string(	dev_name, napi->dev ? napi->dev->name : NO_DEV)
 	),
 
 	TP_fast_assign(
 		__entry->napi = napi;
+		__entry->work = work;
+		__entry->budget = budget;
 		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
 	),
 
-	TP_printk("napi poll on napi struct %p for device %s",
-		__entry->napi, __get_str(dev_name))
+	TP_printk("napi poll on napi struct %p for device %s work %d budget %d",
+		  __entry->napi, __get_str(dev_name),
+		  __entry->work, __entry->budget)
 );
 
 #undef NO_DEV
diff --git a/net/core/dev.c b/net/core/dev.c
index b8cc5e979168..7a4e9a714fb3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4973,7 +4973,7 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 
 			if (test_bit(NAPI_STATE_SCHED, &napi->state)) {
 				rc = napi->poll(napi, BUSY_POLL_BUDGET);
-				trace_napi_poll(napi);
+				trace_napi_poll(napi, rc, BUSY_POLL_BUDGET);
 				if (rc == BUSY_POLL_BUDGET) {
 					napi_complete_done(napi, rc);
 					napi_schedule(napi);
@@ -5129,7 +5129,7 @@ static int napi_poll(struct napi_struct *n, struct list_head *repoll)
 	work = 0;
 	if (test_bit(NAPI_STATE_SCHED, &n->state)) {
 		work = n->poll(n, weight);
-		trace_napi_poll(n);
+		trace_napi_poll(n, work, weight);
 	}
 
 	WARN_ON_ONCE(work > weight);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 94acfc89ad97..53599bd0c82d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -163,7 +163,7 @@ static void poll_one_napi(struct napi_struct *napi)
 	 */
 	work = napi->poll(napi, 0);
 	WARN_ONCE(work, "%pF exceeded budget in poll\n", napi->poll);
-	trace_napi_poll(napi);
+	trace_napi_poll(napi, work, 0);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
 }
