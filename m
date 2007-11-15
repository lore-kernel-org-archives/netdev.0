From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 01/01] iproute2-2.6.23: RFC4214 Support (v2.2)
Date: Wed, 14 Nov 2007 22:46:23 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2C@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC18@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC20@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC25@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2A@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:53329 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932475AbXKOGqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 01:46:34 -0500
Content-class: urn:content-classes:message
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2A@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <fred.l.templin@boeing.com>

This patch includes support for the Intra-Site Automatic Tunnel
Addressing Protocol (ISATAP) per RFC4214.

The following diffs are specific to the iproute2-2.6.23
software distribution. This message includes the full and
patchable diff text; please use this version to apply patches.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- iproute2-2.6.23/ip/iptunnel.c.orig	2007-11-08 16:27:24.000000000 -0800
+++ iproute2-2.6.23/ip/iptunnel.c	2007-11-12 06:53:38.000000000 -0800
@@ -39,7 +39,8 @@ static void usage(void) __attribute__((n
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip tunnel { add | change | del | show } [ NAME ]\n");
-	fprintf(stderr, "          [ mode { ipip | gre | sit } ] [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ]\n");
+	fprintf(stderr, "          [ remote ADDR ] [ local ADDR ] [ router ADDR ] [ lifetime NUMBER ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "\n");
@@ -55,6 +56,9 @@ static int parse_args(int argc, char **a
 {
 	int count = 0;
 	char medium[IFNAMSIZ];
+	int isatap = 0;
+	unsigned router = 0;
+	unsigned lifetime = 0;
 
 	memset(p, 0, sizeof(*p));
 	memset(&medium, 0, sizeof(medium));
@@ -90,6 +94,13 @@ static int parse_args(int argc, char **a
 					exit(-1);
 				}
 				p->iph.protocol = IPPROTO_IPV6;
+			} else if (strcmp(*argv, "isatap") == 0) {
+				if (p->iph.protocol && p->iph.protocol != IPPROTO_IPV6) {
+					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
+					exit(-1);
+				}
+				p->iph.protocol = IPPROTO_IPV6;
+				isatap++;
 			} else {
 				fprintf(stderr,"Cannot guess tunnel mode.\n");
 				exit(-1);
@@ -160,6 +171,18 @@ static int parse_args(int argc, char **a
 			NEXT_ARG();
 			if (strcmp(*argv, "any"))
 				p->iph.saddr = get_addr32(*argv);
+		} else if (strcmp(*argv, "router") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "any"))
+				router = get_addr32(*argv);
+		} else if (strcmp(*argv, "lifetime") == 0) {
+			unsigned uval;
+			NEXT_ARG();
+			if (get_unsigned(&uval, *argv, 0)) {
+				invarg("invalid lifetime\n", *argv);
+				exit(-1);
+			}
+			lifetime = uval;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			strncpy(medium, *argv, IFNAMSIZ-1);
@@ -212,6 +235,10 @@ static int parse_args(int argc, char **a
 			p->iph.protocol = IPPROTO_IPIP;
 		else if (memcmp(p->name, "sit", 3) == 0)
 			p->iph.protocol = IPPROTO_IPV6;
+		else if (memcmp(p->name, "isatap", 6) == 0) {
+			p->iph.protocol = IPPROTO_IPV6;
+			isatap++;
+		}
 	}
 
 	if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
@@ -239,6 +266,20 @@ static int parse_args(int argc, char **a
 		fprintf(stderr, "Broadcast tunnel requires a source address.\n");
 		return -1;
 	}
+	if (isatap) {
+		if (p->iph.daddr) {
+			fprintf(stderr, "no remote with isatap.\n");
+			return -1;
+		}
+		p->i_key = router ? router : INADDR_NONE;
+		p->o_key = lifetime ? lifetime : 120;	/* RFC4214 default */
+	} else {
+		if (router || lifetime) {
+			fprintf(stderr, "router/lifetime only for isatap.\n");
+			return -1;
+		}
+	}
+
 	return 0;
 }
