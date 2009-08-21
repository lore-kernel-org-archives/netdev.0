From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: [Patch] Fix commit 63d9950b08184e6531adceb65f64b429909cc101
 (ipv6: Make v4-mapped bindings consistent with IPv4)
Date: Sat, 22 Aug 2009 01:45:23 +0200
Message-ID: <20090822014523.3ec2f591@neptune.home>
References: <20090822011541.7b95dbcc@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp-153-131.adsl.restena.lu ([158.64.153.131]:33000 "EHLO
	bonbons.gotdns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbZHUXpq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 19:45:46 -0400
In-Reply-To: <20090822011541.7b95dbcc@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 63d9950b08184e6531adceb65f64b429909cc101
  (ipv6: Make v4-mapped bindings consistent with IPv4)
changes behavior of inet6_bind() for v4-mapped addresses so it should
behave the same way as inet_bind().

During this change setting of err to -EADDRNOTAVAIL got lost:

af_inet.c:469 inet_bind()
	err =3D -EADDRNOTAVAIL;
	if (!sysctl_ip_nonlocal_bind &&
	    !(inet->freebind || inet->transparent) &&
	    addr->sin_addr.s_addr !=3D htonl(INADDR_ANY) &&
	    chk_addr_ret !=3D RTN_LOCAL &&
	    chk_addr_ret !=3D RTN_MULTICAST &&
	    chk_addr_ret !=3D RTN_BROADCAST)
		goto out;


af_inet6.c:463 inet6_bind()
	if (addr_type =3D=3D IPV6_ADDR_MAPPED) {
		int chk_addr_ret;

		/* Binding to v4-mapped address on a v6-only socket                  =
      =20
		 * makes no sense                                                    =
      =20
		 */
		if (np->ipv6only) {
			err =3D -EINVAL;
			goto out;=20
		}

		/* Reproduce AF_INET checks to make the bindings consitant */        =
      =20
		v4addr =3D addr->sin6_addr.s6_addr32[3];                             =
        =20
		chk_addr_ret =3D inet_addr_type(net, v4addr);                        =
        =20
		if (!sysctl_ip_nonlocal_bind &&                                      =
      =20
		    !(inet->freebind || inet->transparent) &&                        =
      =20
		    v4addr !=3D htonl(INADDR_ANY) &&
		    chk_addr_ret !=3D RTN_LOCAL &&                                   =
        =20
		    chk_addr_ret !=3D RTN_MULTICAST &&                               =
        =20
		    chk_addr_ret !=3D RTN_BROADCAST)
			goto out;
	} else {


Signed-off-by Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
---
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index caa0278..45f9a2a 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -306,8 +306,10 @@ int inet6_bind(struct socket *sock, struct sockadd=
r *uaddr, int addr_len)
 		    v4addr !=3D htonl(INADDR_ANY) &&
 		    chk_addr_ret !=3D RTN_LOCAL &&
 		    chk_addr_ret !=3D RTN_MULTICAST &&
-		    chk_addr_ret !=3D RTN_BROADCAST)
+		    chk_addr_ret !=3D RTN_BROADCAST) {
+			err =3D -EADDRNOTAVAIL;
 			goto out;
+		}
 	} else {
 		if (addr_type !=3D IPV6_ADDR_ANY) {
 			struct net_device *dev =3D NULL;

