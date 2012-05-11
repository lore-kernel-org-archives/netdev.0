From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fq_codel: Fair Queue Codel AQM
Date: Fri, 11 May 2012 15:59:56 +0200
Message-ID: <1336744796.31653.164.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <van@pollere.net>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42009 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759901Ab2EKOAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 10:00:02 -0400
Received: by bkcji2 with SMTP id ji2so2263928bkc.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 07:00:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fair Queue Codel implementation.

Principles :

- Packets are classified (internal classifier or external) on flows.
- This is a Stochastic model (as we use a hash, several flows might
                              be hashed on same slot)
- Each flow has a CoDel managed queue.
- Flows are linked onto two (Round Robin) lists,
  so that new flows have priority on old ones.

- For a given flow, packets are not reordered (CoDel uses a FIFO)
- head drops only.
- ECN capability is on by default.
- Very low memory footprint (64 bytes per flow)

tc qdisc ... fq_codel [ limit PACKETS ] [ flows number ]
                      [ target TIME ] [ interval TIME ] [ noecn ]

defaults : 1024 flows, 10240 packets limit

Impressive results on load :

# tc -s -d class show dev eth9

class htb 1:1 root leaf 10: prio 0 quantum 1514 rate 200000Kbit ceil 200000Kbit burst 1475b/8 mpu 0b overhead 0b cburst 1475b/8 mpu 0b overhead 0b level 0 
 Sent 1267974946 bytes 837585 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 202298Kbit 16702pps backlog 0b 103p requeues 0 
 lended: 837482 borrowed: 0 giants: 0
 tokens: -912 ctokens: -912

class fq_codel 10:a7 parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 18168b 12p requeues 0 
  deficit 1514 count 1 lastcount 1 ldelay 7.0ms
class fq_codel 10:10b parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 16654b 11p requeues 0 
  deficit 1514 count 1 lastcount 1 ldelay 6.4ms
class fq_codel 10:146 parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 13626b 9p requeues 0 
  deficit 1514 count 1 lastcount 1 ldelay 5.2ms
class fq_codel 10:1c0 parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 12112b 8p requeues 0 
  deficit 1514 count 1 lastcount 1 ldelay 2.8ms
class fq_codel 10:2ba parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 13626b 9p requeues 0 
  deficit 926 count 1 lastcount 1 ldelay 5.2ms
class fq_codel 10:31d parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 16654b 11p requeues 0 
  deficit 0 count 1 lastcount 1 ldelay 6.4ms
class fq_codel 10:32c parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 15140b 10p requeues 0 
  deficit 80 count 1 lastcount 1 ldelay 6.4ms
class fq_codel 10:342 parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 16654b 11p requeues 0 
  deficit 1514 count 1 lastcount 1 ldelay 6.4ms
class fq_codel 10:3ab parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 18168b 12p requeues 0 
  deficit 1514 count 1 lastcount 1 ldelay 7.0ms
class fq_codel 10:3c2 parent 10: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 15140b 10p requeues 0 
  deficit 1514 count 1 lastcount 1 ldelay 6.4ms

# tc -s -d qdisc show dev eth9

qdisc htb 1: root refcnt 6 r2q 10 default 1 direct_packets_stat 0 ver 3.17
 Sent 1267878050 bytes 837521 pkt (dropped 0, overlimits 1666567 requeues 1) 
 rate 202305Kbit 16703pps backlog 0b 104p requeues 1 
qdisc fq_codel 10: parent 1:1 limit 10240p target 5.0ms interval 100.0ms ecn 
 Sent 1267878050 bytes 837521 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 202305Kbit 16703pps backlog 157456b 104p requeues 0 
  maxpacket 1514 drop_overlimit 0 new_flow_count 87 ecn_mark 4071
  new_flows_len 0 old_flows_len 10

# ping -c 10 172.30.42.18
PING 172.30.42.18 (172.30.42.18) 56(84) bytes of data.
64 bytes from 172.30.42.18: icmp_req=1 ttl=64 time=0.227 ms
64 bytes from 172.30.42.18: icmp_req=2 ttl=64 time=0.165 ms
64 bytes from 172.30.42.18: icmp_req=3 ttl=64 time=0.166 ms
64 bytes from 172.30.42.18: icmp_req=4 ttl=64 time=0.151 ms
64 bytes from 172.30.42.18: icmp_req=5 ttl=64 time=0.164 ms
64 bytes from 172.30.42.18: icmp_req=6 ttl=64 time=0.172 ms
64 bytes from 172.30.42.18: icmp_req=7 ttl=64 time=0.175 ms
64 bytes from 172.30.42.18: icmp_req=8 ttl=64 time=0.183 ms
64 bytes from 172.30.42.18: icmp_req=9 ttl=64 time=0.158 ms
64 bytes from 172.30.42.18: icmp_req=10 ttl=64 time=0.200 ms

