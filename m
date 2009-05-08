From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] dropmon: add ability to detect when hardware drops rx
	packets
Date: Fri, 8 May 2009 15:50:26 -0400
Message-ID: <20090508195026.GB13017@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40941 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031AbZEHTug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 15:50:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	A few weeks back I sent out an RFC in which I proposed that I could
extend dropwatch to detect drops in hardware by adding a napi poll tracepoint,
using that as an indicator that I should periodically check the stats to see if
the rx drop counter had changed.  Having not had any negative feedback to that
proposal, heres the patch.  I've tested it and it seems to work fairly well.
Neil


Patch to add the ability to detect drops in hardware interfaces via dropwatch.
Adds a tracepoint to net_rx_action to signal everytime a napi instance is
polled.  The dropmon code then periodically checks to see if the rx_frames
counter has changed, and if so, adds a drop notification to the netlink
protocol, using the reserved all-0's vector to indicate the drop location was in
hardware, rather than somewhere in the code.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/net_dropmon.h |    7 ++
 include/trace/napi.h        |   11 ++++
 net/core/dev.c              |    5 +-
 net/core/drop_monitor.c     |  107 ++++++++++++++++++++++++++++++++++++++++++--
 net/core/net-traces.c       |    4 +
 net/core/netpoll.c          |    2 
 6 files changed, 131 insertions(+), 5 deletions(-)

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
index 2797b71..538c1d4 100644
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
 
@@ -38,7 +40,7 @@ static void send_dm_alert(struct work_struct *unused);
  * and the work handle that will send up
  * netlink alerts
  */
-struct sock *dm_sock;
+static int trace_state = TRACE_OFF;
 
 struct per_cpu_dm_data {
 	struct work_struct dm_alert_work;
@@ -47,6 +49,12 @@ struct per_cpu_dm_data {
 	struct timer_list send_timer;
 };
 
+struct dm_hw_stat_delta {
+	struct net_device *dev;
+	struct list_head list;
+	unsigned long last_drop_val;
+};
+
 static struct genl_family net_drop_monitor_family = {
 	.id             = GENL_ID_GENERATE,
 	.hdrsize        = 0,
@@ -59,7 +67,8 @@ static DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cpu_data);
 
 static int dm_hit_limit = 64;
 static int dm_delay = 1;
-
+static unsigned long dm_hw_check_delta = 2*HZ;
+static LIST_HEAD(hw_stats_list);
 
 static void reset_per_cpu_data(struct per_cpu_dm_data *data)
 {
@@ -115,7 +124,7 @@ static void sched_send_work(unsigned long unused)
 	schedule_work(&data->dm_alert_work);
 }
 
-static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
+static void trace_drop_common(struct sk_buff *skb, void *location)
 {
 	struct net_dm_alert_msg *msg;
 	struct nlmsghdr *nlh;
@@ -159,18 +168,59 @@ out:
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
+	list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
+		if ((new_stat->dev == napi->dev)  &&
+		    (napi->dev->stats.rx_dropped != new_stat->last_drop_val)) {
+			trace_drop_common(NULL, NULL);
+			new_stat->last_drop_val = napi->dev->stats.rx_dropped;
+			break;
+		}
+	}
+}
+
+
 static int set_all_monitor_traces(int state)
 {
 	int rc = 0;
+	struct dm_hw_stat_delta *new_stat = NULL;
 
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
+		rcu_read_lock();
+		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
+			if (new_stat->dev == NULL) {
+				list_del_rcu(&new_stat->list);
+				kfree(new_stat);
+			}
+		}
+		rcu_read_unlock();
 		break;
 	default:
 		rc = 1;
@@ -179,6 +229,7 @@ static int set_all_monitor_traces(int state)
 
 	if (rc)
 		return -EINPROGRESS;
+	trace_state = state;
 	return rc;
 }
 
@@ -204,6 +255,43 @@ static int net_dm_cmd_trace(struct sk_buff *skb,
 	return -ENOTSUPP;
 }
 
+int dropmon_net_event(struct notifier_block *ev_block,
+			unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct dm_hw_stat_delta *new_stat = NULL;
+
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		new_stat = kzalloc(sizeof(struct dm_hw_stat_delta), GFP_KERNEL);
+
+		if (!new_stat)
+			goto out;
+
+		new_stat->dev = dev;
+		rcu_read_lock();
+		list_add_rcu(&new_stat->list, &hw_stats_list);
+		rcu_read_unlock();
+		break;
+	case NETDEV_UNREGISTER:
+		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
+			if (new_stat->dev == dev)
+				new_stat->dev = NULL;
+				break;
+		}
+
+		if (trace_state == TRACE_OFF) {
+			rcu_read_lock();
+			list_del_rcu(&new_stat->list);
+			rcu_read_unlock();
+			kfree(new_stat);
+		}
+		break;
+	}
+out:
+	return NOTIFY_DONE;
+}
 
 static struct genl_ops dropmon_ops[] = {
 	{
@@ -220,6 +308,10 @@ static struct genl_ops dropmon_ops[] = {
 	},
 };
 
+static struct notifier_block dropmon_net_notifier = {
+	.notifier_call = dropmon_net_event
+};
+
 static int __init init_net_drop_monitor(void)
 {
 	int cpu;
@@ -243,12 +335,18 @@ static int __init init_net_drop_monitor(void)
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
@@ -259,6 +357,7 @@ static int __init init_net_drop_monitor(void)
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

