From: Nathaniel W Filardo <nwf@cs.jhu.edu>
Subject: New "ip wait" subcommand for iproute2
Date: Mon, 28 Dec 2015 18:47:51 -0500
Message-ID: <20151228234751.GH47562@gradx.cs.jhu.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FRnlOPVounx9/Gmj"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blaze.cs.jhu.edu ([128.220.13.50]:54957 "EHLO blaze.cs.jhu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbbL2Apm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2015 19:45:42 -0500
Received: from gradx.cs.jhu.edu (gradx.cs.jhu.edu [128.220.35.100])
	by blaze.cs.jhu.edu (8.14.4/8.14.4) with ESMTP id tBSNlqgo043589
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 18:47:52 -0500
Received: from gradx.cs.jhu.edu (localhost [127.0.0.1])
	by gradx.cs.jhu.edu (8.14.9/8.14.5) with ESMTP id tBSNlqX3027243
	for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 18:47:52 -0500
Received: (from nwf@localhost)
	by gradx.cs.jhu.edu (8.14.9/8.14.9/Submit) id tBSNlpww027242
	for netdev@vger.kernel.org; Mon, 28 Dec 2015 18:47:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FRnlOPVounx9/Gmj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hallo netdev@,

I had occasion to want to programmatically wait for an interface to become
available from within a shell script, but found there to be no off-the-shelf
tool for such a thing.  Could this patch be considered for inclusion as part
of iproute2?  It adds an "ip wait link" subcommand ("link" required in case
someone wants to add things like "ip wait addr" or somesuch) based quite
heavily on the ipmonitor.c file.

For example, one might "ip wait link dev eth0 up" to wait for an interface
of that name to appear (specifically, for a RTM_NEWLINK message).  "ip wait
link dev eth0 down" will wait for it to go away (RTM_DELLINK).

This should be checkpatch clean, but please let me know if I missed
something.

Cheers,
--nwf;

=46rom f6e0acbc07af9650cb5e66c0dec08e6e3e878f79 Mon Sep 17 00:00:00 2001
=46rom: Nathaniel Wesley Filardo <nwf@cs.jhu.edu>
Date: Mon, 28 Dec 2015 18:35:17 -0500
Subject: [PATCH] New 'ip wait' command

Signed-off-by: Nathaniel Filardo <nwf@cs.jhu.edu>
---
 ip/Makefile    |   2 +-
 ip/ip.c        |   3 +-
 ip/ip_common.h |   1 +
 ip/ipwait.c    | 149 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 4 files changed, 153 insertions(+), 2 deletions(-)
 create mode 100644 ip/ipwait.c

diff --git a/ip/Makefile b/ip/Makefile
index f3d2987..cf12af7 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -7,7 +7,7 @@ IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o i=
pnetns.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.=
o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
-    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o
+    iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipwait.o
=20
 RTMONOBJ=3Drtmon.o
=20
diff --git a/ip/ip.c b/ip/ip.c
index eea00b8..36d8a24 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -51,7 +51,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT :=3D { link | address | addrlabel | route | rule | neighbor=
 | ntable |\n"
 "                   tunnel | tuntap | maddress | mroute | mrule | monitor =
| xfrm |\n"
-"                   netns | l2tp | fou | tcp_metrics | token | netconf }\n"
+"                   netns | l2tp | fou | tcp_metrics | token | netconf | w=
ait }\n"
 "       OPTIONS :=3D { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve=
] |\n"
 "                    -h[uman-readable] | -iec |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge=
 | link } |\n"
@@ -97,6 +97,7 @@ static const struct cmd {
 	{ "mrule",	do_multirule },
 	{ "netns",	do_netns },
 	{ "netconf",	do_ipnetconf },
+	{ "wait",	do_ipwait },
 	{ "help",	do_help },
 	{ 0 }
 };
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 9a846df..5670b9b 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -54,6 +54,7 @@ int do_ipfou(int argc, char **argv);
 int do_tcp_metrics(int argc, char **argv);
 int do_ipnetconf(int argc, char **argv);
 int do_iptoken(int argc, char **argv);
