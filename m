From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: [PATCH] networking: enhance NAPI tracing
Date: Mon, 15 Apr 2013 12:16:24 +0300
Message-ID: <1820981.mWzDT3QAhR@lx-vladimir>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth01.qualcomm.com ([65.197.215.72]:55910 "EHLO
	sabertooth01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934370Ab3DOJQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 05:16:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I faced with lack of tracing when debugging NAPI,
patch below adds missing bits.

There are warnings from checkpatch, because of commonly used style
for the traces.



>From 12f3171f1346a2b89121f941208111711fab1097 Mon Sep 17 00:00:00 2001
From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Date: Mon, 15 Apr 2013 12:00:08 +0300
Subject: [PATCH] networking: enhance NAPI tracing

NAPI cycle includes napi_schedule(), poll() and napi_complete() functions.

Add trace for napi_schedule()/napi_complete() - for internal functions with '__',
when actual actions performed.

For poll(), add printing of 'weight' and 'work'

Signed-off-by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
---
 include/trace/events/napi.h |   39 +++++++++++++++++++++++++++++++++++++--
 net/core/dev.c              |    4 +++-
 net/core/netpoll.c          |    2 +-
 3 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/napi.h b/include/trace/events/napi.h
index 8fe1e93..26fdb75 100644
--- a/include/trace/events/napi.h
+++ b/include/trace/events/napi.h
@@ -12,6 +12,31 @@
 
 TRACE_EVENT(napi_poll,
 
+	TP_PROTO(struct napi_struct *napi, int weight, int work),
+
+	TP_ARGS(napi, weight, work),
+
+	TP_STRUCT__entry(
+		__field(	struct napi_struct *,	napi)
+		__string(	dev_name, napi->dev ? napi->dev->name : NO_DEV)
+		__field(	int,	weight)
+		__field(	int,	work)
+	),
+
+	TP_fast_assign(
+		__entry->napi = napi;
+		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
+		__entry->weight = weight;
+		__entry->work = work;
+	),
+
+	TP_printk("napi poll on napi struct %p for device %s"
+		  " weight %d work %d",
+		__entry->napi, __get_str(dev_name), __entry->weight,
+		__entry->work)
+);
+
+DECLARE_EVENT_CLASS(napi_state,
 	TP_PROTO(struct napi_struct *napi),
 
 	TP_ARGS(napi),
@@ -26,8 +51,18 @@ TRACE_EVENT(napi_poll,
 		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
 	),
 
-	TP_printk("napi poll on napi struct %p for device %s",
-		__entry->napi, __get_str(dev_name))
+	TP_printk("napi struct %p for device %s",
+		  __entry->napi, __get_str(dev_name))
+);
+
+DEFINE_EVENT(napi_state, napi_schedule,
+	TP_PROTO(struct napi_struct *napi),
+	TP_ARGS(napi)
+);
+
+DEFINE_EVENT(napi_state, napi_complete,
+	TP_PROTO(struct napi_struct *napi),
+	TP_ARGS(napi)
 );
 
 #undef NO_DEV
diff --git a/net/core/dev.c b/net/core/dev.c
index e7d68ed..2537253 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4023,6 +4023,7 @@ void __napi_schedule(struct napi_struct *n)
 	local_irq_save(flags);
 	____napi_schedule(&__get_cpu_var(softnet_data), n);
 	local_irq_restore(flags);
+	trace_napi_schedule(n);
 }
 EXPORT_SYMBOL(__napi_schedule);
 
@@ -4034,6 +4035,7 @@ void __napi_complete(struct napi_struct *n)
 	list_del(&n->poll_list);
 	smp_mb__before_clear_bit();
 	clear_bit(NAPI_STATE_SCHED, &n->state);
+	trace_napi_complete(n);
 }
 EXPORT_SYMBOL(__napi_complete);
 
@@ -4134,7 +4136,7 @@ static void net_rx_action(struct softirq_action *h)
 		work = 0;
 		if (test_bit(NAPI_STATE_SCHED, &n->state)) {
 			work = n->poll(n, weight);
-			trace_napi_poll(n);
+			trace_napi_poll(n, weight, work);
 		}
 
 		WARN_ON_ONCE(work > weight);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index fa32899..75f8c32 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -160,7 +160,7 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
 	work = napi->poll(napi, budget);
-	trace_napi_poll(napi);
+	trace_napi_poll(napi, budget, work);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
 	atomic_dec(&trapped);
-- 
1.7.10.4
