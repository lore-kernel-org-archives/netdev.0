From: Lorenzo Colitti <lorenzo@google.com>
Subject: [RFC][PATCH net-next] net: Support for dual-stack ping sockets.
Date: Fri, 25 Apr 2014 01:02:56 +0900
Message-ID: <1398355376-7741-1-git-send-email-lorenzo@google.com>
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:42294 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758127AbaDXQDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 12:03:11 -0400
Received: by mail-pb0-f44.google.com with SMTP id jt11so386206pbb.31
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 09:03:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This mostly looks fine, except that to make the protocol field in
the IPv4 header be ICMP (1) instead of ICMPv6 (58), it hacks
sk->sk_protocol to IPPROTO_ICMP. It's done with the socket
locked, so it will at least not race with other calls to
sendmsg on the same socket, but it feels hacky and I don't know
what else might break.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/ping.h |  2 ++
 net/ipv4/ping.c    | 37 ++++++++++++++++++++++++++++---------
 net/ipv6/ping.c    | 23 ++++++++++++++++++-----
 3 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/include/net/ping.h b/include/net/ping.h
index 026479b..0e0f3ac 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -79,6 +79,8 @@ int  ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		  size_t len, int noblock, int flags, int *addr_len);
 int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 			 void *user_icmph, size_t icmph_len);
+int  ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		     size_t len);
 int  ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		     size_t len);
 int  ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 8a912b8..657092b2f 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -278,6 +278,7 @@ int ping_init_sock(struct sock *sk)
 
 out_release_group:
 	put_group_info(group_info);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(ping_init_sock);
@@ -682,8 +683,8 @@ int ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 }
 EXPORT_SYMBOL_GPL(ping_common_sendmsg);
 
-static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-			   size_t len)
+int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		    size_t len)
 {
 	struct net *net = sock_net(sk);
 	struct flowi4 fl4;
@@ -697,6 +698,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	__be32 saddr, daddr, faddr;
 	u8  tos;
 	int err;
+	u8 protocol;
 
 	pr_debug("ping_v4_sendmsg(sk=%p,sk->num=%u)\n", inet, inet->inet_num);
 
@@ -777,7 +779,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 		ipc.oif = inet->uc_index;
 
 	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
-			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
+			   RT_SCOPE_UNIVERSE, IPPROTO_ICMP,
 			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0,
 			   sock_i_uid(sk));
 
@@ -814,12 +816,23 @@ back_from_confirm:
 	pfh.wcheck = 0;
 	pfh.family = AF_INET;
 
+	/* Hack for dual-stack sockets.
+	 * The protocol field in the IPv4 header is determined by
+	 * sk->sk_protocol, but on a dual-stack socket, sk->sk_protocol is
+	 * IPPROTO_ICMPV6. Fix it up here and set it back to the previous
+	 * value before releasing the lock.
+	 */
+	protocol = sk->sk_protocol;
+	sk->sk_protocol = IPPROTO_ICMP;
+
 	err = ip_append_data(sk, &fl4, ping_getfrag, &pfh, len,
 			0, &ipc, &rt, msg->msg_flags);
 	if (err)
 		ip_flush_pending_frames(sk);
 	else
 		err = ping_v4_push_pending_frames(sk, &pfh, &fl4);
+
+	protocol = sk->sk_protocol;
 	release_sock(sk);
 
 out:
@@ -901,18 +914,24 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	} else if (family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 		struct ipv6hdr *ip6 = ipv6_hdr(skb);
+		int is_ipv4 = (skb->protocol == htons(ETH_P_IP));
 		DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
 
 		if (sin6) {
 			sin6->sin6_family = AF_INET6;
 			sin6->sin6_port = 0;
-			sin6->sin6_addr = ip6->saddr;
 			sin6->sin6_flowinfo = 0;
-			if (np->sndflow)
-				sin6->sin6_flowinfo = ip6_flowinfo(ip6);
-			sin6->sin6_scope_id =
-				ipv6_iface_scope_id(&sin6->sin6_addr,
-						    IP6CB(skb)->iif);
+			if (is_ipv4) {
+				ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
+					       &sin6->sin6_addr);
+			} else {
+				sin6->sin6_addr = ip6->saddr;
+				if (np->sndflow)
+					sin6->sin6_flowinfo = ip6_flowinfo(ip6);
+				sin6->sin6_scope_id =
+					ipv6_iface_scope_id(&sin6->sin6_addr,
+							    IP6CB(skb)->iif);
+			}
 			*addr_len = sizeof(*sin6);
 		}
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 96730c6..7011b3d 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -97,11 +97,6 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	pr_debug("ping_v6_sendmsg(sk=%p,sk->num=%u)\n", inet, inet->inet_num);
 
-	err = ping_common_sendmsg(AF_INET6, msg, len, &user_icmph,
-				  sizeof(user_icmph));
-	if (err)
-		return err;
-
 	if (sin6) {
 		if (addr_len < sizeof(struct sockaddr_in6))
 			return -EINVAL;
@@ -114,6 +109,24 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		daddr = &sk->sk_v6_daddr;
 	}
 
+	if (ipv6_addr_v4mapped(daddr)) {
+		struct sockaddr_in sin;
+
+		sin.sin_family = AF_INET;
+		sin.sin_port = sin6 ? sin6->sin6_port : inet->inet_dport;
+		sin.sin_addr.s_addr = daddr->s6_addr32[3];
+		msg->msg_name = &sin;
+		msg->msg_namelen = sizeof(sin);
+		if (__ipv6_only_sock(sk))
+			return -ENETUNREACH;
+		return ping_v4_sendmsg(iocb, sk, msg, len);
+	}
+
+	err = ping_common_sendmsg(AF_INET6, msg, len, &user_icmph,
+				  sizeof(user_icmph));
+	if (err)
+		return err;
+
 	if (ipv6_addr_v4mapped(daddr))
 		return -EINVAL;
 
-- 
1.9.1.423.g4596e3a
