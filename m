From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: [PATCH 2/2] netem: trace enhancement: kernel
Date: Tue, 20 Nov 2007 23:13:59 +0100
Message-ID: <20071120231359.ek6hyzkpessww4o0@email.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:54051 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759041AbXKTWYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 17:24:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If netem runs with the trace enhancement the function 
tcn_flow_attr_store saves the delay values obtained from the user space 
flowseed process alternately in two buffers. This function does not 
return until new delay values are needed, thus enabling the flowseed 
process to send a new chunk of delay values.

If netem uses the trace option the netem_enqueue function reads the 
delay values from the buffers. All further processing is the same as 
for the other netem options.
tc qdisc show gives a summary over how many packets are processed and 
over the applied values.

Signed-off-by: Ariane Keller <arkeller@ee.ethz.ch>

---

diff -uprN -X linux-2.6.23.8-vanilla/Documentation/dontdiff 
linux-2.6.23.8-vanilla/include/linux/pkt_sched.h 
linux-2.6.23.8/include/linux/pkt_sched.h
--- linux-2.6.23.8-vanilla/include/linux/pkt_sched.h	2007-11-16 
19:14:27.000000000 +0100
+++ linux-2.6.23.8/include/linux/pkt_sched.h	2007-11-20 
13:47:42.000000000 +0100
@@ -439,6 +439,8 @@ enum
	TCA_NETEM_DELAY_DIST,
	TCA_NETEM_REORDER,
	TCA_NETEM_CORRUPT,
+	TCA_NETEM_TRACE,
+	TCA_NETEM_STATS,
	__TCA_NETEM_MAX,
};

@@ -454,6 +456,35 @@ struct tc_netem_qopt
	__u32	jitter;		/* random jitter in latency (us) */
};

