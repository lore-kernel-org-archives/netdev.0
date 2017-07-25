From: martinbj2008@gmail.com
Subject: [PATCH v2 net-next 1/5] drop_monitor: import netnamespace framework
Date: Tue, 25 Jul 2017 19:38:55 +0800
Message-ID: <1500982739-15805-1-git-send-email-zhangjunweimartin@didichuxing.com>
References: <1499855478-29736-1-git-send-email-zhangjunweimartin@didichuxing.com>
Cc: netdev@vger.kernel.org,
        martin Zhang <zhangjunweimartin@didichuxing.com>
To: martinbj2008@gmail.com, davem@davemloft.net, nhorman@tuxdriver.com,
        xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33481 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbdGYLjJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 07:39:09 -0400
Received: by mail-pg0-f66.google.com with SMTP id 123so3665326pgj.0
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 04:39:08 -0700 (PDT)
In-Reply-To: <1499855478-29736-1-git-send-email-zhangjunweimartin@didichuxing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: martin Zhang <zhangjunweimartin@didichuxing.com>

Part1: requirement: dropwatch need work well under docekr instance.
    With the docker be widely accepted, there are several net ns on a single physical host.
some of them may have same IP address. A docker instance is used as a physical host a few years ago.
the owner of a instance only care about the dropped packet in his own instance, not the whole physical host.
so the Initial motivation is:
   provide dropped packet information for per instance(net ns) just like we have done for host.

Part2: why current dropwatch could not work well with docker instance or net namespace
   Dropwatch is a sharp knife to find the location for the dropped packet,
   but it could not work under net namespace(docker instance).
   1. net_drop_monitor_family does not support ".netnsok"
   2. drop monitor does not support statistics for per net namespace.

Part3: How to extend current drop monitor.
For control path
  1. Extend the start/stop netlink command for for per net ns.
    The change is extend the swtich to a per net ns switch.
    without patch: when get start/stop netlink command, check switch filter repeat operation,
        and then (un)register_trace.
    with patch:  when get start/stop netlink command, check per net ns switch to filter repeat operation,
        and then add(dec) ref for global trace, then (un)register_trace if ref (0->1 or 1->0).

For data path
  1. hook the dropped skb: In current version it works well, and is not touched.
  2. get the net namespace of skb, and check if the switch of current net ns is TRACE_on.
    this part is arguable:
    V1: Get netns by skb->dev, skb->sock,
        which is wrong for udp socket.
        Thanks for CongWang and Neil.

    V2: switch to get netns by skb->sock, skb->dev.
        because a: when cross net ns, skb->sk will be clean and set to NULL.
                b. I think no case: skb->sock and skb->dev wil be NULL at the same time.
                If I am wrong, please note me, thanks.

  3. reocord the skb and increase the statistics for net ns of skb.
        This part just extend the netlink skb buffer from a globle variable to per net ns variable.
        without patch:
 47 struct per_cpu_dm_data {
 48         spinlock_t              lock;
 49         struct sk_buff          *skb;
 50         struct work_struct      dm_alert_work;
 51         struct timer_list       send_timer;
 52 };
        with patch:
            only keep dm_alert_work for per cpu, skb and send timer will be change to per cpu of per netns.

  4. broadcast the stat to userspace.
    Keep a workqueue for per cpu. The workqueue function travel all the net namespace and broadcast netlink message
for per netns.
    I think the drop path is unfrequent, maybe it need enhanced for future.

In this patch:
Import two struct to support net ns:

1. struct per_ns_dm_cb:
  Just like its name, it is used in per net ns.

  In this patch it is empty, but in following patch, these field will be added.
  a. trace_state: every net ns has a switch to indicate the trace state.
  b. ns_dm_mutex: the mutex will only work and keep exclusive operatons in a net ns.
  c. hw_stats_list: monitor for NAPI of net device.

2. ns_pcpu_dm_data
   It is used to replace per_cpu_dm_data under per net ns.

   per_cpu_dm_data will only keep the dm_alert_work, and the other field
will be moved to ns_pcpu_dm_data. They do same thing just like current
code, and the only difference is under per net ns.

  Keep there is a work under percpu, to send alter netlink message.

Signed-off-by: martin Zhang <zhangjunweimartin@didichuxing.com>
---
 net/core/drop_monitor.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 70ccda2..6a75e04 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -32,6 +32,10 @@
 #include <trace/events/napi.h>
 
 #include <asm/unaligned.h>
+#include <net/sock.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <linux/smp.h>
 
 #define TRACE_ON 1
 #define TRACE_OFF 0
@@ -41,6 +45,13 @@
  * and the work handle that will send up
  * netlink alerts
  */
+
+struct ns_pcpu_dm_data {
+};
+
+struct per_ns_dm_cb {
+};
+
 static int trace_state = TRACE_OFF;
 static DEFINE_MUTEX(trace_state_mutex);
 
@@ -59,6 +70,7 @@ struct dm_hw_stat_delta {
 	unsigned long last_drop_val;
 };
 
+static int dm_net_id __read_mostly;
 static struct genl_family net_drop_monitor_family;
 
 static DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cpu_data);
@@ -382,6 +394,33 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 	.notifier_call = dropmon_net_event
 };
 
+static int __net_init dm_net_init(struct net *net)
+{
+	struct per_ns_dm_cb *ns_dm_cb;
+
+	ns_dm_cb = net_generic(net, dm_net_id);
+	if (!ns_dm_cb)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __net_exit dm_net_exit(struct net *net)
+{
+	struct per_ns_dm_cb *ns_dm_cb;
+
+	ns_dm_cb = net_generic(net, dm_net_id);
+	if (!ns_dm_cb)
+		return;
+}
+
+static struct pernet_operations dm_net_ops = {
+	.init = dm_net_init,
+	.exit = dm_net_exit,
+	.id   = &dm_net_id,
+	.size = sizeof(struct per_ns_dm_cb),
+};
+
 static int __init init_net_drop_monitor(void)
 {
 	struct per_cpu_dm_data *data;
@@ -393,6 +432,7 @@ static int __init init_net_drop_monitor(void)
 		pr_err("Unable to store program counters on this arch, Drop monitor failed\n");
 		return -ENOSPC;
 	}
+	rc = register_pernet_subsys(&dm_net_ops);
 
 	rc = genl_register_family(&net_drop_monitor_family);
 	if (rc) {
@@ -441,6 +481,7 @@ static void exit_net_drop_monitor(void)
 	 * or pending schedule calls
 	 */
 
+	unregister_pernet_subsys(&dm_net_ops);
 	for_each_possible_cpu(cpu) {
 		data = &per_cpu(dm_cpu_data, cpu);
 		del_timer_sync(&data->send_timer);
-- 
1.8.3.1
