From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] GTSM for IPv6
Date: Fri, 19 Mar 2010 09:56:40 -0700
Message-ID: <20100319095640.42c8d82d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ?=
	 =?UTF-8?B?6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35418 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439Ab0CSQ4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 12:56:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements Generalized TTL Security Mechanism for IPv6.
It is not tested, but I am putting it out to get feedback about:
  * is this the API (setsockout IPV6_MIN_HOPS) that we want to use
  * compatibility with IPv4
  * minor growth of socket packet info structure

Also RFC doesn't explicitly address GTSM on IPV6.
Maybe the RFC editors think the problem will magically no longer exist
in IPv6 world because everyone will be using IPsec.


---
 include/linux/in6.h      |    3 +++
 include/linux/ipv6.h     |    3 ++-
 net/ipv6/ipv6_sockglue.c |   12 ++++++++++++
 net/ipv6/tcp_ipv6.c      |   17 ++++++++++++++---
 4 files changed, 31 insertions(+), 4 deletions(-)

--- a/net/ipv6/tcp_ipv6.c	2010-03-19 09:05:48.038329597 -0700
+++ b/net/ipv6/tcp_ipv6.c	2010-03-19 09:51:12.293647330 -0700
@@ -349,6 +349,12 @@ static void tcp_v6_err(struct sk_buff *s
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
 
+	np = inet6_sk(sk);
+	if (ipv6_hdr(skb)->hop_limit < np->min_hops) {
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
+		goto out;
+	}
+
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
@@ -357,8 +363,6 @@ static void tcp_v6_err(struct sk_buff *s
 		goto out;
 	}
 
-	np = inet6_sk(sk);
-
 	if (type == ICMPV6_PKT_TOOBIG) {
 		struct dst_entry *dst = NULL;
 
@@ -1675,6 +1679,7 @@ ipv6_pktoptions:
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
 	struct tcphdr *th;
+	struct ipv6hdr *hdr;
 	struct sock *sk;
 	int ret;
 	struct net *net = dev_net(skb->dev);
@@ -1701,12 +1706,13 @@ static int tcp_v6_rcv(struct sk_buff *sk
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
@@ -1717,6 +1723,11 @@ process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	if (hdr->hop_limit < inet6_sk(sk)->min_hops) {
+		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
+		goto discard_and_relse;
+	}
+
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
--- a/include/linux/in6.h	2010-03-19 09:40:24.788957033 -0700
+++ b/include/linux/in6.h	2010-03-19 09:41:41.432704471 -0700
@@ -265,6 +265,9 @@ struct in6_flowlabel_req {
 #define IPV6_PREFER_SRC_CGA		0x0008
 #define IPV6_PREFER_SRC_NONCGA		0x0800
 
+/* RFC5082: Generalized Ttl Security Mechanism */
+#define IPV6_MIN_HOPS		73
+
 /*
  * Multicast Routing:
  * see include/linux/mroute6.h.
--- a/include/linux/ipv6.h	2010-03-19 09:26:17.368329255 -0700
+++ b/include/linux/ipv6.h	2010-03-19 09:27:03.929206412 -0700
@@ -348,6 +348,7 @@ struct ipv6_pinfo {
 						 * 010: prefer public address
 						 * 100: prefer care-of address
 						 */
+	__u8			min_hops;
 	__u8			tclass;
 
 	__u32			dst_cookie;
--- a/net/ipv6/ipv6_sockglue.c	2010-03-19 09:35:40.488016906 -0700
+++ b/net/ipv6/ipv6_sockglue.c	2010-03-19 09:39:57.948026685 -0700
@@ -766,6 +766,14 @@ pref_skip_coa:
 
 		break;
 	    }
+	case IPV6_MIN_HOPS:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		if (val < 0 || val > 255)
+			goto e_inval;
+		np->min_hops = val;
+		retv = 0;
+		break;
 	}
 
 	release_sock(sk);
@@ -1114,6 +1122,10 @@ static int do_ipv6_getsockopt(struct soc
 			val |= IPV6_PREFER_SRC_HOME;
 		break;
 
+	case IPV6_MIN_HOPS:
+		val = np->min_hops;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
