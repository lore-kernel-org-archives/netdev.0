From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v6 2/2] net: ipv6: Use ip6_datagram_send_common in ping.
Date: Sat,  3 May 2014 04:11:08 +0900
Message-ID: <1399057868-3488-3-git-send-email-lorenzo@google.com>
References: <1399057868-3488-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	yoshifuji@linux-ipv6.org, david.laight@aculab.com,
	eric.dumazet@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:47278 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbaEBTLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:11:22 -0400
Received: by mail-pa0-f43.google.com with SMTP id rd3so5894925pab.2
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 12:11:21 -0700 (PDT)
In-Reply-To: <1399057868-3488-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replaces the ad-hoc code used by ping6_sendmsg with the
implementation now used by UDP, raw and L2TP sockets. This also
adds the ability to set options via ancillary data, proper
flowlabel validation, etc. etc.

Tested: Black-box tested using user-mode Linux.

- IPv6 pings using both connect()/send() and sendto() still work.
- Fragmented IPv6 pings still work.
- Specifying a flowlabel still works.
- Attempting to send a flowlabel that is not first set via
  IPV6_FLOWLABEL_MGR now correctly returns EINVAL.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv6/ping.c | 89 +++++++++++++++++++--------------------------------------
 1 file changed, 30 insertions(+), 59 deletions(-)

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index ee633a6..c90161b 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -81,16 +81,16 @@ static int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		    size_t len)
 {
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
 	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct ip6_output_opts outopts;
+	struct ipv6_txoptions opt_space;
+	struct ip6_output_opts outopts = IP6_OUTOPTS_INIT;
 	struct icmp6hdr user_icmph;
-	int addr_type;
+	int addr_len = msg->msg_namelen;
 	struct in6_addr *daddr;
-	int iif = 0;
-	struct flowi6 fl6;
 	int err;
-	struct dst_entry *dst;
+	struct flowi6 fl6;
+	struct dst_entry *dst = NULL;
 	struct rt6_info *rt;
 	struct pingfakehdr pfh;
 
@@ -101,63 +101,37 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (err)
 		return err;
 
-	if (msg->msg_name) {
-		DECLARE_SOCKADDR(struct sockaddr_in6 *, u, msg->msg_name);
-		if (msg->msg_namelen < sizeof(struct sockaddr_in6) ||
-		    u->sin6_family != AF_INET6) {
-			return -EINVAL;
-		}
-		if (sk->sk_bound_dev_if &&
-		    sk->sk_bound_dev_if != u->sin6_scope_id) {
+	if (sin6) {
+		if (addr_len < sizeof(struct sockaddr_in6))
 			return -EINVAL;
-		}
-		daddr = &(u->sin6_addr);
-		iif = u->sin6_scope_id;
+
+		if (sin6->sin6_family != AF_INET6)
+			return -EAFNOSUPPORT;
+
+		daddr = &sin6->sin6_addr;
 	} else {
-		if (sk->sk_state != TCP_ESTABLISHED)
-			return -EDESTADDRREQ;
 		daddr = &sk->sk_v6_daddr;
 	}
 
-	if (!iif)
-		iif = sk->sk_bound_dev_if;
-
-	addr_type = ipv6_addr_type(daddr);
-	if (__ipv6_addr_needs_scope_id(addr_type) && !iif)
-		return -EINVAL;
-	if (addr_type & IPV6_ADDR_MAPPED)
+	if (ipv6_addr_v4mapped(daddr))
 		return -EINVAL;
 
-	/* TODO: use ip6_datagram_send_ctl to get options from cmsg */
-
 	memset(&fl6, 0, sizeof(fl6));
-
 	fl6.flowi6_proto = IPPROTO_ICMPV6;
-	fl6.saddr = np->saddr;
-	fl6.daddr = *daddr;
-	fl6.flowi6_mark = sk->sk_mark;
 	fl6.fl6_icmp_type = user_icmph.icmp6_type;
 	fl6.fl6_icmp_code = user_icmph.icmp6_code;
-	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
-
-	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
-		fl6.flowi6_oif = np->mcast_oif;
-	else if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->ucast_oif;
 
-	dst = ip6_sk_dst_lookup_flow(sk, &fl6,  daddr);
-	if (IS_ERR(dst))
-		return PTR_ERR(dst);
-	rt = (struct rt6_info *) dst;
-
-	np = inet6_sk(sk);
-	if (!np)
-		return -EBADF;
+	err = ip6_datagram_send_common(sk, msg, &fl6, &dst,
+				       &outopts, &opt_space);
+	if (err)
+		goto out;
 
-	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
-		fl6.flowi6_oif = np->mcast_oif;
-	else if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->ucast_oif;
+	/* TODO: Move this check into ip6_datagram_sendmsg. */
+	if (__ipv6_addr_needs_scope_id(__ipv6_addr_type(daddr)) &&
+	    !fl6.flowi6_oif) {
+		err = -EINVAL;
+		goto out;
+	}
 
 	pfh.icmph.type = user_icmph.icmp6_type;
 	pfh.icmph.code = user_icmph.icmp6_code;
@@ -168,12 +142,10 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	pfh.wcheck = 0;
 	pfh.family = AF_INET6;
 
-
-	ip6_output_opts_sk_dst_init(&outopts, np, &fl6, dst);
-
+	rt = (struct rt6_info *) dst;
 	lock_sock(sk);
-	err = ip6_append_data(sk, ping_getfrag, &pfh, len, 0,
-			      &outopts, &fl6, rt, MSG_DONTWAIT);
+	err = ip6_append_data(sk, ping_getfrag, &pfh, len, 0, &fl6, rt,
+			      &outopts, MSG_DONTWAIT);
 
 	if (err) {
 		ICMP6_INC_STATS(sock_net(sk), rt->rt6i_idev,
@@ -186,10 +158,9 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 	release_sock(sk);
 
-	if (err)
-		return err;
-
-	return len;
+out:
+	dst_release(dst);
+	return err ? err : len;
 }
 
 #ifdef CONFIG_PROC_FS
-- 
1.9.1.423.g4596e3a
