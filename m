From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next v3 3/3] net: ipv6: Use ip6_datagram_send_common in ping.
Date: Wed, 23 Apr 2014 00:14:16 +0900
Message-ID: <1398179656-9313-3-git-send-email-lorenzo@google.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
 <1398179656-9313-1-git-send-email-lorenzo@google.com>
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	davem@davemloft.net, eric.dumazet@gmail.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33700 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932963AbaDVPOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 11:14:47 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so5015995pdb.0
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 08:14:46 -0700 (PDT)
In-Reply-To: <1398179656-9313-1-git-send-email-lorenzo@google.com>
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
 net/ipv6/ping.c | 95 +++++++++++++++++++--------------------------------------
 1 file changed, 31 insertions(+), 64 deletions(-)

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index bda7429..96730c6 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -81,16 +81,17 @@ static int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		    size_t len)
 {
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
 	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ipv6_txoptions *opt, opt_space;
 	struct icmp6hdr user_icmph;
-	int addr_type;
+	int addr_len = msg->msg_namelen;
 	struct in6_addr *daddr;
-	int iif = 0;
 	struct flowi6 fl6;
 	int err;
-	int hlimit;
-	struct dst_entry *dst;
+	int hlimit, tclass, dontfrag;
+	int connected;
+	struct dst_entry *dst = NULL;
 	struct rt6_info *rt;
 	struct pingfakehdr pfh;
 
@@ -101,63 +102,38 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (err)
 		return err;
 
-	if (msg->msg_name) {
-		DECLARE_SOCKADDR(struct sockaddr_in6 *, u, msg->msg_name);
-		if (msg->msg_namelen < sizeof(struct sockaddr_in6) ||
-		    u->sin6_family != AF_INET6) {
+	if (sin6) {
+		if (addr_len < sizeof(struct sockaddr_in6))
 			return -EINVAL;
-		}
-		if (sk->sk_bound_dev_if &&
-		    sk->sk_bound_dev_if != u->sin6_scope_id) {
-			return -EINVAL;
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
 
-	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
-		fl6.flowi6_oif = np->mcast_oif;
-	else if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->ucast_oif;
-
-	dst = ip6_sk_dst_lookup_flow(sk, &fl6,  daddr);
-	if (IS_ERR(dst))
-		return PTR_ERR(dst);
-	rt = (struct rt6_info *) dst;
-
-	np = inet6_sk(sk);
-	if (!np)
-		return -EBADF;
+	err = ip6_datagram_send_common(sk, msg, sin6, addr_len, &fl6, &dst,
+				       &opt, &opt_space, &hlimit, &tclass,
+				       &dontfrag, &connected);
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
@@ -168,18 +144,10 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	pfh.wcheck = 0;
 	pfh.family = AF_INET6;
 
-	if (ipv6_addr_is_multicast(&fl6.daddr))
-		hlimit = np->mcast_hops;
-	else
-		hlimit = np->hop_limit;
-	if (hlimit < 0)
-		hlimit = ip6_dst_hoplimit(dst);
-
+	rt = (struct rt6_info *) dst;
 	lock_sock(sk);
-	err = ip6_append_data(sk, ping_getfrag, &pfh, len,
-			      0, hlimit,
-			      np->tclass, NULL, &fl6, rt,
-			      MSG_DONTWAIT, np->dontfrag);
+	err = ip6_append_data(sk, ping_getfrag, &pfh, len, 0, hlimit, tclass,
+			      opt, &fl6, rt, msg->msg_flags, dontfrag);
 
 	if (err) {
 		ICMP6_INC_STATS(sock_net(sk), rt->rt6i_idev,
@@ -192,10 +160,9 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
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
