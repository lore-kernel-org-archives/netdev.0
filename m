From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net 1/4] ipv6: datagram: Refactor flowi6 init codes to a new function
Date: Mon, 11 Apr 2016 15:29:34 -0700
Message-ID: <1460413777-177662-2-git-send-email-kafai@fb.com>
References: <1460413777-177662-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55275 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752846AbcDKW3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 18:29:52 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3BMO0Yb006058
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:29:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 226wj48rqj-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:29:51 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 e68dcad6003411e6a4e924be0595f910-ecce93f0 for <netdev@vger.kernel.org>;	Mon,
 11 Apr 2016 15:29:49 -0700
In-Reply-To: <1460413777-177662-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move flowi6 init codes for connected datagram sk to a newly created
function ip6_datagram_flow_key_init().

Notes:
1. fl6_flowlabel is used instead of fl6.flowlabel in __ip6_datagram_connect
2. ipv6_addr_is_multicast(&fl6->daddr) is used instead of
   (addr_type & IPV6_ADDR_MULTICAST) in ip6_datagram_flow_key_init()

This new function will be reused during pmtu update in the later patch.

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
