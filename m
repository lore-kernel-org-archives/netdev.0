From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH v2 iproute2 net-next 1/2] iproute: Add support for ttl-propagation attribute
Date: Tue, 11 Apr 2017 09:37:20 +0100
Message-ID: <1491899841-1361-2-git-send-email-rshearma@brocade.com>
References: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
 <1491899841-1361-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:52740 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751365AbdDKIhp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 04:37:45 -0400
In-Reply-To: <1491899841-1361-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for setting and displaying the ttl-propagation attribute
initially used by MPLS to control propagation of MPLS TTL to IPv4/IPv6
TTL/hop-limit on popping final label on a per-route basis.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 ip/iproute.c           | 22 ++++++++++++++++++++++
 man/man8/ip-route.8.in | 10 +++++++++-
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 7cdf0726feb3..6f75319c944a 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -77,6 +77,7 @@ static void usage(void)
 	fprintf(stderr, "NODE_SPEC := [ TYPE ] PREFIX [ tos TOS ]\n");
 	fprintf(stderr, "             [ table TABLE_ID ] [ proto RTPROTO ]\n");
 	fprintf(stderr, "             [ scope SCOPE ] [ metric METRIC ]\n");
+	fprintf(stderr, "             [ ttl-propagate { enabled | disabled } ]\n");
 	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
 	fprintf(stderr, "NH := [ encap ENCAPTYPE ENCAPHDR ] [ via [ FAMILY ] ADDRESS ]\n");
 	fprintf(stderr, "	    [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
@@ -714,6 +715,13 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			fprintf(fp, "%u", pref);
 		}
 	}
+	if (tb[RTA_TTL_PROPAGATE]) {
+		fprintf(fp, "ttl-propagate ");
+		if (rta_getattr_u8(tb[RTA_TTL_PROPAGATE]))
+			fprintf(fp, "enabled");
+		else
+			fprintf(fp, "disabled");
+	}
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
@@ -1184,6 +1192,20 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 			if (rta->rta_len > RTA_LENGTH(0))
 				addraw_l(&req.n, 1024, RTA_DATA(rta), RTA_PAYLOAD(rta));
+		} else if (strcmp(*argv, "ttl-propagate") == 0) {
+			__u8 ttl_prop;
+
+			NEXT_ARG();
+			if (matches(*argv, "enabled") == 0)
+				ttl_prop = 1;
+			else if (matches(*argv, "disabled") == 0)
+				ttl_prop = 0;
+			else
+				invarg("\"ttl-propagate\" value is invalid\n",
+				       *argv);
+
+			addattr8(&req.n, sizeof(req), RTA_TTL_PROPAGATE,
+				 ttl_prop);
 		} else {
 			int type;
 			inet_prefix dst;
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index d6e06649a464..fbe2711a4301 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -75,7 +75,9 @@ replace " } "
 .B  scope
 .IR SCOPE " ] [ "
 .B  metric
-.IR METRIC " ]"
+.IR METRIC " ] [ "
+.B  ttl-propagate
+.RB "{ " enabled " | " disabled " } ]"
 
 .ti -8
 .IR INFO_SPEC " := " "NH OPTIONS FLAGS" " ["
@@ -710,6 +712,12 @@ is a set of encapsulation attributes specific to the
 the route will be deleted after the expires time.
 .B Only
 support IPv6 at present.
+
+.TP
+.BR ttl-propagate " { " enabled " | " disabled " } "
+Control whether TTL should be propagated from any encap into the
+un-encapsulated packet, overriding any global configuration. Only
+supported for MPLS at present.
 .RE
 
 .TP
-- 
2.1.4
