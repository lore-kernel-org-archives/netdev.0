From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.6] NETFILTER: new ip_conntrack_sctp
Date: Mon, 2 Aug 2004 01:03:38 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040801230338.GE18758@sunbeam2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6e7ZaeXHKrTJCxdu"
Cc: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	netdev@oss.sgi.com, immidi_kiran@yahoo.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: David Miller <davem@redhat.com>
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--6e7ZaeXHKrTJCxdu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Incremental to all other patches so far, there is also the new SCTP
conntrack helper by Kiran Kumar.  Please apply for 2.6.9 ++, thanks.

Signed-off-by: Kiran Kumar Immidi <immidi_kiran@yahoo.com>
Signed-off-by: Harald Welte <laforge@netfilter.org>

Please apply, thanks.

diff --exclude-from /sunbeam/home/laforge/scripts/dontdiff -Nru linux-2.6.8=
-rc2-nfquilt/include/linux/netfilter_ipv4/ip_conntrack.h linux-2.6.8-rc2-nf=
quilt-nfp/include/linux/netfilter_ipv4/ip_conntrack.h
--- linux-2.6.8-rc2-nfquilt/include/linux/netfilter_ipv4/ip_conntrack.h	200=
4-08-02 00:51:27.793033003 +0200
+++ linux-2.6.8-rc2-nfquilt-nfp/include/linux/netfilter_ipv4/ip_conntrack.h=
	2004-08-02 00:52:49.107882646 +0200
@@ -51,10 +51,12 @@
=20
 #include <linux/netfilter_ipv4/ip_conntrack_tcp.h>
 #include <linux/netfilter_ipv4/ip_conntrack_icmp.h>
+#include <linux/netfilter_ipv4/ip_conntrack_sctp.h>
=20
 /* per conntrack: protocol private data */
 union ip_conntrack_proto {
 	/* insert conntrack proto private data here */
+	struct ip_ct_sctp sctp;
 	struct ip_ct_tcp tcp;
 	struct ip_ct_icmp icmp;
 };
diff --exclude-from /sunbeam/home/laforge/scripts/dontdiff -Nru linux-2.6.8=
-rc2-nfquilt/include/linux/netfilter_ipv4/ip_conntrack_sctp.h linux-2.6.8-r=
c2-nfquilt-nfp/include/linux/netfilter_ipv4/ip_conntrack_sctp.h
--- linux-2.6.8-rc2-nfquilt/include/linux/netfilter_ipv4/ip_conntrack_sctp.=
h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.8-rc2-nfquilt-nfp/include/linux/netfilter_ipv4/ip_conntrack_s=
ctp.h	2004-08-02 00:52:49.088883383 +0200
@@ -0,0 +1,25 @@
+#ifndef _IP_CONNTRACK_SCTP_H
+#define _IP_CONNTRACK_SCTP_H
+/* SCTP tracking. */
+
+enum sctp_conntrack {
+	SCTP_CONNTRACK_NONE,
+	SCTP_CONNTRACK_CLOSED,
+	SCTP_CONNTRACK_COOKIE_WAIT,
+	SCTP_CONNTRACK_COOKIE_ECHOED,
+	SCTP_CONNTRACK_ESTABLISHED,
+	SCTP_CONNTRACK_SHUTDOWN_SENT,
+	SCTP_CONNTRACK_SHUTDOWN_RECD,
+	SCTP_CONNTRACK_SHUTDOWN_ACK_SENT,
+	SCTP_CONNTRACK_MAX
+};
+
+struct ip_ct_sctp
+{
+	enum sctp_conntrack state;
+
+	u_int32_t vtag[IP_CT_DIR_MAX];
+	u_int32_t ttag[IP_CT_DIR_MAX];
+};
+
+#endif /* _IP_CONNTRACK_SCTP_H */
diff --exclude-from /sunbeam/home/laforge/scripts/dontdiff -Nru linux-2.6.8=
-rc2-nfquilt/include/linux/netfilter_ipv4/ip_conntrack_tuple.h linux-2.6.8-=
rc2-nfquilt-nfp/include/linux/netfilter_ipv4/ip_conntrack_tuple.h
--- linux-2.6.8-rc2-nfquilt/include/linux/netfilter_ipv4/ip_conntrack_tuple=
=2Eh	2004-06-16 07:19:43.000000000 +0200
+++ linux-2.6.8-rc2-nfquilt-nfp/include/linux/netfilter_ipv4/ip_conntrack_t=
uple.h	2004-08-02 00:52:49.143881251 +0200
@@ -25,6 +25,9 @@
 	struct {
 		u_int16_t id;
 	} icmp;
