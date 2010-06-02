From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2 net-next-2.6] net: QDISC_STATE_RUNNING dont need atomic
 bit ops
Date: Wed, 02 Jun 2010 11:50:33 +0200
Message-ID: <1275472233.2725.146.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	 <1269377667.2915.25.camel@edumazet-laptop>
	 <20100323.144512.140757007.davem@davemloft.net>
	 <1269382380.2915.40.camel@edumazet-laptop>
	 <20100521084349.0d6f8f9a@nehalam>
	 <1274460275.2439.469.camel@edumazet-laptop>
	 <1274463643.2439.473.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54412 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286Ab0FBJui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 05:50:38 -0400
Received: by wyi11 with SMTP id 11so1705787wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 02:50:36 -0700 (PDT)
In-Reply-To: <1274463643.2439.473.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__QDISC_STATE_RUNNING is always changed while qdisc lock is held.

We can avoid two atomic operations in xmit path, if we move this bit in
a new __state container.

Location of this __state container is carefully chosen so that fast path
only dirties one qdisc cache line.

THROTTLED bit could later be moved into this __state location too, to
avoid dirtying first qdisc cache line.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sch_generic.h |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9707dae..b3591e4 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -23,11 +23,17 @@ struct qdisc_rate_table {
 };
 
 enum qdisc_state_t {
-	__QDISC_STATE_RUNNING,
 	__QDISC_STATE_SCHED,
 	__QDISC_STATE_DEACTIVATED,
 };
 
+/*
+ * following bits are only changed while qdisc lock is held
+ */
+enum qdisc___state_t {
+	__QDISC___STATE_RUNNING,
+};
+
 struct qdisc_size_table {
 	struct list_head	list;
 	struct tc_sizespec	szopts;
@@ -72,23 +78,24 @@ struct Qdisc {
 	unsigned long		state;
 	struct sk_buff_head	q;
 	struct gnet_stats_basic_packed bstats;
+	unsigned long		__state;
 	struct gnet_stats_queue	qstats;
 	struct rcu_head     rcu_head;
 };
 
 static inline bool qdisc_is_running(struct Qdisc *qdisc)
 {
-	return test_bit(__QDISC_STATE_RUNNING, &qdisc->state);
+	return test_bit(__QDISC___STATE_RUNNING, &qdisc->__state);
 }
 
 static inline bool qdisc_run_begin(struct Qdisc *qdisc)
 {
-	return !test_and_set_bit(__QDISC_STATE_RUNNING, &qdisc->state);
+	return !__test_and_set_bit(__QDISC___STATE_RUNNING, &qdisc->__state);
 }
 
 static inline void qdisc_run_end(struct Qdisc *qdisc)
 {
-	clear_bit(__QDISC_STATE_RUNNING, &qdisc->state);
+	__clear_bit(__QDISC___STATE_RUNNING, &qdisc->__state);
 }
 
 struct Qdisc_class_ops {


