From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] net/tcp: Fix tcp memory limits initialization when !CONFIG_SYSCTL
Date: Mon, 30 Jan 2012 15:20:17 +0400
Message-ID: <1327922417-9191-1-git-send-email-glommer@parallels.com>
Cc: netdev@vger.kernel.org, Glauber Costa <glommer@parallels.com>,
	Ingo Molnar <mingo@elte.hu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27683 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635Ab2A3LUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 06:20:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sysctl_tcp_mem() initialization was moved to sysctl_tcp_ipv4.c
in commit 3dc43e3e4d0b52197d3205214fe8f162f9e0c334, since it
became a per-ns value.

That code, however, will never run when CONFIG_SYSCTL is
disabled, leading to bogus values on those fields - causing hung
TCP sockets.

This patch fixes it by keeping an initialization code in
tcp_init(). It will be overwritten by the first net namespace
init if CONFIG_SYSCTL is compiled in, and do the right thing if
it is compiled out.

It is also named properly as tcp_init_mem(), to properly signal
its non-sysctl side effect on TCP limits.

Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: David S. Miller <davem@davemloft.net>
Link: http://lkml.kernel.org/r/4F22D05A.8030604@parallels.com
[ renamed the function, tidied up the changelog a bit ]
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 include/net/tcp.h          |    2 ++
 net/ipv4/sysctl_net_ipv4.c |    1 +
 net/ipv4/tcp.c             |   16 +++++++++++++---
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0118ea9..d49db01 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -311,6 +311,8 @@ extern struct proto tcp_prot;
 #define TCP_ADD_STATS_USER(net, field, val) SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val)
 #define TCP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.tcp_statistics, field, val)
 
+extern void tcp_init_mem(struct net *net);
+
 extern void tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void tcp_shutdown (struct sock *sk, int how);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 4aa7e9d..4cb9cd2 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -814,6 +814,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 
 	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
 
+	tcp_init_mem(net);
 	limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
 	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9bcdec3..06373b4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3216,6 +3216,16 @@ static int __init set_thash_entries(char *str)
 }
 __setup("thash_entries=", set_thash_entries);
 
+void tcp_init_mem(struct net *net)
+{
+	/* Set per-socket limits to no more than 1/128 the pressure threshold */
+	unsigned long limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
+	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
+	net->ipv4.sysctl_tcp_mem[1] = limit;
+	net->ipv4.sysctl_tcp_mem[2] = net->ipv4.sysctl_tcp_mem[0] * 2;
+}
+
 void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
@@ -3276,9 +3286,9 @@ void __init tcp_init(void)
 	sysctl_tcp_max_orphans = cnt / 2;
 	sysctl_max_syn_backlog = max(128, cnt / 256);
 
-	/* Set per-socket limits to no more than 1/128 the pressure threshold */
-	limit = ((unsigned long)init_net.ipv4.sysctl_tcp_mem[1])
-		<< (PAGE_SHIFT - 7);
+	tcp_init_mem(&init_net);
+	limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
 	max_share = min(4UL*1024*1024, limit);
 
 	sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
-- 
1.7.7.4
