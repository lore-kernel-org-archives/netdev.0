From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 08/13] TProxy: added tproxy sockopt interface in the IPV6
 layer
Date: Sat, 12 Sep 2009 10:53:01 +0200
Message-ID: <1253548005.12519.8.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support for IPV6_RECVORIGDSTADDR sockopt for UDP sockets were contributed by
Harry Mason.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 include/linux/in6.h      |    5 +++++
 include/linux/ipv6.h     |    4 +++-
 net/ipv6/datagram.c      |   19 +++++++++++++++++++
 net/ipv6/ipv6_sockglue.c |   22 ++++++++++++++++++++++
 4 files changed, 49 insertions(+), 1 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 718bf21..1bfaac8 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -268,6 +268,11 @@ struct in6_flowlabel_req
 #define IPV6_PREFER_SRC_CGA		0x0008
 #define IPV6_PREFER_SRC_NONCGA		0x0800
 
+#define IPV6_ORIGDSTADDR        73
+#define IPV6_RECVORIGDSTADDR    IPV6_ORIGDSTADDR
+#define IPV6_TRANSPARENT        74
+
+
 /*
  * Multicast Routing:
  * see include/linux/mroute6.h.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index be4c9c6..6d71614 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -333,7 +333,9 @@ struct ipv6_pinfo {
 				dstopts:1,
 				odstopts:1,
                                 rxflow:1,
-				rxtclass:1;
+				rxtclass:1,
+				rxorigdstaddr:1;
+				/* 3 bits hole */
 		} bits;
 		__u16		all;
 	} rxopt;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index e2bdc6d..fec931a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -492,6 +492,25 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
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
index a7fdf9a..0f70cd1 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -333,6 +333,20 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = 0;
 		break;
 
+	case IPV6_TRANSPARENT:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		/* we don't have a separate transparent bit for IPV6 we use the one in the IPv4 socket */
+		inet_sk(sk)->transparent = valbool;
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
@@ -1049,6 +1063,14 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->rxopt.bits.rxflow;
 		break;
 
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
1.6.0.4

