From: Vincent Bernat <bernat@luffy.cx>
Subject: [PATCH 1/2] net/ipv6: add ip_nonlocal_bind sysctl for IPv6
Date: Wed, 14 Dec 2011 17:20:47 +0100
Message-ID: <1323879648-419-2-git-send-email-bernat@luffy.cx>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	Vincent Bernat <bernat@luffy.cx>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:39851 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756798Ab1LNQVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 11:21:04 -0500
In-Reply-To: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net.ipv4.ip_nonlocal_bind sysctl allows applications to bind to non
local IPv4 addresses (for example, dynamic addresses that do not exist
yet). This modification introduces net.ipv6.ip_nonlocal_bind which has
the same effect for IPv6.

However, contrary to net.ipv4.ip_nonlocal_bind, this settings is bound
to the current namespace.

Signed-off-by: Vincent Bernat <bernat@luffy.cx>
---
 Documentation/networking/ip-sysctl.txt |    5 +++++
 include/net/netns/ipv6.h               |    1 +
 net/ipv6/af_inet6.c                    |    4 +++-
 net/ipv6/sysctl_net_ipv6.c             |    8 ++++++++
 4 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ad3e80e..be8a80e 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1007,6 +1007,11 @@ bindv6only - BOOLEAN
 
 	Default: FALSE (as specified in RFC3493)
 
+ip_nonlocal_bind - BOOLEAN
+	If set, allows processes to bind() to non-local IP addresses,
+	which can be quite useful - but may break some applications.
+	Default: FALSE
+
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 81abfcb..f9326cc 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -16,6 +16,7 @@ struct netns_sysctl_ipv6 {
 	struct ctl_table_header *frags_hdr;
 #endif
 	int bindv6only;
+	int ip6_nonlocal_bind;
 	int flush_delay;
 	int ip6_rt_max_size;
 	int ip6_rt_gc_min_interval;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 273f48d..27c32f387 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -347,7 +347,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			 */
 			v4addr = LOOPBACK4_IPV6;
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
-				if (!(inet->freebind || inet->transparent) &&
+				if (!net->ipv6.sysctl.ip6_nonlocal_bind &&
+				    !(inet->freebind || inet->transparent) &&
 				    !ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
 					err = -EADDRNOTAVAIL;
@@ -1017,6 +1018,7 @@ static int __net_init inet6_net_init(struct net *net)
 	int err = 0;
 
 	net->ipv6.sysctl.bindv6only = 0;
+	net->ipv6.sysctl.ip6_nonlocal_bind = 0;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 
 	err = ipv6_init_mibs(net);
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 166a57c..42f0cf0 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -48,6 +48,13 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "ip_nonlocal_bind",
+		.data		= &init_net.ipv6.sysctl.ip6_nonlocal_bind,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -93,6 +100,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[1].child = ipv6_icmp_table;
 
 	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;
+	ipv6_table[3].data = &net->ipv6.sysctl.ip6_nonlocal_bind;
 
 	net->ipv6.sysctl.table = register_net_sysctl_table(net, net_ipv6_ctl_path,
 							   ipv6_table);
-- 
1.7.7.3
