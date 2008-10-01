From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 02/16] Implement IP_TRANSPARENT socket option
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.69747.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the IP_TRANSPARENT socket option: enabling that will make
the IPv4 routing omit the non-local source address check on output. Setting
IP_TRANSPARENT requires NET_ADMIN capability.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/linux/in.h               |    1 +
 include/net/inet_sock.h          |    3 ++-
 include/net/inet_timewait_sock.h |    3 ++-
 net/ipv4/inet_timewait_sock.c    |    1 +
 net/ipv4/ip_sockglue.c           |   15 ++++++++++++++-
 5 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 4065313..db458be 100644
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
index 643e26b..e97b66e 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -129,7 +129,8 @@ struct inet_sock {
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
index 9132490..80e4977 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -128,7 +128,8 @@ struct inet_timewait_sock {
 	__be16			tw_dport;
 	__u16			tw_num;
 	/* And these are ours. */
-	__u8			tw_ipv6only:1;
+	__u8			tw_ipv6only:1,
+				tw_transparent:1;
 	/* 15 bits hole, try to pack */
 	__u16			tw_ipv6_offset;
 	unsigned long		tw_ttd;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 743f011..1c5fd38 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -126,6 +126,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_reuse	    = sk->sk_reuse;
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
+		tw->tw_transparent  = inet->transparent;
 		tw->tw_prot	    = sk->sk_prot_creator;
 		twsk_net_set(tw, hold_net(sock_net(sk)));
 		atomic_set(&tw->tw_refcnt, 1);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 105d92a..465abf0 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -419,7 +419,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			     (1<<IP_TTL) | (1<<IP_HDRINCL) |
 			     (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
-			     (1<<IP_PASSSEC))) ||
+			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT))) ||
 	    optname == IP_MULTICAST_TTL ||
 	    optname == IP_MULTICAST_LOOP) {
 		if (optlen >= sizeof(int)) {
@@ -878,6 +878,16 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		err = xfrm_user_policy(sk, optname, optval, optlen);
 		break;
 
+	case IP_TRANSPARENT:
+		if (!capable(CAP_NET_ADMIN)) {
+			err = -EPERM;
+			break;
+		}
+		if (optlen < 1)
+			goto e_inval;
+		inet->transparent = !!val;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -1130,6 +1140,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_FREEBIND:
 		val = inet->freebind;
 		break;
+	case IP_TRANSPARENT:
+		val = inet->transparent;
+		break;
 	default:
 		release_sock(sk);
 		return -ENOPROTOOPT;


