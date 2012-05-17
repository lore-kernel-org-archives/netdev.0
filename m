From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2] drop_monitor: convert to modular building
Date: Thu, 17 May 2012 13:49:00 -0400
Message-ID: <1337276940-5025-1-git-send-email-nhorman@tuxdriver.com>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37491 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762241Ab2EQRtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 13:49:17 -0400
In-Reply-To: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I first wrote drop monitor I wrote it to just build monolithically.  There
is no reason it can't be built modularly as well, so lets give it that
flexibiity.

I've tested this by building it as both a module and monolithically, and it
seems to work quite well

Change notes:

v2)
* fixed for_each_present_cpu loops to be more correct as per Eric D.
* Converted exit path failures to BUG_ON as per Ben H.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---
 net/Kconfig             |    2 +-
 net/core/drop_monitor.c |   46 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 45 insertions(+), 3 deletions(-)

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
index cfeeef8..b6760a6 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -24,6 +24,7 @@
 #include <linux/timer.h>
 #include <linux/bitops.h>
 #include <linux/slab.h>
+#include <linux/module.h>
 #include <net/genetlink.h>
 #include <net/netevent.h>
 
@@ -225,9 +226,15 @@ static int set_all_monitor_traces(int state)
 
 	switch (state) {
 	case TRACE_ON:
+		if (!try_module_get(THIS_MODULE)) {
+			rc = -ENODEV;
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
@@ -243,6 +250,9 @@ static int set_all_monitor_traces(int state)
 				kfree_rcu(new_stat, rcu);
 			}
 		}
+
+		module_put(THIS_MODULE);
+
 		break;
 	default:
 		rc = 1;
@@ -368,7 +378,7 @@ static int __init init_net_drop_monitor(void)
 
 	rc = 0;
 
-	for_each_present_cpu(cpu) {
+	for_each_possible_cpu(cpu) {
 		data = &per_cpu(dm_cpu_data, cpu);
 		reset_per_cpu_data(data);
 		INIT_WORK(&data->dm_alert_work, send_dm_alert);
@@ -385,4 +395,36 @@ out:
 	return rc;
 }
 
-late_initcall(init_net_drop_monitor);
+static void exit_net_drop_monitor(void)
+{
+	struct per_cpu_dm_data *data;
+	int cpu;
+
+	BUG_ON(unregister_netdevice_notifier(&dropmon_net_notifier));
+
+	/*
+	 * Because of the module_get/put we do in the trace state change path
+	 * we are guarnateed not to have any current users when we get here
+	 * all we need to do is make sure that we don't have any running timers
+	 * or pending schedule calls
+	 */
+
+	for_each_possible_cpu(cpu) {
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
+	BUG_ON(genl_unregister_family(&net_drop_monitor_family));
+}
+
+module_init(init_net_drop_monitor);
+module_exit(exit_net_drop_monitor);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Neil Horman <nhorman@tuxdriver.com>");
-- 
1.7.7.6
