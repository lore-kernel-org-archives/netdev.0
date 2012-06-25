From: David McCullough <david_mccullough@mcafee.com>
Subject: [PATCH] net/ipv6/route.c: packets originating on device match lo
Date: Mon, 25 Jun 2012 16:50:30 +1000
Message-ID: <20120625065030.GA28914@mcafee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <david_mccullough@mcafee.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dnvwsmailout1.mcafee.com ([161.69.31.173]:10927 "EHLO
	DNVWSMAILOUT1.mcafee.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab2FYHBR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 03:01:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

Seems like the special case of "iif lo" when using rules to control pac=
kets
is broken for IPv6 traffic.  The section from the ip man page is:

   iif NAME
          select  the incoming device to match.  If the interface is lo=
op=E2=80=90
          back, the rule only matches packets originating from this  ho=
st.
          This  means that you may create separate routing tables for f=
or=E2=80=90
          warded and local packets and, hence, completely segregate the=
m.

If I run the following configuration:

    ifconfig eth0 192.168.0.1 netmask 255.255.255.0
    ip addr add fec0:0:0:2::1/64 dev eth0

    ip route add table 200 unreachable default
    ip -6 route add table 200 unreachable default

    ip rule add to 192.168.0.2 table 200 iif lo
    ip -6 rule add to fec0:0:0:2::2 table 200 iif lo

and then test with:

    # ping 192.168.0.2
    connect: Network is unreachable
    # ping6 fec0:0:0:2::2
    PING fec0:0:0:2::2(fec0:0:0:2::2) 56 data bytes
    64 bytes from fec0:0:0:2::2: icmp_seq=3D1 ttl=3D64 time=3D0.648 ms
    ...

The patch below is against linux-3.4.  I am not sure if its the best
solution but it appears to fix the case above:

    # ping6 fec0:0:0:2::2
    connect: Network is unreachable

and does not appear to affect forwarded packets is the few cases I have
tried.  Tested on linux-3.4 and iproute2-3.4.0, Feedback appreciated :-=
)

Thanks,
Davidm

Signed-off-by: David McCullough <david_mccullough@mcafee.com>

diff -p -u -r1.1.1.59 route.c
--- linux-3.4/net/ipv6/route.c	21 May 2012 23:15:01 -0000	1.1.1.59
+++ linux-3.4/net/ipv6/route.c	25 Jun 2012 05:43:50 -0000
@@ -931,6 +931,9 @@ struct dst_entry * ip6_route_output(stru
 {
 	int flags =3D 0;
=20
+	if (fl6->flowi6_iif =3D=3D 0)
+		fl6->flowi6_iif =3D net->loopback_dev->ifindex;
+	=09
 	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr))
 		flags |=3D RT6_LOOKUP_F_IFACE;
=20

--=20
David McCullough,      david_mccullough@mcafee.com,  Ph:+61 734352815
McAfee - SnapGear      http://www.mcafee.com         http://www.uCdot.o=
rg