+	struct {
+		u_int16_t port;
+	} sctp;
 };
=20
 /* The manipulable part of the tuple. */
@@ -55,6 +58,9 @@
 			struct {
 				u_int8_t type, code;
 			} icmp;
+			struct {
+				u_int16_t port;
+			} sctp;
 		} u;
=20
 		/* The protocol. */
diff --exclude-from /sunbeam/home/laforge/scripts/dontdiff -Nru linux-2.6.8=
-rc2-nfquilt/include/linux/sysctl.h linux-2.6.8-rc2-nfquilt-nfp/include/lin=
ux/sysctl.h
--- linux-2.6.8-rc2-nfquilt/include/linux/sysctl.h	2004-08-01 23:52:00.0215=
86979 +0200
+++ linux-2.6.8-rc2-nfquilt-nfp/include/linux/sysctl.h	2004-08-02 00:52:49.=
146881135 +0200
@@ -410,6 +410,13 @@
 	NET_IPV4_NF_CONNTRACK_ICMP_TIMEOUT=3D12,
 	NET_IPV4_NF_CONNTRACK_GENERIC_TIMEOUT=3D13,
 	NET_IPV4_NF_CONNTRACK_BUCKETS=3D14,
+	NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_CLOSED=3D15,
+	NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_COOKIE_WAIT=3D16,
+	NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_COOKIE_ECHOED=3D17,
+	NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_ESTABLISHED=3D18,
+	NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_SENT=3D19,
+	NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_RECD=3D20,
+	NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_ACK_SENT=3D21,
 };
 =20
 /* /proc/sys/net/ipv6 */
diff --exclude-from /sunbeam/home/laforge/scripts/dontdiff -Nru linux-2.6.8=
-rc2-nfquilt/net/ipv4/netfilter/Kconfig linux-2.6.8-rc2-nfquilt-nfp/net/ipv=
4/netfilter/Kconfig
--- linux-2.6.8-rc2-nfquilt/net/ipv4/netfilter/Kconfig	2004-08-02 00:51:27.=
223055074 +0200
+++ linux-2.6.8-rc2-nfquilt-nfp/net/ipv4/netfilter/Kconfig	2004-08-02 00:52=
:49.115882336 +0200
@@ -636,5 +636,9 @@
 	tristate  'SCTP protocol match support'
 	depends on IP_NF_IPTABLES
=20
+config IP_NF_CT_PROTO_SCTP
+	tristate  'SCTP protocol connection tracking support (EXPERIMENTAL)'
+	depends on IP_NF_CONNTRACK && EXPERIMENTAL
+
 endmenu
=20
diff --exclude-from /sunbeam/home/laforge/scripts/dontdiff -Nru linux-2.6.8=
-rc2-nfquilt/net/ipv4/netfilter/Makefile linux-2.6.8-rc2-nfquilt-nfp/net/ip=
v4/netfilter/Makefile
--- linux-2.6.8-rc2-nfquilt/net/ipv4/netfilter/Makefile	2004-08-02 00:51:27=
=2E224055035 +0200
+++ linux-2.6.8-rc2-nfquilt-nfp/net/ipv4/netfilter/Makefile	2004-08-02 00:5=
2:49.117882259 +0200
@@ -19,6 +19,9 @@
 # connection tracking
 obj-$(CONFIG_IP_NF_CONNTRACK) +=3D ip_conntrack.o
=20
+# SCTP protocol connection tracking
+obj-$(CONFIG_IP_NF_CT_PROTO_SCTP) +=3D ip_conntrack_proto_sctp.o
+
 # connection tracking helpers
 obj-$(CONFIG_IP_NF_AMANDA) +=3D ip_conntrack_amanda.o
 obj-$(CONFIG_IP_NF_TFTP) +=3D ip_conntrack_tftp.o
