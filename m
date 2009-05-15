From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Fri, 15 May 2009 12:07:02 -0400
Message-ID: <20090515160702.GE7745@hmsreliant.think-freely.org>
References: <20090512163044.GD5019@hmsreliant.think-freely.org> <20090513182354.GH6752@linux.vnet.ibm.com> <20090514004548.GA14428@localhost.localdomain> <20090514010359.GL6752@linux.vnet.ibm.com> <20090514123300.GA7166@hmsreliant.think-freely.org> <20090514124407.GP3517@psychotron.englab.brq.redhat.com> <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515065102.GB25620@psychotron.englab.brq.redhat.com> <20090515105909.GA7745@hmsreliant.think-freely.org> <20090515112736.GG25620@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56149 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113AbZEOQHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 12:07:24 -0400
Content-Disposition: inline
In-Reply-To: <20090515112736.GG25620@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 01:27:36PM +0200, Jiri Pirko wrote:
> Fri, May 15, 2009 at 12:59:09PM CEST, nhorman@tuxdriver.com wrote:
> >On Fri, May 15, 2009 at 08:51:02AM +0200, Jiri Pirko wrote:
> >> Thu, May 14, 2009 at 07:29:54PM CEST, nhorman@tuxdriver.com wrote:
> >> >On Thu, May 14, 2009 at 02:44:08PM +0200, Jiri Pirko wrote:
> >> >> >+
> >> >> >+		/*
> >> >> >+		 * Clean the device list
> >> >> >+		 */
> >> >> >+		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> >> >> 		^^^^^^^^^^^^^^^^^^^^^^^
> >> >> This is meaningless here. Use list_for_each_entry_rcu only under rcu_read_lock.
> >> >> Also it would be good to use list_for_each_entry_safe here since you're
> >> >> modifying the list.
> >> >> 
> >> >
> >> >The definition of list_for_each_entry_rcu specifically says its safe against
> >> >list-mutation primitives, so its fine.  Although you are correct, in that its
> >> >safety is dependent on the protection of rcu_read_lock(), so I'll add that in.
> >> 
> >> You are right that list_for_each_entry_rcu is safe against list-mutation
> >> primitives. But there's no need for this on the update side when you hold a writer
> >> spinlock. Here I think it's better (and also less confusing) to use ordinary
> >> list_for_each_entry which in this case must be list_for_each_entry_safe.
> >> 
> >> 		Jirka
> >> 
> >I disagree.  I think visually its more understandable with the rcu variant, and
> >that spinlock isn't a writer spinlock, the other uses of this list don't use
> >that lock (to imporove performance).  The spinlock is there simply to serialize
> >changes to the trace state (so that one cpu doen't try to turn dropmon on, while
> >another tries to turn it off).  So we need the rcu variant to protect the list
> >removal against concurrent use on the reader side in the new registered trace
> >point function.
> 
> Ok, since you spinlock is not writer lock, you need to protect writers from
> concurrent list updates anyway! And this spinlock does that work. Then you
> _donotneed_ rcu_read_lock to read from list, you work with it as with ordinary
> list while reading. As Eric wrote this approach is common.
> 
> 		Jirka
> 

Ok, I've spent the morning looking at several other examples, and re-reading
your comments and Erics, and agree, the rcu_read_lock doesn't need to be there,
and a writer mutex does (which I can use trace_state_lock for).  As such, I've
got a new patch below, tested and working.  I think it fully takes your and
Erics comments into account.

V4 Change Notes:
1) Remove rcu_read_lock from TRACE_OFF case in set_all_monitor_traces, since its
not needed in light of the use of the trace_state_lock to protect list mutations 

2) Change list_for_each_entry_rcu to list_for_each_entry_safe, since rcu list
traversal isn't needed here.

3) Fully protect global tracer state with trace_state lock

4) Add freeing code to the NETDEV_UNREGISTER event notification to safe on
memory if the tracer is never used (using trace_state_lock properly here too)



Patch to add the ability to detect drops in hardware interfaces via dropwatch.
Adds a tracepoint to net_rx_action to signal everytime a napi instance is
polled.  The dropmon code then periodically checks to see if the rx_frames
counter has changed, and if so, adds a drop notification to the netlink
protocol, using the reserved all-0's vector to indicate the drop location was in
hardware, rather than somewhere in the code.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>



 include/linux/net_dropmon.h |    7 ++
 include/trace/napi.h        |   11 +++
 net/core/dev.c              |    5 +
 net/core/drop_monitor.c     |  127 ++++++++++++++++++++++++++++++++++++++++++--
 net/core/net-traces.c       |    4 +
 net/core/netpoll.c          |    2 
 6 files changed, 151 insertions(+), 5 deletions(-)

