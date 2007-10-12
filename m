From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPROUTE2: Support IPv4/IPv6 Tunnel
Date: Fri, 12 Oct 2007 16:51:22 +0900 (JST)
Message-ID: <20071012.165122.05747470.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	yasuyuki.kozakai@toshiba.co.jp
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53629 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbXJLHta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 03:49:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on patch from Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 6468d99..cbbdf9d 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -52,6 +52,7 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip -f inet6 tunnel { add | change | del | show } [ NAME ]\n");
+	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
 	fprintf(stderr, "          [ remote ADDR local ADDR ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ encaplimit ELIM ]\n");
 	fprintf(stderr ,"          [ hoplimit HLIM ] [ tc TC ] [ fl FL ]\n");
@@ -116,7 +117,24 @@ static int parse_args(int argc, char **argv, struct ip6_tnl_parm *p)
 	memset(medium, 0, sizeof(medium));
 
 	while (argc > 0) {
-		if (strcmp(*argv, "remote") == 0) {
+		if (strcmp(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "ipv6/ipv6") == 0 ||
+			    strcmp(*argv, "ip6ip6") == 0)
+				p->proto = IPPROTO_IPV6;
+			else if (strcmp(*argv, "ip/ipv6") == 0 ||
+				 strcmp(*argv, "ipv4/ipv6") == 0 ||
+				 strcmp(*argv, "ipip6") == 0 ||
+				 strcmp(*argv, "ip4ip6") == 0)
+				p->proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "any/ipv6") == 0 ||
+				 strcmp(*argv, "any") == 0)
+				p->proto = 0;
+			else {
+                                fprintf(stderr,"Cannot guess tunnel mode.\n");
+                                exit(-1);
+                        }
+                } else if (strcmp(*argv, "remote") == 0) {
 			inet_prefix raddr;
 			NEXT_ARG();
 			get_prefix(&raddr, *argv, preferred_family);
diff --git a/ip/tunnel.c b/ip/tunnel.c
index 5fede2c..104340d 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -51,6 +51,9 @@ const char *tnl_strproto(__u8 proto)
 	case IPPROTO_IPV6:
 		strcpy(buf, "ipv6");
 		break;
+	case 0:
+		strcpy(buf, "any");
+		break;
 	default:
 		strcpy(buf, "unknown");
 		break;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
