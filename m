From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 3/5] ipv6: remove rcv_tclass of ipv6_pinfo
Date: Sun,  8 Dec 2013 15:46:59 +0100
Message-ID: <1386514021-11646-3-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:57311 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759182Ab3LHOrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 09:47:13 -0500
In-Reply-To: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tclass information in now already stored in rcv_flowinfo
We do not need to store the same information twice.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/linux/ipv6.h     | 1 -
 net/ipv6/ipv6_sockglue.c | 2 +-
 net/ipv6/tcp_ipv6.c      | 6 +-----
 3 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 6ba19dd..ecd9152 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -199,7 +199,6 @@ struct ipv6_pinfo {
 				dontfrag:1;
 	__u8			min_hopcount;
 	__u8			tclass;
-	__u8			rcv_tclass;
 	__be32			rcv_flowinfo;
 
 	__u32			dst_cookie;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index c2db1df..7d93915 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1019,7 +1019,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 				put_cmsg(&msg, SOL_IPV6, IPV6_HOPLIMIT, sizeof(hlim), &hlim);
 			}
 			if (np->rxopt.bits.rxtclass) {
-				int tclass = np->rcv_tclass;
+				int tclass = ntohl(np->rcv_flowinfo & IPV6_TCLASS_MASK) >> 20;
 				put_cmsg(&msg, SOL_IPV6, IPV6_TCLASS, sizeof(tclass), &tclass);
 			}
 			if (np->rxopt.bits.rxoinfo) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 79a1963..bd91e7f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1135,7 +1135,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newnp->opt	   = NULL;
 		newnp->mcast_oif   = inet6_iif(skb);
 		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
-		newnp->rcv_tclass  = ipv6_get_dsfield(ipv6_hdr(skb));
 		newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
 
 		/*
@@ -1216,7 +1215,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newnp->opt	  = NULL;
 	newnp->mcast_oif  = inet6_iif(skb);
 	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
-	newnp->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));
 	newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
 
 	/* Clone native IPv6 options from listening socket (if any)
@@ -1427,9 +1425,7 @@ ipv6_pktoptions:
 			np->mcast_oif = inet6_iif(opt_skb);
 		if (np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim)
 			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
-		if (np->rxopt.bits.rxtclass)
-			np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(opt_skb));
-		if (np->rxopt.bits.rxflow)
+		if (np->rxopt.bits.rxflow || np->rxopt.bits.rxtclass)
 			np->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(opt_skb));
 		if (ipv6_opt_accepted(sk, opt_skb)) {
 			skb_set_owner_r(opt_skb, sk);
-- 
1.8.4.3
