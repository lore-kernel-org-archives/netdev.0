From: John Tobin <ogre@sirinet.net>
Subject: UDP Wide Broadcast patch
Date: 18 Aug 2002 13:22:41 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <1029694978.330.6.camel@ogre>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ZOumsiTdBhg3WQaoNHwE"
Cc: ttimo@idsoftware.com
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-ZOumsiTdBhg3WQaoNHwE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,
DocWilco and I came up with this patch for the linux kernel at Quakecon
last night based off of his BSD patch that works around the programming
oversight in Quake 3 that causes packets from the dedicated server to
not broadcast when the +set net_ip option is used on a LAN, it isn't an
issue with internet servers since the send heartbeats to the id master
server. The behavior is off by default and can be turned on using a
sysctl.

John Tobin



--=-ZOumsiTdBhg3WQaoNHwE
Content-Disposition: attachment; filename=udp_wide_broadcast.patch
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; name=udp_wide_broadcast.patch; charset=ANSI_X3.4-1968

--- linux/include/linux/sysctl.h.orig	2002-08-17 19:52:27.000000000 -0500
+++ linux/include/linux/sysctl.h	2002-08-17 19:53:00.000000000 -0500
@@ -291,7 +291,8 @@
 	NET_IPV4_NONLOCAL_BIND=3D88,
 	NET_IPV4_ICMP_RATELIMIT=3D89,
 	NET_IPV4_ICMP_RATEMASK=3D90,
-	NET_TCP_TW_REUSE=3D91
+	NET_TCP_TW_REUSE=3D91,
+	NET_UDP_WIDE_BROADCAST=3D92
 };
=20
 enum {
--- linux-modified/net/ipv4/sysctl_net_ipv4.c.orig	2002-08-17 19:48:19.0000=
00000 -0500
+++ linux-modified/net/ipv4/sysctl_net_ipv4.c	2002-08-17 19:52:03.000000000=
 -0500
@@ -45,6 +45,9 @@
 extern int inet_peer_gc_mintime;
 extern int inet_peer_gc_maxtime;
=20
+/* From udp.c */
+extern int sysctl_udp_wide_broadcast;
+
 #ifdef CONFIG_SYSCTL
 static int tcp_retr1_max =3D 255;=20
 static int ip_local_port_range_min[] =3D { 1, 1 };
@@ -221,6 +224,8 @@
 	 &sysctl_icmp_ratemask, sizeof(int), 0644, NULL, &proc_dointvec},
 	{NET_TCP_TW_REUSE, "tcp_tw_reuse",
 	 &sysctl_tcp_tw_reuse, sizeof(int), 0644, NULL, &proc_dointvec},
+	{NET_UDP_WIDE_BROADCAST, "udp_wide_broadcast",
+	 &sysctl_udp_wide_broadcast, sizeof(int), 0644, NULL, &proc_dointvec},
 	{0}
 };
=20
--- linux-modified/net/ipv4/udp.c.orig	2002-08-17 19:40:59.000000000 -0500
+++ linux-modified/net/ipv4/udp.c	2002-08-17 23:37:47.000000000 -0500
@@ -94,6 +94,8 @@
 #include <net/inet_common.h>
 #include <net/checksum.h>
=20
+int sysctl_udp_wide_broadcast =3D 0;
+
 /*
  *	Snmp MIB for the UDP layer
  */
@@ -272,9 +274,10 @@
 		if ((s->num !=3D hnum)					||
 		    (s->daddr && s->daddr!=3Drmt_addr)			||
 		    (s->dport !=3D rmt_port && s->dport !=3D 0)			||
-		    (s->rcv_saddr  && s->rcv_saddr !=3D loc_addr)		||
-		    (s->bound_dev_if && s->bound_dev_if !=3D dif))
+		    !(sysctl_udp_wide_broadcast || !(s->rcv_saddr  && s->rcv_saddr !=3D =
loc_addr))	||
+		    (s->bound_dev_if && s->bound_dev_if !=3D dif)) {
 			continue;
+		}
 		break;
   	}
   	return s;

--=-ZOumsiTdBhg3WQaoNHwE
Content-Disposition: attachment; filename=readme.txt
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; name=readme.txt; charset=ANSI_X3.4-1968

UDP Wide Broadcast Patch for Kernel 2.4.19

Main purpose is to allow Quake 3 servers, and all games powered by the
engine, to be visible in the server browser when the servers are being run =
on
aliased IP addresses and multiple NICs using the +set net_ip option.

To apply the patch run "patch -p1 < udp_wide_broadcast.patch" from your
source directory and recompile.

Add "echo "1" > /proc/sys/net/ipv4/udp_wide_broadcast" to one of your start=
up
scripts, i.e./etc/rc.d/rc.local, and run thousands of servers from your
computer.


Patch by:
Rogier Mulhujzen <linux@bsdchicks.com>
John Tobin <ogre@sirinet.net>

A patch with the same functionality for FreeBSD is available from
http://www.bsdchicks.com/patches

--=-ZOumsiTdBhg3WQaoNHwE--
