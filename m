From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 3/5] net: Add & modify tracepoints to skb FCLONE_SCRATCH paths
Date: Thu, 27 Oct 2011 15:53:39 -0400
Message-ID: <1319745221-30880-4-git-send-email-nhorman@tuxdriver.com>
References: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@updev.think-freely.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38402 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab1J0Tyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 15:54:33 -0400
In-Reply-To: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@updev.think-freely.org>

Since skbs that are fcloned via the FCLONE_SCRATCH method are opportunistic, it
would be nice to have some feedback on how efficiently the path is acting.
These tracepoints provide the infrastructure needed to create perf scripts that
let us measure things like the number of skbs that are converted for
FCLONE_SCRATCH use, the number of scratch skbs that actually get
allocated, and the average per-packet time spent in the napi softirq context.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 include/linux/skbuff.h      |   21 +--------------------
 include/trace/events/napi.h |   41 +++++++++++++++++++++++++++++++++++++++++
 include/trace/events/skb.h  |   41 +++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c              |    2 ++
 net/core/skbuff.c           |   37 +++++++++++++++++++++++++++++++++----
 5 files changed, 118 insertions(+), 24 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e04fa48..77e3605 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2540,26 +2540,7 @@ extern unsigned int skb_make_fclone_scratch(struct sk_buff *skb);
 /*
  * Allocates an skb out of our scratch space
  */
-static inline struct sk_buff *alloc_fscratch_skb(struct sk_buff *skb)
-{
-	struct skb_scr_control *sctl = skb_get_scratch_control(skb);
-	struct sk_buff *sskb;
-
-	BUG_ON(skb->fclone != SKB_FCLONE_SCRATCH);
-	BUG_ON(!sctl);
-	BUG_ON(sctl->owner != skb);
-	if (skb_queue_empty(&sctl->scr_skbs))
-		return NULL;
-
-	sskb = __skb_dequeue(&sctl->scr_skbs);
-
-	/*
-	 * Mark us as a scratch skb, so we get properly kfree-ed
-	 */
-	sskb->fclone = SKB_FCLONE_SCRATCH;
-
-	return sskb;
-}
+extern struct sk_buff *alloc_fscratch_skb(struct sk_buff *skb);
 
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/include/trace/events/napi.h b/include/trace/events/napi.h
index 8fe1e93..5af5675 100644
--- a/include/trace/events/napi.h
+++ b/include/trace/events/napi.h
@@ -7,6 +7,7 @@
 #include <linux/netdevice.h>
 #include <linux/tracepoint.h>
 #include <linux/ftrace.h>
+#include <linux/kernel_stat.h>
 
 #define NO_DEV "(no_device)"
 
@@ -30,6 +31,46 @@ TRACE_EVENT(napi_poll,
 		__entry->napi, __get_str(dev_name))
 );
 
+TRACE_EVENT(napi_schedule,
+
+	TP_PROTO(struct napi_struct *napi),
+
+	TP_ARGS(napi),
+
+	TP_STRUCT__entry(
+		__field(	struct napi_struct *,	napi)
+		__string(	dev_name, napi->dev ? napi->dev->name : NO_DEV)
+	),
+
+	TP_fast_assign(
+		__entry->napi = napi;
+		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
+	),
+
+	TP_printk("napi schedule on napi struct %p for device %s",
+		__entry->napi, __get_str(dev_name))
+);
+
+TRACE_EVENT(napi_complete,
+
+	TP_PROTO(struct napi_struct *napi),
+
+	TP_ARGS(napi),
+
+	TP_STRUCT__entry(
+		__field(	struct napi_struct *,	napi)
+		__string(	dev_name, napi->dev ? napi->dev->name : NO_DEV)
+	),
+
+	TP_fast_assign(
+		__entry->napi = napi;
+		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
+	),
+
+	TP_printk("napi complete on napi struct %p for device %s",
+		__entry->napi, __get_str(dev_name))
+);
+
 #undef NO_DEV
 
 #endif /* _TRACE_NAPI_H_ */
diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 0c68ae22..3b83438 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -69,6 +69,47 @@ TRACE_EVENT(skb_copy_datagram_iovec,
 	TP_printk("skbaddr=%p len=%d", __entry->skbaddr, __entry->len)
 );
 
