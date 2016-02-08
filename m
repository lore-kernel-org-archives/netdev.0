From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 1/4] igmp: Namespaceify igmp_max_memberships sysctl knob
Date: Mon,  8 Feb 2016 23:29:21 +0200
Message-ID: <1454966964-13559-2-git-send-email-kernel@kyup.com>
References: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, edumazet@google.com,
	pdowney@brocade.com, dsa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35913 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932205AbcBHV3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 16:29:31 -0500
Received: by mail-wm0-f45.google.com with SMTP id p63so132759079wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 13:29:29 -0800 (PST)
In-Reply-To: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/linux/igmp.h       |  1 -
 include/net/netns/ipv4.h   |  2 ++
 net/ipv4/igmp.c            |  4 +---
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  2 ++
 5 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 9c9de11549a7..57d6d06ce0b3 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -38,7 +38,6 @@ static inline struct igmpv3_query *
 }
 
 extern int sysctl_igmp_llm_reports;
-extern int sysctl_igmp_max_memberships;
 extern int sysctl_igmp_max_msf;
 extern int sysctl_igmp_qrv;
 
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 4d6ec3f6fafe..759cf624eec2 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -108,6 +108,8 @@ struct netns_ipv4 {
 	int sysctl_tcp_fin_timeout;
 	unsigned int sysctl_tcp_notsent_lowat;
 
+	int sysctl_igmp_max_memberships;
+
 	struct ping_group_range ping_group_range;
 
 	atomic_t dev_addr_genid;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 05e4cba14162..5b86257c9d6b 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -107,7 +107,6 @@
 #include <linux/seq_file.h>
 #endif
 
-#define IP_MAX_MEMBERSHIPS	20
 #define IP_MAX_MSF		10
 
 /* IGMP reports for link-local multicast groups are enabled by default */
@@ -1727,7 +1726,6 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 /*
  *	Join a socket to a group
  */
-int sysctl_igmp_max_memberships __read_mostly = IP_MAX_MEMBERSHIPS;
 int sysctl_igmp_max_msf __read_mostly = IP_MAX_MSF;
 #ifdef CONFIG_IP_MULTICAST
 int sysctl_igmp_qrv __read_mostly = IGMP_QUERY_ROBUSTNESS_VARIABLE;
@@ -2074,7 +2072,7 @@ int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
 		count++;
 	}
 	err = -ENOBUFS;
-	if (count >= sysctl_igmp_max_memberships)
+	if (count >= net->ipv4.sysctl_igmp_max_memberships)
 		goto done;
 	iml = sock_kmalloc(sk, sizeof(*iml), GFP_KERNEL);
 	if (!iml)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 44bb59824267..6ea3dbb96db4 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -368,13 +368,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "igmp_max_memberships",
-		.data		= &sysctl_igmp_max_memberships,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "igmp_max_msf",
 		.data		= &sysctl_igmp_max_msf,
 		.maxlen		= sizeof(int),
@@ -872,6 +865,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "igmp_max_memberships",
+		.data		= &init_net.ipv4.sysctl_igmp_max_memberships,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "tcp_keepalive_time",
 		.data		= &init_net.ipv4.sysctl_tcp_keepalive_time,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0d381fa164f8..3e984d44295d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2397,6 +2397,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_fin_timeout = TCP_FIN_TIMEOUT;
 	net->ipv4.sysctl_tcp_notsent_lowat = UINT_MAX;
 
+	net->ipv4.sysctl_igmp_max_memberships = 20;
+
 	return 0;
 fail:
 	tcp_sk_exit(net);
-- 
2.5.0
