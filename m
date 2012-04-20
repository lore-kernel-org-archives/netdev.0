From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 07/10] l2tp: netlink api for l2tpv3 ipv6 unmanaged tunnels
Date: Fri, 20 Apr 2012 10:02:50 +0100
Message-ID: <1334912573-28804-8-git-send-email-jchapman@katalix.com>
References: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Cc: bcrl@kvack.org, Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:56666 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786Ab2DTJDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 05:03:00 -0400
In-Reply-To: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Elston <celston@katalix.com>

This patch adds support for unmanaged L2TPv3 tunnels over IPv6 using
the netlink API. We already support unmanaged L2TPv3 tunnels over
IPv4. A patch to iproute2 to make use of this feature will be
submitted separately.

Signed-off-by: Chris Elston <celston@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 include/linux/l2tp.h    |    2 +
 net/l2tp/l2tp_core.c    |   78 ++++++++++++++++++++++++++++++++++++----------
 net/l2tp/l2tp_core.h    |    4 ++
 net/l2tp/l2tp_netlink.c |   48 ++++++++++++++++++++++++++--
 4 files changed, 111 insertions(+), 21 deletions(-)

diff --git a/include/linux/l2tp.h b/include/linux/l2tp.h
index e77d7f9..16b8347 100644
--- a/include/linux/l2tp.h
+++ b/include/linux/l2tp.h
@@ -108,6 +108,8 @@ enum {
 	L2TP_ATTR_MTU,			/* u16 */
 	L2TP_ATTR_MRU,			/* u16 */
 	L2TP_ATTR_STATS,		/* nested */
+	L2TP_ATTR_IP6_SADDR,		/* struct in6_addr */
+	L2TP_ATTR_IP6_DADDR,		/* struct in6_addr */
 	__L2TP_ATTR_MAX,
 };
 
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 5e27c05..5a7d908 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1365,31 +1365,68 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 {
 	int err = -EINVAL;
 	struct sockaddr_in udp_addr;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct sockaddr_in6 udp6_addr;
+#endif
 	struct sockaddr_l2tpip ip_addr;
 	struct socket *sock = NULL;
 
 	switch (cfg->encap) {
 	case L2TP_ENCAPTYPE_UDP:
-		err = sock_create(AF_INET, SOCK_DGRAM, 0, sockp);
-		if (err < 0)
-			goto out;
+#if IS_ENABLED(CONFIG_IPV6)
+		if (cfg->local_ip6 && cfg->peer_ip6) {
+			err = sock_create(AF_INET6, SOCK_DGRAM, 0, sockp);
+			if (err < 0)
+				goto out;
 
-		sock = *sockp;
+			sock = *sockp;
 
-		memset(&udp_addr, 0, sizeof(udp_addr));
-		udp_addr.sin_family = AF_INET;
-		udp_addr.sin_addr = cfg->local_ip;
-		udp_addr.sin_port = htons(cfg->local_udp_port);
-		err = kernel_bind(sock, (struct sockaddr *) &udp_addr, sizeof(udp_addr));
-		if (err < 0)
-			goto out;
+			memset(&udp6_addr, 0, sizeof(udp6_addr));
+			udp6_addr.sin6_family = AF_INET6;
+			memcpy(&udp6_addr.sin6_addr, cfg->local_ip6,
+			       sizeof(udp6_addr.sin6_addr));
+			udp6_addr.sin6_port = htons(cfg->local_udp_port);
+			err = kernel_bind(sock, (struct sockaddr *) &udp6_addr,
+					  sizeof(udp6_addr));
+			if (err < 0)
+				goto out;
 
-		udp_addr.sin_family = AF_INET;
-		udp_addr.sin_addr = cfg->peer_ip;
-		udp_addr.sin_port = htons(cfg->peer_udp_port);
-		err = kernel_connect(sock, (struct sockaddr *) &udp_addr, sizeof(udp_addr), 0);
-		if (err < 0)
-			goto out;
+			udp6_addr.sin6_family = AF_INET6;
+			memcpy(&udp6_addr.sin6_addr, cfg->peer_ip6,
+			       sizeof(udp6_addr.sin6_addr));
+			udp6_addr.sin6_port = htons(cfg->peer_udp_port);
+			err = kernel_connect(sock,
+					     (struct sockaddr *) &udp6_addr,
+					     sizeof(udp6_addr), 0);
+			if (err < 0)
+				goto out;
+		} else
+#endif
+		{
+			err = sock_create(AF_INET, SOCK_DGRAM, 0, sockp);
+			if (err < 0)
+				goto out;
+
+			sock = *sockp;
+
+			memset(&udp_addr, 0, sizeof(udp_addr));
+			udp_addr.sin_family = AF_INET;
+			udp_addr.sin_addr = cfg->local_ip;
+			udp_addr.sin_port = htons(cfg->local_udp_port);
+			err = kernel_bind(sock, (struct sockaddr *) &udp_addr,
+					  sizeof(udp_addr));
+			if (err < 0)
+				goto out;
+
+			udp_addr.sin_family = AF_INET;
+			udp_addr.sin_addr = cfg->peer_ip;
+			udp_addr.sin_port = htons(cfg->peer_udp_port);
+			err = kernel_connect(sock,
+					     (struct sockaddr *) &udp_addr,
+					     sizeof(udp_addr), 0);
+			if (err < 0)
+				goto out;
+		}
 
 		if (!cfg->use_udp_checksums)
 			sock->sk->sk_no_check = UDP_CSUM_NOXMIT;
@@ -1397,6 +1434,13 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 		break;
 
 	case L2TP_ENCAPTYPE_IP:
+#if IS_ENABLED(CONFIG_IPV6)
+		if (cfg->local_ip6 && cfg->peer_ip6) {
+			/* IP encap over IPv6 not yet supported */
+			err = -EPROTONOSUPPORT;
+			goto out;
+		}
+#endif
 		err = sock_create(AF_INET, SOCK_DGRAM, IPPROTO_L2TP, sockp);
 		if (err < 0)
 			goto out;
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a8c943b..0bf60fc 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -151,6 +151,10 @@ struct l2tp_tunnel_cfg {
 	/* Used only for kernel-created sockets */
 	struct in_addr		local_ip;
 	struct in_addr		peer_ip;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct in6_addr		*local_ip6;
+	struct in6_addr		*peer_ip6;
+#endif
 	u16			local_udp_port;
 	u16			peer_udp_port;
 	unsigned int		use_udp_checksums:1;
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 1dbb977..24edad0 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -133,10 +133,25 @@ static int l2tp_nl_cmd_tunnel_create(struct sk_buff *skb, struct genl_info *info
 	if (info->attrs[L2TP_ATTR_FD]) {
 		fd = nla_get_u32(info->attrs[L2TP_ATTR_FD]);
 	} else {
-		if (info->attrs[L2TP_ATTR_IP_SADDR])
-			cfg.local_ip.s_addr = nla_get_be32(info->attrs[L2TP_ATTR_IP_SADDR]);
-		if (info->attrs[L2TP_ATTR_IP_DADDR])
-			cfg.peer_ip.s_addr = nla_get_be32(info->attrs[L2TP_ATTR_IP_DADDR]);
+#if IS_ENABLED(CONFIG_IPV6)
+		if (info->attrs[L2TP_ATTR_IP6_SADDR] &&
+		    info->attrs[L2TP_ATTR_IP6_DADDR]) {
+			cfg.local_ip6 = nla_data(
+				info->attrs[L2TP_ATTR_IP6_SADDR]);
+			cfg.peer_ip6 = nla_data(
+				info->attrs[L2TP_ATTR_IP6_DADDR]);
+		} else
+#endif
+		if (info->attrs[L2TP_ATTR_IP_SADDR] &&
+		    info->attrs[L2TP_ATTR_IP_DADDR]) {
+			cfg.local_ip.s_addr = nla_get_be32(
+				info->attrs[L2TP_ATTR_IP_SADDR]);
+			cfg.peer_ip.s_addr = nla_get_be32(
+				info->attrs[L2TP_ATTR_IP_DADDR]);
+		} else {
+			ret = -EINVAL;
+			goto out;
+		}
 		if (info->attrs[L2TP_ATTR_UDP_SPORT])
 			cfg.local_udp_port = nla_get_u16(info->attrs[L2TP_ATTR_UDP_SPORT]);
 		if (info->attrs[L2TP_ATTR_UDP_DPORT])
@@ -225,6 +240,9 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 	struct nlattr *nest;
 	struct sock *sk = NULL;
 	struct inet_sock *inet;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct ipv6_pinfo *np = NULL;
+#endif
 	struct l2tp_stats stats;
 	unsigned int start;
 
@@ -273,6 +291,11 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 	if (!sk)
 		goto out;
 
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6)
+		np = inet6_sk(sk);
+#endif
+
 	inet = inet_sk(sk);
 
 	switch (tunnel->encap) {
@@ -284,6 +307,15 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 			goto nla_put_failure;
 		/* NOBREAK */
 	case L2TP_ENCAPTYPE_IP:
+#if IS_ENABLED(CONFIG_IPV6)
+		if (np) {
+			if (nla_put(skb, L2TP_ATTR_IP6_SADDR, sizeof(np->saddr),
+				    &np->saddr) ||
+			    nla_put(skb, L2TP_ATTR_IP6_DADDR, sizeof(np->daddr),
+				    &np->daddr))
+				goto nla_put_failure;
+		} else
+#endif
 		if (nla_put_be32(skb, L2TP_ATTR_IP_SADDR, inet->inet_saddr) ||
 		    nla_put_be32(skb, L2TP_ATTR_IP_DADDR, inet->inet_daddr))
 			goto nla_put_failure;
@@ -752,6 +784,14 @@ static struct nla_policy l2tp_nl_policy[L2TP_ATTR_MAX + 1] = {
 	[L2TP_ATTR_MTU]			= { .type = NLA_U16, },
 	[L2TP_ATTR_MRU]			= { .type = NLA_U16, },
 	[L2TP_ATTR_STATS]		= { .type = NLA_NESTED, },
+	[L2TP_ATTR_IP6_SADDR] = {
+		.type = NLA_BINARY,
+		.len = sizeof(struct in6_addr),
+	},
+	[L2TP_ATTR_IP6_DADDR] = {
+		.type = NLA_BINARY,
+		.len = sizeof(struct in6_addr),
+	},
 	[L2TP_ATTR_IFNAME] = {
 		.type = NLA_NUL_STRING,
 		.len = IFNAMSIZ - 1,
-- 
1.7.0.4
