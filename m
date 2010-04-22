From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] IPv6: Generic TTL Security Mechanism (final version)
Date: Thu, 22 Apr 2010 15:18:46 -0700
Message-ID: <20100422151846.710a6d17@nehalam>
References: <20100403232103.923025940@vyatta.com>
	<20100403232922.489187907@vyatta.com>
	<20100422092305.0e45f547@nehalam>
	<20100422.143805.95887767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org, nick@inex.ie,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55622 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862Ab0DVWTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 18:19:09 -0400
In-Reply-To: <20100422.143805.95887767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds IPv6 support for RFC5082 Generalized TTL Security Mechanism.  

Not to users of mapped address; the IPV6 and IPV4 socket options are seperate.
The server does have to deal with both IPv4 and IPv6 socket options
and the client has to handle the different for each family.

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
		setsockopt(s, IPPROTO_IP, IP_MINTTL, &minttl, sizeof(minttl));
			
		if (bind(s, rp->ai_addr, rp->ai_addrlen) == 0)
			break
...
Same as v1 (except commit message)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/in6.h      |    3 +++
 include/linux/ipv6.h     |    1 +
 net/ipv6/ipv6_sockglue.c |   12 ++++++++++++
 net/ipv6/tcp_ipv6.c      |   14 +++++++++++++-
 4 files changed, 29 insertions(+), 1 deletion(-)

--- a/net/ipv6/tcp_ipv6.c	2010-04-22 09:32:39.845447496 -0700
+++ b/net/ipv6/tcp_ipv6.c	2010-04-22 09:32:47.395758592 -0700
@@ -353,6 +353,11 @@ static void tcp_v6_err(struct sk_buff *s
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
 
--- a/include/linux/in6.h	2010-04-22 09:32:39.855445952 -0700
+++ b/include/linux/in6.h	2010-04-22 09:32:47.395758592 -0700
@@ -265,6 +265,9 @@ struct in6_flowlabel_req {
 #define IPV6_PREFER_SRC_CGA		0x0008
 #define IPV6_PREFER_SRC_NONCGA		0x0800
 
+/* RFC5082: Generalized Ttl Security Mechanism */
+#define IPV6_MINHOPCOUNT		73
+
 /*
  * Multicast Routing:
  * see include/linux/mroute6.h.
--- a/include/linux/ipv6.h	2010-04-22 09:32:39.865447950 -0700
+++ b/include/linux/ipv6.h	2010-04-22 09:32:47.395758592 -0700
@@ -348,6 +348,7 @@ struct ipv6_pinfo {
 						 * 010: prefer public address
 						 * 100: prefer care-of address
 						 */
+	__u8			min_hopcount;
 	__u8			tclass;
 
 	__u32			dst_cookie;
--- a/net/ipv6/ipv6_sockglue.c	2010-04-22 09:32:39.835445583 -0700
+++ b/net/ipv6/ipv6_sockglue.c	2010-04-22 09:32:47.405760414 -0700
@@ -767,6 +767,14 @@ pref_skip_coa:
 
 		break;
 	    }
+	case IPV6_MINHOPCOUNT:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		if (val < 0 || val > 255)
+			goto e_inval;
+		np->min_hopcount = val;
+		retv = 0;
+		break;
 	}
 
 	release_sock(sk);
@@ -1116,6 +1124,10 @@ static int do_ipv6_getsockopt(struct soc
 			val |= IPV6_PREFER_SRC_HOME;
 		break;
 
+	case IPV6_MINHOPCOUNT:
+		val = np->min_hopcount;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
