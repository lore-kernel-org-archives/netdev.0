From: Ben Hutchings <ben@decadent.org.uk>
Subject: [RFC][PATCH] IP: Make ping sockets optional
Date: Wed, 23 Apr 2014 16:20:28 +0100
Message-ID: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-83ZU5DvAsqL41LzVvvEk"
Cc: Vasiliy Kulikov <segoon@openwall.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57194 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932086AbaDWPUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 11:20:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-83ZU5DvAsqL41LzVvvEk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ICMP ping sockets currently require a new ping binary and are only
available after setting a sysctl.  The code adds about 10K to the
(uncompressed) size of the kernel.  Make this optional and disable
it by default.

This is compile-tested only; I'd just like to see whether people think
this is worth doing.
---
 include/net/ping.h         | 16 ++++++++++++++++
 net/ipv4/Kconfig           | 10 ++++++++++
 net/ipv4/Makefile          |  4 +++-
 net/ipv4/af_inet.c         |  6 ++++++
 net/ipv4/sysctl_net_ipv4.c |  7 +++++++
 net/ipv6/Makefile          |  4 +++-
 net/ipv6/af_inet6.c        |  4 ++++
 7 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/include/net/ping.h b/include/net/ping.h
index 026479b..d980ea7 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -13,6 +13,8 @@
 #ifndef _PING_H
 #define _PING_H
=20
+#ifdef CONFIG_INET_PING
+
 #include <net/icmp.h>
 #include <net/netns/hash.h>
=20
@@ -108,4 +110,18 @@ void __init ping_init(void);
 int  __init pingv6_init(void);
 void pingv6_exit(void);
=20
+#else /* !CONFIG_INET_PING */
+
+static inline void ping_err(struct sk_buff *skb, int offset, u32 info) {}
+static inline void ping_rcv(struct sk_buff *skb) {}
+
+static inline int __init ping_proc_init(void) { return 0; }
+static inline void ping_proc_exit(void) {}
+
+static inline void __init ping_init(void) {}
+static inline int __init pingv6_init(void) { return 0; }
+static inline void pingv6_exit(void) {}
+
+#endif
+
 #endif /* _PING_H */
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 05c57f0..a3cb144 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -618,3 +618,13 @@ config TCP_MD5SIG
 	  on the Internet.
=20
 	  If unsure, say N.
+
+config INET_PING
+	bool "ICMP: Ping sockets"
+	default n
+	---help---
+	  ICMP ping sockets allow 'ping' to be implemented without using a
+	  raw socket, so it does not need to be installed  setuid-root or
+	  setcap.  See <http://openwall.info/wiki/people/segoon/ping>.
+
+	  If unsure, say N.
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index f032688..85f65fc 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -11,7 +11,7 @@ obj-y     :=3D route.o inetpeer.o protocol.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
+	     inet_fragment.o ip_tunnel_core.o gre_offload.o
=20
 obj-$(CONFIG_NET_IP_TUNNEL) +=3D ip_tunnel.o
 obj-$(CONFIG_SYSCTL) +=3D sysctl_net_ipv4.o
@@ -56,3 +56,5 @@ obj-$(CONFIG_NETLABEL) +=3D cipso_ipv4.o
=20
 obj-$(CONFIG_XFRM) +=3D xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o xfrm4_protocol.o
+
+obj-$(CONFIG_INET_PING) +=3D ping.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870..3819b1d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1016,6 +1016,7 @@ static struct inet_protosw inetsw_array[] =3D
 		.flags =3D      INET_PROTOSW_PERMANENT,
        },
=20
+#ifdef CONFIG_INET_PING
        {
 		.type =3D       SOCK_DGRAM,
 		.protocol =3D   IPPROTO_ICMP,
@@ -1024,6 +1025,7 @@ static struct inet_protosw inetsw_array[] =3D
 		.no_check =3D   UDP_CSUM_DEFAULT,
 		.flags =3D      INET_PROTOSW_REUSE,
        },