+TRACE_EVENT(skb_make_fclone_scratch,
+
+	TP_PROTO(struct sk_buff *skb, int count),
+
+	TP_ARGS(skb, count),
+
+	TP_STRUCT__entry(
+		__field(	const struct sk_buff *,	skb)
+		__string(	name, skb->dev ? skb->dev->name : "unknown")
+		__field(	int,			fccount)
+	),
+
+	TP_fast_assign(
+		__entry->skb = skb;
+		__assign_str(name, skb->dev ? skb->dev->name : "unknown");
+		__entry->fccount = count;
+	),
+
+	TP_printk("skb= %p, dev=%s, count=%d", __entry->skb,
+		  __get_str(name), __entry->fccount)
+);
+
+TRACE_EVENT(alloc_fscratch_skb,
+
+	TP_PROTO(const struct sk_buff *parent, const struct sk_buff *child),
+
+	TP_ARGS(parent, child),
+
+	TP_STRUCT__entry(
+		__field(	const struct sk_buff *, parent)
+		__field(	const struct sk_buff *, child)
+	),
+
+	TP_fast_assign(
+		__entry->parent = parent;
+		__entry->child = child;
+	),
+
+	TP_printk("parent=%p, child=%p", __entry->parent, __entry->child)
+);
+
 #endif /* _TRACE_SKB_H */
 
 /* This part must be outside protection */
diff --git a/net/core/dev.c b/net/core/dev.c
index b7ba81a..1af4c02 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2579,6 +2579,7 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 static inline void ____napi_schedule(struct softnet_data *sd,
 				     struct napi_struct *napi)
 {
+	trace_napi_schedule(napi);
 	list_add_tail(&napi->poll_list, &sd->poll_list);
 	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 }
@@ -3829,6 +3830,7 @@ void __napi_complete(struct napi_struct *n)
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
 	BUG_ON(n->gro_list);
 
+	trace_napi_complete(n);
 	list_del(&n->poll_list);
 	smp_mb__before_clear_bit();
 	clear_bit(NAPI_STATE_SCHED, &n->state);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6fdf1a7..0347446 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3221,6 +3221,30 @@ void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
 
+/*
+ * Allocates an skb out of our scratch space
+ */
+struct sk_buff *alloc_fscratch_skb(struct sk_buff *skb)
+{
+	struct skb_scr_control *sctl = skb_get_scratch_control(skb);
+	struct sk_buff *sskb = NULL;
+
+	BUG_ON(skb->fclone != SKB_FCLONE_SCRATCH);
+	BUG_ON(!sctl);
+	BUG_ON(sctl->owner != skb);
+
+	sskb = __skb_dequeue(&sctl->scr_skbs);
+
+	/*
+	 * Mark us as a scratch skb, so we get properly kfree-ed
+	 */
+	sskb->fclone = SKB_FCLONE_SCRATCH;
+
+	trace_alloc_fscratch_skb(skb, sskb);
+	return sskb;
+}
+EXPORT_SYMBOL(alloc_fscratch_skb);
+
 unsigned int skb_make_fclone_scratch(struct sk_buff *skb)
 {
 	size_t bufsz, totsz, scrsz, tmpsz;
@@ -3228,15 +3252,16 @@ unsigned int skb_make_fclone_scratch(struct sk_buff *skb)
 	struct sk_buff *scr_skb;
 	struct skb_shared_info *old_info;
 	bool format_tail = false;
+	int fclone_count = 0;
 
 	if (skb_shared(skb))
-		return 0;
+		goto out;
 
 	/*
 	 * Cant do scratch space on fcloned skbs
 	 */
 	if (skb->fclone)
-		return 0;
+		goto out;
 
 	if ((skb->end - skb->tail) > sizeof(struct skb_shared_info)) {
 		old_info = skb_shinfo(skb);
@@ -3257,7 +3282,7 @@ unsigned int skb_make_fclone_scratch(struct sk_buff *skb)
 		 sizeof(struct skb_shared_info);
 
 	if ((bufsz + sizeof(struct skb_scr_control)) >= totsz)
-		return 0;
+		goto out;
 
 	/*
 	 * And this is the leftover area, minus sizeof(int) to store the number
@@ -3278,6 +3303,10 @@ unsigned int skb_make_fclone_scratch(struct sk_buff *skb)
 
 	skb->fclone = SKB_FCLONE_SCRATCH;
 
-	return skb_queue_len(&sctl->scr_skbs);
+	fclone_count = skb_queue_len(&sctl->scr_skbs);
+out:
+	trace_skb_make_fclone_scratch(skb, fclone_count);
+	return fclone_count;
 
 }
+EXPORT_SYMBOL(skb_make_fclone_scratch);
-- 
1.7.6.4
