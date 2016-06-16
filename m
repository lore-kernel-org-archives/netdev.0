From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 6/8] ipv6: Support TOU
Date: Thu, 16 Jun 2016 10:52:00 -0700
Message-ID: <1466099522-690741-7-git-send-email-tom@herbertland.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46291 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755061AbcFPRw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 13:52:29 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GHoeNM003252
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23kxw30q5t-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:28 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 16f14bb433eb11e6b7aa0002c9dfb610-84cc2e0 for <netdev@vger.kernel.org>;	Thu,
 16 Jun 2016 10:52:27 -0700
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In transmit path (inet6_csk_xmit) check if encapsulation is enabled and
call the build header op if it is. Add IP_TOU_ENCAP setsockopt for IPv6
sockets.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/in6.h         |  1 +
 net/ipv6/inet6_connection_sock.c | 58 ++++++++++++++++++++++++++++++++++------
 net/ipv6/ipv6_sockglue.c         |  7 +++++
 3 files changed, 58 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 318a482..9a610c3 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -282,6 +282,7 @@ struct in6_flowlabel_req {
 #define IPV6_RECVORIGDSTADDR    IPV6_ORIGDSTADDR
 #define IPV6_TRANSPARENT        75
 #define IPV6_UNICAST_IF         76
+#define IPV6_TOU_ENCAP		77
 
 /*
  * Multicast Routing:
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 532c3ef..6c971bc 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -24,6 +24,7 @@
 #include <net/inet_ecn.h>
 #include <net/inet_hashtables.h>
 #include <net/ip6_route.h>
+#include <net/ip6_tunnel.h>
 #include <net/sock.h>
 #include <net/inet6_connection_sock.h>
 #include <net/sock_reuseport.h>
@@ -118,13 +119,11 @@ struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
 	return __sk_dst_check(sk, cookie);
 }
 
-static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
-						struct flowi6 *fl6)
+static void inet6_csk_fill_flowi6(struct sock *sk,
+				  struct flowi6 *fl6)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct in6_addr *final_p, final;
-	struct dst_entry *dst;
 
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->flowi6_proto = sk->sk_protocol;
@@ -137,6 +136,14 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 	fl6->fl6_sport = inet->inet_sport;
 	fl6->fl6_dport = inet->inet_dport;
 	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
+}
+
+static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
+						struct flowi6 *fl6)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct in6_addr *final_p, final;
+	struct dst_entry *dst;
 
 	rcu_read_lock();
 	final_p = fl6_update_dst(fl6, rcu_dereference(np->opt), &final);
@@ -154,20 +161,48 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 
 int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl_unused)
 {
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int res;
+	u8 protocol = sk->sk_protocol;
+	struct ip_tunnel_encap *e = inet->tou_encap;
+
+	inet6_csk_fill_flowi6(sk, &fl6);
+
+	rcu_read_lock();
+
+	e = rcu_dereference(inet->tou_encap);
+	if (e) {
+		const struct ip6_tnl_encap_ops *ops;
+
+		/* Transport layer protocol over UDP enapsulation */
+		ops = rcu_dereference(ip6tun_encaps[e->type]);
+		if (likely(ops && ops->build_header)) {
+			res = ops->build_header(skb, e, &protocol,
+						&fl6, sock_net(sk));
+			if (res < 0)
+				goto fail;
+		} else {
+			res = -EINVAL;
+			goto fail;
+		}
+
+		/* Changing ports and protocol to be routed */
+		fl6.fl6_sport = e->sport;
+		fl6.fl6_dport = e->dport;
+		fl6.flowi6_proto = protocol;
+	}
 
 	dst = inet6_csk_route_socket(sk, &fl6);
 	if (IS_ERR(dst)) {
 		sk->sk_err_soft = -PTR_ERR(dst);
 		sk->sk_route_caps = 0;
-		kfree_skb(skb);
-		return PTR_ERR(dst);
+		res = PTR_ERR(dst);
+		goto fail;
 	}
 
-	rcu_read_lock();
 	skb_dst_set_noref(skb, dst);
 
 	/* Restore final destination back after routing done */
@@ -177,14 +212,21 @@ int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl_unused
 		       np->tclass);
 	rcu_read_unlock();
 	return res;
+fail:
+	rcu_read_unlock();
+	kfree_skb(skb);
+	return res;
 }
 EXPORT_SYMBOL_GPL(inet6_csk_xmit);
 
 struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu)
 {
 	struct flowi6 fl6;
-	struct dst_entry *dst = inet6_csk_route_socket(sk, &fl6);
+	struct dst_entry *dst;
+
+	inet6_csk_fill_flowi6(sk, &fl6);
 
+	dst = inet6_csk_route_socket(sk, &fl6);
 	if (IS_ERR(dst))
 		return NULL;
 	dst->ops->update_pmtu(dst, sk, NULL, mtu);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a9895e1..1697c0e 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -52,6 +52,7 @@
 #include <net/udplite.h>
 #include <net/xfrm.h>
 #include <net/compat.h>
+#include <net/tou.h>
 
 #include <asm/uaccess.h>
 
@@ -868,6 +869,9 @@ pref_skip_coa:
 		np->autoflowlabel = valbool;
 		retv = 0;
 		break;
+	case IPV6_TOU_ENCAP:
+		retv = tou_encap_setsockopt(sk, optval, optlen, true);
+		break;
 	}
 
 	release_sock(sk);
@@ -1310,6 +1314,9 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->autoflowlabel;
 		break;
 
+	case IPV6_TOU_ENCAP:
+		return tou_encap_getsockopt(sk, optval, len, optlen, true);
+
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
2.8.0.rc2
