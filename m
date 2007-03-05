From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 06/13] Implement IP_TRANSPARENT socket option
Date: Mon, 05 Mar 2007 16:45:51 +0100
Message-ID: <20070305154551.3471.97713.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:3587 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933540AbXCEPpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:45:53 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 29754294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:45:52 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the IP_TRANSPARENT socket option: enabling that will make
the IPv4 routing omit the non-local source address check on output. Setting
IP_TRANSPARENT requires NET_ADMIN capability.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/linux/in.h               |    1 +
 include/net/inet_sock.h          |    3 ++-
 include/net/inet_timewait_sock.h |    3 ++-
 include/net/route.h              |    1 +
 net/ipv4/inet_timewait_sock.c    |    1 +
 net/ipv4/ip_sockglue.c           |   12 +++++++++++-
 6 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 1912e7c..66be615 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -75,6 +75,7 @@ struct in_addr {
 #define IP_IPSEC_POLICY	16
 #define IP_XFRM_POLICY	17
 #define IP_PASSSEC	18
+#define IP_TRANSPARENT	19
 
 /* BSD compatibility */
 #define IP_RECVRETOPTS	IP_RETOPTS
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 0bd167b..14b597d 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -128,7 +128,8 @@ struct inet_sock {
 				is_icsk:1,
 				freebind:1,
 				hdrincl:1,
-				mc_loop:1;
+				mc_loop:1,
+				transparent:1;
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist	*mc_list;
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index f7be1ac..e30dd61 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -126,7 +126,8 @@ struct inet_timewait_sock {
 	__be16			tw_dport;
 	__u16			tw_num;
 	/* And these are ours. */
-	__u8			tw_ipv6only:1;
+	__u8			tw_ipv6only:1,
+				tw_transparent:1;
 	/* 15 bits hole, try to pack */
 	__u16			tw_ipv6_offset;
 	int			tw_timeout;
diff --git a/include/net/route.h b/include/net/route.h
index efaa6b2..13da592 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -27,6 +27,7 @@
 #include <net/dst.h>
 #include <net/inetpeer.h>
 #include <net/flow.h>
+#include <net/inet_sock.h>
 #include <linux/in_route.h>
 #include <linux/rtnetlink.h>
 #include <linux/route.h>
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index a73cf93..f57f81a 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -108,6 +108,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_reuse	    = sk->sk_reuse;
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
+		tw->tw_transparent  = inet->transparent;
 		tw->tw_prot	    = sk->sk_prot_creator;
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 23048d9..02e8d9f 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -414,7 +414,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			    (1<<IP_TTL) | (1<<IP_HDRINCL) |
 			    (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
 			    (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
-			    (1<<IP_PASSSEC))) ||
+			    (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT))) ||
 				optname == IP_MULTICAST_TTL ||
 				optname == IP_MULTICAST_LOOP) {
 		if (optlen >= sizeof(int)) {
@@ -875,6 +875,16 @@ mc_msf_out:
 			err = xfrm_user_policy(sk, optname, optval, optlen);
 			break;
 
+		case IP_TRANSPARENT:
+			if (!capable(CAP_NET_ADMIN)) {
+				err = -EPERM;
+				break;
+			}
+			if (optlen < 1)
+				goto e_inval;
+			inet->transparent = !!val;
+			break;
+
 		default:
 			err = -ENOPROTOOPT;
 			break;

