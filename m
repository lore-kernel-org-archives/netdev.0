From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19: Kernel panic with "ifconfig eth0 up"
Date: Sat, 02 Dec 2006 01:15:52 -0800 (PST)
Message-ID: <20061202.011552.75188818.davem@davemloft.net>
References: <200612021030.17796.m.hanninen@kymp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53673
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1162853AbWLBJPv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Dec 2006 04:15:51 -0500
To: m.hanninen@kymp.net
In-Reply-To: <200612021030.17796.m.hanninen@kymp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Marko H=E4nninen <m.hanninen@kymp.net>
Date: Sat, 2 Dec 2006 10:30:17 +0200

> Hi,
>=20
> I'm having a kernel panic issue when bringing eth0 up. It happens eve=
ry time=20
> with command "ifconfig eth0 up". This is vanilla 2.6.19 kernel from k=
ernel.org.=20
> Works ok with 2.6.18.3. The system is a Acer Aspire 5021 WLMI laptop.
> Is there anything I can try? I'm not subscribed to the list, so pleas=
e CC me.

Known problem mentioned on the lists a few times already,
here is the fix:

commit c28728decc37fe52c8cdf48b3e0c0cf9b0c2fefb
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Nov 29 18:14:47 2006 -0800

    [IPV6] NDISC: Calculate packet length correctly for allocation.
   =20
    MAX_HEADER does not include the ipv6 header length in it,
    so we need to add it in explicitly.
   =20
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 73eb8c3..c42d4c2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -441,7 +441,8 @@ static void ndisc_send_na(struct net_dev
         struct sk_buff *skb;
 	int err;
=20
-	len =3D sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
+	len =3D sizeof(struct ipv6hdr) + sizeof(struct icmp6hdr) +
+		sizeof(struct in6_addr);
=20
 	/* for anycast or proxy, solicited_addr !=3D src_addr */
 	ifp =3D ipv6_get_ifaddr(solicited_addr, dev, 1);
@@ -556,7 +557,8 @@ void ndisc_send_ns(struct net_device *de
 	if (err < 0)
 		return;
=20
-	len =3D sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
+	len =3D sizeof(struct ipv6hdr) + sizeof(struct icmp6hdr) +
+		sizeof(struct in6_addr);
 	send_llinfo =3D dev->addr_len && !ipv6_addr_any(saddr);
 	if (send_llinfo)
 		len +=3D ndisc_opt_addr_space(dev);
@@ -632,7 +634,7 @@ void ndisc_send_rs(struct net_device *de
 	if (err < 0)
 		return;
=20
-	len =3D sizeof(struct icmp6hdr);
+	len =3D sizeof(struct ipv6hdr) + sizeof(struct icmp6hdr);
 	if (dev->addr_len)
 		len +=3D ndisc_opt_addr_space(dev);
=20
@@ -1381,7 +1383,8 @@ void ndisc_send_redirect(struct sk_buff=20
 			 struct in6_addr *target)
 {
 	struct sock *sk =3D ndisc_socket->sk;
-	int len =3D sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
+	int len =3D sizeof(struct ipv6hdr) + sizeof(struct icmp6hdr) +
+		2 * sizeof(struct in6_addr);
 	struct sk_buff *buff;
 	struct icmp6hdr *icmph;
 	struct in6_addr saddr_buf;
