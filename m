From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH iproute] ip: add support for multicast rules
Date: Tue, 13 Apr 2010 17:06:24 +0200
Message-ID: <4BC48870.7070704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060304040000040606040002"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51328 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab0DMPGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:06:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060304040000040606040002
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This patch adds support for a "ip mrule" command, which is used
to configure multicast routing rules.

The corresponding kernel patches have been sent to Dave and
should (hopefully) appear in net-next soon.

--------------060304040000040606040002
Content-Type: text/x-patch;
 name="mrule.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mrule.diff"

>From 1c21ad3ad0a5cd10d1f8cf9c7c5f5b28ae558103 Mon Sep 17 00:00:00 2001
From: Patrick McHardy <kaber@trash.net>
Date: Tue, 13 Apr 2010 17:03:47 +0200
Subject: [PATCH] ip: add support for multicast rules

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/fib_rules.h |    8 ++++++++
 ip/ip.c                   |    3 ++-
 ip/ip_common.h            |    1 +
 ip/iprule.c               |   12 ++++++++++++
 4 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 51da65b..04a3976 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -15,6 +15,14 @@
 /* try to find source address in routing lookups */
 #define FIB_RULE_FIND_SADDR	0x00010000
 
+/* fib_rules families. values up to 127 are reserved for real address
+ * families, values above 128 may be used arbitrarily.
+ */
+#define FIB_RULES_IPV4		AF_INET
+#define FIB_RULES_IPV6		AF_INET6
+#define FIB_RULES_DECNET	AF_DECnet
+#define FIB_RULES_IPMR		128
+
 struct fib_rule_hdr {
 	__u8		family;
 	__u8		dst_len;
diff --git a/ip/ip.c b/ip/ip.c
index e0cf175..9f29533 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -42,7 +42,7 @@ static void usage(void)
 "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
-"                   tunnel | tuntap | maddr | mroute | monitor | xfrm }\n"
+"                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
 "                    -o[neline] | -t[imestamp] | -b[atch] [filename] |\n"
@@ -76,6 +76,7 @@ static const struct cmd {
 	{ "monitor",	do_ipmonitor },
 	{ "xfrm",	do_xfrm },
 	{ "mroute",	do_multiroute },
+	{ "mrule",	do_multirule },
 	{ "help",	do_help },
 	{ 0 }
 };
diff --git a/ip/ip_common.h b/ip/ip_common.h
index c857667..a114186 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -37,6 +37,7 @@ extern int do_iplink(int argc, char **argv);
 extern int do_ipmonitor(int argc, char **argv);
 extern int do_multiaddr(int argc, char **argv);
 extern int do_multiroute(int argc, char **argv);
+extern int do_multirule(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
diff --git a/ip/iprule.c b/ip/iprule.c
index 7140375..abb8752 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -436,3 +436,15 @@ int do_iprule(int argc, char **argv)
 	exit(-1);
 }
 
+int do_multirule(int argc, char **argv)
+{
+	if (preferred_family == AF_UNSPEC ||
+	    preferred_family == AF_INET)
+		preferred_family = FIB_RULES_IPMR;
+	else {
+		fprintf(stderr, "Multicast rules are only supported for IPv4\n");
+		exit(-1);
+	}
+
+	return do_iprule(argc, argv);
+}
-- 
1.7.0.4


--------------060304040000040606040002--