+struct tc_netem_stats
+{
+	int packetcount;
+	int packetok;
+	int normaldelay;
+	int drops;
+	int dupl;
+	int corrupt;
+	int novaliddata;
+	int uninitialized;
+	int bufferunderrun;
+	int bufferinuseempty;
+	int noemptybuffer;
+	int readbehindbuffer;
+	int buffer1_reloads;
+	int buffer2_reloads;
+	int tobuffer1_switch;
+	int tobuffer2_switch;
+	int switch_to_empty1;
+	int switch_to_empty2;
+};
+
+struct tc_netem_trace
+{
+	__u32   fid;             /*flowid */
+	__u32   def;          	 /* default action 0 = no delay, 1 = drop*/
+	__u32   ticks;	         /* number of ticks corresponding to 1ms */
+};
+
struct tc_netem_corr
{
	__u32	delay_corr;	/* delay correlation */
diff -uprN -X linux-2.6.23.8-vanilla/Documentation/dontdiff 
linux-2.6.23.8-vanilla/include/net/flowseed.h 
linux-2.6.23.8/include/net/flowseed.h
--- linux-2.6.23.8-vanilla/include/net/flowseed.h	1970-01-01 
01:00:00.000000000 +0100
+++ linux-2.6.23.8/include/net/flowseed.h	2007-11-20 13:47:42.000000000 +0100
@@ -0,0 +1,50 @@
+/* flowseed.h     header file for the netem trace enhancement
+ */
+
+#ifndef _FLOWSEED_H
+#define _FLOWSEED_H
+#include <net/sch_generic.h>
+
+/* must be divisible by 4 (=#pkts)*/
+#define DATA_PACKAGE 4000
+#define DATA_PACKAGE_ID 4008
+
+/* maximal amount of parallel flows */
+#define MAX_FLOWS 8
+
+/* struct per flow - kernel */
+struct tcn_control
+{
+	void *buffer1;
+	void *buffer2;
+	void *buffer_in_use;   /* buffer that is used by consumer */
+	int *offsetpos;       /* pointer to actual pos in the buffer in use */
+	void *buffer1_empty;   /* *buffer1 if buffer is empty, NULL else */
+	void *buffer2_empty;   /* *buffer2 if buffer is empty, NULL else */
+	int validdataB1;        /* 1 if Data in buffer1 is valid */
+	int validdataB2;        /* 1 if Data in buffer2 is valid */
+};
+
+struct tcn_statistic
+{
+	int packetcount;
+	int packetok;
+	int normaldelay;
+	int drops;
+	int dupl;
+	int corrupt;
+	int novaliddata;
+	int uninitialized;
+	int bufferunderrun;
+	int bufferinuseempty;
+	int noemptybuffer;
+	int readbehindbuffer;
+	int buffer1_reloads;
+	int buffer2_reloads;
+	int tobuffer1_switch;
+	int tobuffer2_switch;
+	int switch_to_empty1;
+	int switch_to_empty2;
+};
+
+#endif
diff -uprN -X linux-2.6.23.8-vanilla/Documentation/dontdiff 
linux-2.6.23.8-vanilla/net/sched/Kconfig 
linux-2.6.23.8/net/sched/Kconfig
--- linux-2.6.23.8-vanilla/net/sched/Kconfig	2007-11-16 
19:14:27.000000000 +0100
+++ linux-2.6.23.8/net/sched/Kconfig	2007-11-20 13:47:42.000000000 +0100
@@ -191,6 +191,7 @@ config NET_SCH_DSMARK

config NET_SCH_NETEM
	tristate "Network emulator (NETEM)"
+	select CONFIGFS_FS
	---help---
	  Say Y if you want to emulate network delay, loss, and packet
	  re-ordering. This is often useful to simulate networks when
diff -uprN -X linux-2.6.23.8-vanilla/Documentation/dontdiff 
linux-2.6.23.8-vanilla/net/sched/sch_netem.c 
linux-2.6.23.8/net/sched/sch_netem.c
--- linux-2.6.23.8-vanilla/net/sched/sch_netem.c	2007-11-16 
19:14:27.000000000 +0100
+++ linux-2.6.23.8/net/sched/sch_netem.c	2007-11-20 14:05:43.000000000 +0100
@@ -11,6 +11,8 @@
  *
  * Authors:	Stephen Hemminger <shemminger@osdl.org>
  *		Catalin(ux aka Dino) BOIE <catab at umbrella dot ro>
+ *              netem trace: Ariane Keller <arkeller at ee.ethz.ch> 
ETH Zurich
+ *                           Rainer Baumann <baumann at hypert.net> 
ETH Zurich
  */

#include <linux/module.h>
@@ -19,11 +21,16 @@
#include <linux/errno.h>
#include <linux/skbuff.h>
#include <linux/rtnetlink.h>
-
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/configfs.h>
+#include <linux/vmalloc.h>
#include <net/netlink.h>
#include <net/pkt_sched.h>

-#define VERSION "1.2"
+#include "net/flowseed.h"
+
+#define VERSION "1.3"

/*	Network Emulation Queuing algorithm.
	====================================
@@ -49,6 +56,11 @@

	 The simulator is limited by the Linux timer resolution
	 and will create packet bursts on the HZ boundary (1ms).
+
+	 The trace option allows us to read the values for packet delay,
+	 duplication, loss and corruption from a tracefile. This permits
+	 the modulation of statistical properties such as long-range
+	 dependences. See http://tcn.hypert.net.
*/

struct netem_sched_data {
@@ -65,6 +77,11 @@ struct netem_sched_data {
	u32 duplicate;
	u32 reorder;
	u32 corrupt;
+	u32 tcnstop;
+	u32 trace;
+	u32 ticks;
+	u32 def;
+	u32 newdataneeded;

	struct crndstate {
		u32 last;
@@ -75,6 +92,10 @@ struct netem_sched_data {
		u32  size;
		s16 table[0];
	} *delay_dist;
+
+	struct tcn_statistic *statistic;
+	struct tcn_control *flowbuffer;
+	wait_queue_head_t my_event;
};

/* Time stamp put into socket buffer control block */
@@ -82,6 +103,20 @@ struct netem_skb_cb {
	psched_time_t	time_to_send;
};

+
+struct confdata {
+	int fid;
+	struct netem_sched_data *sched_data;
+};
+
+static struct confdata map[MAX_FLOWS];
+
+#define MASK_BITS	29
+#define MASK_DELAY	((1<<MASK_BITS)-1)
+#define MASK_HEAD       ~MASK_DELAY
+
+enum tcn_action { FLOW_NORMAL, FLOW_DROP, FLOW_DUP, FLOW_MANGLE };
+
/* init_crandom - initialize correlated random number generator
  * Use entropy source for initial seed.
  */
@@ -141,6 +176,103 @@ static psched_tdiff_t tabledist(psched_t
	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
}

+/* don't call this function directly. It is called after
+ * a packet has been taken out of a buffer and it was the last.
+ */
+static int reload_flowbuffer(struct netem_sched_data *q)
+{
+	struct tcn_control *flow = q->flowbuffer;
+
+	if (flow->buffer_in_use == flow->buffer1) {
+		flow->buffer1_empty = flow->buffer1;
+		if (flow->buffer2_empty) {
+			q->statistic->switch_to_empty2++;
+			return -EFAULT;
+		}
+
+		q->statistic->tobuffer2_switch++;
+
+		flow->buffer_in_use = flow->buffer2;
+		flow->offsetpos = flow->buffer2;
+
+	} else {
+		flow->buffer2_empty = flow->buffer2;
+
+		if (flow->buffer1_empty) {
+			q->statistic->switch_to_empty1++;
+			return -EFAULT;
+		}
+
+		q->statistic->tobuffer1_switch++;
+
+		flow->buffer_in_use = flow->buffer1;
+		flow->offsetpos = flow->buffer1;
+
+	}
+	/*the flowseed process can send more data*/
+	q->tcnstop = 0;
+	q->newdataneeded = 1;
+	wake_up(&q->my_event);
+	return 0;
+}
+
+/* return pktdelay with delay and drop/dupl/corrupt option */
+static int get_next_delay(struct netem_sched_data *q, enum tcn_action *head)
+{
+	struct tcn_control *flow = q->flowbuffer;
+	u32 variout;
+
+	/*choose whether to drop or 0 delay packets on default*/
+	*head = q->def;
+
+	if (!flow) {
+		printk(KERN_ERR "netem: read from an uninitialized flow.\n");
+		q->statistic->uninitialized++;
+		return 0;
+	}
+
+	q->statistic->packetcount++;
+
+	/* check if we have to reload a buffer */
+	if ((void *)flow->offsetpos - flow->buffer_in_use == DATA_PACKAGE)
+		reload_flowbuffer(q);
+
+	/* sanity checks */
+	if ((flow->buffer_in_use == flow->buffer1 && flow->validdataB1)
+	    || (flow->buffer_in_use == flow->buffer2 && flow->validdataB2)) {
+
+		if (flow->buffer1_empty && flow->buffer2_empty) {
+			q->statistic->bufferunderrun++;
+			return 0;
+		}
+
+		if (flow->buffer1_empty == flow->buffer_in_use ||
+		    flow->buffer2_empty == flow->buffer_in_use) {
+			q->statistic->bufferinuseempty++;
+			return 0;
+		}
+
+		if ((void *)flow->offsetpos - flow->buffer_in_use >=
+		    DATA_PACKAGE) {
+			q->statistic->readbehindbuffer++;
+			return 0;
+		}
+		/*end of tracefile reached*/
+	} else {
+		q->statistic->novaliddata++;
+		return 0;
+	}
+
+	/* now it's safe to read */
+	variout = *flow->offsetpos++;
+	*head = (variout & MASK_HEAD) >> MASK_BITS;
+
+	(&q->statistic->normaldelay)[*head] += 1;
+	q->statistic->packetok++;
+
+	return ((variout & MASK_DELAY) * q->ticks) / 1000;
+}
+
/*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -153,17 +285,24 @@ static int netem_enqueue(struct sk_buff 	/* We 
don't fill cb now as skb_unshare() may invalidate it */
	struct netem_skb_cb *cb;
	struct sk_buff *skb2;
+	enum tcn_action action = FLOW_NORMAL;
+	psched_tdiff_t delay;
	int ret;
	int count = 1;

	pr_debug("netem_enqueue skb=%p\n", skb);

+	if (q->trace)
+		delay = get_next_delay(q, &action);
+
	/* Random duplication */
-	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
+	if (q->trace ? action == FLOW_DUP :
+	    (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)))
		++count;

	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss && q->loss >= get_crandom(&q->loss_cor))
+	if (q->trace ? action == FLOW_DROP :
+	    (q->loss && q->loss >= get_crandom(&q->loss_cor)))
		--count;

