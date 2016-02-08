From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 2/4] igmp: Namespaceify igmp_max_msf sysctl knob
Date: Mon,  8 Feb 2016 23:29:22 +0200
Message-ID: <1454966964-13559-3-git-send-email-kernel@kyup.com>
References: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, edumazet@google.com,
	pdowney@brocade.com, dsa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35721 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbcBHV3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 16:29:32 -0500
Received: by mail-wm0-f53.google.com with SMTP id c200so34871574wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 13:29:31 -0800 (PST)
In-Reply-To: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/linux/igmp.h       |  1 -
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/igmp.c            |  5 +----
 net/ipv4/ip_sockglue.c     |  5 +++--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  1 +
 6 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 57d6d06ce0b3..a91ec9f575e7 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -38,7 +38,6 @@ static inline struct igmpv3_query *
 }
 
 extern int sysctl_igmp_llm_reports;
-extern int sysctl_igmp_max_msf;
 extern int sysctl_igmp_qrv;
 
 struct ip_sf_socklist {
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 759cf624eec2..522a2cfe1ad9 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -109,6 +109,7 @@ struct netns_ipv4 {
 	unsigned int sysctl_tcp_notsent_lowat;
 
 	int sysctl_igmp_max_memberships;
+	int sysctl_igmp_max_msf;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 5b86257c9d6b..6da2e467b63c 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -107,8 +107,6 @@
 #include <linux/seq_file.h>
 #endif
 
-#define IP_MAX_MSF		10
-
 /* IGMP reports for link-local multicast groups are enabled by default */
 int sysctl_igmp_llm_reports __read_mostly = 1;
 
@@ -1726,7 +1724,6 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 /*
  *	Join a socket to a group
  */
-int sysctl_igmp_max_msf __read_mostly = IP_MAX_MSF;
 #ifdef CONFIG_IP_MULTICAST
 int sysctl_igmp_qrv __read_mostly = IGMP_QUERY_ROBUSTNESS_VARIABLE;
 #endif
@@ -2244,7 +2241,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	}
 	/* else, add a new source to the filter */
 
-	if (psl && psl->sl_count >= sysctl_igmp_max_msf) {
+	if (psl && psl->sl_count >= net->ipv4.sysctl_igmp_max_msf) {
 		err = -ENOBUFS;
 		goto done;
 	}
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5f73a7c03e27..92808f147ef5 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -571,6 +571,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			    int optname, char __user *optval, unsigned int optlen)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	int val = 0, err;
 	bool needs_rtnl = setsockopt_needs_rtnl(optname);
 
@@ -910,7 +911,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 		/* numsrc >= (1G-4) overflow in 32 bits */
 		if (msf->imsf_numsrc >= 0x3ffffffcU ||
-		    msf->imsf_numsrc > sysctl_igmp_max_msf) {
+		    msf->imsf_numsrc > net->ipv4.sysctl_igmp_max_msf) {
 			kfree(msf);
 			err = -ENOBUFS;
 			break;
@@ -1065,7 +1066,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 
 		/* numsrc >= (4G-140)/128 overflow in 32 bits */
 		if (gsf->gf_numsrc >= 0x1ffffff ||
-		    gsf->gf_numsrc > sysctl_igmp_max_msf) {
+		    gsf->gf_numsrc > net->ipv4.sysctl_igmp_max_msf) {
 			err = -ENOBUFS;
 			goto mc_msf_out;
 		}
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 6ea3dbb96db4..225659a02cf2 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -367,13 +367,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "igmp_max_msf",
-		.data		= &sysctl_igmp_max_msf,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 #ifdef CONFIG_IP_MULTICAST
 	{
 		.procname	= "igmp_qrv",
@@ -872,6 +865,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "igmp_max_msf",
+		.data		= &init_net.ipv4.sysctl_igmp_max_msf,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "tcp_keepalive_time",
 		.data		= &init_net.ipv4.sysctl_tcp_keepalive_time,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3e984d44295d..d0ac43b95378 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2398,6 +2398,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_notsent_lowat = UINT_MAX;
 
 	net->ipv4.sysctl_igmp_max_memberships = 20;
+	net->ipv4.sysctl_igmp_max_msf = 10;
 
 	return 0;
 fail:
-- 
2.5.0
