From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] fq_codel: Fair Queue Codel AQM
Date: Fri, 11 May 2012 21:30:50 +0200
Message-ID: <1336764650.31653.277.camel@edumazet-glaptop>
References: <1336744796.31653.164.camel@edumazet-glaptop>
	 <CABa6K_Fk07CUR1+hOx06cwJ5MuNYi7vpeLYFOc_1Qwmu5ubYhQ@mail.gmail.com>
	 <1336749810.31653.176.camel@edumazet-glaptop>
	 <1336752516.31653.196.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <van@pollere.net>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Changli Gao <xiaosuo@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35972 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946017Ab2EKTa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 15:30:57 -0400
Received: by bkcji2 with SMTP id ji2so2516393bkc.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 12:30:55 -0700 (PDT)
In-Reply-To: <1336752516.31653.196.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

=46air Queue Codel packet scheduler

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
                      [ quantum BYTES ]

defaults : 1024 flows, 10240 packets limit, quantum : device MTU
           target : 5ms (CoDel default)
           interval : 100ms (CoDel default)

Impressive results on load :

# tc -s -d cl show dev eth9

class htb 1:1 root leaf 10: prio 0 quantum 1514 rate 200000Kbit ceil 20=
0000Kbit burst 1475b/8 mpu 0b overhead 0b cburst 1475b/8 mpu 0b overhea=
d 0b level 0=20
 Sent 43304920109 bytes 33063109 pkt (dropped 0, overlimits 0 requeues =
0)=20
 rate 201691Kbit 28595pps backlog 0b 312p requeues 0=20
 lended: 33063109 borrowed: 0 giants: 0
 tokens: -912 ctokens: -912

class fq_codel 10:1735 parent 10:=20
 (dropped 1292, overlimits 0 requeues 0)=20
 backlog 15140b 10p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 7.1ms
class fq_codel 10:4524 parent 10:=20
 (dropped 1291, overlimits 0 requeues 0)=20
 backlog 16654b 11p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 7.1ms
class fq_codel 10:4e74 parent 10:=20
 (dropped 1290, overlimits 0 requeues 0)=20
 backlog 6056b 4p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 6.4ms dropping drop_next 92.0=
ms
class fq_codel 10:628a parent 10:=20
 (dropped 1289, overlimits 0 requeues 0)=20
 backlog 7570b 5p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 5.4ms dropping drop_next 90.9=
ms
class fq_codel 10:a4b3 parent 10:=20
 (dropped 302, overlimits 0 requeues 0)=20
 backlog 16654b 11p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 7.1ms
class fq_codel 10:c3c2 parent 10:=20
 (dropped 1284, overlimits 0 requeues 0)=20
 backlog 13626b 9p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 5.9ms
class fq_codel 10:d331 parent 10:=20
 (dropped 299, overlimits 0 requeues 0)=20
 backlog 15140b 10p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 7.0ms
class fq_codel 10:d526 parent 10:=20
 (dropped 12160, overlimits 0 requeues 0)=20
 backlog 35870b 211p requeues 0=20
  deficit 1508 count 12160 lastcount 1 ldelay 15.3ms dropping drop_next=
 247us
class fq_codel 10:e2c6 parent 10:=20
 (dropped 1288, overlimits 0 requeues 0)=20
 backlog 15140b 10p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 7.1ms
class fq_codel 10:eab5 parent 10:=20
 (dropped 1285, overlimits 0 requeues 0)=20
 backlog 16654b 11p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 5.9ms
class fq_codel 10:f220 parent 10:=20
 (dropped 1289, overlimits 0 requeues 0)=20
 backlog 15140b 10p requeues 0=20
  deficit 1514 count 1 lastcount 1 ldelay 7.1ms

# tc -s -d qd show dev eth9

qdisc htb 1: root refcnt 6 r2q 10 default 1 direct_packets_stat 0 ver 3=
=2E17
 Sent 43331086547 bytes 33092812 pkt (dropped 0, overlimits 66063544 re=
queues 71)=20
 rate 201697Kbit 28602pps backlog 0b 260p requeues 71=20
qdisc fq_codel 10: parent 1:1 limit 10240p flows 65536 target 5.0ms int=
erval 100.0ms ecn=20
 Sent 43331086547 bytes 33092812 pkt (dropped 949359, overlimits 0 requ=
eues 0)=20
 rate 201697Kbit 28602pps backlog 189352b 260p requeues 0=20
  maxpacket 1514 drop_overlimit 0 new_flow_count 5582 ecn_mark 125593
  new_flows_len 0 old_flows_len 11


