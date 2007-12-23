From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement: kernel
Date: Sun, 23 Dec 2007 20:54:40 +0100
Message-ID: <476EBD00.2060905@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47559119.6070803@candelatech.com> <47559455.1080009@ee.ethz.ch> <47559763.9050408@candelatech.com> <4755C984.70906@ee.ethz.ch> <4755D2EB.4000807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:39073 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684AbXLWTyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2007 14:54:51 -0500
In-Reply-To: <4755D2EB.4000807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch applies to kernel 2.6.23.
It enhances the network emulator netem with the possibility
to read all delay/drop/duplicate etc values from a trace file.
This trace file contains for each packet to be processed one value.
The values are read from the file in a user space process called
flowseed. These values are sent to the netem module with the help of
rtnetlink sockets.
In the netem module the values are "cached" in buffers.
The number of buffers is configurable upon start of netem.
If a buffer is empty the netem module sends a rtnetlink notification
to the flowseed process.
Upon receiving such a notification this process sends
the next 1000 values to the netem module.

signed-off-by: Ariane Keller <ariane.keller@tik.ee.ethz.ch>

---
diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
linux-2.6.23.8/include/linux/pkt_sched.h 
linux-2.6.23.8_mod/include/linux/pkt_sched.h
--- linux-2.6.23.8/include/linux/pkt_sched.h	2007-11-16 
19:14:27.000000000 +0100
+++ linux-2.6.23.8_mod/include/linux/pkt_sched.h	2007-12-21 
19:42:49.000000000 +0100
@@ -439,6 +439,9 @@ enum
  	TCA_NETEM_DELAY_DIST,
  	TCA_NETEM_REORDER,
  	TCA_NETEM_CORRUPT,
+	TCA_NETEM_TRACE,
+	TCA_NETEM_TRACE_DATA,
+	TCA_NETEM_STATS,
  	__TCA_NETEM_MAX,
  };

