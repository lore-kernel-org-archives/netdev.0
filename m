From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/3] ip{6,}tunnel: Avoid copying user-supplied interface name around
Date: Tue, 26 Sep 2017 18:35:46 +0200
Message-ID: <20170926163548.24347-2-phil@nwl.cc>
References: <20170926163548.24347-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58106 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934771AbdIZQgF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 12:36:05 -0400
In-Reply-To: <20170926163548.24347-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In both files' parse_args() functions as well as in iptunnel's do_prl()
and do_6rd() functions, a user-supplied 'dev' parameter is uselessly
copied into a temporary buffer before passing it to ll_name_to_index()
or copying into a struct ifreq.  Avoid this by just caching the argv
pointer value until the later lookup/strcpy.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip6tunnel.c |  6 +++---
 ip/iptunnel.c  | 22 +++++++++-------------
 2 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index b4a7def144226..c12d700e74189 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -136,7 +136,7 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 {
 	int count = 0;
-	char medium[IFNAMSIZ] = {};
+	const char *medium = NULL;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "mode") == 0) {
@@ -180,7 +180,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 			memcpy(&p->laddr, &laddr.data, sizeof(p->laddr));
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ - 1);
+			medium = *argv;
 		} else if (strcmp(*argv, "encaplimit") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "none") == 0) {
@@ -285,7 +285,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 		count++;
 		argc--; argv++;
 	}
-	if (medium[0]) {
+	if (medium) {
 		p->link = ll_name_to_index(medium);
 		if (p->link == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", medium);
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 105d0f5576f1a..0acfd0793d3cd 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -60,7 +60,7 @@ static void set_tunnel_proto(struct ip_tunnel_parm *p, int proto)
 static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 {
 	int count = 0;
-	char medium[IFNAMSIZ] = {};
+	const char *medium = NULL;
 	int isatap = 0;
 
 	memset(p, 0, sizeof(*p));
@@ -139,7 +139,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				p->iph.saddr = htonl(INADDR_ANY);
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ - 1);
+			medium = *argv;
 		} else if (strcmp(*argv, "ttl") == 0 ||
 			   strcmp(*argv, "hoplimit") == 0 ||
 			   strcmp(*argv, "hlim") == 0) {
@@ -216,7 +216,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 		}
 	}
 
-	if (medium[0]) {
+	if (medium) {
 		p->link = ll_name_to_index(medium);
 		if (p->link == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", medium);
@@ -465,9 +465,8 @@ static int do_prl(int argc, char **argv)
 {
 	struct ip_tunnel_prl p = {};
 	int count = 0;
-	int devname = 0;
 	int cmd = 0;
-	char medium[IFNAMSIZ] = {};
+	const char *medium = NULL;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "prl-default") == 0) {
@@ -488,8 +487,7 @@ static int do_prl(int argc, char **argv)
 			count++;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ-1);
-			devname++;
+			medium = *argv;
 		} else {
 			fprintf(stderr,
 				"Invalid PRL parameter \"%s\"\n", *argv);
@@ -502,7 +500,7 @@ static int do_prl(int argc, char **argv)
 		}
 		argc--; argv++;
 	}
-	if (devname == 0) {
+	if (!medium) {
 		fprintf(stderr, "Must specify device\n");
 		exit(-1);
 	}
@@ -513,9 +511,8 @@ static int do_prl(int argc, char **argv)
 static int do_6rd(int argc, char **argv)
 {
 	struct ip_tunnel_6rd ip6rd = {};
-	int devname = 0;
 	int cmd = 0;
-	char medium[IFNAMSIZ] = {};
+	const char *medium = NULL;
 	inet_prefix prefix;
 
 	while (argc > 0) {
@@ -537,8 +534,7 @@ static int do_6rd(int argc, char **argv)
 			cmd = SIOCDEL6RD;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ-1);
-			devname++;
+			medium = *argv;
 		} else {
 			fprintf(stderr,
 				"Invalid 6RD parameter \"%s\"\n", *argv);
@@ -546,7 +542,7 @@ static int do_6rd(int argc, char **argv)
 		}
 		argc--; argv++;
 	}
-	if (devname == 0) {
+	if (!medium) {
 		fprintf(stderr, "Must specify device\n");
 		exit(-1);
 	}
-- 
2.13.1