diff --git a/include/linux/net_dropmon.h b/include/linux/net_dropmon.h
index 0217fb8..9addc62 100644
--- a/include/linux/net_dropmon.h
+++ b/include/linux/net_dropmon.h
@@ -8,6 +8,13 @@ struct net_dm_drop_point {
 	__u32 count;
 };
 
+#define is_drop_point_hw(x) do {\
+	int ____i, ____j;\
+	for (____i = 0; ____i < 8; i ____i++)\
+		____j |= x[____i];\
+	____j;\
+} while (0)
+
 #define NET_DM_CFG_VERSION  0
 #define NET_DM_CFG_ALERT_COUNT  1
 #define NET_DM_CFG_ALERT_DELAY 2
diff --git a/include/trace/napi.h b/include/trace/napi.h
new file mode 100644
index 0000000..7c39eb7
--- /dev/null
+++ b/include/trace/napi.h
@@ -0,0 +1,11 @@
+#ifndef _TRACE_NAPI_H_
+#define _TRACE_NAPI_H_
+
+#include <linux/skbuff.h>
+#include <linux/tracepoint.h>
+
+DECLARE_TRACE(napi_poll,
+	TP_PROTO(struct napi_struct *napi),
+	TP_ARGS(napi));
+
+#endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 637ea71..165979c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -126,6 +126,7 @@
 #include <linux/in.h>
 #include <linux/jhash.h>
 #include <linux/random.h>
+#include <trace/napi.h>
 
 #include "net-sysfs.h"
 
@@ -2763,8 +2764,10 @@ static void net_rx_action(struct softirq_action *h)
 		 * accidently calling ->poll() when NAPI is not scheduled.
 		 */
 		work = 0;
-		if (test_bit(NAPI_STATE_SCHED, &n->state))
+		if (test_bit(NAPI_STATE_SCHED, &n->state)) {
 			work = n->poll(n, weight);
+			trace_napi_poll(n);
+		}
 
 		WARN_ON_ONCE(work > weight);
 
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 2797b71..4f7e915 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -22,8 +22,10 @@
 #include <linux/timer.h>
 #include <linux/bitops.h>
 #include <net/genetlink.h>
+#include <net/netevent.h>
 
 #include <trace/skb.h>
+#include <trace/napi.h>
 
 #include <asm/unaligned.h>
 
@@ -38,7 +40,8 @@ static void send_dm_alert(struct work_struct *unused);
  * and the work handle that will send up
  * netlink alerts
  */
