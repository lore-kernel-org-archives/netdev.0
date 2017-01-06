From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 4/4] l2tp: rework socket comparison in
 __l2tp_ip*_bind_lookup()
Date: Fri, 6 Jan 2017 20:03:57 +0100
Message-ID: <c4f5fddf63e2ddf717437d0c1f7e5be041a19966.1483727525.git.g.nault@alphalink.fr>
References: <cover.1483727525.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60929 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032836AbdAFTEB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 14:04:01 -0500
Content-Disposition: inline
In-Reply-To: <cover.1483727525.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split conditions, so that each test becomes clearer.

Also, for l2tp_ip, check if "laddr" is 0. This prevents a socket from
binding to the unspecified address when other sockets are already bound
using the same device (if any), connection ID and namespace.

Same thing for l2tp_ip6: add ipv6_addr_any(laddr) and
ipv6_addr_any(raddr) tests to ensure that an IPv6 unspecified address
passed as parameter is properly treated a wildcard.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c  | 24 +++++++++++++++++-------
 net/l2tp/l2tp_ip6.c | 25 ++++++++++++++++++-------
 2 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 499d3cdbfbc8..b07a859f21bd 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -56,13 +56,23 @@ static struct sock *__l2tp_ip_bind_lookup(const struct net *net, __be32 laddr,
 		const struct l2tp_ip_sock *l2tp = l2tp_ip_sk(sk);
 		const struct inet_sock *inet = inet_sk(sk);
 
-		if ((l2tp->conn_id == tunnel_id) &&
-		    net_eq(sock_net(sk), net) &&
-		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
-		    (!inet->inet_daddr || !raddr || inet->inet_daddr == raddr) &&
-		    (!sk->sk_bound_dev_if || !dif ||
-		     sk->sk_bound_dev_if == dif))
-			goto found;
+		if (!net_eq(sock_net(sk), net))
+			continue;
+
+		if (sk->sk_bound_dev_if && dif && sk->sk_bound_dev_if != dif)
+			continue;
+
+		if (inet->inet_rcv_saddr && laddr &&
+		    inet->inet_rcv_saddr != laddr)
+			continue;
+
+		if (inet->inet_daddr && raddr && inet->inet_daddr != raddr)
+			continue;
+
+		if (l2tp->conn_id != tunnel_id)
+			continue;
+
+		goto found;
 	}
 
 	sk = NULL;
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 7165b06d7b25..4b06eb415f68 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -69,13 +69,24 @@ static struct sock *__l2tp_ip6_bind_lookup(const struct net *net,
 		const struct in6_addr *sk_raddr = &sk->sk_v6_daddr;
 		const struct l2tp_ip6_sock *l2tp = l2tp_ip6_sk(sk);
 
-		if ((l2tp->conn_id == tunnel_id) &&
-		    net_eq(sock_net(sk), net) &&
-		    (!sk_laddr || ipv6_addr_any(sk_laddr) || ipv6_addr_equal(sk_laddr, laddr)) &&
-		    (!raddr || ipv6_addr_any(sk_raddr) || ipv6_addr_equal(sk_raddr, raddr)) &&
-		    (!sk->sk_bound_dev_if || !dif ||
-		     sk->sk_bound_dev_if == dif))
-			goto found;
+		if (!net_eq(sock_net(sk), net))
+			continue;
+
+		if (sk->sk_bound_dev_if && dif && sk->sk_bound_dev_if != dif)
+			continue;
+
+		if (sk_laddr && !ipv6_addr_any(sk_laddr) &&
+		    !ipv6_addr_any(laddr) && !ipv6_addr_equal(sk_laddr, laddr))
+			continue;
+
+		if (!ipv6_addr_any(sk_raddr) && raddr &&
+		    !ipv6_addr_any(raddr) && !ipv6_addr_equal(sk_raddr, raddr))
+			continue;
+
+		if (l2tp->conn_id != tunnel_id)
+			continue;
+
+		goto found;
 	}
 
 	sk = NULL;
-- 
2.11.0
