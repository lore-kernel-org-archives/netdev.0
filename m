From: Wei Dong <weidong@cn.fujitsu.com>
Subject: Re: Fix "ipOutNoRoutes" counter error for TCP and UDP
Date: Tue, 27 Mar 2007 18:53:22 +0800
Message-ID: <4608F7A2.7070101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:53753 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753830AbXC0MTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 08:19:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mr. David
	I have modified my patch according to you advice. I think -EHOSTUNREACH
is only for "input path". In "output" path, we can just simply check
-ENETUNREACH  (^_^), the patch is shown in the end of this mail.

BTW: my E-mail has been changed to weidong@cn.fujitsu.com

 >> Function need to fix:
 >> tcp_v4_connect(); ip4_datagram_connect(); udp_sendmsg();

 > I think we need to make these checks more carefully.
 >
 > Route lookup can fail for several reasons other than
 > no route being available.  Two examples are:
 >
 > 1) Out of memory error while creating route
 > 2) IPSEC disallows communication to that flow ID
 >
 > As a result, we'll probably best limiting the counter
 > increment when the error is either -EHOSTUNREACH or
 > -ENETUNREACH.

signed-off-by: Wei Dong <weidong@cn.fujitsu.com>

diff -ruNp old/net/ipv4/datagram.c new/net/ipv4/datagram.c
--- old/net/ipv4/datagram.c	2007-03-27 18:15:56.000000000 +0800
+++ new/net/ipv4/datagram.c	2007-03-27 18:23:58.000000000 +0800
@@ -50,8 +50,12 @@ int ip4_datagram_connect(struct sock *sk
  			       RT_CONN_FLAGS(sk), oif,
  			       sk->sk_protocol,
  			       inet->sport, usin->sin_port, sk);
-	if (err)
+	if (err) {
+		if (err == -ENETUNREACH)
+			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
  		return err;
+	}
+
  	if ((rt->rt_flags & RTCF_BROADCAST) && !sock_flag(sk, SOCK_BROADCAST)) {
  		ip_rt_put(rt);
  		return -EACCES;
diff -ruNp old/net/ipv4/tcp_ipv4.c new/net/ipv4/tcp_ipv4.c
--- old/net/ipv4/tcp_ipv4.c	2007-03-27 18:15:56.000000000 +0800
+++ new/net/ipv4/tcp_ipv4.c	2007-03-27 18:28:38.000000000 +0800
@@ -192,8 +192,11 @@ int tcp_v4_connect(struct sock *sk, stru
  			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
  			       IPPROTO_TCP,
  			       inet->sport, usin->sin_port, sk);
-	if (tmp < 0)
+	if (tmp < 0) {
+		if (tmp == -ENETUNREACH)
+			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
  		return tmp;
+	}

  	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
  		ip_rt_put(rt);
diff -ruNp old/net/ipv4/udp.c new/net/ipv4/udp.c
--- old/net/ipv4/udp.c	2007-03-27 18:15:56.000000000 +0800
+++ new/net/ipv4/udp.c	2007-03-27 18:26:47.000000000 +0800
@@ -630,8 +630,11 @@ int udp_sendmsg(struct kiocb *iocb, stru
  						 .dport = dport } } };
  		security_sk_classify_flow(sk, &fl);
  		err = ip_route_output_flow(&rt, &fl, sk, 
!(msg->msg_flags&MSG_DONTWAIT));
-		if (err)
+		if (err) {
+			if (err == -ENETUNREACH)
+				IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
  			goto out;
+		}

  		err = -EACCES;
  		if ((rt->rt_flags & RTCF_BROADCAST) &&

