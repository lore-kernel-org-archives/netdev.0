From: Michal Kazior <michal.kazior@tieto.com>
Subject: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Fri, 26 Feb 2016 14:09:23 +0100
Message-ID: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, dave.taht@gmail.com,
	emmanuel.grumbach@intel.com, nbd@openwrt.org,
	Tim Shepard <shep@alum.mit.edu>,
	Michal Kazior <michal.kazior@tieto.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33256 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981AbcBZNJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 08:09:26 -0500
Received: by mail-lf0-f50.google.com with SMTP id m1so53141004lfg.0
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 05:09:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 11n aggregation become important to get the
best out of txops. However aggregation inherently
requires buffering and queuing. Once variable
medium conditions to different associated stations
is considered it became apparent that bufferbloat
can't be simply fought with qdiscs for wireless
drivers. 11ac with MU-MIMO makes the problem
worse because the bandwidth-delay product becomes
even greater.

This bases on codel5 and sch_fq_codel.c. It may
not be the Right Thing yet but it should at least
provide a framework for more improvements.

I guess dropping rate could factor in per-station
rate control info but I don't know how this should
exactly be done. HW rate control drivers would
need extra work to take advantage of this.

This obviously works only with drivers that use
wake_tx_queue op.

Note: This uses IFF_NO_QUEUE to get rid of qdiscs
for wireless drivers that use mac80211 and
implement wake_tx_queue op.

Moreover the current txq_limit and latency setting
might need tweaking. Either from userspace or be
dynamically scaled with regard to, e.g. number of
associated stations.

FWIW This already works nicely with ath10k's (not
yey merged) pull-push congestion control for
MU-MIMO as far as throughput is concerned.

Evaluating latency improvements is a little tricky
at this point if a driver is using more queue
layering and/or its firmware controls tx
scheduling - hence I don't have any solid data on
this. I'm open for suggestions though.

It might also be a good idea to do the following
in the future:

 - make generic tx scheduling which does some RR
   over per-sta-tid queues and dequeues bursts of
   packets to form a PPDU to fit into designated
   txop timeframe and bytelimit

   This could in theory be shared and used by
   ath9k and (future) mt76.

   Moreover tx scheduling could factor in rate
   control info and keep per-station number of
   queued packets at a sufficient low threshold to
   avoid queue buildup for slow stations. Emmanuel
   already did similar experiment for iwlwifi's
   station mode and got promising results.

 - make software queueing default internally in
   mac80211. This could help other drivers to get
   at least some benefit from mac80211 smarter
   queueing.

Signed-off-by: Michal Kazior <michal.kazior@tieto.com>
---
 include/net/mac80211.h     |  36 ++++-
 net/mac80211/agg-tx.c      |   8 +-
 net/mac80211/codel.h       | 260 +++++++++++++++++++++++++++++++
 net/mac80211/codel_i.h     |  89 +++++++++++
 net/mac80211/ieee80211_i.h |  27 +++-
 net/mac80211/iface.c       |  25 ++-
 net/mac80211/main.c        |   9 +-
 net/mac80211/rx.c          |   2 +-
 net/mac80211/sta_info.c    |  10 +-
 net/mac80211/sta_info.h    |  27 ++++
 net/mac80211/tx.c          | 370 ++++++++++++++++++++++++++++++++++++++++-----
 net/mac80211/util.c        |  20 ++-
 12 files changed, 805 insertions(+), 78 deletions(-)
 create mode 100644 net/mac80211/codel.h
 create mode 100644 net/mac80211/codel_i.h

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 6617516a276f..4667d2bad356 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -565,6 +565,18 @@ struct ieee80211_bss_conf {
 	struct ieee80211_p2p_noa_attr p2p_noa_attr;
 };
 
+typedef u64 codel_time_t;
+
+/*
+ * struct codel_params - contains codel parameters
+ * @interval:	initial drop rate
+ * @target:     maximum persistent sojourn time
+ */
+struct codel_params {
+	codel_time_t	interval;
+	codel_time_t	target;
+};
+
 /**
  * enum mac80211_tx_info_flags - flags to describe transmission information/status
  *
@@ -886,8 +898,18 @@ struct ieee80211_tx_info {
 				/* only needed before rate control */
 				unsigned long jiffies;
 			};
-			/* NB: vif can be NULL for injected frames */
-			struct ieee80211_vif *vif;
+			union {
+				/* NB: vif can be NULL for injected frames */
+				struct ieee80211_vif *vif;
+
+				/* When packets are enqueued on txq it's easy
+				 * to re-construct the vif pointer. There's no
+				 * more space in tx_info so it can be used to
+				 * store the necessary enqueue time for packet
+				 * sojourn time computation.
+				 */
+				codel_time_t enqueue_time;
+			};
 			struct ieee80211_key_conf *hw_key;
 			u32 flags;
 			/* 4 bytes free */
