From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH iproute2 net-next 2/2] iproute: Add support for MPLS LWT ttl attribute
Date: Mon, 10 Apr 2017 15:36:12 +0100
Message-ID: <1491834972-26668-3-git-send-email-rshearma@brocade.com>
References: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>,
        Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35968 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753539AbdDJOhE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:37:04 -0400
In-Reply-To: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for setting and displaying the ttl attribute
for MPLS IP lighweight tunnels.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 ip/iproute_lwtunnel.c  | 31 +++++++++++++++++++++++++++++--
 man/man8/ip-route.8.in |  9 ++++++++-
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 0fa1cab0a790..845a115e9e41 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -84,6 +84,9 @@ static void print_encap_mpls(FILE *fp, struct rtattr *encap)
 	if (tb[MPLS_IPTUNNEL_DST])
 		fprintf(fp, " %s ",
 			format_host_rta(AF_MPLS, tb[MPLS_IPTUNNEL_DST]));
+	if (tb[MPLS_IPTUNNEL_TTL])
+		fprintf(fp, "ttl %u ",
+			rta_getattr_u8(tb[MPLS_IPTUNNEL_TTL]));
 }
 
 static void print_encap_ip(FILE *fp, struct rtattr *encap)
@@ -247,6 +250,7 @@ static int parse_encap_mpls(struct rtattr *rta, size_t len,
 	inet_prefix addr;
 	int argc = *argcp;
 	char **argv = *argvp;
+	int ttl_ok = 0;
 
 	if (get_addr(&addr, *argv, AF_MPLS)) {
 		fprintf(stderr,
@@ -258,8 +262,31 @@ static int parse_encap_mpls(struct rtattr *rta, size_t len,
 	rta_addattr_l(rta, len, MPLS_IPTUNNEL_DST, &addr.data,
 		      addr.bytelen);
 
-	*argcp = argc;
-	*argvp = argv;
+	argc--;
+	argv++;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "ttl") == 0) {
+			__u8 ttl;
+
+			NEXT_ARG();
+			if (ttl_ok++)
+				duparg2("ttl", *argv);
+			if (get_u8(&ttl, *argv, 0))
+				invarg("\"ttl\" value is invalid\n", *argv);
+			rta_addattr8(rta, len, MPLS_IPTUNNEL_TTL, ttl);
+		} else {
+			break;
+		}
+		argc--; argv++;
+	}
+
+	/* argv is currently the first unparsed argument,
+	 * but the lwt_parse_encap() caller will move to the next,
+	 * so step back
+	 */
+	*argcp = argc + 1;
+	*argvp = argv - 1;
 
 	return 0;
 }
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index fbe2711a4301..d2a44acf2793 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -181,7 +181,9 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .ti -8
 .IR ENCAP_MPLS " := "
 .BR mpls " [ "
-.IR LABEL " ]"
+.IR LABEL " ] ["
+.B  ttl
+.IR TTL " ]"
 
 .ti -8
 .IR ENCAP_IP " := "
@@ -666,6 +668,11 @@ is a set of encapsulation attributes specific to the
 .I MPLSLABEL
 - mpls label stack with labels separated by
 .I "/"
+.sp
+
+.B ttl
+.I TTL
+- TTL to use for MPLS header or 0 to inherit from IP header
 .in -2
 .sp
 
-- 
2.1.4
