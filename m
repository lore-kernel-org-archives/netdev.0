From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 3/4] inetpeer: Namespacify inet_peer_minttl sysctl knob
Date: Wed, 17 Feb 2016 12:09:57 +0200
Message-ID: <1455703798-15258-4-git-send-email-kernel@kyup.com>
References: <1455703798-15258-1-git-send-email-kernel@kyup.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35070 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933891AbcBQKKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:10:05 -0500
Received: by mail-wm0-f48.google.com with SMTP id c200so204869283wme.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 02:10:04 -0800 (PST)
In-Reply-To: <1455703798-15258-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/ip.h           |  1 -
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/inetpeer.c        |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 15 ++++++++-------
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index c33d53176d3c..11a20a3e60c6 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -242,7 +242,6 @@ static inline int inet_is_local_reserved_port(struct net *net, int port)
 
 /* From inetpeer.c */
 extern int inet_peer_threshold;
-extern int inet_peer_minttl;
 
 void ipfrag_init(void);
 
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index b0623c4e2f0a..1bc51c22ef42 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -89,6 +89,7 @@ struct netns_ipv4 {
 	int sysctl_ip_early_demux;
 
 	int sysctl_inet_peer_maxttl;
+	int sysctl_inet_peer_minttl;
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index a9245ada56c2..97e834eae90c 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -81,7 +81,6 @@ EXPORT_SYMBOL_GPL(inet_peer_base_init);
 /* Exported for sysctl_net_ipv4.  */
 int inet_peer_threshold __read_mostly = 65536 + 128;	/* start to throw entries more
 					 * aggressively at this stage */
-int inet_peer_minttl __read_mostly = 120 * HZ;	/* TTL under high load: 120 sec */
 
 static void inetpeer_gc_worker(struct work_struct *work)
 {
@@ -369,6 +368,7 @@ static int inet_peer_gc(struct inet_peer_base *base,
 {
 	struct inet_peer *p, *gchead = NULL;
 	int inet_peer_maxttl = base->net->ipv4.sysctl_inet_peer_maxttl;
+	int inet_peer_minttl = base->net->ipv4.sysctl_inet_peer_minttl;
 	__u32 delta, ttl;
 	int cnt = 0;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2aaa049cbf9d..9b55ca56b99f 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -352,13 +352,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "inet_peer_minttl",
-		.data		= &inet_peer_minttl,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
 		.procname	= "tcp_fack",
 		.data		= &sysctl_tcp_fack,
 		.maxlen		= sizeof(int),
@@ -737,6 +730,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
+		.procname	= "inet_peer_minttl",
+		.data		= &init_net.ipv4.sysctl_inet_peer_minttl,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
 		.procname	= "ip_early_demux",
 		.data		= &init_net.ipv4.sysctl_ip_early_demux,
 		.maxlen		= sizeof(int),
@@ -992,6 +992,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	net->ipv4.sysctl_ip_dynaddr = 0;
 	net->ipv4.sysctl_ip_early_demux = 1;
 	net->ipv4.sysctl_inet_peer_maxttl = 10 * 60 * HZ;  /* usual time to live: 10 min */
+	net->ipv4.sysctl_inet_peer_minttl = 120 * HZ;      /* TTL under high load: 120 sec */
 
 	return 0;
 
-- 
2.5.0