	if (count == 0) {
@@ -194,7 +333,8 @@ static int netem_enqueue(struct sk_buff 	 * If 
packet is going to be hardware checksummed, then
	 * do it now in software before we mangle it.
	 */
-	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
+	if (q->trace ? action == FLOW_MANGLE :
+	    (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor))) {
		if (!(skb = skb_unshare(skb, GFP_ATOMIC))
		    || (skb->ip_summed == CHECKSUM_PARTIAL
			&& skb_checksum_help(skb))) {
@@ -210,10 +350,10 @@ static int netem_enqueue(struct sk_buff 	    || 
q->counter < q->gap 	/* inside last reordering gap */
	    || q->reorder < get_crandom(&q->reorder_cor)) {
		psched_time_t now;
-		psched_tdiff_t delay;

-		delay = tabledist(q->latency, q->jitter,
-				  &q->delay_cor, q->delay_dist);
+		if (!q->trace)
+			delay = tabledist(q->latency, q->jitter,
+					  &q->delay_cor, q->delay_dist);

		now = psched_get_time();
		cb->time_to_send = now + delay;
@@ -332,6 +472,64 @@ static int set_fifo_limit(struct Qdisc *
	return ret;
}

+static void reset_stats(struct netem_sched_data *q)
+{
+	memset(q->statistic, 0, sizeof(*(q->statistic)));
+	return;
+}
+
+static void free_flowbuffer(struct netem_sched_data *q)
+{
+	if (q->flowbuffer != NULL) {
+		q->tcnstop = 1;
+		q->newdataneeded = 1;
+		wake_up(&q->my_event);
+
+		if (q->flowbuffer->buffer1 != NULL)
+			kfree(q->flowbuffer->buffer1);
+
+		if (q->flowbuffer->buffer2 != NULL)
+			kfree(q->flowbuffer->buffer2);
+
+		kfree(q->flowbuffer);
+		kfree(q->statistic);
+		q->flowbuffer = NULL;
+		q->statistic = NULL;
+	}
+}
+
+static int init_flowbuffer(unsigned int fid, struct netem_sched_data *q)
+{
+	int i, flowid = -1;
+
+	q->statistic = kzalloc(sizeof(*(q->statistic)), GFP_KERNEL);
+	init_waitqueue_head(&q->my_event);
+
+	for (i = 0; i < MAX_FLOWS; i++) {
+		if (map[i].fid == 0) {
+			flowid = i;
+			map[i].fid = fid;
+			map[i].sched_data = q;
+			break;
+		}
+	}
+
+	if (flowid != -1) {
+		q->flowbuffer = kmalloc(sizeof(*(q->flowbuffer)), GFP_KERNEL);
+		q->flowbuffer->buffer1 = kmalloc(DATA_PACKAGE, GFP_KERNEL);
+		q->flowbuffer->buffer2 = kmalloc(DATA_PACKAGE, GFP_KERNEL);
+
+		q->flowbuffer->buffer_in_use = q->flowbuffer->buffer1;
+		q->flowbuffer->offsetpos = q->flowbuffer->buffer1;
+		q->flowbuffer->buffer1_empty = q->flowbuffer->buffer1;
+		q->flowbuffer->buffer2_empty = q->flowbuffer->buffer2;
+		q->flowbuffer->validdataB1 = 0;
+		q->flowbuffer->validdataB2 = 0;
+	}
+
+	return flowid;
+}
+
/*
  * Distribution data is a variable size payload containing
  * signed 16 bit values.
@@ -403,6 +601,32 @@ static int get_corrupt(struct Qdisc *sch
	return 0;
}

+static int get_trace(struct Qdisc *sch, const struct rtattr *attr)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	const struct tc_netem_trace *traceopt = RTA_DATA(attr);
+
+	if (RTA_PAYLOAD(attr) != sizeof(*traceopt))
+		return -EINVAL;
+
+	if (traceopt->fid) {
+		/*correction us -> ticks*/
+		int ind;
+		q->ticks = traceopt->ticks;
+		ind = init_flowbuffer(traceopt->fid, q);
+		if (ind < 0) {
+			printk(KERN_INFO "netem: maximum number of traces:%d"
+			       " change in net/flowseedprocfs.h\n", MAX_FLOWS);
+			return -EINVAL;
+		}
+		q->trace = ind + 1;
+
+	} else
+		q->trace = 0;
+	q->def = traceopt->def;
+	return 0;
+}
+
/* Parse netlink message to set options */
static int netem_change(struct Qdisc *sch, struct rtattr *opt)
{
@@ -419,6 +643,13 @@ static int netem_change(struct Qdisc *sc
		pr_debug("netem: can't set fifo limit\n");
		return ret;
	}
+	if (q->trace) {
+		int temp = q->trace - 1;
+		q->trace = 0;
+		map[temp].fid = 0;
+		reset_stats(q);
+		free_flowbuffer(q);
+	}

	q->latency = qopt->latency;
	q->jitter = qopt->jitter;
@@ -467,6 +698,11 @@ static int netem_change(struct Qdisc *sc
			if (ret)
				return ret;
		}
+		if (tb[TCA_NETEM_TRACE-1]) {
+			ret = get_trace(sch, tb[TCA_NETEM_TRACE-1]);
+			if (ret)
+				return ret;
+		}
	}

	return 0;
@@ -567,6 +803,7 @@ static int netem_init(struct Qdisc *sch,

	qdisc_watchdog_init(&q->watchdog, sch);

+	q->trace = 0;
	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
				     TC_H_MAKE(sch->handle, 1));
	if (!q->qdisc) {
@@ -585,6 +822,12 @@ static int netem_init(struct Qdisc *sch,
static void netem_destroy(struct Qdisc *sch)
{
	struct netem_sched_data *q = qdisc_priv(sch);
+	if (q->trace) {
+		int temp = q->trace -1;
+		q->trace = 0;
+		map[temp].fid = 0;
+		free_flowbuffer(q);
+	}

	qdisc_watchdog_cancel(&q->watchdog);
	qdisc_destroy(q->qdisc);
@@ -600,6 +843,7 @@ static int netem_dump(struct Qdisc *sch,
	struct tc_netem_corr cor;
	struct tc_netem_reorder reorder;
	struct tc_netem_corrupt corrupt;
+	struct tc_netem_trace traceopt;

	qopt.latency = q->latency;
	qopt.jitter = q->jitter;
@@ -622,6 +866,33 @@ static int netem_dump(struct Qdisc *sch,
	corrupt.correlation = q->corrupt_cor.rho;
	RTA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);

+	traceopt.fid = q->trace;
+	traceopt.def = q->def;
+	traceopt.ticks = q->ticks;
+	RTA_PUT(skb, TCA_NETEM_TRACE, sizeof(traceopt), &traceopt);
+
+	if (q->trace) {
+		struct tc_netem_stats tstats;
+		tstats.packetcount = q->statistic->packetcount;
+		tstats.packetok = q->statistic->packetok;
+		tstats.normaldelay = q->statistic->normaldelay;
+		tstats.drops = q->statistic->drops;
+		tstats.dupl = q->statistic->dupl;
+		tstats.corrupt = q->statistic->corrupt;
+		tstats.novaliddata = q->statistic->novaliddata;
+		tstats.uninitialized = q->statistic->uninitialized;
+		tstats.bufferunderrun = q->statistic->bufferunderrun;
+		tstats.bufferinuseempty = q->statistic->bufferinuseempty;
+		tstats.noemptybuffer = q->statistic->noemptybuffer;
+		tstats.readbehindbuffer = q->statistic->readbehindbuffer;
+		tstats.buffer1_reloads = q->statistic->buffer1_reloads;
+		tstats.buffer2_reloads = q->statistic->buffer2_reloads;
+		tstats.tobuffer1_switch = q->statistic->tobuffer1_switch;
+		tstats.tobuffer2_switch = q->statistic->tobuffer2_switch;
+		tstats.switch_to_empty1 = q->statistic->switch_to_empty1;
+		tstats.switch_to_empty2 = q->statistic->switch_to_empty2;
+		RTA_PUT(skb, TCA_NETEM_STATS, sizeof(tstats), &tstats);
+	}
	rta->rta_len = skb_tail_pointer(skb) - b;

	return skb->len;
@@ -705,6 +976,172 @@ static struct tcf_proto **netem_find_tcf
	return NULL;
}

+/*configfs to read tcn delay values from userspace*/
+struct tcn_flow {
+	struct config_item item;
+};
+
+static struct tcn_flow *to_tcn_flow(struct config_item *item)
+{
+	return item ? container_of(item, struct tcn_flow, item) : NULL;
+}
+
+static struct configfs_attribute tcn_flow_attr_storeme = {
+	.ca_owner = THIS_MODULE,
+	.ca_name = "delayvalue",
+	.ca_mode = S_IRUGO | S_IWUSR,
+};
+
+static struct configfs_attribute *tcn_flow_attrs[] = {
+	&tcn_flow_attr_storeme,
+	NULL,
+};
+
+static ssize_t tcn_flow_attr_store(struct config_item *item,
+				       struct configfs_attribute *attr,
+				       const char *page, size_t count)
+{
+	char *p = (char *)page;
+	int fid, i, validData = 0;
+	int flowid = -1;
+	struct tcn_control *checkbuf;
+
+	if (count != DATA_PACKAGE_ID) {
+		printk(KERN_INFO "netem: Unexpected data: %d\n", count);
+		return -EMSGSIZE;
+	}
+
+	memcpy(&fid, p + DATA_PACKAGE, sizeof(int));
+	memcpy(&validData, p + DATA_PACKAGE + sizeof(int), sizeof(int));
+
+	/* check whether this flow is registered */
+	for (i = 0; i < MAX_FLOWS; i++) {
+		if (map[i].fid == fid) {
+			flowid = i;
+			break;
+		}
+	}
+	/* exit if flow is not registered */
+	if (flowid < 0) {
+		printk(KERN_INFO "netem: Invalid FID. Killing process.\n");
+		return -EINVAL;
+	}
+
+	checkbuf = map[flowid].sched_data->flowbuffer;
+	if (checkbuf == NULL) {
+		printk(KERN_INFO "netem: no flow registered");
+		return -ENOBUFS;
+	}
+
+	/* check if flowbuffer has empty buffer and copy data into it */
+	if (checkbuf->buffer1_empty != NULL) {
+		memcpy(checkbuf->buffer1, p, DATA_PACKAGE);
+		checkbuf->buffer1_empty = NULL;
+		checkbuf->validdataB1 = validData;
+		map[flowid].sched_data->statistic->buffer1_reloads++;
+
+	} else if (checkbuf->buffer2_empty != NULL) {
+		memcpy(checkbuf->buffer2, p, DATA_PACKAGE);
+		checkbuf->buffer2_empty = NULL;
+		checkbuf->validdataB2 = validData;
+		map[flowid].sched_data->statistic->buffer2_reloads++;
+
+	} else {
+		printk("netem: flow %d: no empty buffer. data loss.\n", flowid);
+		map[flowid].sched_data->statistic->noemptybuffer++;
+	}
+
+	if (validData) {
+		/* on initialization both buffers need data */
+		if (checkbuf->buffer2_empty != NULL)
+			return DATA_PACKAGE_ID;
+
+		/* wait until new data is needed */
+		wait_event(map[flowid].sched_data->my_event,
+			   map[flowid].sched_data->newdataneeded);
+		map[flowid].sched_data->newdataneeded = 0;
+
+	}
+
+	if (map[flowid].sched_data->tcnstop)
+		return -ECANCELED;
+
+	return DATA_PACKAGE_ID;
+
+}
+
+static void tcn_flow_release(struct config_item *item)
+{
+	kfree(to_tcn_flow(item));
+
+}
+
+static struct configfs_item_operations tcn_flow_item_ops = {
+	.release = tcn_flow_release,
+	.store_attribute = tcn_flow_attr_store,
+};
+
+static struct config_item_type tcn_flow_type = {
+	.ct_item_ops = &tcn_flow_item_ops,
+	.ct_attrs = tcn_flow_attrs,
+	.ct_owner = THIS_MODULE,
+};
+
+static struct config_item *tcn_make_item(struct config_group *group,
+						     const char *name)
+{
+	struct tcn_flow *tcn_flow;
+
+	tcn_flow = kmalloc(sizeof(struct tcn_flow), GFP_KERNEL);
+	if (!tcn_flow)
+		return NULL;
+
+	memset(tcn_flow, 0, sizeof(struct tcn_flow));
+
+	config_item_init_type_name(&tcn_flow->item, name,
+				   &tcn_flow_type);
+	return &tcn_flow->item;
+}
+
+static struct configfs_group_operations tcn_group_ops = {
+	.make_item = tcn_make_item,
+};
+
+static struct config_item_type tcn_type = {
+	.ct_group_ops = &tcn_group_ops,
+	.ct_owner = THIS_MODULE,
+};
+
+static struct configfs_subsystem tcn_subsys = {
+	.su_group = {
+		     .cg_item = {
+				 .ci_namebuf = "tcn",
+				 .ci_type = &tcn_type,
+				 },
+		     },
+};
+
+static __init int configfs_init(void)
+{
+	int ret;
+	struct configfs_subsystem *subsys = &tcn_subsys;
+
+	config_group_init(&subsys->su_group);
+	mutex_init(&subsys->su_mutex);
+	ret = configfs_register_subsystem(subsys);
+	if (ret) {
+		printk(KERN_ERR "Error %d while registering subsystem %s\n",
+		       ret, subsys->su_group.cg_item.ci_namebuf);
+		configfs_unregister_subsystem(&tcn_subsys);
+	}
+	return ret;
+}
+
+static void configfs_exit(void)
+{
+	configfs_unregister_subsystem(&tcn_subsys);
+}
+
static struct Qdisc_class_ops netem_class_ops = {
	.graft		=	netem_graft,
	.leaf		=	netem_leaf,
@@ -736,11 +1173,17 @@ static struct Qdisc_ops netem_qdisc_ops static 
int __init netem_module_init(void)
{
+	int err;
+
	pr_info("netem: version " VERSION "\n");
+	err = configfs_init();
+	if (err)
+		return err;
	return register_qdisc(&netem_qdisc_ops);
}
static void __exit netem_module_exit(void)
{
+	configfs_exit();
	unregister_qdisc(&netem_qdisc_ops);
}
module_init(netem_module_init)

