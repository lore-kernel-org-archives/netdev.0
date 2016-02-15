From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 4/6] ipv4: namespacify ip_early_demux sysctl knob
Date: Mon, 15 Feb 2016 12:11:30 +0200
Message-ID: <1455531092-23184-5-git-send-email-kernel@kyup.com>
References: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Cc: netfilter-devel@vger.kernel.org, ebiederm@xmission.com,
	pabeni@redhat.com, jmorris@namei.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34270 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbcBOKLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 05:11:40 -0500
Received: by mail-wm0-f45.google.com with SMTP id b205so60594406wmb.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 02:11:40 -0800 (PST)
In-Reply-To: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/ip.h           |  3 ---
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/ip_input.c        |  5 +----
 net/ipv4/sysctl_net_ipv4.c | 15 ++++++++-------
 net/ipv6/ip6_input.c       |  2 +-
 5 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index e3fb25d76421..cbb134b2f0e4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -245,9 +245,6 @@ extern int inet_peer_threshold;
 extern int inet_peer_minttl;
 extern int inet_peer_maxttl;
 
-/* From ip_input.c */
-extern int sysctl_ip_early_demux;
-
 void ipfrag_init(void);
 
 void ip_static_sysctl_init(void);
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index b7e3fb2587da..a69cde3ce460 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -86,6 +86,7 @@ struct netns_ipv4 {
 	int sysctl_ip_nonlocal_bind;
 	/* Shall we try to damage output packets if routing dev changes? */
 	int sysctl_ip_dynaddr;
+	int sysctl_ip_early_demux;
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 852002f64c68..e3d782746d9d 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -308,15 +308,12 @@ drop:
 	return true;
 }
 
-int sysctl_ip_early_demux __read_mostly = 1;
-EXPORT_SYMBOL(sysctl_ip_early_demux);
-
 static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 
-	if (sysctl_ip_early_demux &&
+	if (net->ipv4.sysctl_ip_early_demux &&
 	    !skb_dst(skb) &&
 	    !skb->sk &&
 	    !ip_is_fragment(iph)) {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 04ac5b763385..1e1fe6086dd9 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -297,13 +297,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "ip_early_demux",
-		.data		= &sysctl_ip_early_demux,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_fastopen",
 		.data		= &sysctl_tcp_fastopen,
 		.maxlen		= sizeof(int),
@@ -744,6 +737,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "ip_early_demux",
+		.data		= &init_net.ipv4.sysctl_ip_early_demux,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "ip_default_ttl",
 		.data		= &init_net.ipv4.sysctl_ip_default_ttl,
 		.maxlen		= sizeof(int),
@@ -990,6 +990,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 
 	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
 	net->ipv4.sysctl_ip_dynaddr = 0;
+	net->ipv4.sysctl_ip_early_demux = 1;
 
 	return 0;
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 31ac3c56da4b..c05c425c2389 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -49,7 +49,7 @@
 
 int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	if (sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
+	if (net->ipv4.sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
 		const struct inet6_protocol *ipprot;
 
 		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);
-- 
2.5.0
