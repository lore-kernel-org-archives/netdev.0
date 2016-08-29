From: Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: [PATCH RFC 2/2] net: Iterate over present cpus only during ipstats
 calculation
Date: Mon, 29 Aug 2016 22:04:09 +0300
Message-ID: <147249744991.18175.5029608970474229005.stgit@pro>
References: <147249730528.18175.4772805024092024580.stgit@pro>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <yoshfuji@linux-ipv6.org>, <jmorris@namei.org>,
        <davem@davemloft.net>, <peterz@infradead.org>,
        <edumazet@google.com>, <mingo@redhat.com>, <kaber@trash.net>,
        <ktkhai@virtuozzo.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0094.outbound.protection.outlook.com ([104.47.2.94]:2369
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757030AbcH2Wg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 18:36:28 -0400
In-Reply-To: <147249730528.18175.4772805024092024580.stgit@pro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use net_stats callback to iterate only present cpus mask.
This gives a signify performance growth on configurations
with large number of possible cpus.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 net/ipv6/addrconf.c |    4 +++-
 net/ipv6/af_inet6.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index df8425f..2ab088d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4970,10 +4970,12 @@ static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
 	memset(buff, 0, sizeof(buff));
 	buff[0] = IPSTATS_MIB_MAX;
 
-	for_each_possible_cpu(c) {
+	preempt_disable();
+	for_each_present_cpu(c) {
 		for (i = 1; i < IPSTATS_MIB_MAX; i++)
 			buff[i] += snmp_get_cpu_field64(mib, c, i, syncpoff);
 	}
+	preempt_enable();
 
 	memcpy(stats, buff, IPSTATS_MIB_MAX * sizeof(u64));
 	memset(&stats[IPSTATS_MIB_MAX], 0, pad);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 46ad699..1c7a431 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -61,6 +61,7 @@
 #include <net/ip6_tunnel.h>
 #endif
 #include <net/calipso.h>
+#include <net/stats.h>
 
 #include <asm/uaccess.h>
 #include <linux/mroute6.h>
@@ -785,6 +786,55 @@ static void ipv6_cleanup_mibs(struct net *net)
 	kfree(net->mib.icmpv6msg_statistics);
 }
 
+static void in6_move_stats(int src_cpu, void __percpu *mib, int max)
+{
+	int i, target_cpu;
+	u64 *ptr, v;
+
+	target_cpu = cpumask_first(cpu_online_mask);
+
+	BUG_ON(target_cpu > nr_cpu_ids || src_cpu != smp_processor_id());
+
+	for (i = 1; i < max; i++) {
+		ptr = ((u64 *)per_cpu_ptr(mib, src_cpu)) + i;
+		v = *ptr;
+		*ptr = 0;
+
+		ptr = ((u64 *)per_cpu_ptr(mib, target_cpu)) + i;
+		*ptr += v;
+	}
+}
+
+static int ipv6_stats_cb(int cpu)
+{
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct net *net;
+
+	WARN_ON(!irqs_disabled());
+
+	rcu_read_lock();
+	write_lock(&dev_base_lock);
+
+	for_each_net(net) {
+		if (!maybe_get_net(net))
+			continue;
+		for_each_netdev(net, dev) {
+			idev = in6_dev_get(dev);
+			if (!idev)
+				continue;
+			in6_move_stats(cpu, idev->stats.ipv6, IPSTATS_MIB_MAX);
+			in6_dev_put(idev);
+		}
+		put_net(net);
+	}
+
+	write_unlock(&dev_base_lock);
+	rcu_read_unlock();
+
+	return 0;
+}
+
 static int __net_init inet6_net_init(struct net *net)
 {
 	int err = 0;
@@ -986,6 +1036,10 @@ static int __init inet6_init(void)
 	if (err)
 		goto pingv6_fail;
 
+	err = register_net_stats_cb(ipv6_stats_cb);
+	if (err)
+		goto net_stats_fail;
+
 	err = calipso_init();
 	if (err)
 		goto calipso_fail;
@@ -1003,6 +1057,8 @@ static int __init inet6_init(void)
 	calipso_exit();
 #endif
 calipso_fail:
+	unregister_net_stats_cb(ipv6_stats_cb);
+net_stats_fail:
 	pingv6_exit();
 pingv6_fail:
 	ipv6_packet_cleanup();
