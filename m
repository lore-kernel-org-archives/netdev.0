From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [IPROUTE2 PATCH 1/2]: Add more aliases for tunnel subcommand.
Date: Thu, 13 Mar 2008 11:17:54 -0400 (EDT)
Message-ID: <20080313.111754.126763958.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54031 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbYCMPQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 11:16:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add more aliases to synchronize IPv4 and IPv6 tunnel command, e.g.,
  IPv4: hoplimit (alias to ttl), tclass (alias to tos)
  IPv6: dsfield, tos (alias to tc, or tclass), ttl (alias to hoplimit)

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index cbbdf9d..8421983 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -55,17 +55,17 @@ static void usage(void)
 	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
 	fprintf(stderr, "          [ remote ADDR local ADDR ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ encaplimit ELIM ]\n");
-	fprintf(stderr ,"          [ hoplimit HLIM ] [ tc TC ] [ fl FL ]\n");
+	fprintf(stderr ,"          [ hoplimit TTL ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
 	fprintf(stderr, "          [ dscp inherit ]\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, "Where: NAME := STRING\n");
-	fprintf(stderr, "       ADDR := IPV6_ADDRESS\n");
-	fprintf(stderr, "       ELIM := { none | 0..255 }(default=%d)\n",
+	fprintf(stderr, "Where: NAME      := STRING\n");
+	fprintf(stderr, "       ADDR      := IPV6_ADDRESS\n");
+	fprintf(stderr, "       ELIM      := { none | 0..255 }(default=%d)\n",
 		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
-	fprintf(stderr, "       HLIM := 0..255 (default=%d)\n",
+	fprintf(stderr, "       TTL       := 0..255 (default=%d)\n",
 		DEFAULT_TNL_HOP_LIMIT);
-	fprintf(stderr, "       TC   := { 0x0..0xff | inherit }\n");
-	fprintf(stderr, "       FL   := { 0x0..0xfffff | inherit }\n");
+	fprintf(stderr, "       TOS       := { 0x0..0xff | inherit }\n");
+	fprintf(stderr, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
 	exit(-1);
 }
 
@@ -93,16 +93,16 @@ static void print_tunnel(struct ip6_tnl_parm *p)
 	printf(" hoplimit %u", p->hop_limit);
 
 	if (p->flags & IP6_TNL_F_USE_ORIG_TCLASS)
-		printf(" tc inherit");
+		printf(" tclass inherit");
 	else {
 		__u32 val = ntohl(p->flowinfo & IP6_FLOWINFO_TCLASS);
-		printf(" tc 0x%02x", (__u8)(val >> 20));
+		printf(" tclass 0x%02x", (__u8)(val >> 20));
 	}
 
 	if (p->flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
-		printf(" fl inherit");
+		printf(" flowlabel inherit");
 	else
-		printf(" fl 0x%05x", ntohl(p->flowinfo & IP6_FLOWINFO_FLOWLABEL));
+		printf(" flowlabel 0x%05x", ntohl(p->flowinfo & IP6_FLOWINFO_FLOWLABEL));
 
 	printf(" (flowinfo 0x%08x)", ntohl(p->flowinfo));
 
@@ -161,33 +161,39 @@ static int parse_args(int argc, char **argv, struct ip6_tnl_parm *p)
 					invarg("invalid ELIM", *argv);
 				p->encap_limit = uval;
 			}
-		} else if (strcmp(*argv, "hoplimit") == 0) {
+		} else if (strcmp(*argv, "hoplimit") == 0 ||
+			   strcmp(*argv, "ttl") == 0 ||
+			   strcmp(*argv, "hlim") == 0) {
 			__u8 uval;
 			NEXT_ARG();
 			if (get_u8(&uval, *argv, 0))
-				invarg("invalid HLIM", *argv);
+				invarg("invalid TTL", *argv);
 			p->hop_limit = uval;
-		} else if (strcmp(*argv, "tc") == 0) {
+		} else if (strcmp(*argv, "tclass") == 0 ||
+			   strcmp(*argv, "tc") == 0 ||
+			   strcmp(*argv, "tos") == 0 ||
+			   matches(*argv, "dsfield") == 0) {
 			__u8 uval;
 			NEXT_ARG();
 			if (strcmp(*argv, "inherit") == 0)
 				p->flags |= IP6_TNL_F_USE_ORIG_TCLASS;
 			else {
 				if (get_u8(&uval, *argv, 16))
-					invarg("invalid TC", *argv);
+					invarg("invalid TClass", *argv);
 				p->flowinfo |= htonl((__u32)uval << 20) & IP6_FLOWINFO_TCLASS;
 				p->flags &= ~IP6_TNL_F_USE_ORIG_TCLASS;
 			}
-		} else if (strcmp(*argv, "fl") == 0) {
+		} else if (strcmp(*argv, "flowlabel") == 0 ||
+			   strcmp(*argv, "fl") == 0) {
 			__u32 uval;
 			NEXT_ARG();
 			if (strcmp(*argv, "inherit") == 0)
 				p->flags |= IP6_TNL_F_USE_ORIG_FLOWLABEL;
 			else {
 				if (get_u32(&uval, *argv, 16))
-					invarg("invalid FL", *argv);
+					invarg("invalid Flowlabel", *argv);
 				if (uval > 0xFFFFF)
-					invarg("invalid FL", *argv);
+					invarg("invalid Flowlabel", *argv);
 				p->flowinfo |= htonl(uval) & IP6_FLOWINFO_FLOWLABEL;
 				p->flags &= ~IP6_TNL_F_USE_ORIG_FLOWLABEL;
 			}
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 3b466bf..769e845 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -171,7 +171,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			strncpy(medium, *argv, IFNAMSIZ-1);
-		} else if (strcmp(*argv, "ttl") == 0) {
+		} else if (strcmp(*argv, "ttl") == 0 ||
+			   strcmp(*argv, "hoplimit") == 0) {
 			unsigned uval;
 			NEXT_ARG();
 			if (strcmp(*argv, "inherit") != 0) {
@@ -182,6 +183,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				p->iph.ttl = uval;
 			}
 		} else if (strcmp(*argv, "tos") == 0 ||
+			   strcmp(*argv, "tclass") == 0 ||
 			   matches(*argv, "dsfield") == 0) {
 			__u32 uval;
 			NEXT_ARG();

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
