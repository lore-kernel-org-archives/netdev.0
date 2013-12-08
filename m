From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 1/5] ipv6: add flowinfo for tcp6 pkt_options for all cases
Date: Sun,  8 Dec 2013 15:46:57 +0100
Message-ID: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:57307 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756025Ab3LHOrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 09:47:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation of IPV6_FLOWINFO only gives a
result if pktoptions is available (thanks to the
ip6_datagram_recv_ctl function).
It gives inconsistent results to user space, sometimes
there is a result for getsockopt(IPV6_FLOWINFO), sometimes
not.

This patch add rcv_flowinfo to store it, and return it to
the userspace in the same way than other pkt_options.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/linux/ipv6.h     | 1 +
 net/ipv6/ipv6_sockglue.c | 4 ++++
 net/ipv6/tcp_ipv6.c      | 4 ++++
 3 files changed, 9 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 5d89d1b..6ba19dd 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -200,6 +200,7 @@ struct ipv6_pinfo {
 	__u8			min_hopcount;
 	__u8			tclass;
 	__u8			rcv_tclass;
+	__be32			rcv_flowinfo;
 
 	__u32			dst_cookie;
 	__u32			rx_dst_cookie;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 1c6ce31..c2db1df 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1034,6 +1034,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 				int hlim = np->mcast_hops;
 				put_cmsg(&msg, SOL_IPV6, IPV6_2292HOPLIMIT, sizeof(hlim), &hlim);
 			}
+			if (np->rxopt.bits.rxflow) {
+				int flowinfo = np->rcv_flowinfo;
+				put_cmsg(&msg, SOL_IPV6, IPV6_FLOWINFO, sizeof(flowinfo), &flowinfo);
+			}
 		}
 		len -= msg.msg_controllen;
 		return put_user(len, optlen);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0740f93..79a1963 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1136,6 +1136,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newnp->mcast_oif   = inet6_iif(skb);
 		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
 		newnp->rcv_tclass  = ipv6_get_dsfield(ipv6_hdr(skb));
+		newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
 
 		/*
 		 * No need to charge this sock to the relevant IPv6 refcnt debug socks count
@@ -1216,6 +1217,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newnp->mcast_oif  = inet6_iif(skb);
 	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
 	newnp->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));
+	newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
 
 	/* Clone native IPv6 options from listening socket (if any)
 
@@ -1427,6 +1429,8 @@ ipv6_pktoptions:
 			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
 		if (np->rxopt.bits.rxtclass)
 			np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(opt_skb));
+		if (np->rxopt.bits.rxflow)
+			np->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(opt_skb));
 		if (ipv6_opt_accepted(sk, opt_skb)) {
 			skb_set_owner_r(opt_skb, sk);
 			opt_skb = xchg(&np->pktoptions, opt_skb);
-- 
1.8.4.3
