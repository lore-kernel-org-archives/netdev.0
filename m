From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Thu, 29 Nov 2007 18:08:30 +0800
Message-ID: <474E8F9E.7040309@cn.fujitsu.com>
References: <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com> <20071120140518.GA1502@one.firstfloor.org> <20071120.173928.53148729.davem@davemloft.net> <474E707A.3080106@cn.fujitsu.com> <20071129092136.GB30066@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	Wang Chen <wangchen@cn.fujitsu.com>, netdev@vger.kernel.org,
	gerrit@erg.abdn.ac.uk, bfields@fieldses.org, neilb@suse.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:65143 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755857AbXK2KLD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 05:11:03 -0500
In-Reply-To: <20071129092136.GB30066@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu said the following on 2007-11-29 17:21:
> On Thu, Nov 29, 2007 at 03:55:38PM +0800, Wang Chen wrote:
> 
> Excellent.  They now do a recvmsg first with no buffer to get
> meta-information, which just happens to increment the counters.
> 
> Could you please resubmit the patch then?
> 

[SNMP]: Defer InDataGrams increment until recvmsg() does checksum

Split UDP receive count into UdpInDatagrams and UdpInEarlyDatagrams

UdpInDatagrams can be confusing because it counts packets that 
might be dropped later.

Move UdpInDatagrams into recvmsg() as allowed by the RFC.

Add a new UdpInEarlyDatagrams counter to count datagrams received early,
but which might be dropped later.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 Documentation/networking/udplite.txt |    2 +-
 include/linux/snmp.h                 |    1 +
 net/ipv4/proc.c                      |    1 +
 net/ipv4/udp.c                       |   12 ++++++++----
 net/ipv6/proc.c                      |    1 +
 net/ipv6/udp.c                       |   13 ++++++++-----
 6 files changed, 20 insertions(+), 10 deletions(-)

diff -Nurp linux-2.6.24.rc3.org/Documentation/networking/udplite.txt linux-2.6.24.rc3/Documentation/networking/udplite.txt
--- linux-2.6.24.rc3.org/Documentation/networking/udplite.txt	2007-11-19 12:37:40.000000000 +0800
+++ linux-2.6.24.rc3/Documentation/networking/udplite.txt	2007-11-28 18:35:29.000000000 +0800
@@ -236,7 +236,7 @@
 
   This displays UDP-Lite statistics variables, whose meaning is as follows.
 
-   InDatagrams:     Total number of received datagrams.
+   InDatagrams:     The total number of UDP datagrams delivered to UDP users.
 
    NoPorts:         Number of packets received to an unknown port.
                     These cases are counted separately (not as InErrors).
diff -Nurp linux-2.6.24.rc3.org/include/linux/snmp.h linux-2.6.24.rc3/include/linux/snmp.h
--- linux-2.6.24.rc3.org/include/linux/snmp.h	2007-11-19 12:38:13.000000000 +0800
+++ linux-2.6.24.rc3/include/linux/snmp.h	2007-11-28 18:06:15.000000000 +0800
@@ -138,6 +138,7 @@ enum
 	UDP_MIB_OUTDATAGRAMS,			/* OutDatagrams */
 	UDP_MIB_RCVBUFERRORS,			/* RcvbufErrors */
 	UDP_MIB_SNDBUFERRORS,			/* SndbufErrors */
+	UDP_MIB_INEARLYDATAGRAMS,		/* Early Datagrams Received */
 	__UDP_MIB_MAX
 };
 
