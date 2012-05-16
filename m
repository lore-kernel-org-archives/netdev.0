From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] drop_monitor: convert to modular building
Date: Wed, 16 May 2012 10:27:06 -0400
Message-ID: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47968 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089Ab2EPO1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 10:27:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I first wrote drop monitor I wrote it to just build monolithically.  There
is no reason it can't be built modularly as well, so lets give it that
flexibiity.

I've tested this by building it as both a module and monolithically, and it
seems to work quite well

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/Kconfig             |    2 +-
 net/core/drop_monitor.c |   46 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index e07272d..76ad6fa 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -295,7 +295,7 @@ config NET_TCPPROBE
 	module will be called tcp_probe.
 
 config NET_DROP_MONITOR
-	boolean "Network packet drop alerting service"
+	tristate "Network packet drop alerting service"
 	depends on INET && EXPERIMENTAL && TRACEPOINTS
 	---help---
 	This feature provides an alerting service to userspace in the
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 5c3c81a..145f399 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -22,6 +22,7 @@
 #include <linux/timer.h>
 #include <linux/bitops.h>
 #include <linux/slab.h>
+#include <linux/module.h>
 #include <net/genetlink.h>
 #include <net/netevent.h>
 
@@ -223,9 +224,15 @@ static int set_all_monitor_traces(int state)
 
 	switch (state) {
 	case TRACE_ON:
+		if (!try_module_get(THIS_MODULE)) {
+			rc = -EINVAL;
+			break;
+		}
+
 		rc |= register_trace_kfree_skb(trace_kfree_skb_hit, NULL);
 		rc |= register_trace_napi_poll(trace_napi_poll_hit, NULL);
 		break;
+
 	case TRACE_OFF:
 		rc |= unregister_trace_kfree_skb(trace_kfree_skb_hit, NULL);
 		rc |= unregister_trace_napi_poll(trace_napi_poll_hit, NULL);
@@ -241,6 +248,9 @@ static int set_all_monitor_traces(int state)
 				kfree_rcu(new_stat, rcu);
 			}
 		}
+
+		module_put(THIS_MODULE);
+
 		break;
 	default:
 		rc = 1;
@@ -383,4 +393,38 @@ out:
 	return rc;
 }
 
-late_initcall(init_net_drop_monitor);
+static void exit_net_drop_monitor(void)
+{
+	struct per_cpu_dm_data *data;
+	int cpu;
+
+	if (unregister_netdevice_notifier(&dropmon_net_notifier))
+		printk(KERN_WARNING "Unable to unregiser dropmon notifer\n");
+
+	/*
+	 * Because of the module_get/put we do in the trace state change path
+	 * we are guarnateed not to have any current users when we get here
+	 * all we need to do is make sure that we don't have any running timers
+	 * or pending schedule calls
+	 */
+
+	for_each_present_cpu(cpu) {
+		data = &per_cpu(dm_cpu_data, cpu);
+		del_timer(&data->send_timer);
+		cancel_work_sync(&data->dm_alert_work);
+		/*
+		 * At this point, we should have exclusive access
+		 * to this struct and can free the skb inside it
+		 */
+		kfree_skb(data->skb);
+	}
+
+	if (genl_unregister_family(&net_drop_monitor_family))
+		printk(KERN_WARNING "Unable to unregister drop monitor socket family\n");
+}
+
+module_init(init_net_drop_monitor);
+module_exit(exit_net_drop_monitor);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Neil Horman <nhorman@tuxdriver.com>");
-- 
1.7.7.6