diff --exclude-from /sunbeam/home/laforge/scripts/dontdiff -Nru linux-2.6.8=
-rc2-nfquilt/net/ipv4/netfilter/ip_conntrack_proto_sctp.c linux-2.6.8-rc2-n=
fquilt-nfp/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
--- linux-2.6.8-rc2-nfquilt/net/ipv4/netfilter/ip_conntrack_proto_sctp.c	19=
70-01-01 01:00:00.000000000 +0100
+++ linux-2.6.8-rc2-nfquilt-nfp/net/ipv4/netfilter/ip_conntrack_proto_sctp.=
c	2004-08-02 00:52:49.098882995 +0200
@@ -0,0 +1,650 @@
+/*
+ * Connection tracking protocol helper module for SCTP.
+ *=20
+ * SCTP is defined in RFC 2960. References to various sections in this cod=
e=20
+ * are to this RFC.
+ *=20
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/*
+ * Added support for proc manipulation of timeouts.
+ */
+
+#include <linux/types.h>
+#include <linux/sched.h>
+#include <linux/timer.h>
+#include <linux/netfilter.h>
+#include <linux/module.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/sctp.h>
+#include <linux/string.h>
+
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
+#include <linux/netfilter_ipv4/lockhelp.h>
+
+#if 0
+#define DEBUGP(format, ...) printk(format, ## __VA_ARGS__)
+#else
+#define DEBUGP(format, args...)
+#endif
+
+/* Protects conntrack->proto.sctp */
+static DECLARE_RWLOCK(sctp_lock);
+
+/* FIXME: Examine ipfilter's timeouts and conntrack transitions more
+   closely.  They're more complex. --RR=20
+
+   And so for me for SCTP :D -Kiran */
+
+static const char *sctp_conntrack_names[] =3D {
+	"NONE",
+	"CLOSED",
+	"COOKIE_WAIT",
+	"COOKIE_ECHOED",
+	"ESTABLISHED",
+	"SHUTDOWN_SENT",
+	"SHUTDOWN_RECD",
+	"SHUTDOWN_ACK_SENT",
+};
+
+#define SECS  * HZ
+#define MINS  * 60 SECS
+#define HOURS * 60 MINS
+#define DAYS  * 24 HOURS
+
+unsigned long ip_ct_sctp_timeout_closed            =3D  10 SECS;
+unsigned long ip_ct_sctp_timeout_cookie_wait       =3D   3 SECS;
+unsigned long ip_ct_sctp_timeout_cookie_echoed     =3D   3 SECS;
+unsigned long ip_ct_sctp_timeout_established       =3D   5 DAYS;
+unsigned long ip_ct_sctp_timeout_shutdown_sent     =3D 300 SECS / 1000;
+unsigned long ip_ct_sctp_timeout_shutdown_recd     =3D 300 SECS / 1000;
+unsigned long ip_ct_sctp_timeout_shutdown_ack_sent =3D   3 SECS;
+
+static unsigned long * sctp_timeouts[]
+=3D { 0,                                     /* SCTP_CONNTRACK_NONE  */
+    &ip_ct_sctp_timeout_closed,	           /* SCTP_CONNTRACK_CLOSED */
+    &ip_ct_sctp_timeout_cookie_wait,       /* SCTP_CONNTRACK_COOKIE_WAIT */
+    &ip_ct_sctp_timeout_cookie_echoed,     /* SCTP_CONNTRACK_COOKIE_ECHOED=
 */
+    &ip_ct_sctp_timeout_established,       /* SCTP_CONNTRACK_ESTABLISHED */
+    &ip_ct_sctp_timeout_shutdown_sent,     /* SCTP_CONNTRACK_SHUTDOWN_SENT=
 */
+    &ip_ct_sctp_timeout_shutdown_recd,     /* SCTP_CONNTRACK_SHUTDOWN_RECD=
 */
+    &ip_ct_sctp_timeout_shutdown_ack_sent  /* SCTP_CONNTRACK_SHUTDOWN_ACK_=
SENT */
+ };
+
+#define sNO SCTP_CONNTRACK_NONE
+#define	sCL SCTP_CONNTRACK_CLOSED
+#define	sCW SCTP_CONNTRACK_COOKIE_WAIT
+#define	sCE SCTP_CONNTRACK_COOKIE_ECHOED
+#define	sES SCTP_CONNTRACK_ESTABLISHED
+#define	sSS SCTP_CONNTRACK_SHUTDOWN_SENT
+#define	sSR SCTP_CONNTRACK_SHUTDOWN_RECD
+#define	sSA SCTP_CONNTRACK_SHUTDOWN_ACK_SENT
+#define	sIV SCTP_CONNTRACK_MAX
+
+/*=20
+	These are the descriptions of the states:
+
+NOTE: These state names are tantalizingly similar to the states of an=20
+SCTP endpoint. But the interpretation of the states is a little different,
+considering that these are the states of the connection and not of an end=
=20
+point. Please note the subtleties. -Kiran
+
+NONE              - Nothing so far.
+COOKIE WAIT       - We have seen an INIT chunk in the original direction, =
or also=20
+                    an INIT_ACK chunk in the reply direction.
+COOKIE ECHOED     - We have seen a COOKIE_ECHO chunk in the original direc=
tion.
+ESTABLISHED       - We have seen a COOKIE_ACK in the reply direction.
+SHUTDOWN_SENT     - We have seen a SHUTDOWN chunk in the original directio=
n.
+SHUTDOWN_RECD     - We have seen a SHUTDOWN chunk in the reply directoin.
+SHUTDOWN_ACK_SENT - We have seen a SHUTDOWN_ACK chunk in the direction opp=
osite
+                    to that of the SHUTDOWN chunk.
+CLOSED            - We have seen a SHUTDOWN_COMPLETE chunk in the directio=
n of=20
+                    the SHUTDOWN chunk. Connection is closed.
+*/
+
+/* TODO
+ - I have assumed that the first INIT is in the original direction.=20
+ This messes things when an INIT comes in the reply direction in CLOSED
+ state.
+ - Check the error type in the reply dir before transitioning from=20
+cookie echoed to closed.
+ - Sec 5.2.4 of RFC 2960
+ - Multi Homing support.
+*/
+
+/* SCTP conntrack state transitions */
+static enum sctp_conntrack sctp_conntracks[2][9][SCTP_CONNTRACK_MAX] =3D {
+	{
+/*	ORIGINAL	*/
+/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA */
+/* init         */ {sCW, sCW, sCW, sCE, sES, sSS, sSR, sSA},
+/* init_ack     */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},
+/* abort        */ {sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
+/* shutdown     */ {sCL, sCL, sCW, sCE, sSS, sSS, sSR, sSA},
+/* shutdown_ack */ {sSA, sCL, sCW, sCE, sES, sSA, sSA, sSA},
+/* error        */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Cant have S=
tale cookie*/
+/* cookie_echo  */ {sCL, sCL, sCE, sCE, sES, sSS, sSR, sSA},/* 5.2.4 - Big=
 TODO */
+/* cookie_ack   */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Cant come i=
n orig dir */
+/* shutdown_comp*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sCL}
+	},
+	{
+/*	REPLY	*/
+/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA */
+/* init         */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* INIT in sCL=
 Big TODO */
+/* init_ack     */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},
+/* abort        */ {sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
+/* shutdown     */ {sIV, sCL, sCW, sCE, sSR, sSS, sSR, sSA},
+/* shutdown_ack */ {sIV, sCL, sCW, sCE, sES, sSA, sSA, sSA},
+/* error        */ {sIV, sCL, sCW, sCL, sES, sSS, sSR, sSA},
+/* cookie_echo  */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Cant come i=
n reply dir */
+/* cookie_ack   */ {sIV, sCL, sCW, sES, sES, sSS, sSR, sSA},
+/* shutdown_comp*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sCL}
+	}
+};
+
+static int sctp_pkt_to_tuple(const struct sk_buff *skb,
+			     unsigned int dataoff,
+			     struct ip_conntrack_tuple *tuple)
+{
+	sctp_sctphdr_t hdr;
+
+	DEBUGP(__FUNCTION__);
+	DEBUGP("\n");
+
+	/* Actually only need first 8 bytes. */
+	if (skb_copy_bits(skb, dataoff, &hdr, 8) !=3D 0)
+		return 0;
+
+	tuple->src.u.sctp.port =3D hdr.source;
+	tuple->dst.u.sctp.port =3D hdr.dest;
+
+	return 1;
+}
+
+static int sctp_invert_tuple(struct ip_conntrack_tuple *tuple,
+			     const struct ip_conntrack_tuple *orig)
+{
+	DEBUGP(__FUNCTION__);
+	DEBUGP("\n");
+
+	tuple->src.u.sctp.port =3D orig->dst.u.sctp.port;
+	tuple->dst.u.sctp.port =3D orig->src.u.sctp.port;
+	return 1;
+}
+
+/* Print out the per-protocol part of the tuple. */
+static unsigned int sctp_print_tuple(char *buffer,
+				     const struct ip_conntrack_tuple *tuple)
+{
+	DEBUGP(__FUNCTION__);
+	DEBUGP("\n");
+
+	return sprintf(buffer, "sport=3D%hu dport=3D%hu ",
+		       ntohs(tuple->src.u.sctp.port),
+		       ntohs(tuple->dst.u.sctp.port));
+}
+
+/* Print out the private part of the conntrack. */
+static unsigned int sctp_print_conntrack(char *buffer,
+					 const struct ip_conntrack *conntrack)
+{
+	enum sctp_conntrack state;
+
+	DEBUGP(__FUNCTION__);
+	DEBUGP("\n");
+
+	READ_LOCK(&sctp_lock);
+	state =3D conntrack->proto.sctp.state;
+	READ_UNLOCK(&sctp_lock);
+
+	return sprintf(buffer, "%s ", sctp_conntrack_names[state]);
+}
+
+#define for_each_sctp_chunk(skb, sch, offset, count)	\
+for (offset =3D skb->nh.iph->ihl * 4 + sizeof (sctp_sctphdr_t), count =3D =
0;	\
+	offset < skb->len && !skb_copy_bits(skb, offset, &sch, sizeof(sch));	\
+	offset +=3D (htons(sch.length) + 3) & ~3, count++)
+
+/* Some validity checks to make sure the chunks are fine */
+static int do_basic_checks(struct ip_conntrack *conntrack,
+			   const struct sk_buff *skb,
+			   char *map)
+{
+	u_int32_t offset, count;
+	sctp_chunkhdr_t sch;
+	int flag;
+
+	DEBUGP(__FUNCTION__);
+	DEBUGP("\n");
+
+	flag =3D 0;
+
+	for_each_sctp_chunk (skb, sch, offset, count) {
+		DEBUGP("Chunk Num: %d  Type: %d\n", count, sch.type);
+
+		if (sch.type =3D=3D SCTP_CID_INIT=20
+			|| sch.type =3D=3D SCTP_CID_INIT_ACK
+			|| sch.type =3D=3D SCTP_CID_SHUTDOWN_COMPLETE) {
+			flag =3D 1;
+		}
+
+		/* Cookie Ack/Echo chunks not the first OR=20
+		   Init / Init Ack / Shutdown compl chunks not the only chunks */
+		if ((sch.type =3D=3D SCTP_CID_COOKIE_ACK=20
+			|| sch.type =3D=3D SCTP_CID_COOKIE_ECHO
+			|| flag)
+		     && count !=3D0 ) {
+			DEBUGP("Basic checks failed\n");
+			return 1;
+		}
+
+		if (map) {
+			set_bit (sch.type, (void *)map);
+		}
+	}
+
+	DEBUGP("Basic checks passed\n");
+	return 0;
+}
+
+static int new_state(enum ip_conntrack_dir dir,
+		     enum sctp_conntrack cur_state,
+		     int chunk_type)
+{
+	int i;
+
+	DEBUGP(__FUNCTION__);
+	DEBUGP("\n");
+
+	DEBUGP("Chunk type: %d\n", chunk_type);
+
+	switch (chunk_type) {
+		case SCTP_CID_INIT:=20
+			DEBUGP("SCTP_CID_INIT\n");
+			i =3D 0; break;
+		case SCTP_CID_INIT_ACK:=20
+			DEBUGP("SCTP_CID_INIT_ACK\n");
+			i =3D 1; break;
+		case SCTP_CID_ABORT:=20
+			DEBUGP("SCTP_CID_ABORT\n");
+			i =3D 2; break;
+		case SCTP_CID_SHUTDOWN:=20
+			DEBUGP("SCTP_CID_SHUTDOWN\n");
+			i =3D 3; break;
+		case SCTP_CID_SHUTDOWN_ACK:=20
+			DEBUGP("SCTP_CID_SHUTDOWN_ACK\n");
+			i =3D 4; break;
+		case SCTP_CID_ERROR:=20
+			DEBUGP("SCTP_CID_ERROR\n");
+			i =3D 5; break;
+		case SCTP_CID_COOKIE_ECHO:=20
+			DEBUGP("SCTP_CID_COOKIE_ECHO\n");
+			i =3D 6; break;
+		case SCTP_CID_COOKIE_ACK:=20
+			DEBUGP("SCTP_CID_COOKIE_ACK\n");
+			i =3D 7; break;
+		case SCTP_CID_SHUTDOWN_COMPLETE:=20
+			DEBUGP("SCTP_CID_SHUTDOWN_COMPLETE\n");
+			i =3D 8; break;
+		default:
+			/* Other chunks like DATA, SACK, HEARTBEAT and
+			its ACK do not cause a change in state */
+			DEBUGP("Unknown chunk type, Will stay in %s\n",=20
+						sctp_conntrack_names[cur_state]);
+			return cur_state;
+	}
+
+	DEBUGP("dir: %d   cur_state: %s  chunk_type: %d  new_state: %s\n",=20
+			dir, sctp_conntrack_names[cur_state], chunk_type,
+			sctp_conntrack_names[sctp_conntracks[dir][i][cur_state]]);
+
+	return sctp_conntracks[dir][i][cur_state];
+}
+
+/* Returns verdict for packet, or -1 for invalid. */
+static int sctp_packet(struct ip_conntrack *conntrack,
+		       const struct sk_buff *skb,
+		       enum ip_conntrack_info ctinfo)
+{
+	enum sctp_conntrack newconntrack, oldsctpstate;
+	sctp_sctphdr_t sctph;
+	sctp_chunkhdr_t sch;
+	u_int32_t offset, count;
+	char map[256 / sizeof (char)] =3D {0};
+
+	DEBUGP(__FUNCTION__);
+	DEBUGP("\n");
+
+	if (skb_copy_bits(skb, skb->nh.iph->ihl * 4, &sctph, sizeof(sctph)) !=3D =
0)
+		return -1;
+
+	if (do_basic_checks(conntrack, skb, map) !=3D 0)
+		return -1;
+
+	/* Check the verification tag (Sec 8.5) */
+	if (!test_bit(SCTP_CID_INIT, (void *)map)
+		&& !test_bit(SCTP_CID_SHUTDOWN_COMPLETE, (void *)map)
+		&& !test_bit(SCTP_CID_COOKIE_ECHO, (void *)map)
+		&& !test_bit(SCTP_CID_ABORT, (void *)map)
+		&& !test_bit(SCTP_CID_SHUTDOWN_ACK, (void *)map)
+		&& (sctph.vtag !=3D conntrack->proto.sctp.vtag[CTINFO2DIR(ctinfo)])) {
+		DEBUGP("Verification tag check failed\n");
+		return -1;
+	}
+
+	oldsctpstate =3D newconntrack =3D SCTP_CONNTRACK_MAX;
+	for_each_sctp_chunk (skb, sch, offset, count) {
+		WRITE_LOCK(&sctp_lock);
+
+		/* Special cases of Verification tag check (Sec 8.5.1) */
+		if (sch.type =3D=3D SCTP_CID_INIT) {
+			/* Sec 8.5.1 (A) */
+			if (sctph.vtag !=3D 0) {
+				WRITE_UNLOCK(&sctp_lock);
+				return -1;
+			}
+		} else if (sch.type =3D=3D SCTP_CID_ABORT) {
+			/* Sec 8.5.1 (B) */
+			if (!(sctph.vtag =3D=3D conntrack->proto.sctp.vtag[CTINFO2DIR(ctinfo)])
+				&& !(sctph.vtag =3D=3D conntrack->proto.sctp.vtag
+							[1 - CTINFO2DIR(ctinfo)])) {
+				WRITE_UNLOCK(&sctp_lock);
+				return -1;
+			}
+		} else if (sch.type =3D=3D SCTP_CID_SHUTDOWN_COMPLETE) {
+			/* Sec 8.5.1 (C) */
+			if (!(sctph.vtag =3D=3D conntrack->proto.sctp.vtag[CTINFO2DIR(ctinfo)])
+				&& !(sctph.vtag =3D=3D conntrack->proto.sctp.vtag
+							[1 - CTINFO2DIR(ctinfo)]=20
+					&& (sch.flags & 1))) {
+				WRITE_UNLOCK(&sctp_lock);
+				return -1;
+			}
+		} else if (sch.type =3D=3D SCTP_CID_COOKIE_ECHO) {
+			/* Sec 8.5.1 (D) */
+			if (!(sctph.vtag =3D=3D conntrack->proto.sctp.vtag[CTINFO2DIR(ctinfo)])=
) {
+				WRITE_UNLOCK(&sctp_lock);
+				return -1;
+			}
+		}
+
+		oldsctpstate =3D conntrack->proto.sctp.state;
+		newconntrack =3D new_state(CTINFO2DIR(ctinfo), oldsctpstate, sch.type);
+
+		/* Invalid */
+		if (newconntrack =3D=3D SCTP_CONNTRACK_MAX) {
+			DEBUGP("ip_conntrack_sctp: Invalid dir=3D%i ctype=3D%u conntrack=3D%u\n=
",
+			       CTINFO2DIR(ctinfo), sch.type, oldsctpstate);
+			WRITE_UNLOCK(&sctp_lock);
+			return -1;
+		}
+
+		/* If it is an INIT or an INIT ACK note down the vtag */
+		if (sch.type =3D=3D SCTP_CID_INIT=20
+			|| sch.type =3D=3D SCTP_CID_INIT_ACK) {
+			sctp_inithdr_t inithdr;
+
+			if (skb_copy_bits(skb, offset + sizeof (sctp_chunkhdr_t),
+				&inithdr, sizeof(inithdr)) !=3D 0) {
+					WRITE_UNLOCK(&sctp_lock);
+					return -1;
+			}
+			DEBUGP("Setting vtag %x for dir %d\n",=20
+					inithdr.init_tag, CTINFO2DIR(ctinfo));
+			conntrack->proto.sctp.vtag[IP_CT_DIR_ORIGINAL] =3D inithdr.init_tag;
+		}
+
+		conntrack->proto.sctp.state =3D newconntrack;
+		WRITE_UNLOCK(&sctp_lock);
+	}
+
+	ip_ct_refresh(conntrack, *sctp_timeouts[newconntrack]);
+
+	if (oldsctpstate =3D=3D SCTP_CONNTRACK_COOKIE_ECHOED
+		&& CTINFO2DIR(ctinfo) =3D=3D IP_CT_DIR_REPLY
+		&& newconntrack =3D=3D SCTP_CONNTRACK_ESTABLISHED) {
+		DEBUGP("Setting assured bit\n");
+		set_bit(IPS_ASSURED_BIT, &conntrack->status);
+	}
+
+	return NF_ACCEPT;
+}
+
+/* Called when a new connection for this protocol found. */
+static int sctp_new(struct ip_conntrack *conntrack,=20
+		    const struct sk_buff *skb)
+{
+	enum sctp_conntrack newconntrack;
+	sctp_sctphdr_t sctph;
+	sctp_chunkhdr_t sch;
+	u_int32_t offset, count;
+	char map[256 / sizeof (char)] =3D {0};
+
+	DEBUGP(__FUNCTION__);
+	DEBUGP("\n");
+
+	if (skb_copy_bits(skb, skb->nh.iph->ihl * 4, &sctph, sizeof(sctph)) !=3D =
0)
+		return -1;
+
+	if (do_basic_checks(conntrack, skb, map) !=3D 0)
+		return -1;
+
+	/* If an OOTB packet has any of these chunks discard (Sec 8.4) */
+	if ((test_bit (SCTP_CID_ABORT, (void *)map))
+		|| (test_bit (SCTP_CID_SHUTDOWN_COMPLETE, (void *)map))
+		|| (test_bit (SCTP_CID_COOKIE_ACK, (void *)map))) {
+		return -1;
+	}
+
+	newconntrack =3D SCTP_CONNTRACK_MAX;
+	for_each_sctp_chunk (skb, sch, offset, count) {
+		/* Don't need lock here: this conntrack not in circulation yet */
+		newconntrack =3D new_state (IP_CT_DIR_ORIGINAL,=20
+						SCTP_CONNTRACK_NONE, sch.type);
+
+		/* Invalid: delete conntrack */
+		if (newconntrack =3D=3D SCTP_CONNTRACK_MAX) {
+			DEBUGP("ip_conntrack_sctp: invalid new deleting.\n");
+			return 0;
+		}
+
+		/* Copy the vtag into the state info */
+		if (sch.type =3D=3D SCTP_CID_INIT) {
+			if (sctph.vtag =3D=3D 0) {
+				sctp_inithdr_t inithdr;
+
+				if (skb_copy_bits(skb, offset + sizeof (sctp_chunkhdr_t),=20
+					&inithdr, sizeof(inithdr)) !=3D 0) {
+						return -1;
+				}
+
+				DEBUGP("Setting vtag %x for new conn\n",=20
+					inithdr.init_tag);
+
+				conntrack->proto.sctp.vtag[IP_CT_DIR_REPLY] =3D=20
+								inithdr.init_tag;
+			} else {
+				/* Sec 8.5.1 (A) */
+				return -1;
+			}
+		}
+		/* If it is a shutdown ack OOTB packet, we expect a return
+		   shutdown complete, otherwise an ABORT Sec 8.4 (5) and (8) */
+		else {
+			DEBUGP("Setting vtag %x for new conn OOTB\n",=20
+				sctph.vtag);
+			conntrack->proto.sctp.vtag[IP_CT_DIR_REPLY] =3D sctph.vtag;
+		}
+
+		conntrack->proto.sctp.state =3D newconntrack;
+	}
+
+	return 1;
+}
+
+static int sctp_exp_matches_pkt(struct ip_conntrack_expect *exp,
+				const struct sk_buff *skb)
+{
+	/* To be implemented */
+	return 0;
+}
+
+struct ip_conntrack_protocol ip_conntrack_protocol_sctp =3D {=20
+	.list 		 =3D { NULL, NULL },=20
+	.proto 		 =3D IPPROTO_SCTP,=20
+	.name 		 =3D "sctp",
+	.pkt_to_tuple 	 =3D sctp_pkt_to_tuple,=20
+	.invert_tuple 	 =3D sctp_invert_tuple,=20
+	.print_tuple 	 =3D sctp_print_tuple,=20
+	.print_conntrack =3D sctp_print_conntrack,
+	.packet 	 =3D sctp_packet,=20
+	.new 		 =3D sctp_new,=20
+	.destroy 	 =3D NULL,=20
+	.exp_matches_pkt =3D sctp_exp_matches_pkt,=20
+	.me 		 =3D THIS_MODULE=20
+};
+
+#ifdef CONFIG_SYSCTL
+static ctl_table ip_ct_sysctl_table[] =3D {
+	{
+		.ctl_name	=3D NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_CLOSED,
+		.procname	=3D "ip_conntrack_sctp_timeout_closed",
+		.data		=3D &ip_ct_sctp_timeout_closed,
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	=3D NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_COOKIE_WAIT,
+		.procname	=3D "ip_conntrack_sctp_timeout_cookie_wait",
+		.data		=3D &ip_ct_sctp_timeout_cookie_wait,
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	=3D NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_COOKIE_ECHOED,
+		.procname	=3D "ip_conntrack_sctp_timeout_cookie_echoed",
+		.data		=3D &ip_ct_sctp_timeout_cookie_echoed,
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	=3D NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_ESTABLISHED,
+		.procname	=3D "ip_conntrack_sctp_timeout_established",
+		.data		=3D &ip_ct_sctp_timeout_established,
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	=3D NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_SENT,
+		.procname	=3D "ip_conntrack_sctp_timeout_shutdown_sent",
+		.data		=3D &ip_ct_sctp_timeout_shutdown_sent,
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	=3D NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_RECD,
+		.procname	=3D "ip_conntrack_sctp_timeout_shutdown_recd",
+		.data		=3D &ip_ct_sctp_timeout_shutdown_recd,
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	=3D NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_ACK_SENT,
+		.procname	=3D "ip_conntrack_sctp_timeout_shutdown_ack_sent",
+		.data		=3D &ip_ct_sctp_timeout_shutdown_ack_sent,
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_jiffies,
+	},
+	{ .ctl_name =3D 0 }
+};
+
+static ctl_table ip_ct_netfilter_table[] =3D {
+	{
+		.ctl_name	=3D NET_IPV4_NETFILTER,
+		.procname	=3D "netfilter",
+		.mode		=3D 0555,
+		.child		=3D ip_ct_sysctl_table,
+	},
+	{ .ctl_name =3D 0 }
+};
+
+static ctl_table ip_ct_ipv4_table[] =3D {
+	{
+		.ctl_name	=3D NET_IPV4,
+		.procname	=3D "ipv4",
+		.mode		=3D 0555,
+		.child		=3D ip_ct_netfilter_table,
+	},
+	{ .ctl_name =3D 0 }
+};
+
+static ctl_table ip_ct_net_table[] =3D {
+	{
+		.ctl_name	=3D CTL_NET,
+		.procname	=3D "net",
+		.mode		=3D 0555,=20
+		.child		=3D ip_ct_ipv4_table,
+	},
+	{ .ctl_name =3D 0 }
+};
+
+static struct ctl_table_header *ip_ct_sysctl_header;
+#endif
+
+int __init init(void)
+{
+	int ret;
+
+	ret =3D ip_conntrack_protocol_register(&ip_conntrack_protocol_sctp);
+	if (ret) {
+		printk("ip_conntrack_proto_sctp: protocol register failed\n");
+		goto out;
+	}
+
+#ifdef CONFIG_SYSCTL
+	ip_ct_sysctl_header =3D register_sysctl_table(ip_ct_net_table, 0);
+	if (ip_ct_sysctl_header =3D=3D NULL) {
+		printk("ip_conntrack_proto_sctp: can't register to sysctl.\n");
+		goto cleanup;
+	}
+#endif
+
+	return ret;
+
+ cleanup:
+#ifdef CONFIG_SYSCTL
+	ip_conntrack_protocol_unregister(&ip_conntrack_protocol_sctp);
+#endif
+ out:
+	DEBUGP("SCTP conntrack module loading %s\n",=20
+					ret ? "failed": "succeeded");
+	return ret;
+}
+
+void __exit fini(void)
+{
+	ip_conntrack_protocol_unregister(&ip_conntrack_protocol_sctp);
+#ifdef CONFIG_SYSCTL
+ 	unregister_sysctl_table(ip_ct_sysctl_header);
+#endif
+	DEBUGP("SCTP conntrack module unloaded\n");
+}
+
+module_init(init);
+module_exit(fini);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Kiran Kumar Immidi");
+MODULE_DESCRIPTION("Netfilter connection tracking protocol helper for SCTP=
");

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--6e7ZaeXHKrTJCxdu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBDXbKXaXGVTD0i/8RAuE0AKCpndyX/rb5mdL8ryi/8ZIk8a8V4gCfWeme
AXWAfdrWrFUBmvMdhd9nWIY=
=w/3I
-----END PGP SIGNATURE-----

--6e7ZaeXHKrTJCxdu--
