From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 3/4] tipc: safely copy UDP netlink data from user
Date: Thu, 3 Mar 2016 14:20:42 +0100
Message-ID: <1457011243-23605-3-git-send-email-richard.alpe@ericsson.com>
References: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:54963 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbcCCNUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 08:20:53 -0500
In-Reply-To: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink policy for TIPC_NLA_UDP_LOCAL and TIPC_NLA_UDP_REMOTE
is of type binary with a defined length. This causes the policy
framework to threat the defined length as maximum length.

There is however no protection against a user sending a smaller
amount of data. Prior to this patch this wasn't handled which could
result in a partially incomplete sockaddr_storage struct containing
uninitialized data.

In this patch we use nla_memcpy() when copying the user data. This
ensures a potential gap at the end is cleared out properly.

This was found by Julia with Coccinelle tool.

Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@gmail.com>
---
 net/tipc/udp_media.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index f22a5bb1..6fe8740 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -276,7 +276,7 @@ static int parse_options(struct nlattr *attrs[], struct udp_bearer *ub,
 			 struct udp_media_addr *remote)
 {
 	struct nlattr *opts[TIPC_NLA_UDP_MAX + 1];
-	struct sockaddr_storage *sa_local, *sa_remote;
+	struct sockaddr_storage sa_local, sa_remote;
 
 	if (!attrs[TIPC_NLA_BEARER_UDP_OPTS])
 		goto err;
@@ -285,41 +285,43 @@ static int parse_options(struct nlattr *attrs[], struct udp_bearer *ub,
 			     tipc_nl_udp_policy))
 		goto err;
 	if (opts[TIPC_NLA_UDP_LOCAL] && opts[TIPC_NLA_UDP_REMOTE]) {
-		sa_local = nla_data(opts[TIPC_NLA_UDP_LOCAL]);
-		sa_remote = nla_data(opts[TIPC_NLA_UDP_REMOTE]);
+		nla_memcpy(&sa_local, opts[TIPC_NLA_UDP_LOCAL],
+			   sizeof(sa_local));
+		nla_memcpy(&sa_remote, opts[TIPC_NLA_UDP_REMOTE],
+			   sizeof(sa_remote));
 	} else {
 err:
 		pr_err("Invalid UDP bearer configuration");
 		return -EINVAL;
 	}
-	if ((sa_local->ss_family & sa_remote->ss_family) == AF_INET) {
+	if ((sa_local.ss_family & sa_remote.ss_family) == AF_INET) {
 		struct sockaddr_in *ip4;
 
-		ip4 = (struct sockaddr_in *)sa_local;
+		ip4 = (struct sockaddr_in *)&sa_local;
 		local->proto = htons(ETH_P_IP);
 		local->udp_port = ip4->sin_port;
 		local->ipv4.s_addr = ip4->sin_addr.s_addr;
 
-		ip4 = (struct sockaddr_in *)sa_remote;
+		ip4 = (struct sockaddr_in *)&sa_remote;
 		remote->proto = htons(ETH_P_IP);
 		remote->udp_port = ip4->sin_port;
 		remote->ipv4.s_addr = ip4->sin_addr.s_addr;
 		return 0;
 
 #if IS_ENABLED(CONFIG_IPV6)
-	} else if ((sa_local->ss_family & sa_remote->ss_family) == AF_INET6) {
+	} else if ((sa_local.ss_family & sa_remote.ss_family) == AF_INET6) {
 		struct sockaddr_in6 *ip6;
 
-		ip6 = (struct sockaddr_in6 *)sa_local;
+		ip6 = (struct sockaddr_in6 *)&sa_local;
 		local->proto = htons(ETH_P_IPV6);
 		local->udp_port = ip6->sin6_port;
-		local->ipv6 = ip6->sin6_addr;
+		memcpy(&local->ipv6, &ip6->sin6_addr, sizeof(struct in6_addr));
 		ub->ifindex = ip6->sin6_scope_id;
 
-		ip6 = (struct sockaddr_in6 *)sa_remote;
+		ip6 = (struct sockaddr_in6 *)&sa_remote;
 		remote->proto = htons(ETH_P_IPV6);
 		remote->udp_port = ip6->sin6_port;
-		remote->ipv6 = ip6->sin6_addr;
+		memcpy(&remote->ipv6, &ip6->sin6_addr, sizeof(struct in6_addr));
 		return 0;
 #endif
 	}
-- 
2.1.4
