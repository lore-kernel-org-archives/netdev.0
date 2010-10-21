From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 13:12:10 +0300
Message-ID: <1287655930-16879-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60064 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014Ab0JUKMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:12:15 -0400
Received: by eyx24 with SMTP id 24so1876953eyx.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 03:12:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we have race condition to user land:
 1. process A changes IP address
 2. kernel sends RTM_NEWADDR
 3. process B gets notification
 4. process B tries to bind() to new IP but that fails with
EADDRNOTAVAIL because FIB is not yet updated and inet_addr_type() in
inet_bind() does not recognize the IP as local
 5. kernel calls inetaddr_chain notifiers which updates FIB

IPv6 side seems to handle the notifications properly: bind()
immediately after RTM_NEWADDR succeeds as expected. This is because
ipv6_chk_addr() uses inet6_addr_lst which is updated before address
notification.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 net/ipv4/af_inet.c  |    9 +++++++++
 net/ipv6/af_inet6.c |    4 +++-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6a1100c..21200e4 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -466,6 +466,15 @@ int inet_bind(struct socket *sock, struct sockaddr=
 *uaddr, int addr_len)
 	if (addr_len < sizeof(struct sockaddr_in))
 		goto out;
=20
+	/* Acquire rtnl_lock to synchronize with possible simultaneous
+	 * IP-address changes. This is needed because when RTM_NEWADDR
+	 * is sent the new IP is not yet in FIB, but alas inet_addr_type
+	 * checks the address type using FIB. Acquiring rtnl lock once
+	 * makse sure that any address for which RTM_NEWADDR was sent
+	 * earlier exists also in FIB. */
+	rtnl_lock();
+	rtnl_unlock();
+
 	chk_addr_ret =3D inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
=20
 	/* Not specified by any standard per-se, however it breaks too
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 56b9bf2..6fc37f4 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -300,7 +300,9 @@ int inet6_bind(struct socket *sock, struct sockaddr=
 *uaddr, int addr_len)
 			goto out;
 		}
=20
-		/* Reproduce AF_INET checks to make the bindings consitant */
+		/* Reproduce AF_INET checks to make the bindings consistent */
+		rtnl_lock();
+		rtnl_unlock();
 		v4addr =3D addr->sin6_addr.s6_addr32[3];
 		chk_addr_ret =3D inet_addr_type(net, v4addr);
 		if (!sysctl_ip_nonlocal_bind &&
--=20
1.7.1

