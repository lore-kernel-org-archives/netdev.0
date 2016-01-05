From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] udp_diag: fix udp_dump_one() vs SO_REUSEPORT
Date: Tue, 05 Jan 2016 14:33:28 -0800
Message-ID: <1452033208.8255.140.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
	 <1452031738.8255.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1452032534.8255.137.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:32779 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbcAEWd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 17:33:29 -0500
Received: by mail-pf0-f181.google.com with SMTP id q63so191209686pfb.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 14:33:29 -0800 (PST)
In-Reply-To: <1452032534.8255.137.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

udp_dump_one() uses __udp4_lib_lookup() & __udp6_lib_lookup()
which cannot properly handle the provided cookie when SO_REUSEPORT
is used, as many sockets share the same 4-tuple

Instead, let's use the provided 64bit cookie to uniquely identify
the socket.

This will allow us to remove a check against skb being NULL in
reuseport_select_sock(), as we no longer share __udp4_lib_lookup() &
__udp6_lib_lookup() with packet processing path.

We no longer need to export these two functions, and udp_diag IPv6
dependency can be removed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/udp.h   |    8 -------
 net/ipv4/Kconfig    |    2 -
 net/ipv4/udp.c      |    8 +++----
 net/ipv4/udp_diag.c |   44 ++++++++++++++++++------------------------
 net/ipv6/udp.c      |    3 --
 5 files changed, 25 insertions(+), 40 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 2842541e28e7..1e3bcadc2169 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -256,18 +256,10 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 		       int (*push_pending_frames)(struct sock *));
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif);
-struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
-			       __be32 daddr, __be16 dport, int dif,
-			       struct udp_table *tbl, struct sk_buff *skb);
 struct sock *udp6_lib_lookup(struct net *net,
 			     const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport,
 			     int dif);
-struct sock *__udp6_lib_lookup(struct net *net,
-			       const struct in6_addr *saddr, __be16 sport,
-			       const struct in6_addr *daddr, __be16 dport,
-			       int dif, struct udp_table *tbl,
-			       struct sk_buff *skb);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index c22920525e5d..ff9b81ff733a 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -430,7 +430,7 @@ config INET_TCP_DIAG
 
 config INET_UDP_DIAG
 	tristate "UDP: socket monitoring interface"
-	depends on INET_DIAG && (IPV6 || IPV6=n)
+	depends on INET_DIAG
 	default n
 	---help---
 	  Support for UDP socket monitoring interface used by the ss tool.
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 835378365f25..6f58a9d86f41 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -551,9 +551,10 @@ found:
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
-		__be16 sport, __be32 daddr, __be16 dport,
-		int dif, struct udp_table *udptable, struct sk_buff *skb)
+static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+				      __be16 sport, __be32 daddr, __be16 dport,
+				      int dif, struct udp_table *udptable,
+				      struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -638,7 +639,6 @@ found:
 	rcu_read_unlock();
 	return result;
 }
-EXPORT_SYMBOL_GPL(__udp4_lib_lookup);
 
 static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 __be16 sport, __be16 dport,
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index df1966f3b6ec..09d0e1cffeb4 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -35,36 +35,30 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 			const struct nlmsghdr *nlh,
 			const struct inet_diag_req_v2 *req)
 {
-	int err = -EINVAL;
-	struct sock *sk;
+	struct sock *aux, *sk = NULL;
 	struct sk_buff *rep;
 	struct net *net = sock_net(in_skb->sk);
-
-	if (req->sdiag_family == AF_INET)
-		sk = __udp4_lib_lookup(net,
-				req->id.idiag_src[0], req->id.idiag_sport,
-				req->id.idiag_dst[0], req->id.idiag_dport,
-				req->id.idiag_if, tbl, NULL);
-#if IS_ENABLED(CONFIG_IPV6)
-	else if (req->sdiag_family == AF_INET6)
-		sk = __udp6_lib_lookup(net,
-				(struct in6_addr *)req->id.idiag_src,
-				req->id.idiag_sport,
-				(struct in6_addr *)req->id.idiag_dst,
-				req->id.idiag_dport,
-				req->id.idiag_if, tbl, NULL);
-#endif
-	else
-		goto out_nosk;
-
-	err = -ENOENT;
+	unsigned short hnum = ntohs(req->id.idiag_dport);
+	unsigned int slot = udp_hashfn(net, hnum, tbl->mask);
+	struct udp_hslot *hslot = &tbl->hash[slot];
+	struct hlist_nulls_node *node;
+	int err = -ENOENT;
+
+	spin_lock_bh(&hslot->lock);
+	sk_nulls_for_each(aux, node, &hslot->head) {
+		if (net_eq(sock_net(aux), net) &&
+		    !sock_diag_check_cookie(aux, req->id.idiag_cookie) &&
+		    (req->sdiag_family == AF_UNSPEC ||
+		     req->sdiag_family == aux->sk_family)) {
+			sk = aux;
+			sock_hold(sk);
+			break;
+		}
+	}
+	spin_unlock_bh(&hslot->lock);
 	if (!sk)
 		goto out_nosk;
 
-	err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
-	if (err)
-		goto out;
-
 	err = -ENOMEM;
 	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
 			sizeof(struct inet_diag_meminfo) + 64,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 56fcb55fda31..83bfd64cf37b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -307,7 +307,7 @@ found:
 	return result;
 }
 
-struct sock *__udp6_lib_lookup(struct net *net,
+static struct sock *__udp6_lib_lookup(struct net *net,
 				      const struct in6_addr *saddr, __be16 sport,
 				      const struct in6_addr *daddr, __be16 dport,
 				      int dif, struct udp_table *udptable,
@@ -395,7 +395,6 @@ found:
 	rcu_read_unlock();
 	return result;
 }
-EXPORT_SYMBOL_GPL(__udp6_lib_lookup);
 
 static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 					  __be16 sport, __be16 dport,
