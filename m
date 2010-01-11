From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Sun, 10 Jan 2010 22:00:34 -0800
Message-ID: <20100110220034.4d46ba8a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-api@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49085 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750895Ab0AKGAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 01:00:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the kernel portions needed to implement
RFC 5082 Generalized TTL Security Mechanism (GTSM).
It is a lightweight security measure against forged
packets causing DoS attacks (for BGP). 

This is already implemented the same way in BSD kernels.
For the necessary Quagga patch 
  http://www.gossamer-threads.com/lists/quagga/dev/17389

Description from Cisco
  http://www.cisco.com/en/US/docs/ios/12_3t/12_3t7/feature/guide/gt_btsh.html

It does add one byte to each socket structure, but I did
a little rearrangement to reuse a hole (on 64 bit), but it
does grow the structure on 32 bit

This should be documented on ip(4) man page and the Glibc in.h
file also needs update.  IPV6_MINHOPLIMIT should also be added
(although BSD doesn't support that).  

Only TCP is supported, but could also be added to UDP, DCCP, SCTP
if desired.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/in.h      |    1 +
 include/net/inet_sock.h |    9 +++++++++
 net/ipv4/ip_sockglue.c  |   14 +++++++++++++-
 net/ipv4/tcp_ipv4.c     |    2 ++
 4 files changed, 25 insertions(+), 1 deletion(-)

--- a/include/linux/in.h	2010-01-10 21:06:42.873122656 -0800
+++ b/include/linux/in.h	2010-01-10 21:06:47.802185618 -0800
@@ -84,6 +84,8 @@ struct in_addr {
 #define IP_ORIGDSTADDR       20
 #define IP_RECVORIGDSTADDR   IP_ORIGDSTADDR
 
+#define IP_MINTTL       21
+
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
 #define IP_PMTUDISC_WANT		1	/* Use per route hints	*/
--- a/include/net/inet_sock.h	2010-01-10 21:06:42.893123288 -0800
+++ b/include/net/inet_sock.h	2010-01-10 21:17:50.262842588 -0800
@@ -122,10 +122,12 @@ struct inet_sock {
 	__be32			inet_saddr;
 	__s16			uc_ttl;
 	__u16			cmsg_flags;
-	struct ip_options	*opt;
 	__be16			inet_sport;
 	__u16			inet_id;
+
+	struct ip_options	*opt;
 	__u8			tos;
+	__u8			min_ttl;
 	__u8			mc_ttl;
 	__u8			pmtudisc;
 	__u8			recverr:1,
--- a/net/ipv4/ip_sockglue.c	2010-01-10 21:06:42.913123212 -0800
+++ b/net/ipv4/ip_sockglue.c	2010-01-10 21:06:47.822184879 -0800
@@ -451,7 +451,8 @@ static int do_ip_setsockopt(struct sock 
 			     (1<<IP_TTL) | (1<<IP_HDRINCL) |
 			     (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
-			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT))) ||
+			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT) |
+	     		     (1<<IP_MINTTL))) ||
 	    optname == IP_MULTICAST_TTL ||
 	    optname == IP_MULTICAST_ALL ||
 	    optname == IP_MULTICAST_LOOP ||
@@ -936,6 +937,14 @@ mc_msf_out:
 		inet->transparent = !!val;
 		break;
 
+	case IP_MINTTL:
+		if (optlen < 1)
+			goto e_inval;
+		if (val < 0 || val > 255)
+			goto e_inval;
+		inet->min_ttl = val;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -1198,6 +1207,9 @@ static int do_ip_getsockopt(struct sock 
 	case IP_TRANSPARENT:
 		val = inet->transparent;
 		break;
+	case IP_MINTTL:
+		val = inet->min_ttl;
+		break;
 	default:
 		release_sock(sk);
 		return -ENOPROTOOPT;
--- a/net/ipv4/tcp_ipv4.c	2010-01-10 21:06:42.931093698 -0800
+++ b/net/ipv4/tcp_ipv4.c	2010-01-10 21:08:21.537513427 -0800
@@ -1649,6 +1649,9 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	if (iph->ttl < inet_sk(sk)->min_ttl)
+		goto discard_and_relse;
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
