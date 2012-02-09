From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH 2/2 net-next] net: implement IP_RECVTOS for IP_PKTOPTIONS
Date: Thu, 9 Feb 2012 20:35:49 +0100
Message-ID: <20120209203549.09ced962@griffin>
References: <20120209203441.24c97aa3@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757903Ab2BITfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 14:35:53 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q19JZqOA022742
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 9 Feb 2012 14:35:52 -0500
Received: from griffin (ovpn-116-57.ams2.redhat.com [10.36.116.57])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q19JZouI018495
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 9 Feb 2012 14:35:52 -0500
In-Reply-To: <20120209203441.24c97aa3@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, it is not easily possible to get TOS/DSCP value of packets from
an incoming TCP stream. The mechanism is there, IP_PKTOPTIONS getsockopt
with IP_RECVTOS set, the same way as incoming TTL can be queried. This is
not actually implemented for TOS, though.

This patch adds this functionality, both for IPv4 (IP_PKTOPTIONS) and IPv6
(IPV6_2292PKTOPTIONS). For IPv4, like in the IP_RECVTTL case, the value of
the TOS field is stored from the other party's ACK.

This is needed for proxies which require DSCP transparency. One such example
is at http://zph.bratcheda.org/.

Signed-off-by: Jiri Benc <jbenc@redhat.com>

---

I'm aware of RFC 2292 being obsolete and not dealing with the
IPV6_RECVTCLASS case. RFC 3542 removes IPV6_PKTOPTIONS and states in 4.1:

   This specification therefore does not define how to get the received
   information on TCP sockets.  The result of the IPV6_RECVxxx options
   on a TCP socket is undefined as well.

Thus, it is not against the RFC to handle IP_RECVTOS/IPV6_RECVTCLASS in the
same way as TP_RECVTTL/IPV6_RECVHOPLIMIT. Although it is indeed not clear
what should the behaviour be when the value changes during the stream
lifetime, for the (most likely sole) use case of TCP proxy this
implementation should be sufficient.

The added fields to inet_sock and ipv6_pinfo structs should fit into
padding, not increasing their length.

---
 include/linux/ipv6.h     |    2 +-
 include/net/inet_sock.h  |    1 +
 net/ipv4/af_inet.c       |    1 +
 net/ipv4/ip_sockglue.c   |    4 ++++
 net/ipv4/tcp_ipv4.c      |    1 +
 net/ipv6/af_inet6.c      |    1 +
 net/ipv6/ipv6_sockglue.c |    4 ++++
 net/ipv6/tcp_ipv6.c      |    4 ++++
 8 files changed, 17 insertions(+), 1 deletion(-)

--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -365,7 +365,7 @@ struct ipv6_pinfo {
 				dontfrag:1;
 	__u8			min_hopcount;
 	__u8			tclass;
-	__u8			padding;
+	__u8			rcv_tclass;
 
 	__u32			dst_cookie;
 
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -167,6 +167,7 @@ struct inet_sock {
 				transparent:1,
 				mc_all:1,
 				nodefrag:1;
+	__u8			rcv_tos;
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist __rcu	*mc_list;
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -381,6 +381,7 @@ lookup_protocol:
 	inet->mc_all	= 1;
 	inet->mc_index	= 0;
 	inet->mc_list	= NULL;
+	inet->rcv_tos	= 0;
 
 	sk_refcnt_debug_inc(sk);
 
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1256,6 +1256,10 @@ static int do_ip_getsockopt(struct sock 
 			int hlim = inet->mc_ttl;
 			put_cmsg(&msg, SOL_IP, IP_TTL, sizeof(hlim), &hlim);
 		}
+		if (inet->cmsg_flags & IP_CMSG_TOS) {
+			int tos = inet->rcv_tos;
+			put_cmsg(&msg, SOL_IP, IP_TOS, sizeof(tos), &tos);
+		}
 		len -= msg.msg_controllen;
 		return put_user(len, optlen);
 	}
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1458,6 +1458,7 @@ struct sock *tcp_v4_syn_recv_sock(struct
 	ireq->opt	      = NULL;
 	newinet->mc_index     = inet_iif(skb);
 	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
+	newinet->rcv_tos      = ip_hdr(skb)->tos;
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
 	if (inet_opt)
 		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -214,6 +214,7 @@ lookup_protocol:
 	inet->mc_ttl	= 1;
 	inet->mc_index	= 0;
 	inet->mc_list	= NULL;
+	inet->rcv_tos	= 0;
 
 	if (ipv4_config.no_pmtu_disc)
 		inet->pmtudisc = IP_PMTUDISC_DONT;
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -987,6 +987,10 @@ static int do_ipv6_getsockopt(struct soc
 				int hlim = np->mcast_hops;
 				put_cmsg(&msg, SOL_IPV6, IPV6_HOPLIMIT, sizeof(hlim), &hlim);
 			}
+			if (np->rxopt.bits.rxtclass) {
+				int tclass = np->rcv_tclass;
+				put_cmsg(&msg, SOL_IPV6, IPV6_TCLASS, sizeof(tclass), &tclass);
+			}
 			if (np->rxopt.bits.rxoinfo) {
 				struct in6_pktinfo src_info;
 				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif :
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1282,6 +1282,7 @@ static struct sock * tcp_v6_syn_recv_soc
 		newnp->opt	   = NULL;
 		newnp->mcast_oif   = inet6_iif(skb);
 		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
+		newnp->rcv_tclass  = ipv6_tclass(ipv6_hdr(skb));
 
 		/*
 		 * No need to charge this sock to the relevant IPv6 refcnt debug socks count
@@ -1360,6 +1361,7 @@ static struct sock * tcp_v6_syn_recv_soc
 	newnp->opt	  = NULL;
 	newnp->mcast_oif  = inet6_iif(skb);
 	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
+	newnp->rcv_tclass = ipv6_tclass(ipv6_hdr(skb));
 
 	/* Clone native IPv6 options from listening socket (if any)
 
@@ -1562,6 +1564,8 @@ ipv6_pktoptions:
 			np->mcast_oif = inet6_iif(opt_skb);
 		if (np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim)
 			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
+		if (np->rxopt.bits.rxtclass)
+			np->rcv_tclass = ipv6_tclass(ipv6_hdr(skb));
 		if (ipv6_opt_accepted(sk, opt_skb)) {
 			skb_set_owner_r(opt_skb, sk);
 			opt_skb = xchg(&np->pktoptions, opt_skb);
