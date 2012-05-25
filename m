From: Arun Sharma <asharma@fb.com>
Subject: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Fri, 25 May 2012 13:15:34 -0700
Message-ID: <1337976934-18065-1-git-send-email-asharma@fb.com>
Cc: Arun Sharma <asharma@fb.com>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The algorithm is based on ipv4 and alloc_large_system_hash().

The following data is from a x86_64 box I tested:

128MB
$ cat /proc/sys/net/ipv{4,6}/route/max_size
16384
22444

512MB
$ cat /proc/sys/net/ipv{4,6}/route/max_size
65536
99856

1GB
$ cat /proc/sys/net/ipv{4,6}/route/max_size
524288
203068

2GB
$ cat /proc/sys/net/ipv{4,6}/route/max_size
1048576
524288

4GB
$ cat /proc/sys/net/ipv{4,6}/route/max_size
2097152
524288

Signed-off-by: Arun Sharma <asharma@fb.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: David Miller <davem@davemloft.net>
---
 net/ipv6/route.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 49d6ce1..c89ebbb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2827,6 +2827,16 @@ struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
 }
 #endif
 
+static __initdata unsigned long ip6_rt_entries;
+static int __init set_rt_entries(char *str)
+{
+	if (!str)
+		return 0;
+	ip6_rt_entries = simple_strtoul(str, &str, 0);
+	return 1;
+}
+__setup("ip6_rt_entries=", set_rt_entries);
+
 static int __net_init ip6_route_net_init(struct net *net)
 {
 	int ret = -ENOMEM;
@@ -2872,8 +2882,17 @@ static int __net_init ip6_route_net_init(struct net *net)
 			 ip6_template_metrics, true);
 #endif
 
+	/* Compute a reasonable default based on what we do for ipv4
+	 * total size = 1/16th of total RAM
+	 * No more than 512k entries unless overridden on kernel cmdline */
+        if (ip6_rt_entries == 0) {
+		ip6_rt_entries = (totalram_pages << PAGE_SHIFT) >> 4;
+		ip6_rt_entries /= sizeof(struct rt6_info);
+		ip6_rt_entries = min(512 * 1024UL, ip6_rt_entries);
+        }
+
 	net->ipv6.sysctl.flush_delay = 0;
-	net->ipv6.sysctl.ip6_rt_max_size = 4096;
+	net->ipv6.sysctl.ip6_rt_max_size = ip6_rt_entries;
 	net->ipv6.sysctl.ip6_rt_gc_min_interval = HZ / 2;
 	net->ipv6.sysctl.ip6_rt_gc_timeout = 60*HZ;
 	net->ipv6.sysctl.ip6_rt_gc_interval = 30*HZ;
-- 
1.7.8.4
