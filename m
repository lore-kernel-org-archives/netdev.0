From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net 2/4] ipv6: datagram: Refactor dst lookup and update codes to a new function
Date: Fri, 1 Apr 2016 15:56:29 -0700
Message-ID: <1459551391-69969-3-git-send-email-kafai@fb.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:23311 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753769AbcDAW5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 18:57:40 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u31MubIu019811
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2016 15:57:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2220mm0cac-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 15:57:34 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 1d5588c2f85d11e5a1a424be0593f280-2beee3f0 for <netdev@vger.kernel.org>;	Fri,
 01 Apr 2016 15:57:31 -0700
In-Reply-To: <1459551391-69969-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the route lookup and update codes for connected
datagram sk to a newly created function ip6_datagram_dst_update()

It will be reused during the pmtu update in the later patch.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Wei Wang <weiwan@google.com>
---
 net/ipv6/datagram.c | 103 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 57 insertions(+), 46 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index f07c1dd..140665b 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -64,16 +64,65 @@ static void ip6_datagram_flow_key_init(struct flowi6 *fl6, struct sock *sk)
 	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 }
 
+static int ip6_datagram_dst_update(struct sock *sk)
+{
+	struct ip6_flowlabel *flowlabel = NULL;
+	struct in6_addr *final_p, final;
+	struct ipv6_txoptions *opt;
+	struct dst_entry *dst;
+	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct flowi6 fl6;
+	int err = 0;
+
+	if (np->sndflow && np->flow_label) {
+		flowlabel = fl6_sock_lookup(sk, np->flow_label);
+		if (!flowlabel)
+			return -EINVAL;
+	}
+	ip6_datagram_flow_key_init(&fl6, sk);
+
+	rcu_read_lock();
+	opt = flowlabel ? flowlabel->opt : rcu_dereference(np->opt);
+	final_p = fl6_update_dst(&fl6, opt, &final);
+	rcu_read_unlock();
+
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
+		goto out;
+	}
+
+	if (ipv6_addr_any(&np->saddr))
+		np->saddr = fl6.saddr;
+
+	if (ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+		sk->sk_v6_rcv_saddr = fl6.saddr;
+		inet->inet_rcv_saddr = LOOPBACK4_IPV6;
+		if (sk->sk_prot->rehash)
+			sk->sk_prot->rehash(sk);
+	}
+
+	ip6_dst_store(sk, dst,
+		      ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr) ?
+		      &sk->sk_v6_daddr : NULL,
+#ifdef CONFIG_IPV6_SUBTREES
+		      ipv6_addr_equal(&fl6.saddr, &np->saddr) ?
+		      &np->saddr :
+#endif
+		      NULL);
+
+out:
+	fl6_sock_release(flowlabel);
+	return err;
+}
+
 static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
 	struct inet_sock	*inet = inet_sk(sk);
 	struct ipv6_pinfo	*np = inet6_sk(sk);
-	struct in6_addr	*daddr, *final_p, final;
-	struct dst_entry	*dst;
-	struct flowi6		fl6;
-	struct ip6_flowlabel	*flowlabel = NULL;
-	struct ipv6_txoptions	*opt;
+	struct in6_addr		*daddr;
 	int			addr_type;
 	int			err;
 	__be32			fl6_flowlabel = 0;
@@ -91,14 +140,8 @@ static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int a
 	if (usin->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
-	if (np->sndflow) {
+	if (np->sndflow)
 		fl6_flowlabel = usin->sin6_flowinfo & IPV6_FLOWINFO_MASK;
-		if (fl6_flowlabel & IPV6_FLOWLABEL_MASK) {
-			flowlabel = fl6_sock_lookup(sk, fl6_flowlabel);
-			if (!flowlabel)
-				return -EINVAL;
-		}
-	}
 
 	addr_type = ipv6_addr_type(&usin->sin6_addr);
 
@@ -178,45 +221,13 @@ ipv4_connected:
 	 *	destination cache for it.
 	 */
 
-	ip6_datagram_flow_key_init(&fl6, sk);
-
-	rcu_read_lock();
-	opt = flowlabel ? flowlabel->opt : rcu_dereference(np->opt);
-	final_p = fl6_update_dst(&fl6, opt, &final);
-	rcu_read_unlock();
-
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
-	err = 0;
-	if (IS_ERR(dst)) {
-		err = PTR_ERR(dst);
+	err = ip6_datagram_dst_update(sk);
+	if (err)
 		goto out;
-	}
-
-	/* source address lookup done in ip6_dst_lookup */
-
-	if (ipv6_addr_any(&np->saddr))
-		np->saddr = fl6.saddr;
-
-	if (ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
-		sk->sk_v6_rcv_saddr = fl6.saddr;
-		inet->inet_rcv_saddr = LOOPBACK4_IPV6;
-		if (sk->sk_prot->rehash)
-			sk->sk_prot->rehash(sk);
-	}
-
-	ip6_dst_store(sk, dst,
-		      ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr) ?
-		      &sk->sk_v6_daddr : NULL,
-#ifdef CONFIG_IPV6_SUBTREES
-		      ipv6_addr_equal(&fl6.saddr, &np->saddr) ?
-		      &np->saddr :
-#endif
-		      NULL);
 
 	sk->sk_state = TCP_ESTABLISHED;
 	sk_set_txhash(sk);
 out:
-	fl6_sock_release(flowlabel);
 	return err;
 }
 
-- 
2.5.1
