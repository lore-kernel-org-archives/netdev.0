From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH v2] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 16:06:23 +0300
Message-ID: <1287666383-17615-1-git-send-email-timo.teras@iki.fi>
References: <4CC02ABF.8090008@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54510 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757924Ab0JUNGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 09:06:41 -0400
Received: by ewy7 with SMTP id 7so36855ewy.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 06:06:40 -0700 (PDT)
In-Reply-To: <4CC02ABF.8090008@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we have race condition to user land:
 1. process A: changes IP address
 2. process A: kernel sends RTM_NEWADDR (and schedules out)
 3. process B: gets notification
 4. process B: tries to bind() to new IP, but fails with EADDRNOTAVAIL
      because FIB is not yet updated and inet_addr_type() in inet_bind(=
)
      does not recognize the IP as local
 5. process A: calls inetaddr_chain notifiers which updates FIB

=46ix the error path to synchronize with configuration changes and retr=
y
the address type check.

IPv6 side seems to handle the notifications properly: bind() immediatel=
y
after RTM_NEWADDR succeeds as expected.  This is because ipv6_chk_addr(=
)
uses inet6_addr_lst which is updated before address notification.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
Since there was no reply to my question if this is ok, I interpreted it
as "maybe". So here's the code for review. Hopefully this helps determi=
ning
if this is an acceptable fix.

 net/ipv4/af_inet.c  |   18 ++++++++++++++++--
 net/ipv6/af_inet6.c |   13 ++++++++++---
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6a1100c..013ab11 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -481,8 +481,22 @@ int inet_bind(struct socket *sock, struct sockaddr=
 *uaddr, int addr_len)
 	    addr->sin_addr.s_addr !=3D htonl(INADDR_ANY) &&
 	    chk_addr_ret !=3D RTN_LOCAL &&
 	    chk_addr_ret !=3D RTN_MULTICAST &&
-	    chk_addr_ret !=3D RTN_BROADCAST)
-		goto out;
+	    chk_addr_ret !=3D RTN_BROADCAST) {
+		/* inet_addr_type() does a FIB lookup to check the
+		 * address type. Since FIB is updated after sending
+		 * RTM_NEWADDR notification, an application may end up
+		 * doing bind() before the FIB is updated. To avoid
+		 * returning a false negative, wait for possible ongoing
+		 * address changes to finish by acquiring rtnl lock and
+		 * retry the address type lookup. */
+		rtnl_lock();
+		rtnl_unlock();
+		chk_addr_ret =3D inet_addr_type(sock_net(sk), addr->sin_addr.s_addr)=
;
+		if (chk_addr_ret !=3D RTN_LOCAL &&
+		    chk_addr_ret !=3D RTN_MULTICAST &&
+		    chk_addr_ret !=3D RTN_BROADCAST)
+			goto out;
+	}
=20
 	snum =3D ntohs(addr->sin_port);
 	err =3D -EACCES;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 56b9bf2..b1a83e1 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -300,7 +300,7 @@ int inet6_bind(struct socket *sock, struct sockaddr=
 *uaddr, int addr_len)
 			goto out;
 		}
=20
-		/* Reproduce AF_INET checks to make the bindings consitant */
+		/* Reproduce AF_INET checks to make the bindings consistent */
 		v4addr =3D addr->sin6_addr.s6_addr32[3];
 		chk_addr_ret =3D inet_addr_type(net, v4addr);
 		if (!sysctl_ip_nonlocal_bind &&
@@ -309,8 +309,15 @@ int inet6_bind(struct socket *sock, struct sockadd=
r *uaddr, int addr_len)
 		    chk_addr_ret !=3D RTN_LOCAL &&
 		    chk_addr_ret !=3D RTN_MULTICAST &&
 		    chk_addr_ret !=3D RTN_BROADCAST) {
-			err =3D -EADDRNOTAVAIL;
-			goto out;
+			rtnl_lock();
+			rtnl_unlock();
+			chk_addr_ret =3D inet_addr_type(net, v4addr);
+			if (chk_addr_ret !=3D RTN_LOCAL &&
+			    chk_addr_ret !=3D RTN_MULTICAST &&
+			    chk_addr_ret !=3D RTN_BROADCAST) {
+				err =3D -EADDRNOTAVAIL;
+				goto out;
+			}
 		}
 	} else {
 		if (addr_type !=3D IPV6_ADDR_ANY) {
--=20
1.7.1

