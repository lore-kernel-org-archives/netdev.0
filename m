From: Michal Humpula <michal.humpula@web4u.cz>
Subject: [PATCH net-next-2.6] ipv6: adding ip_nonlocal_bind option from ipv4
Date: Sat, 3 Jul 2010 22:38:28 +0200
Message-ID: <201007032238.28344.michal.humpula@web4u.cz>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hudrydum.cz ([88.208.90.178]:41279 "EHLO hudrydum.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450Ab0GCUpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jul 2010 16:45:54 -0400
Received: from mekka.localnet (mekka.hudrydum.local [192.168.0.2])
	by hudrydum.cz (Postfix) with ESMTPSA id 81391368DB
	for <netdev@vger.kernel.org>; Sat,  3 Jul 2010 22:38:29 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds ability to bind non-local IPv6 address the same way as for IPv4

Signed-off-by: Michal Humpula <michal.humpula@web4u.cz>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f350c69..27fa09a 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -962,6 +962,10 @@ bindv6only - BOOLEAN
 		FALSE: enable IPv4-mapped address feature
 
 	Default: FALSE (as specified in RFC2553bis)
+ipv6_nonlocal_bind - BOOLEAN
+	If set, allows processes to bind() to non-local IPv6 addresses,
+	which can be quite useful - but may break some applications.
+	Default: 0
 
 IPv6 Fragmentation:
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 7bb5cb6..8957ead 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -528,6 +528,7 @@ enum {
 	NET_IPV6_IP6FRAG_TIME=23,
 	NET_IPV6_IP6FRAG_SECRET_INTERVAL=24,
 	NET_IPV6_MLD_MAX_MSF=25,
+	NET_IPV6_NONLOCAL_BIND=26
 };
 
 enum {
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 1f84124..f459fcb 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -641,6 +641,8 @@ static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
 #endif
 
 #ifdef CONFIG_SYSCTL
+extern int sysctl_ipv6_nonlocal_bind;
+
 extern ctl_table ipv6_route_table_template[];
 extern ctl_table ipv6_icmp_table_template[];
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 1357c57..525edae 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -559,6 +559,7 @@ static const struct bin_table bin_net_ipv6_table[] = {
 	{ CTL_DIR,	NET_IPV6_ROUTE,		"route",	bin_net_ipv6_route_table },
 	{ CTL_DIR,	NET_IPV6_ICMP,		"icmp",		bin_net_ipv6_icmp_table },
 	{ CTL_INT,	NET_IPV6_BINDV6ONLY,		"bindv6only" },
+	{ CTL_INT,	NET_IPV6_NONLOCAL_BIND,		"ipv6_nonlocal_bind" },
 	{ CTL_INT,	NET_IPV6_IP6FRAG_HIGH_THRESH,	"ip6frag_high_thresh" },
 	{ CTL_INT,	NET_IPV6_IP6FRAG_LOW_THRESH,	"ip6frag_low_thresh" },
 	{ CTL_INT,	NET_IPV6_IP6FRAG_TIME,		"ip6frag_time" },
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e830cd4..55b3552 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -252,6 +252,8 @@ out_rcu_unlock:
 	goto out;
 }
 
+int sysctl_ipv6_nonlocal_bind __read_mostly;
+EXPORT_SYMBOL(sysctl_ipv6_nonlocal_bind);
 
 /* bind for INET6 API */
 int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
@@ -345,8 +347,10 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
 				if (!ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
-					err = -EADDRNOTAVAIL;
-					goto out_unlock;
+					if (!sysctl_ipv6_nonlocal_bind) {
+						err = -EADDRNOTAVAIL;
+						goto out_unlock;
+					}
 				}
 			}
 			rcu_read_unlock();
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index fa1d8f4..56bfe76 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -35,6 +35,13 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname = "ipv6_nonlocal_bind",
+		.data   = &sysctl_ipv6_nonlocal_bind,
+		.maxlen   = sizeof(int),
+		.mode   = 0644,
+		.proc_handler = proc_dointvec
+	},
 	{ }
 };
 
