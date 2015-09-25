From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/3] ip: macvlan: support MACVLAN_FLAG_NOPROMISC flag
Date: Fri, 25 Sep 2015 14:09:50 +0200
Message-ID: <1443182991-4628-3-git-send-email-phil@nwl.cc>
References: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59522 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754432AbbIYMJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 08:09:53 -0400
In-Reply-To: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag is allowed for devices in passthru mode to prevent forcing the
underlying interface into promiscuous mode.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink_macvlan.c | 30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index d759f0e..f195e81 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -29,7 +29,7 @@
 static void print_explain(struct link_util *lu, FILE *f)
 {
 	fprintf(f,
-		"Usage: ... %s mode { private | vepa | bridge | passthru }\n",
+		"Usage: ... %s mode { private | vepa | bridge | passthru [nopromisc] }\n",
 		lu->id
 	);
 }
@@ -49,9 +49,11 @@ static int mode_arg(const char *arg)
 static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
+	__u32 mode = 0;
+	__u16 flags = 0;
+
 	while (argc > 0) {
 		if (matches(*argv, "mode") == 0) {
-			__u32 mode = 0;
 			NEXT_ARG();
 
 			if (strcmp(*argv, "private") == 0)
@@ -64,7 +66,8 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				mode = MACVLAN_MODE_PASSTHRU;
 			else
 				return mode_arg(*argv);
-			addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
+		} else if (matches(*argv, "nopromisc") == 0) {
+			flags |= MACVLAN_FLAG_NOPROMISC;
 		} else if (matches(*argv, "help") == 0) {
 			explain(lu);
 			return -1;
@@ -76,12 +79,25 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		argc--, argv++;
 	}
 
+	if (mode)
+		addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
+
+	if (flags) {
+		if (flags & MACVLAN_FLAG_NOPROMISC &&
+		    mode != MACVLAN_MODE_PASSTHRU) {
+			pfx_err(lu, "nopromisc flag only valid in passthru mode");
+			explain(lu);
+			return -1;
+		}
+		addattr16(n, 1024, IFLA_MACVLAN_FLAGS, flags);
+	}
 	return 0;
 }
 
 static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
 	__u32 mode;
+	__u16 flags;
 
 	if (!tb)
 		return;
@@ -97,6 +113,14 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
 		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
 		:				 "unknown");
+
+	if (!tb[IFLA_MACVLAN_FLAGS] ||
+	    RTA_PAYLOAD(tb[IFLA_MACVLAN_FLAGS]) < sizeof(__u16))
+		return;
+
+	flags = rta_getattr_u16(tb[IFLA_MACVLAN_FLAGS]);
+	if (flags & MACVLAN_FLAG_NOPROMISC)
+		fprintf(f, "nopromisc ");
 }
 
 static void macvlan_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.1.2
