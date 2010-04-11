From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: [PATCH] netstat 1.42 patch adding ROSE support
Date: Sun, 11 Apr 2010 19:22:49 +0200
Message-ID: <4BC20569.5030504@upmc.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060001050007080203090405"
To: dc6iq@insu1.etec.uni-karlsruhe.de, net-tools@lina.inka.de,
	Linux Netdev List <netdev@vger.kernel.org>, philb@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:57454 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752336Ab0DKRXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Apr 2010 13:23:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060001050007080203090405
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

In netstat README file one can read :

"route/netstat -r do not yet support different address families
cleanly.  IPX/DDP/AX25 people, please feel free to add the code."

This is why I am sending this patch against netstat v 1.42 included 
in net-tools 1.60-23. 
The patch adds AMPR ROSE address family support as may be seen here :

[root@f6bvp-11 net-tools-1.60-23]# netstat -V
net-tools 1.60
netstat 1.42 (2001-04-15)
Fred Baumgarten, Alan Cox, Bernd Eckenfels, Phil Blundell, Tuan Hoang and others
+NEW_ADDRT +RTF_IRTT +RTF_REJECT -FW_MASQUERADE -I18N
AF: (inet) +UNIX +INET -INET6 -IPX +AX25 +NETROM -X25 -ATALK -ECONET +ROSE 
HW:  +ETHER -ARC -SLIP -PPP -TUNNEL -TR +AX25 +NETROM -X25 -FR +ROSE -ASH -SIT -FDDI -HIPPI -HDLC/LAPB 

[root@f6bvp-11 net-tools-1.60-23]# netstat -h
usage: netstat [-veenNcCF] [<Af>] -r         netstat {-V|--version|-h|--help}
------
------
 <Socket>={-t|--tcp} {-u|--udp} {-w|--raw} {-x|--unix} --ax25 --ipx --netrom --rose
  <AF>=Use '-A <af>' or '--<af>'; default: inet
  List of possible address families (which support routing):
    inet (DARPA Internet) ax25 (AMPR AX.25) netrom (AMPR NET/ROM) 
    rose (AMPR ROSE) 

[root@f6bvp-11 net-tools-1.60-23]# netstat --rose
Active ROSE sockets
dest_addr   dest_call  src_addr    src_call  dev   lci neigh   state
2080175520  WP-0       2080175502  WP-0      rose0  32    16   ESTABLISHED
*           *          2080175502  FE6BVP-1  rose0   0     0   LISTENING
2080175520  F6BVP-1    2080175502  F6BVP-12  rose0   0     0   LISTENING
2080175502  FPAD-0     2080175502  WP-0      rose0  32     1   ESTABLISHED
2080428501  F4BWT-10   2080175502  F6BVP-0   rose0   0     0   LISTENING
*           *          2080175502  ROUTE-0   rose0   0     0   LISTENING
*           *          2080175502  F6BVP-15  rose0   0     0   LISTENING
*           *          2080175502  WP-0      rose0   0     0   LISTENING
2080175502  WP-0       2080175502  FPAD-0    rose0   1     1   ESTABLISHED
*           *          2080175502  ??????-?  rose0   0     0   LISTENING

Bernard Pidoux


--------------060001050007080203090405
Content-Type: text/plain;
 name="net-tools-1.60-23.netstat.rose.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="net-tools-1.60-23.netstat.rose.patch"

diff -ruN net-tools-1.60-23/config.in net-tools-1.60-23/config.in
--- net-tools-1.60-23/config.in	2000-05-21 16:32:12.000000000 +0200
+++ net-tools-1.60-23/config.in	2009-11-21 17:19:02.937147071 +0100
@@ -54,7 +54,7 @@
 bool 'Appletalk DDP protocol family' HAVE_AFATALK y
 bool 'AX25 (packet radio) protocol family' HAVE_AFAX25 y
 bool 'NET/ROM (packet radio) protocol family' HAVE_AFNETROM y