--- 172.30.42.18 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 8999ms
rtt min/avg/max/mdev = 0.151/0.176/0.227/0.022 ms

Much better than SFQ because of priority given to new flows

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dave Taht <dave.taht@bufferbloat.net>
Cc: Kathleen Nichols <nichols@pollere.com>
Cc: Van Jacobson <van@pollere.net>
Cc: Tom Herbert <therbert@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
---
 include/linux/pkt_sched.h |   45 ++
 net/sched/Kconfig         |   11 
 net/sched/Makefile        |    1 
 net/sched/sch_fq_codel.c  |  595 ++++++++++++++++++++++++++++++++++++
 4 files changed, 652 insertions(+)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index cde56c2..3ffdaec 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -681,4 +681,49 @@ struct tc_codel_xstats {
 	__u32	dropping;  /* are we in dropping state ? */
 };
 
+/* FQ_CODEL */
+
+enum {
+	TCA_FQ_CODEL_UNSPEC,
+	TCA_FQ_CODEL_TARGET,
+	TCA_FQ_CODEL_LIMIT,
+	TCA_FQ_CODEL_INTERVAL,
+	TCA_FQ_CODEL_ECN,
+	TCA_FQ_CODEL_FLOWS,
+	__TCA_FQ_CODEL_MAX
+};
+
+#define TCA_FQ_CODEL_MAX	(__TCA_FQ_CODEL_MAX - 1)
+
+enum {
+	TCA_FQ_CODEL_XSTATS_QDISC,
+	TCA_FQ_CODEL_XSTATS_CLASS,
+};
+
+struct tc_fq_codel_xstats {
+	__u32	type;
+	union {
+		struct {
+			__u32	maxpacket; /* largest packet we've seen so far */
+			__u32	drop_overlimit; /* number of time max qdisc packet limit was hit */
+			__u32	ecn_mark;  /* number of packets we ECN marked
+					    * instead of dropped
+					    */
+			__u32	new_flow_count; /* number of time packets created a 'new flow' */
+			__u32	new_flows_len;	/* count of flows in new list */
+			__u32	old_flows_len;	/* count of flows in old list */ 
+		} qdisc_stats;
+		struct {
+			__s32	deficit;
+			__u32	ldelay; /* in-queue delay seen by most recently
+					 * dequeued packet
+					 */
+			__u32	count;
+			__u32	lastcount;
+			__u32	dropping;
+			__s32	drop_next;
+		} class_stats;
+	};
+};
+
 #endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index fadd252..e7a8976 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -261,6 +261,17 @@ config NET_SCH_CODEL
 
 	  If unsure, say N.
 
+config NET_SCH_FQ_CODEL
+	tristate "Fair Queue Controlled Delay AQM (FQ_CODEL)"
+	help
+	  Say Y here if you want to use the FQ Controlled Delay (FQ_CODEL)
+	  packet scheduling algorithm.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sch_fq_codel.
+
+	  If unsure, say N.
+
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	depends on NET_CLS_ACT
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 30fab03..5940a19 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -38,6 +38,7 @@ obj-$(CONFIG_NET_SCH_MQPRIO)	+= sch_mqprio.o
 obj-$(CONFIG_NET_SCH_CHOKE)	+= sch_choke.o
 obj-$(CONFIG_NET_SCH_QFQ)	+= sch_qfq.o
 obj-$(CONFIG_NET_SCH_CODEL)	+= sch_codel.o
