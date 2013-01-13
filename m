From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6: Use ipv6_get_dsfield() instead of ipv6_tclass().
Date: Sun, 13 Jan 2013 17:32:13 +0900
Message-ID: <50F2710D.4030005@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:37815 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752013Ab3AMIcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 03:32:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7a3198a8 ("ipv6: helper function to get tclass") introduced
ipv6_tclass(), but similar function is already available as
ipv6_get_dsfield().

We might be able to call ipv6_tclass() from ipv6_get_dsfield(),
but it is confusing to have two versions.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/ipv6.h |    5 -----
 net/ipv6/datagram.c  |    3 ++-
 net/ipv6/tcp_ipv6.c  |    6 +++---
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index faed1e3..304a9f4 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -77,11 +77,6 @@ static inline struct ipv6hdr *ipipv6_hdr(const struct sk_buff *skb)
 	return (struct ipv6hdr *)skb_transport_header(skb);
 }
 
-static inline __u8 ipv6_tclass(const struct ipv6hdr *iph)
-{
-	return (ntohl(*(__be32 *)iph) >> 20) & 0xff;
-}
-
 /* 
    This structure contains results of exthdrs parsing
    as offsets from skb->nh.
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 56b692b..633ac55 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -30,6 +30,7 @@
 #include <net/transp_v6.h>
 #include <net/ip6_route.h>
 #include <net/tcp_states.h>
+#include <net/dsfield.h>
 
 #include <linux/errqueue.h>
 #include <asm/uaccess.h>
@@ -487,7 +488,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 	}
 
 	if (np->rxopt.bits.rxtclass) {
-		int tclass = ipv6_tclass(ipv6_hdr(skb));
+		int tclass = ipv6_get_dsfield(ipv6_hdr(skb));
 		put_cmsg(msg, SOL_IPV6, IPV6_TCLASS, sizeof(tclass), &tclass);
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3164ad2..3701c3c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1163,7 +1163,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newnp->opt	   = NULL;
 		newnp->mcast_oif   = inet6_iif(skb);
 		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
-		newnp->rcv_tclass  = ipv6_tclass(ipv6_hdr(skb));
+		newnp->rcv_tclass  = ipv6_get_dsfield(ipv6_hdr(skb));
 
 		/*
 		 * No need to charge this sock to the relevant IPv6 refcnt debug socks count
@@ -1243,7 +1243,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newnp->opt	  = NULL;
 	newnp->mcast_oif  = inet6_iif(skb);
 	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
-	newnp->rcv_tclass = ipv6_tclass(ipv6_hdr(skb));
+	newnp->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));
 
 	/* Clone native IPv6 options from listening socket (if any)
 
@@ -1456,7 +1456,7 @@ ipv6_pktoptions:
 		if (np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim)
 			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
 		if (np->rxopt.bits.rxtclass)
-			np->rcv_tclass = ipv6_tclass(ipv6_hdr(skb));
+			np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));
 		if (ipv6_opt_accepted(sk, opt_skb)) {
 			skb_set_owner_r(opt_skb, sk);
 			opt_skb = xchg(&np->pktoptions, opt_skb);
-- 
1.7.9.5