-bool 'Rose (packet radio) protocol family' HAVE_AFROSE n
+bool 'Rose (packet radio) protocol family' HAVE_AFROSE y
 bool 'X.25 (CCITT) protocol family' HAVE_AFX25 y
 bool 'Econet protocol family' HAVE_AFECONET n
 bool 'DECnet protocol family' HAVE_AFDECnet n
@@ -71,7 +71,7 @@
 bool 'STRIP (Metricom radio) support' HAVE_HWSTRIP y
 bool 'Token ring (generic) support' HAVE_HWTR y
 bool 'AX25 (packet radio) support' HAVE_HWAX25 y
-bool 'Rose (packet radio) support' HAVE_HWROSE n
+bool 'Rose (packet radio) support' HAVE_HWROSE y
 bool 'NET/ROM (packet radio) support' HAVE_HWNETROM y
 bool 'X.25 (generic) support' HAVE_HWX25 y
 bool 'DLCI/FRAD (frame relay) support' HAVE_HWFR y
diff -ruN net-tools-1.60-23/lib/af.c net-tools-1.60-23/lib/af.c
--- net-tools-1.60-23/lib/af.c	2000-05-20 20:27:23.000000000 +0200
+++ net-tools-1.60-23/lib/af.c	2009-11-21 17:19:02.937147071 +0100
@@ -32,6 +32,7 @@
 int flag_ax25;
 int flag_ddp;
 int flag_netrom;
+int flag_rose;
 int flag_inet;
 int flag_inet6;
 int flag_econet;
