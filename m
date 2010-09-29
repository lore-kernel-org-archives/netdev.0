From: Arnaud Ebalard <arno@natisbad.org>
Subject: [PATCHv3 net-next-2.6 2/5] XFRM,IPv6: Introduce receive sockopts to access IRO remapped src/dst addresses
Date: Wed, 29 Sep 2010 11:05:41 +0200
Message-ID: <6a4082ab12d691c521c3558ec0b51b48a60b42d8.1285749610.git.arno@natisbad.org>
References: <cover.1285749610.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:38525 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754157Ab0I2JEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 05:04:45 -0400
In-Reply-To: <cover.1285749610.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch introduces IRO recv sockopts, in order for userland processes
(e.g. UMIP) to access on-wire source or destination addresses found in
incoming (IPsec-protected) packets as they were before remapping by IRO.
The socket options are respectively IPV6_RECVIROSRC and IPV6_RECVIRODST.

Basically, the two recv socket options are similar in their purpose to
their generic RH2/HAO counterparts defined in RFC 3542 (IPV6_RECVIROSRC
<->  IPV6_RECVDSTOPTS, IPV6_RECVIRODST <-> IPV6_RECVRTHDR). They differ
on the following aspects:

 - IRO reporting sockopts only work on incoming IPsec-protected packets
   Userspace will never get IRO remapped address report for common
   (non protected) packets.
 - The receiver gets the original source/desination address (IRO
   remapping) from its IPsec stack.
 - as IRO sockopts only deal with addresses, no specific structure is
   defined, i.e. struct in6_addr is used to pass info.

As we only interact with IPsec protected packets, struct sec_path is
used to carry information (addresses) for incoming packets that have
undergone remapping process.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 include/linux/in6.h      |    7 +++++++
 include/linux/ipv6.h     |    4 +++-
 include/net/xfrm.h       |    5 +++++
 net/ipv6/datagram.c      |   18 ++++++++++++++++++
 net/ipv6/ipv6_sockglue.c |   26 ++++++++++++++++++++++++++
 5 files changed, 59 insertions(+), 1 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index c4bf46f..52a98ab 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -283,4 +283,11 @@ struct in6_flowlabel_req {
  * MRT6_PIM			208
  * (reserved)			209
  */
+
+/* IRO (IPsec Route Optimization) sockopts */
+#define IPV6_RECVIROSRC         74
+#define IPV6_IROSRC		75
+#define IPV6_RECVIRODST         76
+#define IPV6_IRODST		77
+
 #endif
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e62683b..55289ee 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -341,7 +341,9 @@ struct ipv6_pinfo {
 				odstopts:1,
                                 rxflow:1,
 				rxtclass:1,
-				rxpmtu:1;
+				rxpmtu:1,
+				irosrc:1,
+				irodst:1;
 		} bits;
 		__u16		all;
 	} rxopt;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4f53532..e6a753c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -909,6 +909,11 @@ struct sec_path {
 	atomic_t		refcnt;
 	int			len;
 	struct xfrm_state	*xvec[XFRM_MAX_DEPTH];
+
+#ifdef CONFIG_XFRM_SUB_POLICY
+	struct in6_addr         irosrc;
+	struct in6_addr         irodst;
+#endif
 };
 
 static inline struct sec_path *
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index ef371aa..2952c9e 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -29,6 +29,7 @@
 #include <net/transp_v6.h>
 #include <net/ip6_route.h>
 #include <net/tcp_states.h>
+#include <net/xfrm.h>
 
 #include <linux/errqueue.h>
 #include <asm/uaccess.h>
@@ -504,6 +505,23 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 		put_cmsg(msg, SOL_IPV6, IPV6_HOPOPTS, (ptr[1]+1)<<3, ptr);
 	}
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+	/* If access to IRO-remapped source or destination address has been
+	 * requested and it has indeed been remapped, provide the on-wire
+	 * address to userland */
+	if (skb_sec_path(skb)) {
+		struct sec_path *sp = skb_sec_path(skb);
+
+		if (np->rxopt.bits.irosrc && !ipv6_addr_any(&sp->irosrc))
+			put_cmsg(msg, SOL_IPV6, IPV6_IROSRC,
+				 sizeof(sp->irosrc), &sp->irosrc);
+
+		if (np->rxopt.bits.irodst && !ipv6_addr_any(&sp->irodst))
+			put_cmsg(msg, SOL_IPV6, IPV6_IRODST,
+				 sizeof(sp->irodst), &sp->irodst);
+	}
+#endif
+
 	if (opt->lastopt &&
 	    (np->rxopt.bits.dstopts || np->rxopt.bits.srcrt)) {
 		/*
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a7f66bc..722a49f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -302,6 +302,22 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = 0;
 		break;
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+	case IPV6_RECVIROSRC:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		np->rxopt.bits.irosrc = valbool;
+		retv = 0;
+		break;
+
+	case IPV6_RECVIRODST:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		np->rxopt.bits.irodst = valbool;
+		retv = 0;
+		break;
+#endif
+
 	case IPV6_2292DSTOPTS:
 		if (optlen < sizeof(int))
 			goto e_inval;
@@ -1056,6 +1072,16 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->rxopt.bits.dstopts;
 		break;
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+	case IPV6_RECVIROSRC:
+		val = np->rxopt.bits.irosrc;
+		break;
+
+	case IPV6_RECVIRODST:
+		val = np->rxopt.bits.irodst;
+		break;
+#endif
+
 	case IPV6_2292DSTOPTS:
 		val = np->rxopt.bits.odstopts;
 		break;
-- 
1.7.1


