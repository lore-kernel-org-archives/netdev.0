From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] net: ipv6: Introduce ip6_sk_dst_hoplimit.
Date: Mon, 28 Apr 2014 15:28:38 +0900
Message-ID: <1398666518-7715-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64520 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbaD1G27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 02:28:59 -0400
Received: by mail-pd0-f179.google.com with SMTP id y10so398814pdj.10
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2014 23:28:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a minor simplification: it replaces a few identical code
snippets with a call to a static inline function.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/addrconf.h   |  5 -----
 include/net/ipv6.h       | 18 ++++++++++++++++++
 net/ipv6/icmp.c          | 14 ++------------
 net/ipv6/ip6_flowlabel.c |  1 -
 net/ipv6/ping.c          |  7 +------
 net/ipv6/raw.c           | 10 ++--------
 net/ipv6/udp.c           | 10 ++--------
 net/l2tp/l2tp_ip6.c      | 10 ++--------
 8 files changed, 27 insertions(+), 48 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 933a9f2..f679877 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -306,11 +306,6 @@ static inline void addrconf_addr_solict_mult(const struct in6_addr *addr,
 		      htonl(0xFF000000) | addr->s6_addr32[3]);
 }
 
-static inline bool ipv6_addr_is_multicast(const struct in6_addr *addr)
-{
-	return (addr->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000);
-}
-
 static inline bool ipv6_addr_is_ll_all_nodes(const struct in6_addr *addr)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d640925..c1a48a1 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -583,6 +583,11 @@ static inline bool ipv6_addr_orchid(const struct in6_addr *a)
 	return (a->s6_addr32[0] & htonl(0xfffffff0)) == htonl(0x20010010);
 }
 
+static inline bool ipv6_addr_is_multicast(const struct in6_addr *addr)
+{
+	return (addr->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000);
+}
+
 static inline void ipv6_addr_set_v4mapped(const __be32 addr,
 					  struct in6_addr *v4mapped)
 {
@@ -664,6 +669,19 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
 
 int ip6_dst_hoplimit(struct dst_entry *dst);
 
+static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
+				      struct dst_entry *dst)
+{
+	int hlimit;
+	if (ipv6_addr_is_multicast(&fl6->daddr))
+		hlimit = np->mcast_hops;
+	else
+		hlimit = np->hop_limit;
+	if (hlimit < 0)
+		hlimit = ip6_dst_hoplimit(dst);
+	return hlimit;
+}
+
 /*
  *	Header manipulation
  */
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 7b32652..3b0905b 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -493,12 +493,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	if (IS_ERR(dst))
 		goto out;
 
-	if (ipv6_addr_is_multicast(&fl6.daddr))
-		hlimit = np->mcast_hops;
-	else
-		hlimit = np->hop_limit;
-	if (hlimit < 0)
-		hlimit = ip6_dst_hoplimit(dst);
+	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
 	msg.skb = skb;
 	msg.offset = skb_network_offset(skb);
@@ -593,12 +588,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	if (IS_ERR(dst))
 		goto out;
 
-	if (ipv6_addr_is_multicast(&fl6.daddr))
-		hlimit = np->mcast_hops;
-	else
-		hlimit = np->hop_limit;
-	if (hlimit < 0)
-		hlimit = ip6_dst_hoplimit(dst);
+	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
 	idev = __in6_dev_get(skb->dev);
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 0961b5e..4052694 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -26,7 +26,6 @@
 #include <net/sock.h>
 
 #include <net/ipv6.h>
-#include <net/addrconf.h>
 #include <net/rawv6.h>
 #include <net/transp_v6.h>
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index bda7429..a2a1d80 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -168,12 +168,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	pfh.wcheck = 0;
 	pfh.family = AF_INET6;
 
-	if (ipv6_addr_is_multicast(&fl6.daddr))
-		hlimit = np->mcast_hops;
-	else
-		hlimit = np->hop_limit;
-	if (hlimit < 0)
-		hlimit = ip6_dst_hoplimit(dst);
+	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
 	lock_sock(sk);
 	err = ip6_append_data(sk, ping_getfrag, &pfh, len,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 1f29996..dddfb5f 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -873,14 +873,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		err = PTR_ERR(dst);
 		goto out;
 	}
-	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl6.daddr))
-			hlimit = np->mcast_hops;
-		else
-			hlimit = np->hop_limit;
-		if (hlimit < 0)
-			hlimit = ip6_dst_hoplimit(dst);
-	}
+	if (hlimit < 0)
+		hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
 	if (tclass < 0)
 		tclass = np->tclass;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e586d9..d8d6ca0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1232,14 +1232,8 @@ do_udp_sendmsg:
 		goto out;
 	}
 
-	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl6.daddr))
-			hlimit = np->mcast_hops;
-		else
-			hlimit = np->hop_limit;
-		if (hlimit < 0)
-			hlimit = ip6_dst_hoplimit(dst);
-	}
+	if (hlimit < 0)
+		hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
 	if (tclass < 0)
 		tclass = np->tclass;
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 7704ea9..6f29b67 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -605,14 +605,8 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		goto out;
 	}
 
-	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl6.daddr))
-			hlimit = np->mcast_hops;
-		else
-			hlimit = np->hop_limit;
-		if (hlimit < 0)
-			hlimit = ip6_dst_hoplimit(dst);
-	}
+	if (hlimit < 0)
+	        hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
 	if (tclass < 0)
 		tclass = np->tclass;
-- 
1.9.1.423.g4596e3a