@@ -2102,8 +2124,8 @@ enum ieee80211_hw_flags {
  * @cipher_schemes: a pointer to an array of cipher scheme definitions
  *	supported by HW.
  *
- * @txq_ac_max_pending: maximum number of frames per AC pending in all txq
- *	entries for a vif.
+ * @txq_cparams: codel parameters to control tx queueing dropping behavior
+ * @txq_limit: maximum number of frames queuesd
  */
 struct ieee80211_hw {
 	struct ieee80211_conf conf;
@@ -2133,7 +2155,8 @@ struct ieee80211_hw {
 	u8 uapsd_max_sp_len;
 	u8 n_cipher_schemes;
 	const struct ieee80211_cipher_scheme *cipher_schemes;
-	int txq_ac_max_pending;
+	struct codel_params txq_cparams;
+	u32 txq_limit;
 };
 
 static inline bool _ieee80211_hw_check(struct ieee80211_hw *hw,
@@ -5602,6 +5625,9 @@ struct sk_buff *ieee80211_tx_dequeue(struct ieee80211_hw *hw,
  * txq state can change half-way of this function and the caller may end up
  * with "new" frame_cnt and "old" byte_cnt or vice-versa.
  *
+ * Moreover returned values are best-case, i.e. assuming queueing algorithm
+ * will not drop frames due to excess latency.
+ *
  * @txq: pointer obtained from station or virtual interface
  * @frame_cnt: pointer to store frame count
  * @byte_cnt: pointer to store byte count
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index 4932e9f243a2..b9d0cee2a786 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -194,17 +194,21 @@ static void
 ieee80211_agg_stop_txq(struct sta_info *sta, int tid)
 {
 	struct ieee80211_txq *txq = sta->sta.txq[tid];
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_fq *fq;
 	struct txq_info *txqi;
 
 	if (!txq)
 		return;
 
 	txqi = to_txq_info(txq);
+	sdata = vif_to_sdata(txq->vif);
+	fq = &sdata->local->fq;
 
 	/* Lock here to protect against further seqno updates on dequeue */
-	spin_lock_bh(&txqi->queue.lock);
+	spin_lock_bh(&fq->lock);
 	set_bit(IEEE80211_TXQ_STOP, &txqi->flags);
-	spin_unlock_bh(&txqi->queue.lock);
+	spin_unlock_bh(&fq->lock);
 }
 
 static void
diff --git a/net/mac80211/codel.h b/net/mac80211/codel.h
new file mode 100644
index 000000000000..f6f1b9b73a9a
--- /dev/null
+++ b/net/mac80211/codel.h
@@ -0,0 +1,260 @@
+#ifndef __NET_MAC80211_CODEL_H
+#define __NET_MAC80211_CODEL_H
+
+/*
+ * Codel - The Controlled-Delay Active Queue Management algorithm
+ *
+ *  Copyright (C) 2011-2012 Kathleen Nichols <nichols@pollere.com>
+ *  Copyright (C) 2011-2012 Van Jacobson <van@pollere.net>
+ *  Copyright (C) 2016 Michael D. Taht <dave.taht@bufferbloat.net>
+ *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2015 Jonathan Morton <chromatix99@gmail.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions, and the following disclaimer,
+ *    without modification.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. The names of the authors may not be used to endorse or promote products
+ *    derived from this software without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of the
+ * GPL apply INSTEAD OF those given above.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
+ *
+ */
+
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/ktime.h>
+#include <linux/skbuff.h>
+#include <net/pkt_sched.h>
+#include <net/inet_ecn.h>
+#include <linux/reciprocal_div.h>
+
+#include "codel_i.h"
+
+/* Controlling Queue Delay (CoDel) algorithm
+ * =========================================
+ * Source : Kathleen Nichols and Van Jacobson
+ * http://queue.acm.org/detail.cfm?id=2209336
+ *
+ * Implemented on linux by Dave Taht and Eric Dumazet
+ */
+
+/* CoDel5 uses a real clock, unlike codel */
+
+static inline codel_time_t codel_get_time(void)
+{
+	return ktime_get_ns();
+}
+
+static inline u32 codel_time_to_us(codel_time_t val)
+{
+	do_div(val, NSEC_PER_USEC);
+	return (u32)val;
+}
+
+/* sizeof_in_bits(rec_inv_sqrt) */
+#define REC_INV_SQRT_BITS (8 * sizeof(u16))
+/* needed shift to get a Q0.32 number from rec_inv_sqrt */
+#define REC_INV_SQRT_SHIFT (32 - REC_INV_SQRT_BITS)
+
+/* Newton approximation method needs more iterations at small inputs,
+ * so cache them.
+ */
+
+static void codel_vars_init(struct codel_vars *vars)
+{
+	memset(vars, 0, sizeof(*vars));
+}
+
+/*
+ * http://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Iterative_methods_for_reciprocal_square_roots
+ * new_invsqrt = (invsqrt / 2) * (3 - count * invsqrt^2)
+ *
+ * Here, invsqrt is a fixed point number (< 1.0), 32bit mantissa, aka Q0.32
+ */
+static inline void codel_Newton_step(struct codel_vars *vars)
+{
+	u32 invsqrt = ((u32)vars->rec_inv_sqrt) << REC_INV_SQRT_SHIFT;
+	u32 invsqrt2 = ((u64)invsqrt * invsqrt) >> 32;
+	u64 val = (3LL << 32) - ((u64)vars->count * invsqrt2);
+
+	val >>= 2; /* avoid overflow in following multiply */
+	val = (val * invsqrt) >> (32 - 2 + 1);
+
+	vars->rec_inv_sqrt = val >> REC_INV_SQRT_SHIFT;
+}
+
+/*
+ * CoDel control_law is t + interval/sqrt(count)
+ * We maintain in rec_inv_sqrt the reciprocal value of sqrt(count) to avoid
+ * both sqrt() and divide operation.
+ */
+static codel_time_t codel_control_law(codel_time_t t,
+				      codel_time_t interval,
+				      u32 rec_inv_sqrt)
+{
+	return t + reciprocal_scale(interval, rec_inv_sqrt <<
+				    REC_INV_SQRT_SHIFT);
+}
+
+/* Forward declaration of this for use elsewhere */
+
+static inline codel_time_t
+custom_codel_get_enqueue_time(struct sk_buff *skb);
+
+static inline struct sk_buff *
+custom_dequeue(struct codel_vars *vars, void *ptr);
+
+static inline void
+custom_drop(struct sk_buff *skb, void *ptr);
+
+static bool codel_should_drop(struct sk_buff *skb,
+			      __u32 *backlog,
+			      struct codel_vars *vars,
+			      const struct codel_params *p,
+			      codel_time_t now)
+{
+	if (!skb) {
+		vars->first_above_time = 0;
+		return false;
+	}
+
+	if (now - custom_codel_get_enqueue_time(skb) < p->target ||
+	    !*backlog) {
+		/* went below - stay below for at least interval */
+		vars->first_above_time = 0;
+		return false;
+	}
+
+	if (vars->first_above_time == 0) {
+		/* just went above from below; mark the time */
+		vars->first_above_time = now + p->interval;
+
+	} else if (now > vars->first_above_time) {
+		return true;
+	}
+
+	return false;
+}
+
+static struct sk_buff *codel_dequeue(void *ptr,
+				     __u32 *backlog,
+				     struct codel_vars *vars,
+				     struct codel_params *p,
+				     codel_time_t now,
+				     bool overloaded)
+{
+	struct sk_buff *skb = custom_dequeue(vars, ptr);
+	bool drop;
+
+	if (!skb) {
+		vars->dropping = false;
+		return skb;
+	}
+	drop = codel_should_drop(skb, backlog, vars, p, now);
+	if (vars->dropping) {
+		if (!drop) {
+			/* sojourn time below target - leave dropping state */
+			vars->dropping = false;
+		} else if (now >= vars->drop_next) {
+			/* It's time for the next drop. Drop the current
+			 * packet and dequeue the next. The dequeue might
+			 * take us out of dropping state.
+			 * If not, schedule the next drop.
+			 * A large backlog might result in drop rates so high
+			 * that the next drop should happen now,
+			 * hence the while loop.
+			 */
+
+			/* saturating increment */
+			vars->count++;
+			if (!vars->count)
+				vars->count--;
+
+			codel_Newton_step(vars);
+			vars->drop_next = codel_control_law(vars->drop_next,
+							    p->interval,
+							    vars->rec_inv_sqrt);
+			do {
+				if (INET_ECN_set_ce(skb) && !overloaded) {
+					vars->ecn_mark++;
+					/* and schedule the next drop */
+					vars->drop_next = codel_control_law(
+						vars->drop_next, p->interval,
+						vars->rec_inv_sqrt);
+					goto end;
+				}
+				custom_drop(skb, ptr);
+				vars->drop_count++;
+				skb = custom_dequeue(vars, ptr);
+				if (skb && !codel_should_drop(skb, backlog, vars,
+							      p, now)) {
+					/* leave dropping state */
+					vars->dropping = false;
+				} else {
+					/* schedule the next drop */
+					vars->drop_next = codel_control_law(
+						vars->drop_next, p->interval,
+						vars->rec_inv_sqrt);
+				}
+			} while (skb && vars->dropping && now >=
+				 vars->drop_next);
+
+			/* Mark the packet regardless */
+			if (skb && INET_ECN_set_ce(skb))
+				vars->ecn_mark++;
+		}
+	} else if (drop) {
+		if (INET_ECN_set_ce(skb) && !overloaded) {
+			vars->ecn_mark++;
+		} else {
+			custom_drop(skb, ptr);
+			vars->drop_count++;
+
+			skb = custom_dequeue(vars, ptr);
+			drop = codel_should_drop(skb, backlog, vars, p, now);
+			if (skb && INET_ECN_set_ce(skb))
+				vars->ecn_mark++;
+		}
+		vars->dropping = true;
+		/* if min went above target close to when we last went below
+		 * assume that the drop rate that controlled the queue on the
+		 * last cycle is a good starting point to control it now.
+		 */
+		if (vars->count > 2 &&
+		    now - vars->drop_next < 8 * p->interval) {
+			vars->count -= 2;
+			codel_Newton_step(vars);
+		} else {
+			vars->count = 1;
+			vars->rec_inv_sqrt = ~0U >> REC_INV_SQRT_SHIFT;
+		}
+		codel_Newton_step(vars);
+		vars->drop_next = codel_control_law(now, p->interval,
+						    vars->rec_inv_sqrt);
+	}
+end:
+	return skb;
+}
+#endif
diff --git a/net/mac80211/codel_i.h b/net/mac80211/codel_i.h
new file mode 100644
index 000000000000..83da7aa5fd9a
--- /dev/null
+++ b/net/mac80211/codel_i.h
@@ -0,0 +1,89 @@
+#ifndef __NET_MAC80211_CODEL_I_H
+#define __NET_MAC80211_CODEL_I_H
+
+/*
+ * Codel - The Controlled-Delay Active Queue Management algorithm
+ *
+ *  Copyright (C) 2011-2012 Kathleen Nichols <nichols@pollere.com>
+ *  Copyright (C) 2011-2012 Van Jacobson <van@pollere.net>
+ *  Copyright (C) 2016 Michael D. Taht <dave.taht@bufferbloat.net>
+ *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2015 Jonathan Morton <chromatix99@gmail.com>
+ *  Copyright (C) 2016 Michal Kazior <michal.kazior@tieto.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions, and the following disclaimer,
+ *    without modification.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. The names of the authors may not be used to endorse or promote products
+ *    derived from this software without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of the
+ * GPL apply INSTEAD OF those given above.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
+ *
+ */
+
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/ktime.h>
+#include <linux/skbuff.h>
+#include <net/pkt_sched.h>
+#include <net/inet_ecn.h>
+#include <linux/reciprocal_div.h>
+
+/* Controlling Queue Delay (CoDel) algorithm
+ * =========================================
+ * Source : Kathleen Nichols and Van Jacobson
+ * http://queue.acm.org/detail.cfm?id=2209336
+ *
+ * Implemented on linux by Dave Taht and Eric Dumazet
+ */
+
+/* CoDel5 uses a real clock, unlike codel */
+
+#define MS2TIME(a) (a * (u64) NSEC_PER_MSEC)
+#define US2TIME(a) (a * (u64) NSEC_PER_USEC)
+
+/**
+ * struct codel_vars - contains codel variables
+ * @count:		how many drops we've done since the last time we
+ *			entered dropping state
+ * @dropping:		set to > 0 if in dropping state
+ * @rec_inv_sqrt:	reciprocal value of sqrt(count) >> 1
+ * @first_above_time:	when we went (or will go) continuously above target
+ *			for interval
+ * @drop_next:		time to drop next packet, or when we dropped last
+ * @drop_count:	temp count of dropped packets in dequeue()
+ * @ecn_mark:	number of packets we ECN marked instead of dropping
+ */
+
+struct codel_vars {
+	u32		count;
+	u16		dropping;
+	u16		rec_inv_sqrt;
+	codel_time_t	first_above_time;
+	codel_time_t	drop_next;
+	u16		drop_count;
+	u16		ecn_mark;
+};
+#endif
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index a96f8c0461f6..c099b81d5a27 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -802,9 +802,12 @@ enum txq_info_flags {
 };
 
 struct txq_info {
-	struct sk_buff_head queue;
+	struct txq_flow flow;
+	struct list_head new_flows;
+	struct list_head old_flows;
+	u32 backlog_bytes;
+	u32 backlog_packets;
 	unsigned long flags;
-	unsigned long byte_cnt;
 
 	/* keep last! */
 	struct ieee80211_txq txq;
@@ -852,7 +855,6 @@ struct ieee80211_sub_if_data {
 	bool control_port_no_encrypt;
 	int encrypt_headroom;
 
-	atomic_t txqs_len[IEEE80211_NUM_ACS];
 	struct ieee80211_tx_queue_params tx_conf[IEEE80211_NUM_ACS];
 	struct mac80211_qos_map __rcu *qos_map;
 
@@ -1089,11 +1091,25 @@ enum mac80211_scan_state {
 	SCAN_ABORT,
 };
 
+struct ieee80211_fq {
+	struct txq_flow *flows;
+	struct list_head backlogs;
+	spinlock_t lock;
+	u32 flows_cnt;
+	u32 perturbation;
+	u32 quantum;
+	u32 backlog;
+
+	u32 drop_overlimit;
+	u32 drop_codel;
+};
+
 struct ieee80211_local {
 	/* embed the driver visible part.
 	 * don't cast (use the static inlines below), but we keep
 	 * it first anyway so they become a no-op */
 	struct ieee80211_hw hw;
+	struct ieee80211_fq fq;
 
 	const struct ieee80211_ops *ops;
 
@@ -1935,6 +1951,11 @@ static inline bool ieee80211_can_run_worker(struct ieee80211_local *local)
 void ieee80211_init_tx_queue(struct ieee80211_sub_if_data *sdata,
 			     struct sta_info *sta,
 			     struct txq_info *txq, int tid);
+void ieee80211_purge_txq(struct ieee80211_local *local, struct txq_info *txqi);
+void ieee80211_init_flow(struct txq_flow *flow);
+int ieee80211_setup_flows(struct ieee80211_local *local);
+void ieee80211_teardown_flows(struct ieee80211_local *local);
+
 void ieee80211_send_auth(struct ieee80211_sub_if_data *sdata,
 			 u16 transaction, u16 auth_alg, u16 status,
 			 const u8 *extra, size_t extra_len, const u8 *bssid,
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 453b4e741780..d1063b50f12c 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -779,6 +779,7 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 			      bool going_down)
 {
 	struct ieee80211_local *local = sdata->local;
+	struct ieee80211_fq *fq = &local->fq;
 	unsigned long flags;
 	struct sk_buff *skb, *tmp;
 	u32 hw_reconf_flags = 0;
@@ -977,12 +978,9 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 	if (sdata->vif.txq) {
 		struct txq_info *txqi = to_txq_info(sdata->vif.txq);
 
-		spin_lock_bh(&txqi->queue.lock);
-		ieee80211_purge_tx_queue(&local->hw, &txqi->queue);
-		txqi->byte_cnt = 0;
-		spin_unlock_bh(&txqi->queue.lock);
-
-		atomic_set(&sdata->txqs_len[txqi->txq.ac], 0);
+		spin_lock_bh(&fq->lock);
+		ieee80211_purge_txq(local, txqi);
+		spin_unlock_bh(&fq->lock);
 	}
 
 	if (local->open_count == 0)
@@ -1198,6 +1196,13 @@ static void ieee80211_if_setup(struct net_device *dev)
 	dev->destructor = ieee80211_if_free;
 }
 
+static void ieee80211_if_setup_no_queue(struct net_device *dev)
+{
+	ieee80211_if_setup(dev);
+	dev->priv_flags |= IFF_NO_QUEUE;
+	/* Note for backporters: use dev->tx_queue_len = 0 instead of IFF_ */
+}
+
 static void ieee80211_iface_work(struct work_struct *work)
 {
 	struct ieee80211_sub_if_data *sdata =
@@ -1707,6 +1712,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 	struct net_device *ndev = NULL;
 	struct ieee80211_sub_if_data *sdata = NULL;
 	struct txq_info *txqi;
+	void (*if_setup)(struct net_device *dev);
 	int ret, i;
 	int txqs = 1;
 
@@ -1734,12 +1740,17 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 			txq_size += sizeof(struct txq_info) +
 				    local->hw.txq_data_size;
 
+		if (local->ops->wake_tx_queue)
+			if_setup = ieee80211_if_setup_no_queue;
+		else
+			if_setup = ieee80211_if_setup;
+
 		if (local->hw.queues >= IEEE80211_NUM_ACS)
 			txqs = IEEE80211_NUM_ACS;
 
 		ndev = alloc_netdev_mqs(size + txq_size,
 					name, name_assign_type,
-					ieee80211_if_setup, txqs, 1);
+					if_setup, txqs, 1);
 		if (!ndev)
 			return -ENOMEM;
 		dev_net_set(ndev, wiphy_net(local->hw.wiphy));
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 8190bf27ebff..9fd3b10ae52b 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1053,9 +1053,6 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 	local->dynamic_ps_forced_timeout = -1;
 
-	if (!local->hw.txq_ac_max_pending)
-		local->hw.txq_ac_max_pending = 64;
-
 	result = ieee80211_wep_init(local);
 	if (result < 0)
 		wiphy_debug(local->hw.wiphy, "Failed to initialize wep: %d\n",
@@ -1087,6 +1084,10 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 	rtnl_unlock();
 
+	result = ieee80211_setup_flows(local);
+	if (result)
+		goto fail_flows;
+
 #ifdef CONFIG_INET
 	local->ifa_notifier.notifier_call = ieee80211_ifa_changed;
 	result = register_inetaddr_notifier(&local->ifa_notifier);
@@ -1112,6 +1113,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 #if defined(CONFIG_INET) || defined(CONFIG_IPV6)
  fail_ifa:
 #endif
+	ieee80211_teardown_flows(local);
+ fail_flows:
 	rtnl_lock();
 	rate_control_deinitialize(local);
 	ieee80211_remove_interfaces(local);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 664e8861edbe..66c36dc389ec 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1248,7 +1248,7 @@ static void sta_ps_start(struct sta_info *sta)
 	for (tid = 0; tid < ARRAY_SIZE(sta->sta.txq); tid++) {
 		struct txq_info *txqi = to_txq_info(sta->sta.txq[tid]);
 
-		if (!skb_queue_len(&txqi->queue))
+		if (!txqi->backlog_packets)
 			set_bit(tid, &sta->txq_buffered_tids);
 		else
 			clear_bit(tid, &sta->txq_buffered_tids);
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 7bbcf5919fe4..456c9fb113fb 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -112,11 +112,7 @@ static void __cleanup_single_sta(struct sta_info *sta)
 	if (sta->sta.txq[0]) {
 		for (i = 0; i < ARRAY_SIZE(sta->sta.txq); i++) {
 			struct txq_info *txqi = to_txq_info(sta->sta.txq[i]);
-			int n = skb_queue_len(&txqi->queue);
-
-			ieee80211_purge_tx_queue(&local->hw, &txqi->queue);
-			atomic_sub(n, &sdata->txqs_len[txqi->txq.ac]);
-			txqi->byte_cnt = 0;
+			ieee80211_purge_txq(local, txqi);
 		}
 	}
 
@@ -1185,7 +1181,7 @@ void ieee80211_sta_ps_deliver_wakeup(struct sta_info *sta)
 		for (i = 0; i < ARRAY_SIZE(sta->sta.txq); i++) {
 			struct txq_info *txqi = to_txq_info(sta->sta.txq[i]);
 
-			if (!skb_queue_len(&txqi->queue))
+			if (!txqi->backlog_packets)
 				continue;
 
 			drv_wake_tx_queue(local, txqi);
@@ -1622,7 +1618,7 @@ ieee80211_sta_ps_deliver_response(struct sta_info *sta,
 		for (tid = 0; tid < ARRAY_SIZE(sta->sta.txq); tid++) {
 			struct txq_info *txqi = to_txq_info(sta->sta.txq[tid]);
 
-			if (!(tids & BIT(tid)) || skb_queue_len(&txqi->queue))
+			if (!(tids & BIT(tid)) || txqi->backlog_packets)
 				continue;
 
 			sta_info_recalc_tim(sta);
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index f4d38994ecee..65431ea5a78d 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -19,6 +19,7 @@
 #include <linux/etherdevice.h>
 #include <linux/rhashtable.h>
 #include "key.h"
+#include "codel_i.h"
 
 /**
  * enum ieee80211_sta_info_flags - Stations flags
@@ -327,6 +328,32 @@ struct mesh_sta {
 
 DECLARE_EWMA(signal, 1024, 8)
 
+struct txq_info;
+
+/**
+ * struct txq_flow - per traffic flow queue
+ *
+ * This structure is used to distinguish and queue different traffic flows
+ * separately for fair queueing/AQM purposes.
+ *
+ * @txqi: txq_info structure it is associated at given time
+ * @flowchain: can be linked to other flows for RR purposes
+ * @backlogchain: can be linked to other flows for backlog sorting purposes
+ * @queue: sk_buff queue
+ * @cvars: codel state vars
+ * @backlog: number of bytes pending in the queue
+ * @deficit: used for fair queueing balancing
+ */
+struct txq_flow {
+	struct txq_info *txqi;
+	struct list_head flowchain;
+	struct list_head backlogchain;
+	struct sk_buff_head queue;
+	struct codel_vars cvars;
+	u32 backlog;
+	u32 deficit;
+};
+
 /**
  * struct sta_info - STA information
  *
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index af584f7cdd63..f42f898cb8b5 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -34,6 +34,7 @@
 #include "wpa.h"
 #include "wme.h"
 #include "rate.h"
+#include "codel.h"
 
 /* misc utils */
 
@@ -1228,26 +1229,312 @@ ieee80211_tx_prepare(struct ieee80211_sub_if_data *sdata,
 	return TX_CONTINUE;
 }
 
-static void ieee80211_drv_tx(struct ieee80211_local *local,
-			     struct ieee80211_vif *vif,
-			     struct ieee80211_sta *pubsta,
-			     struct sk_buff *skb)
+static inline codel_time_t
+custom_codel_get_enqueue_time(struct sk_buff *skb)
+{
+	return IEEE80211_SKB_CB(skb)->control.enqueue_time;
+}
+
+static inline struct sk_buff *
+flow_dequeue(struct ieee80211_local *local, struct txq_flow *flow)
+{
+	struct ieee80211_fq *fq = &local->fq;
+	struct txq_info *txqi = flow->txqi;
+	struct txq_flow *i;
+	struct sk_buff *skb;
+
+	skb = __skb_dequeue(&flow->queue);
+	if (!skb)
+		return NULL;
+
+	txqi->backlog_bytes -= skb->len;
+	txqi->backlog_packets--;
+	flow->backlog -= skb->len;
+	fq->backlog--;
+
+	if (flow->backlog == 0) {
+		list_del_init(&flow->backlogchain);
+	} else {
+		i = flow;
+
+		list_for_each_entry_continue(i, &fq->backlogs, backlogchain) {
+			if (i->backlog < flow->backlog)
+				break;
+		}
+
+		list_move_tail(&flow->backlogchain, &i->backlogchain);
+	}
+
+	return skb;
+}
+
+static inline struct sk_buff *
+custom_dequeue(struct codel_vars *vars, void *ptr)
+{
+	struct txq_flow *flow = ptr;
+	struct txq_info *txqi = flow->txqi;
+	struct ieee80211_vif *vif = txqi->txq.vif;
+	struct ieee80211_sub_if_data *sdata = vif_to_sdata(vif);
+	struct ieee80211_local *local = sdata->local;
+
+	return flow_dequeue(local, flow);
+}
+
+static inline void
+custom_drop(struct sk_buff *skb, void *ptr)
+{
+	struct txq_flow *flow = ptr;
+	struct txq_info *txqi = flow->txqi;
+	struct ieee80211_vif *vif = txqi->txq.vif;
+	struct ieee80211_sub_if_data *sdata = vif_to_sdata(vif);
+	struct ieee80211_local *local = sdata->local;
+	struct ieee80211_hw *hw = &local->hw;
+
+	ieee80211_free_txskb(hw, skb);
+	local->fq.drop_codel++;
+}
+
+static u32 fq_hash(struct ieee80211_fq *fq, struct sk_buff *skb)
+{
+	u32 hash = skb_get_hash_perturb(skb, fq->perturbation);
+	return reciprocal_scale(hash, fq->flows_cnt);
+}
+
+static void fq_drop(struct ieee80211_local *local)
+{
+	struct ieee80211_hw *hw = &local->hw;
+	struct ieee80211_fq *fq = &local->fq;
+	struct txq_flow *flow;
+	struct sk_buff *skb;
+
+	flow = list_first_entry_or_null(&fq->backlogs, struct txq_flow,
+					backlogchain);
+	if (WARN_ON_ONCE(!flow))
+		return;
+
+	skb = flow_dequeue(local, flow);
+	if (WARN_ON_ONCE(!skb))
+		return;
+
+	ieee80211_free_txskb(hw, skb);
+	fq->drop_overlimit++;
+}
+
+void ieee80211_init_flow(struct txq_flow *flow)
+{
+	INIT_LIST_HEAD(&flow->flowchain);
+	INIT_LIST_HEAD(&flow->backlogchain);
+	__skb_queue_head_init(&flow->queue);
+	codel_vars_init(&flow->cvars);
+}
+
+int ieee80211_setup_flows(struct ieee80211_local *local)
+{
+	struct ieee80211_fq *fq = &local->fq;
+	int i;
+
+	if (!local->ops->wake_tx_queue)
+		return 0;
+
+	if (!local->hw.txq_limit)
+		local->hw.txq_limit = 8192;
+
+	if (!local->hw.txq_cparams.target)
+		local->hw.txq_cparams.target = MS2TIME(5);
+
+	if (!local->hw.txq_cparams.interval)
+		local->hw.txq_cparams.interval = MS2TIME(100);
+
+	memset(fq, 0, sizeof(fq[0]));
+	INIT_LIST_HEAD(&fq->backlogs);
+	spin_lock_init(&fq->lock);
+	fq->flows_cnt = 4096;
+	fq->perturbation = prandom_u32();
+	fq->quantum = 300;
+
+	fq->flows = kzalloc(fq->flows_cnt * sizeof(fq->flows[0]), GFP_KERNEL);
+	if (!fq->flows)
+		return -ENOMEM;
+
+	for (i = 0; i < fq->flows_cnt; i++)
+		ieee80211_init_flow(&fq->flows[i]);
+
+	return 0;
+}
+
+static void ieee80211_reset_flow(struct ieee80211_local *local,
+				 struct txq_flow *flow)
+{
+	if (!list_empty(&flow->flowchain))
+		list_del_init(&flow->flowchain);
+
+	if (!list_empty(&flow->backlogchain))
+		list_del_init(&flow->backlogchain);
+
+	ieee80211_purge_tx_queue(&local->hw, &flow->queue);
+
+	flow->deficit = 0;
+	flow->txqi = NULL;
+}
+
+void ieee80211_purge_txq(struct ieee80211_local *local, struct txq_info *txqi)
+{
+	struct txq_flow *flow;
+	int i;
+
+	for (i = 0; i < local->fq.flows_cnt; i++) {
+		flow = &local->fq.flows[i];
+
+		if (flow->txqi != txqi)
+			continue;
+
+		ieee80211_reset_flow(local, flow);
+	}
+
+	ieee80211_reset_flow(local, &txqi->flow);
+
+	txqi->backlog_bytes = 0;
+	txqi->backlog_packets = 0;
+}
+
+void ieee80211_teardown_flows(struct ieee80211_local *local)
+{
+	struct ieee80211_fq *fq = &local->fq;
+	struct ieee80211_sub_if_data *sdata;
+	struct sta_info *sta;
+	int i;
+
+	if (!local->ops->wake_tx_queue)
+		return;
+
+	list_for_each_entry_rcu(sta, &local->sta_list, list)
+		for (i = 0; i < IEEE80211_NUM_TIDS; i++)
+			ieee80211_purge_txq(local,
+					    to_txq_info(sta->sta.txq[i]));
+
+	list_for_each_entry_rcu(sdata, &local->interfaces, list)
+		ieee80211_purge_txq(local, to_txq_info(sdata->vif.txq));
+
+	for (i = 0; i < fq->flows_cnt; i++)
+		ieee80211_reset_flow(local, &fq->flows[i]);
+
+	kfree(fq->flows);
+
+	fq->flows = NULL;
+	fq->flows_cnt = 0;
+}
+
+static void ieee80211_txq_enqueue(struct ieee80211_local *local,
+				  struct txq_info *txqi,
+				  struct sk_buff *skb)
+{
+	struct ieee80211_fq *fq = &local->fq;
+	struct ieee80211_hw *hw = &local->hw;
+	struct txq_flow *flow;
+	struct txq_flow *i;
+	size_t idx = fq_hash(fq, skb);
+
+	flow = &fq->flows[idx];
+
+	if (flow->txqi)
+		flow = &txqi->flow;
+
+	/* The following overwrites `vif` pointer effectively. It is later
+	 * restored using txq structure.
+	 */
+	IEEE80211_SKB_CB(skb)->control.enqueue_time = codel_get_time();
+
+	flow->txqi = txqi;
+	flow->backlog += skb->len;
+	txqi->backlog_bytes += skb->len;
+	txqi->backlog_packets++;
+	fq->backlog++;
+
+	if (list_empty(&flow->backlogchain))
+		i = list_last_entry(&fq->backlogs, struct txq_flow, backlogchain);
+	else
+		i = flow;
+
+	list_for_each_entry_continue_reverse(i, &fq->backlogs, backlogchain)
+		if (i->backlog > flow->backlog)
+			break;
+
+	list_move(&flow->backlogchain, &i->backlogchain);
+
+	if (list_empty(&flow->flowchain)) {
+		flow->deficit = fq->quantum;
+		list_add_tail(&flow->flowchain, &txqi->new_flows);
+	}
+
+	__skb_queue_tail(&flow->queue, skb);
+
+	if (fq->backlog > hw->txq_limit)
+		fq_drop(local);
+}
+
+static struct sk_buff *ieee80211_txq_dequeue(struct ieee80211_local *local,
+					     struct txq_info *txqi)
+{
+	struct ieee80211_fq *fq = &local->fq;
+	struct ieee80211_hw *hw = &local->hw;
+	struct txq_flow *flow;
+	struct list_head *head;
+	struct sk_buff *skb;
+
+begin:
+	head = &txqi->new_flows;
+	if (list_empty(head)) {
+		head = &txqi->old_flows;
+		if (list_empty(head))
+			return NULL;
+	}
+
+	flow = list_first_entry(head, struct txq_flow, flowchain);
+
+	if (flow->deficit <= 0) {
+		flow->deficit += fq->quantum;
+		list_move_tail(&flow->flowchain, &txqi->old_flows);
+		goto begin;
+	}
+
+	skb = codel_dequeue(flow, &flow->backlog, &flow->cvars,
+			    &hw->txq_cparams, codel_get_time(), false);
+	if (!skb) {
+		if ((head == &txqi->new_flows) &&
+		    !list_empty(&txqi->old_flows)) {
+			list_move_tail(&flow->flowchain, &txqi->old_flows);
+		} else {
+			list_del_init(&flow->flowchain);
+			flow->txqi = NULL;
+		}
+		goto begin;
+	}
+
+	flow->deficit -= skb->len;
+
+	/* The `vif` pointer was overwritten with enqueue time during
+	 * enqueuing. Restore it before handing to driver.
+	 */
+	IEEE80211_SKB_CB(skb)->control.vif = flow->txqi->txq.vif;
+
+	return skb;
+}
+
+static struct txq_info *
+ieee80211_get_txq(struct ieee80211_local *local,
+		  struct ieee80211_vif *vif,
+		  struct ieee80211_sta *pubsta,
+		  struct sk_buff *skb)
 {
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-	struct ieee80211_sub_if_data *sdata = vif_to_sdata(vif);
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
-	struct ieee80211_tx_control control = {
-		.sta = pubsta,
-	};
 	struct ieee80211_txq *txq = NULL;
-	struct txq_info *txqi;
-	u8 ac;
 
 	if (info->control.flags & IEEE80211_TX_CTRL_PS_RESPONSE)
-		goto tx_normal;
+		return NULL;
 
 	if (!ieee80211_is_data(hdr->frame_control))
-		goto tx_normal;
+		return NULL;
 
 	if (pubsta) {
 		u8 tid = skb->priority & IEEE80211_QOS_CTL_TID_MASK;
@@ -1258,52 +1545,29 @@ static void ieee80211_drv_tx(struct ieee80211_local *local,
 	}
 
 	if (!txq)
-		goto tx_normal;
+		return NULL;
 
-	ac = txq->ac;
-	txqi = to_txq_info(txq);
-	atomic_inc(&sdata->txqs_len[ac]);
-	if (atomic_read(&sdata->txqs_len[ac]) >= local->hw.txq_ac_max_pending)
-		netif_stop_subqueue(sdata->dev, ac);
-
-	spin_lock_bh(&txqi->queue.lock);
-	txqi->byte_cnt += skb->len;
-	__skb_queue_tail(&txqi->queue, skb);
-	spin_unlock_bh(&txqi->queue.lock);
-
-	drv_wake_tx_queue(local, txqi);
-
-	return;
-
-tx_normal:
-	drv_tx(local, &control, skb);
+	return to_txq_info(txq);
 }
 
 struct sk_buff *ieee80211_tx_dequeue(struct ieee80211_hw *hw,
 				     struct ieee80211_txq *txq)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
-	struct ieee80211_sub_if_data *sdata = vif_to_sdata(txq->vif);
+	struct ieee80211_fq *fq = &local->fq;
 	struct txq_info *txqi = container_of(txq, struct txq_info, txq);
 	struct ieee80211_hdr *hdr;
 	struct sk_buff *skb = NULL;
-	u8 ac = txq->ac;
 
-	spin_lock_bh(&txqi->queue.lock);
+	spin_lock_bh(&fq->lock);
 
 	if (test_bit(IEEE80211_TXQ_STOP, &txqi->flags))
 		goto out;
 
-	skb = __skb_dequeue(&txqi->queue);
+	skb = ieee80211_txq_dequeue(local, txqi);
 	if (!skb)
 		goto out;
 
-	txqi->byte_cnt -= skb->len;
-
-	atomic_dec(&sdata->txqs_len[ac]);
-	if (__netif_subqueue_stopped(sdata->dev, ac))
-		ieee80211_propagate_queue_wake(local, sdata->vif.hw_queue[ac]);
-
 	hdr = (struct ieee80211_hdr *)skb->data;
 	if (txq->sta && ieee80211_is_data_qos(hdr->frame_control)) {
 		struct sta_info *sta = container_of(txq->sta, struct sta_info,
@@ -1318,7 +1582,7 @@ struct sk_buff *ieee80211_tx_dequeue(struct ieee80211_hw *hw,
 	}
 
 out:
-	spin_unlock_bh(&txqi->queue.lock);
+	spin_unlock_bh(&fq->lock);
 
 	return skb;
 }
@@ -1330,7 +1594,10 @@ static bool ieee80211_tx_frags(struct ieee80211_local *local,
 			       struct sk_buff_head *skbs,
 			       bool txpending)
 {
+	struct ieee80211_fq *fq = &local->fq;
+	struct ieee80211_tx_control control = {};
 	struct sk_buff *skb, *tmp;
+	struct txq_info *txqi;
 	unsigned long flags;
 
 	skb_queue_walk_safe(skbs, skb, tmp) {
@@ -1345,6 +1612,24 @@ static bool ieee80211_tx_frags(struct ieee80211_local *local,
 		}
 #endif
 
+		/* XXX: This changes behavior for offchan-tx. Is this really a
+		 *      problem with per-sta-tid queueing now?
+		 */
+		txqi = ieee80211_get_txq(local, vif, sta, skb);
+		if (txqi) {
+			info->control.vif = vif;
+
+			__skb_unlink(skb, skbs);
+
+			spin_lock_bh(&fq->lock);
+			ieee80211_txq_enqueue(local, txqi, skb);
+			spin_unlock_bh(&fq->lock);
+
+			drv_wake_tx_queue(local, txqi);
+
+			continue;
+		}
+
 		spin_lock_irqsave(&local->queue_stop_reason_lock, flags);
 		if (local->queue_stop_reasons[q] ||
 		    (!txpending && !skb_queue_empty(&local->pending[q]))) {
@@ -1387,9 +1672,10 @@ static bool ieee80211_tx_frags(struct ieee80211_local *local,
 		spin_unlock_irqrestore(&local->queue_stop_reason_lock, flags);
 
 		info->control.vif = vif;
+		control.sta = sta;
 
 		__skb_unlink(skb, skbs);
-		ieee80211_drv_tx(local, vif, sta, skb);
+		drv_tx(local, &control, skb);
 	}
 
 	return true;
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 323d300878ca..0d33cb7339a2 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -244,6 +244,9 @@ void ieee80211_propagate_queue_wake(struct ieee80211_local *local, int queue)
 	struct ieee80211_sub_if_data *sdata;
 	int n_acs = IEEE80211_NUM_ACS;
 
+	if (local->ops->wake_tx_queue)
+		return;
+
 	if (local->hw.queues < IEEE80211_NUM_ACS)
 		n_acs = 1;
 
@@ -260,11 +263,6 @@ void ieee80211_propagate_queue_wake(struct ieee80211_local *local, int queue)
 		for (ac = 0; ac < n_acs; ac++) {
 			int ac_queue = sdata->vif.hw_queue[ac];
 
-			if (local->ops->wake_tx_queue &&
-			    (atomic_read(&sdata->txqs_len[ac]) >
-			     local->hw.txq_ac_max_pending))
-				continue;
-
 			if (ac_queue == queue ||
 			    (sdata->vif.cab_queue == queue &&
 			     local->queue_stop_reasons[ac_queue] == 0 &&
@@ -352,6 +350,9 @@ static void __ieee80211_stop_queue(struct ieee80211_hw *hw, int queue,
 	if (__test_and_set_bit(reason, &local->queue_stop_reasons[queue]))
 		return;
 
+	if (local->ops->wake_tx_queue)
+		return;
+
 	if (local->hw.queues < IEEE80211_NUM_ACS)
 		n_acs = 1;
 
@@ -3364,8 +3365,11 @@ void ieee80211_init_tx_queue(struct ieee80211_sub_if_data *sdata,
 			     struct sta_info *sta,
 			     struct txq_info *txqi, int tid)
 {
-	skb_queue_head_init(&txqi->queue);
+	INIT_LIST_HEAD(&txqi->old_flows);
+	INIT_LIST_HEAD(&txqi->new_flows);
+	ieee80211_init_flow(&txqi->flow);
 	txqi->txq.vif = &sdata->vif;
+	txqi->flow.txqi = txqi;
 
 	if (sta) {
 		txqi->txq.sta = &sta->sta;
@@ -3386,9 +3390,9 @@ void ieee80211_txq_get_depth(struct ieee80211_txq *txq,
 	struct txq_info *txqi = to_txq_info(txq);
 
 	if (frame_cnt)
-		*frame_cnt = txqi->queue.qlen;
+		*frame_cnt = txqi->backlog_packets;
 
 	if (byte_cnt)
-		*byte_cnt = txqi->byte_cnt;
+		*byte_cnt = txqi->backlog_bytes;
 }
 EXPORT_SYMBOL(ieee80211_txq_get_depth);
-- 
2.1.4
