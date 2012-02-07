From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: [PATCH v4 2/2] Implement IPV6_UNICAST_IF socket option.
Date: Mon,  6 Feb 2012 22:01:16 -0700
Message-ID: <1328590876-15980-2-git-send-email-ehoover@mines.edu>
Cc: "Erich E. Hoover" <ehoover@mines.edu>
To: Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:54346 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966Ab2BGFCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 00:02:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The IPV6_UNICAST_IF feature is the IPv6 compliment to IP_UNICAST_IF.

Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
---
 include/linux/in6.h      |    1 +
 include/linux/ipv6.h     |    1 +
 net/ipv6/af_inet6.c      |    1 +
 net/ipv6/icmp.c          |    4 ++++
 net/ipv6/ipv6_sockglue.c |   34 ++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c           |    2 ++
 net/ipv6/udp.c           |    3 +++
 7 files changed, 46 insertions(+), 0 deletions(-)

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
index 6318268..743a16a 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -324,6 +324,7 @@ struct ipv6_pinfo {
 				__unused_2:6;
 	__s16			mcast_hops:9;
 #endif
+	int			ucast_oif;
 	int			mcast_oif;
 
 	/* pktoption flags */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7f51915..2345922 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -199,6 +199,7 @@ lookup_protocol:
 	sk->sk_backlog_rcv	= answer->prot->backlog_rcv;
 
 	inet_sk(sk)->pinet6 = np = inet6_sk_generic(sk);
+	np->ucast_oif	= 0;
 	np->hop_limit	= -1;
 	np->mcast_hops	= IPV6_DEFAULT_MCASTHOPS;
 	np->mc_loop	= 1;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 01d46bf..af88934 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -468,6 +468,8 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
 		fl6.flowi6_oif = np->mcast_oif;
+	else if (!fl6.flowi6_oif)
+		fl6.flowi6_oif = np->ucast_oif;
 
 	dst = icmpv6_route_lookup(net, skb, sk, &fl6);
 	if (IS_ERR(dst))
@@ -553,6 +555,8 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
 		fl6.flowi6_oif = np->mcast_oif;
+	else if (!fl6.flowi6_oif)
+		fl6.flowi6_oif = np->ucast_oif;
 
 	err = ip6_dst_lookup(sk, &dst, &fl6);
 	if (err)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 18a2719..6d6b65f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -516,6 +516,36 @@ done:
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
+			np->ucast_oif = 0;
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
+		if (sk->sk_bound_dev_if)
+			break;
+
+		np->ucast_oif = ifindex;
+		retv = 0;
+		break;
+	}
+
 	case IPV6_MULTICAST_IF:
 		if (sk->sk_type == SOCK_STREAM)
 			break;
@@ -1160,6 +1190,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->mcast_oif;
 		break;
 
+	case IPV6_UNICAST_IF:
+		val = (__force int)htonl((__u32) np->ucast_oif);
+		break;
+
 	case IPV6_MTU_DISCOVER:
 		val = np->pmtudisc;
 		break;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d02f7e4..5bddea7 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -856,6 +856,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
 		fl6.flowi6_oif = np->mcast_oif;
+	else if (!fl6.flowi6_oif)
+		fl6.flowi6_oif = np->ucast_oif;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, true);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4f96b5c..ec2c4ae 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1130,6 +1130,9 @@ do_udp_sendmsg:
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr)) {
 		fl6.flowi6_oif = np->mcast_oif;
 		connected = 0;
+	} else if (!fl6.flowi6_oif) {
+		fl6.flowi6_oif = np->ucast_oif;
+		connected = 0;
 	}
 
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
-- 
1.7.5.4
