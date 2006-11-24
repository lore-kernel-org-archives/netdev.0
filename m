From: Masahide@neptune.linux-ipv6.org
Subject: [PATCH] [IP] ADDR: Enable to add IPv6 address with valid/preferred lifetime.
Date: Fri, 24 Nov 2006 12:11:21 +0900
Message-ID: <7067.1132569716$1164338323@news.gmane.org>
Cc: takamiya@po.ntts.co.jp, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:51925 "EHLO
	neptune.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S1757588AbWKXDQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 22:16:04 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Signed-off-by: TAKAMIYA Noriaki <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/ipaddress.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 592875a..ea27d42 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -60,7 +60,8 @@ static void usage(void)
 	if (do_link) {
 		iplink_usage();
 	}
-	fprintf(stderr, "Usage: ip addr {add|del} IFADDR dev STRING\n");
+	fprintf(stderr, "Usage: ip addr add IFADDR dev STRING [ LIFETIME ]\n");
+	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
 	fprintf(stderr, "       ip addr {show|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ]\n");
 	fprintf(stderr, "IFADDR := PREFIX | ADDR peer PREFIX\n");
@@ -70,6 +71,9 @@ static void usage(void)
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG  := [ permanent | dynamic | secondary | primary |\n");
 	fprintf(stderr, "           tentative | deprecated ]\n");
+	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
+	fprintf(stderr, "LFT := forever | SECONDS\n");
+
 	exit(-1);
 }
 
@@ -276,6 +280,16 @@ static int flush_update(void)
 	return 0;
 }
 
+static int set_lifetime(unsigned int *lifetime, char *argv)
+{
+	if (strcmp(argv, "forever") == 0)
+		*lifetime = 0xFFFFFFFFU;
+	else if (get_u32(lifetime, argv, 0))
+		return -1;
+
+	return 0;
+}
+
 int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n, 
 		   void *arg)
 {
@@ -742,6 +756,8 @@ int ipaddr_modify(int cmd, int argc, cha
 	char  *d = NULL;
 	char  *l = NULL;
 	char  *lcl_arg = NULL;
+	char  *valid_lftp = NULL;
+	char  *preferred_lftp = NULL;
 	inet_prefix lcl;
 	inet_prefix peer;
 	int local_len = 0;
@@ -749,6 +765,9 @@ int ipaddr_modify(int cmd, int argc, cha
 	int brd_len = 0;
 	int any_len = 0;
 	int scoped = 0;
+	__u32 preferred_lft = 0xFFFFFFFFU;
+	__u32 valid_lft = 0xFFFFFFFFU;
+	struct ifa_cacheinfo cinfo;
 
 	memset(&req, 0, sizeof(req));
 
@@ -811,6 +830,20 @@ int ipaddr_modify(int cmd, int argc, cha
 			NEXT_ARG();
 			l = *argv;
 			addattr_l(&req.n, sizeof(req), IFA_LABEL, l, strlen(l)+1);
+		} else if (matches(*argv, "valid_lft") == 0) {
+			if (valid_lftp)
+				duparg("valid_lft", *argv);
+			NEXT_ARG();
+			valid_lftp = *argv;
+			if (set_lifetime(&valid_lft, *argv))
+				invarg("valid_lft value", *argv);
+		} else if (matches(*argv, "preferred_lft") == 0) {
+			if (preferred_lftp)
+				duparg("preferred_lft", *argv);
+			NEXT_ARG();
+			preferred_lftp = *argv;
+			if (set_lifetime(&preferred_lft, *argv))
+				invarg("preferred_lft value", *argv);
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
@@ -881,6 +914,23 @@ int ipaddr_modify(int cmd, int argc, cha
 		return -1;
 	}
 
+	if (valid_lftp || preferred_lftp) {
+		if (!valid_lft) {
+			fprintf(stderr, "valid_lft is zero\n");
+			return -1;
+		}
+		if (valid_lft < preferred_lft) {
+			fprintf(stderr, "preferred_lft is greater than valid_lft\n");
+			return -1;
+		}
+
+		memset(&cinfo, 0, sizeof(cinfo));
+		cinfo.ifa_prefered = preferred_lft;
+		cinfo.ifa_valid = valid_lft;
+		addattr_l(&req.n, sizeof(req), IFA_CACHEINFO, &cinfo,
+			  sizeof(cinfo));
+	}
+
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
 		exit(2);
 
-- 
1.4.2