# ping -c 10 172.30.42.18
PING 172.30.42.18 (172.30.42.18) 56(84) bytes of data.
64 bytes from 172.30.42.18: icmp_req=3D1 ttl=3D64 time=3D0.227 ms
64 bytes from 172.30.42.18: icmp_req=3D2 ttl=3D64 time=3D0.165 ms
64 bytes from 172.30.42.18: icmp_req=3D3 ttl=3D64 time=3D0.166 ms
64 bytes from 172.30.42.18: icmp_req=3D4 ttl=3D64 time=3D0.151 ms
64 bytes from 172.30.42.18: icmp_req=3D5 ttl=3D64 time=3D0.164 ms
64 bytes from 172.30.42.18: icmp_req=3D6 ttl=3D64 time=3D0.172 ms
64 bytes from 172.30.42.18: icmp_req=3D7 ttl=3D64 time=3D0.175 ms
64 bytes from 172.30.42.18: icmp_req=3D8 ttl=3D64 time=3D0.183 ms
64 bytes from 172.30.42.18: icmp_req=3D9 ttl=3D64 time=3D0.158 ms
64 bytes from 172.30.42.18: icmp_req=3D10 ttl=3D64 time=3D0.200 ms

--- 172.30.42.18 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 8999ms
rtt min/avg/max/mdev =3D 0.151/0.176/0.227/0.022 ms

Much better than SFQ because of priority given to new flows, and fast
path dirtying less cache lines.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dave Taht <dave.taht@bufferbloat.net>
Cc: Kathleen Nichols <nichols@pollere.com>
Cc: Van Jacobson <van@pollere.net>
Cc: Tom Herbert <therbert@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Changli Gao <xiaosuo@gmail.com>
---
v2: added 'dropped' counter per flow (sum of drops and marks)
    .change method allowed (tc qdisc change .... )
    quantum is a tunable
    no starvation of old flows because of new ones.
    drop_count correctly handled in dequeue() (upcall to parents)
    pkt_sched.h cleanups

 include/linux/pkt_sched.h |   54 +++
 net/sched/Kconfig         |   11=20
 net/sched/Makefile        |    1=20
 net/sched/sch_fq_codel.c  |  625 ++++++++++++++++++++++++++++++++++++
 4 files changed, 691 insertions(+)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index cde56c2..32aef0a 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -681,4 +681,58 @@ struct tc_codel_xstats {
 	__u32	dropping;  /* are we in dropping state ? */
 };