diff -Nurp linux-2.6.24.rc3.org/net/ipv4/proc.c linux-2.6.24.rc3/net/ipv4/proc.c
--- linux-2.6.24.rc3.org/net/ipv4/proc.c	2007-11-19 12:38:14.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv4/proc.c	2007-11-28 18:06:15.000000000 +0800
@@ -149,6 +149,7 @@ static const struct snmp_mib snmp4_tcp_l
 
 static const struct snmp_mib snmp4_udp_list[] = {
 	SNMP_MIB_ITEM("InDatagrams", UDP_MIB_INDATAGRAMS),
+	SNMP_MIB_ITEM("InEarlyDatagrams", UDP_MIB_INEARLYDATAGRAMS),
 	SNMP_MIB_ITEM("NoPorts", UDP_MIB_NOPORTS),
 	SNMP_MIB_ITEM("InErrors", UDP_MIB_INERRORS),
 	SNMP_MIB_ITEM("OutDatagrams", UDP_MIB_OUTDATAGRAMS),
diff -Nurp linux-2.6.24.rc3.org/net/ipv4/udp.c linux-2.6.24.rc3/net/ipv4/udp.c
--- linux-2.6.24.rc3.org/net/ipv4/udp.c	2007-11-19 12:38:14.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv4/udp.c	2007-11-29 17:24:25.000000000 +0800
@@ -873,6 +873,8 @@ try_again:
 	if (err)
 		goto out_free;
 
+	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
+
 	sock_recv_timestamp(msg, sk, skb);
 
 	/* Copy the address. */
@@ -940,6 +942,7 @@ int udp_queue_rcv_skb(struct sock * sk, 
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
+	int is_udplite = IS_UDPLITE(sk);
 
 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
@@ -967,7 +970,8 @@ int udp_queue_rcv_skb(struct sock * sk, 
 
 			ret = (*up->encap_rcv)(sk, skb);
 			if (ret <= 0) {
-				UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
+				UDP_INC_STATS_BH(UDP_MIB_INEARLYDATAGRAMS,
+						 is_udplite);
 				return -ret;
 			}
 		}
@@ -1019,15 +1023,15 @@ int udp_queue_rcv_skb(struct sock * sk, 
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, is_udplite);
 		goto drop;
 	}
 
-	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
+	UDP_INC_STATS_BH(UDP_MIB_INEARLYDATAGRAMS, is_udplite);
 	return 0;
 
 drop:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS, up->pcflag);
+	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return -1;
 }
diff -Nurp linux-2.6.24.rc3.org/net/ipv6/proc.c linux-2.6.24.rc3/net/ipv6/proc.c
--- linux-2.6.24.rc3.org/net/ipv6/proc.c	2007-11-19 12:38:14.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv6/proc.c	2007-11-28 18:06:15.000000000 +0800
@@ -104,6 +104,7 @@ static char *icmp6type2name[256] = {
 
 static struct snmp_mib snmp6_udp6_list[] = {
 	SNMP_MIB_ITEM("Udp6InDatagrams", UDP_MIB_INDATAGRAMS),
+	SNMP_MIB_ITEM("Udp6InEarlyDatagrams", UDP_MIB_INEARLYDATAGRAMS),
 	SNMP_MIB_ITEM("Udp6NoPorts", UDP_MIB_NOPORTS),
 	SNMP_MIB_ITEM("Udp6InErrors", UDP_MIB_INERRORS),
 	SNMP_MIB_ITEM("Udp6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
diff -Nurp linux-2.6.24.rc3.org/net/ipv6/udp.c linux-2.6.24.rc3/net/ipv6/udp.c
--- linux-2.6.24.rc3.org/net/ipv6/udp.c	2007-11-19 12:38:14.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv6/udp.c	2007-11-29 17:25:11.000000000 +0800
@@ -164,6 +164,8 @@ try_again:
 	if (err)
 		goto out_free;
 
+	UDP6_INC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
+
 	sock_recv_timestamp(msg, sk, skb);
 
 	/* Copy the address. */
@@ -205,7 +207,7 @@ out:
 	return err;
 
 csum_copy_err:
-	UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
+	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	skb_kill_datagram(sk, skb, flags);
 
 	if (flags & MSG_DONTWAIT)
@@ -258,6 +260,7 @@ int udpv6_queue_rcv_skb(struct sock * sk
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
+	int is_udplite = IS_UDPLITE(sk);
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
@@ -265,7 +268,7 @@ int udpv6_queue_rcv_skb(struct sock * sk
 	/*
 	 * UDP-Lite specific tests, ignored on UDP sockets (see net/ipv4/udp.c).
 	 */
-	if ((up->pcflag & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
+	if ((is_udplite & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
 
 		if (up->pcrlen == 0) {          /* full coverage was set  */
 			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE6: partial coverage"
@@ -289,13 +292,13 @@ int udpv6_queue_rcv_skb(struct sock * sk
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, is_udplite);
 		goto drop;
 	}
-	UDP6_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
+	UDP6_INC_STATS_BH(UDP_MIB_INEARLYDATAGRAMS, is_udplite);
 	return 0;
 drop:
-	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, up->pcflag);
+	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return -1;
 }