+obj-$(CONFIG_NET_SCH_FQ_CODEL)	+= sch_fq_codel.o
 
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
new file mode 100644
index 0000000..8675ff8
--- /dev/null
+++ b/net/sched/sch_fq_codel.c
@@ -0,0 +1,595 @@
+/*
+ * Fair Queue CoDel discipline
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *  Copyright (C) 2012 Eric Dumazet <edumazet@google.com>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/jiffies.h>
+#include <linux/string.h>
+#include <linux/in.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/jhash.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <net/flow_keys.h>
+#include <net/codel.h>
+
+/*	Fair Queue CoDel.
+ *
+ * Principles :
+ * Packets are classified (internal classifier or external) on flows.
+ * This is a Stochastic model (as we use a hash, several flows
+ *			       might be hashed on same slot)
+ * Each flow has a CoDel managed queue.
+ * Flows are linked onto two (Round Robin) lists,
+ * so that new flows have priority on old ones.
+ *
+ * For a given flow, packets are not reordered (CoDel uses a FIFO)
+ * head drops only.
+ * ECN capability is on by default.
+ * Low memory footprint (64 bytes per flow)
+ */
+
+struct fq_codel_flow {
+	struct sk_buff	  *head;
+	struct sk_buff	  *tail;
+	struct list_head  flowchain;
+	int		  deficit;
+	struct codel_vars cvars;
+};
+
+struct fq_codel_sched_data {
+	struct tcf_proto *filter_list;	/* external classifier */
+	struct fq_codel_flow *flows;	/* Flows table [flows_cnt] */
+	u32		*backlogs;	/* backlog table [flows_cnt] */
+	u32		flows_cnt;	/* number of flows */
+	u32		perturbation;	/* hash perturbation */
+	u32		quantum;	/* psched_mtu(qdisc_dev(sch)); */
+	struct codel_params cparams;
+	struct codel_stats cstats;
+	u32		drop_overlimit;
+	u32		new_flow_count;
+
+	struct list_head new_flows;	/* list of new flows */
+	struct list_head old_flows;	/* list of old flows */
+};
+
+static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
+				  const struct sk_buff *skb)
+{
+	struct flow_keys keys;
+	unsigned int hash;
+
+	skb_flow_dissect(skb, &keys);
+	hash = jhash_3words((__force u32)keys.dst,
+			    (__force u32)keys.src ^ keys.ip_proto,
+			    (__force u32)keys.ports, q->perturbation);
+	return ((u64)hash * q->flows_cnt) >> 32;
+}
+
+static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
+				      int *qerr)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	struct tcf_result res;
+	int result;
+
+	if (TC_H_MAJ(skb->priority) == sch->handle &&
+	    TC_H_MIN(skb->priority) > 0 &&
+	    TC_H_MIN(skb->priority) <= q->flows_cnt)
+		return TC_H_MIN(skb->priority);
+
+	if (!q->filter_list)
+		return fq_codel_hash(q, skb) + 1;
+
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+	result = tc_classify(skb, q->filter_list, &res);
+	if (result >= 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+		case TC_ACT_SHOT:
+			return 0;
+		}
+#endif
+		if (TC_H_MIN(res.classid) <= q->flows_cnt)
+			return TC_H_MIN(res.classid);
+	}
+	return 0;
+}
+
+/* helper functions : might be changed when/if skb use a standard list_head */
+
+/* remove one skb from head of slot queue */
+static inline struct sk_buff *dequeue_head(struct fq_codel_flow *flow)
+{
+	struct sk_buff *skb = flow->head;
+
+	flow->head = skb->next;
+	skb->next = NULL;
+	return skb;
+}
+
+/* add skb to flow queue (tail add) */
+static inline void flow_queue_add(struct fq_codel_flow *flow,
+				  struct sk_buff *skb)
+{
+	if (flow->head == NULL)
+		flow->head = skb;
+	else
+		flow->tail->next = skb;
+	flow->tail = skb;
+	skb->next = NULL;
+}
+
+static unsigned int fq_codel_drop(struct Qdisc *sch)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+	unsigned int maxbacklog = 0, idx = 0, i, len;
+	struct fq_codel_flow *flow;
+
+	/* Queue is full! Find the fat flow and drop packet from it.
+	 * This might sound expensive, but with 1024 flows, we scan
+	 * 4KB of memory, and we dont need to handle a complex tree
+	 * in fast path (packet queue/enqueue) with many cache misses.
+	 */
+	for (i = 0; i < q->flows_cnt; i++) {
+		if (q->backlogs[i] > maxbacklog) {
+			maxbacklog = q->backlogs[i];
+			idx = i;
+		}
+	}
+	flow = &q->flows[idx];
+	skb = dequeue_head(flow);
+	len = qdisc_pkt_len(skb);
+	q->backlogs[idx] -= len;
+	kfree_skb(skb);
+	sch->q.qlen--;
+	sch->qstats.drops++;
+	sch->qstats.backlog -= len;
+	return idx;
+}
+
+static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	unsigned int idx;
+	struct fq_codel_flow *flow;
+	int uninitialized_var(ret);
+
+	idx = fq_codel_classify(skb, sch, &ret);
+	if (idx == 0) {
+		if (ret & __NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+	idx--;
+
+	codel_set_enqueue_time(skb);
+	flow = &q->flows[idx];
+	flow_queue_add(flow, skb);
+	q->backlogs[idx] += qdisc_pkt_len(skb);
+	sch->qstats.backlog += qdisc_pkt_len(skb);
+
+	if (list_empty(&flow->flowchain)) {
+		list_add_tail(&flow->flowchain, &q->new_flows);
+		codel_vars_init(&flow->cvars);
+		q->new_flow_count++;
+		flow->deficit = q->quantum;
+	}
+	if (++sch->q.qlen < sch->limit)
+		return NET_XMIT_SUCCESS;
+
+	q->drop_overlimit++;
+	/* Return Congestion Notification only if we dropped a packet
+	 * from this flow.
+	 */
+	if (fq_codel_drop(sch) == idx)
+		return NET_XMIT_CN;
+
+	/* As we dropped a packet, better let upper stack know this */
+	qdisc_tree_decrease_qlen(sch, 1);
+	return NET_XMIT_SUCCESS;
+}
+
+/* This is the specific function called from codel_dequeue()
+ * to dequeue a packet from queue. Note: backlog is handled in
+ * codel, we dont need to reduce it here.
+ */
+static struct sk_buff *dequeue(struct codel_vars *vars, struct Qdisc *sch)
+{
+	struct fq_codel_flow *flow;
+	struct sk_buff *skb = NULL;
+
+	flow = container_of(vars, struct fq_codel_flow, cvars);
+	if (flow->head) {
+		skb = dequeue_head(flow);
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
+		sch->q.qlen--;
+	}
+	return skb;
+}
+
+static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+	struct fq_codel_flow *flow;
+
+begin:
+	if (!list_empty(&q->new_flows))
+		flow = list_first_entry(&q->new_flows,
+					struct fq_codel_flow,
+					flowchain);
+	else if (!list_empty(&q->old_flows))
+		flow = list_first_entry(&q->old_flows,
+					struct fq_codel_flow,
+					flowchain);
+	else
+		return NULL;
+
+	if (flow->deficit <= 0) {
+		flow->deficit += q->quantum;
+		list_move_tail(&flow->flowchain, &q->old_flows);
+		goto begin;
+	}
+	skb = codel_dequeue(sch, &q->cparams, &flow->cvars, &q->cstats,
+			    dequeue, &q->backlogs[flow - q->flows]);
+	if (!skb) {
+		list_del_init(&flow->flowchain);
+		goto begin;
+	}
+	qdisc_bstats_update(sch, skb);
+	flow->deficit -= qdisc_pkt_len(skb);
+	return skb;
+}
+
+static void fq_codel_reset(struct Qdisc *sch)
+{
+	struct sk_buff *skb;
+
+	while ((skb = fq_codel_dequeue(sch)) != NULL)
+		kfree_skb(skb);
+}
+
+static const struct nla_policy fq_codel_policy[TCA_FQ_CODEL_MAX + 1] = {
+	[TCA_FQ_CODEL_TARGET]	= { .type = NLA_U32 },
+	[TCA_FQ_CODEL_LIMIT]	= { .type = NLA_U32 },
+	[TCA_FQ_CODEL_INTERVAL]	= { .type = NLA_U32 },
+	[TCA_FQ_CODEL_ECN]	= { .type = NLA_U32 },
+};
+
+static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	struct nlattr *tb[TCA_FQ_CODEL_MAX + 1];
+	int err;
+
+	if (!opt)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_FQ_CODEL_MAX, opt, fq_codel_policy);
+	if (err < 0)
+		return err;
+	if (tb[TCA_FQ_CODEL_FLOWS]) {
+		if (q->flows)
+			return -EINVAL;
+		q->flows_cnt = nla_get_u32(tb[TCA_FQ_CODEL_FLOWS]);
+		if (!q->flows_cnt ||
+		    q->flows_cnt > 65536)
+			return -EINVAL;
+	}
+	sch_tree_lock(sch);
+
+	if (tb[TCA_FQ_CODEL_TARGET]) {
+		u64 target = nla_get_u32(tb[TCA_FQ_CODEL_TARGET]);
+
+		q->cparams.target = (target * NSEC_PER_USEC) >> CODEL_SHIFT;
+	}
+
+	if (tb[TCA_FQ_CODEL_INTERVAL]) {
+		u64 interval = nla_get_u32(tb[TCA_FQ_CODEL_INTERVAL]);
+
+		q->cparams.interval = (interval * NSEC_PER_USEC) >> CODEL_SHIFT;
+	}
+
+	if (tb[TCA_FQ_CODEL_LIMIT])
+		sch->limit = nla_get_u32(tb[TCA_FQ_CODEL_LIMIT]);
+
+	if (tb[TCA_FQ_CODEL_ECN])
+		q->cparams.ecn = !!nla_get_u32(tb[TCA_FQ_CODEL_ECN]);
+
+	while (sch->q.qlen > sch->limit) {
+		struct sk_buff *skb = fq_codel_dequeue(sch);
+
+		kfree_skb(skb);
+		q->cstats.drop_count++;
+	}
+	qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
+	q->cstats.drop_count = 0;
+
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static void *fq_codel_zalloc(size_t sz)
+{
+	void *ptr = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN);
+
+	if (!ptr)
+		ptr = vzalloc(sz);
+	return ptr;
+}
+
+static void fq_codel_free(void *addr)
+{
+	if (addr) {
+		if (is_vmalloc_addr(addr))
+			vfree(addr);
+		else
+			kfree(addr);
+	}
+}
+
+static void fq_codel_destroy(struct Qdisc *sch)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+
+	tcf_destroy_chain(&q->filter_list);
+	fq_codel_free(q->backlogs);
+	fq_codel_free(q->flows);
+}
+
+static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	int i;
+
+	sch->limit = 10*1024;
+	q->flows_cnt = 1024;
+	q->quantum = psched_mtu(qdisc_dev(sch));
+	q->perturbation = net_random();
+	INIT_LIST_HEAD(&q->new_flows);
+	INIT_LIST_HEAD(&q->old_flows);
+	codel_params_init(&q->cparams);
+	codel_stats_init(&q->cstats);
+	q->cparams.ecn = true;
+
+	if (opt) {
+		int err = fq_codel_change(sch, opt);
+		if (err)
+			return err;
+	}
+
+	if (!q->flows) {
+		q->flows = fq_codel_zalloc(q->flows_cnt *
+					   sizeof(struct fq_codel_flow));
+		if (!q->flows)
+			return -ENOMEM;
+		q->backlogs = fq_codel_zalloc(q->flows_cnt * sizeof(u32));
+		if (!q->backlogs) {
+			fq_codel_free(q->flows);
+			return -ENOMEM;
+		}
+		for (i = 0; i < q->flows_cnt; i++) {
+			struct fq_codel_flow *flow = q->flows + i;
+
+			INIT_LIST_HEAD(&flow->flowchain);
+		}
+	}
+	if (sch->limit >= 1)
+		sch->flags |= TCQ_F_CAN_BYPASS;
+	else
+		sch->flags &= ~TCQ_F_CAN_BYPASS;
+	return 0;
+}
+
+static int fq_codel_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	struct nlattr *opts;
+
+	opts = nla_nest_start(skb, TCA_OPTIONS);
+	if (opts == NULL)
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, TCA_FQ_CODEL_TARGET,
+			codel_time_to_us(q->cparams.target)) ||
+	    nla_put_u32(skb, TCA_FQ_CODEL_LIMIT,
+			sch->limit) ||
+	    nla_put_u32(skb, TCA_FQ_CODEL_INTERVAL,
+			codel_time_to_us(q->cparams.interval)) ||
+	    nla_put_u32(skb, TCA_FQ_CODEL_ECN,
+			q->cparams.ecn) ||
+	    nla_put_u32(skb, TCA_FQ_CODEL_FLOWS,
+			q->flows_cnt))
+		goto nla_put_failure;
+
+	return nla_nest_end(skb, opts);
+
+nla_put_failure:
+	nla_nest_cancel(skb, opts);
+	return -1;
+}
+
+static int fq_codel_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	struct tc_fq_codel_xstats st = {
+		.type				= TCA_FQ_CODEL_XSTATS_QDISC,
+		.qdisc_stats.maxpacket		= q->cstats.maxpacket,
+		.qdisc_stats.drop_overlimit	= q->drop_overlimit,
+		.qdisc_stats.ecn_mark		= q->cstats.ecn_mark,
+		.qdisc_stats.new_flow_count	= q->new_flow_count,
+	};
+	struct list_head *pos;
+
+	list_for_each(pos, &q->new_flows)
+		st.qdisc_stats.new_flows_len++;
+
+	list_for_each(pos, &q->old_flows)
+		st.qdisc_stats.old_flows_len++;
+
+	return gnet_stats_copy_app(d, &st, sizeof(st));
+}
+
+static struct Qdisc *fq_codel_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	return NULL;
+}
+
+static unsigned long fq_codel_get(struct Qdisc *sch, u32 classid)
+{
+	return 0;
+}
+
+static unsigned long fq_codel_bind(struct Qdisc *sch, unsigned long parent,
+			      u32 classid)
+{
+	/* we cannot bypass queue discipline anymore */
+	sch->flags &= ~TCQ_F_CAN_BYPASS;
+	return 0;
+}
+
+static void fq_codel_put(struct Qdisc *q, unsigned long cl)
+{
+}
+
+static struct tcf_proto **fq_codel_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+	return &q->filter_list;
+}
+
+static int fq_codel_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	tcm->tcm_handle |= TC_H_MIN(cl);
+	return 0;
+}
+
+static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
+				     struct gnet_dump *d)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	u32 idx = cl - 1;
+	struct gnet_stats_queue qs = { 0 };
+	struct tc_fq_codel_xstats xstats;
+
+	if (idx < q->flows_cnt) {
+		const struct fq_codel_flow *flow = &q->flows[idx];
+		const struct sk_buff *skb = flow->head;
+
+		memset(&xstats, 0, sizeof(xstats));
+		xstats.type = TCA_FQ_CODEL_XSTATS_CLASS;
+		xstats.class_stats.deficit = flow->deficit;
+		xstats.class_stats.ldelay =
+			codel_time_to_us(flow->cvars.ldelay);
+		xstats.class_stats.count = flow->cvars.count;
+		xstats.class_stats.lastcount = flow->cvars.lastcount;
+		xstats.class_stats.dropping = flow->cvars.dropping;
+		if (flow->cvars.dropping) {
+			codel_tdiff_t delta = flow->cvars.drop_next -
+					      codel_get_time();
+
+			xstats.class_stats.drop_next = (delta >= 0) ?
+				codel_time_to_us(delta) :
+				-codel_time_to_us(-delta);
+		}
+		while (skb) {
+			qs.qlen++;
+			skb = skb->next;
+		}
+		qs.backlog = q->backlogs[idx];
+	}
+	if (gnet_stats_copy_queue(d, &qs) < 0)
+		return -1;
+	if (idx < q->flows_cnt)
+		return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
+	return 0;
+}
+
+static void fq_codel_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	unsigned int i;
+
+	if (arg->stop)
+		return;
+
+	for (i = 0; i < q->flows_cnt; i++) {
+		if (list_empty(&q->flows[i].flowchain) ||
+		    arg->count < arg->skip) {
+			arg->count++;
+			continue;
+		}
+		if (arg->fn(sch, i + 1, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+		arg->count++;
+	}
+}
+
+static const struct Qdisc_class_ops fq_codel_class_ops = {
+	.leaf		=	fq_codel_leaf,
+	.get		=	fq_codel_get,
+	.put		=	fq_codel_put,
+	.tcf_chain	=	fq_codel_find_tcf,
+	.bind_tcf	=	fq_codel_bind,
+	.unbind_tcf	=	fq_codel_put,
+	.dump		=	fq_codel_dump_class,
+	.dump_stats	=	fq_codel_dump_class_stats,
+	.walk		=	fq_codel_walk,
+};
+
+static struct Qdisc_ops fq_codel_qdisc_ops __read_mostly = {
+	.cl_ops		=	&fq_codel_class_ops,
+	.id		=	"fq_codel",
+	.priv_size	=	sizeof(struct fq_codel_sched_data),
+	.enqueue	=	fq_codel_enqueue,
+	.dequeue	=	fq_codel_dequeue,
+	.peek		=	qdisc_peek_dequeued,
+	.drop		=	fq_codel_drop,
+	.init		=	fq_codel_init,
+	.reset		=	fq_codel_reset,
+	.destroy	=	fq_codel_destroy,
+	.change		=	NULL,
+	.dump		=	fq_codel_dump,
+	.dump_stats =	fq_codel_dump_stats,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init fq_codel_module_init(void)
+{
+	return register_qdisc(&fq_codel_qdisc_ops);
+}
+
+static void __exit fq_codel_module_exit(void)
+{
+	unregister_qdisc(&fq_codel_qdisc_ops);
+}
+
+module_init(fq_codel_module_init)
+module_exit(fq_codel_module_exit)
+MODULE_AUTHOR("Eric Dumazet");
+MODULE_LICENSE("GPL");
