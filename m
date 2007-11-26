From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 01/01] iproute2-2.6.23: RFC4214 Support (v2.5)
Date: Mon, 26 Nov 2007 09:20:07 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC46@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC18@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC20@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC25@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2A@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2C@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC40@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>,
	"Vlad Yasevich" <vladislav.yasevich@hp.com>,
	"Stephane Bortzmeyer" <bortzmeyer@nic.fr>,
	"David Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:52516 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755575AbXKZRVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 12:21:00 -0500
Content-class: urn:content-classes:message
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC40@XCH-NW-7V2.nw.nos.boeing.com>
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
+++ iproute2-2.6.23/ip/iptunnel.c	2007-11-19 05:57:47.000000000 -0800
@@ -39,7 +39,7 @@ static void usage(void) __attribute__((n
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip tunnel { add | change | del | show } [ NAME ]\n");
-	fprintf(stderr, "          [ mode { ipip | gre | sit } ] [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ] [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "\n");
@@ -55,6 +55,7 @@ static int parse_args(int argc, char **a
 {
 	int count = 0;
 	char medium[IFNAMSIZ];
+	int isatap = 0;
 
 	memset(p, 0, sizeof(*p));
 	memset(&medium, 0, sizeof(medium));
@@ -90,6 +91,13 @@ static int parse_args(int argc, char **a
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
@@ -212,6 +220,10 @@ static int parse_args(int argc, char **a
 			p->iph.protocol = IPPROTO_IPIP;
 		else if (memcmp(p->name, "sit", 3) == 0)
 			p->iph.protocol = IPPROTO_IPV6;
+		else if (memcmp(p->name, "isatap", 6) == 0) {
+			p->iph.protocol = IPPROTO_IPV6;
+			isatap++;
+		}
 	}
 
 	if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
@@ -239,6 +251,14 @@ static int parse_args(int argc, char **a
 		fprintf(stderr, "Broadcast tunnel requires a source address.\n");
 		return -1;
 	}
+	if (isatap) {
+		if (p->iph.daddr) {
+			fprintf(stderr, "no remote with isatap.\n");
+			return -1;
+		}
+		p->i_flags |= SIT_ISATAP;
+	}
+
 	return 0;
 }