@@ -454,6 +457,26 @@ struct tc_netem_qopt
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
+	int reloadbuffer;
+};
+
+struct tc_netem_trace
+{
+	__u32   fid;             /*flowid */
+	__u32   def;          	 /* default action 0 = no delay, 1 = drop*/
+	__u32   ticks;	         /* number of ticks corresponding to 1ms */
+	__u32   nr_bufs;	 /* number of buffers to save trace data*/
+};
+
  struct tc_netem_corr
  {
  	__u32	delay_corr;	/* delay correlation */
diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
linux-2.6.23.8/include/net/flowseed.h 
linux-2.6.23.8_mod/include/net/flowseed.h
--- linux-2.6.23.8/include/net/flowseed.h	1970-01-01 01:00:00.000000000 
+0100
+++ linux-2.6.23.8_mod/include/net/flowseed.h	2007-12-21 
19:43:24.000000000 +0100
@@ -0,0 +1,34 @@
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
+/* struct per flow - kernel */
+struct tcn_control
+{
+	struct list_head full_buffer_list;
+	struct list_head empty_buffer_list;
+	struct buflist * buffer_in_use;		
+	int *offsetpos;       /* pointer to actual pos in the buffer in use */
+	int flowid;
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
+	int reloadbuffer;
+};
+
+#endif
diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
linux-2.6.23.8/include/net/pkt_sched.h 
linux-2.6.23.8_mod/include/net/pkt_sched.h
--- linux-2.6.23.8/include/net/pkt_sched.h	2007-11-16 19:14:27.000000000 
+0100
+++ linux-2.6.23.8_mod/include/net/pkt_sched.h	2007-12-21 
19:42:49.000000000 +0100
@@ -72,6 +72,9 @@ extern void qdisc_watchdog_cancel(struct
  extern struct Qdisc_ops pfifo_qdisc_ops;
  extern struct Qdisc_ops bfifo_qdisc_ops;

+extern int qdisc_notify_pid(int pid, struct nlmsghdr *n, u32 clid,
+			struct Qdisc *old, struct Qdisc *new);
+
  extern int register_qdisc(struct Qdisc_ops *qops);
  extern int unregister_qdisc(struct Qdisc_ops *qops);
  extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
linux-2.6.23.8/net/core/rtnetlink.c linux-2.6.23.8_mod/net/core/rtnetlink.c
--- linux-2.6.23.8/net/core/rtnetlink.c	2007-11-16 19:14:27.000000000 +0100
+++ linux-2.6.23.8_mod/net/core/rtnetlink.c	2007-12-21 
19:42:49.000000000 +0100
@@ -460,7 +460,7 @@ int rtnetlink_send(struct sk_buff *skb,
  	NETLINK_CB(skb).dst_group = group;
  	if (echo)
  		atomic_inc(&skb->users);
-	netlink_broadcast(rtnl, skb, pid, group, GFP_KERNEL);
+	netlink_broadcast(rtnl, skb, pid, group, gfp_any());
  	if (echo)
  		err = netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
  	return err;
diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
linux-2.6.23.8/net/sched/sch_api.c linux-2.6.23.8_mod/net/sched/sch_api.c
--- linux-2.6.23.8/net/sched/sch_api.c	2007-11-16 19:14:27.000000000 +0100
+++ linux-2.6.23.8_mod/net/sched/sch_api.c	2007-12-21 19:42:49.000000000 
+0100
@@ -28,6 +28,7 @@
  #include <linux/list.h>
  #include <linux/hrtimer.h>

+#include <net/sock.h>
  #include <net/netlink.h>
  #include <net/pkt_sched.h>

@@ -841,6 +842,62 @@ rtattr_failure:
  	nlmsg_trim(skb, b);
  	return -1;
  }
+static int tc_fill(struct sk_buff *skb, struct Qdisc *q, u32 clid,
+			 u32 pid, u32 seq, u16 flags, int event)
+{
+	struct tcmsg *tcm;
+	struct nlmsghdr  *nlh;
+	unsigned char *b = skb_tail_pointer(skb);
+
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
+	tcm = NLMSG_DATA(nlh);
+	tcm->tcm_family = AF_UNSPEC;
+	tcm->tcm__pad1 = 0;
+	tcm->tcm__pad2 = 0;
+	tcm->tcm_ifindex = q->dev->ifindex;
+	tcm->tcm_parent = clid;
+	tcm->tcm_handle = q->handle;
+	tcm->tcm_info = atomic_read(&q->refcnt);
+	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
+	if (q->ops->dump && q->ops->dump(q, skb) < 0)
+		goto rtattr_failure;
+
+	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
+
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+int qdisc_notify_pid(int pid, struct nlmsghdr *n,
+			u32 clid, struct Qdisc *old, struct Qdisc *new)
+{
+	struct sk_buff *skb;
+	skb = alloc_skb(NLMSG_GOODSIZE, gfp_any());
+	if (!skb)
+		return -ENOBUFS;
+
+	if (old && old->handle) {
+		if (tc_fill(skb, old, clid, pid, n->nlmsg_seq,
+				0, RTM_DELQDISC) < 0)
+			goto err_out;
+	}
+	if (new) {
+		if (tc_fill(skb, new, clid, pid, n->nlmsg_seq,
+				old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
+			goto err_out;
+	}
+	if (skb->len)
+		return rtnetlink_send(skb, pid, RTNLGRP_TC, n->nlmsg_flags);
+
+err_out:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+EXPORT_SYMBOL(qdisc_notify_pid);

  static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n,
  			u32 clid, struct Qdisc *old, struct Qdisc *new)
@@ -848,7 +905,7 @@ static int qdisc_notify(struct sk_buff *
  	struct sk_buff *skb;
  	u32 pid = oskb ? NETLINK_CB(oskb).pid : 0;

-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	skb = alloc_skb(NLMSG_GOODSIZE, gfp_any());
  	if (!skb)
  		return -ENOBUFS;

diff -uprN -X linux-2.6.23.8/Documentation/dontdiff 
linux-2.6.23.8/net/sched/sch_netem.c 
linux-2.6.23.8_mod/net/sched/sch_netem.c
--- linux-2.6.23.8/net/sched/sch_netem.c	2007-11-16 19:14:27.000000000 +0100
+++ linux-2.6.23.8_mod/net/sched/sch_netem.c	2007-12-21 
19:42:49.000000000 +0100
@@ -11,6 +11,8 @@
   *
   * Authors:	Stephen Hemminger <shemminger@osdl.org>
   *		Catalin(ux aka Dino) BOIE <catab at umbrella dot ro>
+ *              netem trace: Ariane Keller <arkeller at ee.ethz.ch> ETH 
Zurich
+ *                           Rainer Baumann <baumann at hypert.net> ETH 
Zurich
   */

  #include <linux/module.h>
@@ -19,11 +21,13 @@
  #include <linux/errno.h>
  #include <linux/skbuff.h>
  #include <linux/rtnetlink.h>
-
+#include <linux/list.h>
  #include <net/netlink.h>
  #include <net/pkt_sched.h>

-#define VERSION "1.2"
+#include "net/flowseed.h"
+
+#define VERSION "1.3"

  /*	Network Emulation Queuing algorithm.
  	====================================
@@ -49,6 +53,11 @@

  	 The simulator is limited by the Linux timer resolution
  	 and will create packet bursts on the HZ boundary (1ms).
+
+	 The trace option allows us to read the values for packet delay,
+	 duplication, loss and corruption from a tracefile. This permits
+	 the modulation of statistical properties such as long-range
+	 dependences. See http://tcn.hypert.net.
  */

  struct netem_sched_data {
@@ -65,7 +74,11 @@ struct netem_sched_data {
  	u32 duplicate;
  	u32 reorder;
  	u32 corrupt;
-
+	u32 trace;
+	u32 ticks;
+	u32 def;
+	u32 flowid;
+	u32 bufnr;
  	struct crndstate {
  		u32 last;
  		u32 rho;
@@ -75,13 +88,29 @@ struct netem_sched_data {
  		u32  size;
  		s16 table[0];
  	} *delay_dist;
+
+	struct tcn_statistic *statistic;
+	struct tcn_control *flowbuffer;
+};
+
+struct  buflist {
+	struct list_head list;
+	char *buf;
  };

+
  /* Time stamp put into socket buffer control block */
  struct netem_skb_cb {
  	psched_time_t	time_to_send;
  };

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
@@ -141,6 +170,72 @@ static psched_tdiff_t tabledist(psched_t
  	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
  }

+/* don't call this function directly. It is called after
+ * a packet has been taken out of a buffer and it was the last.
+ */
+static int reload_flowbuffer(struct netem_sched_data *q, struct Qdisc *sch)
+{
+	struct tcn_control *flow = q->flowbuffer;
+	struct nlmsghdr n;
+	struct buflist *element = list_entry(flow->full_buffer_list.next,
+					     struct buflist, list);
+	/* the current buffer is empty */
+	list_add_tail(&flow->buffer_in_use->list, &flow->empty_buffer_list);
+
+	if (list_empty(&q->flowbuffer->full_buffer_list)) {
+		printk(KERN_ERR "netem: reload_flowbuffer, no full buffer\n");
+		return -EFAULT;
+	}
+
+	list_del_init(&element->list);
+	flow->buffer_in_use = element;
+	flow->offsetpos = (int *)element->buf;
+	memset(&n, 0, sizeof(struct nlmsghdr));
+	n.nlmsg_seq = 1;
+	n.nlmsg_flags = NLM_F_REQUEST;
+	if (qdisc_notify_pid(q->flowid, &n, sch->parent, NULL, sch) < 0)
+		printk(KERN_ERR "netem: unable to request for more data\n");
+
+	return 0;
+}
+
+/* return pktdelay with delay and drop/dupl/corrupt option */
+static int get_next_delay(struct netem_sched_data *q, enum tcn_action 
*head,
+			  struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct tcn_control *flow = q->flowbuffer;
+	u32 variout;
+	/*choose whether to drop or 0 delay packets on default*/
+	*head = q->def;
+
+	if (!flow) {
+		printk(KERN_ERR "netem: read from an uninitialized flow.\n");
+		q->statistic->novaliddata++;
+		return 0;
+	}
+	if (!flow->buffer_in_use) {
+		printk(KERN_ERR "netem: read from uninitialized flow\n");
+		return 0;
+	}
+	if (!flow->buffer_in_use->buf || !flow->offsetpos) {
+		printk(KERN_ERR "netem: buffer empty or offsetpos null\n");
+		return 0;
+	}
+
+	q->statistic->packetcount++;
+	/* check if we have to reload a buffer */
+	if ((void *)flow->offsetpos - (void *)flow->buffer_in_use->buf == 
DATA_PACKAGE)
+		reload_flowbuffer(q, sch);
+
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
@@ -153,17 +248,23 @@ static int netem_enqueue(struct sk_buff
  	/* We don't fill cb now as skb_unshare() may invalidate it */
  	struct netem_skb_cb *cb;
  	struct sk_buff *skb2;
+	enum tcn_action action = FLOW_NORMAL;
+	psched_tdiff_t delay  = -1;
  	int ret;
  	int count = 1;

  	pr_debug("netem_enqueue skb=%p\n", skb);
+	if (q->trace)
+		delay = get_next_delay(q, &action, sch->q.next, sch);

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
@@ -194,7 +295,8 @@ static int netem_enqueue(struct sk_buff
  	 * If packet is going to be hardware checksummed, then
  	 * do it now in software before we mangle it.
  	 */
-	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
+	if (q->trace ? action == FLOW_MANGLE :
+	    (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor))) {
  		if (!(skb = skb_unshare(skb, GFP_ATOMIC))
  		    || (skb->ip_summed == CHECKSUM_PARTIAL
  			&& skb_checksum_help(skb))) {
@@ -210,10 +312,10 @@ static int netem_enqueue(struct sk_buff
  	    || q->counter < q->gap 	/* inside last reordering gap */
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
@@ -332,6 +434,61 @@ static int set_fifo_limit(struct Qdisc *
  	return ret;
  }

+static void reset_stats(struct netem_sched_data *q)
+{
+	if (q->statistic)
+		memset(q->statistic, 0, sizeof(*(q->statistic)));
+	return;
+}
+
+static void free_flowbuffer(struct netem_sched_data *q)
+{
+	struct buflist *cursor;
+	struct buflist *next;
+	list_for_each_entry_safe(cursor, next,
+				 &q->flowbuffer->full_buffer_list, list) {
+		kfree(cursor->buf);
+		list_del(&cursor->list);
+		kfree(cursor);
+	}
+
+	list_for_each_entry_safe(cursor, next,
+				 &q->flowbuffer->empty_buffer_list, list) {
+		kfree(cursor->buf);
+		list_del(&cursor->list);
+		kfree(cursor);
+	}
+
+	kfree(q->flowbuffer->buffer_in_use->buf);
+	kfree(q->flowbuffer->buffer_in_use);
+
+	kfree(q->statistic);
+	kfree(q->flowbuffer);
+	q->statistic = NULL;
+	q->flowbuffer = NULL;
+
+}
+
+static int init_flowbuffer(unsigned int fid, struct netem_sched_data *q)
+{
+	q->statistic = kzalloc(sizeof(*(q->statistic)), GFP_KERNEL);
+	q->flowbuffer = kmalloc(sizeof(*(q->flowbuffer)), GFP_KERNEL);
+
+	INIT_LIST_HEAD(&q->flowbuffer->full_buffer_list);
+	INIT_LIST_HEAD(&q->flowbuffer->empty_buffer_list);
+
+	while (q->bufnr > 0) {
+		int size = sizeof(struct buflist);
+		struct buflist *element = kmalloc(size, GFP_KERNEL);
+		element->buf =  kmalloc(DATA_PACKAGE, GFP_KERNEL);
+		list_add(&element->list, &q->flowbuffer->empty_buffer_list);
+		q->bufnr--;
+	}
+	q->flowbuffer->buffer_in_use = NULL;
+	q->flowbuffer->offsetpos = NULL;
+	return 0;
+}
+
  /*
   * Distribution data is a variable size payload containing
   * signed 16 bit values.
@@ -403,6 +560,87 @@ static int get_corrupt(struct Qdisc *sch
  	return 0;
  }

+static int get_trace(struct Qdisc *sch, const struct rtattr *attr)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	const struct tc_netem_trace *traceopt = RTA_DATA(attr);
+	struct nlmsghdr n;
+	if (RTA_PAYLOAD(attr) != sizeof(*traceopt))
+		return -EINVAL;
+
+	if (traceopt->fid) {
+		q->ticks = traceopt->ticks;
+		q->bufnr = traceopt->nr_bufs;
+		q->trace = 1;
+		init_flowbuffer(traceopt->fid, q);
+	} else {
+		printk(KERN_ERR "netem: invalid flow id\n");
+		q->trace = 0;
+	}
+	q->def = traceopt->def;
+	q->flowid = traceopt->fid;
+
+	memset(&n, 0, sizeof(struct nlmsghdr));
+
+	n.nlmsg_seq = 1;
+	n.nlmsg_flags = NLM_F_REQUEST;
+
+	if (qdisc_notify_pid(traceopt->fid, &n, sch->parent, NULL, sch) < 0) {
+		printk(KERN_ERR "netem: could not send notification");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int get_trace_data(struct Qdisc *sch, const struct rtattr *attr)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	const char *msg = RTA_DATA(attr);
+	int fid, validData;
+	struct buflist *element;
+	struct tcn_control *flow;
+	if (RTA_PAYLOAD(attr) != DATA_PACKAGE_ID) {
+		printk("get_trace_data: invalid size\n");
+		return -EINVAL;
+	}
+	memcpy(&fid, msg + DATA_PACKAGE, sizeof(int));
+	memcpy(&validData, msg + DATA_PACKAGE + sizeof(int), sizeof(int));
+
+	/* check whether this process is allowed to send data */
+	if (fid != q->flowid)
+		return -EPERM;
+
+	/* no empty buffer */
+	if (list_empty(&q->flowbuffer->empty_buffer_list))
+		return -ENOBUFS;
+
+	element = list_entry(q->flowbuffer->empty_buffer_list.next,
+			     struct buflist, list);
+	if (element->buf == NULL)
+		return -ENOBUFS;
+
+	list_del_init(&element->list);
+	memcpy(element->buf, msg, DATA_PACKAGE);
+	flow = q->flowbuffer;
+	if (flow->buffer_in_use == NULL) {
+		flow->buffer_in_use = element;
+		flow->offsetpos = (int *)element->buf;
+	} else
+		list_add_tail(&element->list, &q->flowbuffer->full_buffer_list);
+
+	if (!list_empty(&q->flowbuffer->empty_buffer_list)) {
+		struct nlmsghdr n;
+		memset(&n, 0, sizeof(struct nlmsghdr));
+		n.nlmsg_flags = NLM_F_REQUEST;
+		n.nlmsg_seq = 1;
+		if (qdisc_notify_pid(fid, &n, sch->parent, NULL, sch) < 0)
+			printk(KERN_NOTICE "could not send data "
+				"request for flow %i\n", fid);
+	}
+	q->statistic->reloadbuffer++;
+	return 0;
+}
+
  /* Parse netlink message to set options */
  static int netem_change(struct Qdisc *sch, struct rtattr *opt)
  {
@@ -414,11 +652,6 @@ static int netem_change(struct Qdisc *sc
  		return -EINVAL;

  	qopt = RTA_DATA(opt);
-	ret = set_fifo_limit(q->qdisc, qopt->limit);
-	if (ret) {
-		pr_debug("netem: can't set fifo limit\n");
-		return ret;
-	}

  	q->latency = qopt->latency;
  	q->jitter = qopt->jitter;
@@ -444,6 +677,29 @@ static int netem_change(struct Qdisc *sc
  				 RTA_PAYLOAD(opt) - sizeof(*qopt)))
  			return -EINVAL;

+		/* its a user tc add or tc change command.
+		 * We free the flowbuffer*/
+		if (!tb[TCA_NETEM_TRACE_DATA-1] && q->trace) {
+			struct nlmsghdr n;
+			q->trace = 0;
+			memset(&n, 0, sizeof(struct nlmsghdr));
+			n.nlmsg_flags = NLM_F_REQUEST;
+			n.nlmsg_seq = 1;
+			if (qdisc_notify_pid(q->flowid, &n, sch->parent, sch, NULL) < 0)
+				printk(KERN_NOTICE "netem: cannot send notification\n");
+
+			reset_stats(q);
+			free_flowbuffer(q);
+
+			/* we set the fifo limit: this is done here
+			 * since TRACE_DATA memset qopt to 0 */
+			ret = set_fifo_limit(q->qdisc, qopt->limit);
+			if (ret) {
+				pr_debug("netem: can't set fifo limit\n");
+				return ret;
+			}
+		}
+
  		if (tb[TCA_NETEM_CORR-1]) {
  			ret = get_correlation(sch, tb[TCA_NETEM_CORR-1]);
  			if (ret)
@@ -467,7 +723,40 @@ static int netem_change(struct Qdisc *sc
  			if (ret)
  				return ret;
  		}
+		if (tb[TCA_NETEM_TRACE-1]) {
+			ret = get_trace(sch, tb[TCA_NETEM_TRACE-1]);
+			if (ret)
+				return ret;
+		}
+		if (tb[TCA_NETEM_TRACE_DATA-1]) {
+			ret = get_trace_data(sch, tb[TCA_NETEM_TRACE_DATA-1]);
+			if (ret)
+				return ret;
+		}
+
  	}
+	/* it was a user tc add or tc change request,
+	 * we delete the current flowbuffer*/
+	else {
+		if (q->trace) {
+			struct nlmsghdr n;
+			q->trace = 0;
+			memset(&n, 0, sizeof(struct nlmsghdr));
+			n.nlmsg_flags = NLM_F_REQUEST;
+			n.nlmsg_seq = 1;
+			if (qdisc_notify_pid(q->flowid, &n, sch->parent, sch, NULL) < 0)
+				printk(KERN_NOTICE "netem: could not send notification\n");
+			reset_stats(q);
+			free_flowbuffer(q);
+		}
+		/* we set the fifo limit */
+		ret = set_fifo_limit(q->qdisc, qopt->limit);
+		if (ret) {
+			pr_debug("netem: can't set fifo limit\n");
+			return ret;
+		}
+	}
+

  	return 0;
  }
@@ -567,6 +856,7 @@ static int netem_init(struct Qdisc *sch,

  	qdisc_watchdog_init(&q->watchdog, sch);

+	q->trace = 0;
  	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
  				     TC_H_MAKE(sch->handle, 1));
  	if (!q->qdisc) {
@@ -585,6 +875,16 @@ static int netem_init(struct Qdisc *sch,
  static void netem_destroy(struct Qdisc *sch)
  {
  	struct netem_sched_data *q = qdisc_priv(sch);
+	if (q->trace) {
+		struct nlmsghdr n;
+		q->trace = 0;
+		memset(&n, 0, sizeof(struct nlmsghdr));
+		n.nlmsg_flags = NLM_F_REQUEST;
+		n.nlmsg_seq = 1;
+		if (qdisc_notify_pid(q->flowid, &n, sch->parent, sch, NULL) < 0)
+			printk(KERN_NOTICE "netem: could not send notification\n");
+		free_flowbuffer(q);
+	}

  	qdisc_watchdog_cancel(&q->watchdog);
  	qdisc_destroy(q->qdisc);
@@ -600,6 +900,7 @@ static int netem_dump(struct Qdisc *sch,
  	struct tc_netem_corr cor;
  	struct tc_netem_reorder reorder;
  	struct tc_netem_corrupt corrupt;
+	struct tc_netem_trace traceopt;

  	qopt.latency = q->latency;
  	qopt.jitter = q->jitter;
@@ -622,6 +923,23 @@ static int netem_dump(struct Qdisc *sch,
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
+		tstats.reloadbuffer = q->statistic->reloadbuffer;
+		RTA_PUT(skb, TCA_NETEM_STATS, sizeof(tstats), &tstats);
+	}
  	rta->rta_len = skb_tail_pointer(skb) - b;

  	return skb->len;


Ben Greear wrote:
> Ariane Keller wrote:
> 
>> Yes, for short-term starvation it helps certainly.
>> But I'm still not convinced that it is really necessary to add more 
>> buffers, because I'm not sure whether the bottleneck is really the 
>> loading of data from user space to kernel space.
>> Some basic tests have shown that the kernel starts loosing packets at 
>> approximately the same packet rate regardless whether we use netem, or 
>> netem with the trace extension.
>> But if you have contrary experience I'm happy to add a parameter which 
>> defines the number of buffers.
> 
> I have no numbers, so if you think it works, then that is fine with me.
> 
> If you actually run out of the trace buffers, do you just continue to
> run with the last settings?  If so, that would keep up throughput
> even if you are out of trace buffers...
> 
> What rates do you see, btw?  (pps, bps).
> 
> Thanks,
> Ben
> 

-- 
Ariane Keller
Communication Systems Research Group, ETH Zurich
Web: http://www.csg.ethz.ch/people/arkeller
Office: ETZ G 60.1, Gloriastrasse 35, 8092 Zurich