-struct sock *dm_sock;
+static int trace_state = TRACE_OFF;
+static spinlock_t trace_state_lock = SPIN_LOCK_UNLOCKED;
 
 struct per_cpu_dm_data {
 	struct work_struct dm_alert_work;
@@ -47,6 +50,13 @@ struct per_cpu_dm_data {
 	struct timer_list send_timer;
 };
 
+struct dm_hw_stat_delta {
+	struct net_device *dev;
+	struct list_head list;
+	struct rcu_head rcu;
+	unsigned long last_drop_val;
+};
+
 static struct genl_family net_drop_monitor_family = {
 	.id             = GENL_ID_GENERATE,
 	.hdrsize        = 0,
@@ -59,7 +69,8 @@ static DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cpu_data);
 
 static int dm_hit_limit = 64;
 static int dm_delay = 1;
-
+static unsigned long dm_hw_check_delta = 2*HZ;
+static LIST_HEAD(hw_stats_list);
 
 static void reset_per_cpu_data(struct per_cpu_dm_data *data)
 {
@@ -115,7 +126,7 @@ static void sched_send_work(unsigned long unused)
 	schedule_work(&data->dm_alert_work);
 }
 
-static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
+static void trace_drop_common(struct sk_buff *skb, void *location)
 {
 	struct net_dm_alert_msg *msg;
 	struct nlmsghdr *nlh;
@@ -159,24 +170,80 @@ out:
 	return;
 }
 
+static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
+{
+	trace_drop_common(skb, location);
+}
+
+static void trace_napi_poll_hit(struct napi_struct *napi)
+{
+	struct dm_hw_stat_delta *new_stat;
+
+	/*
+	 * Ratelimit our check time to dm_hw_check_delta jiffies
+	 */
+	if (!time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
+		return;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
+		if ((new_stat->dev == napi->dev)  &&
+		    (napi->dev->stats.rx_dropped != new_stat->last_drop_val)) {
+			trace_drop_common(NULL, NULL);
+			new_stat->last_drop_val = napi->dev->stats.rx_dropped;
+			break;
+		}
+	}
+	rcu_read_unlock();
+}
+
+
+static void free_dm_hw_stat(struct rcu_head *head)
+{
+	struct dm_hw_stat_delta *n;
+	n = container_of(head, struct dm_hw_stat_delta, rcu);
+	kfree(n);
+}
+
 static int set_all_monitor_traces(int state)
 {
 	int rc = 0;
+	struct dm_hw_stat_delta *new_stat = NULL;
+	struct dm_hw_stat_delta *temp;
+
+	spin_lock(&trace_state_lock);
 
 	switch (state) {
 	case TRACE_ON:
 		rc |= register_trace_kfree_skb(trace_kfree_skb_hit);
+		rc |= register_trace_napi_poll(trace_napi_poll_hit);
 		break;
 	case TRACE_OFF:
 		rc |= unregister_trace_kfree_skb(trace_kfree_skb_hit);
+		rc |= unregister_trace_napi_poll(trace_napi_poll_hit);
 
 		tracepoint_synchronize_unregister();
+
+		/*
+		 * Clean the device list
+		 */
+		list_for_each_entry_safe(new_stat, temp, &hw_stats_list, list) {
+			if (new_stat->dev == NULL) {
+				list_del_rcu(&new_stat->list);
+				call_rcu(&new_stat->rcu, free_dm_hw_stat);
+			}
+		}
 		break;
 	default:
 		rc = 1;
 		break;
 	}
 
+	if (!rc)
+		trace_state = state;
+
+	spin_unlock(&trace_state_lock);
+
 	if (rc)
 		return -EINPROGRESS;
 	return rc;
@@ -204,6 +271,47 @@ static int net_dm_cmd_trace(struct sk_buff *skb,
 	return -ENOTSUPP;
 }
 
+static int dropmon_net_event(struct notifier_block *ev_block,
+			unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct dm_hw_stat_delta *new_stat = NULL;
+	int found = 0;
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		new_stat = kzalloc(sizeof(struct dm_hw_stat_delta), GFP_KERNEL);
+
+		if (!new_stat)
+			goto out;
+
+		new_stat->dev = dev;
+		INIT_RCU_HEAD(&new_stat->rcu);
+		spin_lock(&trace_state_lock);
+		list_add_rcu(&new_stat->list, &hw_stats_list);
+		spin_unlock(&trace_state_lock);
+		break;
+	case NETDEV_UNREGISTER:
+		rcu_read_lock();
+		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
+			if (new_stat->dev == dev)
+				new_stat->dev = NULL;
+				found = 1;
+				break;
+		}
+		rcu_read_unlock();
+
+		spin_lock(&trace_state_lock);
+		if (found && (trace_state == TRACE_OFF)) {
+			list_del_rcu(&new_stat->list);
+			call_rcu(&new_stat->rcu, free_dm_hw_stat);
+		}
+		spin_unlock(&trace_state_lock);
+		break;
+	}
+out:
+	return NOTIFY_DONE;
+}
 
 static struct genl_ops dropmon_ops[] = {
 	{
@@ -220,6 +328,10 @@ static struct genl_ops dropmon_ops[] = {
 	},
 };
 
+static struct notifier_block dropmon_net_notifier = {
+	.notifier_call = dropmon_net_event
+};
+
 static int __init init_net_drop_monitor(void)
 {
 	int cpu;
@@ -243,12 +355,18 @@ static int __init init_net_drop_monitor(void)
 		ret = genl_register_ops(&net_drop_monitor_family,
 					&dropmon_ops[i]);
 		if (ret) {
-			printk(KERN_CRIT "failed to register operation %d\n",
+			printk(KERN_CRIT "Failed to register operation %d\n",
 				dropmon_ops[i].cmd);
 			goto out_unreg;
 		}
 	}
 
+	rc = register_netdevice_notifier(&dropmon_net_notifier);
+	if (rc < 0) {
+		printk(KERN_CRIT "Failed to register netdevice notifier\n");
+		goto out_unreg;
+	}
+
 	rc = 0;
 
 	for_each_present_cpu(cpu) {
@@ -259,6 +377,7 @@ static int __init init_net_drop_monitor(void)
 		data->send_timer.data = cpu;
 		data->send_timer.function = sched_send_work;
 	}
+
 	goto out;
 
 out_unreg:
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index c8fb456..b07b25b 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -20,6 +20,7 @@
 #include <linux/netlink.h>
 #include <linux/net_dropmon.h>
 #include <trace/skb.h>
+#include <trace/napi.h>
 
 #include <asm/unaligned.h>
 #include <asm/bitops.h>
@@ -27,3 +28,6 @@
 
 DEFINE_TRACE(kfree_skb);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
+
+DEFINE_TRACE(napi_poll);
+EXPORT_TRACEPOINT_SYMBOL_GPL(napi_poll);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index b5873bd..446d3ba 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -24,6 +24,7 @@
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <asm/unaligned.h>
+#include <trace/napi.h>
 
 /*
  * We maintain a small pool of fully-sized skbs, to make sure the
@@ -137,6 +138,7 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
 	work = napi->poll(napi, budget);
+	trace_napi_poll(napi->dev);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
 	atomic_dec(&trapped);

