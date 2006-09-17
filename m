From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: 2.6.18-rc[67] crashes in TCP ack handling
Date: Sun, 17 Sep 2006 12:11:01 +0200
Message-ID: <20060917101101.GA30461@outpost.ds9a.nl>
References: <20060916221948.GA12421@outpost.ds9a.nl> <20060917083214.45b5f61f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+QahgC5+KEYLbs62"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:41105 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S964880AbWIQKLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2006 06:11:03 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060917083214.45b5f61f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 17, 2006 at 08:32:14AM +0900, Stephen Hemminger wrote:

> By building all the possiblities into the kernel, ie. not as modules
> you get the last one registered. TCP LP is probably the worst one
> to use, because it is designed for bulk low priority applications.
> It also is one of the newest least tested.  Right now, I would rate

Hehe, this seems to be a bad default configuration policy then. People
generally don't assume that if the kernel offers 10 policies that the most
unstable will be used by default if you compile them all in.

I've attached a patch that reorders the choices per your suggested order, so
people are most likely to get a sane default.

I've tried to make "reno" the default, no matter what you compiled in, but
it didn't work. The linker probably reorders tcp_cong.o in early.

> Without a back trace, it will be hard to find the bug in TCP LP

Indeed. 

Many thanks for your quick answer Stephen!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services

--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=reorder-congestion-objects

--- linux-2.6.18/net/ipv4/Makefile~	2006-09-17 11:48:33.000000000 +0200
+++ linux-2.6.18/net/ipv4/Makefile	2006-09-17 11:48:45.000000000 +0200
@@ -7,7 +7,7 @@
 	     ip_output.o ip_sockglue.o inet_hashtables.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
-	     tcp_minisocks.o tcp_cong.o \
+	     tcp_minisocks.o \
 	     datagram.o raw.o udp.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
 
@@ -37,16 +37,20 @@
 obj-$(CONFIG_IP_ROUTE_MULTIPATH_CACHED) += multipath.o
 obj-$(CONFIG_INET_TCP_DIAG) += tcp_diag.o
 obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
-obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
-obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
-obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
+
+obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
+obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
+obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_HSTCP) += tcp_highspeed.o
 obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
+obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
+obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
-obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
-obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
-obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
-obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
+obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
+
+# make sure the built in congestion scheme is the default
+obj-y += tcp_cong.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o

--+QahgC5+KEYLbs62--
