From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v2] net: ping: Return EAFNOSUPPORT when appropriate.
Date: Tue,  3 Mar 2015 23:16:16 +0900
Message-ID: <1425392176-29114-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35877 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933AbbCCOQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:16:25 -0500
Received: by pdbnh10 with SMTP id nh10so25127692pdb.3
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 06:16:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. For an IPv4 ping socket, ping_check_bind_addr does not check
   the family of the socket address that's passed in. Instead,
   make it behave like inet_bind, which enforces either that the
   address family is AF_INET, or that the family is AF_UNSPEC and
   the address is 0.0.0.0.
2. For an IPv6 ping socket, ping_check_bind_addr returns EINVAL
   if the socket family is not AF_INET6. Return EAFNOSUPPORT
   instead, for consistency with inet6_bind.
3. Make ping_v4_sendmsg and ping_v6_sendmsg return EAFNOSUPPORT
   instead of EINVAL if an incorrect socket address structure is
   passed in.
4. Make IPv6 ping sockets be IPv6-only. The code does not support
   IPv4, and it cannot easily be made to support IPv4 because
   the protocol numbers for ICMP and ICMPv6 are different. This
   makes connect(::ffff:192.0.2.1) fail with EAFNOSUPPORT instead
   of making the socket unusable.

Among other things, this fixes an oops that can be triggered by:

    int s = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
    struct sockaddr_in6 sin6 = {
        .sin6_family = AF_INET6,
        .sin6_addr = in6addr_any,
    };
    bind(s, (struct sockaddr *) &sin6, sizeof(sin6));

Change-Id: If06ca86d9f1e4593c0d6df174caca3487c57a241
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/ping.c | 12 ++++++++++--
 net/ipv6/ping.c |  5 +++--
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 3648e7f..fd88f86 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -259,6 +259,9 @@ int ping_init_sock(struct sock *sk)
 	kgid_t low, high;
 	int ret = 0;
 
+	if (sk->sk_family == AF_INET6)
+		sk->sk_ipv6only = 1;
+
 	inet_get_ping_group_range_net(net, &low, &high);
 	if (gid_lte(low, group) && gid_lte(group, high))
 		return 0;
@@ -305,6 +308,11 @@ static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 		if (addr_len < sizeof(*addr))
 			return -EINVAL;
 
+		if (addr->sin_family != AF_INET &&
+		    !(addr->sin_family == AF_UNSPEC &&
+		      addr->sin_addr.s_addr == htonl(INADDR_ANY)))
+			return -EAFNOSUPPORT;
+
 		pr_debug("ping_check_bind_addr(sk=%p,addr=%pI4,port=%d)\n",
 			 sk, &addr->sin_addr.s_addr, ntohs(addr->sin_port));
 
@@ -330,7 +338,7 @@ static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 			return -EINVAL;
 
 		if (addr->sin6_family != AF_INET6)
-			return -EINVAL;
+			return -EAFNOSUPPORT;
 
 		pr_debug("ping_check_bind_addr(sk=%p,addr=%pI6c,port=%d)\n",
 			 sk, addr->sin6_addr.s6_addr, ntohs(addr->sin6_port));
@@ -715,7 +723,7 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		if (msg->msg_namelen < sizeof(*usin))
 			return -EINVAL;
 		if (usin->sin_family != AF_INET)
-			return -EINVAL;
+			return -EAFNOSUPPORT;
 		daddr = usin->sin_addr.s_addr;
 		/* no remote port */
 	} else {
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index fee25c0..263a516 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -101,9 +101,10 @@ int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	if (msg->msg_name) {
 		DECLARE_SOCKADDR(struct sockaddr_in6 *, u, msg->msg_name);
-		if (msg->msg_namelen < sizeof(struct sockaddr_in6) ||
-		    u->sin6_family != AF_INET6) {
+		if (msg->msg_namelen < sizeof(*u))
 			return -EINVAL;
+		if (u->sin6_family != AF_INET6) {
+			return -EAFNOSUPPORT;
 		}
 		if (sk->sk_bound_dev_if &&
 		    sk->sk_bound_dev_if != u->sin6_scope_id) {
-- 
2.2.0.rc0.207.ga3a616c
