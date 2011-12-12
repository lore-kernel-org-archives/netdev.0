From: Vincent Bernat <bernat@luffy.cx>
Subject: [PATCH] net: add ip_nonlocal_bind sysctl for IPv6
Date: Mon, 12 Dec 2011 14:18:43 +0100
Message-ID: <1323695923-23849-2-git-send-email-bernat@luffy.cx>
References: <1323695923-23849-1-git-send-email-bernat@luffy.cx>
Cc: davem@davemloft.net, Vincent Bernat <bernat@luffy.cx>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:44151 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753019Ab1LLN1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 08:27:46 -0500
In-Reply-To: <1323695923-23849-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net.ipv4.ip_nonlocal_bind sysctl allows applications to bind to non
local IPv4 addresses (for example, dynamic addresses that do not exist
yet). This modification introduces net.ipv6.ip_nonlocal_bind which has
the same effect for IPv6.

Signed-off-by: Vincent Bernat <bernat@luffy.cx>
---
 Documentation/networking/ip-sysctl.txt |    5 +++++
 include/net/ipv6.h                     |    1 +
 net/ipv6/af_inet6.c                    |    6 +++++-
 net/ipv6/sysctl_net_ipv6.c             |    7 +++++++
 4 files changed, 18 insertions(+), 1 deletions(-)

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
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e4170a2..393ea35 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -113,6 +113,7 @@ struct frag_hdr {
 
 /* sysctls */
 extern int sysctl_mld_max_msf;
+extern int sysctl_ip6_nonlocal_bind;
 extern struct ctl_path net_ipv6_ctl_path[];
 
 #define _DEVINC(net, statname, modifier, idev, field)			\
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7694c82..1d1ab9b 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -252,6 +252,9 @@ out_rcu_unlock:
 	goto out;
 }
 
+/* It is off by default, see below. */
+int sysctl_ip6_nonlocal_bind __read_mostly;
+EXPORT_SYMBOL(sysctl_ip6_nonlocal_bind);
 
 /* bind for INET6 API */
 int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
@@ -347,7 +350,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			 */
 			v4addr = LOOPBACK4_IPV6;
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
-				if (!(inet->freebind || inet->transparent) &&
+				if (!sysctl_ip6_nonlocal_bind &&
+				    !(inet->freebind || inet->transparent) &&
 				    !ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
 					err = -EADDRNOTAVAIL;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 166a57c..e88e09e 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -48,6 +48,13 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "ip_nonlocal_bind",
+		.data		= &sysctl_ip6_nonlocal_bind,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
-- 
1.7.7.3
