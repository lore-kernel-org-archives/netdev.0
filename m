From: kaber@trash.net
Subject: [PATCH 62/72] tproxy: added tproxy sockopt interface in the IPV6 layer
Date: Thu, 21 Oct 2010 17:19:49 +0200
Message-ID: <1287674399-31455-63-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

Support for IPV6_RECVORIGDSTADDR sockopt for UDP sockets were contributed by
Harry Mason.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/in6.h      |    4 ++++
 include/linux/ipv6.h     |    4 +++-
 net/ipv6/datagram.c      |   19 +++++++++++++++++++
 net/ipv6/ipv6_sockglue.c |   23 +++++++++++++++++++++++
 4 files changed, 49 insertions(+), 1 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index c4bf46f..097a34b 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -268,6 +268,10 @@ struct in6_flowlabel_req {
 /* RFC5082: Generalized Ttl Security Mechanism */
 #define IPV6_MINHOPCOUNT		73
 
+#define IPV6_ORIGDSTADDR        74
+#define IPV6_RECVORIGDSTADDR    IPV6_ORIGDSTADDR
+#define IPV6_TRANSPARENT        75
+
 /*
  * Multicast Routing:
  * see include/linux/mroute6.h.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e62683b..8e429d0 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -341,7 +341,9 @@ struct ipv6_pinfo {
 				odstopts:1,
                                 rxflow:1,
 				rxtclass:1,
-				rxpmtu:1;
+				rxpmtu:1,
+				rxorigdstaddr:1;
+				/* 2 bits hole */
 		} bits;
 		__u16		all;
 	} rxopt;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index ef371aa..320bdb8 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -577,6 +577,25 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 		u8 *ptr = nh + opt->dst1;
 		put_cmsg(msg, SOL_IPV6, IPV6_2292DSTOPTS, (ptr[1]+1)<<3, ptr);
 	}
+	if (np->rxopt.bits.rxorigdstaddr) {
+		struct sockaddr_in6 sin6;
+		u16 *ports = (u16 *) skb_transport_header(skb);
+
+		if (skb_transport_offset(skb) + 4 <= skb->len) {
+			/* All current transport protocols have the port numbers in the
+			 * first four bytes of the transport header and this function is
+			 * written with this assumption in mind.
+			 */
+
+			sin6.sin6_family = AF_INET6;
+			ipv6_addr_copy(&sin6.sin6_addr, &ipv6_hdr(skb)->daddr);
+			sin6.sin6_port = ports[1];
+			sin6.sin6_flowinfo = 0;
+			sin6.sin6_scope_id = 0;
+
+			put_cmsg(msg, SOL_IPV6, IPV6_ORIGDSTADDR, sizeof(sin6), &sin6);
+		}
+	}
 	return 0;
 }
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a7f66bc..0553867 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -342,6 +342,21 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = 0;
 		break;
 
+	case IPV6_TRANSPARENT:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		/* we don't have a separate transparent bit for IPV6 we use the one in the IPv4 socket */
+		inet_sk(sk)->transparent = valbool;
+		retv = 0;
+		break;
+
+	case IPV6_RECVORIGDSTADDR:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		np->rxopt.bits.rxorigdstaddr = valbool;
+		retv = 0;
+		break;
+
 	case IPV6_HOPOPTS:
 	case IPV6_RTHDRDSTOPTS:
 	case IPV6_RTHDR:
@@ -1104,6 +1119,14 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		break;
 	}
 
+	case IPV6_TRANSPARENT:
+		val = inet_sk(sk)->transparent;
+		break;
+
+	case IPV6_RECVORIGDSTADDR:
+		val = np->rxopt.bits.rxorigdstaddr;
+		break;
+
 	case IPV6_UNICAST_HOPS:
 	case IPV6_MULTICAST_HOPS:
 	{
-- 
1.7.1

