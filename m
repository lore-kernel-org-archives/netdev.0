From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 7/9][NETNS][IPV6] make mld_max_msf per namespace
Date: Wed, 02 Jan 2008 13:25:55 +0100
Message-ID: <20080102122827.779444823@localhost.localdomain>
References: <20080102122548.629622062@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:51899 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286AbYABMgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 07:36:35 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m02CaYTY456176
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 12:36:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m02CaY7m4997172
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 12:36:34 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m02CaVHG025700
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 12:36:31 GMT
Content-Disposition: inline; filename=move-mld_max_msf-to-netns.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mld_max_msf variable is moved to the network namespace structure.
A helper function has been added to initialize the variable.

Because the ipv6 protocol is not yet per namespace, the variable is
accessed relatively from the initial network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h         |    3 ---
 include/net/netns/ipv6.h   |    1 +
 net/ipv6/ipv6_sockglue.c   |    3 +--
 net/ipv6/mcast.c           |    9 ++++++---
 net/ipv6/sysctl_net_ipv6.c |    5 ++++-
 5 files changed, 12 insertions(+), 9 deletions(-)

Index: net-2.6.25/include/net/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/ipv6.h
+++ net-2.6.25/include/net/ipv6.h
@@ -108,9 +108,6 @@ struct frag_hdr {
 
 #include <net/sock.h>
 
-/* sysctls */
-extern int sysctl_mld_max_msf;
-
 #define _DEVINC(statname, modifier, idev, field)			\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
Index: net-2.6.25/include/net/netns/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/netns/ipv6.h
+++ net-2.6.25/include/net/netns/ipv6.h
@@ -13,6 +13,7 @@ struct netns_sysctl_ipv6 {
 	struct ctl_table_header *table;
    	struct inet_frags_ctl frags;
  	int bindv6only;
+ 	int mld_max_msf;
 };
 
 struct netns_ipv6 {
Index: net-2.6.25/net/ipv6/ipv6_sockglue.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ipv6_sockglue.c
+++ net-2.6.25/net/ipv6/ipv6_sockglue.c
@@ -656,7 +656,6 @@ done:
 	}
 	case MCAST_MSFILTER:
 	{
-		extern int sysctl_mld_max_msf;
 		struct group_filter *gsf;
 
 		if (optlen < GROUP_FILTER_SIZE(0))
@@ -677,7 +676,7 @@ done:
 		}
 		/* numsrc >= (4G-140)/128 overflow in 32 bits */
 		if (gsf->gf_numsrc >= 0x1ffffffU ||
-		    gsf->gf_numsrc > sysctl_mld_max_msf) {
+		    gsf->gf_numsrc > init_net.ipv6.sysctl.mld_max_msf) {
 			kfree(gsf);
 			retv = -ENOBUFS;
 			break;
Index: net-2.6.25/net/ipv6/mcast.c
===================================================================
--- net-2.6.25.orig/net/ipv6/mcast.c
+++ net-2.6.25/net/ipv6/mcast.c
@@ -172,8 +172,6 @@ static int ip6_mc_leave_src(struct sock 
 
 #define IPV6_MLD_MAX_MSF	64
 
-int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
-
 /*
  *	socket join on multicast group
  */
@@ -441,7 +439,7 @@ int ip6_mc_source(int add, int omode, st
 	}
 	/* else, add a new source to the filter */
 
-	if (psl && psl->sl_count >= sysctl_mld_max_msf) {
+	if (psl && psl->sl_count >= init_net.ipv6.sysctl.mld_max_msf) {
 		err = -ENOBUFS;
 		goto done;
 	}
@@ -2597,6 +2595,11 @@ static const struct file_operations igmp
 };
 #endif
 
+void igmp6_sysctl_init(struct net *net)
+{
+	net->ipv6.sysctl.mld_max_msf = IPV6_MLD_MAX_MSF;
+}
+
 int __init igmp6_init(struct net_proto_family *ops)
 {
 	struct ipv6_pinfo *np;
Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -17,6 +17,7 @@
 extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
 extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
 extern void ipv6_frag_sysctl_init(struct net *net);
+extern void igmp6_sysctl_init(struct net *net);
 
 static ctl_table ipv6_table_template[] = {
 	{
@@ -78,7 +79,7 @@ static ctl_table ipv6_table_template[] =
 	{
 		.ctl_name	= NET_IPV6_MLD_MAX_MSF,
 		.procname	= "mld_max_msf",
-		.data		= &sysctl_mld_max_msf,
+		.data		= &init_net.ipv6.sysctl.mld_max_msf,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
@@ -121,8 +122,10 @@ static int ipv6_sysctl_net_init(struct n
     	ipv6_table[4].data = &net->ipv6.sysctl.frags.low_thresh;
     	ipv6_table[5].data = &net->ipv6.sysctl.frags.timeout;
   	ipv6_table[6].data = &net->ipv6.sysctl.frags.secret_interval;
+   	ipv6_table[7].data = &net->ipv6.sysctl.mld_max_msf;
 
 	ipv6_frag_sysctl_init(net);
+	igmp6_sysctl_init(net);
 
 	net->ipv6.sysctl.bindv6only = 0;
 

-- 