+#endif
=20
        {
 	       .type =3D       SOCK_RAW,
@@ -1719,9 +1721,11 @@ static int __init inet_init(void)
 	if (rc)
 		goto out_unregister_udp_proto;
=20
+#ifdef CONFIG_INET_PING
 	rc =3D proto_register(&ping_prot, 1);
 	if (rc)
 		goto out_unregister_raw_proto;
+#endif
=20
 	/*
 	 *	Tell SOCKET that we are alive...
@@ -1810,8 +1814,10 @@ static int __init inet_init(void)
 	rc =3D 0;
 out:
 	return rc;
+#ifdef CONFIG_INET_PING
 out_unregister_raw_proto:
 	proto_unregister(&raw_prot);
+#endif
 out_unregister_udp_proto:
 	proto_unregister(&udp_prot);
 out_unregister_tcp_proto:
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 44eba05..bf87094 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -39,8 +39,10 @@ static int ip_ttl_min =3D 1;
 static int ip_ttl_max =3D 255;
 static int tcp_syn_retries_min =3D 1;
 static int tcp_syn_retries_max =3D MAX_TCP_SYNCNT;
+#ifdef CONFIG_INET_PING
 static int ip_ping_group_range_min[] =3D { 0, 0 };
 static int ip_ping_group_range_max[] =3D { GID_T_MAX, GID_T_MAX };
+#endif
=20
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
@@ -82,6 +84,7 @@ static int ipv4_local_port_range(struct ctl_table *table,=
 int write,
 	return ret;
 }
=20
+#ifdef CONFIG_INET_PING
=20
 static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_=
t *low, kgid_t *high)
 {
@@ -145,6 +148,8 @@ static int ipv4_ping_group_range(struct ctl_table *tabl=
e, int write,
 	return ret;
 }
=20
+#endif /* CONFIG_INET_PING */
+
 static int proc_tcp_congestion_control(struct ctl_table *ctl, int write,
 				       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -803,6 +808,7 @@ static struct ctl_table ipv4_net_table[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec
 	},
+#ifdef CONFIG_INET_PING
 	{
 		.procname	=3D "ping_group_range",
 		.data		=3D &init_net.ipv4.sysctl_ping_group_range,
@@ -810,6 +816,7 @@ static struct ctl_table ipv4_net_table[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D ipv4_ping_group_range,
 	},
+#endif
 	{
 		.procname	=3D "tcp_ecn",
 		.data		=3D &init_net.ipv4.sysctl_tcp_ecn,
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2fe6836..b8e0488 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_IPV6) +=3D ipv6.o
 ipv6-objs :=3D	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		addrlabel.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
-		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o ping.o \
+		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
=20
 ipv6-offload :=3D	ip6_offload.o tcpv6_offload.o udp_offload.o exthdrs_offl=
oad.o
@@ -45,3 +45,5 @@ obj-y +=3D addrconf_core.o exthdrs_core.o ip6_checksum.o =
ip6_icmp.o
 obj-$(CONFIG_INET) +=3D output_core.o protocol.o $(ipv6-offload)
=20
 obj-$(subst m,y,$(CONFIG_IPV6)) +=3D inet6_hashtables.o
+
+obj-$(CONFIG_INET_PING) +=3D ping.o
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d935889..7599ed8 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -861,9 +861,11 @@ static int __init inet6_init(void)
 	if (err)
 		goto out_unregister_udplite_proto;
=20
+#ifdef CONFIG_INET_PING
 	err =3D proto_register(&pingv6_prot, 1);
 	if (err)
 		goto out_unregister_ping_proto;
+#endif
=20
 	/* We MUST register RAW sockets before we create the ICMP6,
 	 * IGMP6, or NDISC control sockets.
@@ -1021,8 +1023,10 @@ register_pernet_fail:
 	rtnl_unregister_all(PF_INET6);
 out_sock_register_fail:
 	rawv6_exit();
+#ifdef CONFIG_INET_PING
 out_unregister_ping_proto:
 	proto_unregister(&pingv6_prot);
+#endif
 out_unregister_raw_proto:
 	proto_unregister(&rawv6_prot);
 out_unregister_udplite_proto:

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-83ZU5DvAsqL41LzVvvEk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1faPOe/yOyVhhEJAQorzhAArx5/nSYQRdl+Y+EtI02M1D5qcMWj9mp3
bOmYGbB+JKyjy07dmcNA+7WCgghczUFb9hDEHGGLxHHOEWWznMtpMs/TaNJQPagh
iq0BUAchxV+Arcw0pVU6Q63kYKCKNqGnJTVgY3pd2UnSC/xjaHP6w5mp47gauq+j
AqXzEBgvLopTYLcYsV8xJq2JvNli6j/P/MAUPR4JrOCvYczgBkADmw7tJkFDfOvW
8/XxORVaXdy7Cr1h4byU9mHi+eE9KyOBFE8FrZsk5IBKeXMxFSog3GJTUfUIE6En
FiZZyGZtYyVnilhAUlZDc5rloKK/QYKWhDuixNljwZdwqiLo05vb2qC9v4Z9FVOX
SZKaGBIerMebT+EHoFoaeZIF/DmhCfLu9EpzXI0nlGUkCnnMy2lf3TKkCb+2Vowq
1UKz9Tl7FompekcgpzRsc+84a/UpRFvcFoAyO2tmV28K4E1y+uTK2UUP9MgZLqcS
XuSw0i9Dzzy7z3btTfX/CqLw0Sb7VOZfQYVwai90XUaoCN6CK8LrmmtGdt3rFiaS
ok7Fe4G0QV3EqyN5mXvCmBXnWAHyNydlJp71G2fonDK7ShGoRdNFSR5r2V0q98Y8
CTtGrLgc6wm0c9AJ8TR4koYOpPvuTepfVoM1E6owaqj/8c8E7dK11lu0kpfriWce
ra3RGgJCnl4=
=UPvB
-----END PGP SIGNATURE-----

--=-83ZU5DvAsqL41LzVvvEk--