+int do_ipwait(int argc, char **argv);
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
=20
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
diff --git a/ip/ipwait.c b/ip/ipwait.c
new file mode 100644
index 0000000..998fb21
--- /dev/null
+++ b/ip/ipwait.c
@@ -0,0 +1,149 @@
+/*
+ * ipwait.c		"ip wait".
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru> (ipmonitor.c)
+ *          Nathaniel Filardo <nwf@cs.jhu.edu> (this file)
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+#include <time.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void usage(void) __attribute__((noreturn));
+int listen_all_nsid;
+int wait_for;
+char *wait_dev;
+int verbose;
+
+static void usage(void)
+{
+	fprintf(stderr,
+		"Usage: ip wait [all-nsid] [verbose] link dev DEVICE {up | down}");
+	exit(-1);
+}
+
+static int accept_msg(const struct sockaddr_nl *who,
+		      struct rtnl_ctrl_data *ctrl,
+		      struct nlmsghdr *n, void *arg)
+{
+	int done =3D 0;
+
+	if (n->nlmsg_type =3D=3D RTM_NEWLINK || n->nlmsg_type =3D=3D RTM_DELLINK)=
 {
+		if (wait_for =3D=3D n->nlmsg_type
+		    && wait_for =3D=3D RTM_DELLINK
+		    && ll_name_to_index(wait_dev) !=3D 0)
+			done =3D 1;
+
+		ll_remember_index(who, n, NULL);
+		if (verbose)
+			print_linkinfo(who, n, stdout);
+
+		if (wait_for =3D=3D n->nlmsg_type
+		    && wait_for =3D=3D RTM_NEWLINK
+		    && ll_name_to_index(wait_dev) !=3D 0)
+			done =3D 1;
+	}
+	if (done) {
+		fflush(stdout);
+		exit(0);
+	}
+	return 0;
+}
+
+int do_ipwait(int argc, char **argv)
+{
+	unsigned groups =3D 0;
+	int llink =3D 0;
+	int wait_up =3D 0;
+	int wait_down =3D 0;
+
+	rtnl_close(&rth);
+
+	while (argc > 0) {
+		if (matches(*argv, "all-nsid") =3D=3D 0) {
+			listen_all_nsid =3D 1;
+		} else if (matches(*argv, "verbose") =3D=3D 0) {
+			verbose =3D 1;
+		} else if (matches(*argv, "link") =3D=3D 0) {
+			llink =3D 1;
+		} else if (matches(*argv, "up") =3D=3D 0) {
+			wait_up =3D 1;
+		} else if (matches(*argv, "down") =3D=3D 0) {
+			wait_down =3D 1;
+		} else if (strcmp(*argv, "dev") =3D=3D 0) {
+			NEXT_ARG();
+			wait_dev =3D *argv;
+		} else if (strcmp(*argv, "help") =3D=3D 0) {
+			usage();
+		} else {
+			fprintf(stderr,
+				"Argument \"%s\" is unknown, try \"ip wait help\".\n",
+				*argv);
+			exit(-1);
+		}
+		argc--;	argv++;
+	}
+
+	if (!wait_down)
+		wait_for =3D RTM_NEWLINK;
+	else if (!wait_up && wait_down)
+		wait_for =3D RTM_DELLINK;
+	else if (wait_up && wait_down) {
+		fprintf(stderr, "Please specify one direction to wait...\n");
+		exit(-1);
+	}
+	if (llink !=3D 1) {
+		fprintf(stderr, "Must specify link\n");
+		exit(-1);
+	}
+	if (wait_dev =3D=3D NULL) {
+		fprintf(stderr, "Must specify device\n");
+		exit(-1);
+	}
+	{
+		int ifindex =3D ll_name_to_index(wait_dev);
+
+		if (wait_up && ifindex)
+			exit(0);
+		if (wait_down && !ifindex)
+			exit(0);
+
+		ipaddr_reset_filter(1, ifindex);
+		iproute_reset_filter(ifindex);
+		ipmroute_reset_filter(ifindex);
+		ipneigh_reset_filter(ifindex);
+		ipnetconf_reset_filter(ifindex);
+	}
+
+	if (llink)
+		groups |=3D nl_mgrp(RTNLGRP_LINK);
+
+	if (rtnl_open(&rth, groups) < 0)
+		exit(1);
+	if (listen_all_nsid && rtnl_listen_all_nsid(&rth) < 0)
+		exit(1);
+
+	ll_init_map(&rth);
+	netns_map_init();
+
+	if (rtnl_listen(&rth, accept_msg, stdout) < 0)
+		exit(2);
+
+	return 0;
+}
--=20
2.6.4


--FRnlOPVounx9/Gmj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlaByicACgkQTeQabvr9Tc8Y0wCgg+KXYfdv9gnMsHEi60AofyIW
OlIAn1efPox3s2iVfYDLbppyLJ14p8ns
=/cJb
-----END PGP SIGNATURE-----

--FRnlOPVounx9/Gmj--
