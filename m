From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ipv6: Nonlocal bind
Date: Wed, 8 Jul 2015 16:58:22 -0700
Message-ID: <1436399902-3049471-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35982 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752635AbbGHX6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:58:33 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t68NsTMp007867
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2015 16:58:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vhccf05w4-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 16:58:33 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 3c71d19225cd11e5b5b50002c991e86a-ca7db2b0 for <netdev@vger.kernel.org>;	Wed,
 08 Jul 2015 16:58:32 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to allow non-local binds similar to how this was done for IPv4.
Non-local binds are very useful in emulating the Internet in a box, etc.

This add the ip_nonlocal_bind sysctl under ipv6.

Testing:

Set up nonlocal binding and receive routing on a host, e.g.:

ip -6 rule add from ::/0 iif eth0 lookup 200
ip -6 route add local 2001:0:0:1::/64 dev lo proto kernel scope host table 200
sysctl -w net.ipv6.ip_nonlocal_bind=1

Set up routing to 2001:0:0:1::/64 on peer to go to first host

ping6 -I 2001:0:0:1::1 peer-address -- to verify

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 Documentation/networking/ip-sysctl.txt | 5 +++++
 include/net/netns/ipv6.h               | 1 +
 net/ipv4/ping.c                        | 3 ++-
 net/ipv6/af_inet6.c                    | 3 ++-
 net/ipv6/raw.c                         | 3 ++-
 net/ipv6/sysctl_net_ipv6.c             | 8 ++++++++
 6 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5fae770..f63aeef 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1435,6 +1435,11 @@ mtu - INTEGER
 	Default Maximum Transfer Unit
 	Default: 1280 (IPv6 required minimum)
 
+ip_nonlocal_bind - BOOLEAN
+	If set, allows processes to bind() to non-local IPv6 addresses,
+	which can be quite useful - but may break some applications.
+	Default: 0
+
 router_probe_interval - INTEGER
 	Minimum interval (in seconds) between Router Probing described
 	in RFC4191.
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 8d93544..c0368db 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -31,6 +31,7 @@ struct netns_sysctl_ipv6 {
 	int auto_flowlabels;
 	int icmpv6_time;
 	int anycast_src_echo_reply;
+	int ip_nonlocal_bind;
 	int fwmark_reflect;
 	int idgen_retries;
 	int idgen_delay;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 05ff44b..e89094a 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -363,7 +363,8 @@ static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 						    scoped);
 		rcu_read_unlock();
 
-		if (!(isk->freebind || isk->transparent || has_addr ||
+		if (!(net->ipv6.sysctl.ip_nonlocal_bind ||
+		      isk->freebind || isk->transparent || has_addr ||
 		      addr_type == IPV6_ADDR_ANY))
 			return -EADDRNOTAVAIL;
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7de52b6..60e1ece 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -342,7 +342,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			 */
 			v4addr = LOOPBACK4_IPV6;
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
-				if (!(inet->freebind || inet->transparent) &&
+				if (!net->ipv6.sysctl.ip_nonlocal_bind &&
+				    !(inet->freebind || inet->transparent) &&
 				    !ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
 					err = -EADDRNOTAVAIL;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ca4700c..fdbada156 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -295,7 +295,8 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		 * unspecified and mapped address have a v4 equivalent.
 		 */
 		v4addr = LOOPBACK4_IPV6;
-		if (!(addr_type & IPV6_ADDR_MULTICAST))	{
+		if (!(addr_type & IPV6_ADDR_MULTICAST) &&
+		    !sock_net(sk)->ipv6.sysctl.ip_nonlocal_bind) {
 			err = -EADDRNOTAVAIL;
 			if (!ipv6_chk_addr(sock_net(sk), &addr->sin6_addr,
 					   dev, 0)) {
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 4e705ad..db48aeb 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -75,6 +75,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "ip_nonlocal_bind",
+		.data		= &init_net.ipv6.sysctl.ip_nonlocal_bind,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -117,6 +124,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[5].data = &net->ipv6.sysctl.idgen_retries;
 	ipv6_table[6].data = &net->ipv6.sysctl.idgen_delay;
 	ipv6_table[7].data = &net->ipv6.sysctl.flowlabel_state_ranges;
+	ipv6_table[8].data = &net->ipv6.sysctl.ip_nonlocal_bind;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
1.8.1
