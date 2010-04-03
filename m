From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] IPv6: Generic TTL Security Mechanism (alternate version)
Date: Sat, 03 Apr 2010 16:21:05 -0700
Message-ID: <20100403232922.575453663@vyatta.com>
References: <20100403232103.923025940@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, Pekka Savola <pekkas@netcore.fi>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Nick Hilliard <nick@inex.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46447 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753745Ab0DCXby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Apr 2010 19:31:54 -0400
Content-Disposition: inline; filename=gtsm-ipv6-ipv4-1a.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds IPv6 support for RFC5082 Generalized TTL
Security Mechanism.  

Very similar to original proposed code; the IPV6 and IPV4 
socket options are seperate, but the setting the IPV6 min hopcount
also sets IPV4 min ttl. This makes for less possible errors by the
programmer when using IPV4 mapped addresses.

With this method, the server does have to deal with both IPv4 and IPv6
socket options and the client has to handle the different for each
family.

On client:
	int ttl = 255;
	getaddrinfo(argv[1], argv[2], &hint, &result);

	for (rp = result; rp != NULL; rp = rp->ai_next) {
		s = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
		if (s < 0) continue;

		if (rp->ai_family == AF_INET) {
			setsockopt(s, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl));
		} else if (rp->ai_family == AF_INET6) {
			setsockopt(s, IPPROTO_IPV6,  IPV6_UNICAST_HOPS, 
					&ttl, sizeof(ttl)))
		}
			
		if (connect(s, rp->ai_addr, rp->ai_addrlen) == 0) {
		   ...

On server:
	int minttl = 255 - maxhops;
   
	getaddrinfo(NULL, port, &hints, &result);
	for (rp = result; rp != NULL; rp = rp->ai_next) {
		s = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
		if (s < 0) continue;

		if (rp->ai_family == AF_INET6)
			setsockopt(s, IPPROTO_IPV6,  IPV6_MINHOPCOUNT,
					&minttl, sizeof(minttl));
		else
		        setsockopt(s, IPPROTO_IP, IP_MINTTL, 
			                &minttl, sizeof(minttl));
			
		if (bind(s, rp->ai_addr, rp->ai_addrlen) == 0)
			break
..


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/in6.h      |    3 +++
 include/linux/ipv6.h     |    1 +
 net/ipv6/ipv6_sockglue.c |   13 +++++++++++++
 net/ipv6/tcp_ipv6.c      |   14 +++++++++++++-
 4 files changed, 30 insertions(+), 1 deletion(-)

--- a/net/ipv6/tcp_ipv6.c	2010-04-03 16:13:50.450038495 -0700
+++ b/net/ipv6/tcp_ipv6.c	2010-04-03 16:14:58.579101059 -0700
@@ -349,6 +349,11 @@ static void tcp_v6_err(struct sk_buff *s
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
 
+	if (ipv6_hdr(skb)->hop_limit < inet6_sk(sk)->min_hopcount) {
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
+		goto out;
+	}
+
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
@@ -1675,6 +1680,7 @@ ipv6_pktoptions:
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
 	struct tcphdr *th;
+	struct ipv6hdr *hdr;
 	struct sock *sk;
 	int ret;
 	struct net *net = dev_net(skb->dev);
@@ -1701,12 +1707,13 @@ static int tcp_v6_rcv(struct sk_buff *sk
 		goto bad_packet;
 
 	th = tcp_hdr(skb);
+	hdr = ipv6_hdr(skb);
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
 				    skb->len - th->doff*4);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
 	TCP_SKB_CB(skb)->when = 0;
-	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(ipv6_hdr(skb));
+	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(hdr);
 	TCP_SKB_CB(skb)->sacked = 0;
 
 	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
@@ -1717,6 +1724,11 @@ process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	if (hdr->hop_limit < inet6_sk(sk)->min_hopcount) {
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
+		goto discard_and_relse;
+	}
+
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
--- a/include/linux/in6.h	2010-04-03 16:13:50.460038505 -0700
+++ b/include/linux/in6.h	2010-04-03 16:14:58.579101059 -0700
@@ -265,6 +265,9 @@ struct in6_flowlabel_req {
 #define IPV6_PREFER_SRC_CGA		0x0008
 #define IPV6_PREFER_SRC_NONCGA		0x0800
 
+/* RFC5082: Generalized Ttl Security Mechanism */
+#define IPV6_MINHOPCOUNT		73
+
 /*
  * Multicast Routing:
  * see include/linux/mroute6.h.
--- a/include/linux/ipv6.h	2010-04-03 16:13:50.470038394 -0700
+++ b/include/linux/ipv6.h	2010-04-03 16:14:58.579101059 -0700
@@ -348,6 +348,7 @@ struct ipv6_pinfo {
 						 * 010: prefer public address
 						 * 100: prefer care-of address
 						 */
+	__u8			min_hopcount;
 	__u8			tclass;
 
 	__u32			dst_cookie;
--- a/net/ipv6/ipv6_sockglue.c	2010-04-03 16:13:50.440037810 -0700
+++ b/net/ipv6/ipv6_sockglue.c	2010-04-03 16:16:45.973137844 -0700
@@ -766,6 +766,15 @@ pref_skip_coa:
 
 		break;
 	    }
+	case IPV6_MINHOPCOUNT:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		if (val < 0 || val > 255)
+			goto e_inval;
+		np->min_hopcount = val;
+		inet_sk(sk)->min_ttl = val;
+		retv = 0;
+		break;
 	}
 
 	release_sock(sk);
@@ -1114,6 +1123,10 @@ static int do_ipv6_getsockopt(struct soc
 			val |= IPV6_PREFER_SRC_HOME;
 		break;
 
+	case IPV6_MINHOPCOUNT:
+		val = np->min_hopcount;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}

-- 

