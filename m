From: weidong <weid@np.css.fujitsu.com>
Subject: Fix "ipOutNoRoutes" counter error for TCP and UDP
Date: Wed, 14 Feb 2007 10:03:49 -0500
Message-ID: <1171465429.7069.18.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:33893 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932270AbXBNC6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 21:58:52 -0500
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l1E2wo8x015075
	for <netdev@vger.kernel.org> (envelope-from weid@np.css.fujitsu.com);
	Wed, 14 Feb 2007 11:58:50 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 088802AC0BA
	for <netdev@vger.kernel.org>; Wed, 14 Feb 2007 11:58:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9620A12C086
	for <netdev@vger.kernel.org>; Wed, 14 Feb 2007 11:58:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6 [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B6A4161C00B
	for <netdev@vger.kernel.org>; Wed, 14 Feb 2007 11:58:49 +0900 (JST)
Received: from ml9.s.css.fujitsu.com (ml9.s.css.fujitsu.com [10.23.4.199])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D48C8161C00C
	for <netdev@vger.kernel.org>; Wed, 14 Feb 2007 11:58:48 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, All
  When I tested Linux-2.6.20 and found that counter "ipOutNoRoutes" can
not increase correctly.
  The criteria is RFC2011

ipOutNoRoutes OBJECT-TYPE
    SYNTAX      Counter32
    MAX-ACCESS  read-only
    STATUS      current
    DESCRIPTION
            "The number of IP datagrams discarded because no route could
            be found to transmit them to their destination.  Note that
            this counter includes any packets counted in ipForwDatagrams
            which meet this `no-route' criterion.  Note that this
            includes any datagrams which a host cannot route because all
            of its default routers are down."
    ::= { ip 12 }

In current Linux TCP/IP stack, maybe we should not increase this counter
in "input path", but only increase it in "output path" due to the TCP/IP
stack performance.

Now in "output path", when TCP client tries to connect to an unreachable
server(net unreachable, so no route can be found), this counter has no
increment. When we use UDP sending UDP datagram to an net unreachable
address, this counter also has no increment.

Function need to fix:
tcp_v4_connect(); ip4_datagram_connect(); udp_sendmsg();

The following patch can fix the problems mentioned above

BR 
Wei Dong

signed-off-by: Wei Dong <weid@np.css.fujitsu.com>

diff -ruN old/net/ipv4/datagram.c new/net/ipv4/datagram.c
--- old/net/ipv4/datagram.c	2007-02-02 12:28:54.000000000 -0500
+++ new/net/ipv4/datagram.c	2007-02-02 12:29:01.000000000 -0500
@@ -50,8 +50,10 @@
 			       RT_CONN_FLAGS(sk), oif,
 			       sk->sk_protocol,
 			       inet->sport, usin->sin_port, sk);
-	if (err)
+	if (err) {
+		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return err;
+	}
 	if ((rt->rt_flags & RTCF_BROADCAST) && !sock_flag(sk, SOCK_BROADCAST)) {
 		ip_rt_put(rt);
 		return -EACCES;
diff -ruN old/net/ipv4/tcp_ipv4.c new/net/ipv4/tcp_ipv4.c
--- old/net/ipv4/tcp_ipv4.c	2007-02-02 12:28:54.000000000 -0500
+++ new/net/ipv4/tcp_ipv4.c	2007-02-02 12:29:01.000000000 -0500
@@ -192,8 +192,10 @@
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_TCP,
 			       inet->sport, usin->sin_port, sk);
-	if (tmp < 0)
+	if (tmp < 0) {
+		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return tmp;
+	}
 
 	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
 		ip_rt_put(rt);
diff -ruN old/net/ipv4/udp.c new/net/ipv4/udp.c
--- old/net/ipv4/udp.c	2007-02-02 12:28:54.000000000 -0500
+++ new/net/ipv4/udp.c	2007-02-02 12:29:01.000000000 -0500
@@ -630,8 +630,10 @@
 						 .dport = dport } } };
 		security_sk_classify_flow(sk, &fl);
 		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
-		if (err)
+		if (err) {
+			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 			goto out;
+		}
 
 		err = -EACCES;
 		if ((rt->rt_flags & RTCF_BROADCAST) &&




