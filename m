From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH iproute/master 3/3] iptunnel: add support for mpls/ip to ipip tunnels
Date: Fri,  9 Jun 2017 18:31:32 -0700
Message-ID: <1497058292-10099-4-git-send-email-kjlx@templeofstupid.com>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
        dsahern@gmail.com, Krister Johansen <kjlx@templeofstupid.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:56429 "EHLO
        homiemail-a48.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751608AbdFJBcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 21:32:20 -0400
Received: from homiemail-a48.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a48.g.dreamhost.com (Postfix) with ESMTP id 8D1CD70D2B03
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 18:32:19 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a48.g.dreamhost.com (Postfix) with ESMTPSA id 5480270D2B0C
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 18:32:19 -0700 (PDT)
In-Reply-To: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original-Author: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
---
 ip/link_iptnl.c       | 21 ++++++++++++++++++++-
 man/man8/ip-link.8.in |  5 +++--
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index cf3a9ef..d24e737 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -50,6 +50,8 @@ static void print_usage(FILE *f, int sit)
 	if (sit) {
 		fprintf(f, "          [ mode { ip6ip | ipip | mplsip | any } ]\n");
 		fprintf(f, "          [ isatap ]\n");
+	} else {
+		fprintf(f, "          [ mode { ipip | mplsip | any } ]\n");
 	}
 	fprintf(f, "                [ external ]\n");
 	fprintf(f, "                [ fwmark MARK ]\n");
@@ -251,6 +253,21 @@ get_failed:
 				proto = 0;
 			else
 				invarg("Cannot guess tunnel mode.", *argv);
+		} else if (strcmp(lu->id, "ipip") == 0 &&
+			   strcmp(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "ipv4/ipv4") == 0 ||
+				 strcmp(*argv, "ipip") == 0 ||
+				 strcmp(*argv, "ip4ip4") == 0)
+				proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "mpls/ipv4") == 0 ||
+				   strcmp(*argv, "mplsip") == 0)
+				proto = IPPROTO_MPLS;
+			else if (strcmp(*argv, "any/ipv4") == 0 ||
+				 strcmp(*argv, "any") == 0)
+				proto = 0;
+			else
+				invarg("Cannot guess tunnel mode.", *argv);
 		} else if (strcmp(*argv, "noencap") == 0) {
 			encaptype = TUNNEL_ENCAP_NONE;
 		} else if (strcmp(*argv, "encap") == 0) {
@@ -343,9 +360,11 @@ get_failed:
 	addattr16(n, 1024, IFLA_IPTUN_ENCAP_SPORT, htons(encapsport));
 	addattr16(n, 1024, IFLA_IPTUN_ENCAP_DPORT, htons(encapdport));
 
+	if (strcmp(lu->id, "ipip") == 0 || strcmp(lu->id, "sit") == 0)
+		addattr8(n, 1024, IFLA_IPTUN_PROTO, proto);
+
 	if (strcmp(lu->id, "sit") == 0) {
 		addattr16(n, 1024, IFLA_IPTUN_FLAGS, iflags);
-		addattr8(n, 1024, IFLA_IPTUN_PROTO, proto);
 		if (ip6rdprefixlen) {
 			addattr_l(n, 1024, IFLA_IPTUN_6RD_PREFIX,
 				  &ip6rdprefix, sizeof(ip6rdprefix));
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 994b539..a782712 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -703,8 +703,9 @@ applicable for Generic UDP Encapsulation.
 .BI mode " { ip6ip | ipip | mplsip | any } "
 - specifies mode in which device should run. "ip6ip" indicates
 IPv6-Over-IPv4, "ipip" indicates "IPv4-Over-IPv4", "mplsip" indicates
-MPLS-Over-IPv4, "any" indicates IPv6, IPv4 or MPLS Over IPv4. Only
-supported for SIT where the default is "ip6ip".
+MPLS-Over-IPv4, "any" indicates IPv6, IPv4 or MPLS Over IPv4. Supported for
+SIT where the default is "ip6ip" and IPIP where the default is "ipip".
+IPv6-Over-IPv4 is not supported for IPIP.
 
 .in -8
 
-- 
2.7.4
