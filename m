From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 4/4] inetpeer: Namespacify inet_peer_threshold sysctl knob
Date: Wed, 17 Feb 2016 12:09:58 +0200
Message-ID: <1455703798-15258-5-git-send-email-kernel@kyup.com>
References: <1455703798-15258-1-git-send-email-kernel@kyup.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35858 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933924AbcBQKKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:10:06 -0500
Received: by mail-wm0-f42.google.com with SMTP id g62so151293069wme.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 02:10:05 -0800 (PST)
In-Reply-To: <1455703798-15258-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/ip.h           |  3 ---
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/inetpeer.c        | 11 ++++-------
 net/ipv4/sysctl_net_ipv4.c | 17 +++++++++--------
 4 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 11a20a3e60c6..b9832da7e636 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -240,9 +240,6 @@ static inline int inet_is_local_reserved_port(struct net *net, int port)
 }
 #endif
 
-/* From inetpeer.c */
-extern int inet_peer_threshold;
-
 void ipfrag_init(void);
 
 void ip_static_sysctl_init(void);
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 1bc51c22ef42..c0d85ba9e5f7 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -90,6 +90,7 @@ struct netns_ipv4 {
 
 	int sysctl_inet_peer_maxttl;
 	int sysctl_inet_peer_minttl;
+	int sysctl_inet_peer_threshold;
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 97e834eae90c..6a51d3abd797 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -78,10 +78,6 @@ EXPORT_SYMBOL_GPL(inet_peer_base_init);
 
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
-/* Exported for sysctl_net_ipv4.  */
-int inet_peer_threshold __read_mostly = 65536 + 128;	/* start to throw entries more
-					 * aggressively at this stage */
-
 static void inetpeer_gc_worker(struct work_struct *work)
 {
 	struct inet_peer *p, *n, *c;
@@ -141,11 +137,11 @@ void __init inet_initpeers(void)
 	 * myself.  --SAW
 	 */
 	if (si.totalram <= (32768*1024)/PAGE_SIZE)
-		inet_peer_threshold >>= 1; /* max pool size about 1MB on IA32 */
+		init_net.ipv4.sysctl_inet_peer_threshold >>= 1; /* max pool size about 1MB on IA32 */
 	if (si.totalram <= (16384*1024)/PAGE_SIZE)
-		inet_peer_threshold >>= 1; /* about 512KB */
+		init_net.ipv4.sysctl_inet_peer_threshold >>= 1; /* about 512KB */
 	if (si.totalram <= (8192*1024)/PAGE_SIZE)
-		inet_peer_threshold >>= 2; /* about 128KB */
+		init_net.ipv4.sysctl_inet_peer_threshold >>= 2; /* about 128KB */
 
 	peer_cachep = kmem_cache_create("inet_peer_cache",
 			sizeof(struct inet_peer),
@@ -369,6 +365,7 @@ static int inet_peer_gc(struct inet_peer_base *base,
 	struct inet_peer *p, *gchead = NULL;
 	int inet_peer_maxttl = base->net->ipv4.sysctl_inet_peer_maxttl;
 	int inet_peer_minttl = base->net->ipv4.sysctl_inet_peer_minttl;
+	int inet_peer_threshold = base->net->ipv4.sysctl_inet_peer_threshold;
 	__u32 delta, ttl;
 	int cnt = 0;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 9b55ca56b99f..36d206209879 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -345,13 +345,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "inet_peer_threshold",
-		.data		= &inet_peer_threshold,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_fack",
 		.data		= &sysctl_tcp_fack,
 		.maxlen		= sizeof(int),
@@ -737,6 +730,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
+		.procname	= "inet_peer_threshold",
+		.data		= &init_net.ipv4.sysctl_inet_peer_threshold,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "ip_early_demux",
 		.data		= &init_net.ipv4.sysctl_ip_early_demux,
 		.maxlen		= sizeof(int),
@@ -993,7 +993,8 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	net->ipv4.sysctl_ip_early_demux = 1;
 	net->ipv4.sysctl_inet_peer_maxttl = 10 * 60 * HZ;  /* usual time to live: 10 min */
 	net->ipv4.sysctl_inet_peer_minttl = 120 * HZ;      /* TTL under high load: 120 sec */
-
+	net->ipv4.sysctl_inet_peer_threshold = 65536 + 128;/* start to throw entries more
+							    * aggressively at this stage */
 	return 0;
 
 err_ports:
-- 
2.5.0
