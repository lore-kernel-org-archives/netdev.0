From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: [PATCH] connect() return value.
Date: Sat, 10 Aug 2002 20:24:41 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020810102441.GA1126@anakin.wychk.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=big5
Content-Disposition: inline

Hi,


I posted this on linux-kernel but didn't get a reply.

Anyway here's a patch for it.



Problem:

(1)

While you try to connect() to port 0 on ipv4 / ipv6, it happily does it.
This doesn't seem to be correct, as I remember port 0 is reserved.
For reference FreeBSD / Solaris / OSF return -EADDRNOTAVAIL for this.

This is what my patch fixes, for ipv4 and ipv6 for both tcp and udp,
I don't know what should be done for the other protocols that is 
supported.


(2)

connect() doesn't return -EINTR on signal, rather it exits the signal
handler after processing it and returns an error if an error occurred
for the connection or does the connect to completion. The Linux man page 
implies that we don't ever return an -EINTR on Linux, but I don't know what 
is the correct behavior.  For reference, FreeBSD / Solaris / OSF return
-EINTR for an interrupted connect().

The patch also addresses this. However, it is noted on OSF that even
though connect() returns with -EINTR if the connection succeeds you can
still send and receive through that socket.


(Please CC:, not on list. Thanks).

	-- G.
	

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=big5
Content-Disposition: attachment; filename=network-patch

diff -ruNp linux-2.4.19/net/ipv4/tcp_ipv4.c linux-2.4.19-glee/net/ipv4/tcp_ipv4.c
--- linux-2.4.19/net/ipv4/tcp_ipv4.c	2002-08-03 19:26:04.000000000 +1000
+++ linux-2.4.19-glee/net/ipv4/tcp_ipv4.c	2002-08-10 19:34:24.000000000 +1000
@@ -763,6 +763,9 @@ int tcp_v4_connect(struct sock *sk, stru
 	if (usin->sin_family != AF_INET)
 		return(-EAFNOSUPPORT);
 
+	if (usin->sin_port == 0)
+		return(-EADDRNOTAVAIL);
+
 	nexthop = daddr = usin->sin_addr.s_addr;
 	if (sk->protinfo.af_inet.opt && sk->protinfo.af_inet.opt->srr) {
 		if (daddr == 0)
diff -ruNp linux-2.4.19/net/ipv4/udp.c linux-2.4.19-glee/net/ipv4/udp.c
--- linux-2.4.19/net/ipv4/udp.c	2002-08-03 19:26:04.000000000 +1000
+++ linux-2.4.19-glee/net/ipv4/udp.c	2002-08-10 19:34:52.000000000 +1000
@@ -723,6 +723,9 @@ int udp_connect(struct sock *sk, struct 
 	if (usin->sin_family != AF_INET) 
 	  	return -EAFNOSUPPORT;
 
+	if (usin->sin_port == 0)
+		return -EADDRNOTAVAIL;
+
 	sk_dst_reset(sk);
 
 	oif = sk->bound_dev_if;
diff -ruNp linux-2.4.19/net/ipv6/tcp_ipv6.c linux-2.4.19-glee/net/ipv6/tcp_ipv6.c
--- linux-2.4.19/net/ipv6/tcp_ipv6.c	2002-08-03 19:26:04.000000000 +1000
+++ linux-2.4.19-glee/net/ipv6/tcp_ipv6.c	2002-08-10 19:35:57.000000000 +1000
@@ -539,6 +539,9 @@ static int tcp_v6_connect(struct sock *s
 	if (usin->sin6_family != AF_INET6) 
 		return(-EAFNOSUPPORT);
 
+	if (usin->sin6_port == 0)
+		return -EADDRNOTAVAIL;
+
 	fl.fl6_flowlabel = 0;
 	if (np->sndflow) {
 		fl.fl6_flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
diff -ruNp linux-2.4.19/net/ipv6/udp.c linux-2.4.19-glee/net/ipv6/udp.c
--- linux-2.4.19/net/ipv6/udp.c	2002-08-03 19:26:04.000000000 +1000
+++ linux-2.4.19-glee/net/ipv6/udp.c	2002-08-10 19:36:22.000000000 +1000
@@ -231,6 +231,9 @@ int udpv6_connect(struct sock *sk, struc
 	if (usin->sin6_family != AF_INET6) 
 	  	return -EAFNOSUPPORT;
 
+	if (usin->sin6_port == 0)
+		return -EADDRNOTAVAIL;
+
 	fl.fl6_flowlabel = 0;
 	if (np->sndflow) {
 		fl.fl6_flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
diff -ruNp linux-2.4.19/net/socket.c linux-2.4.19-glee/net/socket.c
--- linux-2.4.19/net/socket.c	2002-08-03 19:26:04.000000000 +1000
+++ linux-2.4.19-glee/net/socket.c	2002-08-10 19:37:23.000000000 +1000
@@ -1118,6 +1118,9 @@ asmlinkage long sys_connect(int fd, stru
 out_put:
 	sockfd_put(sock);
 out:
+	if (signal_pending(current))
+		return -EINTR;
+
 	return err;
 }
 

--gKMricLos+KVdGMg--