=20
+/* FQ_CODEL */
+
+enum {
+	TCA_FQ_CODEL_UNSPEC,
+	TCA_FQ_CODEL_TARGET,
+	TCA_FQ_CODEL_LIMIT,
+	TCA_FQ_CODEL_INTERVAL,
+	TCA_FQ_CODEL_ECN,
+	TCA_FQ_CODEL_FLOWS,
+	TCA_FQ_CODEL_QUANTUM,
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
+struct tc_fq_codel_qd_stats {
+	__u32	maxpacket;	/* largest packet we've seen so far */
+	__u32	drop_overlimit; /* number of time max qdisc
+				 * packet limit was hit
+				 */
+	__u32	ecn_mark;	/* number of packets we ECN marked
+				 * instead of being dropped
+				 */
+	__u32	new_flow_count; /* number of time packets
+				 * created a 'new flow'
+				 */
+	__u32	new_flows_len;	/* count of flows in new list */
+	__u32	old_flows_len;	/* count of flows in old list */
+};
+
+struct tc_fq_codel_cl_stats {
+	__s32	deficit;
+	__u32	ldelay;		/* in-queue delay seen by most recently
+				 * dequeued packet
+				 */
+	__u32	count;
+	__u32	lastcount;
+	__u32	dropping;
+	__s32	drop_next;
+};
+
+struct tc_fq_codel_xstats {
+	__u32	type;
+	union {
+		struct tc_fq_codel_qd_stats qdisc_stats;
+		struct tc_fq_codel_cl_stats class_stats;
+	};
+};
+
 #endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index fadd252..e7a8976 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -261,6 +261,17 @@ config NET_SCH_CODEL
=20
 	  If unsure, say N.
=20
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
@@ -38,6 +38,7 @@ obj-$(CONFIG_NET_SCH_MQPRIO)	+=3D sch_mqprio.o
 obj-$(CONFIG_NET_SCH_CHOKE)	+=3D sch_choke.o
 obj-$(CONFIG_NET_SCH_QFQ)	+=3D sch_qfq.o
 obj-$(CONFIG_NET_SCH_CODEL)	+=3D sch_codel.o
+obj-$(CONFIG_NET_SCH_FQ_CODEL)	+=3D sch_fq_codel.o
=20
 obj-$(CONFIG_NET_CLS_U32)	+=3D cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+=3D cls_route.o
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
new file mode 100644
index 0000000..1f538e4
--- /dev/null
+++ b/net/sched/sch_fq_codel.c
@@ -0,0 +1,625 @@
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
+	u32		  dropped; /* number of drops (or ECN marks) on this flow */
+	struct codel_vars cvars;
+}; /* please try to keep this structure <=3D 64 bytes */
+
+struct fq_codel_sched_data {
+	struct tcf_proto *filter_list;	/* optional external classifier */
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
+	hash =3D jhash_3words((__force u32)keys.dst,
+			    (__force u32)keys.src ^ keys.ip_proto,
+			    (__force u32)keys.ports, q->perturbation);
+	return ((u64)hash * q->flows_cnt) >> 32;
+}
+
+static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdis=
c *sch,
+				      int *qerr)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	struct tcf_result res;
+	int result;
+
+	if (TC_H_MAJ(skb->priority) =3D=3D sch->handle &&
+	    TC_H_MIN(skb->priority) > 0 &&
+	    TC_H_MIN(skb->priority) <=3D q->flows_cnt)
+		return TC_H_MIN(skb->priority);
+
+	if (!q->filter_list)
+		return fq_codel_hash(q, skb) + 1;
+
+	*qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+	result =3D tc_classify(skb, q->filter_list, &res);
+	if (result >=3D 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+		case TC_ACT_SHOT:
+			return 0;
+		}
+#endif
+		if (TC_H_MIN(res.classid) <=3D q->flows_cnt)
+			return TC_H_MIN(res.classid);
+	}
+	return 0;
+}
+
+/* helper functions : might be changed when/if skb use a standard list=
_head */
+
+/* remove one skb from head of slot queue */
+static inline struct sk_buff *dequeue_head(struct fq_codel_flow *flow)
+{
+	struct sk_buff *skb =3D flow->head;
+
+	flow->head =3D skb->next;
+	skb->next =3D NULL;
+	return skb;
+}
+
+/* add skb to flow queue (tail add) */
+static inline void flow_queue_add(struct fq_codel_flow *flow,
+				  struct sk_buff *skb)
+{
+	if (flow->head =3D=3D NULL)
+		flow->head =3D skb;
+	else
+		flow->tail->next =3D skb;
+	flow->tail =3D skb;
+	skb->next =3D NULL;
+}
+
+static unsigned int fq_codel_drop(struct Qdisc *sch)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	struct sk_buff *skb;
+	unsigned int maxbacklog =3D 0, idx =3D 0, i, len;
+	struct fq_codel_flow *flow;
+
+	/* Queue is full! Find the fat flow and drop packet from it.
+	 * This might sound expensive, but with 1024 flows, we scan
+	 * 4KB of memory, and we dont need to handle a complex tree
+	 * in fast path (packet queue/enqueue) with many cache misses.
+	 */
+	for (i =3D 0; i < q->flows_cnt; i++) {
+		if (q->backlogs[i] > maxbacklog) {
+			maxbacklog =3D q->backlogs[i];
+			idx =3D i;
+		}
+	}
+	flow =3D &q->flows[idx];
+	skb =3D dequeue_head(flow);
+	len =3D qdisc_pkt_len(skb);
+	q->backlogs[idx] -=3D len;
+	kfree_skb(skb);
+	sch->q.qlen--;
+	sch->qstats.drops++;
+	sch->qstats.backlog -=3D len;
+	flow->dropped++;
+	return idx;
+}
+
+static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	unsigned int idx;
+	struct fq_codel_flow *flow;
+	int uninitialized_var(ret);
+
+	idx =3D fq_codel_classify(skb, sch, &ret);
+	if (idx =3D=3D 0) {
+		if (ret & __NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+	idx--;
+
+	codel_set_enqueue_time(skb);
+	flow =3D &q->flows[idx];
+	flow_queue_add(flow, skb);
+	q->backlogs[idx] +=3D qdisc_pkt_len(skb);
+	sch->qstats.backlog +=3D qdisc_pkt_len(skb);
+
+	if (list_empty(&flow->flowchain)) {
+		list_add_tail(&flow->flowchain, &q->new_flows);
+		codel_vars_init(&flow->cvars);
+		q->new_flow_count++;
+		flow->deficit =3D q->quantum;
+		flow->dropped =3D 0;
+	}
+	if (++sch->q.qlen < sch->limit)
+		return NET_XMIT_SUCCESS;
+
+	q->drop_overlimit++;
+	/* Return Congestion Notification only if we dropped a packet
+	 * from this flow.
+	 */
+	if (fq_codel_drop(sch) =3D=3D idx)
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
+static struct sk_buff *dequeue(struct codel_vars *vars, struct Qdisc *=
sch)
+{
+	struct fq_codel_flow *flow;
+	struct sk_buff *skb =3D NULL;
+
+	flow =3D container_of(vars, struct fq_codel_flow, cvars);
+	if (flow->head) {
+		skb =3D dequeue_head(flow);
+		sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+		sch->q.qlen--;
+	}
+	return skb;
+}
+
+static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	struct sk_buff *skb;
+	struct fq_codel_flow *flow;
+	struct list_head *head;
+	u32 prev_drop_count, prev_ecn_mark;
+
+begin:
+	head =3D &q->new_flows;
+	if (list_empty(head)) {
+		head =3D &q->old_flows;
+		if (list_empty(head))
+			return NULL;
+	}
+	flow =3D list_first_entry(head, struct fq_codel_flow, flowchain);
+
+	if (flow->deficit <=3D 0) {
+		flow->deficit +=3D q->quantum;
+		list_move_tail(&flow->flowchain, &q->old_flows);
+		goto begin;
+	}
+
+	prev_drop_count =3D q->cstats.drop_count;
+	prev_ecn_mark =3D q->cstats.ecn_mark;
+
+	skb =3D codel_dequeue(sch, &q->cparams, &flow->cvars, &q->cstats,
+			    dequeue, &q->backlogs[flow - q->flows]);
+
+	flow->dropped +=3D q->cstats.drop_count - prev_drop_count;
+	flow->dropped +=3D q->cstats.ecn_mark - prev_ecn_mark;
+
+	if (!skb) {
+		/* force a pass through old_flows to prevent starvation */
+		if ((head =3D=3D &q->new_flows) && !list_empty(&q->old_flows))
+			list_move_tail(&flow->flowchain, &q->old_flows);
+		else
+			list_del_init(&flow->flowchain);
+		goto begin;
+	}
+	qdisc_bstats_update(sch, skb);
+	flow->deficit -=3D qdisc_pkt_len(skb);
+	/* We cant call qdisc_tree_decrease_qlen() if our qlen is 0,
+	 * or HTB crashes. Defer it for next round.
+	 */
+	if (q->cstats.drop_count && sch->q.qlen) {
+		qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
+		q->cstats.drop_count =3D 0;
+	}
+	return skb;
+}
+
+static void fq_codel_reset(struct Qdisc *sch)
+{
+	struct sk_buff *skb;
+
+	while ((skb =3D fq_codel_dequeue(sch)) !=3D NULL)
+		kfree_skb(skb);
+}
+
+static const struct nla_policy fq_codel_policy[TCA_FQ_CODEL_MAX + 1] =3D=
 {
+	[TCA_FQ_CODEL_TARGET]	=3D { .type =3D NLA_U32 },
+	[TCA_FQ_CODEL_LIMIT]	=3D { .type =3D NLA_U32 },
+	[TCA_FQ_CODEL_INTERVAL]	=3D { .type =3D NLA_U32 },
+	[TCA_FQ_CODEL_ECN]	=3D { .type =3D NLA_U32 },
+	[TCA_FQ_CODEL_FLOWS]	=3D { .type =3D NLA_U32 },
+	[TCA_FQ_CODEL_QUANTUM]	=3D { .type =3D NLA_U32 },
+};
+
+static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	struct nlattr *tb[TCA_FQ_CODEL_MAX + 1];
+	int err;
+
+	if (!opt)
+		return -EINVAL;
+
+	err =3D nla_parse_nested(tb, TCA_FQ_CODEL_MAX, opt, fq_codel_policy);
+	if (err < 0)
+		return err;
+	if (tb[TCA_FQ_CODEL_FLOWS]) {
+		if (q->flows)
+			return -EINVAL;
+		q->flows_cnt =3D nla_get_u32(tb[TCA_FQ_CODEL_FLOWS]);
+		if (!q->flows_cnt ||
+		    q->flows_cnt > 65536)
+			return -EINVAL;
+	}
+	sch_tree_lock(sch);
+
+	if (tb[TCA_FQ_CODEL_TARGET]) {
+		u64 target =3D nla_get_u32(tb[TCA_FQ_CODEL_TARGET]);
+
+		q->cparams.target =3D (target * NSEC_PER_USEC) >> CODEL_SHIFT;
+	}
+
+	if (tb[TCA_FQ_CODEL_INTERVAL]) {
+		u64 interval =3D nla_get_u32(tb[TCA_FQ_CODEL_INTERVAL]);
+
+		q->cparams.interval =3D (interval * NSEC_PER_USEC) >> CODEL_SHIFT;
+	}
+
+	if (tb[TCA_FQ_CODEL_LIMIT])
+		sch->limit =3D nla_get_u32(tb[TCA_FQ_CODEL_LIMIT]);
+
+	if (tb[TCA_FQ_CODEL_ECN])
+		q->cparams.ecn =3D !!nla_get_u32(tb[TCA_FQ_CODEL_ECN]);
+
+	if (tb[TCA_FQ_CODEL_QUANTUM])
+		q->quantum =3D max(256U, nla_get_u32(tb[TCA_FQ_CODEL_QUANTUM]));
+
+	while (sch->q.qlen > sch->limit) {
+		struct sk_buff *skb =3D fq_codel_dequeue(sch);
+
+		kfree_skb(skb);
+		q->cstats.drop_count++;
+	}
+	qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
+	q->cstats.drop_count =3D 0;
+
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static void *fq_codel_zalloc(size_t sz)
+{
+	void *ptr =3D kzalloc(sz, GFP_KERNEL | __GFP_NOWARN);
+
+	if (!ptr)
+		ptr =3D vzalloc(sz);
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
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+
+	tcf_destroy_chain(&q->filter_list);
+	fq_codel_free(q->backlogs);
+	fq_codel_free(q->flows);
+}
+
+static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	int i;
+
+	sch->limit =3D 10*1024;
+	q->flows_cnt =3D 1024;
+	q->quantum =3D psched_mtu(qdisc_dev(sch));
+	q->perturbation =3D net_random();
+	INIT_LIST_HEAD(&q->new_flows);
+	INIT_LIST_HEAD(&q->old_flows);
+	codel_params_init(&q->cparams);
+	codel_stats_init(&q->cstats);
+	q->cparams.ecn =3D true;
+
+	if (opt) {
+		int err =3D fq_codel_change(sch, opt);
+		if (err)
+			return err;
+	}
+
+	if (!q->flows) {
+		q->flows =3D fq_codel_zalloc(q->flows_cnt *
+					   sizeof(struct fq_codel_flow));
+		if (!q->flows)
+			return -ENOMEM;
+		q->backlogs =3D fq_codel_zalloc(q->flows_cnt * sizeof(u32));
+		if (!q->backlogs) {
+			fq_codel_free(q->flows);
+			return -ENOMEM;
+		}
+		for (i =3D 0; i < q->flows_cnt; i++) {
+			struct fq_codel_flow *flow =3D q->flows + i;
+
+			INIT_LIST_HEAD(&flow->flowchain);
+		}
+	}
+	if (sch->limit >=3D 1)
+		sch->flags |=3D TCQ_F_CAN_BYPASS;
+	else
+		sch->flags &=3D ~TCQ_F_CAN_BYPASS;
+	return 0;
+}
+
+static int fq_codel_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	struct nlattr *opts;
+
+	opts =3D nla_nest_start(skb, TCA_OPTIONS);
+	if (opts =3D=3D NULL)
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
+	    nla_put_u32(skb, TCA_FQ_CODEL_QUANTUM,
+			q->quantum) ||
+	    nla_put_u32(skb, TCA_FQ_CODEL_FLOWS,
+			q->flows_cnt))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, opts);
+	return skb->len;
+
+nla_put_failure:
+	return -1;
+}
+
+static int fq_codel_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	struct tc_fq_codel_xstats st =3D {
+		.type				=3D TCA_FQ_CODEL_XSTATS_QDISC,
+		.qdisc_stats.maxpacket		=3D q->cstats.maxpacket,
+		.qdisc_stats.drop_overlimit	=3D q->drop_overlimit,
+		.qdisc_stats.ecn_mark		=3D q->cstats.ecn_mark,
+		.qdisc_stats.new_flow_count	=3D q->new_flow_count,
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
+static struct Qdisc *fq_codel_leaf(struct Qdisc *sch, unsigned long ar=
g)
+{
+	return NULL;
+}
+
+static unsigned long fq_codel_get(struct Qdisc *sch, u32 classid)
+{
+	return 0;
+}
+
+static unsigned long fq_codel_bind(struct Qdisc *sch, unsigned long pa=
rent,
+			      u32 classid)
+{
+	/* we cannot bypass queue discipline anymore */
+	sch->flags &=3D ~TCQ_F_CAN_BYPASS;
+	return 0;
+}
+
+static void fq_codel_put(struct Qdisc *q, unsigned long cl)
+{
+}
+
+static struct tcf_proto **fq_codel_find_tcf(struct Qdisc *sch, unsigne=
d long cl)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+	return &q->filter_list;
+}
+
+static int fq_codel_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	tcm->tcm_handle |=3D TC_H_MIN(cl);
+	return 0;
+}
+
+static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long =
cl,
+				     struct gnet_dump *d)
+{
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	u32 idx =3D cl - 1;
+	struct gnet_stats_queue qs =3D { 0 };
+	struct tc_fq_codel_xstats xstats;
+
+	WARN_ON_ONCE(1);
+	if (idx < q->flows_cnt) {
+		const struct fq_codel_flow *flow =3D &q->flows[idx];
+		const struct sk_buff *skb =3D flow->head;
+
+		memset(&xstats, 0, sizeof(xstats));
+		xstats.type =3D TCA_FQ_CODEL_XSTATS_CLASS;
+		xstats.class_stats.deficit =3D flow->deficit;
+		xstats.class_stats.ldelay =3D
+			codel_time_to_us(flow->cvars.ldelay);
+		xstats.class_stats.count =3D flow->cvars.count;
+		xstats.class_stats.lastcount =3D flow->cvars.lastcount;
+		xstats.class_stats.dropping =3D flow->cvars.dropping;
+		if (flow->cvars.dropping) {
+			codel_tdiff_t delta =3D flow->cvars.drop_next -
+					      codel_get_time();
+
+			xstats.class_stats.drop_next =3D (delta >=3D 0) ?
+				codel_time_to_us(delta) :
+				-codel_time_to_us(-delta);
+		}
+		while (skb) {
+			qs.qlen++;
+			skb =3D skb->next;
+		}
+		qs.backlog =3D q->backlogs[idx];
+		qs.drops =3D flow->dropped;
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
+	struct fq_codel_sched_data *q =3D qdisc_priv(sch);
+	unsigned int i;
+
+	if (arg->stop)
+		return;
+
+	for (i =3D 0; i < q->flows_cnt; i++) {
+		if (list_empty(&q->flows[i].flowchain) ||
+		    arg->count < arg->skip) {
+			arg->count++;
+			continue;
+		}
+		if (arg->fn(sch, i + 1, arg) < 0) {
+			arg->stop =3D 1;
+			break;
+		}
+		arg->count++;
+	}
+}
+
+static const struct Qdisc_class_ops fq_codel_class_ops =3D {
+	.leaf		=3D	fq_codel_leaf,
+	.get		=3D	fq_codel_get,
+	.put		=3D	fq_codel_put,
+	.tcf_chain	=3D	fq_codel_find_tcf,
+	.bind_tcf	=3D	fq_codel_bind,
+	.unbind_tcf	=3D	fq_codel_put,
+	.dump		=3D	fq_codel_dump_class,
+	.dump_stats	=3D	fq_codel_dump_class_stats,
+	.walk		=3D	fq_codel_walk,
+};
+
+static struct Qdisc_ops fq_codel_qdisc_ops __read_mostly =3D {
+	.cl_ops		=3D	&fq_codel_class_ops,
+	.id		=3D	"fq_codel",
+	.priv_size	=3D	sizeof(struct fq_codel_sched_data),
+	.enqueue	=3D	fq_codel_enqueue,
+	.dequeue	=3D	fq_codel_dequeue,
+	.peek		=3D	qdisc_peek_dequeued,
+	.drop		=3D	fq_codel_drop,
+	.init		=3D	fq_codel_init,
+	.reset		=3D	fq_codel_reset,
+	.destroy	=3D	fq_codel_destroy,
+	.change		=3D	fq_codel_change,
+	.dump		=3D	fq_codel_dump,
+	.dump_stats =3D	fq_codel_dump_stats,
+	.owner		=3D	THIS_MODULE,
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
