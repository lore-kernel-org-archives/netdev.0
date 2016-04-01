From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net 1/4] ipv6: datagram: Refactor flowi6 init codes to a new function
Date: Fri, 1 Apr 2016 15:56:28 -0700
Message-ID: <1459551391-69969-2-git-send-email-kafai@fb.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33136 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753749AbcDAW5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 18:57:32 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u31MubSX019806
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2016 15:57:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2220mm0ca2-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 15:57:31 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 1d047cd4f85d11e583000002c99331b0-231f33f0 for <netdev@vger.kernel.org>;	Fri,
 01 Apr 2016 15:57:30 -0700
In-Reply-To: <1459551391-69969-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move flowi6 init codes for connected datagram sk to a newly created
function ip6_datagram_flow_key_init().

It will be reused during pmtu update in the later patch.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Wei Wang <weiwan@google.com>
---
 net/ipv6/datagram.c | 50 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 20 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 4281621..f07c1dd 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -40,6 +40,30 @@ static bool ipv6_mapped_addr_any(const struct in6_addr *a)
 	return ipv6_addr_v4mapped(a) && (a->s6_addr32[3] == 0);
 }
 
+static void ip6_datagram_flow_key_init(struct flowi6 *fl6, struct sock *sk)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	memset(fl6, 0, sizeof(*fl6));
+	fl6->flowi6_proto = sk->sk_protocol;
+	fl6->daddr = sk->sk_v6_daddr;
+	fl6->saddr = np->saddr;
+	fl6->flowi6_oif = sk->sk_bound_dev_if;
+	fl6->flowi6_mark = sk->sk_mark;
+	fl6->fl6_dport = inet->inet_dport;
+	fl6->fl6_sport = inet->inet_sport;
+	fl6->flowlabel = np->flow_label;
+
+	if (!fl6->flowi6_oif)
+		fl6->flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
+
+	if (!fl6->flowi6_oif && ipv6_addr_is_multicast(&fl6->daddr))
+		fl6->flowi6_oif = np->mcast_oif;
+
+	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
+}
+
 static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
@@ -52,6 +76,7 @@ static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int a
 	struct ipv6_txoptions	*opt;
 	int			addr_type;
 	int			err;
+	__be32			fl6_flowlabel = 0;
 
 	if (usin->sin6_family == AF_INET) {
 		if (__ipv6_only_sock(sk))
@@ -66,11 +91,10 @@ static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int a
 	if (usin->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
-	memset(&fl6, 0, sizeof(fl6));
 	if (np->sndflow) {
-		fl6.flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-		if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
-			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
+		fl6_flowlabel = usin->sin6_flowinfo & IPV6_FLOWINFO_MASK;
+		if (fl6_flowlabel & IPV6_FLOWLABEL_MASK) {
+			flowlabel = fl6_sock_lookup(sk, fl6_flowlabel);
 			if (!flowlabel)
 				return -EINVAL;
 		}
@@ -145,7 +169,7 @@ ipv4_connected:
 	}
 
 	sk->sk_v6_daddr = *daddr;
-	np->flow_label = fl6.flowlabel;
+	np->flow_label = fl6_flowlabel;
 
 	inet->inet_dport = usin->sin6_port;
 
@@ -154,21 +178,7 @@ ipv4_connected:
 	 *	destination cache for it.
 	 */
 
-	fl6.flowi6_proto = sk->sk_protocol;
-	fl6.daddr = sk->sk_v6_daddr;
-	fl6.saddr = np->saddr;
-	fl6.flowi6_oif = sk->sk_bound_dev_if;
-	fl6.flowi6_mark = sk->sk_mark;
-	fl6.fl6_dport = inet->inet_dport;
-	fl6.fl6_sport = inet->inet_sport;
-
-	if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
-
-	if (!fl6.flowi6_oif && (addr_type&IPV6_ADDR_MULTICAST))
-		fl6.flowi6_oif = np->mcast_oif;
-
-	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
+	ip6_datagram_flow_key_init(&fl6, sk);
 
 	rcu_read_lock();
 	opt = flowlabel ? flowlabel->opt : rcu_dereference(np->opt);
-- 
2.5.1
