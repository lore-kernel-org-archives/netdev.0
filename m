From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25 07/10][NETNS][IPV6] make ip6_frags per namespace
Date: Wed, 09 Jan 2008 17:45:40 +0100
Message-ID: <20080109165033.080905501@localhost.localdomain>
References: <20080109164533.695191040@localhost.localdomain>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:57451 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbYAIRAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 12:00:33 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m09H0VdW607214
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:00:31 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09H0VfH4694156
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:00:31 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09H0Fls018338
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:00:15 GMT
Content-Disposition: inline; filename=sysctl/move-ip6-frags-to-netns.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip6_frags is moved to the network namespace structure.
Because there can be multiple instances of the network namespaces,
and the ip6_frags is no longer a global static variable, a helper
function has been added to facilitate the initialization of the
variables.

Until the ipv6 protocol is not per namespace, the variables are
accessed relatively from the initial network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h         |    3 ---
 include/net/netns/ipv6.h   |    3 +++
 net/ipv6/af_inet6.c        |    8 ++++++++
 net/ipv6/reassembly.c      |   16 +++++++---------
 net/ipv6/sysctl_net_ipv6.c |   12 ++++++++----
 5 files changed, 26 insertions(+), 16 deletions(-)

Index: net-2.6.25/include/net/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/ipv6.h
+++ net-2.6.25/include/net/ipv6.h
@@ -572,9 +572,6 @@ extern int inet6_hash_connect(struct ine
 /*
  * reassembly.c
  */
-struct inet_frags_ctl;
-extern struct inet_frags_ctl ip6_frags_ctl;
-
 extern const struct proto_ops inet6_stream_ops;
 extern const struct proto_ops inet6_dgram_ops;
 
Index: net-2.6.25/include/net/netns/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/netns/ipv6.h
+++ net-2.6.25/include/net/netns/ipv6.h
@@ -2,6 +2,8 @@
  * ipv6 in net namespaces
  */
 
+#include <net/inet_frag.h>
+
 #ifndef __NETNS_IPV6_H__
 #define __NETNS_IPV6_H__
 
@@ -11,6 +13,7 @@ struct netns_sysctl_ipv6 {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header *table;
 #endif
+	struct inet_frags_ctl frags;
 	int bindv6only;
 };
 
Index: net-2.6.25/net/ipv6/reassembly.c
===================================================================
--- net-2.6.25.orig/net/ipv6/reassembly.c
+++ net-2.6.25/net/ipv6/reassembly.c
@@ -82,13 +82,6 @@ struct frag_queue
 	__u16			nhoffset;
 };
 
-struct inet_frags_ctl ip6_frags_ctl __read_mostly = {
-	.high_thresh 	 = 256 * 1024,
-	.low_thresh	 = 192 * 1024,
-	.timeout	 = IPV6_FRAG_TIMEOUT,
-	.secret_interval = 10 * 60 * HZ,
-};
-
 static struct inet_frags ip6_frags;
 
 int ip6_frag_nqueues(void)
@@ -605,7 +598,7 @@ static int ipv6_frag_rcv(struct sk_buff 
 		return 1;
 	}
 
-	if (atomic_read(&ip6_frags.mem) > ip6_frags_ctl.high_thresh)
+	if (atomic_read(&ip6_frags.mem) > init_net.ipv6.sysctl.frags.high_thresh)
 		ip6_evictor(ip6_dst_idev(skb->dst));
 
 	if ((fq = fq_find(fhdr->identification, &hdr->saddr, &hdr->daddr,
@@ -632,6 +625,11 @@ static struct inet6_protocol frag_protoc
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
+void ipv6_frag_sysctl_init(struct net *net)
+{
+	ip6_frags.ctl = &net->ipv6.sysctl.frags;
+}
+
 int __init ipv6_frag_init(void)
 {
 	int ret;
@@ -639,7 +637,7 @@ int __init ipv6_frag_init(void)
 	ret = inet6_add_protocol(&frag_protocol, IPPROTO_FRAGMENT);
 	if (ret)
 		goto out;
-	ip6_frags.ctl = &ip6_frags_ctl;
+
 	ip6_frags.hashfn = ip6_hashfn;
 	ip6_frags.constructor = ip6_frag_init;
 	ip6_frags.destructor = NULL;
Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -43,7 +43,7 @@ static ctl_table ipv6_table_template[] =
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_HIGH_THRESH,
 		.procname	= "ip6frag_high_thresh",
-		.data		= &ip6_frags_ctl.high_thresh,
+		.data		= &init_net.ipv6.sysctl.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
@@ -51,7 +51,7 @@ static ctl_table ipv6_table_template[] =
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_LOW_THRESH,
 		.procname	= "ip6frag_low_thresh",
-		.data		= &ip6_frags_ctl.low_thresh,
+		.data		= &init_net.ipv6.sysctl.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
@@ -59,7 +59,7 @@ static ctl_table ipv6_table_template[] =
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_TIME,
 		.procname	= "ip6frag_time",
-		.data		= &ip6_frags_ctl.timeout,
+		.data		= &init_net.ipv6.sysctl.frags.timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_jiffies,
@@ -68,7 +68,7 @@ static ctl_table ipv6_table_template[] =
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_SECRET_INTERVAL,
 		.procname	= "ip6frag_secret_interval",
-		.data		= &ip6_frags_ctl.secret_interval,
+		.data		= &init_net.ipv6.sysctl.frags.secret_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_jiffies,
@@ -117,6 +117,10 @@ static int ipv6_sysctl_net_init(struct n
      	ipv6_table[1].child = ipv6_icmp_table;
 
 	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;
+      	ipv6_table[3].data = &net->ipv6.sysctl.frags.high_thresh;
+      	ipv6_table[4].data = &net->ipv6.sysctl.frags.low_thresh;
+      	ipv6_table[5].data = &net->ipv6.sysctl.frags.timeout;
+    	ipv6_table[6].data = &net->ipv6.sysctl.frags.secret_interval;
 
 	net->ipv6.sysctl.table = register_net_sysctl_table(net, net_ipv6_ctl_path,
 							   ipv6_table);
Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -72,6 +72,8 @@ MODULE_LICENSE("GPL");
 static struct list_head inetsw6[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw6_lock);
 
+void ipv6_frag_sysctl_init(struct net *net);
+
 static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
 	const int offset = sk->sk_prot->obj_size - sizeof(struct ipv6_pinfo);
@@ -720,6 +722,12 @@ static void cleanup_ipv6_mibs(void)
 static int inet6_net_init(struct net *net)
 {
 	net->ipv6.sysctl.bindv6only = 0;
+	net->ipv6.sysctl.frags.high_thresh = 256 * 1024;
+	net->ipv6.sysctl.frags.low_thresh = 192 * 1024;
+	net->ipv6.sysctl.frags.timeout = IPV6_FRAG_TIMEOUT;
+	net->ipv6.sysctl.frags.secret_interval = 10 * 60 * HZ;
+	ipv6_frag_sysctl_init(net);
+
 	return 0;
 }
 

-- 
