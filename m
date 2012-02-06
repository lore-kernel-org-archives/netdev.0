From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: [PATCH v3 2/2] Implement IPV6_UNICAST_IF socket option.
Date: Mon,  6 Feb 2012 10:57:44 -0700
Message-ID: <1328551064-28573-2-git-send-email-ehoover@mines.edu>
Cc: "Erich E. Hoover" <ehoover@mines.edu>
To: Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:52983 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753743Ab2BFR6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 12:58:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The IPV6_UNICAST_IF feature is the IPv6 compliment to IP_UNICAST_IF.

Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
---
 include/linux/in6.h      |    1 +
 include/linux/ipv6.h     |    2 +
 include/net/ipv6.h       |    2 +
 net/ipv6/af_inet6.c      |    1 +
 net/ipv6/icmp.c          |    3 ++
 net/ipv6/ipv6_sockglue.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c           |    2 +-
 net/ipv6/udp.c           |    2 +-
 8 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 097a34b..a67d76e 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -163,6 +163,7 @@ struct in6_flowlabel_req {
 #define IPV6_NEXTHOP		9
 #define IPV6_AUTHHDR		10	/* obsolete */
 #define IPV6_FLOWINFO		11
+#define IPV6_UNICAST_IF		12
 
 #define IPV6_UNICAST_HOPS	16
 #define IPV6_MULTICAST_IF	17
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 6318268..1602fb0 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -299,6 +299,8 @@ struct ipv6_pinfo {
 	struct in6_addr		*saddr_cache;
 #endif
 
+	int			outif_index;
+
 	__be32			flow_label;
 	__u32			frag_size;
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e4170a2..252677c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -254,6 +254,8 @@ static inline void fl6_sock_release(struct ip6_flowlabel *fl)
 
 extern int 			ip6_ra_control(struct sock *sk, int sel);
 
+extern int 			ipv6_default_ifindex(const struct sock *sk);
+
 extern int			ipv6_parse_hopopts(struct sk_buff *skb);
 
 extern struct ipv6_txoptions *  ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 13b84bc..d9ac287 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -199,6 +199,7 @@ lookup_protocol:
 	sk->sk_backlog_rcv	= answer->prot->backlog_rcv;
 
 	inet_sk(sk)->pinet6 = np = inet6_sk_generic(sk);
+	np->outif_index = 0;
 	np->hop_limit	= -1;
 	np->mcast_hops	= IPV6_DEFAULT_MCASTHOPS;
 	np->mc_loop	= 1;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 01d46bf..18f144e 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -551,6 +551,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 		return;
 	np = inet6_sk(sk);
 
+	if (!fl6.flowi6_oif)
+		fl6.flowi6_oif = ipv6_default_ifindex(sk);
+
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
 		fl6.flowi6_oif = np->mcast_oif;
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 18a2719..7248f5a 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -98,6 +98,21 @@ int ip6_ra_control(struct sock *sk, int sel)
 	return 0;
 }
 
+int ipv6_default_ifindex(const struct sock *sk)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	int ifindex = sk->sk_bound_dev_if;
+
+	/*
+         * If not bound to a specific interface then set the outgoing interface
+	 * to the value from the IPV6_UNICAST_IF socket option.
+         */
+	if (!ifindex)
+		ifindex = np->outif_index;
+
+	return ifindex;
+}
+
 static
 struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 					   struct ipv6_txoptions *opt)
@@ -516,6 +531,36 @@ done:
 		retv = 0;
 		break;
 
+	case IPV6_UNICAST_IF:
+	{
+		struct net_device *dev = NULL;
+		int ifindex;
+
+		if (optlen != sizeof(int))
+			goto e_inval;
+
+		ifindex = (__force int)ntohl((__force __be32)val);
+		if (ifindex == 0) {
+			np->outif_index = 0;
+			retv = 0;
+			break;
+		}
+
+		dev = dev_get_by_index(net, ifindex);
+		retv = -EADDRNOTAVAIL;
+		if (!dev)
+			break;
+		dev_put(dev);
+
+		retv = -EINVAL;
+		if (sk->sk_bound_dev_if && ifindex != sk->sk_bound_dev_if)
+			break;
+
+		np->outif_index = ifindex;
+		retv = 0;
+		break;
+	}
+
 	case IPV6_MULTICAST_IF:
 		if (sk->sk_type == SOCK_STREAM)
 			break;
@@ -1160,6 +1205,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->mcast_oif;
 		break;
 
+	case IPV6_UNICAST_IF:
+		val = (__force int)htonl((__u32) np->outif_index);
+		break;
+
 	case IPV6_MTU_DISCOVER:
 		val = np->pmtudisc;
 		break;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d02f7e4..25539a1 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -813,7 +813,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	if (fl6.flowi6_oif == 0)
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
+		fl6.flowi6_oif = ipv6_default_ifindex(sk);
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4f96b5c..bb8db62 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1081,7 +1081,7 @@ do_udp_sendmsg:
 	}
 
 	if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
+		fl6.flowi6_oif = ipv6_default_ifindex(sk);
 
 	if (!fl6.flowi6_oif)
 		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
-- 
1.7.5.4