@@ -64,6 +65,9 @@
 	"netrom", "netrom", &flag_netrom
     },
     {
+	"rose", "rose", &flag_rose
+    },
+    {
 	"inet", "inet", &flag_inet
     },
     {
@@ -100,6 +104,7 @@
 extern struct aftype inet6_aftype;
 extern struct aftype ax25_aftype;
 extern struct aftype netrom_aftype;
+extern struct aftype rose_aftype;
 extern struct aftype ipx_aftype;
 extern struct aftype ddp_aftype;
 extern struct aftype ec_aftype;
diff -ruN net-tools-1.60-23/lib/getroute.c net-tools-1.60-23/lib/getroute=
=2Ec
--- net-tools-1.60-23/lib/getroute.c	2000-05-20 20:27:23.000000000 +0200
+++ net-tools-1.60-23/lib/getroute.c	2009-11-21 17:19:02.937147071 +0100
@@ -44,6 +44,7 @@
 extern struct aftype inet6_aftype;
 extern struct aftype ax25_aftype;
 extern struct aftype netrom_aftype;
+extern struct aftype rose_aftype;
 extern struct aftype ipx_aftype;
 extern struct aftype ddp_aftype;
 extern struct aftype x25_aftype;
@@ -59,6 +60,9 @@
 #if HAVE_AFNETROM
     netrom_aftype.rprint =3D NETROM_rprint;
 #endif
+#if HAVE_AFROSE
+    rose_aftype.rprint =3D ROSE_rprint;
+#endif
 #if HAVE_AFAX25
     ax25_aftype.rprint =3D AX25_rprint;
 #endif
diff -ruN net-tools-1.60-23/lib/net-support.h net-tools-1.60-23/lib/net-s=
upport.h
--- net-tools-1.60-23/lib/net-support.h	2000-10-28 12:59:42.000000000 +02=
00
+++ net-tools-1.60-23/lib/net-support.h	2009-11-21 17:19:02.937147071 +01=
00
@@ -109,6 +109,7 @@
 extern int DDP_rprint(int options);
 extern int IPX_rprint(int options);
 extern int NETROM_rprint(int options);
+extern int ROSE_rprint(int options);
 extern int AX25_rprint(int options);
 extern int X25_rprint(int options);
=20
@@ -117,6 +118,7 @@
 extern int DDP_rinput(int action, int flags, char **argv);
 extern int IPX_rinput(int action, int flags, char **argv);
 extern int NETROM_rinput(int action, int flags, char **argv);
+extern int ROSE_rinput(int action, int flags, char **argv);
 extern int AX25_rinput(int action, int flags, char **argv);
 extern int X25_rinput(int action, int flags, char **argv);
=20
@@ -130,6 +132,7 @@
 extern int flag_ax25;
 extern int flag_ddp;
 extern int flag_netrom;
+extern int flag_rose;
 extern int flag_x25;
 extern int flag_inet;
 extern int flag_inet6;
@@ -143,6 +146,7 @@
 	{"ipx",         0,	0,	1}, \
 	{"appletalk",	0,	0,	1}, \
 	{"netrom",	0,	0,	1}, \
+       {"rose",        0,      0,      1}, \
 	{"inet",	0,	0,	1}, \
 	{"inet6",	0,	0,	1}, \
 	{"ddp",		0,	0,	1}, \
diff -ruN net-tools-1.60-23/lib/pathnames.h net-tools-1.60-23/lib/pathnam=
es.h
--- net-tools-1.60-23/lib/pathnames.h	2000-05-20 20:27:26.000000000 +0200=

+++ net-tools-1.60-23/lib/pathnames.h	2009-11-21 17:19:02.937147071 +0100=

@@ -41,6 +41,9 @@
 #define _PATH_PROCNET_DEV		"/proc/net/dev"
 #define _PATH_PROCNET_RARP		"/proc/net/rarp"
 #define _PATH_ETHERS			"/etc/ethers"
+#define _PATH_PROCNET_ROSE		"/proc/net/rose"
+#define _PATH_PROCNET_ROSE_NEIGH	"/proc/net/rose_neigh"
+#define _PATH_PROCNET_ROSE_NODES	"/proc/net/rose_nodes"
 #define _PATH_PROCNET_ROSE_ROUTE	"/proc/net/rose_routes"
 #define _PATH_PROCNET_X25              "/proc/net/x25"
 #define _PATH_PROCNET_X25_ROUTE                "/proc/net/x25_routes"
diff -ruN net-tools-1.60-23/lib/rose_gr.c net-tools-1.60-23/lib/rose_gr.c=

--- net-tools-1.60-23/lib/rose_gr.c	1999-01-09 16:55:24.000000000 +0100
+++ net-tools-1.60-23/lib/rose_gr.c	2009-11-21 17:19:02.937147071 +0100
@@ -11,6 +11,9 @@
  *              Copyright 1999 Bernd Eckenfels, Germany
  *              base on Code from Jonathan Naylor <jsn@Cs.Nott.AC.UK>
  *
+ *              Largely rewritten by Bernard Pidoux f6bvp@amsat.org
+ *              November 2009.             =20
+ *
  *              This program is free software; you can redistribute it
  *              and/or  modify it under  the terms of  the GNU General
  *              Public  License as  published  by  the  Free  Software
@@ -41,27 +44,48 @@
=20
 int ROSE_rprint(int options)
 {
-    FILE *f =3D NULL;
-    char buffer[256];
-    int use;
+    FILE *f1 =3D NULL;
+    FILE *f2 =3D NULL;
+    char buffer1[256], buffer2[256];
+    int i, neigh, use;
=20
-    f=3Dfopen(_PATH_PROCNET_ROSE_ROUTE, "r");
-    if (f =3D=3D NULL) {
-	perror(_PATH_PROCNET_ROSE_ROUTE);
+    f2=3Dfopen(_PATH_PROCNET_ROSE_NEIGH, "r");
+    f1=3Dfopen(_PATH_PROCNET_ROSE_NODES, "r");
+    if (f1 =3D=3D NULL) {
+	perror(_PATH_PROCNET_ROSE_NODES);
 	printf(_("ROSE not configured in this system.\n"));	/* xxx */
 	return 1;
     }
     printf(_("Kernel ROSE routing table\n"));
-    printf(_("Destination  Iface    Use\n"));
-    fgets(buffer, 256, f);
-    while (fgets(buffer, 256, f)) {
-	buffer[9] =3D 0;
-	buffer[14] =3D 0;
-	use =3D atoi(buffer + 15);
-	printf("%-9s    %-5s  %5d\n",
-	       buffer, buffer + 10, use);
+    printf(_("Destination  neigh1 callsign  device  neigh2 callsign  dev=
ice  neigh3 callsign  device\n"));
+    fgets(buffer1, 256, f1);
+    while (fgets(buffer1, 256, f1)) {
+	buffer1[10] =3D 0; /* address */
+	buffer1[15] =3D 0; /* mask */
+	buffer1[17] =3D 0; /* use */
+	buffer1[23] =3D 0; /* neigh 1 */
+	buffer1[29] =3D 0; /* neigh 2 */
+	buffer1[35] =3D 0; /* neigh 3 */
+/*	mask =3D atoi(buffer1 + 11); */
+	use =3D atoi(buffer1 + 16);
+	neigh =3D atoi(buffer1 + 18);
+	printf("%-10s   ", buffer1);
+	for (i=3D0; i < use; i++) {
+		neigh =3D atoi(buffer1 + 6*(i+3));
+		printf("%05d  ", neigh);
+		rewind(f2);
+		fgets(buffer2, 256, f2);
+		while (fgets(buffer2, 256, f2)) {
+			buffer2[15] =3D 0;
+			buffer2[21] =3D 0;
+			if (atoi(buffer2) =3D=3D neigh)
+				printf("%-10s   %-4s", buffer2 + 6, buffer2 + 16);
+    		}
+	}
+	printf("\n");
     }
-    fclose(f);
+    fclose(f1);
+    fclose(f2);
     return 0;
 }
=20
diff -ruN net-tools-1.60-23/netstat.c net-tools-1.60-23/netstat.c
--- net-tools-1.60-23/netstat.c	2001-04-15 16:41:17.000000000 +0200
+++ net-tools-1.60-23/netstat.c	2009-11-21 17:19:02.937147071 +0100
@@ -58,6 +58,7 @@
  *
  *990420 {1.38} Tuan Hoang              removed a useless assignment fro=
m igmp_do_one()
  *20010404 {1.39} Arnaldo Carvalho de Melo - use setlocale
+ *20091121      Bernard Pidoux          completed ampr ROSE support
  *
  *              This program is free software; you can redistribute it
  *              and/or  modify it under  the terms of  the GNU General
@@ -488,6 +489,49 @@
 }
 #endif
=20
+#if HAVE_AFROSE
+static const char *rose_state[] =3D
+{
+    N_("LISTENING"),
+    N_("CONN SENT"),
+    N_("DISC SENT"),
+    N_("ESTABLISHED")
+};
+
+static int rose_info(void)
+{
+    FILE *f;
+    char buffer[256], dev[6];
+    int ret, st, lci, neigh;
+    char src_addr[10], src_call[9], dest_addr[10], dest_call[9];
+
+    f =3D fopen(_PATH_PROCNET_ROSE, "r");
+    if (f =3D=3D NULL) {
+	if (errno !=3D ENOENT) {
+	    perror(_PATH_PROCNET_ROSE);
+	    return (-1);
+	}
+	if (flag_arg || flag_ver)
+	    ESYSNOT("netstat", "AF ROSE");
+	if (flag_arg)
+	    return (1);
+	else
+	    return (0);
+    }
+    printf(_("Active ROSE sockets\n"));
+    printf(_("dest_addr   dest_call  src_addr    src_call  dev   lci nei=
gh  state\n"));=20
+    fgets(buffer, 256, f);
+
+    while (fgets(buffer, 256, f)) {
+	ret =3D sscanf(buffer, "%s %s %s %s %s %d %d %d", dest_addr, dest_call,=
 src_addr, src_call, dev, &lci, &neigh, &st);
+	printf("%-10s  %-9s  %-10s  %-9s %-5s %3d %5d   %s\n", dest_addr, dest_=
call, src_addr, src_call, dev, lci, neigh, _(rose_state[st]));
+=09
+    }
+    fclose(f);
+    return 0;
+}
+#endif
+
 /* These enums are used by IPX too. :-( */
 enum {
     TCP_ESTABLISHED =3D 1,
@@ -1502,7 +1546,7 @@
     fprintf(stderr, _("        -F, --fib                display Forwardi=
ng Information Base (default)\n"));
     fprintf(stderr, _("        -C, --cache              display routing =
cache instead of FIB\n\n"));
=20
-    fprintf(stderr, _("  <Socket>=3D{-t|--tcp} {-u|--udp} {-w|--raw} {-x=
|--unix} --ax25 --ipx --netrom\n"));
+    fprintf(stderr, _("  <Socket>=3D{-t|--tcp} {-u|--udp} {-w|--raw} {-x=
|--unix} --ax25 --ipx --netrom --rose\n"));
     fprintf(stderr, _("  <AF>=3DUse '-A <af>' or '--<af>'; default: %s\n=
"), DFLT_AF);
     fprintf(stderr, _("  List of possible address families (which suppor=
t routing):\n"));
     print_aflist(1); /* 1 =3D routeable */
@@ -1665,7 +1709,7 @@
         flag_inet =3D flag_inet6 =3D 1;
=20
     flag_arg =3D flag_tcp + flag_udp + flag_raw + flag_unx + flag_ipx
-	+ flag_ax25 + flag_netrom + flag_igmp + flag_x25;
+	+ flag_ax25 + flag_netrom + flag_rose + flag_igmp + flag_x25;
=20
     if (flag_mas) {
 #if HAVE_FW_MASQUERADE && HAVE_AFINET
@@ -1845,6 +1889,18 @@
 	    }
 #endif
 	}
+	if (!flag_arg || flag_rose) {
+#if HAVE_AFROSE
+	    i =3D rose_info();
+	    if (i)
+		return (i);
+#else
+	    if (flag_arg) {
+		i =3D 1;
+		ENOSUPP("netstat", "AF ROSE");
+	    }
+#endif
+	}
 	if (!flag_cnt || i)
 	    break;
 	sleep(1);
@@ -1852,3 +1908,4 @@
     }
     return (i);
 }
+
diff -ruN net-tools-1.60-23/po/fr.po net-tools-1.60-23/po/fr.po
--- net-tools-1.60-23/po/fr.po	2000-02-20 22:47:00.000000000 +0100
+++ net-tools-1.60-23/po/fr.po	2009-11-21 17:19:02.937147071 +0100
@@ -797,7 +797,7 @@
=20
 #: ../netstat.c:394 ../netstat.c:1089 ../netstat.c:1166
 msgid "LISTENING"
-msgstr "LISTENING"
+msgstr "ECOUTE"
=20
 #: ../netstat.c:395
 msgid "CONN SENT"
@@ -809,11 +809,19 @@
=20
 #: ../netstat.c:397 ../netstat.c:464 ../netstat.c:809 ../netstat.c:1169
 msgid "ESTABLISHED"
-msgstr "ESTABLISHED"
+msgstr "ETABLIE"
=20
-#: ../netstat.c:419
+#: ../netstat.c:467
 msgid "Active NET/ROM sockets\n"
-msgstr "sockets NET/ROM actives\n"
+msgstr "Prises (sockets) NET/ROM actives\n"
+
+#: ../netstat.c:521
+msgid "Active ROSE sockets\n"
+msgstr "Prises (sockets) ROSE actives\n"
+
+#: ../netstat.c:522
+msgid "dest_addr   dest_call  src_addr    src_call  dev   lci neigh  sta=
te\n"=20
+msgstr "Destinat    call_dest  Source      call_src  Periph lci Voisin E=
tat \n"=20
=20
 #: ../netstat.c:420
 msgid ""
@@ -826,7 +834,7 @@
 #: ../netstat.c:430 ../netstat.c:1208
 #, c-format
 msgid "Problem reading data from %s\n"
-msgstr ""
+msgstr "Ne peut lire les donn=E9es de %s\n"
=20
 #: ../netstat.c:465
 msgid "SYN_SENT"
@@ -1008,7 +1016,7 @@
=20
 #: ../netstat.c:1184
 msgid "Active AX.25 sockets\n"
-msgstr "Sockets AX.25 actives\n"
+msgstr "Prises (sockets) AX.25 actives\n"
=20
 #: ../netstat.c:1185
 msgid "Dest       Source     Device  State        Vr/Vs    Send-Q  Recv-=
Q\n"

--------------060001050007080203090405--
